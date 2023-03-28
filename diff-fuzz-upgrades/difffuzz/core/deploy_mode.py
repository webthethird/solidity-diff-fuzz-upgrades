#!/usr/bin/env python3

import argparse
import os
from typing import List
from solc_select.solc_select import (
    switch_global_version,
    installed_versions,
    get_installable_versions,
)
from slither import Slither
from slither.exceptions import SlitherError
from slither.utils.upgradeability import get_proxy_implementation_slot
from difffuzz.classes import ContractData
from difffuzz.utils.printer import PrintMode, crytic_print
from difffuzz.utils.helpers import (
    get_pragma_version_from_file,
    get_compilation_unit_name,
    write_to_file
)
from difffuzz.core.code_generation import (
    get_contract_interface,
    generate_test_contract,
    generate_config_file
)


def get_contracts_from_comma_separated_paths(paths_string: str, suffix: str = "") -> List[ContractData]:
    contracts = []
    filepaths = paths_string.split(",")

    for path in filepaths:
        contract_data = get_contract_data_from_path(path, suffix)
        contracts.append(contract_data)
    return contracts


def get_contract_data_from_path(filepath: str, suffix: str = "") -> ContractData:
    contract_data = ContractData()

    crytic_print(PrintMode.MESSAGE, f"* Getting contract data from {filepath}")

    contract_data["path"] = filepath
    contract_data["suffix"] = suffix
    version = get_pragma_version_from_file(filepath)
    contract_data["solc_version"] = version
    if version in installed_versions() or version in get_installable_versions():
        switch_global_version(version, True)

    try:
        contract_data["slither"] = get_slither_object_from_path(filepath)
        contract_data["valid_data"] = True
    except:
        contract_data["slither"] = None
        contract_data["valid_data"] = False

    if contract_data["valid_data"]:
        slither_object = contract_data["slither"]
        contract_name = get_compilation_unit_name(slither_object)
        try:
            contract = slither_object.get_contract_from_name(contract_name)[0]
        except IndexError:
            contract = slither_object.get_contract_from_name(contract_name.replace("V1", "").replace("V2", ""))[0]
        contract_data["contract_object"] = contract
        if contract.is_upgradeable_proxy:
            contract_data["is_proxy"] = True
            contract_data["implementation_slot"] = get_proxy_implementation_slot(
                contract
            )
        else:
            contract_data["is_proxy"] = False
        target_info = get_contract_interface(contract_data, suffix)
        contract_data["interface"] = target_info["interface"]
        contract_data["interface_name"] = target_info["interface_name"]
        contract_data["name"] = target_info["name"]
        contract_data["functions"] = target_info["functions"]
        crytic_print(
            PrintMode.MESSAGE, f"  * Done compiling contract {contract_data['name']}"
        )

    return contract_data


def get_slither_object_from_path(filepath: str) -> Slither:
    if not os.path.exists(filepath):
        raise ValueError("File path does not exist!")
    try:
        crytic_print(
            PrintMode.MESSAGE, f"  * Compiling contracts and retrieving Slither IR..."
        )
        slither_object = Slither(filepath)
        return slither_object
    except SlitherError as e:
        crytic_print(PrintMode.ERROR, f"  * Slither error:\v{str(e)}")
        raise SlitherError(str(e))


def deploy_mode(args: argparse.Namespace):
    if args.output_dir is not None:
        output_dir = args.output_dir
        if not str(output_dir).endswith(os.path.sep):
            output_dir += os.path.sep
    else:
        output_dir = "./"

    if args.network:
        crytic_print(PrintMode.WARNING, "* Network specified via command line argument, but you are using 'deployment mode'. "
                                        "To use fork mode, provide addresses instead of file paths.\n  Ignoring network...\n")
    if args.block:
        crytic_print(PrintMode.WARNING, "* Block specified via command line argument, but you are using 'deployment mode'. "
                                        "To use fork mode, provide addresses instead of file paths.\n  Ignoring block...\n")
    if args.network_rpc:
        crytic_print(PrintMode.WARNING, "* RPC specified via command line argument, but you are using 'deployment mode'. "
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
        deploy,
        version,
        targets=targets,
        proxy=proxy,
        upgrade=upgrade
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
