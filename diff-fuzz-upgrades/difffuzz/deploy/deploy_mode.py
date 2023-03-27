#!/usr/bin/env python3

import argparse
import logging
import time
import os
import subprocess
import difflib
from typing import Any, TypedDict, List, Tuple
from solc_select.solc_select import (
    switch_global_version,
    installed_versions,
    get_installable_versions,
)
from web3 import Web3, logs
from web3.middleware import geth_poa_middleware
from slither import Slither
from slither.exceptions import SlitherError
from slither.utils.upgradeability import compare, get_proxy_implementation_slot
from slither.utils.type import convert_type_for_solidity_signature_to_string
from slither.utils.code_generation import generate_interface
from slither.core.declarations.contract import Contract
from slither.core.declarations.function import Function
from slither.core.variables.state_variable import StateVariable
from slither.core.variables.local_variable import LocalVariable
from slither.core.declarations.enum import Enum
from slither.core.solidity_types import (
    Type,
    ElementaryType,
    UserDefinedType,
    ArrayType,
    MappingType
)
from slither.core.declarations.structure import Structure
from slither.core.declarations.structure_contract import StructureContract
from crytic_compile import InvalidCompilation
from eth_utils import to_checksum_address, is_address
from eth_typing.evm import ChecksumAddress
from colorama import Back, Fore, Style, init as colorama_init
from difffuzz.classes import FunctionInfo, ContractData
from difffuzz.utils.printer import PrintMode, crytic_print
from difffuzz.utils.helpers import (
    get_pragma_version_from_file,
    get_compilation_unit_name,
    get_contract_interface,
    generate_config_file
)


def get_contracts_from_comma_separated_paths(paths_string: str, suffix: str = "") -> List[ContractData]:
    contracts = []
    filepaths = paths_string.split(",")

    for path in filepaths:
        contract_data = get_contract_data_from_path(path, suffix)
        contracts.append(contract_data)
    return contracts


def get_contract_data_from_path(filepath: str, suffix: str = "") -> ContractData:
    contract_data = ContractData()

    crytic_print(PrintMode.MESSAGE, f"* Getting contract data from {filepath}")

    contract_data["path"] = filepath
    contract_data["suffix"] = suffix
    version = get_pragma_version_from_file(filepath)
    contract_data["solc_version"] = version
    if version in installed_versions() or version in get_installable_versions():
        switch_global_version(version, True)

    try:
        contract_data["slither"] = get_slither_object_from_path(filepath)
        contract_data["valid_data"] = True
    except:
        contract_data["slither"] = None
        contract_data["valid_data"] = False

    if contract_data["valid_data"]:
        slither_object = contract_data["slither"]
        contract_name = get_compilation_unit_name(slither_object)
        try:
            contract = slither_object.get_contract_from_name(contract_name)[0]
        except IndexError:
            contract = slither_object.get_contract_from_name(contract_name.replace("V1", "").replace("V2", ""))[0]
        contract_data["contract_object"] = contract
        if contract.is_upgradeable_proxy:
            contract_data["is_proxy"] = True
            contract_data["implementation_slot"] = get_proxy_implementation_slot(
                contract
            )
        else:
            contract_data["is_proxy"] = False
        target_info = get_contract_interface(contract_data, suffix)
        contract_data["interface"] = target_info["interface"]
        contract_data["interface_name"] = target_info["interface_name"]
        contract_data["name"] = target_info["name"]
        contract_data["functions"] = target_info["functions"]
        crytic_print(
            PrintMode.MESSAGE, f"  * Done compiling contract {contract_data['name']}"
        )

    return contract_data


def get_slither_object_from_path(filepath: str) -> Slither:
    if not os.path.exists(filepath):
        raise ValueError("File path does not exist!")
    try:
        crytic_print(
            PrintMode.MESSAGE, f"  * Compiling contracts and retrieving Slither IR..."
        )
        slither_object = Slither(filepath)
        return slither_object
    except SlitherError as e:
        crytic_print(PrintMode.ERROR, f"  * Slither error:\v{str(e)}")
        raise SlitherError(str(e))


def wrap_functions(target: List[ContractData]) -> str:
    wrapped = ""

    if len(target) == 0:
        return wrapped

    for t in target:
        functions_to_wrap: List[FunctionInfo] = t["functions"]
        for f in functions_to_wrap:
            args = "("
            call_args = "("
            counter = 0
            if len(f["inputs"]) == 0:
                args += ")"
                call_args += ")"
            else:
                for i in f["inputs"]:
                    args += f"{i} {chr(ord('a')+counter)}, "
                    call_args += f"{chr(ord('a')+counter)}, "
                    counter += 1
                args = f"{args[0:-2]})"
                call_args = f"{call_args[0:-2]})"

            wrapped += f"    function {t['name']}_{f['name']}{args} public {{\n"
            wrapped += "        hevm.prank(msg.sender);\n"
            wrapped += f"        {t['name']}.{f[0]}{call_args};\n    }}\n\n"

    return wrapped


def get_args_and_returns_for_wrapping(func: FunctionInfo) -> Tuple[str, str, List[str], List[str]]:
    args = "("
    call_args = "("
    return_vals = []
    returns_to_compare = []
    counter = 0
    if len(func["inputs"]) == 0:
        args += ")"
        call_args += ")"
    else:
        for i in func["inputs"]:
            args += f"{i} {chr(ord('a') + counter)}, "
            call_args += f"{chr(ord('a') + counter)}, "
            counter += 1
        args = f"{args[0:-2]})"
        call_args = f"{call_args[0:-2]})"
    if len(func['outputs']) == 0:
        return_vals = ""
    elif len(func['outputs']) == 1:
        for j in range(0, 2):
            return_vals.append(f"{func['outputs'][0]} {chr(ord('a') + counter)}")
            returns_to_compare.append(f"{chr(ord('a') + counter)}")
            counter += 1
    else:
        for j in range(0, 2):
            return_vals.append("(")
            returns_to_compare.append("(")
            for i in func['outputs']:
                return_vals[j] += f"{i} {chr(ord('a') + counter)}, "
                returns_to_compare[j] += f"{chr(ord('a') + counter)}, "
                counter += 1
            return_vals[j] = f"{return_vals[j][0:-2]})"
            returns_to_compare[j] = f"{returns_to_compare[j][0:-2]})"
    return args, call_args, return_vals, returns_to_compare


def wrap_additional_target_functions(targets: List[ContractData]) -> str:
    wrapped = ""

    if len(targets) == 0:
        return wrapped

    wrapped += "\n    /*** Additional Targets ***/ \n\n"
    for t in targets:
        functions_to_wrap = t["functions"]
        for func in functions_to_wrap:
            wrapped += wrap_diff_function(t, t, func)
    return wrapped


def wrap_low_level_call(c: ContractData, func: FunctionInfo, call_args: str, suffix: str, proxy=None) -> str:
    if proxy is None:
        target = camel_case(c['name'])
    else:
        target = camel_case(proxy['name'])
    wrapped = ""
    wrapped += f"        (bool success{suffix}, bytes memory output{suffix}) = address({target}{suffix}).call(\n"
    wrapped += f"            abi.encodeWithSelector(\n"
    wrapped += f"                {camel_case(c['name'])}{suffix}.{func['name']}.selector{call_args.replace('()', '').replace('(', ', ').replace(')', '')}\n"
    wrapped += f"            )\n"
    wrapped += f"        );\n"
    return wrapped


def wrap_diff_function(v1: ContractData, v2: ContractData, func: FunctionInfo, func2: FunctionInfo = None, proxy: ContractData = None) -> str:
    wrapped = ""
    if func2 is None:
        func2 = func
    (
        args,
        call_args,
        return_vals,
        returns_to_compare,
    ) = get_args_and_returns_for_wrapping(func2)

    wrapped += f"    function {v2['name']}_{func2['name']}{args} public virtual {{\n"
    if not func2['protected']:
        wrapped += "        hevm.prank(msg.sender);\n"
    wrapped += wrap_low_level_call(v2, func2, call_args, "V2", proxy)
    # if len(return_vals) > 0:
    #     wrapped +=  f"        {return_vals[0]} = {v1['name']}V1.{func[0]}{call_args};\n"
    # else:
    #     wrapped +=  f"        {v1['name']}V1.{func[0]}{call_args};\n"
    if not func['protected']:
        wrapped += "        hevm.prank(msg.sender);\n"
    if func != func2:
        _, call_args, _, _ = get_args_and_returns_for_wrapping(func)
    wrapped += wrap_low_level_call(v1, func, call_args, "V1", proxy)
    wrapped += f"        assert(successV1 == successV2); \n"
    wrapped += f"        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));\n"
    # if len(return_vals) > 0:
    #     wrapped +=  f"        {return_vals[1]} = {v2['name']}V2.{func[0]}{call_args};\n"
    #     wrapped +=  f"        return {returns_to_compare[0]} == {returns_to_compare [1]};\n"
    # else:
    #     wrapped +=  f"        {v2['name']}V2.{func[0]}{call_args};\n"
    wrapped += "    }\n\n"
    return wrapped


def wrap_diff_functions(v1: ContractData, v2: ContractData, proxy: ContractData = None) -> str:
    wrapped = ""

    diff = do_diff(v1, v2)

    wrapped += "\n    /*** Modified Functions ***/ \n\n"
    for f in diff["modified-functions"]:
        if f.visibility in ["internal", "private"]:
            continue
        func = next(func for func in v2["functions"] if func['name'] == f.name and len(func['inputs']) == len(f.parameters))
        if proxy is not None:
            wrapped += wrap_diff_function(v1, v2, func, proxy=proxy)
        else:
            wrapped += wrap_diff_function(v1, v2, func)

    wrapped += "\n    /*** Tainted Functions ***/ \n\n"
    for f in diff["tainted-functions"]:
        if f.visibility in ["internal", "private"]:
            continue
        func = next(func for func in v2["functions"] if func['name'] == f.name and len(func['inputs']) == len(f.parameters))
        if proxy is not None:
            wrapped += wrap_diff_function(v1, v2, func, proxy=proxy)
        else:
            wrapped += wrap_diff_function(v1, v2, func)

    wrapped += "\n    /*** New Functions ***/ \n\n"
    for f in diff["new-functions"]:
        if f.visibility in ["internal", "private"]:
            continue
        for f0 in v1["contract_object"].functions_entry_points:
            if similar(f.name, f0.name):
                wrapped += "    // TODO: Double-check this function for correctness\n"
                wrapped += f"    // {f.canonical_name}\n"
                wrapped += f"    // is a new function, which appears to replace a function with a similar name,\n"
                wrapped += f"    // {f0.canonical_name}.\n"
                wrapped += "    // If these functions have different arguments, this function may be incorrect.\n"
                func = next(func for func in v1["functions"] if func['name'] == f0.name)
                func2 = next(func for func in v2["functions"] if func['name'] == f.name)
                if proxy is not None:
                    wrapped += wrap_diff_function(v1, v2, func, func2, proxy=proxy)
                else:
                    wrapped += wrap_diff_function(v1, v2, func, func2)

    wrapped += "\n    /*** Tainted Variables ***/ \n\n"
    for v in diff["tainted-variables"]:
        if proxy is None:
            target_v1 = camel_case(v1['name'])
            target_v2 = camel_case(v2['name'])
        else:
            target_v1 = target_v2 = camel_case(proxy['name'])
        if v.visibility in ["internal", "private"]:
            continue
        if v.type.is_dynamic:
            if isinstance(v.type, MappingType):
                type_from = v.type.type_from.name
                wrapped += (
                    f"    function {v1['name']}_{v.name}({type_from} a) public {{\n"
                )
                wrapped += f"        assert({target_v1}V1.{v.name}(a) == {target_v2}V2.{v.name}(a));\n"
                wrapped += "    }\n\n"
            elif isinstance(v.type, ArrayType):
                wrapped += f"    function {v1['name']}_{v.name}(uint i) public {{\n"
                wrapped += f"        assert({target_v1}V1.{v.name}(i) == {target_v2}V2.{v.name}(i));\n"
                wrapped += "    }\n\n"
        else:
            wrapped += f"    function {v1['name']}_{v.full_name} public {{\n"
            wrapped += f"        assert({target_v1}V1.{v.full_name} == {target_v2}V2.{v.full_name});\n"
            wrapped += "    }\n\n"

    return wrapped


def do_diff(v1: ContractData, v2: ContractData) -> dict:
    crytic_print(PrintMode.MESSAGE, "    * Performing diff of V1 and V2")
    missing_vars, new_vars, tainted_vars, new_funcs, modified_funcs, tainted_funcs = compare(v1["contract_object"], v2["contract_object"])
    diff = {
        "missing-variables": missing_vars,
        "new-variables": new_vars,
        "tainted-variables": tainted_vars,
        "new-functions": new_funcs,
        "modified-functions": modified_funcs,
        "tainted-functions": tainted_funcs
    }
    for key in diff.keys():
        if len(diff[key]) > 0:
            crytic_print(PrintMode.WARNING, f'      * {str(key).replace("-", " ")}:')
            for obj in diff[key]:
                if isinstance(obj, StateVariable):
                    crytic_print(PrintMode.WARNING, f"          * {obj.full_name}")
                elif isinstance(obj, Function):
                    crytic_print(PrintMode.WARNING, f"          * {obj.signature_str}")
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


def generate_test_contract(
    v1: ContractData,
    v2: ContractData,
    deploy: bool,
    version: str,
    tokens: List[ContractData] = None,
    targets: List[ContractData] = None,
    proxy: ContractData = None,
    upgrade: bool = False
) -> str:

    crytic_print(PrintMode.INFORMATION, f"\n* Generating exploit contract...")

    final_contract = ""

    # Add solidity pragma and SPDX to avoid warnings
    final_contract += (
        f"// SPDX-License-Identifier: AGPLv3\npragma solidity ^{version};\n\n"
    )

    if deploy:
        final_contract += (
            f'import {{ {v1["name"]} as {v1["name"]}_V1 }} from "{v1["path"]}";\n'
        )
        final_contract += (
            f'import {{ {v2["name"]} as {v2["name"]}_V2 }} from "{v2["path"]}";\n'
        )
        if proxy:
            final_contract += f'import {{ {proxy["name"]} }} from "{proxy["path"]}";\n'
        if tokens is not None:
            for i in tokens:
                final_contract += f'import {{ {i["name"]} }} from "{i["path"]}";\n'
        if targets is not None:
            for i in targets:
                final_contract += f'import {{ {i["name"]} }} from "{i["path"]}";\n'
        final_contract += "\n"

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
    if proxy is not None:
        final_contract += proxy["interface"]

    # Add the hevm interface
    final_contract += "interface IHevm {\n"
    final_contract += "    function warp(uint256 newTimestamp) external;\n"
    final_contract += "    function roll(uint256 newNumber) external;\n"
    final_contract += (
        "    function load(address where, bytes32 slot) external returns (bytes32);\n"
    )
    final_contract += (
        "    function store(address where, bytes32 slot, bytes32 value) external;\n"
    )
    final_contract += "    function sign(uint256 privateKey, bytes32 digest) external returns (uint8 r, bytes32 v, bytes32 s);\n"
    final_contract += (
        "    function addr(uint256 privateKey) external returns (address add);\n"
    )
    final_contract += "    function ffi(string[] calldata inputs) external returns (bytes memory result);\n"
    final_contract += "    function prank(address newSender) external;\n}\n\n"

    # Create the exploit contract
    crytic_print(PrintMode.INFORMATION, f"  * Creating the exploit contract.")
    final_contract += "contract DiffFuzzUpgrades {\n"

    # State variables
    crytic_print(PrintMode.INFORMATION, f"  * Adding state variables declarations.")

    final_contract += (
        "    IHevm hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);\n\n"
    )
    final_contract += (
        "    // TODO: Deploy the contracts and put their addresses below\n"
    )
    final_contract += f"    {v1['interface_name']} {camel_case(v1['name'])}V1;\n"
    final_contract += f"    {v2['interface_name']} {camel_case(v2['name'])}V2;\n"

    if proxy is not None:
        final_contract += f"    {proxy['interface_name']} {camel_case(proxy['name'])}V1;\n"
        final_contract += f"    {proxy['interface_name']} {camel_case(proxy['name'])}V2;\n"

    if tokens is not None:
        for t in tokens:
            final_contract += f"    {t['interface_name']} {camel_case(t['name'])}V1;\n"
            final_contract += f"    {t['interface_name']} {camel_case(t['name'])}V2;\n"

    if targets is not None:
        for t in targets:
            final_contract += f"    {t['interface_name']} {camel_case(t['name'])}V1;\n"
            final_contract += f"    {t['interface_name']} {camel_case(t['name'])}V2;\n"

    # Constructor
    crytic_print(PrintMode.INFORMATION, f"  * Generating constructor.")

    if deploy:
        final_contract += generate_deploy_constructor(v1, v2, tokens, targets, proxy, upgrade)
    else:
        final_contract += "\n    constructor() public {\n"
        final_contract += "        // TODO: Add any necessary initialization logic to the constructor here.\n"
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

    if upgrade and proxy is not None:
        crytic_print(PrintMode.INFORMATION, f"  * Adding upgrade function.")
        final_contract += "    /*** Upgrade Function ***/ \n\n"
        final_contract += "    function upgradeV2() external virtual {\n"
        final_contract += f"        hevm.store(\n"
        final_contract += f"            address({camel_case(proxy['name'])}V2),\n"
        final_contract += (
            f"            bytes32(uint({proxy['implementation_slot'].slot})),\n"
        )
        final_contract += (
            f"            bytes32(uint256(uint160(address({camel_case(v2['name'])}V2))))\n"
        )
        final_contract += f"        );\n"
        final_contract += "    }\n\n"

    # Wrapper functions
    crytic_print(PrintMode.INFORMATION, f"  * Adding wrapper functions.")

    final_contract += wrap_diff_functions(v1, v2, proxy)

    if targets is not None:
        final_contract += wrap_additional_target_functions(targets)
    if tokens is not None:
        final_contract += wrap_functions(tokens)

    # End of contract
    final_contract += "}\n"

    return final_contract


def generate_deploy_constructor(
    v1: ContractData, 
    v2: ContractData, 
    tokens: List[ContractData] = None, 
    targets: List[ContractData] = None, 
    proxy: ContractData = None, 
    upgrade: bool = False
) -> str:
    constructor = "\n    constructor() public {\n"
    constructor += f"        {camel_case(v1['name'])}V1 = {v1['interface_name']}(address(new {v1['name']}_V1()));\n"
    constructor += f"        {camel_case(v2['name'])}V2 = {v2['interface_name']}(address(new {v2['name']}_V2()));\n"
    if proxy:
        constructor += f"        {camel_case(proxy['name'])}V1 = {proxy['interface_name']}(address(new {proxy['name']}()));\n"
        constructor += f"        {camel_case(proxy['name'])}V2 = {proxy['interface_name']}(address(new {proxy['name']}()));\n"
        constructor += "        // Store the implementation addresses in the proxy.\n"
        constructor += f"        hevm.store(\n"
        constructor += f"            address({camel_case(proxy['name'])}V1),\n"
        constructor += (
            f"            bytes32(uint({proxy['implementation_slot'].slot})),\n"
        )
        constructor += (
            f"            bytes32(uint256(uint160(address({camel_case(v1['name'])}V1))))\n"
        )
        constructor += f"        );\n"
        constructor += f"        hevm.store(\n"
        constructor += f"            address({camel_case(proxy['name'])}V2),\n"
        constructor += (
            f"            bytes32(uint({proxy['implementation_slot'].slot})),\n"
        )
        constructor += (
            f"            bytes32(uint256(uint160(address({camel_case(v2['name'])}{'V1' if upgrade else 'V2'}))))\n"
        )
        constructor += f"        );\n"
    if tokens is not None:
        for t in tokens:
            constructor += f"        {camel_case(t['name'])}V1 = {t['interface_name']}(address(new {t['name']}()));\n"
            constructor += f"        {camel_case(t['name'])}V2 = {t['interface_name']}(address(new {t['name']}()));\n"
    if targets is not None:
        for t in targets:
            constructor += f"        {camel_case(t['name'])}V1 = {t['interface_name']}(address(new {t['name']}()));\n"
            constructor += f"        {camel_case(t['name'])}V2 = {t['interface_name']}(address(new {t['name']}()));\n"
    constructor += "    }\n\n"
    return constructor

def deploy_mode(args: argparse.Namespace):
    if args.output_dir is not None:
        output_dir = args.output_dir
        if not str(output_dir).endswith(os.path.sep):
            output_dir += os.path.sep
    else:
        output_dir = "./"

    if args.network:
        crytic_print(PrintMode.WARNING, "* Network specified via command line argument, but you are using 'deployment mode'. "
                                        "To use fork mode, provide addresses instead of file paths.\n  Ignoring network...\n")
    if args.block:
        crytic_print(PrintMode.WARNING, "* Block specified via command line argument, but you are using 'deployment mode'. "
                                        "To use fork mode, provide addresses instead of file paths.\n  Ignoring block...\n")
    if args.network_rpc:
        crytic_print(PrintMode.WARNING, "* RPC specified via command line argument, but you are using 'deployment mode'. "
                                        "To use fork mode, provide addresses instead of file paths.\n  Ignoring RPC...\n")

    crytic_print(PrintMode.INFORMATION, "* Inspecting V1 and V2 contracts:")
    v1_contract_data = get_contract_data_from_path(args.v1, suffix="V1")
    v2_contract_data = get_contract_data_from_path(args.v2, suffix="V2")

    if args.proxy is not None:
        crytic_print(
            PrintMode.INFORMATION,
            "\n* Proxy contract specified via command line parameter:",
        )
        proxy = get_contract_data_from_path(args.proxy)
        if not proxy["is_proxy"]:
            crytic_print(
                PrintMode.ERROR,
                f"\n  * {proxy['name']} does not appear to be a proxy. Ignoring...",
            )
            proxy = None
    else:
        proxy = None

    if args.fuzz_upgrade:
        if args.proxy:
            upgrade = True
        else:
            crytic_print(
                PrintMode.WARNING, 
                "  * Upgrade during fuzz sequence specified via command line parameter, but no proxy was specified. Ignoring..."
            )
            upgrade = False
    else:
        upgrade = False

    if args.targets is not None:
        crytic_print(
            PrintMode.INFORMATION,
            "\n* Additional targets specified via command line parameter:",
        )
        targets = get_contracts_from_comma_separated_paths(args.targets)
    else:
        targets = None

    if args.deploy:
        deploy = True
    else:
        deploy = False

    if args.seq_len:
        if str(args.seq_len).isnumeric():
            seq_len = int(args.seq_len)
        else:
            crytic_print(
                PrintMode.ERROR,
                "\n* Sequence length provided is not numeric. Defaulting to 100.",
            )
            seq_len = 100
    else:
        seq_len = 100

    if args.version:
        version = args.version
    else:
        version = "0.8.0"

    if args.contract_addr:
        contract_addr = args.contract_addr
        crytic_print(
            PrintMode.INFORMATION,
            f"\n* Exploit contract address specified via command line parameter: "
            f"{contract_addr}",
        )
    else:
        contract_addr = ""

    contract = generate_test_contract(
        v1_contract_data,
        v2_contract_data,
        deploy,
        version,
        targets=targets,
        proxy=proxy,
        upgrade=upgrade
    )
    write_to_file(f"{output_dir}DiffFuzzUpgrades.sol", contract)
    crytic_print(
        PrintMode.SUCCESS,
        f"  * Fuzzing contract generated and written to {output_dir}DiffFuzzUpgrades.sol.",
    )

    config_file = generate_config_file(
        f"{output_dir}corpus", "1000000000000", contract_addr, seq_len
    )
    write_to_file(f"{output_dir}CryticConfig.yaml", config_file)
    crytic_print(
        PrintMode.SUCCESS,
        f"  * Echidna configuration file generated and written to {output_dir}CryticConfig.yaml.",
    )

    crytic_print(
        PrintMode.MESSAGE,
        f"\n-----------------------------------------------------------",
    )
    crytic_print(
        PrintMode.MESSAGE,
        f"My work here is done. Thanks for using me, have a nice day!",
    )
    crytic_print(
        PrintMode.MESSAGE,
        f"-----------------------------------------------------------",
    )
