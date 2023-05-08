#!/usr/bin/env python3

"""Main module for fork mode."""

import argparse
import os
from typing import Optional, List
from eth_utils import is_address
from diffusc.utils.classes import ContractData
from diffusc.utils.helpers import do_diff
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
    _tokens: List[ContractData]
    _token_holders: Optional[List[str]]

    def __init__(self, args: argparse.Namespace) -> None:
        self._mode = "fork"
        super().__init__(args)
        self._provider = NetworkSlitherProvider(self._prefix, self._api_key)
        self._net_info = NetworkInfoProvider(self._network_rpc, self._block_number, self._is_poa)
        self._tokens = []

    @property
    def network_rpc(self) -> str:
        return self._network_rpc

    @property
    def block_number(self) -> int:
        return self._block_number

    @property
    def tokens(self) -> List[ContractData]:
        return self._tokens

    @property
    def token_holders(self) -> Optional[List[str]]:
        return self._token_holders

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
            CryticPrint.print_information(
                f"* Block number specified via command line parameter: {self._block_number}",
            )
        elif "ECHIDNA_RPC_BLOCK" in os.environ:
            self._block_number = int(os.environ["ECHIDNA_RPC_BLOCK"])
            CryticPrint.print_information(
                "* Block number specified via ECHIDNA_RPC_BLOCK environment variable: "
                f"{self._block_number}",
            )

        self._token_holders = None
        if args.holders:
            self._token_holders = []

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
            CryticPrint.print_information(
                f"* Network specified via command line parameter: {args.network}",
            )
        else:
            CryticPrint.print_warning(
                f"* Network {args.network} not supported. Defaulting to Ethereum main network.",
            )
            self._prefix = "mainet:"
            self._api_env_var = "ETHERSCAN_API_KEY"

        self._api_key = ""
        if self._api_env_var in os.environ:
            self._api_key = os.environ[self._api_env_var]
        elif args.etherscan_key:
            self._api_key = args.etherscan_key

        # Try to get the network RPC endpoint
        self._network_rpc = ""
        if args.network_rpc:
            self._network_rpc = args.network_rpc
            CryticPrint.print_information(
                f"* RPC specified via command line parameter: {self._network_rpc}",
            )
        else:
            for env_var in net_vars.WEB3_RPC_ENV_VARS:
                if env_var in os.environ:
                    self._network_rpc = os.environ[env_var]
                    CryticPrint.print_information(
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
            CryticPrint.print_information(
                "\n* Proxy contract specified via command line parameter:",
            )
            if is_address(self._proxy_address):
                self._proxy = get_contract_data_from_address(
                    self._proxy_address, "", self._provider, self._net_info
                )
                if not self._proxy["valid_data"]:
                    CryticPrint.print_error(
                        f"\n  * Failed to get proxy at {self._proxy['address']}. Ignoring...",
                    )
                    self._proxy = None
                elif not self._proxy["is_proxy"]:
                    CryticPrint.print_error(
                        f"\n  * {self._proxy['name']} does not appear to be a proxy. Ignoring...",
                    )
                    self._proxy = None
            else:
                CryticPrint.print_error(
                    "\n  * When using fork mode, the proxy must be specified as an address.",
                )
                self._proxy = None
        else:
            self._proxy = None

        if self._target_addresses is not None:
            CryticPrint.print_information(
                "\n* Additional targets specified via command line parameter:",
            )
            self._targets, _, _ = get_contracts_from_comma_separated_string(
                self._target_addresses, self._provider, self._net_info
            )
        else:
            self._targets = None

        if not self._diff:
            self._diff = do_diff(self._v1, self._v2, self._targets)

        self.analyze_tokens()

    def analyze_tokens(self) -> None:
        if self._v1["is_erc20"] and self._v2["is_erc20"]:
            if self._proxy is not None:
                self._tokens.append(self._proxy)
                contract = self._proxy["contract_object"]
                slither = self._proxy["slither"]
                abi = contract.file_scope.abi(
                    slither.compilation_units[0].crytic_compile_compilation_unit, contract.name
                )
                if self._token_holders is not None:
                    self._token_holders.extend(
                        self._net_info.get_token_holders(10000, 5, self._proxy["address"], abi)
                    )
            else:
                self._tokens.extend([self._v1, self._v2])
                contract = self._v1["contract_object"]
                slither = self._v1["slither"]
                abi = contract.file_scope.abi(
                    slither.compilation_units[0].crytic_compile_compilation_unit, contract.name
                )
                if self._token_holders is not None:
                    self._token_holders.extend(
                        self._net_info.get_token_holders(10000, 5, self._v1["address"], abi)
                    )
        if self._targets is not None:
            for target in self._targets:
                if target["is_erc20"]:
                    self._tokens.append(target)
                    contract = target["contract_object"]
                    slither = target["slither"]
                    abi = contract.file_scope.abi(
                        slither.compilation_units[0].crytic_compile_compilation_unit, contract.name
                    )
                    if self._token_holders is not None:
                        self._token_holders.extend(
                            self._net_info.get_token_holders(10000, 5, target["address"], abi)
                        )
        for token in self._tokens:
            CryticPrint.print_information(
                f"  * Found token {token['name']} at address {token['address']}"
            )

    # def recursive_search(self) -> None:
    #
    #     all_data = []
    #     all_data.extend(self._tokens)
    #     different = [t for t in self._targets if t not in self._tokens]
    #     all_data.extend(different)
    #
    #     address_list: list[str]=[]
    #     address_list = [t["address"] for t in all_data if t["address"] not in address_list]
    #
    #     possible: list[AddressData]=[]
    #     recursive_finds: list[AddressData]=[]
    #
    #     CryticPrint.print_information(f"  * Starting recursive search from {', '.join(address_list)}")
    #
    #     for t in all_data:
    #         current = self._find_possible_contracts(t)
    #         current = [to_checksum_address(t) for t in current]
    #         possible.extend(current)
    #
    #     for p in possible:
    #         if not p in address_list:
    #             address_list.append(p)
    #             d = get_contract_data_from_address(p, "", self._provider, self._net_info)
    #             if d["valid_data"]:
    #                 recursive_finds.append(d)
    #             else:
    #                 CryticPrint.print_error(f"    * Contract at {p} has no source code.")
    #
    #     for r in recursive_finds:
    #         if r["is_erc20"]:
    #             self._tokens.append(r)
    #             CryticPrint.print_success(f"    * Recursive search found token {r['name']} at {r['address']}.")
    #         else:
    #             self._targets.append(r)
    #             CryticPrint.print_success(f"    * Recursive search found target {r['name']} at {r['address']}.")
    #
    #     if len(recursive_finds) == 0:
    #         CryticPrint.print_warning(f"    * Couldn't find any references.")
