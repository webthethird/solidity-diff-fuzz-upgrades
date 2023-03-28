import os
import difflib
from typing import List

from solc_select.solc_select import get_installable_versions
from slither.utils.type import convert_type_for_solidity_signature_to_string
from slither.utils.code_generation import generate_interface
from slither.core.declarations.contract import Contract
from slither.core.variables.local_variable import LocalVariable
from slither.core.declarations.enum import Enum
from slither.core.solidity_types import (
    Type,
    ElementaryType,
    UserDefinedType,
    ArrayType
)
from slither.core.declarations.structure import Structure
from difffuzz.classes import FunctionInfo, ContractData
from difffuzz.utils.printer import PrintMode, crytic_print


def get_compilation_unit_name(slither_object) -> str:
    name = list(slither_object.crytic_compile.compilation_units.keys())[0]
    if os.path.sep in name:
        name = name.rsplit(os.path.sep, maxsplit=1)[1]
    if name.endswith(".sol"):
        name = os.path.splitext(name)[0]
    return name


def get_solidity_function_parameters(parameters: List[LocalVariable]) -> List[str]:
    """Get function parameters as solidity types.
    It can return additional interfaces/structs if parameter types are tupes
    """
    inputs = []

    if len(parameters) > 0:
        for inp in parameters:
            if isinstance(inp.type, ElementaryType):
                base_type = inp.type.name
                if inp.type.is_dynamic:
                    base_type += f" {inp.location}"

            elif isinstance(inp.type, UserDefinedType):
                if isinstance(inp.type.type, Structure):
                    base_type = f"{inp.type.type.name} {inp.location}"
                elif isinstance(inp.type.type, Contract):
                    base_type = convert_type_for_solidity_signature_to_string(inp.type)

            elif isinstance(inp.type, ArrayType):
                base_type = convert_type_for_solidity_signature_to_string(inp.type)
                if inp.type.is_dynamic:
                    base_type += f" {inp.location}"

            inputs.append(base_type)

    return inputs


def get_solidity_function_returns(return_type: Type) -> List[str]:
    """Get function return types as solidity types.
    It can return additional interfaces/structs if parameter types are tupes
    """
    outputs = []

    if not return_type:
        return outputs

    if len(return_type) > 0:
        for out in return_type:
            if isinstance(out, ElementaryType):
                base_type = convert_type_for_solidity_signature_to_string(out)
                if out.is_dynamic:
                    base_type += " memory"
            elif isinstance(out, ArrayType):
                if isinstance(out.type, UserDefinedType) and isinstance(out.type.type, Structure):
                    base_type = f"{out.type.type.name}[] memory"
                else:
                    base_type = convert_type_for_solidity_signature_to_string(out)
                    base_type += " memory"
            elif isinstance(out, UserDefinedType):
                if isinstance(out.type, Structure):
                    base_type = f"{out.type.name} memory"
                elif isinstance(out.type, (Contract, Enum)):
                    base_type = convert_type_for_solidity_signature_to_string(out)
            outputs.append(base_type)

    return outputs


def get_contract_interface(contract_data: ContractData, suffix: str = "") -> dict:
    """Get contract ABI from Slither"""

    contract: Contract = contract_data["contract_object"]

    if not contract.functions_entry_points:
        raise ValueError("Contract has no public or external functions")

    contract_info = dict()
    contract_info["functions"] = []

    for i in contract.functions_entry_points:

        # Interface won't need constructor or fallbacks
        if i.is_constructor or i.is_fallback or i.is_receive:
            continue

        # Get info for interface and wrapper
        name = i.name
        inputs = get_solidity_function_parameters(i.parameters)
        outputs = get_solidity_function_returns(i.return_type)
        protected = i.is_protected()

        contract_info["functions"].append(
            FunctionInfo(
                name=name,
                function=i,
                inputs=inputs,
                outputs=outputs,
                protected=protected
            )
        )

    contract_info["name"] = contract.name
    contract_info["interface"] = generate_interface(contract, unroll_structs=False, skip_errors=True, skip_events=True).replace(
        f"interface I{contract.name}",
        f"interface I{contract.name}{suffix}"
    )
    contract_info["interface_name"] = f"I{contract.name}{suffix}"

    return contract_info


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


def generate_config_file(
    corpus_dir: str, campaign_length: str, contract_addr: str, seq_len: int
) -> str:
    crytic_print(
        PrintMode.INFORMATION,
        f"* Generating Echidna configuration file with campaign limit {campaign_length}"
        f" and corpus directory {corpus_dir}",
    )
    config_file = f"testMode: assertion\n"
    config_file += f"testLimit: {campaign_length}\n"
    config_file += f"corpusDir: {corpus_dir}\n"
    config_file += "codeSize: 0xffff\n"
    config_file += f"seqLen: {seq_len}\n"
    if contract_addr != "":
        config_file += f"contractAddr: '{contract_addr}'\n"

    return config_file


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
