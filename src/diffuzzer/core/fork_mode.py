#!/usr/bin/env python3

import argparse
import logging
import time
import os
import subprocess
import difflib
from typing import Any, TypedDict, List, Tuple
from solc_select.solc_select import (
    switch_global_version,
    installed_versions,
    get_installable_versions,
)
from web3 import Web3, logs
from web3.middleware import geth_poa_middleware
from crytic_compile import InvalidCompilation
from eth_utils import to_checksum_address, is_address
from eth_typing.evm import ChecksumAddress
from colorama import Back, Fore, Style, init as colorama_init
from slither import Slither
from slither.exceptions import SlitherError
from slither.utils.upgradeability import compare, get_proxy_implementation_slot
from slither.utils.type import convert_type_for_solidity_signature_to_string
from slither.utils.code_generation import generate_interface
from slither.core.declarations.contract import Contract
from slither.core.declarations.function import Function
from slither.core.variables.state_variable import StateVariable
from slither.core.variables.local_variable import LocalVariable
from slither.core.declarations.enum import Enum
from slither.core.solidity_types import (
    Type,
    ElementaryType,
    UserDefinedType,
    ArrayType,
    MappingType
)
from slither.core.declarations.structure import Structure
from slither.core.declarations.structure_contract import StructureContract
from diffuzzer.utils.printer import PrintMode, crytic_print
from diffuzzer.utils.helpers import (
    write_to_file
)
from diffuzzer.core.code_generation import (
    generate_test_contract,
    generate_config_file
)
from diffuzzer.utils.from_address import (
    get_contracts_from_comma_separated_string,
    get_contract_data_from_address
)


SUPPORTED_NETWORKS = [ "mainet","optim","ropsten","kovan","rinkeby","goerli","tobalaba","bsc","testnet.bsc","arbi","testnet.arbi","poly","mumbai","avax","testnet.avax","ftm"]
WEB3_RPC_ENV_VARS  = [ "WEB3_PROVIDER_URI", "ECHIDNA_RPC_URL", "RPC_URL" ]


def fork_mode(args: argparse.Namespace):
    mode = "fork"

    if args.output_dir is not None:
        output_dir = args.output_dir
        if not str(output_dir).endswith(os.path.sep):
            output_dir += os.path.sep
    else:
        output_dir = "./"

    # Network prefix
    prefix = ""

    # Information from contracts
    tokens = []
    targets = []

    # Try to get the network RPC endpoint
    network_rpc = ""
    if args.network_rpc:
        network_rpc = args.network_rpc
        crytic_print(PrintMode.INFORMATION, f"* RPC specified via command line parameter: {network_rpc}")
    else:
        for env_var in WEB3_RPC_ENV_VARS:
            if env_var in os.environ:
                network_rpc = os.environ[env_var]
                crytic_print(PrintMode.INFORMATION,
                             f"* RPC specified via {env_var} environment variable: {network_rpc}")
                break

    if network_rpc != "":
        w3 = Web3(Web3.HTTPProvider(network_rpc))
        if not w3.is_connected():
            crytic_print(PrintMode.ERROR, f"* Could not connect to the provided RPC endpoint.")
            raise ValueError(f"Could not connect to the provided RPC endpoint: {network_rpc}.")
        else:
            crytic_print(PrintMode.SUCCESS, f"* Connected to RPC endpoint.")
    else:
        crytic_print(PrintMode.ERROR, f"* RPC not specified")
        raise ValueError(f"RPC not specified.")

    # Add prefix for current network
    if args.network in SUPPORTED_NETWORKS or args.network == "mainnet":
        if args.network == "mainnet":
            prefix = "mainet:"
        else:
            prefix = f"{args.network}:"
        crytic_print(PrintMode.INFORMATION, f"* Network specified via command line parameter: {args.network}")
    else:
        crytic_print(PrintMode.WARNING, f"* Network {args.network} not supported. Defaulting to Ethereum main network.")
        prefix = "mainet:"

    # Workaround for PoA networks
    if prefix in ["bsc:", "poly:", "rinkeby:"]:
        w3.middleware_onion.inject(geth_poa_middleware, layer=0)

    # Get block number
    if args.block:
        blocknumber = int(args.block)
        crytic_print(PrintMode.INFORMATION, f"* Block number specified via command line parameter: {blocknumber}")
    elif "ECHIDNA_RPC_BLOCK" in os.environ:
        blocknumber = int(os.environ["ECHIDNA_RPC_BLOCK"])
        crytic_print(PrintMode.INFORMATION,
                     f"* Block number specified via ECHIDNA_RPC_BLOCK environment variable: {blocknumber}")
    elif w3 is not None:
        blocknumber = int(w3.eth.get_block('latest')["number"])
        crytic_print(PrintMode.INFORMATION, f"* Using network's latest block as starting block: {blocknumber}")
    else:
        blocknumber = 0  # We have no starting block
        crytic_print(PrintMode.WARNING, f"* Block number not specified, and could not get network's latest block.")

    crytic_print(PrintMode.INFORMATION, "* Inspecting V1 and V2 contracts:")
    v1_contract_data = get_contract_data_from_address(args.v1, "", prefix, blocknumber, w3, suffix="V1")
    v2_contract_data = get_contract_data_from_address(args.v2, "", prefix, blocknumber, w3, suffix="V2")

    if args.proxy is not None:
        crytic_print(
            PrintMode.INFORMATION,
            "\n* Proxy contract specified via command line parameter:",
        )
        if is_address(args.proxy):
            proxy = get_contract_data_from_address(args.proxy, "", prefix, blocknumber, w3)
            if not proxy["is_proxy"]:
                crytic_print(
                    PrintMode.ERROR,
                    f"\n  * {proxy['name']} does not appear to be a proxy. Ignoring...",
                )
                proxy = None
        else:
            crytic_print(
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
        targets, _, _ = get_contracts_from_comma_separated_string(args.targets, prefix, blocknumber, w3)
    else:
        targets = None

    if args.deploy:
        crytic_print(
                PrintMode.WARNING, 
                "* Deploy mode flag specified, but you are using fork mode. The contracts are already deployed! Ignoring..."
            )
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
    write_to_file(f"{output_dir}diffuzzerUpgrades.sol", contract)
    crytic_print(
        PrintMode.SUCCESS,
        f"  * Fuzzing contract generated and written to {output_dir}diffuzzerUpgrades.sol.",
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
