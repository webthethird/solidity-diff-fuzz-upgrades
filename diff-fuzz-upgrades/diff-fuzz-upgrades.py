#!/usr/bin/env python3

import argparse
import logging
import os

from eth_utils import is_address
from colorama import init as colorama_init
from difffuzz.utils.printer import PrintMode, crytic_print
from difffuzz.core.deploy_mode import deploy_mode
from difffuzz.core.fork_mode import fork_mode


SUPPORTED_NETWORKS = [ "mainet","optim","ropsten","kovan","rinkeby","goerli","tobalaba","bsc","testnet.bsc","arbi","testnet.arbi","poly","mumbai","avax","testnet.avax","ftm"]


def main():
    # Read command line arguments

    parser = argparse.ArgumentParser(
        prog="diff-fuzz-upgrades",
        description="Generate differential fuzz testing contract for comparing two upgradeable contract versions.",
    )

    parser.add_argument(
        "v1", help="The original version of the contract."
    )
    parser.add_argument(
        "v2", help="The upgraded version of the contract."
    )
    parser.add_argument(
        "-p", "--proxy", dest="proxy", help="Specifies the proxy contract to use."
    )
    parser.add_argument(
        "-t", "--tokens", dest="tokens", help="Specifies the token contracts to use."
    )
    parser.add_argument(
        "-T",
        "--targets",
        dest="targets",
        help="Specifies the additional contracts to target.",
    )
    parser.add_argument(
        "-D",
        "--deploy",
        dest="deploy",
        action="store_true",
        help="Specifies if the test contract deploys the contracts under test in its constructor.",
    )
    parser.add_argument(
        "-d",
        "--output-dir",
        dest="output_dir",
        help="Specifies the directory where the generated test contract and config file are saved."
    )
    parser.add_argument(
        "-A",
        "--contract-addr",
        dest="contract_addr",
        help="Specifies the address to which to deploy the test contract.",
    )
    parser.add_argument(
        "-v",
        "--version",
        dest="version",
        help="Specifies the solc version to use in the test contract (default is 0.8.0).",
    )

    parser.add_argument(
        "-u",
        "--fuzz-upgrade",
        dest="fuzz_upgrade",
        action="store_true",
        help="Specifies whether to upgrade the proxy to the V2 during fuzzing (default is False). Requires a proxy."
    )

    parser.add_argument(
        "-l",
        "--seq-length",
        dest="seq_len",
        help="Specifies the sequence length to use with Slither. Default is 100."
    )
    parser.add_argument(
        '-n', 
        '--network', 
        dest='network', 
        help='Specifies the network where the contracts are deployed. Valid values: ' + ', '.join(SUPPORTED_NETWORKS)
    )
    parser.add_argument(
        '-b', 
        '--block', 
        dest='block', 
        help='Specifies the block number to fetch the contracts from. If not specified and RPC is available, latest block will be used.'
    )
    parser.add_argument(
        '-R', 
        '--rpc', 
        dest='network_rpc', 
        help='Specifies network RPC endpoint for reading operations'
    )


    args = parser.parse_args()

    crytic_print(PrintMode.MESSAGE, "\nWelcome to diff-fuzz-upgrades, enjoy your stay!")
    crytic_print(PrintMode.MESSAGE, "===============================================\n")

    # Silence Slither Read Storage
    logging.getLogger("Slither-read-storage").setLevel(logging.CRITICAL)

    # Initialize colorama
    colorama_init()

    crytic_print(PrintMode.INFORMATION, "* Inspecting V1 and V2 contracts:")
    if is_address(args.v1) and is_address(args.v2):
        crytic_print(PrintMode.ERROR, "\nFork mode coming soon...")
        fork_mode(args)
    if os.path.exists(args.v1) and os.path.exists(args.v2):
        crytic_print(PrintMode.INFORMATION, "* Using 'deployment mode' (no fork):")
        deploy_mode(args)
    elif not os.path.exists(args.v1):
        crytic_print(PrintMode.ERROR, f"\nFile not found: {args.v1}")
        raise FileNotFoundError(args.v1)
    else:
        crytic_print(PrintMode.ERROR, f"\nFile not found: {args.v2}")
        raise FileNotFoundError(args.v2)


if __name__ == "__main__":
    main()
