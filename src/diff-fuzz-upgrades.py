#!/usr/bin/env python3

import argparse
import logging
import time
import os
import subprocess
from web3 import Web3, logs
from web3.middleware import geth_poa_middleware
from slither import Slither
from slither.exceptions import SlitherError
from slither.utils.upgradeability import compare
from slither.core.declarations.contract import Contract
from slither.core.declarations.function import Function
from slither.core.variables.state_variable import StateVariable
from slither.core.declarations.enum import Enum
from crytic_compile import InvalidCompilation
from eth_utils import to_checksum_address, is_address
from eth_typing.evm import ChecksumAddress
from colorama import Back, Fore, Style, init as colorama_init


class PrintMode(Enum):
    MESSAGE = 0
    SUCCESS = 1
    INFORMATION = 2
    WARNING = 3
    ERROR = 4


def crytic_print(mode, message):
    if mode is PrintMode.MESSAGE:
        print(Style.BRIGHT + Fore.LIGHTBLUE_EX + message + Style.RESET_ALL)
    elif mode is PrintMode.SUCCESS:
        print(Fore.LIGHTGREEN_EX + message + Style.RESET_ALL)
    elif mode is PrintMode.INFORMATION:
        print(Fore.LIGHTCYAN_EX + message + Style.RESET_ALL)
    elif mode is PrintMode.WARNING:
        print(Fore.LIGHTYELLOW_EX + message + Style.RESET_ALL)
    elif mode is PrintMode.ERROR:
        print(Style.BRIGHT + Fore.LIGHTRED_EX + message + Style.RESET_ALL)


def get_compilation_unit_name(slither_object):
    name = list(slither_object.crytic_compile.compilation_units.keys())[0]
    if os.path.sep in name:
        name = name.rsplit(os.path.sep, maxsplit=1)[1]
    if name.endswith(".sol"):
        name = os.path.splitext(name)[0]
    return name


def get_contract_data_from_path(filepath):
    contract_data = dict()

    crytic_print(PrintMode.MESSAGE, f"Getting contract data from {filepath}")

    try:
        contract_data["slither"] = get_slither_object_from_path(filepath)
        contract_data["valid_data"] = True
    except:
        contract_data["slither"] = None
        contract_data["valid_data"] = False

    if contract_data["valid_data"]:
        slither_object = contract_data["slither"]
        contract_name = get_compilation_unit_name(slither_object)
        contract_data["contract_object"] = slither_object.get_contract_from_name(contract_name)[0]

    return contract_data


def get_slither_object_from_path(filepath):
    if not os.path.exists(filepath):
        raise ValueError("File path does not exist!")
    try:
        crytic_print(PrintMode.MESSAGE, f"Getting Slither object")
        slither_object = Slither(filepath)
        return slither_object
    except SlitherError as e:
        crytic_print(PrintMode.ERROR, f"Slither error:\v{str(e)}")
        raise SlitherError(str(e))


def main():
    # Read command line arguments

    parser = argparse.ArgumentParser(
        prog='diff-fuzz-upgrades',
        description='Generate differential fuzz testing contract for comparing two upgradeable contract versions.'
    )

    parser.add_argument('v1_filename', help='The path to the original version of the contract.')
    parser.add_argument('v2_filename', help='The path to the upgraded version of the contract.')

    args = parser.parse_args()

    v1_contract_data = get_contract_data_from_path(args.v1_filename)
    v2_contract_data = get_contract_data_from_path(args.v2_filename)

    crytic_print(PrintMode.MESSAGE, "Performing diff of V1 and V2")
    diff = compare(v1_contract_data["contract_object"], v2_contract_data["contract_object"])
    for key in diff.keys():
        if len(diff[key]) > 0:
            crytic_print(PrintMode.WARNING, f'    * {str(key).replace("-", " ")}:')
            for obj in diff[key]:
                if isinstance(obj, StateVariable):
                    crytic_print(PrintMode.WARNING, f'        * {obj.full_name}')
                elif isinstance(obj, Function):
                    crytic_print(PrintMode.WARNING, f'        * {obj.signature_str}')


if __name__ == "__main__":
    main()

