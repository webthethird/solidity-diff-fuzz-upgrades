import os
import time
from typing import List, Any
from solc_select.solc_select import (
    switch_global_version,
    installed_versions,
    get_installable_versions,
)
from web3 import Web3
from eth_utils import to_checksum_address, is_address
from slither import Slither
from slither.exceptions import SlitherError
from slither.core.declarations import Contract
from slither.core.variables.state_variable import StateVariable
from slither.utils.upgradeability import get_proxy_implementation_slot
from slither.tools.read_storage.utils import get_storage_data
from slither.tools.read_storage.read_storage import SlotInfo
from slither.tools.read_storage import SlitherReadStorage
from difffuzz.classes import ContractData
from difffuzz.utils.printer import PrintMode, crytic_print
from difffuzz.utils.helpers import (
    get_pragma_version_from_file,
    get_compilation_unit_name
)
from difffuzz.core.code_generation import (
    get_contract_interface
)
from crytic_compile.utils.zip import load_from_zip, save_to_zip


def get_contract_from_network_address(address: str, prefix: str) -> Slither:
    prefix = prefix[:-1]    # remove semicolon -- for compatibility with windows filesystems
    path = f"./crytic-cache/"
    filename = f"{prefix}-{address}.zip"

    crytic_print(PrintMode.INFORMATION, f"  * Downloading contract {address}.")

    if os.path.exists(path + filename):
        crytic_print(PrintMode.SUCCESS, f"    * Contract {prefix}-{address} found in cache.")
        cc = load_from_zip(path + filename)
        return Slither(cc[0])
    else:
        crytic_print(PrintMode.INFORMATION, f"    * Contract {prefix}-{address} not found in cache. Fetching from network...")
        crytic_print(PrintMode.INFORMATION, f"      * Waiting for Etherscan API timeout...")     # needed for etherscan without api key
        time.sleep(5)
    
        try:
            slither_object = Slither(f"{prefix}:{address}")
            if not os.path.exists(path):
                os.makedirs(path)
            save_to_zip([slither_object.crytic_compile], path + filename)
            crytic_print(PrintMode.SUCCESS, f"      * Contract {prefix}-{address} obtained and cached.")
            return slither_object
        except KeyError:
            crytic_print(PrintMode.ERROR, f"    * Contract {prefix}-{address} source code is not available.")
            raise ValueError("Contract source code is not available.")
        

def get_contract_variable_value(variable: StateVariable, contract_data: ContractData) -> Any:
    contract = variable.contract
    srs = SlitherReadStorage(contract, 20)

    srs.storage_address = contract_data["address"]
    srs.block = contract_data["block"]
    srs._web3 = contract_data["web3_provider"]

    try:
        slot = srs.get_storage_slot(variable, contract)
        srs.get_slot_values(slot)
        return slot.value
    except:
        return ''
        

def get_proxy_implementation(contract: Contract, contract_data: ContractData) -> str:

    crytic_print(PrintMode.INFORMATION, f"    * Getting proxy implementation from {contract.name} at {contract_data['address']}.")

    if not contract_data["web3_provider"]:
        crytic_print(PrintMode.ERROR, f"    * A valid Web3 provider is needed to get proxy implementations.")
        raise ValueError("A valid Web3 provider is needed to get proxy implementations.")
    
    slot: SlotInfo = get_proxy_implementation_slot(contract)
    if slot is not None: 
        
        imp = get_storage_data(contract_data["web3_provider"], contract_data["address"], bytes(slot.slot), contract_data["block"])
        impl_address = '0x' + imp.hex()[-40:]
    
        if impl_address != "0x0000000000000000000000000000000000000000":
            return impl_address

        crytic_print(PrintMode.WARNING, f"      * storage slot {slot.name} is zero")

        raise ValueError("Proxy storage slot not found")
    else:
        # Fallback: Try finding a state variable with "implementation" or "target" in its name
        implementation_var = []

        for v in contract.state_variables_ordered:
            if v.name.lower().find("implementation") >= 0 or v.name.lower().find("target") >= 0:
                implementation_var.append(v)

        if not implementation_var:
            crytic_print(PrintMode.WARNING, f"      * Couldn't find proxy implementation in contract storage")
            raise ValueError("Couldn't find proxy implementation in contract storage")
        else:
            for imp in implementation_var:
                slot_value = get_contract_variable_value(imp, contract_data)
                
                if slot_value[0:2] != "0x":
                    slot_value = "0x" + slot_value

                if is_address(slot_value) and slot_value != '0000000000000000000000000000000000000000':
                    crytic_print(PrintMode.WARNING, f"      * Proxy implementation address read from variable: {imp.type} {imp.name}")
                    return slot_value

            crytic_print(PrintMode.ERROR, f"      * Proxy storage slot read is not an address")
            raise ValueError("Proxy storage slot read is not an address")
        

def get_deployed_contract(contract_data: ContractData, implementation: str) -> tuple[Contract, Slither|None, Contract|None]:
    """Get deployed contract ABI from Slither
    Will get the correct implementation if the contract is a proxy
    """

    crytic_print(PrintMode.INFORMATION, f"    * Getting information from contract...")
    slither_object = contract_data["slither"]
    contract_name = get_compilation_unit_name(slither_object)
    contract = slither_object.get_contract_from_name(contract_name)[0]
    impl_slither = None
    impl_contract = None

    if contract.is_upgradeable_proxy:
        if implementation == "":
            implementation = get_proxy_implementation(contract, contract_data)
            if implementation == "0x0000000000000000000000000000000000000000":
                crytic_print(PrintMode.WARNING, f"      * Contract at {contract_data['address']} was mistakenly identified as a proxy. Please check that results are consistent.")
                return contract, impl_slither, impl_contract
            crytic_print(PrintMode.WARNING, f"      * {contract_data['address']} is a proxy. Found implementation at {implementation}")

        impl_slither = get_contract_from_network_address(implementation, contract_data["prefix"])
        contract_name = get_compilation_unit_name(impl_slither)
        impl_contract = impl_slither.get_contract_from_name(contract_name)[0]

    return contract, impl_slither, impl_contract


def get_contract_data_from_address(address: str, implementation: str, prefix: str, blocknumber: str, w3provider: Web3, suffix: str = "") -> ContractData:

    contract_data = ContractData()

    crytic_print(PrintMode.INFORMATION, f"  * Getting information from address {to_checksum_address(address)}")

    contract_data["address"] = to_checksum_address(address)    
    contract_data["block"]   = blocknumber
    contract_data["prefix"]  = prefix
    contract_data["suffix"]  = suffix
    contract_data["web3_provider"] = w3provider
    try:
        contract_data["slither"] = get_contract_from_network_address(contract_data["address"], prefix)
        contract_data["valid_data"] = True
    except:
        contract_data["slither"] = None
        contract_data["valid_data"] = False
        crytic_print(PrintMode.WARNING, f"    * Could not fetch information.")

    if contract_data["valid_data"]:
        contract, impl_slither, impl_contract = get_deployed_contract(contract_data, implementation)
        contract_data["contract_object"] = contract

        if impl_slither and impl_contract:
            contract_data["is_proxy"] = True
            contract_data["implementation_slither"] = impl_slither
            contract_data["implementation_object"] = impl_contract
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

        crytic_print(PrintMode.SUCCESS, f"    * Information fetched correctly for contract {contract_data['name']}")

    return contract_data


def addresses_from_comma_separated_string(data: str) -> tuple[list, dict]:
    addresses = data.split(",")

    unique_addresses = set()
    implementations = dict()

    for u in addresses:
        if ":" in u:
            # This is an implementation specification
            pair = u.split(":")
            proxy = to_checksum_address(pair[0])
            impl  = to_checksum_address(pair[1])

            unique_addresses.add(proxy)
            implementations[proxy] = impl
        else:
            if not is_address(u):
                crytic_print(
                    PrintMode.ERROR,
                    f"\n  * {u} is not an address. Ignoring...",
                )
            else:
                unique_addresses.add(to_checksum_address(u))
    
    unique_addresses = list(unique_addresses)

    return unique_addresses, implementations


def get_contracts_from_comma_separated_string(addresses_string: str, prefix: str, blocknumber: str, w3: Web3) -> tuple[list[ContractData], list[str], dict]:

    results = []

    [addresses, implementations] = addresses_from_comma_separated_string(addresses_string)
    for a in addresses:
        data = get_contract_data_from_address(a, implementations.get(a, ""), prefix, blocknumber, w3)
        if not data["valid_data"]:
            crytic_print(PrintMode.ERROR, f"  * Target contract {a} source code is not available.")
            raise ValueError(f"Target contract {a} source code is not available.")
        else:
            results.append(data)

    return results, addresses, implementations
