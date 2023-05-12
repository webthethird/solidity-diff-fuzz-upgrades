import os
from pathlib import Path
from argparse import Namespace

from solc_select import solc_select
from slither import Slither
from diffusc.core.code_generation import CodeGenerator
from diffusc.utils.classes import ContractData, FunctionInfo, SlotInfo
from diffusc.utils.from_address import get_contract_data_from_address
from diffusc.utils.from_path import get_contract_data_from_path


TEST_DATA_DIR = Path(__file__).resolve().parent / "test_data"
TEST_CONTRACTS = {"CodeGeneration.sol": "0.8.4", "TransparentUpgradeableProxy.sol": "0.8.0"}


def test_interface_from_file() -> None:
    for test, version in TEST_CONTRACTS.items():
        solc_select.switch_global_version(version, always_install=True)
        file_path = Path(TEST_DATA_DIR, f"{test}").as_posix()
        sl = Slither(file_path)
        contract = sl.get_contract_from_name(test.replace(".sol", ""))[0]
        contract_data = ContractData(
            contract_object=contract,
            slither=sl,
            path=contract.file_scope.filename.absolute,
            valid_data=True,
            is_proxy=False,
            suffix=""
        )   # type: ignore[typeddict-item]
        contract_data = CodeGenerator.get_contract_interface(contract_data)
        expected_file = Path(TEST_DATA_DIR, f"I{test}").as_posix()
        with open(expected_file, "r") as file:
            expected = file.read()
        assert contract_data["interface"] == expected


def test_contract_data_from_slither() -> None:
    for test, version in TEST_CONTRACTS.items():
        solc_select.switch_global_version(version, always_install=True)
        file_path = Path(TEST_DATA_DIR, f"{test}").as_posix()
        sl = Slither(file_path)
        contract = sl.get_contract_from_name(test.replace(".sol", ""))[0]
        contract_data = CodeGenerator.get_contract_data(contract)
        assert contract_data["valid_data"]
        assert contract_data["slither"].crytic_compile == sl.crytic_compile
        assert contract_data["path"] == file_path
        assert contract_data["name"] == test.replace(".sol", "")
        assert contract_data["interface_name"] == "I" + test.replace(".sol", "")
        assert contract_data["solc_version"] == version
        expected_file = Path(TEST_DATA_DIR, f"I{test}").as_posix()
        with open(expected_file, "r") as file:
            expected_interface = file.read()
        assert contract_data["interface"] == expected_interface
        if contract.is_upgradeable_proxy:
            assert contract_data["is_proxy"]
            assert isinstance(contract_data["implementation_slot"], SlotInfo)


def test_args_and_returns() -> None:
    pass
    # solc_select.switch_global_version("0.8.4", always_install=True)
    # file_path = Path(TEST_DATA_DIR, "CodeGeneration.sol").as_posix()
    # sl = Slither(file_path)
    # contract = sl.get_contract_from_name("CodeGeneration")[0]
    # func_info = FunctionInfo()


# def test_generate_test_contract_fork() -> None:
