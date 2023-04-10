import os
import difflib
from typing import List

from solc_select.solc_select import get_installable_versions
from slither.utils.upgradeability import compare, tainted_inheriting_contracts, TaintedExternalContract
from slither.core.declarations import Function
from slither.core.variables.state_variable import StateVariable
from diffuzzer.classes import ContractData, Diff
from diffuzzer.utils.printer import PrintMode, crytic_print


def get_compilation_unit_name(slither_object) -> str:
    name = list(slither_object.crytic_compile.compilation_units.keys())[0]
    if os.path.sep in name:
        name = name.rsplit(os.path.sep, maxsplit=1)[1]
    if name.endswith(".sol"):
        name = os.path.splitext(name)[0]
    return name


def get_pragma_version_from_file(filepath: str, seen: List[str] = None) -> str:
    if seen is None:
        seen = list()
    try:
        f = open(filepath, "r")
        lines = f.readlines()
        f.close()
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
    for file in files:
        if file.startswith("./"):
            file = file.replace("./", filepath.rsplit("/", maxsplit=1)[0] + "/")
        elif file.startswith("../"):
            file = file.replace("../", filepath.rsplit("/", maxsplit=2)[0] + "/")
        if file not in seen:
            seen.append(file)
            versions.append(get_pragma_version_from_file(file, seen))
    high_version = ["0", "0", "0"]
    for v in versions:
        vers = v.split(".")
        vers[0] = "0"
        if int(vers[1]) > int(high_version[1]) or (
            int(vers[1]) == int(high_version[1]) and int(vers[2]) > int(high_version[2])
        ):
            high_version = vers
            if v.startswith(">") and not v.startswith(">="):
                vers[2] = str(int(vers[2]) + 1)
                if not ".".join(vers) in get_installable_versions():
                    vers[1] = str(int(vers[1]) + 1)
                    vers[2] = "0"
                if ".".join(vers) in get_installable_versions():
                    high_version = vers
    return ".".join(high_version)


def do_diff(v1: ContractData, v2: ContractData, additional_targets: List[ContractData] = None) -> Diff:
    crytic_print(PrintMode.MESSAGE, "* Performing diff of V1 and V2")
    (
        missing_vars, new_vars, tainted_vars, new_funcs, modified_funcs, tainted_funcs, tainted_contracts
    ) = compare(v1["contract_object"], v2["contract_object"])
    if additional_targets:
        tainted_contracts = tainted_inheriting_contracts(
            tainted_contracts, [
                t["contract_object"] for t in additional_targets 
                if t["contract_object"] not in 
                [c.contract for c in tainted_contracts] + [v1["contract_object"], v2["contract_object"]]
            ]
        )
    diff = Diff(
        missing_variables=missing_vars,
        new_variables=new_vars,
        tainted_variables=tainted_vars,
        new_functions=new_funcs,
        modified_functions=modified_funcs,
        tainted_functions=tainted_funcs,
        tainted_contracts=tainted_contracts
    )
    for key in diff.keys():
        if len(diff[key]) > 0:
            crytic_print(PrintMode.WARNING, f'  * {str(key).replace("-", " ")}:')
            for obj in diff[key]:
                if isinstance(obj, StateVariable):
                    crytic_print(PrintMode.WARNING, f"      * {obj.full_name}")
                elif isinstance(obj, Function):
                    crytic_print(PrintMode.WARNING, f"      * {obj.signature_str}")
                elif isinstance(obj, TaintedExternalContract):
                    crytic_print(PrintMode.WARNING, f"      * {obj.contract.name}")
                    for f in obj.tainted_functions:
                        crytic_print(PrintMode.WARNING, f"        * {f.signature_str}")
                    for v in obj.tainted_variables:
                        crytic_print(PrintMode.WARNING, f"        * {v.signature_str}")
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
    parts = name.replace("_", " ").replace("-", " ").split()
    name = parts[0][0].lower() + parts[0][1:]
    if len(parts) > 1:
        for i in range(1, len(parts)):
            name += parts[i][0].upper() + parts[i][1:]
    return name


def write_to_file(filename: str, content: str) -> None:
    out_file = open(filename, "wt")
    out_file.write(content)
    out_file.close()
