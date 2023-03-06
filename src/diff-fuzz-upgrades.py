#!/usr/bin/env python3

import argparse
import logging
import time
import os
import subprocess
from web3 import Web3, logs
from web3.middleware import geth_poa_middleware
from slither import Slither
from slither.exceptions import SlitherError
from slither.utils.upgradeability import compare
from slither.utils.type import convert_type_for_solidity_signature_to_string
from slither.tools.read_storage.utils import get_storage_data
from slither.tools.read_storage import SlitherReadStorage
from eth_utils import to_checksum_address, is_address
from slither.core.declarations.contract import Contract
from slither.core.declarations.function import Function
from slither.core.variables.state_variable import StateVariable
from slither.core.declarations.enum import Enum
from slither.core.solidity_types.elementary_type import ElementaryType
from slither.core.solidity_types.user_defined_type import UserDefinedType
from slither.core.solidity_types.array_type import ArrayType
from slither.core.solidity_types.mapping_type import MappingType
from slither.core.declarations.structure import Structure
from slither.core.declarations.structure_contract import StructureContract
from crytic_compile import InvalidCompilation
from eth_utils import to_checksum_address, is_address
from eth_typing.evm import ChecksumAddress
from colorama import Back, Fore, Style, init as colorama_init


class PrintMode(Enum):
    MESSAGE = 0
    SUCCESS = 1
    INFORMATION = 2
    WARNING = 3
    ERROR = 4


def crytic_print(mode, message):
    if mode is PrintMode.MESSAGE:
        print(Style.BRIGHT + Fore.LIGHTBLUE_EX + message + Style.RESET_ALL)
    elif mode is PrintMode.SUCCESS:
        print(Fore.LIGHTGREEN_EX + message + Style.RESET_ALL)
    elif mode is PrintMode.INFORMATION:
        print(Fore.LIGHTCYAN_EX + message + Style.RESET_ALL)
    elif mode is PrintMode.WARNING:
        print(Fore.LIGHTYELLOW_EX + message + Style.RESET_ALL)
    elif mode is PrintMode.ERROR:
        print(Style.BRIGHT + Fore.LIGHTRED_EX + message + Style.RESET_ALL)


def get_compilation_unit_name(slither_object):
    name = list(slither_object.crytic_compile.compilation_units.keys())[0]
    if os.path.sep in name:
        name = name.rsplit(os.path.sep, maxsplit=1)[1]
    if name.endswith(".sol"):
        name = os.path.splitext(name)[0]
    return name


def get_solidity_function_parameters(parameters):
    """Get function parameters as solidity types.
    It can return additional interfaces/structs if parameter types are tupes
    """
    inputs = []
    additional_interfaces = set()

    if len(parameters) > 0:
        for inp in parameters:
            if isinstance(inp.type, ElementaryType):
                base_type = inp.type.name
                if inp.type.is_dynamic:
                    base_type += f" {inp.location}"

            elif isinstance(inp.type, UserDefinedType):
                if isinstance(inp.type.type, Structure):
                    base_type = f"{inp.type.type.name} {inp.location}"
                    
                    new_type = f"struct {inp.type.type.name} {{\n"
                    for t in inp.type.type.elems_ordered:
                        new_type += f"    {convert_type_for_solidity_signature_to_string(t.type)} {t.name};\n"
                    new_type += f"}}"
                    additional_interfaces.add(new_type)
                elif isinstance(inp.type.type, Contract):
                    base_type = convert_type_for_solidity_signature_to_string(inp.type)

            elif isinstance(inp.type, ArrayType):
                base_type = convert_type_for_solidity_signature_to_string(inp.type)
                if inp.type.is_dynamic:
                    base_type += f" {inp.location}"
            
            inputs.append(base_type)
    
    return inputs, additional_interfaces


def get_solidity_function_returns(return_type):
    """Get function return types as solidity types.
    """
    outputs = []

    if not return_type:
        return outputs

    if len(return_type) > 0:
        for out in return_type:
            if isinstance(out, ElementaryType) or isinstance(out, ArrayType) or isinstance(out, UserDefinedType):
                base_type = convert_type_for_solidity_signature_to_string(out)
                if out.is_dynamic or isinstance(out, ArrayType):
                    base_type += f" memory"
        outputs.append(base_type)

    return outputs


def get_interface_function_signature(name, inputs, outputs):
    interface = f"    function {name}("

    if inputs:
        for i in inputs:
            interface += f"{i},"
        interface = f"{interface[0:-1]}"
    interface += ") external"

    if outputs:
        interface += f" returns ("
        for i in outputs:
            interface += f"{i},"
        interface = f"{interface[0:-1]})"
    interface += ";\n"

    return interface


def structure_to_interface(structure):
    nested = False

    if isinstance(structure, Structure):
        new_type = f"struct {structure.name} {{\n"
        for t in structure.elems_ordered:
            new_type += f"    {convert_type_for_solidity_signature_to_string(t.type)} {t.name};\n"
        new_type += f"}}"
        if "mapping(" in new_type:
            # Nested mapping in structure, mark it
            nested = True
        return [new_type], nested
    else:
        return "", nested


def get_solidity_getter_outputs(getter):
    additional_interfaces = None
    nested = False
    itype = None
    
    if isinstance(getter.type, MappingType):
        itype = getter.type
        while isinstance(itype.type_to, MappingType):
            itype = itype.type_to
        itype = itype.type_to
        if isinstance(itype, ElementaryType) or isinstance(itype, ArrayType):
            outputs = convert_type_for_solidity_signature_to_string(itype)
        else:
            outputs = str(itype.type)
            additional_interfaces, nested = structure_to_interface(itype.type)
        if itype.is_dynamic or isinstance(itype.type, Structure):
            outputs += " memory"
    elif isinstance(getter.type, ArrayType):
        if isinstance(getter.type.type, UserDefinedType):
            if isinstance(getter.type.type.type, StructureContract):
                itype = getter.type.type.type
                additional_interfaces, nested = structure_to_interface(itype)
                outputs = f"{str(itype)}[] memory"
            elif isinstance(getter.type.type.type, Contract):
                outputs = f"address[] memory"
        else:
            outputs = convert_type_for_solidity_signature_to_string(getter.type.type)
    elif isinstance(getter.type, UserDefinedType):
        if isinstance(getter.type.type, StructureContract):
            itype = getter.type.type
            additional_interfaces, nested = structure_to_interface(itype)
            outputs = f"{str(itype)} memory"
        else:
            outputs = convert_type_for_solidity_signature_to_string(getter.type)
    else:
        itype = getter.type
        outputs = convert_type_for_solidity_signature_to_string(itype)
    
    if (outputs == "string" or outputs == "bytes" or "[]" in outputs) and not "memory" in outputs:
        outputs += f" memory"

    if isinstance(itype, UserDefinedType):
        additional_interfaces, nested = structure_to_interface(itype.type)

    return outputs, additional_interfaces, nested  


def get_contract_interface(contract_data, suffix=''):
    """Get contract ABI from Slither
    """

    contract = contract_data["contract_object"]
    interface = ""

    if not contract.functions_entry_points:
        raise ValueError("Contract has no public or external functions")
    interface += f"interface I{contract.name}{suffix} {{\n"

    contract_info = dict()
    contract_info["functions"] = []
    additional_interfaces = set()

    entry_points_signatures = [n.signature[0:2] for n in contract.functions_entry_points]

    for i in contract.functions_entry_points:

        # Interface won't need constructor or fallbacks
        if i.is_constructor or i.is_fallback or i.is_receive:
            continue

        # Get info for interface and wrapper
        name = i.name

        [inputs, additional] = get_solidity_function_parameters(i.parameters)
        if additional:
            additional_interfaces.update(additional)

        outputs = get_solidity_function_returns(i.return_type)

        # Only wrap state-modifying, not protected functions 
        # Might wrap protected functions anyway, as the modifiers can have any other name
        # modifiers = list(map(str,i.modifiers))
        # protected_mods = ["onlyAdmin", "onlyGov", "onlyOwner"]
        # if not i.pure and not i.view and not set(modifiers).intersection(set(protected_mods)):
        contract_info["functions"].append((name, inputs, outputs))

        interface += get_interface_function_signature(name, inputs, outputs)

    for i in contract.state_variables_entry_points:
        [name, inputs, _] = i.signature

        # Avoid duplications from functions
        if (name, inputs) in entry_points_signatures:
            continue

        [outputs, new_interfaces, nested] = get_solidity_getter_outputs(i)

        if not nested:
            if new_interfaces:
                additional_interfaces.update(new_interfaces)

            interface += get_interface_function_signature(name, inputs, [outputs])

    interface += "}\n\n"

    for ai in list(additional_interfaces):
        interface += f"{ai}\n\n"

    contract_info["name"] = contract.name
    contract_info["interface"] = interface
    contract_info["interface_name"] = f"I{contract.name}{suffix}"

    return contract_info


def get_contract_data_from_path(filepath, suffix=''):
    contract_data = dict()

    crytic_print(PrintMode.MESSAGE, f"Getting contract data from {filepath}")

    try:
        contract_data["slither"] = get_slither_object_from_path(filepath)
        contract_data["valid_data"] = True
    except:
        contract_data["slither"] = None
        contract_data["valid_data"] = False

    if contract_data["valid_data"]:
        slither_object = contract_data["slither"]
        contract_name = get_compilation_unit_name(slither_object)
        contract_data["contract_object"] = slither_object.get_contract_from_name(contract_name)[0]

        target_info = get_contract_interface(contract_data, suffix)
        contract_data["interface"] = target_info["interface"]
        contract_data["interface_name"] = target_info["interface_name"]
        contract_data["name"] = target_info["name"]
        contract_data["functions"] = target_info["functions"]

    return contract_data


def get_slither_object_from_path(filepath):
    if not os.path.exists(filepath):
        raise ValueError("File path does not exist!")
    try:
        crytic_print(PrintMode.MESSAGE, f"Getting Slither object")
        slither_object = Slither(filepath)
        return slither_object
    except SlitherError as e:
        crytic_print(PrintMode.ERROR, f"Slither error:\v{str(e)}")
        raise SlitherError(str(e))
    

def wrap_functions(target):
    wrapped = ""

    if len(target) == 0:
        return wrapped

    for t in target:
        functions_to_wrap = t["functions"]
        for f in functions_to_wrap:
            args = "("
            call_args = "("
            counter = 0
            if len(f[1]) == 0:
                args += ")"
                call_args += ")"
            else:
                for i in f[1]:
                    args += f"{i} {chr(ord('a')+counter)}, "
                    call_args += f"{chr(ord('a')+counter)}, "
                    counter += 1
                args = f"{args[0:-2]})"
                call_args = f"{call_args[0:-2]})"

            wrapped +=  f"    function {t['name']}_{f[0]}{args} public {{\n"
            wrapped +=   "        hevm.prank(msg.sender);\n"
            wrapped +=  f"        {t['name']}.{f[0]}{call_args};\n    }}\n\n"

    return wrapped


def wrap_diff_functions(v1, v2):
    wrapped = ""
    
    crytic_print(PrintMode.MESSAGE, "\n  * Performing diff of V1 and V2")
    diff = compare(v1["contract_object"], v2["contract_object"])

    diff_functions = diff['modified-functions'] + diff['tainted-functions']
    new_functions = diff['new-functions']
    diff_variables = diff['tainted-variables']

    for f in diff_functions:
        if f.visibility in ["internal", "private"]:
            continue
        func = next(func for func in v2['functions'] if func[0] == f.name)

        args = "("
        call_args = "("
        return_vals = []
        returns_to_compare = []
        counter = 0
        if len(func[1]) == 0:
            args += ")"
            call_args += ")"
        else:
            for i in func[1]:
                args += f"{i} {chr(ord('a')+counter)}, "
                call_args += f"{chr(ord('a')+counter)}, "
                counter += 1
            args = f"{args[0:-2]})"
            call_args = f"{call_args[0:-2]})"
        if len(func[2]) == 0:
            return_vals = ""
        elif len(func[2]) == 1:
            for j in range(0, 2):
                return_vals.append(f"{i} {chr(ord('a')+counter)}")
                returns_to_compare.append(f"{chr(ord('a')+counter)}")
                counter += 1
        else:
            for j in range(0, 2):
                return_vals.append("(")
                returns_to_compare.append("(")
                for i in func[2]:
                    return_vals[j] += f"{i} {chr(ord('a')+counter)}, "
                    returns_to_compare[j] += f"{chr(ord('a')+counter)}, "
                    counter += 1
                return_vals[j] = f"{return_vals[j][0:-2]})"
                returns_to_compare[j] = f"{returns_to_compare[j][0:-2]})"

        wrapped +=  f"    function {v1['name']}_{func[0]}{args} public returns (bool) {{\n"
        wrapped +=   "        hevm.prank(msg.sender);\n"
        if len(return_vals) > 0:
            wrapped +=  f"        {return_vals[0]} = {v1['name']}V1.{func[0]}{call_args};\n"
        else:
            wrapped +=  f"        {v1['name']}V1.{func[0]}{call_args};\n"
        wrapped +=   "        hevm.prank(msg.sender);\n"
        if len(return_vals) > 0:
            wrapped +=  f"        {return_vals[1]} = {v2['name']}V2.{func[0]}{call_args};\n"
            wrapped +=  f"        return {returns_to_compare[0]} == {returns_to_compare [1]};\n"
        else:
            wrapped +=  f"        {v2['name']}V2.{func[0]}{call_args};\n"
        wrapped +=   "    }\n\n"

    for v in diff_variables:
        if v.visibility in ["internal", "private"]:
            continue
        if v.type.is_dynamic:
            if isinstance(v.type, MappingType):
                type_from = v.type.type_from.name
                wrapped +=  f"    function {v1['name']}_{v.name}({type_from} a) public returns (bool) {{\n"
                wrapped +=  f"        return {v1['name']}V1.{v.name}(a) == {v2['name']}V2.{v.name}(a);\n"
                wrapped +=   "    }\n\n"
            elif isinstance(v.type, ArrayType):
                wrapped +=  f"    function {v1['name']}_{v.name}(uint i) public returns (bool) {{\n"
                wrapped +=  f"        return {v1['name']}V1.{v.name}[i] == {v2['name']}V2.{v.name}[i];\n"
                wrapped +=   "    }\n\n"
        else:
            wrapped +=  f"    function {v1['name']}_{v.full_name} public returns (bool) {{\n"
            wrapped +=  f"        return {v1['name']}V1.{v.full_name} == {v2['name']}V2.{v.full_name};\n"
            wrapped +=   "    }\n\n"
            

    return wrapped


def write_to_file(filename, content):
    out_file = open(filename, "wt")
    out_file.write(content)
    out_file.close()
    

def generate_test_contract(v1, v2, tokens=None, targets=None):

    crytic_print(PrintMode.INFORMATION, f"\n* Generating exploit contract...")

    final_contract = ""

    # Add solidity pragma and SPDX to avoid warnings
    final_contract += "// SPDX-License-Identifier: AGPLv3\npragma solidity ^0.8.0;\n\n"

    # Add all interfaces first
    crytic_print(PrintMode.INFORMATION, f"  * Adding interfaces.")
    final_contract += v1["interface"]
    final_contract += v2["interface"]

    if tokens is not None:
        for i in tokens:   
            final_contract += i["interface"]
    if targets is not None:
        for i in targets:
            final_contract += i["interface"]

    # Add the hevm interface
    final_contract += "interface IHevm {\n"
    final_contract += "    function warp(uint256 newTimestamp) external;\n"
    final_contract += "    function roll(uint256 newNumber) external;\n"
    final_contract += "    function load(address where, bytes32 slot) external returns (bytes32);\n"
    final_contract += "    function store(address where, bytes32 slot, bytes32 value) external;\n"
    final_contract += "    function sign(uint256 privateKey, bytes32 digest) external returns (uint8 r, bytes32 v, bytes32 s);\n"
    final_contract += "    function addr(uint256 privateKey) external returns (address add);\n"
    final_contract += "    function ffi(string[] calldata inputs) external returns (bytes memory result);\n"
    final_contract += "    function prank(address newSender) external;\n}\n\n"

    # Create the exploit contract
    crytic_print(PrintMode.INFORMATION, f"  * Creating the exploit contract.")
    final_contract +=  "contract DiffFuzzUpgrades {\n"

    # State variables
    crytic_print(PrintMode.INFORMATION, f"  * Adding state variables declarations.")

    final_contract +=  "    IHevm hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);\n\n"
    final_contract += f"    {v1['interface_name']} {v1['name']}V1 = {v1['interface_name']}(V1_ADDRESS_HERE);\n"
    final_contract += f"    {v2['interface_name']} {v2['name']}V2 = {v2['interface_name']}(V2_ADDRESS_HERE);\n"

    if tokens is not None:
        for t in tokens:
            final_contract += f"    {t['interface_name']} {t['name']} = {t['interface_name']}({t['name']}_ADDRESS_HERE);\n"

    if targets is not None:
        for t in targets:
            final_contract += f"    {t['interface_name']} {t['name']} = {t['interface_name']}({t['name']}_ADDRESS_HERE);\n\n"

    # Constructor
    crytic_print(PrintMode.INFORMATION, f"  * Generating constructor.")

    final_contract +=  "    constructor() {\n"
    # final_contract += f"        hevm.warp({timestamp});\n"
    # final_contract += f"        hevm.roll({blocknumber});\n\n"

    # # Borrow some tokens from holder
    # for t in tokens:
    #     final_contract += f"        tokenHolder = address({holder});\n"
    #     final_contract += f"        initialAmount = {t['name']}.balanceOf(tokenHolder);\n"
    #     final_contract += f"        hevm.prank(tokenHolder);\n"
    #     final_contract += f"        {t['name']}.transfer(address(this), initialAmount);\n\n"
    #     final_contract += f"        require({t['name']}.balanceOf(address(this)) > 0, \"Zero balance in the contract, perhaps transfer failed?\");\n\n"

    # if len(targets) > 0:
    #     for t in targets:
    #         for tk in tokens:
    #             final_contract +=  f"        {tk['name']}.approve(address({t['name']}), type(uint256).max);\n"
    #         for f in t["functions"]:
    #             if f[0] == "approve" and f[1] == ["address", "uint256"]:
    #                 final_contract +=  f"        {t['name']}.approve(address({t['name']}), type(uint256).max);\n"
    final_contract += f"    }}\n\n"

    # Wrapper functions
    crytic_print(PrintMode.INFORMATION, f"  * Adding wrapper functions.")

    final_contract += wrap_diff_functions(v1, v2)

    if targets is not None:
        final_contract += wrap_functions(targets)
    if tokens is not None:
        final_contract += wrap_functions(tokens)


    # End of contract
    final_contract +=  "}\n"

    return final_contract


def main():
    # Read command line arguments

    parser = argparse.ArgumentParser(
        prog='diff-fuzz-upgrades',
        description='Generate differential fuzz testing contract for comparing two upgradeable contract versions.'
    )

    parser.add_argument('v1_filename', help='The path to the original version of the contract.')
    parser.add_argument('v2_filename', help='The path to the upgraded version of the contract.')

    args = parser.parse_args()

    v1_contract_data = get_contract_data_from_path(args.v1_filename, suffix="V1")
    v2_contract_data = get_contract_data_from_path(args.v2_filename, suffix="V2")

    # crytic_print(PrintMode.MESSAGE, "Performing diff of V1 and V2")
    # diff = compare(v1_contract_data["contract_object"], v2_contract_data["contract_object"])
    # for key in diff.keys():
    #     if len(diff[key]) > 0:
    #         crytic_print(PrintMode.WARNING, f'    * {str(key).replace("-", " ")}:')
    #         for obj in diff[key]:
    #             if isinstance(obj, StateVariable):
    #                 crytic_print(PrintMode.WARNING, f'        * {obj.full_name}')
    #             elif isinstance(obj, Function):
    #                 crytic_print(PrintMode.WARNING, f'        * {obj.signature_str}')

    contract = generate_test_contract(v1_contract_data, v2_contract_data)
    write_to_file("DiffFuzzUpgrades.sol", contract)


if __name__ == "__main__":
    main()

