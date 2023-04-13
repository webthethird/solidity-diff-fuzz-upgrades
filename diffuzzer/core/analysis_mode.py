import os
import argparse
from typing import List, Optional
from diffuzzer.utils.classes import ContractData
from diffuzzer.utils.crytic_print import CryticPrint
from diffuzzer.utils.slither_provider import SlitherProvider
from diffuzzer.utils.network_info_provider import NetworkInfoProvider
from diffuzzer.core.code_generation import CodeGenerator


class AnalysisMode:
    _mode: str
    _provider: SlitherProvider
    _net_info: Optional[NetworkInfoProvider]
    _v1: Optional[ContractData]
    _v2: Optional[ContractData]
    _proxy: Optional[ContractData]
    _targets: Optional[List[ContractData]]
    _output_dir: str
    _version: str
    _seq_len: int
    _contract_addr: str
    _upgrade: bool
    _protected: bool

    def __init__(self, args: argparse.Namespace) -> None:
        self.parse_args(args)
        self._v1 = None
        self._v2 = None
        self._proxy = None
        self._targets = None

    def parse_args(self, args: argparse.Namespace) -> None:
        """Parse arguments that are used in both analysis modes."""

        if args.version:
            self._version = args.version
        else:
            self._version = "0.8.0"

        if args.fuzz_upgrade and not args.proxy:
            CryticPrint.print_warning(
                "  * Upgrade during fuzz sequence specified via command line parameter,"
                " but no proxy was specified. Ignoring...",
            )
            self._upgrade = False
        else:
            self._upgrade = bool(args.fuzz_upgrade)

        self._protected = bool(args.include_protected)

    def analyze_contracts(self) -> None:
        raise NotImplementedError()

    def write_test_contract(self) -> str:
        """
        Calls CodeGenerator.generate_test_contract and returns the generated contract code.
        :return: The test contract code as a string.
        """
        if not self._v1 or not self._v2:
            self.analyze_contracts()

        code_generator = CodeGenerator(
            self._v1,
            self._v2,
            self._mode,
            self._version,
            self._upgrade,
            self._protected,
            self._net_info
        )
        code_generator.proxy = self._proxy
        code_generator.targets = self._targets

        contract = code_generator.generate_test_contract()
        return contract
