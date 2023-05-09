import os
import logging
from subprocess import Popen, PIPE

from solc_select.solc_select import (
    switch_global_version,
    installed_versions,
    get_installable_versions,
)
from diffusc.utils.helpers import get_pragma_version_from_file
from diffusc.utils.crytic_print import CryticPrint


def mutate_contract(file_path: str, output_path: str = "./mutants/", version: str = "") -> str:
    try:
        os.mkdir(output_path)
    except OSError:
        os.rmdir(output_path)
        os.mkdir(output_path)

    file_name: str = file_path.rsplit(os.sep, maxsplit=1)[1]
    CryticPrint.print_information(f"* Mutating {file_name}...")

    # Silence universalmutator
    # logging.getLogger("universalmutator").setLevel(logging.CRITICAL)

    if version == "":
        version = get_pragma_version_from_file(file_path)
    if version in installed_versions() or version in get_installable_versions():
        switch_global_version(version, True)

    call = ["timeout", "180s", "mutate"]
    call.extend([file_path])
    call.extend(["solidity", "solidity.rules", "universal.rules", "c_like.rules"])
    # call.extend(["--cmd", "solc MUTANT"])     # Trying to compile mutant fails if tmp file not in same dir as imports
    call.extend(["--mutantDir", output_path])

    CryticPrint.print_information(f"  * Generating mutants with {' '.join(call)}")
    proc = Popen(call, stderr=PIPE, stdout=PIPE, bufsize=0, universal_newlines=True)
    proc.wait()

    num_mutants = len(os.listdir(output_path))
    CryticPrint.print_information(f"  * Generated {num_mutants} mutants.")
