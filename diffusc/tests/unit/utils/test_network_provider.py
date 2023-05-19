import os
from pathlib import Path

# import pytest
from solc_select.solc_select import switch_global_version
from slither import Slither
from diffusc.utils.network_info_provider import NetworkInfoProvider
from diffusc.core.code_generation import CodeGenerator

TEST_DATA_DIR = Path(__file__).resolve().parent / "test_data"


def test_bad_rpc_init() -> None:
    # Should fail due to bad RPC Url
    rpc_url = "https://mainnet.infura.io/v3/no_api_key"
    try:
        NetworkInfoProvider(rpc_url, "latest")
        assert False
    except ValueError as err:
        assert str(err) == f"Could not connect to the provided RPC endpoint: {rpc_url}."


def test_bad_poa_init() -> None:
    # Should fail because is_poa = True should be passed into NetworkInfoProvider for BSC
    rpc_url = os.getenv("BSC_RPC_URL")
    assert rpc_url is not None
    try:
        NetworkInfoProvider(rpc_url, "latest")
        assert False
    except ValueError as err:
        assert (
            str(err) == "Got ExtraDataLengthError when getting block latest. "
            "Probably missing network value, if RPC url is for a POA chain."
        )


def test_bad_block_init() -> None:
    # Should fail because "final" is not a valid block identifier (should be "finalized")
    rpc_url = os.getenv("BSC_RPC_URL")
    assert rpc_url is not None
    try:
        NetworkInfoProvider(rpc_url, "final", is_poa=True)
        assert False
    except ValueError as err:
        assert (
            str(err) == '"final" is not a valid block identifier. Use "latest", "earliest", '
            '"pending", "safe" or "finalized" if not specifying an integer block number'
        )


def test_block_timestamp() -> None:
    rpc_url = os.getenv("BSC_RPC_URL")
    assert rpc_url is not None
    net_info = NetworkInfoProvider(rpc_url, 26857408, is_poa=True)
    assert net_info.get_block_timestamp() == 1680008936


def test_block_number() -> None:
    rpc_url = os.getenv("BSC_RPC_URL")
    assert rpc_url is not None
    net_info = NetworkInfoProvider(rpc_url, 26857408, is_poa=True)
    assert net_info.get_block_number() == 26857408
    net_info = NetworkInfoProvider(rpc_url, 0, is_poa=True)
    assert net_info.get_block_number() != 0


def test_contract_variable_value() -> None:
    rpc_url = os.getenv("GOERLI_RPC_URL")
    assert rpc_url is not None
    net_info = NetworkInfoProvider(rpc_url, "latest")
    api_key = os.getenv("GOERLI_API_KEY")
    contract_addr = "0xDc0Da9E56d7AEaA47b0f4913bAbb467b6E0C81cB"
    switch_global_version("0.8.18", always_install=True)
    sl = Slither(f"goerli:{contract_addr}", etherscan_api_key=api_key)
    contract = sl.get_contract_from_name("BadProxy")[0]
    state_var = contract.get_state_variable_from_name("stateVar1")
    assert net_info.get_contract_variable_value(state_var, contract_addr) == 1
    state_var = contract.get_state_variable_from_name("_IMPLEMENTATION_SLOT")
    # Should return empty string because slither-read-storage can't get the value of a constant
    assert net_info.get_contract_variable_value(state_var, contract_addr) == ""


def test_empty_proxy_implementation() -> None:
    # Should fail because the BadProxy I deployed has no address stored in _IMPLEMENTATION_SLOT
    rpc_url = os.getenv("GOERLI_RPC_URL")
    assert rpc_url is not None
    net_info = NetworkInfoProvider(rpc_url, "latest")
    api_key = os.getenv("GOERLI_API_KEY")
    contract_addr = "0xDc0Da9E56d7AEaA47b0f4913bAbb467b6E0C81cB"
    switch_global_version("0.8.18", always_install=True)
    sl = Slither(f"goerli:{contract_addr}", etherscan_api_key=api_key)
    contract_obj = sl.get_contract_from_name("BadProxy")[0]
    contract_data = CodeGenerator.get_contract_data(contract_obj)
    contract_data["address"] = contract_addr
    try:
        net_info.get_proxy_implementation(contract_obj, contract_data)
        assert False
    except ValueError as err:
        assert str(err) == "Proxy storage slot not found"


def test_proxy_missing_slot_info() -> None:
    # Should fail because the BadProxy I deployed overrides the fallback and breaks the data dependency
    rpc_url = os.getenv("GOERLI_RPC_URL")
    assert rpc_url is not None
    net_info = NetworkInfoProvider(rpc_url, "latest")
    api_key = os.getenv("GOERLI_API_KEY")
    contract_addr = "0x5a763c928430bc5742A144358B68CD8E14243030"
    switch_global_version("0.8.18", always_install=True)
    sl = Slither(f"goerli:{contract_addr}", etherscan_api_key=api_key)
    contract_obj = sl.get_contract_from_name("BadProxy")[0]
    contract_data = CodeGenerator.get_contract_data(contract_obj)
    contract_data["address"] = contract_addr
    try:
        net_info.get_proxy_implementation(contract_obj, contract_data)
    except ValueError as err:
        assert str(err) == "Proxy storage slot read is not an address"


def test_missing_token_holders() -> None:
    rpc_url = os.getenv("GOERLI_RPC_URL")
    assert rpc_url is not None
    net_info = NetworkInfoProvider(rpc_url, "latest")
    api_key = os.getenv("GOERLI_API_KEY")
    contract_addr = "0xDc0Da9E56d7AEaA47b0f4913bAbb467b6E0C81cB"
    switch_global_version("0.8.18", always_install=True)
    sl = Slither(f"goerli:{contract_addr}", etherscan_api_key=api_key)
    contract = sl.get_contract_from_name("BadProxy")[0]
    abi = contract.file_scope.abi(
        sl.compilation_units[0].crytic_compile_compilation_unit, contract.name
    )
    try:
        net_info.get_token_holders(1000, 1, contract_addr, abi)
    except ValueError as err:
        assert (
            str(err) == f"Contract at {contract_addr} doesn't appear to be a token. "
            "It does not have a Transfer event."
        )
