from io import UnsupportedOperation
from os import mkdir, environ
from subprocess import Popen, PIPE, TimeoutExpired
from typing import List

from diffusc.utils.crytic_print import CryticPrint


def create_echidna_process(prefix: str, filename: str, contract: str, config: str, extra_args: List[str]) -> Popen:
    try:
        mkdir(prefix)
    except OSError:
        pass
    
    call = ["echidna"]
    call.extend([filename])
    call.extend(["--config", config])
    call.extend(["--contract", contract])
    call.extend(extra_args)
    CryticPrint.print_information(f"* Calling echidna from {prefix} using {' '.join(call)}")
    env = environ.copy()
    return Popen(call, stderr=PIPE, stdout=PIPE, bufsize=0, cwd=prefix, universal_newlines=True) #cwd=os.path.abspath(prefix)),


def run_echidna_campaign(proc: Popen, min_tests: int = 1) -> int:
    keep_running = True
    max_value = float("-inf")
    while keep_running:
        line = ""
        try: 
            line = proc.stdout.readline()
            print(line.strip())
        except UnsupportedOperation:
            pass
        if line == "":
            keep_running = proc.poll() is None
        elif "tests:" in line:
            tests = line.split("tests: ")[1].split("/")[0]
            tests = int(tests)
            fuzzes = line.split("fuzzing: ")[1].split("/")[0]
            fuzzes = int(fuzzes)
            if tests > max_value:
                max_value = tests
                if fuzzes == 0:
                    CryticPrint.print_information(f"* Reading initial bytecodes and slots..") 
                elif fuzzes > 0:
                    CryticPrint.print_information(f"* Fuzzing campaign started!") 
                if max_value >= min_tests:
                    CryticPrint.print_success(f"* Failed {max_value} tests after {fuzzes} rounds of fuzzing!")
                    keep_running = False    # Useful for quick CI tests, but it will be removed in production
 
    CryticPrint.print_information(f"* Terminating Echidna campaign!") 
    proc.terminate()
    proc.wait()
    return max_value
