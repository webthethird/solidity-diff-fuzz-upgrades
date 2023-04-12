#!/usr/bin/env python3

"""Main module for path mode."""

import argparse
from typing import Optional

from diffuzzer.utils.crytic_print import PrintMode, CryticPrint
from diffuzzer.utils.helpers import write_to_file
from diffuzzer.core.code_generation import generate_test_contract
from diffuzzer.utils.classes import ContractData
from diffuzzer.utils.from_path import (
    get_contracts_from_comma_separated_paths,
    get_contract_data_from_path,
)
from diffuzzer.utils.slither_provider import FileSlitherProvider
from diffuzzer.core.analysis_mode import AnalysisMode


class PathMode(AnalysisMode):
    """Class for handling targets provided as file paths."""
    _v1_path: str
    _v2_path: str
    _proxy_path: Optional[str]
    _target_paths: Optional[str]

    def __init__(self, args: argparse.Namespace) -> None:
        self._mode = "deploy"
        self._provider = FileSlitherProvider()
        self._net_info = None
        super().__init__(args)

    def parse_args(self, args: argparse.Namespace) -> None:
        super().parse_args(args)

        if args.network:
            CryticPrint.print_warning(
                "* Network specified via command line argument, but you are using 'path mode'. "
                "To use fork mode, provide addresses instead of file paths.\n  Ignoring network...\n",
            )
        if args.block:
            CryticPrint.print_warning(
                "* Block specified via command line argument, but you are using 'path mode'. "
                "To use fork mode, provide addresses instead of file paths.\n  Ignoring block...\n",
            )
        if args.network_rpc:
            CryticPrint.print_warning(
                "* RPC specified via command line argument, but you are using 'path mode'. "
                "To use fork mode, provide addresses instead of file paths.\n  Ignoring RPC...\n",
            )

        self._v1_path = args.v1
        self._v2_path = args.v2
        
        if args.proxy is not None:
            CryticPrint.print_information(
                "\n* Proxy contract specified via command line parameter:",
            )
            self._proxy_path = args.proxy
        else:
            self._proxy_path = None

        if args.targets is not None:
            CryticPrint.print_information(
                "\n* Additional targets specified via command line parameter:",
            )
            self._target_paths = args.targets
        else:
            self._target_paths = None

    def analyze_contracts(self) -> None:
        assert(self._v1_path != "" and self._v2_path != "")
        
        self._v1 = get_contract_data_from_path(self._v1_path, self._provider, suffix="V1")
        self._v2 = get_contract_data_from_path(self._v2_path, self._provider, suffix="V2")

        if self._proxy_path:
            self._proxy = get_contract_data_from_path(self._proxy_path, self._provider)
            if not self._proxy["is_proxy"]:
                CryticPrint.print_error(
                    f"\n  * {self._proxy['name']} does not appear to be a proxy. Ignoring...",
                )
                self._proxy = None
        else:
            self._proxy = None
        
        if self._target_paths:
            self._targets = get_contracts_from_comma_separated_paths(
                self._target_paths, self._provider
            )
        else:
            self._targets = None


# pylint: disable=too-many-branches,too-many-statements
def path_mode(args: argparse.Namespace, output_dir: str, version: str):
    """Takes over from diffuzzer.main when args provided are file paths."""

    mode = "deploy"
    provider = FileSlitherProvider()

    if args.network:
        CryticPrint.print(
            PrintMode.WARNING,
            "* Network specified via command line argument, but you are using 'path mode'. "
            "To use fork mode, provide addresses instead of file paths.\n  Ignoring network...\n",
        )
    if args.block:
        CryticPrint.print(
            PrintMode.WARNING,
            "* Block specified via command line argument, but you are using 'path mode'. "
            "To use fork mode, provide addresses instead of file paths.\n  Ignoring block...\n",
        )
    if args.network_rpc:
        CryticPrint.print(
            PrintMode.WARNING,
            "* RPC specified via command line argument, but you are using 'path mode'. "
            "To use fork mode, provide addresses instead of file paths.\n  Ignoring RPC...\n",
        )

    CryticPrint.print(PrintMode.INFORMATION, "* Inspecting V1 and V2 contracts:")
    v1_contract_data = get_contract_data_from_path(args.v1, provider, suffix="V1")
    v2_contract_data = get_contract_data_from_path(args.v2, provider, suffix="V2")

    if args.proxy is not None:
        CryticPrint.print(
            PrintMode.INFORMATION,
            "\n* Proxy contract specified via command line parameter:",
        )
        proxy = get_contract_data_from_path(args.proxy, provider)
        if not proxy["is_proxy"]:
            CryticPrint.print(
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
            CryticPrint.print(
                PrintMode.WARNING,
                "  * Upgrade during fuzz sequence specified via command line parameter,"
                " but no proxy was specified. Ignoring...",
            )
            upgrade = False
    else:
        upgrade = False

    if args.targets is not None:
        CryticPrint.print(
            PrintMode.INFORMATION,
            "\n* Additional targets specified via command line parameter:",
        )
        targets = get_contracts_from_comma_separated_paths(args.targets, provider)
    else:
        targets = None

    contract = generate_test_contract(
        v1_contract_data,
        v2_contract_data,
        mode,
        version,
        targets=targets,
        proxy=proxy,
        upgrade=upgrade,
        protected=bool(args.include_protected),
    )
    write_to_file(f"{output_dir}DiffFuzzUpgrades.sol", contract)
    CryticPrint.print(
        PrintMode.SUCCESS,
        f"  * Fuzzing contract generated and written to {output_dir}DiffFuzzUpgrades.sol.",
    )
