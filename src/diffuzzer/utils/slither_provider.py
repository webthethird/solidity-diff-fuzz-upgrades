import base64
import io
import os

from crytic_compile import CryticCompile
from zipfile import ZipFile
from slither import Slither
from crytic_compile.utils.zip import load_from_zip, save_to_zip
from eth_utils import to_checksum_address, is_address

from diffuzzer.utils.crytic_print import CryticPrint


class SlitherProvider:

    _slither_object: Slither | None
    _address: str
    _network_prefix: str
    _cache_path: str
    _cache_filename: str

    def __init__(self):
        self._slither_object = None
        self._network_prefix = ""
        self._filename = ""
        self._cache_path = f"./crytic-cache/"
        self._cache_filename = ""

    def get_slither_from_address(self, address: str) -> Slither:
        raise NotImplementedError()

    def get_slither_from_filepath(self, path: str) -> Slither:
        raise NotImplementedError()

    def get_network_prefix(self) -> str:
        return self._network_prefix

    def _get_slither_from_cache(self, address: str) -> Slither | None:
        CryticPrint.print_information(f"  * Downloading contract {address}.")

        if os.path.exists(self._cache_path + self._cache_filename):
            CryticPrint.print_success(
                f"    * Contract {self._network_prefix}-{address} found in cache."
            )
            cc = load_from_zip(self._cache_path + self._cache_filename)
            return Slither(cc[0])

    def _save_slither_to_cache(self) -> None:
        if not os.path.exists(self._cache_path):
            os.makedirs(self._cache_path)
        save_to_zip(
            [self._slither_object.crytic_compile],
            self._cache_path + self._cache_filename,
        )

        CryticPrint.print_success(
            f"      * Contract {self._cache_filename[:-4]} obtained and cached."
        )

    def _check_address(self, address: str) -> str:
        if not is_address(address):
            raise ValueError("Invalid address supplied")

        return to_checksum_address(address)


class NetworkSlitherProvider(SlitherProvider):
    def __init__(self, network_prefix: str, api_key: str):
        super().__init__()
        self._api_key = api_key
        self._network_prefix = network_prefix
        if self._network_prefix[-1] == ":":
            self._network_prefix = self._network_prefix[:-1]

    def get_slither_from_address(self, address: str) -> Slither:

        self._address = self._check_address(address)
        self._cache_filename = f"{self._network_prefix}-{address}.zip"

        s = self._get_slither_from_cache(address)

        if s is not None:
            self._slither_object = s
            return s
        else:
            s = Slither(
                f"{self._network_prefix}:{address}", bscan_api_key=self._api_key
            )
            self._slither_object = s
            self._save_slither_to_cache()
            return s


class FileSlitherProvider(SlitherProvider):
    def __init__(self):
        super().__init__()
        self._network_prefix = "testnet"

    def get_slither_from_filepath(self, path: str) -> Slither:

        self._filename = path.rsplit(os.path.sep, maxsplit=1)[1].replace(".sol", "")
        self._cache_filename = f"{self._network_prefix}={self._filename}.zip"

        s = self._get_slither_from_cache(self._filename)

        if s is not None:
            self._slither_object = s
            return s
        else:
            s = Slither(path)
            self._slither_object = s
            self._save_slither_to_cache()
            return s


class SlitherbotSlitherProvider(SlitherProvider):

    _slitherbot_path: str

    def __init__(self, slitherbot_path: str):
        super().__init__()
        self._network_prefix = "mainet"
        self._slitherbot_path = slitherbot_path

        if self._slitherbot_path[-1] != "/":
            self._slitherbot_path = f"{self._slitherbot_path}/"
        self._slitherbot_path = f"{self._slitherbot_path}contracts/"

        if not os.path.exists(self._slitherbot_path):
            CryticPrint.print_error(f"Slitherbot contracts not found in provided path")
            raise NotADirectoryError("Slitherbot contracts not found in provided path")

    def _get_slither_from_slitherbot_cache(self) -> Slither:

        dir = self._slitherbot_path
        for c in self._address[2:8].lower():
            dir += f"{c}/"
        path = dir + self._address.lower() + "/"
        filename = path + "artifact.zip.base64"

        if not os.path.exists(path):
            CryticPrint.print_error(f"Contract not found on slitherbot cache")
            raise ValueError("Contract not found on slitherbot cache")

        # Decode the base64 artifact
        artifact = open(filename)
        data = artifact.read()
        artifact.close()
        data_decoded = base64.b64decode(data)

        # Read the zip file containing the CC json
        with ZipFile(io.BytesIO(data_decoded)) as zip_file:
            for zipinfo in zip_file.infolist():
                if zipinfo.filename[-4:] == "json":
                    with zip_file.open(zipinfo) as json_file:
                        json_contents = json_file.read().decode("utf8")
                    break

        cc = CryticCompile(json_contents, compile_force_framework="Archive")
        return Slither(cc)

    def get_slither_from_address(self, address: str) -> Slither:

        self._address = self._check_address(address)
        self._cache_filename = f"{self._network_prefix}-{address}.zip"

        s = self._get_slither_from_cache(address)

        if s is not None:
            self._slither_object = s
            return s
        else:
            s = self._get_slither_from_slitherbot_cache()
            self._slither_object = s
            self._save_slither_to_cache()
            return s
