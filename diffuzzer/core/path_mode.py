#!/usr/bin/env python3

"""Main module for path mode."""

import argparse
from typing import Optional

from diffuzzer.utils.crytic_print import CryticPrint
from diffuzzer.utils.from_path import (
    get_contracts_from_comma_separated_paths,
    get_contract_data_from_path,
)
from diffuzzer.utils.slither_provider import FileSlitherProvider
from diffuzzer.core.analysis_mode import AnalysisMode


# pylint: disable=too-many-instance-attributes
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
        """Parse arguments for path mode."""
        super().parse_args(args)

        if args.network:
            CryticPrint.print_warning(
                "* Network specified via command line argument, but you are using 'path mode'. To"
                " use fork mode, provide addresses instead of file paths.\n  Ignoring network...\n",
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
        """Get ContractData objects from the file paths provided."""
        assert self._v1_path != "" and self._v2_path != ""
        assert isinstance(self._provider, FileSlitherProvider)

        self._v1 = get_contract_data_from_path(
            self._v1_path, self._provider, suffix="V1"
        )
        self._v2 = get_contract_data_from_path(
            self._v2_path, self._provider, suffix="V2"
        )

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
