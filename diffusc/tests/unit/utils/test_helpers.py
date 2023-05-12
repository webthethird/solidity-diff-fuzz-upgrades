import os
from pathlib import Path

from solc_select import solc_select
from slither import Slither
from diffusc.utils import helpers

TEST_DATA_DIR = Path(__file__).resolve().parent / "test_data" / "helpers"


def test_pragma_from_file() -> None:
    file = Path(TEST_DATA_DIR, "pragmaA.sol").as_posix()
    versions = helpers.get_pragma_versions_from_file(file)
    assert versions == ("0.8.0", "0.8.20")
    file = Path(TEST_DATA_DIR, "pragmaB.sol").as_posix()
    versions = helpers.get_pragma_versions_from_file(file)
    assert versions == ("0.8.2", "0.8.20")
    file = Path(TEST_DATA_DIR, "pragmaC.sol").as_posix()
    versions = helpers.get_pragma_versions_from_file(file)
    assert versions == ("0.8.2", "0.8.17")
    file = Path(TEST_DATA_DIR, "pragmaD.sol").as_posix()
    versions = helpers.get_pragma_versions_from_file(file)
    assert versions == ("0.8.2", "0.8.14")
    file = Path(TEST_DATA_DIR, "pragmaE.sol").as_posix()
    versions = helpers.get_pragma_versions_from_file(file)
    assert versions == ("0.8.10", "0.8.10")


def test_compilation_unit_name() -> None:
    file = Path(TEST_DATA_DIR, "pragmaA.sol").as_posix()
    sl = Slither(file)
    assert helpers.get_compilation_unit_name(sl) == "pragmaA"


def test_do_diff() -> None:
    pass


def test_similar() -> None:
    pass


def test_camel_case() -> None:
    pass
