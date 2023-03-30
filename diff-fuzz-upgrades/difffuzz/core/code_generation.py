from typing import List, Tuple

from slither import Slither
from slither.utils.type import convert_type_for_solidity_signature_to_string
from slither.utils.code_generation import generate_interface
from slither.utils.upgradeability import get_proxy_implementation_slot, TaintedExternalContract
from slither.core.declarations.contract import Contract
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
from difffuzz.classes import FunctionInfo, ContractData, Diff
from difffuzz.utils.printer import PrintMode, crytic_print
from difffuzz.utils.helpers import (
    get_pragma_version_from_file,
    similar,
    camel_case,
    do_diff
)


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


def get_contract_data(contract: Contract, suffix: str = "") -> ContractData:
    contract_data = ContractData(
        contract_object=contract,
        suffix=suffix,
        path=contract.file_scope.filename.absolute,
        solc_version=get_pragma_version_from_file(contract.file_scope.filename.absolute),
    )

    try:
        contract_data["slither"] = Slither(contract.file_scope.filename.absolute)
        contract_data["valid_data"] = True
    except:
        contract_data["slither"] = None
        contract_data["valid_data"] = False

    if contract_data["valid_data"]:
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

    return contract_data


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

    diff: Diff = do_diff(v1, v2)

    wrapped += "\n    /*** Modified Functions ***/ \n\n"
    for f in diff["modified_functions"]:
        if f.visibility in ["internal", "private"]:
            continue
        func = next(func for func in v2["functions"] if func['name'] == f.name and len(func['inputs']) == len(f.parameters))
        if proxy is not None:
            wrapped += wrap_diff_function(v1, v2, func, proxy=proxy)
        else:
            wrapped += wrap_diff_function(v1, v2, func)

    wrapped += "\n    /*** Tainted Functions ***/ \n\n"
    for f in diff["tainted_functions"]:
        if f.visibility in ["internal", "private"]:
            continue
        func = next(func for func in v2["functions"] if func['name'] == f.name and len(func['inputs']) == len(f.parameters))
        if proxy is not None:
            wrapped += wrap_diff_function(v1, v2, func, proxy=proxy)
        else:
            wrapped += wrap_diff_function(v1, v2, func)

    wrapped += "\n    /*** New Functions ***/ \n\n"
    for f in diff["new_functions"]:
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
    for v in diff["tainted_variables"]:
        if proxy is None:
            target_v1 = camel_case(v1['name']) + "V1"
            target_v2 = camel_case(v2['name']) + "V2"
        else:
            target_v1 = f"{v1['interface_name']}(address({camel_case(proxy['name'])}V1))"
            target_v2 = f"{v2['interface_name']}(address({camel_case(proxy['name'])}V2))"
        if v.visibility in ["internal", "private"]:
            continue
        if v.type.is_dynamic:
            if isinstance(v.type, MappingType):
                type_from = v.type.type_from.name
                wrapped += (
                    f"    function {v1['name']}_{v.name}({type_from} a) public {{\n"
                )
                wrapped += f"        assert({target_v1}.{v.name}(a) == {target_v2}.{v.name}(a));\n"
                wrapped += "    }\n\n"
            elif isinstance(v.type, ArrayType):
                wrapped += f"    function {v1['name']}_{v.name}(uint i) public {{\n"
                wrapped += f"        assert({target_v1}.{v.name}(i) == {target_v2}.{v.name}(i));\n"
                wrapped += "    }\n\n"
        else:
            wrapped += f"    function {v1['name']}_{v.full_name} public {{\n"
            wrapped += f"        assert({target_v1}.{v.full_name} == {target_v2}.{v.full_name});\n"
            wrapped += "    }\n\n"

    return wrapped


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
