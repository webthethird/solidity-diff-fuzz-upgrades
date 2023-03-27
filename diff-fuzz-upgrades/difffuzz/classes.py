from typing import TypedDict, List

from web3 import Web3
from slither import Slither
from slither.core.declarations.contract import Contract
from slither.core.declarations.function import Function

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