import os
import json
from pathlib import Path
from solc_select.solc_select import switch_global_version
from diffusc.diffusc import main


TEST_DATA_DIR = Path(__file__).resolve().parent / "test_data"


def test_diffusc_fork_mode() -> None:
    output_dir = os.path.join(TEST_DATA_DIR, "output")
    expected_dir = os.path.join(TEST_DATA_DIR, "expected")
    os.makedirs(output_dir, exist_ok=True)
    api_key = os.getenv("BSC_API_KEY")
    rpc_url = os.getenv("BSC_RPC_URL")
    args = [
        "0x0296201bfdfb410c29ef30bcae1b395537aeeb31",
        "0xEb11a0a0beF1AC028B8C2d4CD64138DD5938cA7A",
    ]
    # Missing RPC argument, should fail
    assert main(args) == 1

    args.extend(
        [
            "-K",
            api_key,
            "-R",
            rpc_url,
        ]
    )
    # Missing network, should fail because addresses have no code on Ethereum
    assert main(args) == 1

    # Test w/o proxy, additional targets, upgrade function or protected functions
    args.extend(
        [
            "-n",
            "bsc",
            "-b",
            "26857408",
            "-v",
            "0.8.11",
            "-d",
            output_dir,
        ]
    )
    assert main(args) == 0
    with open(os.path.join(expected_dir, "Expected_ForkMode_0.sol"), "r", encoding="utf-8") as file:
        expected = file.read()
    with open(os.path.join(output_dir, "DiffFuzzUpgrades.sol"), "r", encoding="utf-8") as file:
        actual = file.read()
    assert actual == expected

    # Test w/ proxy and upgrade function, w/o additional targets or protected functions
    args.extend(
        [
            "-p",
            "0x42981d0bfbAf196529376EE702F2a9Eb9092fcB5",
            "-u",
        ]
    )
    assert main(args) == 0
    with open(os.path.join(expected_dir, "Expected_ForkMode_1.sol"), "r", encoding="utf-8") as file:
        expected = file.read()
    with open(os.path.join(output_dir, "DiffFuzzUpgrades.sol"), "r", encoding="utf-8") as file:
        actual = file.read()
    assert actual == expected

    # Test w/ additional targets, w/o proxy, upgrade function, protected functions
    args[14] = "-t"
    args[15] = (
        "0x6ac68913d8fccd52d196b09e6bc0205735a4be5f:0xaa62468f41d9f1076920feb60b561a84ce62e9c3,"
        "0x524bc73fcb4fb70e2e84dc08efe255252a3b026e:0x8d63502B5E50f8F100C407B34ef16bF808DFA278"
    )
    assert main(args) == 0
    with open(os.path.join(expected_dir, "Expected_ForkMode_2.sol"), "r", encoding="utf-8") as file:
        expected = file.read()
    with open(os.path.join(output_dir, "DiffFuzzUpgrades.sol"), "r", encoding="utf-8") as file:
        actual = file.read()
    assert actual == expected

    # Test w/ additional targets, external taint and protected functions, w/o proxy, upgrade function
    args.extend(
        [
            "-x",
            "-P",
        ]
    )
    assert main(args) == 0
    with open(os.path.join(expected_dir, "Expected_ForkMode_3.sol"), "r", encoding="utf-8") as file:
        expected = file.read()
    with open(os.path.join(output_dir, "DiffFuzzUpgrades.sol"), "r", encoding="utf-8") as file:
        actual = file.read()
    assert actual == expected

    # Test w/ proxy, additional targets, external taint, token holders, protected functions and upgrade function
    args.extend(
        [
            "-p",
            "0x42981d0bfbAf196529376EE702F2a9Eb9092fcB5",
            "-T",
        ]
    )
    assert main(args) == 0
    with open(os.path.join(expected_dir, "Expected_ForkMode_4.sol"), "r", encoding="utf-8") as file:
        expected = file.read()
    with open(os.path.join(output_dir, "DiffFuzzUpgrades.sol"), "r", encoding="utf-8") as file:
        actual = file.read()
    assert actual == expected
