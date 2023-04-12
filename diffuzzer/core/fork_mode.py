#!/usr/bin/env python3

"""Main module for fork mode."""

import argparse
import os
from eth_utils import is_address
from diffuzzer.utils.crytic_print import PrintMode, CryticPrint
from diffuzzer.utils.slither_provider import NetworkSlitherProvider
from diffuzzer.utils.network_info_provider import NetworkInfoProvider
from diffuzzer.utils.helpers import write_to_file
import diffuzzer.utils.network_vars as net_vars
from diffuzzer.utils.from_address import (
    get_contracts_from_comma_separated_string,
    get_contract_data_from_address,
)
from diffuzzer.core.code_generation import generate_test_contract



# pylint: disable=too-many-locals,too-many-branches,too-many-statements
def fork_mode(args: argparse.Namespace, output_dir: str, version: str):
    """Takes over from diffuzzer.main when args provided are addresses."""

    provider: NetworkSlitherProvider

    # Add prefix for current network and create the SlitherProvider
    if args.network in net_vars.SUPPORTED_NETWORKS or args.network == "mainnet":
        if args.network == "mainnet":
            prefix = "mainet:"
            provider = NetworkSlitherProvider(prefix, os.environ["ETHERSCAN_API_KEY"])
        else:
            prefix = f"{args.network}:"
            if net_vars.SUPPORTED_BLOCK_EXPLORER_ENV_VARS[args.network] in os.environ:
                provider = NetworkSlitherProvider(
                    prefix, os.environ[net_vars.SUPPORTED_BLOCK_EXPLORER_ENV_VARS[args.network]]
                )
            else:
                provider = NetworkSlitherProvider(
                    prefix, os.environ["ETHERSCAN_API_KEY"]
                )
        CryticPrint.print(
            PrintMode.INFORMATION,
            f"* Network specified via command line parameter: {args.network}",
        )
    else:
        CryticPrint.print(
            PrintMode.WARNING,
            f"* Network {args.network} not supported. Defaulting to Ethereum main network.",
        )
        prefix = "mainet:"
        provider = NetworkSlitherProvider(prefix, os.environ["ETHERSCAN_API_KEY"])

    # Try to get the network RPC endpoint
    network_rpc = ""
    if args.network_rpc:
        network_rpc = args.network_rpc
        CryticPrint.print(
            PrintMode.INFORMATION,
            f"* RPC specified via command line parameter: {network_rpc}",
        )
    else:
        for env_var in net_vars.WEB3_RPC_ENV_VARS:
            if env_var in os.environ:
                network_rpc = os.environ[env_var]
                CryticPrint.print(
                    PrintMode.INFORMATION,
                    f"* RPC specified via {env_var} environment variable: {network_rpc}",
                )
                break

    if network_rpc == "":
        CryticPrint.print_error(
            "* RPC not provided, I can't fetch information from the network."
        )
        raise ValueError("No RPC provided")

    # Workaround for PoA networks
    is_poa = False
    if prefix in ["bsc:", "poly:", "rinkeby:"]:
        is_poa = True

    # Get block number
    if args.block:
        blocknumber = int(args.block)
        CryticPrint.print(
            PrintMode.INFORMATION,
            f"* Block number specified via command line parameter: {blocknumber}",
        )
    elif "ECHIDNA_RPC_BLOCK" in os.environ:
        blocknumber = int(os.environ["ECHIDNA_RPC_BLOCK"])
        CryticPrint.print(
            PrintMode.INFORMATION,
            f"* Block number specified via ECHIDNA_RPC_BLOCK environment variable: {blocknumber}",
        )

    net_info = NetworkInfoProvider(network_rpc, blocknumber, is_poa)

    CryticPrint.print(PrintMode.INFORMATION, "* Inspecting V1 and V2 contracts:")
    v1_contract_data = get_contract_data_from_address(
        args.v1, "", provider, net_info, suffix="V1"
    )
    v2_contract_data = get_contract_data_from_address(
        args.v2, "", provider, net_info, suffix="V2"
    )

    if args.proxy is not None:
        CryticPrint.print(
            PrintMode.INFORMATION,
            "\n* Proxy contract specified via command line parameter:",
        )
        if is_address(args.proxy):
            proxy = get_contract_data_from_address(args.proxy, "", provider, net_info)
            if not proxy["is_proxy"]:
                CryticPrint.print(
                    PrintMode.ERROR,
                    f"\n  * {proxy['name']} does not appear to be a proxy. Ignoring...",
                )
                proxy = None
        else:
            CryticPrint.print(
                PrintMode.ERROR,
                "\n  * When using fork mode, the proxy must be specified as an address.",
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
                "  * Upgrade during fuzz sequence specified via command line parameter, "
                "but no proxy was specified. Ignoring...",
            )
            upgrade = False
    else:
        upgrade = False

    targets = []

    if args.targets is not None:
        CryticPrint.print(
            PrintMode.INFORMATION,
            "\n* Additional targets specified via command line parameter:",
        )
        targets, _, _ = get_contracts_from_comma_separated_string(
            args.targets, provider, net_info
        )
    else:
        targets = None

    contract = generate_test_contract(
        v1_contract_data,
        v2_contract_data,
        "fork",
        version,
        targets=targets,
        proxy=proxy,
        upgrade=upgrade,
        protected=bool(args.include_protected),
        network_info=net_info
    )
    write_to_file(f"{output_dir}DiffFuzzUpgrades.sol", contract)
    CryticPrint.print(
        PrintMode.SUCCESS,
        f"  * Fuzzing contract generated and written to {output_dir}DiffFuzzUpgrades.sol.",
    )
