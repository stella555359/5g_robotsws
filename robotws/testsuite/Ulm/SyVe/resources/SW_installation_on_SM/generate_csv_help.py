###############################################################################
# ------------------------------------IMPORTS-------------------------------- #
###############################################################################

import sys
import argparse
import re

try:
    sys.path.insert(0, "..")
    from installation import Installation
except ImportError:
    print("The required file 'installation.py' was not found in the dictonary")


###############################################################################
# -----------------------------------VARIABLES------------------------------- #
###############################################################################

cmd_1 = "mkdir /ffs/fs3"
cmd_2 = "mount /dev/sda3 /ffs/fs3"
cmd_3 = "ls /ffs/fs3"
cmd_4 = "umount /ffs/fs3"


comms_FDSW = [cmd_1, cmd_2, cmd_3]
comms_SW = ["ls /ffs/stb"]

installation = Installation(".")

# --------------------------------------------------------------------------- #
# --------------------------------------------------------------------------- #


def parse_args():
    parser = argparse.ArgumentParser(
        description="parsing some information about the Software"
    )

    parser.add_argument(
        "--version", help="FDSW: get FDSW-version and SW: get SW_version"
    )

    # parsing the args
    args = parser.parse_args()

    return args


###############################################################################
# ----------------------------------EXECUTION-------------------------------- #
###############################################################################

# getting args
inputs = parse_args()
version = inputs.version

# patterns
pattern_FDSW = re.compile("(.)*FDSW(.)*_([0-9])*_([0-9])*_([0-9])*(.)*")
pattern_SW = re.compile("(.)*SBTS(.)*_ENB_(.)*.xml")

# SW_Version
SW_version = "-"

if version == "FDSW":
    files = installation.ssh_to_SM(comms_FDSW)

    # iterating over all files
    for f in files:
        if pattern_FDSW.fullmatch(f):
            SW_version = f[f.find("FDSW"): f.find(".")]


if version == "SW":
    files = installation.ssh_to_SM(comms_SW)

    # iterating over all files
    for f in files:
        if pattern_SW.fullmatch(f):
            SW_version = f[f.find("SBTS"): f.find(".")]

# return
print(SW_version)
sys.stdout.write("current SW on SM: " + SW_version)
sys.stdout.flush()
