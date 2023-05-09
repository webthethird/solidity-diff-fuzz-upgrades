#!/usr/bin/env python3

"""Main module"""

import argparse
import logging
import os

from eth_utils import is_address
from diffusc.core.path_mode import PathMode
from diffusc.core.fork_mode import ForkMode
from diffusc.core.analysis_mode import AnalysisMode
from diffusc.core.code_generation import CodeGenerator
from diffusc.utils.helpers import write_to_file
from diffusc.utils.crytic_print import CryticPrint
import diffusc.utils.network_vars as net_vars


# pylint: disable=too-many-statements
def main() -> None:
    """Main method, parses arguments and calls path_mode or fork_mode."""
    # Read command line arguments

    parser = argparse.ArgumentParser(
        prog="diffusc",
        description="Generate differential fuzz testing contract for comparing two upgradeable contract versions.",
    )

    parser.add_argument("v1", help="The original version of the contract.")
    parser.add_argument(
        "v2",
        nargs="?",
        default="",
        help="The upgraded version of the contract."
    )
    parser.add_argument("-p", "--proxy", dest="proxy", help="Specifies the proxy contract to use.")
    parser.add_argument(
        "-t",
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
        "-L",
        "--campaign-length",
        dest="campaign_len",
        help="Specifies the campaign length to use with Echidna. Default is 1000000000000.",
    )
    parser.add_argument(
        "-l",
        "--seq-length",
        dest="seq_len",
        help="Specifies the sequence length to use with Echidna. Default is 100.",
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
        "-T",
        "--token-holders",
        dest="holders",
        action="store_true",
        help="Specifies whether to automatically detect token holders to send transactions from when fuzzing "
        "(default false).",
    )
    parser.add_argument(
        "-P",
        "--protected",
        dest="include_protected",
        action="store_true",
        help="Specifies whether to include wrappers for protected functions (default false).",
    )
    parser.add_argument(
        "-K",
        "--etherscan-key",
        dest="etherscan_key",
        help="Specifies the API key to use with Etherscan.",
    )
    parser.add_argument(
        "-r",
        "--run",
        dest="run_mode",
        action="store_true",
        help="Specifies whether to run Echidna on the generated test contract (default false)."
    )
    parser.add_argument(
        "-M",
        "--mutation",
        dest="mutation",
        action="store_true",
        help="Specifies whether to create a V2 contract by mutating V1 (default false). If not set, V2 must be given."
    )

    args = parser.parse_args()

    CryticPrint.initialize()
    CryticPrint.print_message("\nWelcome to diff-fuzz-upgrades, enjoy your stay!")
    CryticPrint.print_message("===============================================\n")

    # Silence Slither Read Storage
    logging.getLogger("Slither-read-storage").setLevel(logging.CRITICAL)

    if args.v2 == "" and not args.mutation:
        CryticPrint.print_error(
            "Error: V2 must be specified unless using mutation mode (`-M` flag).",
        )
        exit(1)

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

    test_len = 1000000000000
    if args.campaign_len:
        if str(args.campaign_len).isnumeric():
            test_len = int(args.campaign_len)
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
    CryticPrint.print_information("* Inspecting V1 and V2 contracts:")
    if is_address(args.v1) and is_address(args.v2):
        CryticPrint.print_information("* Using 'fork mode':")
        analysis = ForkMode(args)
        contract = analysis.write_test_contract()
    elif os.path.exists(args.v1) and os.path.exists(args.v2):
        CryticPrint.print_information("* Using 'path mode' (no fork):")
        analysis = PathMode(args)
        contract = analysis.write_test_contract()
    elif not os.path.exists(args.v1):
        CryticPrint.print_error(f"\nFile not found: {args.v1}")
        raise FileNotFoundError(args.v1)
    else:
        CryticPrint.print_error(f"\nFile not found: {args.v2}")
        raise FileNotFoundError(args.v2)

    write_to_file(f"{output_dir}DiffFuzzUpgrades.sol", contract)
    CryticPrint.print_success(
        f"  * Fuzzing contract generated and written to {output_dir}DiffFuzzUpgrades.sol.",
    )

    if isinstance(analysis, ForkMode):
        holders = analysis.token_holders
        config_file = CodeGenerator.generate_config_file(
            f"{output_dir}corpus",
            test_len,
            contract_addr,
            seq_len,
            block=analysis.block_number,
            rpc_url=analysis.network_rpc,
            senders=holders,
        )
    else:
        config_file = CodeGenerator.generate_config_file(
            f"{output_dir}corpus", test_len, contract_addr, seq_len
        )
    write_to_file(f"{output_dir}CryticConfig.yaml", config_file)
    CryticPrint.print_success(
        f"  * Echidna configuration file generated and written to {output_dir}CryticConfig.yaml.",
    )

    CryticPrint.print_message(
        "\n-----------------------------------------------------------",
    )
    CryticPrint.print_message(
        "My work here is done. Thanks for using me, have a nice day!",
    )
    CryticPrint.print_message(
        "-----------------------------------------------------------",
    )


if __name__ == "__main__":
    main()
