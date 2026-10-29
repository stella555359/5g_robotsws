"""
author: Mathis Rost
Email: mathis.rost.ext@nokia.com
"""

###############################################################################
# ------------------------------------IMPORTS-------------------------------- #
###############################################################################

import sys
import paramiko
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

# important Paths
path_to_config = "/tmp/CRT/testline_configuration"
path_to_SW = "/mnt/etfiles/images/sbts"
path_to_VM = "/home/ute"
path_to_YAFT = "/home/ute/yaft"

# ssh-clinet
user = "toor4nsn"
pw = "oZPS0POrRieRtu"
ip = "192.168.255.129"
port = 443

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())


###############################################################################
# ------------------------------------METHODS-------------------------------- #
###############################################################################


def parse_args():
    parser = argparse.ArgumentParser(
        description="parsing some information about the Software"
    )

    parser.add_argument(
        "--swv", required=True,
        help="Software version to flash the systemmodul"
    )
    args = parser.parse_args()
    return args


# --------------------------------------------------------------------------- #
# --------------------------------------------------------------------------- #


def search_for_SW(files):
    # pattern for SW_version
    pattern_SW = re.compile("(.)*SBTS(.)*_ENB_(.)*.xml")
    for f in files:
        if pattern_SW.fullmatch(f):
            return f[f.find("SBTS"):f.rfind(".")]

    # if no SW was found. This is usually not the case
    print("**********************************")
    print("There is no installed Software on the systemmodul")
    print("**********************************")
    return "NO SOFTWARE INSTALLED!"


###############################################################################
# -----------------------------------EXECUTION------------------------------- #
###############################################################################

# parsing inputs
inputs = parse_args()

# extracting software which shall be installed
SW_version_new = inputs.swv
print("The software which will be installed is: " + SW_version_new)

# getting the path to the desired SW_version
path_to_SW = "/mnt/etfiles/images/sbts/" + SW_version_new

# import help class
installation = Installation(path_to_SW)
print(installation.__string__())

# checking current SW_version
commands = ["ls /ffs/fs1"]
current_SW = ""
try:
    files = installation.ssh_to_SM(commands)
    current_SW = search_for_SW(files)
    print("**********************************")
    print("The currently installed SW-version is: " + current_SW)
    print("**********************************")
except Exception as e:
    print(e)
    print("**************************************")
    print("*Could not connect to the system-modul!*")
    print("**************************************")
    raise Exception("no connection to system-modul")

# check if old SW_version is the new SW_version
if SW_version_new == current_SW:
    print("**********************************")
    print("The selected software is allready isntalled!")
    print("**********************************")
    sys.exit()


try:
    # get newest yaft version"
    installation.init_YAFT()

    # copy SW_version into yaft folder
    installation.transfer_SW(SW_version_new)

    # install the software
    installation.install_SW(SW_version_new)

    # show new SW_version and reboot SM
    commands = ["ls /ffs/stb", "reboot"]
    files = installation.ssh_to_SM(commands)
    new_SW = search_for_SW(files)
    print("**********************************")
    print("The new installed SW-version is: " + new_SW)
    print("**********************************")
    print("Updated from " + current_SW + " to " + new_SW + "!")


except Exception as e:
    print(e)
    print("**********************************")
    print("*The installation failed!*")
    print("**********************************")
    raise Exception("The installation failed")


# remove SW from yaft folder
installation.remove_SW_from_YAFT(SW_version_new)


###############################################################################
# --------------------------------------END---------------------------------- #
###############################################################################
