#!/usr/bin/env python3

"""Main module for fork mode."""

import argparse
import os
from typing import Optional
from eth_utils import is_address
from diffusc.utils.crytic_print import PrintMode, CryticPrint
from diffusc.utils.slither_provider import NetworkSlitherProvider
from diffusc.utils.network_info_provider import NetworkInfoProvider
import diffusc.utils.network_vars as net_vars
from diffusc.utils.from_address import (
    get_contracts_from_comma_separated_string,
    get_contract_data_from_address,
)
from diffusc.core.analysis_mode import AnalysisMode

# pylint: disable=too-many-instance-attributes
class ForkMode(AnalysisMode):
    """Class for handling targets provided as addresses."""

    _v1_address: str
    _v2_address: str
    _proxy_address: Optional[str]
    _target_addresses: Optional[str]
    _api_env_var: str
    _api_key: str
    _prefix: str
    _network_rpc: str
    _is_poa: bool
    _block_number: int

    def __init__(self, args: argparse.Namespace) -> None:
        self._mode = "fork"
        super().__init__(args)
        self._provider = NetworkSlitherProvider(self._prefix, self._api_key)
        self._net_info = NetworkInfoProvider(self._network_rpc, self._block_number, self._is_poa)

    def parse_args(self, args: argparse.Namespace) -> None:
        """Parse arguments for fork mode."""
        super().parse_args(args)

        self._v1_address = args.v1
        self._v2_address = args.v2

        self._proxy_address = None
        if args.proxy is not None:
            CryticPrint.print_information(
                "\n* Proxy contract specified via command line parameter:",
            )
            self._proxy_address = args.proxy

        self._target_addresses = None
        if args.targets is not None:
            CryticPrint.print_information(
                "\n* Additional targets specified via command line parameter:",
            )
            self._target_addresses = args.targets

        self.parse_network_args(args)

        if self._network_rpc is None or self._network_rpc == "":
            CryticPrint.print_error(
                "* RPC not provided, I can't fetch information from the network."
            )
            raise ValueError("No RPC provided")
        if self._api_key is None or self._api_key == "":
            CryticPrint.print_error(
                "* Error: Block explorer API key not found. Either specify a key using the "
                f"--etherscan-key flag or set it with the {self._api_env_var} environment variable."
            )
            raise ValueError("No block explorer API key provided")

        # Workaround for PoA networks
        self._is_poa = False
        if self._prefix in ["bsc:", "poly:", "rinkeby:"]:
            self._is_poa = True

        # Get block number
        if args.block:
            self._block_number = int(args.block)
            CryticPrint.print(
                PrintMode.INFORMATION,
                f"* Block number specified via command line parameter: {self._block_number}",
            )
        elif "ECHIDNA_RPC_BLOCK" in os.environ:
            self._block_number = int(os.environ["ECHIDNA_RPC_BLOCK"])
            CryticPrint.print(
                PrintMode.INFORMATION,
                "* Block number specified via ECHIDNA_RPC_BLOCK environment variable: "
                f"{self._block_number}",
            )

    def parse_network_args(self, args: argparse.Namespace):
        """Parse arguments related to network info."""
        # Get prefix for current network and Etherscan API key
        if args.network in net_vars.SUPPORTED_NETWORKS or args.network == "mainnet":
            if args.network == "mainnet":
                self._prefix = "mainet:"
                self._api_env_var = "ETHERSCAN_API_KEY"
            else:
                self._prefix = f"{args.network}:"
                if net_vars.SUPPORTED_BLOCK_EXPLORER_ENV_VARS[args.network] in os.environ:
                    self._api_env_var = net_vars.SUPPORTED_BLOCK_EXPLORER_ENV_VARS[args.network]
                else:
                    self._api_env_var = "ETHERSCAN_API_KEY"
            CryticPrint.print(
                PrintMode.INFORMATION,
                f"* Network specified via command line parameter: {args.network}",
            )
        else:
            CryticPrint.print(
                PrintMode.WARNING,
                f"* Network {args.network} not supported. Defaulting to Ethereum main network.",
            )
            self._prefix = "mainet:"
            self._api_env_var = "ETHERSCAN_API_KEY"

        if self._api_env_var in os.environ:
            self._api_key = os.environ[self._api_env_var]
        elif args.etherscan_key:
            self._api_key = args.etherscan_key

        # Try to get the network RPC endpoint
        if args.network_rpc:
            self._network_rpc = args.network_rpc
            CryticPrint.print(
                PrintMode.INFORMATION,
                f"* RPC specified via command line parameter: {self._network_rpc}",
            )
        else:
            for env_var in net_vars.WEB3_RPC_ENV_VARS:
                if env_var in os.environ:
                    self._network_rpc = os.environ[env_var]
                    CryticPrint.print(
                        PrintMode.INFORMATION,
                        f"* RPC specified via {env_var} environment variable: {self._network_rpc}",
                    )
                    break

    def analyze_contracts(self) -> None:
        """Get ContractData objects from the addresses provided."""
        assert self._v1_address != "" and self._v2_address != ""
        assert isinstance(self._provider, NetworkSlitherProvider)

        self._v1 = get_contract_data_from_address(
            self._v1_address, "", self._provider, self._net_info, suffix="V1"
        )
        self._v2 = get_contract_data_from_address(
            self._v2_address, "", self._provider, self._net_info, suffix="V2"
        )

        if self._proxy_address is not None:
            CryticPrint.print(
                PrintMode.INFORMATION,
                "\n* Proxy contract specified via command line parameter:",
            )
            if is_address(self._proxy_address):
                self._proxy = get_contract_data_from_address(
                    self._proxy_address, "", self._provider, self._net_info
                )
                if not self._proxy["is_proxy"]:
                    CryticPrint.print(
                        PrintMode.ERROR,
                        f"\n  * {self._proxy['name']} does not appear to be a proxy. Ignoring...",
                    )
                    self._proxy = None
            else:
                CryticPrint.print(
                    PrintMode.ERROR,
                    "\n  * When using fork mode, the proxy must be specified as an address.",
                )
                self._proxy = None
        else:
            self._proxy = None

        if self._target_addresses is not None:
            CryticPrint.print(
                PrintMode.INFORMATION,
                "\n* Additional targets specified via command line parameter:",
            )
            self._targets, _, _ = get_contracts_from_comma_separated_string(
                self._target_addresses, self._provider, self._net_info
            )
        else:
            self._targets = None
