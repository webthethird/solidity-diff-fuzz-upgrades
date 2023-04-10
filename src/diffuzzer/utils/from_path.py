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
from diffuzzer.classes import ContractData
from diffuzzer.utils.printer import PrintMode, crytic_print
from diffuzzer.utils.helpers import (
    get_pragma_version_from_file,
    get_compilation_unit_name
)
from diffuzzer.core.code_generation import (
    get_contract_interface
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
        crytic_print(PrintMode.ERROR, f"  * Error getting Slither object")
        contract_data["slither"] = None
        contract_data["valid_data"] = False

    if contract_data["valid_data"]:
        slither_object = contract_data["slither"]
        contract_name = get_compilation_unit_name(slither_object)
        try:
            contract = slither_object.get_contract_from_name(contract_name)[0]
        except IndexError:
            contract = slither_object.get_contract_from_name(contract_name.replace("V1", "").replace("V2", "").replace("V3", ""))[0]
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
    except Exception as e:
        crytic_print(PrintMode.ERROR, f"  * Exception:\v{str(e)}")
