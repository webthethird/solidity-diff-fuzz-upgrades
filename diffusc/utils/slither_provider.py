"""Module containing classes for getting (and caching) Slither objects."""

import base64
import io
import os
from time import sleep
from random import random

from zipfile import ZipFile
from slither import Slither
from slither.exceptions import SlitherError
from crytic_compile import CryticCompile
from crytic_compile.utils.zip import load_from_zip, save_to_zip
from eth_utils import to_checksum_address, is_address

from diffusc.utils.crytic_print import CryticPrint


class SlitherProvider:
    """Base class for SlitherProviders"""

    _slither_object: Slither | None
    _address: str
    _network_prefix: str
    _cache_path: str
    _cache_filename: str

    def __init__(self) -> None:
        self._slither_object = None
        self._network_prefix = ""
        self._filename = ""
        self._cache_path = "./crytic-cache/"
        self._cache_filename = ""

    def get_slither_from_address(self, address: str) -> Slither:
        """Not implemented in base class."""
        raise NotImplementedError()

    def get_network_prefix(self) -> str:
        """Network prefix getter"""
        return self._network_prefix

    def _get_slither_from_cache(self, address: str) -> Slither | None:
        """Check if the contract at an address has already been compiled and cached."""
        CryticPrint.print_information(f"  * Looking for contract {address} in cache.")

        if os.path.exists(self._cache_path + self._cache_filename):
            CryticPrint.print_success(
                f"    * Contract {self._network_prefix}-{address} found in cache."
            )
            c_compile = load_from_zip(self._cache_path + self._cache_filename)
            return Slither(c_compile[0])
        return None

    def _save_slither_to_cache(self) -> None:
        """Cache a Slither compilation."""
        assert isinstance(self._slither_object, Slither)
        if not os.path.exists(self._cache_path):
            os.makedirs(self._cache_path)
        save_to_zip(
            [self._slither_object.crytic_compile],
            self._cache_path + self._cache_filename,
        )

        CryticPrint.print_success(
            f"      * Contract {self._cache_filename[:-4]} obtained and cached."
        )

    @staticmethod
    def _check_address(address: str) -> str:
        """Convert an address to checksum address. Raise ValueError for invalid address."""
        if not is_address(address):
            raise ValueError("Invalid address supplied")

        return to_checksum_address(address)


class NetworkSlitherProvider(SlitherProvider):
    """SlitherProvider for contracts specified by network address."""

    _api_key: str

    def __init__(self, network_prefix: str, api_key: str) -> None:
        super().__init__()
        self._api_key = api_key
        self._network_prefix = network_prefix
        if self._network_prefix[-1] == ":":
            self._network_prefix = self._network_prefix[:-1]

    def get_api_key(self) -> str:
        return self._api_key

    def get_slither_from_address(self, address: str) -> Slither:
        """Try to get Slither object from cache, and fetch it from web if not cached."""

        self._address = self._check_address(address)
        self._cache_filename = f"{self._network_prefix}-{address}.zip"

        slither = self._get_slither_from_cache(address)

        if slither is not None:
            self._slither_object = slither
            return slither
        CryticPrint.print_information(f"  * Did not find contract {address} in cache. Downloading...")
        tries = 5
        while slither is None and tries > 0:
            try:
                args = self._generate_api_key_dict()
                slither = Slither(f"{self._network_prefix}:{address}", **args)
                self._slither_object = slither
                self._save_slither_to_cache()
            except SlitherError as err:
                if tries > 0:
                    tries -= 1
                    CryticPrint.print_warning(f"    * Failed to download contract {address}. {tries} tries remaining...")
                    sleep(random() * 3)
                    continue
                raise SlitherError(str(err)) from err
        return slither

    def _generate_api_key_dict(self) -> dict:
        out_dict = {}
        if self._network_prefix == "mainet:":
            out_dict["etherscan_api_key"] = self._api_key
        elif self._network_prefix == "arbi:":
            out_dict["arbiscan_api_key"] = self._api_key
        elif self._network_prefix == "poly:":
            out_dict["polygonscan_api_key"] = self._api_key
        elif self._network_prefix == "mumbai:":
            out_dict["test_polygonscan_api_key"] = self._api_key
        elif self._network_prefix == "avax:":
            out_dict["avax_api_key"] = self._api_key
        elif self._network_prefix == "ftm:":
            out_dict["ftmscan_api_key"] = self._api_key
        elif self._network_prefix == "bsc:":
            out_dict["bscan_api_key"] = self._api_key
        elif self._network_prefix == "optim:":
            out_dict["optim_api_key"] = self._api_key
        else:
            out_dict["etherscan_api_key"] = self._api_key

        return out_dict


class FileSlitherProvider(SlitherProvider):
    """SlitherProvider for contracts specified by file path."""

    def __init__(self) -> None:
        super().__init__()
        self._network_prefix = "testnet"

    def get_slither_from_filepath(self, path: str) -> Slither:
        """Try to get Slither object from cache, compile file and cache if not cached."""

        self._filename = path.rsplit(os.path.sep, maxsplit=1)[1].replace(".sol", "")
        self._cache_filename = f"{self._network_prefix}={self._filename}.zip"

        slither = self._get_slither_from_cache(self._filename)

        if slither is not None:
            self._slither_object = slither
            return slither
        try:
            slither = Slither(path)
            self._slither_object = slither
            self._save_slither_to_cache()
        except SlitherError as err:
            raise SlitherError(str(err)) from err
        return slither

    def get_slither_from_address(self, address: str) -> Slither:
        """Same as get_slither_from_filepath(path)."""
        return self.get_slither_from_filepath(address)


class SlitherbotSlitherProvider(SlitherProvider):
    """SlitherProvider for contracts from Slitherbot."""

    _slitherbot_path: str

    def __init__(self, slitherbot_path: str) -> None:
        super().__init__()
        self._network_prefix = "mainet"
        self._slitherbot_path = slitherbot_path

        if self._slitherbot_path[-1] != "/":
            self._slitherbot_path = f"{self._slitherbot_path}/"
        self._slitherbot_path = f"{self._slitherbot_path}contracts/"

        if not os.path.exists(self._slitherbot_path):
            CryticPrint.print_error("Slitherbot contracts not found in provided path")
            raise NotADirectoryError("Slitherbot contracts not found in provided path")

    def _get_slither_from_slitherbot_cache(self) -> Slither:
        """Try to get Slither object from the slitherbot cache"""

        directory = self._slitherbot_path
        for character in str(self._address)[2:8].lower():
            directory += f"{character}/"
        path = directory + str(self._address).lower() + "/"
        filename = path + "artifact.zip.base64"

        if not os.path.exists(path):
            CryticPrint.print_error("Contract not found on slitherbot cache")
            raise ValueError("Contract not found on slitherbot cache")

        # Decode the base64 artifact
        with open(filename, encoding="utf-8") as artifact:
            data = artifact.read()
        data_decoded = base64.b64decode(data)

        # Read the zip file containing the CC json
        with ZipFile(io.BytesIO(data_decoded)) as zip_file:
            for zipinfo in zip_file.infolist():
                if zipinfo.filename[-4:] == "json":
                    with zip_file.open(zipinfo) as json_file:
                        json_contents = json_file.read().decode("utf8")
                    break

        c_compile = CryticCompile(json_contents, compile_force_framework="Archive")
        return Slither(c_compile)

    def get_slither_from_address(self, address: str) -> Slither:
        """Try to get Slither object from cache, or from Slitherbot if not in main cache."""

        self._address = self._check_address(address)
        self._cache_filename = f"{self._network_prefix}-{address}.zip"

        slither = self._get_slither_from_cache(address)

        if slither is not None:
            self._slither_object = slither
            return slither
        slither = self._get_slither_from_slitherbot_cache()
        self._slither_object = slither
        self._save_slither_to_cache()
        return slither
