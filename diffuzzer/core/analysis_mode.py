import os
import argparse
from typing import List, Optional
from diffuzzer.utils.classes import ContractData
from diffuzzer.utils.crytic_print import CryticPrint
from diffuzzer.utils.slither_provider import SlitherProvider
from diffuzzer.utils.network_info_provider import NetworkInfoProvider
from diffuzzer.core.code_generation import generate_test_contract


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
        if args.output_dir is not None:
            self._output_dir = args.output_dir
            if not str(self._output_dir).endswith(os.path.sep):
                self._output_dir += os.path.sep
        else:
            self._output_dir = "./"
        if args.seq_len:
            if str(args.seq_len).isnumeric():
                self._seq_len = int(args.seq_len)
            else:
                CryticPrint.print_error(
                    "\n* Sequence length provided is not numeric. Defaulting to 100.",
                )
                self._seq_len = 100
        else:
            self._seq_len = 100

        if args.version:
            self._version = args.version
        else:
            self._version = "0.8.0"

        if args.contract_addr:
            self._contract_addr = args.contract_addr
            CryticPrint.print_information(
                "\n* Exploit contract address specified via command line parameter: "
                f"{self._contract_addr}",
            )
        else:
            self._contract_addr = ""

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
        if not self._v1 or not self._v2:
            self.analyze_contracts()
        contract = generate_test_contract(
            self._v1,
            self._v2,
            self._mode,
            self._version,
            targets=self._targets,
            proxy=self._proxy,
            upgrade=self._upgrade,
            protected=self._protected,
            network_info=self._net_info
        )
        return contract
