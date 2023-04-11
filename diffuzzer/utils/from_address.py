"""Module containing helper functions used by fork mode."""

from eth_utils import to_checksum_address, is_address
from slither import Slither
from slither.exceptions import SlitherError
from slither.core.declarations import Contract
from slither.utils.upgradeability import get_proxy_implementation_slot
from diffuzzer.utils.classes import ContractData
from diffuzzer.utils.crytic_print import PrintMode, CryticPrint
from diffuzzer.utils.slither_provider import NetworkSlitherProvider
from diffuzzer.utils.network_info_provider import NetworkInfoProvider
from diffuzzer.utils.helpers import (
    get_compilation_unit_name,
)
from diffuzzer.core.code_generation import get_contract_interface


def get_deployed_contract(
    contract_data: ContractData,
    implementation: str,
    slither_provider: NetworkSlitherProvider,
    network_info: NetworkInfoProvider,
) -> tuple[Contract, Slither | None, Contract | None]:
    """Get deployed contract ABI from Slither
    Will get the correct implementation if the contract is a proxy
    """

    CryticPrint.print(
        PrintMode.INFORMATION, "    * Getting information from contract..."
    )
    slither_object = contract_data["slither"]
    contract_name = get_compilation_unit_name(slither_object)
    contract = slither_object.get_contract_from_name(contract_name)[0]
    impl_slither = None
    impl_contract = None

    if contract.is_upgradeable_proxy:
        if implementation == "":
            implementation, contract_data = network_info.get_proxy_implementation(
                contract, contract_data
            )
            if implementation == "0x0000000000000000000000000000000000000000":
                CryticPrint.print(
                    PrintMode.WARNING,
                    f"      * Contract at {contract_data['address']} was mistakenly "
                    "identified as a proxy. Please check that results are consistent.",
                )
                return contract, impl_slither, impl_contract
            CryticPrint.print(
                PrintMode.WARNING,
                f"      * {contract_data['address']} is a proxy. Found implementation "
                f"at {implementation}",
            )

        impl_slither = slither_provider.get_slither_from_address(implementation)
        contract_name = get_compilation_unit_name(impl_slither)
        impl_contract = impl_slither.get_contract_from_name(contract_name)[0]

    return contract, impl_slither, impl_contract


def get_contract_data_from_address(
    address: str,
    implementation: str,
    slither_provider: NetworkSlitherProvider,
    network_info: NetworkInfoProvider,
    suffix: str = "",
) -> ContractData:
    """Get a ContractData object from a network address, including Slither object."""

    contract_data = ContractData()

    CryticPrint.print(
        PrintMode.INFORMATION,
        f"  * Getting information from address {to_checksum_address(address)}",
    )

    contract_data["address"] = to_checksum_address(address)
    contract_data["block"] = network_info.get_block_number()
    contract_data["prefix"] = slither_provider.get_network_prefix()
    contract_data["suffix"] = suffix
    try:
        contract_data["slither"] = slither_provider.get_slither_from_address(
            contract_data["address"]
        )
        contract_data["valid_data"] = True
    except SlitherError:
        contract_data["slither"] = None
        contract_data["valid_data"] = False
        CryticPrint.print(PrintMode.WARNING, "    * Could not fetch information.")

    if contract_data["valid_data"]:
        contract, impl_slither, impl_contract = get_deployed_contract(
            contract_data, implementation, slither_provider, network_info
        )
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

        CryticPrint.print(
            PrintMode.SUCCESS,
            f"    * Information fetched correctly for contract {contract_data['name']}",
        )

    return contract_data


def addresses_from_comma_separated_string(data: str) -> tuple[list, dict]:
    """
    Get a list of addresses and a dict mapping proxies to implementation address
    from a comma-separated list of addresses, such as the example below:
    0xaddress1,0xproxy2:0ximplementation2,0xaddress3
    """
    addresses = data.split(",")

    unique_addresses = set()
    implementations = {}

    for address in addresses:
        if ":" in address:
            # This is an implementation specification
            pair = address.split(":")
            proxy = to_checksum_address(pair[0])
            impl = to_checksum_address(pair[1])

            unique_addresses.add(proxy)
            implementations[proxy] = impl
        else:
            if not is_address(address):
                CryticPrint.print(
                    PrintMode.ERROR,
                    f"\n  * {address} is not an address. Ignoring...",
                )
            else:
                unique_addresses.add(to_checksum_address(address))

    unique_addresses = list(unique_addresses)

    return unique_addresses, implementations


def get_contracts_from_comma_separated_string(
    addresses_string: str,
    slither_provider: NetworkSlitherProvider,
    network_info: NetworkInfoProvider,
) -> tuple[list[ContractData], list[str], dict]:
    """
    Get a list of ContractData objects, as well as a list of addresses and a
    dict mapping proxies to implementation addresses, from a comma-separated
    list of addresses, such as the example below:
    0xaddress1,0xproxy2:0ximplementation2,0xaddress3
    """

    results = []

    [addresses, implementations] = addresses_from_comma_separated_string(
        addresses_string
    )
    for address in addresses:
        data = get_contract_data_from_address(
            address, implementations.get(address, ""), slither_provider, network_info
        )
        if not data["valid_data"]:
            CryticPrint.print(
                PrintMode.ERROR,
                f"  * Target contract {address} source code is not available.",
            )
            raise ValueError(f"Target contract {address} source code is not available.")
        results.append(data)

    return results, addresses, implementations
