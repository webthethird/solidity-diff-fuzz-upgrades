"""Module containing helper functions used by path mode."""

from typing import List

# pylint: disable= no-name-in-module
from solc_select.solc_select import (
    switch_global_version,
    installed_versions,
    get_installable_versions,
)
from slither.exceptions import SlitherError
from diffuzzer.utils.classes import ContractData
from diffuzzer.utils.crytic_print import PrintMode, CryticPrint
from diffuzzer.utils.slither_provider import FileSlitherProvider
from diffuzzer.utils.helpers import (
    get_pragma_version_from_file,
    get_compilation_unit_name,
)
from diffuzzer.core.code_generation import CodeGenerator


def get_contracts_from_comma_separated_paths(
    paths_string: str, provider: FileSlitherProvider, suffix: str = ""
) -> List[ContractData]:
    """Get multiple ContractData objects from a comma-separated list of paths."""
    contracts = []
    filepaths = paths_string.split(",")

    for path in filepaths:
        contract_data = get_contract_data_from_path(path, provider, suffix)
        contracts.append(contract_data)
    return contracts


def get_contract_data_from_path(
    filepath: str, provider: FileSlitherProvider, suffix: str = ""
) -> ContractData:
    """Get a ContractData object from file path, including Slither object."""
    contract_data = ContractData()

    CryticPrint.print(PrintMode.MESSAGE, f"* Getting contract data from {filepath}")

    contract_data["path"] = filepath
    contract_data["suffix"] = suffix
    version = get_pragma_version_from_file(filepath)
    contract_data["solc_version"] = version
    if version in installed_versions() or version in get_installable_versions():
        switch_global_version(version, True)

    try:
        contract_data["slither"] = provider.get_slither_from_filepath(filepath)
        contract_data["valid_data"] = True
    except SlitherError:
        CryticPrint.print(PrintMode.ERROR, "  * Error getting Slither object")
        contract_data["slither"] = None
        contract_data["valid_data"] = False

    if contract_data["valid_data"]:
        slither_object = contract_data["slither"]
        contract_name = get_compilation_unit_name(slither_object)
        try:
            contract = slither_object.get_contract_from_name(contract_name)[0]
        except IndexError:
            contract = slither_object.get_contract_from_name(
                contract_name.replace("V1", "").replace("V2", "").replace("V3", "")
            )[0]
        contract_data["contract_object"] = contract
        contract_data = CodeGenerator.get_valid_contract_data(contract_data)
        CryticPrint.print(
            PrintMode.MESSAGE, f"  * Done compiling contract {contract_data['name']}"
        )

    return contract_data
