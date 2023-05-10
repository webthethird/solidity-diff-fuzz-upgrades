"""Module containing helper functions used in both path mode and fork mode."""

import os
import difflib
from typing import TYPE_CHECKING, List, Optional

# pylint: disable= no-name-in-module
from solc_select.solc_select import get_installable_versions
from slither.utils.upgradeability import (
    compare,
    tainted_inheriting_contracts,
    TaintedExternalContract,
)
from slither.core.declarations import Function
from slither.core.variables.state_variable import StateVariable
from diffusc.utils.classes import ContractData, Diff
from diffusc.utils.crytic_print import CryticPrint

if TYPE_CHECKING:
    from slither import Slither


def get_compilation_unit_name(slither_object: "Slither") -> str:
    """Get the name of the compilation unit from Slither."""

    name = list(slither_object.crytic_compile.compilation_units.keys())[0]
    if os.path.sep in name:
        name = name.rsplit(os.path.sep, maxsplit=1)[1]
    if name.endswith(".sol"):
        name = os.path.splitext(name)[0]
    return name


def get_pragma_version_from_file(filepath: str, seen: Optional[List[str]] = None) -> str:
    """Recursive function to determine minimum solc version required by a Solidity file."""

    if seen is None:
        seen = []
    try:
        with open(filepath, "r", encoding="utf-8") as file:
            lines = file.readlines()
    except FileNotFoundError:
        return "0.0.0"
    versions = [
        line.split("solidity")[1].split(";")[0].replace(" ", "")
        for line in lines
        if "pragma solidity" in line
    ]
    imports = [line for line in lines if "import" in line]
    files = [
        line.split()[1].split(";")[0].replace('"', "").replace("'", "")
        if line.startswith("import")
        else line.split()[1].replace('"', "").replace("'", "")
        for line in imports
    ]
    for path in files:
        if path.startswith("./"):
            path = path.replace("./", filepath.rsplit("/", maxsplit=1)[0] + "/")
        elif path.startswith("../"):
            path = path.replace("../", filepath.rsplit("/", maxsplit=2)[0] + "/")
        if path not in seen:
            seen.append(path)
            versions.append(get_pragma_version_from_file(path, seen))
    high_version = ["0", "0", "0"]
    for ver in versions:
        vers = ver.split(".")
        vers[0] = "0"
        if int(vers[1]) > int(high_version[1]) or (
            int(vers[1]) == int(high_version[1]) and int(vers[2]) > int(high_version[2])
        ):
            high_version = vers
            if ver.startswith(">") and not ver.startswith(">="):
                vers[2] = str(int(vers[2]) + 1)
                if ".".join(vers) not in get_installable_versions():
                    vers[1] = str(int(vers[1]) + 1)
                    vers[2] = "0"
                if ".".join(vers) in get_installable_versions():
                    high_version = vers
    return ".".join(high_version)


# pylint: disable=too-many-locals
def do_diff(
    v_1: ContractData,
    v_2: ContractData,
    additional_targets: Optional[List[ContractData]] = None,
    include_external: bool = False
) -> Diff:
    """Use slither.utils.upgradeability to perform a diff between two contract versions."""
    assert v_1["valid_data"] and v_2["valid_data"]

    CryticPrint.print_message("* Performing diff of V1 and V2")
    (
        missing_vars,
        new_vars,
        tainted_vars,
        new_funcs,
        modified_funcs,
        tainted_funcs,
        tainted_contracts,
    ) = compare(v_1["contract_object"], v_2["contract_object"], include_external)
    if additional_targets:
        tainted_contracts = tainted_inheriting_contracts(
            tainted_contracts,
            [
                t["contract_object"]
                for t in additional_targets
                if t["contract_object"]
                not in [c.contract for c in tainted_contracts]
                + [v_1["contract_object"], v_2["contract_object"]]
            ],
        )
    diff = Diff(
        missing_variables=missing_vars,
        new_variables=new_vars,
        tainted_variables=tainted_vars,
        new_functions=new_funcs,
        modified_functions=modified_funcs,
        tainted_functions=tainted_funcs,
        tainted_contracts=tainted_contracts,
    )
    for key, lst in diff.items():
        if isinstance(lst, list) and len(lst) > 0:
            CryticPrint.print_warning(f'  * {str(key).replace("-", " ")}:')
            for obj in lst:
                if isinstance(obj, StateVariable):
                    CryticPrint.print_warning(f"      * {obj.full_name}")
                elif isinstance(obj, Function):
                    CryticPrint.print_warning(f"      * {obj.signature_str}")
                elif isinstance(obj, TaintedExternalContract):
                    CryticPrint.print_warning(f"      * {obj.contract.name}")
                    for taint in obj.tainted_functions:
                        CryticPrint.print_warning(f"        * {taint.signature_str}")
                    for taint in obj.tainted_variables:
                        CryticPrint.print_warning(f"        * {taint.signature_str}")
    return diff


def similar(name1: str, name2: str) -> bool:
    """
    Test the name similarity
    Two names are similar if difflib.SequenceMatcher on the lowercase
    version of the name is greater than 0.90
    See: https://docs.python.org/2/library/difflib.html
    Args:
        name1 (str): first name
        name2 (str): second name
    Returns:
        bool: true if names are similar
    """

    val = difflib.SequenceMatcher(a=name1.lower(), b=name2.lower()).ratio()
    ret = val > 0.90
    return ret


def camel_case(name: str) -> str:
    """Convert a string to camel case."""

    parts = name.replace("_", " ").replace("-", " ").split()
    name = parts[0][0].lower() + parts[0][1:]
    if len(parts) > 1:
        for i in range(1, len(parts)):
            name += parts[i][0].upper() + parts[i][1:]
    return name


def write_to_file(filename: str, content: str) -> None:
    """Write content to a file."""

    with open(filename, "wt", encoding="utf-8") as out_file:
        out_file.write(content)
