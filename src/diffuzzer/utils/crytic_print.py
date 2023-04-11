from slither.core.declarations.enum import Enum
from colorama import Fore, Style, init as colorama_init


class PrintMode(Enum):
    MESSAGE = 0
    SUCCESS = 1
    INFORMATION = 2
    WARNING = 3
    ERROR = 4


class CryticPrint:
    @staticmethod
    def initialize() -> None:
        colorama_init()

    @staticmethod
    def print(mode: PrintMode, message: str) -> None:
        if mode is PrintMode.MESSAGE:
            CryticPrint.print_message(message)
        elif mode is PrintMode.SUCCESS:
            CryticPrint.print_success(message)
        elif mode is PrintMode.INFORMATION:
            CryticPrint.print_information(message)
        elif mode is PrintMode.WARNING:
            CryticPrint.print_warning(message)
        elif mode is PrintMode.ERROR:
            CryticPrint.print_error(message)

    @staticmethod
    def print_message(message: str) -> None:
        print(Style.BRIGHT + Fore.LIGHTBLUE_EX + message + Style.RESET_ALL)

    @staticmethod
    def print_success(message: str) -> None:
        print(Fore.LIGHTGREEN_EX + message + Style.RESET_ALL)

    @staticmethod
    def print_information(message: str) -> None:
        print(Fore.LIGHTCYAN_EX + message + Style.RESET_ALL)

    @staticmethod
    def print_warning(message: str) -> None:
        print(Fore.LIGHTYELLOW_EX + message + Style.RESET_ALL)

    @staticmethod
    def print_error(message: str) -> None:
        print(Style.BRIGHT + Fore.LIGHTRED_EX + message + Style.RESET_ALL)
