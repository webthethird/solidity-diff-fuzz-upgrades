#!/usr/bin/env python3

import argparse
import os
from eth_utils import is_address
from diffuzzer.utils.crytic_print import PrintMode, CryticPrint
from diffuzzer.utils.slither_provider import NetworkSlitherProvider
from diffuzzer.utils.network_info_provider import NetworkInfoProvider
from diffuzzer.utils.helpers import write_to_file
from diffuzzer.core.code_generation import generate_test_contract, generate_config_file
from diffuzzer.utils.from_address import (
    get_contracts_from_comma_separated_string,
    get_contract_data_from_address,
)


SUPPORTED_NETWORKS = [
    "mainet",
    "optim",
    "ropsten",
    "kovan",
    "rinkeby",
    "goerli",
    "tobalaba",
    "bsc",
    "testnet.bsc",
    "arbi",
    "testnet.arbi",
    "poly",
    "mumbai",
    "avax",
    "testnet.avax",
    "ftm",
]
WEB3_RPC_ENV_VARS = ["WEB3_PROVIDER_URI", "ECHIDNA_RPC_URL", "RPC_URL"]
SUPPORTED_BLOCK_EXPLORER_ENV_VARS = {
    "mainet": "ETHERSCAN_API_KEY",
    "optim": "OPTIMISTIC_ETHERSCAN_API_KEY",
    "bsc": "BSCSCAN_API_KEY",
    "arbi": "ARBISCAN_API_KEY",
    "poly": "POLYGONSCAN_API_KEY",
    "avax": "SNOWTRACE_API_KEY",
    "ftm": "FTMSCAN_API_KEY",
}
SUPPORTED_RPC_ENV_VARS = {
    "mainet": "ECHIDNA_RPC_URL_MAINNET",
    "optim": "ECHIDNA_RPC_URL_OPTIMISM",
    "ropsten": "ECHIDNA_RPC_URL_ROPSTEN",
    "kovan": "ECHIDNA_RPC_URL_KOVAN",
    "rinkeby": "ECHIDNA_RPC_URL_RINKEBY",
    "goerli": "ECHIDNA_RPC_URL_GOERLI",
    "tobalaba": "ECHIDNA_RPC_URL_TOBALABA",
    "bsc": "ECHIDNA_RPC_URL_BSC",
    "testnet.bsc": "ECHIDNA_RPC_URL_BSC_TESTNET",
    "arbi": "ECHIDNA_RPC_URL_ARBI",
    "testnet.arbi": "ECHIDNA_RPC_URL_ARBI_TESTNET",
    "poly": "ECHIDNA_RPC_URL_POLY",
    "mumbai": "ECHIDNA_RPC_URL_MUMBAI",
    "avax": "ECHIDNA_RPC_URL_AVAX",
    "testnet.avax": "ECHIDNA_RPC_URL_AVAX_TESTNET",
    "ftm": "ECHIDNA_RPC_URL_FTM",
}


def fork_mode(args: argparse.Namespace):
    mode = "fork"
    provider: NetworkSlitherProvider

    if args.output_dir is not None:
        output_dir = args.output_dir
        if not str(output_dir).endswith(os.path.sep):
            output_dir += os.path.sep
    else:
        output_dir = "./"

    # Add prefix for current network and create the SlitherProvider
    if args.network in SUPPORTED_NETWORKS or args.network == "mainnet":
        if args.network == "mainnet":
            prefix = "mainet:"
            provider = NetworkSlitherProvider(prefix, os.environ["ETHERSCAN_API_KEY"])
        else:
            prefix = f"{args.network}:"
            if SUPPORTED_BLOCK_EXPLORER_ENV_VARS[args.network] in os.environ:
                provider = NetworkSlitherProvider(
                    prefix, os.environ[SUPPORTED_BLOCK_EXPLORER_ENV_VARS[args.network]]
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
        for env_var in WEB3_RPC_ENV_VARS:
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
                f"\n  * When using fork mode, the proxy must be specified as an address. Ignoring...",
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
                "  * Upgrade during fuzz sequence specified via command line parameter, but no proxy was specified. Ignoring...",
            )
            upgrade = False
    else:
        upgrade = False

    tokens = []
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

    if args.deploy:
        CryticPrint.print(
            PrintMode.WARNING,
            "* Deploy mode flag specified, but you are using fork mode. The contracts are already deployed! Ignoring...",
        )
    deploy = False

    if args.seq_len:
        if str(args.seq_len).isnumeric():
            seq_len = int(args.seq_len)
        else:
            CryticPrint.print(
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

    if args.include_protected:
        protected = True
    else:
        protected = False

    if args.contract_addr:
        contract_addr = args.contract_addr
        CryticPrint.print(
            PrintMode.INFORMATION,
            f"\n* Exploit contract address specified via command line parameter: "
            f"{contract_addr}",
        )
    else:
        contract_addr = ""

    contract = generate_test_contract(
        v1_contract_data,
        v2_contract_data,
        mode,
        version,
        targets=targets,
        proxy=proxy,
        upgrade=upgrade,
        protected=protected,
    )
    write_to_file(f"{output_dir}DiffFuzzUpgrades.sol", contract)
    CryticPrint.print(
        PrintMode.SUCCESS,
        f"  * Fuzzing contract generated and written to {output_dir}DiffFuzzUpgrades.sol.",
    )

    config_file = generate_config_file(
        f"{output_dir}corpus", "1000000000000", contract_addr, seq_len
    )
    write_to_file(f"{output_dir}CryticConfig.yaml", config_file)
    CryticPrint.print(
        PrintMode.SUCCESS,
        f"  * Echidna configuration file generated and written to {output_dir}CryticConfig.yaml.",
    )

    CryticPrint.print(
        PrintMode.MESSAGE,
        f"\n-----------------------------------------------------------",
    )
    CryticPrint.print(
        PrintMode.MESSAGE,
        f"My work here is done. Thanks for using me, have a nice day!",
    )
    CryticPrint.print(
        PrintMode.MESSAGE,
        f"-----------------------------------------------------------",
    )
