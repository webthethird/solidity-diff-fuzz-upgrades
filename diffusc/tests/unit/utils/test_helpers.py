import os
from pathlib import Path

from solc_select import solc_select
from slither import Slither

TEST_DATA_DIR = Path(__file__).resolve().parent / "test_data" / "helpers"


def test_pragma_from_file() -> None:
    pass
