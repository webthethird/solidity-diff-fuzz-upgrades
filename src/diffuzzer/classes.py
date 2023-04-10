from typing import TypedDict, List

from web3 import Web3
from slither import Slither
from slither.core.declarations.contract import Contract
from slither.core.declarations.function import Function
from slither.core.variables.variable import Variable
from slither.utils.upgradeability import TaintedExternalContract
from slither.tools.read_storage.read_storage import SlotInfo


class FunctionInfo(TypedDict):
    name: str
    function: Function
    inputs: List[str]
    outputs: List[str]
    protected: bool


class ContractData(TypedDict):
    # Blockchain info
    address: str
    block: str
    prefix: str
    valid_data: bool
    web3_provider: Web3
    # File info
    path: str
    solc_version: str
    suffix: str
    # Contract info
    name: str
    interface: str
    interface_name: str
    functions: List[FunctionInfo]
    slither: Slither
    contract_object: Contract
    # Proxy info
    is_proxy: bool    
    implementation_object: Contract
    implementation_slither: Slither
    implementation_slot: SlotInfo


class Diff(TypedDict):
    missing_variables: List[Variable]
    new_variables: List[Variable]
    tainted_variables: List[Variable]
    new_functions: List[Function]
    modified_functions: List[Function]
    tainted_functions: List[Function]
    tainted_contracts: List[TaintedExternalContract]
