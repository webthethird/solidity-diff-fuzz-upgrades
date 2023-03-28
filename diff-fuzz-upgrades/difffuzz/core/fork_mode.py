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
from crytic_compile import InvalidCompilation
from eth_utils import to_checksum_address, is_address
from eth_typing.evm import ChecksumAddress
from colorama import Back, Fore, Style, init as colorama_init


SUPPORTED_NETWORKS = [ "mainet","optim","ropsten","kovan","rinkeby","goerli","tobalaba","bsc","testnet.bsc","arbi","testnet.arbi","poly","mumbai","avax","testnet.avax","ftm"]
WEB3_RPC_ENV_VARS  = [ "WEB3_PROVIDER_URI", "ECHIDNA_RPC_URL", "RPC_URL" ]


def fork_mode(args: argparse.Namespace):
    raise NotImplementedError()
