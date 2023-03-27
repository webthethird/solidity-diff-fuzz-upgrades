import os
from slither.core.declarations.enum import Enum
from colorama import Back, Fore, Style

class PrintMode(Enum):
    MESSAGE = 0
    SUCCESS = 1
    INFORMATION = 2
    WARNING = 3
    ERROR = 4


def crytic_print(mode, message) -> None:
    if mode is PrintMode.MESSAGE:
        print(Style.BRIGHT + Fore.LIGHTBLUE_EX + message + Style.RESET_ALL)
    elif mode is PrintMode.SUCCESS:
        print(Fore.LIGHTGREEN_EX + message + Style.RESET_ALL)
    elif mode is PrintMode.INFORMATION:
        print(Fore.LIGHTCYAN_EX + message + Style.RESET_ALL)
    elif mode is PrintMode.WARNING:
        print(Fore.LIGHTYELLOW_EX + message + Style.RESET_ALL)
    elif mode is PrintMode.ERROR:
        print(Style.BRIGHT + Fore.LIGHTRED_EX + message + Style.RESET_ALL)
