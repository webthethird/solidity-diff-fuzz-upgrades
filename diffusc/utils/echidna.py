from io import UnsupportedOperation
from os import mkdir, environ
from subprocess import Popen, PIPE, TimeoutExpired

from diffusc.utils.crytic_print import CryticPrint


def create_echidna_process(prefix, filename, contract, config, extra_args):
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


def run_echidna_campaign(proc, rate):
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
        elif "values:" in line:
            value = line.split("values: [")[1].split("],")[0]
            value = int(value)
            if value > max_value:
                max_value = value
                if max_value < 0:
                    CryticPrint.print_information(f"* Reading initial bytecodes and slots..") 
                elif max_value == 0:
                    CryticPrint.print_information(f"* Fuzzing campaign started!") 
                elif max_value > 0:
                    if (rate is None):
                        CryticPrint.print_success(f"* Exploit succefully extracted {max_value} ERC20 tokens!")  
                    else:
                        CryticPrint.print_success(f"* Exploit succefully extracted {max_value} ERC20 tokens with a value of {max_value * rate} USD!") 
                    keep_running = False # Useful for quick CI tests, but it will be removed in production
 
    CryticPrint.print_information(f"* Terminating Echidna campaign!") 
    proc.terminate()
    proc.wait()
    return max_value
