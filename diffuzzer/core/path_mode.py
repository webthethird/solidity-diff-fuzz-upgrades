#!/usr/bin/env python3

"""Main module for path mode."""

import argparse
import os

from diffuzzer.utils.crytic_print import PrintMode, CryticPrint
from diffuzzer.utils.helpers import write_to_file
from diffuzzer.core.code_generation import generate_test_contract
from diffuzzer.utils.from_path import (
    get_contracts_from_comma_separated_paths,
    get_contract_data_from_path,
)
from diffuzzer.utils.slither_provider import FileSlitherProvider


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
