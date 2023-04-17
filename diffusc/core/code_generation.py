"""Module for generating test contract code."""

from typing import List, Tuple, Optional

# pylint: disable= no-name-in-module
from solc_select.solc_select import (
    switch_global_version,
    installed_versions,
    get_installable_versions,
)
from slither import Slither
from slither.exceptions import SlitherError
from slither.utils.type import convert_type_for_solidity_signature_to_string
from slither.utils.code_generation import generate_interface
from slither.utils.upgradeability import (
    get_proxy_implementation_slot,
    TaintedExternalContract,
)
from slither.core.declarations.contract import Contract
from slither.core.variables.variable import Variable
from slither.core.variables.local_variable import LocalVariable
from slither.core.declarations.enum import Enum
from slither.core.solidity_types import (
    Type,
    ElementaryType,
    UserDefinedType,
    ArrayType,
    MappingType,
)
from slither.core.declarations.structure import Structure
from diffusc.utils.classes import FunctionInfo, ContractData, Diff
from diffusc.utils.crytic_print import PrintMode, CryticPrint
from diffusc.utils.network_info_provider import NetworkInfoProvider
from diffusc.utils.helpers import (
    get_pragma_version_from_file,
    similar,
    camel_case,
    do_diff,
)


# pylint: disable=too-many-instance-attributes
class CodeGenerator:
    """Class for generating test contract code."""

    # pylint: disable=too-many-arguments
    def __init__(
        self,
        v_1: ContractData,
        v_2: ContractData,
        mode: str,
        version: str,
        upgrade: bool,
        protected: bool,
        net_info: NetworkInfoProvider = None,
    ):
        assert mode in ["deploy", "fork"]

        self._v_1: ContractData = v_1
        self._v_2: ContractData = v_2
        self._proxy: Optional[ContractData] = None
        self._targets: List[ContractData] = []
        self._fork: bool = mode == "fork"
        self._version: str = version
        self._upgrade: bool = upgrade
        self._protected: bool = protected
        self._network_info: Optional[NetworkInfoProvider] = net_info

    @property
    def v_1(self) -> ContractData:
        """V1 ContractData getter"""
        return self._v_1

    @property
    def v_2(self) -> ContractData:
        """V2 ContractData getter"""
        return self._v_2

    @property
    def proxy(self) -> Optional[ContractData]:
        """Proxy ContractData getter"""
        return self._proxy

    @proxy.setter
    def proxy(self, _proxy: ContractData) -> None:
        """Proxy ContractData setter"""
        self._proxy = _proxy

    @property
    def targets(self) -> List[ContractData]:
        """Additional targets ContractData list getter"""
        return self._targets

    @targets.setter
    def targets(self, _targets: List[ContractData]) -> None:
        """Additional targets ContractData list setter"""
        self._targets = _targets

    @staticmethod
    def generate_config_file(
        corpus_dir: str, campaign_length: str, contract_addr: str, seq_len: int
    ) -> str:
        """Generate an Echidna config file."""
        CryticPrint.print(
            PrintMode.INFORMATION,
            f"* Generating Echidna configuration file with campaign limit {campaign_length}"
            f" and corpus directory {corpus_dir}",
        )
        config_file = "testMode: assertion\n"
        config_file += f"testLimit: {campaign_length}\n"
        config_file += f"corpusDir: {corpus_dir}\n"
        config_file += "codeSize: 0xffff\n"
        config_file += f"seqLen: {seq_len}\n"
        if contract_addr != "":
            config_file += f"contractAddr: '{contract_addr}'\n"

        return config_file

    @staticmethod
    def get_solidity_function_parameters(parameters: List[LocalVariable]) -> List[str]:
        """Get function parameters as solidity types."""
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

    @staticmethod
    def get_solidity_function_returns(return_type: List[Type]) -> List[str]:
        """Get function return types as solidity types."""
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
                    if isinstance(out.type, UserDefinedType) and isinstance(
                        out.type.type, Structure
                    ):
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

    @staticmethod
    def get_contract_interface(contract_data: ContractData) -> ContractData:
        """Populate ContractData with contract interface and function info from Slither"""

        contract: Contract = contract_data["contract_object"]
        suffix: str = contract_data["suffix"]

        if not contract.functions_entry_points:
            raise ValueError("Contract has no public or external functions")

        contract_data["functions"] = []

        for i in contract.functions_entry_points:

            # Interface won't need constructor or fallbacks
            if i.is_constructor or i.is_fallback or i.is_receive:
                continue

            # Get info for interface and wrapper
            name = i.name
            inputs = CodeGenerator.get_solidity_function_parameters(i.parameters)
            outputs = CodeGenerator.get_solidity_function_returns(i.return_type)
            protected = i.is_protected()

            contract_data["functions"].append(
                FunctionInfo(
                    name=name,
                    function=i,
                    inputs=inputs,
                    outputs=outputs,
                    protected=protected,
                )
            )

        contract_data["name"] = contract.name
        contract_data["interface"] = generate_interface(
            contract, unroll_structs=False, skip_errors=True, skip_events=True
        ).replace(f"interface I{contract.name}", f"interface I{contract.name}{suffix}")
        contract_data["interface_name"] = f"I{contract.name}{suffix}"

        return contract_data

    @staticmethod
    def get_contract_data(contract: Contract, suffix: str = "") -> ContractData:
        """Get ContractData object from Contract object."""

        CryticPrint.print(PrintMode.MESSAGE, f"  * Getting contract data from {contract.name}")

        version = get_pragma_version_from_file(contract.file_scope.filename.absolute)
        contract_data = ContractData(
            contract_object=contract,
            suffix=suffix,
            path=contract.file_scope.filename.absolute,
            solc_version=version,
        )
        if version in installed_versions() or version in get_installable_versions():
            switch_global_version(version, True)

        try:
            contract_data["slither"] = Slither(contract.compilation_unit.crytic_compile)
            contract_data["valid_data"] = True
        except SlitherError:
            contract_data["slither"] = None
            contract_data["valid_data"] = False

        if contract_data["valid_data"]:
            contract_data = CodeGenerator.get_valid_contract_data(contract_data)

        return contract_data

    @staticmethod
    def get_valid_contract_data(contract_data: ContractData) -> ContractData:
        """Complete the ContractData object after getting valid data from Slither."""

        assert contract_data["valid_data"]

        if contract_data["contract_object"].is_upgradeable_proxy:
            contract_data["is_proxy"] = True
            contract_data["implementation_slot"] = get_proxy_implementation_slot(
                contract_data["contract_object"]
            )
        else:
            contract_data["is_proxy"] = False
        contract_data = CodeGenerator.get_contract_interface(contract_data)

        return contract_data

    @staticmethod
    def get_args_and_returns_for_wrapping(
        func: FunctionInfo,
    ) -> Tuple[str, str, List[str], List[str]]:
        """Get function arguments and return value types for wrapper functions."""

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
        if len(func["outputs"]) == 0:
            return_vals = ""
        elif len(func["outputs"]) == 1:
            for j in range(0, 2):
                return_vals.append(f"{func['outputs'][0]} {chr(ord('a') + counter)}")
                returns_to_compare.append(f"{chr(ord('a') + counter)}")
                counter += 1
        else:
            for j in range(0, 2):
                return_vals.append("(")
                returns_to_compare.append("(")
                for i in func["outputs"]:
                    return_vals[j] += f"{i} {chr(ord('a') + counter)}, "
                    returns_to_compare[j] += f"{chr(ord('a') + counter)}, "
                    counter += 1
                return_vals[j] = f"{return_vals[j][0:-2]})"
                returns_to_compare[j] = f"{returns_to_compare[j][0:-2]})"
        return args, call_args, return_vals, returns_to_compare

    def wrap_additional_target_functions(
        self,
        tainted: List[TaintedExternalContract] = None,
    ) -> str:
        """Create wrapper functions for a list of additional target contracts."""

        protected_mods = [
            "onlyOwner",
            "onlyAdmin",
            "ifOwner",
            "ifAdmin",
            "adminOnly",
            "ownerOnly",
        ]
        wrapped = ""

        targets = self.targets
        proxy = self.proxy
        if targets is None or len(targets) == 0:
            return wrapped
        if tainted is None:
            tainted = []
        if proxy is None:
            proxy = ContractData(name="")
        tainted_contracts = [taint.contract for taint in tainted]
        CryticPrint.print(
            PrintMode.INFORMATION, "  * Adding wrapper functions for additional targets."
        )

        wrapped += "\n    /*** Additional Targets ***/ \n\n"
        for target in targets:
            contract: Contract = target["contract_object"]
            if contract.name in [t.name for t in tainted_contracts] + [proxy["name"]]:
                # already covered by wrap_diff_functions
                continue
            functions_to_wrap: List[FunctionInfo] = target["functions"]
            for func in functions_to_wrap:
                mods = [m.name for m in func["function"].modifiers]
                if not self._protected and any(m in protected_mods for m in mods):
                    continue
                if len(tainted) > 0:
                    if any(
                        func["function"].signature_str == f.signature_str
                        for taint in tainted
                        for f in taint.tainted_functions
                    ):
                        wrapped += self.wrap_diff_function(target, target, func)
                else:
                    wrapped += self.wrap_diff_function(target, target, func)
        return wrapped

    def wrap_low_level_call(
        self,
        c_data: ContractData,
        func: FunctionInfo,
        suffix: str,
        proxy=None,
    ) -> str:
        """Generate code for a low-level call to use in wrapper functions."""

        if proxy is None:
            target = camel_case(c_data["name"])
        else:
            target = camel_case(proxy["name"])
        if not self._fork:
            target += c_data["suffix"]
        _, call_args, _, _ = self.get_args_and_returns_for_wrapping(func)
        wrapped = ""
        wrapped += (
            f"        (bool success{suffix}, bytes memory output{suffix}) = "
            f"address({target}).call(\n"
        )
        wrapped += "            abi.encodeWithSelector(\n"
        wrapped += (
            f"                {camel_case(c_data['name'])}{c_data['suffix']}."
            f"{func['name']}"
            f".selector{call_args.replace('()', '').replace('(', ', ').replace(')', '')}\n"
        )
        wrapped += "            )\n"
        wrapped += "        );\n"
        return wrapped

    # pylint: disable=too-many-arguments
    def wrap_diff_function(
        self,
        v_1: ContractData,
        v_2: ContractData,
        func: FunctionInfo,
        func2: FunctionInfo = None,
        proxy: ContractData = None,
    ) -> str:
        """Create wrapper function for comparing V1 and V2."""

        wrapped = ""
        if func2 is None:
            func2 = func
        args, _, _, _ = self.get_args_and_returns_for_wrapping(func2)

        wrapped += f"    function {v_2['name']}_{func2['name']}{args} public virtual {{\n"
        if self._fork:
            wrapped += "        hevm.selectFork(fork2);\n"
        if not func2["protected"]:
            wrapped += "        hevm.prank(msg.sender);\n"
        wrapped += self.wrap_low_level_call(v_2, func2, "V2", proxy)
        # if len(return_vals) > 0:
        #     wrapped +=  f"        {return_vals[0]} = {v1['name']}V1.{func[0]}{call_args};\n"
        # else:
        #     wrapped +=  f"        {v1['name']}V1.{func[0]}{call_args};\n"
        if self._fork:
            wrapped += "        hevm.selectFork(fork1);\n"
        if not func["protected"]:
            wrapped += "        hevm.prank(msg.sender);\n"
        wrapped += self.wrap_low_level_call(v_1, func, "V1", proxy)
        wrapped += "        assert(successV1 == successV2); \n"
        wrapped += "        assert((!successV1 && !successV2) || keccak256(outputV1) == keccak256(outputV2));\n"
        # if len(return_vals) > 0:
        #     wrapped +=  f"        {return_vals[1]} = {v2['name']}V2.{func[0]}{call_args};\n"
        #     wrapped +=  f"        return {returns_to_compare[0]} == {returns_to_compare [1]};\n"
        # else:
        #     wrapped +=  f"        {v2['name']}V2.{func[0]}{call_args};\n"
        wrapped += "    }\n\n"
        return wrapped

    # pylint: disable=too-many-branches
    def wrap_tainted_vars(
        self,
        variables: List[Variable],
    ) -> str:
        """Create wrapper functions for comparing tainted state variables."""

        v_1 = self.v_1
        v_2 = self.v_2
        proxy = self.proxy
        fork = self._fork

        wrapped = "\n    /*** Tainted Variables ***/ \n\n"
        for var in variables:
            if proxy is None:
                target_v1 = camel_case(v_1["name"]) + v_1["suffix"]
                target_v2 = camel_case(v_2["name"]) + v_2["suffix"]
            elif fork:
                target_v1 = f"{v_1['interface_name']}(address({camel_case(proxy['name'])}))"
                target_v2 = f"{v_2['interface_name']}(address({camel_case(proxy['name'])}))"
            else:
                target_v1 = (
                    f"{v_1['interface_name']}(address({camel_case(proxy['name'])}{v_1['suffix']}))"
                )
                target_v2 = (
                    f"{v_2['interface_name']}(address({camel_case(proxy['name'])}{v_2['suffix']}))"
                )
            if var.visibility in ["internal", "private"]:
                continue
            if var.type.is_dynamic:
                if isinstance(var.type, MappingType):
                    type_from = var.type.type_from.name
                    wrapped += f"    function {v_1['name']}_{var.name}({type_from} a) public {{\n"
                    if fork:
                        wrapped += "        hevm.selectFork(fork1);\n"
                        wrapped += f"        {var.type.type_to} a1 = {target_v1}.{var.name}(a);\n"
                        wrapped += "        hevm.selectFork(fork2);\n"
                        wrapped += f"        {var.type.type_to} a2 = {target_v2}.{var.name}(a);\n"
                        wrapped += "        assert(a1 == a2);\n"
                    else:
                        wrapped += f"        assert({target_v1}.{var.name}(a) == {target_v2}.{var.name}(a));\n"
                elif isinstance(var.type, ArrayType):
                    wrapped += f"    function {v_1['name']}_{var.name}(uint i) public {{\n"
                    if fork:
                        wrapped += "        hevm.selectFork(fork1);\n"
                        wrapped += f"        {var.type.type} a1 = {target_v1}.{var.name}(i);\n"
                        wrapped += "        hevm.selectFork(fork2);\n"
                        wrapped += f"        {var.type.type} a2 = {target_v2}.{var.name}(i);\n"
                        wrapped += "        assert(a1 == a2);\n"
                    else:
                        wrapped += f"        assert({target_v1}.{var.name}(i) == {target_v2}.{var.name}(i));\n"
            else:
                wrapped += f"    function {v_1['name']}_{var.full_name} public {{\n"
                if fork:
                    wrapped += "        hevm.selectFork(fork1);\n"
                    wrapped += f"        {'address' if isinstance(var.type, UserDefinedType) and isinstance(var.type.type, Contract) else var.type} a1 = {target_v1}.{var.full_name};\n"
                    wrapped += "        hevm.selectFork(fork2);\n"
                    wrapped += f"        {'address' if isinstance(var.type, UserDefinedType) and isinstance(var.type.type, Contract) else var.type} a2 = {target_v2}.{var.full_name};\n"
                    wrapped += "        assert(a1 == a2);\n"
                else:
                    wrapped += f"        assert({target_v1}.{var.full_name} == {target_v2}.{var.full_name});\n"
            wrapped += "    }\n\n"
        return wrapped

    # pylint: disable=too-many-branches,too-many-statements,too-many-locals
    def wrap_diff_functions(
        self,
        diff: Diff,
        external_taint: List[ContractData] = None,
    ) -> str:
        """Create wrapper functions based on the diff between V1 and V2, including tainted contracts."""

        v_1 = self.v_1
        v_2 = self.v_2
        proxy = self.proxy
        fork = self._fork
        protected = self._protected

        protected_mods = [
            "onlyOwner",
            "onlyAdmin",
            "ifOwner",
            "ifAdmin",
            "adminOnly",
            "ownerOnly",
        ]

        wrapped = "\n    /*** Modified Functions ***/ \n\n"
        for diff_func in diff["modified_functions"]:
            mods = [m.name for m in diff_func.modifiers]
            if not protected and any(m in protected_mods for m in mods):
                continue
            if diff_func.visibility in ["internal", "private"]:
                continue
            func = next(
                func
                for func in v_2["functions"]
                if func["name"] == diff_func.name
                and len(func["inputs"]) == len(diff_func.parameters)
            )
            if proxy is not None:
                wrapped += self.wrap_diff_function(v_1, v_2, func, proxy=proxy)
            else:
                wrapped += self.wrap_diff_function(v_1, v_2, func)

        wrapped += "\n    /*** Tainted Functions ***/ \n\n"
        for diff_func in diff["tainted_functions"]:
            mods = [m.name for m in diff_func.modifiers]
            if not protected and any(m in protected_mods for m in mods):
                continue
            if diff_func.visibility in ["internal", "private"]:
                continue
            func = next(
                func
                for func in v_2["functions"]
                if func["name"] == diff_func.name
                and len(func["inputs"]) == len(diff_func.parameters)
            )
            if proxy is not None:
                wrapped += self.wrap_diff_function(v_1, v_2, func, proxy=proxy)
            else:
                wrapped += self.wrap_diff_function(v_1, v_2, func)

        wrapped += "\n    /*** New Functions ***/ \n\n"
        for diff_func in diff["new_functions"]:
            mods = [m.name for m in diff_func.modifiers]
            if not protected and any(m in protected_mods for m in mods):
                continue
            if diff_func.visibility in ["internal", "private"]:
                continue
            for func_0 in v_1["contract_object"].functions_entry_points:
                if similar(diff_func.name, func_0.name):
                    wrapped += "    // TODO: Double-check this function for correctness\n"
                    wrapped += f"    // {diff_func.canonical_name}\n"
                    wrapped += "    // is a new function, which appears to replace a function with a similar name,\n"
                    wrapped += f"    // {func_0.canonical_name}.\n"
                    wrapped += "    // If these functions have different arguments, this function may be incorrect.\n"
                    func = next(func for func in v_1["functions"] if func["name"] == func_0.name)
                    func2 = next(
                        func for func in v_2["functions"] if func["name"] == diff_func.name
                    )
                    if proxy is not None:
                        wrapped += self.wrap_diff_function(v_1, v_2, func, func2, proxy)
                    else:
                        wrapped += self.wrap_diff_function(v_1, v_2, func, func2)

        wrapped += self.wrap_tainted_vars(diff["tainted_variables"])

        if external_taint:
            wrapped += "\n    /*** Tainted External Contracts ***/ \n\n"
            for tainted in diff["tainted_contracts"]:
                contract: Contract = tainted.contract
                contract_data = next(
                    (t for t in external_taint if t["name"] == contract.name), None
                )
                if contract_data:
                    contract_data_2 = contract_data.copy()
                    if not fork:
                        contract_data["suffix"] = "V1"
                        contract_data_2["suffix"] = "V2"
                    for diff_func in tainted.tainted_functions:
                        mods = [m.name for m in diff_func.modifiers]
                        if not protected and any(m in protected_mods for m in mods):
                            continue
                        if diff_func.visibility in ["internal", "private"] or any(
                            [diff_func.is_constructor, diff_func.is_fallback, diff_func.is_receive]
                        ):
                            continue
                        func = next(
                            func
                            for func in contract_data["functions"]
                            if func["name"] == diff_func.name
                            and len(func["inputs"]) == len(diff_func.parameters)
                        )
                        wrapped += self.wrap_diff_function(contract_data, contract_data_2, func)

        return wrapped

    # pylint: disable=too-many-branches,too-many-statements,too-many-locals
    def generate_test_contract(self) -> str:
        """Main function for generating a diff fuzzing test contract."""

        v_1 = self.v_1
        v_2 = self.v_2
        proxy = self.proxy
        targets = self.targets
        if targets is None:
            targets = []
        version = self._version
        fork = self._fork
        upgrade = self._upgrade

        final_contract = ""
        diff: Diff = do_diff(v_1, v_2, targets)
        tainted_contracts: List[TaintedExternalContract] = diff["tainted_contracts"]
        tainted_contracts = [
            t
            for t in tainted_contracts
            if t.contract not in [v_1["contract_object"], v_2["contract_object"]]
        ]
        CryticPrint.print(PrintMode.INFORMATION, "* Getting contract data for tainted contracts.")
        tainted_targets = [
            self.get_contract_data(t.contract)
            if t.contract.name
            not in [
                target["contract_object"].name if target["valid_data"] else "" for target in targets
            ]
            + [proxy["contract_object"].name if proxy is not None and proxy["valid_data"] else ""]
            else next(target for target in targets + [proxy] if t.contract.name == target["name"])
            for t in tainted_contracts
        ]
        tainted_targets = [t for t in tainted_targets if t["valid_data"]]
        other_targets = list(targets)
        if proxy:
            other_targets.append(proxy)

        CryticPrint.print(PrintMode.INFORMATION, "\n* Generating exploit contract...")
        # Add solidity pragma and SPDX to avoid warnings
        final_contract += f"// SPDX-License-Identifier: AGPLv3\npragma solidity ^{version};\n\n"

        if not fork:
            final_contract += (
                f'import {{ {v_1["name"]} as {v_1["name"]}_V1 }} from "{v_1["path"]}";\n'
            )
            final_contract += (
                f'import {{ {v_2["name"]} as {v_2["name"]}_V2 }} from "{v_2["path"]}";\n'
            )
            if proxy:
                final_contract += f'import {{ {proxy["name"]} }} from "{proxy["path"]}";\n'
            for target in targets:
                final_contract += f'import {{ {target["name"]} }} from "{target["path"]}";\n'
            if tainted_targets is not None:
                for tainted in tainted_targets:
                    contract: Contract = tainted["contract_object"]
                    if contract.name not in (t["name"] for t in other_targets):
                        final_contract += (
                            f"import {{ {contract.name} }} from "
                            f'"{contract.file_scope.filename.absolute}";\n'
                        )
            final_contract += "\n"

        # Add all interfaces first
        CryticPrint.print(PrintMode.INFORMATION, "  * Adding interfaces.")
        final_contract += v_1["interface"]
        final_contract += v_2["interface"]

        for target in targets:
            final_contract += target["interface"]
        for target in tainted_targets:
            if target["name"] not in (t["contract_object"].name for t in other_targets):
                final_contract += target["interface"]
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
        final_contract += (
            "    function sign(uint256 privateKey, bytes32 digest) "
            "external returns (uint8 r, bytes32 v, bytes32 s);\n"
        )
        final_contract += "    function addr(uint256 privateKey) external returns (address add);\n"
        final_contract += (
            "    function ffi(string[] calldata inputs) external returns "
            "(bytes memory result);\n"
        )
        final_contract += "    function prank(address newSender) external;\n"
        final_contract += "    function createFork() external returns (uint256 forkId);\n"
        final_contract += "    function selectFork(uint256 forkId) external;\n}\n\n"

        # Create the exploit contract
        CryticPrint.print(PrintMode.INFORMATION, "  * Creating the exploit contract.")
        final_contract += "contract DiffFuzzUpgrades {\n"

        # State variables
        CryticPrint.print(PrintMode.INFORMATION, "  * Adding state variables declarations.")

        final_contract += "    IHevm hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);\n\n"
        final_contract += "    // TODO: Deploy the contracts and put their addresses below\n"
        final_contract += f"    {v_1['interface_name']} {camel_case(v_1['name'])}V1;\n"
        final_contract += f"    {v_2['interface_name']} {camel_case(v_2['name'])}V2;\n"

        if not fork:
            if proxy is not None:
                final_contract += f"    {proxy['interface_name']} {camel_case(proxy['name'])}V1;\n"
                final_contract += f"    {proxy['interface_name']} {camel_case(proxy['name'])}V2;\n"

            for target in targets:
                final_contract += (
                    f"    {target['interface_name']} {camel_case(target['name'])}V1;\n"
                )
                final_contract += (
                    f"    {target['interface_name']} {camel_case(target['name'])}V2;\n"
                )

            for target in tainted_targets:
                if target["name"] not in [t["name"] for t in other_targets]:
                    final_contract += (
                        f"    {target['interface_name']} {camel_case(target['name'])}V1;\n"
                    )
                    final_contract += (
                        f"    {target['interface_name']} {camel_case(target['name'])}V2;\n"
                    )
        else:
            if proxy is not None:
                final_contract += f"    {proxy['interface_name']} {camel_case(proxy['name'])};\n"

            for target in targets:
                final_contract += f"    {target['interface_name']} {camel_case(target['name'])};\n"

            for target in tainted_targets:
                if target["name"] not in [t["name"] for t in other_targets]:
                    final_contract += (
                        f"    {target['interface_name']} {camel_case(target['name'])};\n"
                    )
            final_contract += "    uint256 fork1;\n    uint256 fork2;\n"

        # Constructor
        CryticPrint.print(PrintMode.INFORMATION, "  * Generating constructor.")

        if not fork:
            final_contract += self.generate_deploy_constructor(tainted_targets)
        else:
            final_contract += self.generate_fork_constructor(tainted_targets)

        # Upgrade function
        if upgrade and proxy is not None:
            CryticPrint.print(PrintMode.INFORMATION, "  * Adding upgrade function.")
            final_contract += "    /*** Upgrade Function ***/ \n\n"
            final_contract += (
                "    // TODO: Consider replacing this with the actual upgrade method\n"
            )
            final_contract += "    function upgradeV2() external virtual {\n"
            if proxy["implementation_slot"] is not None:
                final_contract += "        hevm.store(\n"
                final_contract += (
                    f"            address({camel_case(proxy['name'])}"
                    f"{v_2['suffix'] if not fork else ''}),\n"
                )
                final_contract += (
                    f"            bytes32(uint({proxy['implementation_slot'].slot})),\n"
                )
                final_contract += (
                    "            bytes32(uint256(uint160(address("
                    f"{camel_case(v_2['name'])}{v_2['suffix']}))))\n"
                )
                final_contract += "        );\n"
            else:
                final_contract += (
                    "        // TODO: add upgrade logic here "
                    "(implementation slot could not be found automatically)\n"
                )
            final_contract += "    }\n\n"

        # Wrapper functions for V1/V2
        CryticPrint.print(PrintMode.INFORMATION, "  * Adding wrapper functions for V1/V2.")

        final_contract += self.wrap_diff_functions(diff, tainted_targets)

        # Wrapper functions for additional targets
        if targets is not None:
            final_contract += self.wrap_additional_target_functions(tainted_contracts)

        # End of contract
        final_contract += "}\n"

        return final_contract

    def generate_deploy_constructor(
        self,
        tainted_targets: List[ContractData] = None,
    ) -> str:
        """Generate constructor code for path mode, including contract deployment."""
        v_1 = self.v_1
        v_2 = self.v_2
        proxy = self.proxy
        targets = self.targets
        if targets is None:
            targets = []
        upgrade = self._upgrade

        constructor = "\n    constructor() public {\n"
        constructor += (
            f"        {camel_case(v_1['name'])}{v_1['suffix']} = "
            f"{v_1['interface_name']}(address(new {v_1['name']}_V1()));\n"
        )
        constructor += (
            f"        {camel_case(v_2['name'])}{v_2['suffix']} = "
            f"{v_2['interface_name']}(address(new {v_2['name']}_V2()));\n"
        )
        if proxy:
            constructor += (
                f"        {camel_case(proxy['name'])}{v_1['suffix']} = "
                f"{proxy['interface_name']}(address(new {proxy['name']}()));\n"
            )
            constructor += (
                f"        {camel_case(proxy['name'])}{v_2['suffix']} = "
                f"{proxy['interface_name']}(address(new {proxy['name']}()));\n"
            )
            if proxy["implementation_slot"] is not None:
                constructor += "        // Store the implementation addresses in the proxy.\n"
                constructor += "        hevm.store(\n"
                constructor += f"            address({camel_case(proxy['name'])}{v_1['suffix']}),\n"
                constructor += f"            bytes32(uint({proxy['implementation_slot'].slot})),\n"
                constructor += (
                    "            bytes32(uint256(uint160(address("
                    f"{camel_case(v_1['name'])}{v_1['suffix']}))))\n"
                )
                constructor += "        );\n"
                constructor += "        hevm.store(\n"
                constructor += f"            address({camel_case(proxy['name'])}{v_2['suffix']}),\n"
                constructor += f"            bytes32(uint({proxy['implementation_slot'].slot})),\n"
                v2_impl = (
                    camel_case(v_1["name"]) + v_1["suffix"]
                    if upgrade
                    else camel_case(v_2["name"]) + v_2["suffix"]
                )
                constructor += f"            bytes32(uint256(uint160(address({v2_impl}))))\n"
                constructor += "        );\n"
            else:
                constructor += (
                    "        // TODO: Set proxy implementations "
                    "(proxy implementation slot not found).\n"
                )
        for target in targets:
            constructor += (
                f"        {camel_case(target['name'])}{v_1['suffix']} = "
                f"{target['interface_name']}(address(new {target['name']}()));\n"
            )
            constructor += (
                f"        {camel_case(target['name'])}{v_2['suffix']} = "
                f"{target['interface_name']}(address(new {target['name']}()));\n"
            )
        other_targets = targets
        if proxy:
            other_targets.append(proxy)
        if tainted_targets is not None:
            for target in tainted_targets:
                if target["name"] not in (
                    target["contract_object"].name for target in other_targets
                ):
                    constructor += (
                        f"        {camel_case(target['name'])}{v_1['suffix']} = "
                        f"{target['interface_name']}(address(new {target['name']}()));\n"
                    )
                    constructor += (
                        f"        {camel_case(target['name'])}{v_2['suffix']} = "
                        f"{target['interface_name']}(address(new {target['name']}()));\n"
                    )
        constructor += "    }\n\n"
        return constructor

    def generate_fork_constructor(
        self,
        tainted_targets: List[ContractData] = None,
    ) -> str:
        """Generate constructor code for fork mode."""
        v_1 = self.v_1
        v_2 = self.v_2
        proxy = self.proxy
        targets = self.targets
        if targets is None:
            targets = []
        upgrade = self._upgrade
        network_info = self._network_info

        constructor = "\n    constructor() public {\n"
        if network_info is not None:
            constructor += f"        hevm.roll({network_info.get_block_number()});\n"
        constructor += "        fork1 = hevm.createFork();\n        fork2 = hevm.createFork();\n"
        constructor += (
            f"        {camel_case(v_1['name'])}{v_1['suffix']} = "
            f"{v_1['interface_name']}({v_1['address']});\n"
        )
        constructor += (
            f"        {camel_case(v_2['name'])}{v_2['suffix']} = "
            f"{v_2['interface_name']}({v_2['address']});\n"
        )
        if proxy:
            constructor += (
                f"        {camel_case(proxy['name'])} = "
                f"{proxy['interface_name']}({proxy['address']});\n"
            )
            if proxy["implementation_slot"] is not None:
                constructor += "        // Store the implementation addresses in the proxy.\n"
                constructor += "        hevm.selectFork(fork1);\n"
                constructor += "        hevm.store(\n"
                constructor += f"            address({camel_case(proxy['name'])}),\n"
                constructor += f"            bytes32(uint({proxy['implementation_slot'].slot})),\n"
                constructor += (
                    "            bytes32(uint256(uint160(address("
                    f"{camel_case(v_1['name'])}{v_1['suffix']}))))\n"
                )
                constructor += "        );\n"
                constructor += "        hevm.selectFork(fork2);\n"
                constructor += "        hevm.store(\n"
                constructor += f"            address({camel_case(proxy['name'])}),\n"
                constructor += f"            bytes32(uint({proxy['implementation_slot'].slot})),\n"
                v2_impl = (
                    camel_case(v_1["name"]) + v_1["suffix"]
                    if upgrade
                    else camel_case(v_2["name"]) + v_2["suffix"]
                )
                constructor += f"            bytes32(uint256(uint160(address({v2_impl}))))\n"
                constructor += "        );\n"
            else:
                constructor += (
                    "        // TODO: Set proxy implementations "
                    "(proxy implementation slot not found).\n"
                )
        for target in targets:
            if "address" in target:
                constructor += (
                    f"        {camel_case(target['name'])} = "
                    f"{target['interface_name']}({target['address']});\n"
                )
            else:
                constructor += (
                    "        // TODO: Fill in target address below "
                    "(address not found automatically)\n"
                )
                constructor += (
                    f"        {camel_case(target['name'])} = "
                    f"{target['interface_name']}(MISSING_TARGET_ADDRESS);\n"
                )
        other_targets = targets
        if proxy:
            other_targets.append(proxy)
        if tainted_targets is not None:
            for target in tainted_targets:
                if target["name"] not in (
                    target["contract_object"].name for target in other_targets
                ):
                    if "address" in target:
                        constructor += (
                            f"        {camel_case(target['name'])} = "
                            f"{target['interface_name']}({target['address']});\n"
                        )
                    else:
                        constructor += (
                            "        // TODO: Fill in target address below "
                            "(address not found automatically)\n"
                        )
                        constructor += (
                            f"        {camel_case(target['name'])} = "
                            f"{target['interface_name']}(MISSING_TARGET_ADDRESS);\n"
                        )
        constructor += "    }\n\n"
        return constructor
