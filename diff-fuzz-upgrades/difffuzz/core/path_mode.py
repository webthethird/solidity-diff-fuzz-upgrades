#!/usr/bin/env python3

import argparse
import os
from typing import List

from difffuzz.utils.printer import PrintMode, crytic_print
from difffuzz.utils.helpers import (
    write_to_file
)
from difffuzz.core.code_generation import (
    generate_test_contract,
    generate_config_file
)
from difffuzz.utils.from_path import (
    get_contracts_from_comma_separated_paths,
    get_contract_data_from_path
)


def path_mode(args: argparse.Namespace):
    mode = "deploy"

    if args.output_dir is not None:
        output_dir = args.output_dir
        if not str(output_dir).endswith(os.path.sep):
            output_dir += os.path.sep
    else:
        output_dir = "./"

    if args.network:
        crytic_print(PrintMode.WARNING, "* Network specified via command line argument, but you are using 'path mode'. "
                                        "To use fork mode, provide addresses instead of file paths.\n  Ignoring network...\n")
    if args.block:
        crytic_print(PrintMode.WARNING, "* Block specified via command line argument, but you are using 'path mode'. "
                                        "To use fork mode, provide addresses instead of file paths.\n  Ignoring block...\n")
    if args.network_rpc:
        crytic_print(PrintMode.WARNING, "* RPC specified via command line argument, but you are using 'path mode'. "
                                        "To use fork mode, provide addresses instead of file paths.\n  Ignoring RPC...\n")

    crytic_print(PrintMode.INFORMATION, "* Inspecting V1 and V2 contracts:")
    v1_contract_data = get_contract_data_from_path(args.v1, suffix="V1")
    v2_contract_data = get_contract_data_from_path(args.v2, suffix="V2")

    if args.proxy is not None:
        crytic_print(
            PrintMode.INFORMATION,
            "\n* Proxy contract specified via command line parameter:",
        )
        proxy = get_contract_data_from_path(args.proxy)
        if not proxy["is_proxy"]:
            crytic_print(
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
            crytic_print(
                PrintMode.WARNING, 
                "  * Upgrade during fuzz sequence specified via command line parameter, but no proxy was specified. Ignoring..."
            )
            upgrade = False
    else:
        upgrade = False

    if args.targets is not None:
        crytic_print(
            PrintMode.INFORMATION,
            "\n* Additional targets specified via command line parameter:",
        )
        targets = get_contracts_from_comma_separated_paths(args.targets)
    else:
        targets = None

    if args.deploy:
        deploy = True
    else:
        deploy = False

    if args.seq_len:
        if str(args.seq_len).isnumeric():
            seq_len = int(args.seq_len)
        else:
            crytic_print(
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
        crytic_print(
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
        protected=protected
    )
    write_to_file(f"{output_dir}DiffFuzzUpgrades.sol", contract)
    crytic_print(
        PrintMode.SUCCESS,
        f"  * Fuzzing contract generated and written to {output_dir}DiffFuzzUpgrades.sol.",
    )

    config_file = generate_config_file(
        f"{output_dir}corpus", "1000000000000", contract_addr, seq_len
    )
    write_to_file(f"{output_dir}CryticConfig.yaml", config_file)
    crytic_print(
        PrintMode.SUCCESS,
        f"  * Echidna configuration file generated and written to {output_dir}CryticConfig.yaml.",
    )

    crytic_print(
        PrintMode.MESSAGE,
        f"\n-----------------------------------------------------------",
    )
    crytic_print(
        PrintMode.MESSAGE,
        f"My work here is done. Thanks for using me, have a nice day!",
    )
    crytic_print(
        PrintMode.MESSAGE,
        f"-----------------------------------------------------------",
    )
