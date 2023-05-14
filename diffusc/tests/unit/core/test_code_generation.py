import argparse
import os
from pathlib import Path

from solc_select import solc_select
from slither import Slither
from diffusc.core.code_generation import CodeGenerator
from diffusc.utils.classes import ContractData, FunctionInfo, SlotInfo
from diffusc.utils.helpers import do_diff
from diffusc.utils.from_address import get_contract_data_from_address
from diffusc.utils.from_path import get_contract_data_from_path
from diffusc.utils.slither_provider import FileSlitherProvider, NetworkSlitherProvider


TEST_DATA_DIR = Path(__file__).resolve().parent / "test_data"
TEST_CONTRACTS = {"CodeGeneration.sol": "0.8.4", "TransparentUpgradeableProxy.sol": "0.8.0"}


def test_interface_from_file() -> None:
    for test, version in TEST_CONTRACTS.items():
        solc_select.switch_global_version(version, always_install=True)
        file_path = os.path.join(TEST_DATA_DIR, test)
        sl = Slither(file_path)
        contract = sl.get_contract_from_name(test.replace(".sol", ""))[0]
        contract_data = ContractData(
            contract_object=contract,
            slither=sl,
            path=contract.file_scope.filename.absolute,
            valid_data=True,
            is_proxy=False,
            suffix="",
        )  # type: ignore[typeddict-item]
        contract_data = CodeGenerator.get_contract_interface(contract_data)
        expected_file = os.path.join(TEST_DATA_DIR, f"I{test}")
        with open(expected_file, "r") as file:
            expected = file.read()
        assert contract_data["interface"] == expected


def test_contract_data_from_slither() -> None:
    for test, version in TEST_CONTRACTS.items():
        solc_select.switch_global_version(version, always_install=True)
        file_path = os.path.join(TEST_DATA_DIR, test)
        sl = Slither(file_path)
        contract = sl.get_contract_from_name(test.replace(".sol", ""))[0]
        contract_data = CodeGenerator.get_contract_data(contract)
        assert contract_data["valid_data"]
        assert isinstance(contract_data["slither"], Slither)
        assert contract_data["slither"].crytic_compile == sl.crytic_compile
        assert contract_data["path"] == file_path
        assert contract_data["name"] == test.replace(".sol", "")
        assert contract_data["interface_name"] == "I" + test.replace(".sol", "")
        assert contract_data["solc_version"] == version
        expected_file = os.path.join(TEST_DATA_DIR, f"I{test}")
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


def test_generate_contract_path_mode() -> None:
    provider = FileSlitherProvider()
    output_dir = os.path.join(TEST_DATA_DIR, "output")
    v1_data = get_contract_data_from_path(
        os.path.join(TEST_DATA_DIR, "ContractV1.sol"), output_dir, provider
    )
    v2_data = get_contract_data_from_path(
        os.path.join(TEST_DATA_DIR, "ContractV2.sol"), output_dir, provider
    )
    proxy_data = get_contract_data_from_path(
        os.path.join(TEST_DATA_DIR, "TransparentUpgradeableProxy.sol"), output_dir, provider
    )
    market_data = get_contract_data_from_path(
        os.path.join(TEST_DATA_DIR, "token", "MarketToken.sol"), output_dir, provider
    )
    oracle_data = get_contract_data_from_path(
        os.path.join(TEST_DATA_DIR, "SimplePriceOracle.sol"), output_dir, provider
    )

    assert v1_data["valid_data"] and v2_data["valid_data"]
    diff = do_diff(v1_data, v2_data)

    # Test code generation w/o proxy, additional targets, upgrade function or protected functions
    generator = CodeGenerator(v1_data, v2_data, "path", "0.8.2", False, False)
    code = generator.generate_test_contract(diff)
    with open(os.path.join(TEST_DATA_DIR, "output", "Expected_0.sol"), "r") as expected:
        expected_code = expected.read()
    assert code.replace(f".{os.sep}", "./") == expected_code

    # Test code generation w/ proxy and upgrade function, w/o additional targets or protected functions
    generator = CodeGenerator(v1_data, v2_data, "path", "0.8.2", True, False)
    assert proxy_data["valid_data"]
    generator.proxy = proxy_data
    code = generator.generate_test_contract(diff)
    with open(os.path.join(TEST_DATA_DIR, "output", "Expected_1.sol"), "r") as expected:
        expected_code = expected.read()
    assert code.replace(f".{os.sep}", "./") == expected_code

    # Test code generation w/ additional targets, w/o proxy, upgrade function, protected functions
    generator = CodeGenerator(v1_data, v2_data, "path", "0.8.2", False, False)
    assert market_data["valid_data"] and oracle_data["valid_data"]
    generator.targets = [market_data, oracle_data]
    diff = do_diff(v1_data, v2_data, [market_data, oracle_data])
    code = generator.generate_test_contract(diff)
    with open(os.path.join(TEST_DATA_DIR, "output", "Expected_2.sol"), "r") as expected:
        expected_code = expected.read()
    assert code.replace(f".{os.sep}", "./") == expected_code

    # Test code generation w/ additional targets, external taint and protected functions, w/o proxy, upgrade function
    generator = CodeGenerator(v1_data, v2_data, "path", "0.8.2", False, True)
    generator.targets = [market_data, oracle_data]
    diff = do_diff(v1_data, v2_data, [market_data, oracle_data], include_external=True)
    code = generator.generate_test_contract(diff)
    with open(os.path.join(TEST_DATA_DIR, "output", "Expected_3.sol"), "r") as expected:
        expected_code = expected.read()
    assert code.replace(f".{os.sep}", "./") == expected_code
