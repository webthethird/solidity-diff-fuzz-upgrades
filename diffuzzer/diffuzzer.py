#!/usr/bin/env python3

"""Main module"""

import argparse
import logging
import os

from eth_utils import is_address
from diffuzzer.core.path_mode import PathMode
from diffuzzer.core.fork_mode import ForkMode
from diffuzzer.core.analysis_mode import AnalysisMode
from diffuzzer.core.code_generation import generate_config_file
from diffuzzer.utils.helpers import write_to_file
from diffuzzer.utils.crytic_print import PrintMode, CryticPrint
import diffuzzer.utils.network_vars as net_vars


# pylint: disable=line-too-long,too-many-statements
def main():
    """Main method, parses arguments and calls path_mode or fork_mode."""
    # Read command line arguments

    parser = argparse.ArgumentParser(
        prog="diff-fuzz-upgrades",
        description="Generate differential fuzz testing contract for comparing two upgradeable contract versions.",
    )

    parser.add_argument("v1", help="The original version of the contract.")
    parser.add_argument("v2", help="The upgraded version of the contract.")
    parser.add_argument(
        "-p", "--proxy", dest="proxy", help="Specifies the proxy contract to use."
    )
    parser.add_argument(
        "-T",
        "--targets",
        dest="targets",
        help="Specifies the additional contracts to target.",
    )
    parser.add_argument(
        "-d",
        "--output-dir",
        dest="output_dir",
        help="Specifies the directory where the generated test contract and config file are saved.",
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
        help="Specifies whether to upgrade the proxy to the V2 during fuzzing (default is False). Requires a proxy.",
    )

    parser.add_argument(
        "-l",
        "--seq-length",
        dest="seq_len",
        help="Specifies the sequence length to use with Slither. Default is 100.",
    )
    parser.add_argument(
        "-n",
        "--network",
        dest="network",
        help="Specifies the network where the contracts are deployed. Valid values: "
        + ", ".join(net_vars.SUPPORTED_NETWORKS),
    )
    parser.add_argument(
        "-b",
        "--block",
        dest="block",
        help="Specifies the block number to fetch the contracts from. If not specified and RPC is available, latest block will be used.",
    )
    parser.add_argument(
        "-R",
        "--rpc",
        dest="network_rpc",
        help="Specifies network RPC endpoint for reading operations.",
    )
    parser.add_argument(
        "--protected",
        dest="include_protected",
        action="store_true",
        help="Specifies whether to include wrappers for protected functions.",
    )
    parser.add_argument(
        "--etherscan-key",
        dest="etherscan_key",
        help="Specifies the API key to use with Etherscan.",
    )

    args = parser.parse_args()

    CryticPrint.initialize()
    CryticPrint.print(
        PrintMode.MESSAGE, "\nWelcome to diff-fuzz-upgrades, enjoy your stay!"
    )
    CryticPrint.print(
        PrintMode.MESSAGE, "===============================================\n"
    )

    # Silence Slither Read Storage
    logging.getLogger("Slither-read-storage").setLevel(logging.CRITICAL)

    output_dir = "./"
    if args.output_dir is not None:
        output_dir = args.output_dir
        if not str(output_dir).endswith(os.path.sep):
            output_dir += os.path.sep

    seq_len = 100
    if args.seq_len:
        if str(args.seq_len).isnumeric():
            seq_len = int(args.seq_len)
        else:
            CryticPrint.print_error(
                "\n* Sequence length provided is not numeric. Defaulting to 100.",
            )

    contract_addr = ""
    if args.contract_addr and is_address(args.contract_addr):
        contract_addr = args.contract_addr
        CryticPrint.print_information(
            "\n* Exploit contract address specified via command line parameter: "
            f"{contract_addr}",
        )

    # Start the analysis
    analysis: AnalysisMode
    CryticPrint.print(PrintMode.INFORMATION, "* Inspecting V1 and V2 contracts:")
    if is_address(args.v1) and is_address(args.v2):
        CryticPrint.print(PrintMode.INFORMATION, "* Using 'fork mode':")
        analysis = ForkMode(args)
        contract = analysis.write_test_contract()
    elif os.path.exists(args.v1) and os.path.exists(args.v2):
        CryticPrint.print(PrintMode.INFORMATION, "* Using 'path mode' (no fork):")
        analysis = PathMode(args)
        contract = analysis.write_test_contract()
    elif not os.path.exists(args.v1):
        CryticPrint.print(PrintMode.ERROR, f"\nFile not found: {args.v1}")
        raise FileNotFoundError(args.v1)
    else:
        CryticPrint.print(PrintMode.ERROR, f"\nFile not found: {args.v2}")
        raise FileNotFoundError(args.v2)

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
        "\n-----------------------------------------------------------",
    )
    CryticPrint.print(
        PrintMode.MESSAGE,
        "My work here is done. Thanks for using me, have a nice day!",
    )
    CryticPrint.print(
        PrintMode.MESSAGE,
        "-----------------------------------------------------------",
    )


if __name__ == "__main__":
    main()
