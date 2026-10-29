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
path_to_FDSW = "/mnt/etfiles/images/FDSW"
path_to_help_script = "./product_info.py"
path_to_VM = "/home/ute"
path_to_YAFT = "/home/ute/yaft"

# commands for the System-modul

cmd_1 = "mkdir /ffs/fs3"
cmd_2 = "mount /dev/sda3 /ffs/fs3"
cmd_3 = "ls /ffs/fs3"
cmd_4 = "umount /ffs/fs3"
cmd_5 = "rm -r /ffs/fs3"
cmd_6 = "reboot"

comms_SM = [cmd_1, cmd_2, cmd_3]
comms_SM_reboot = [cmd_3, cmd_4, cmd_5, cmd_6]


# ssh-client
user = "toor4nsn"
pw = "oZPS0POrRieRtu"
ip = "192.168.255.129"
port = 443

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())


###############################################################################
# ------------------------------------METHODS-------------------------------- #
###############################################################################
"""
search for a FDSW software_version in a dictonary.
"""


def search_for_SW(files):
    # pattern for SW_version
    pattern_SW = re.compile("(.)*FDSW(.)*_([0-9])*_([0-9])*_([0-9])*(.)*")
    for f in files:
        if pattern_SW.fullmatch(f):
            return f[f.find("FDSW"):f.rfind(".")]

    # the installed sogtware might only contain ASIA, ASIL, ...
        pattern_SW = re.compile(("(.)*FDSW(.)*_A([A-Z])*_([0-9])*_"
                                 "([0-9])*_([0-9])*(.)*"))
    for f in files:
        if pattern_SW.fullmatch(f):
            return f[f.find("FDSW"):f.rfind(".")]

    # if no SW was found. The installation can still proceed.
    # This is usually not the case
    print("**********************************")
    print("There is no installed Software on the systemmodul")
    print("**********************************")
    return "NO SOFTWARE INSTALLED!"


# --------------------------------------------------------------------------- #
# --------------------------------------------------------------------------- #
"""
we need to extract the Branch and the type of the FDSW
in case that a new version shall be downloaded.
"""


def get_version_information(old_version):
    # getting the Branch
    branch = old_version[old_version.find("FDSW"):old_version.find("_")]
    a = old_version.find("_") + 1
    b = old_version.find("_") + 5
    module_type = old_version[a:b]
    print("**********************************")
    print("The branch is: " + branch)
    print("**********************************")

    if module_type[0] == "A":
        print("The modul_type is: " + module_type)
    else:
        module_type = ""

    return branch, module_type


# --------------------------------------------------------------------------- #
# --------------------------------------------------------------------------- #
"""
compare the old and new software version.
it's important that the new FDSW is a newer version of the old FDSW.
"""


def valid_FDSW_version(old_version, new_version):

    # check if old version is new version. If true stop execution
    if old_version == new_version:
        print("**********************************")
        print("The selected software is allready installed!")
        print("**********************************")
        return False

    # check if the selcected FDSW has desired properties
    if "FDSW" not in new_version:
        print("**********************************")
        print("The software-version entered is not a valid FDSW!")
        print("**********************************")
        return False

    # comparing if only change in FDSW[22B1]_ASIL_0000_[000046]_000000
    print("checking if new and old version are simular")
    string_help_old = old_version[9:-14] + old_version[-6:]
    string_help_new = new_version[9:-14] + new_version[-6:]

    if string_help_new == string_help_old:
        print("**********************************")
        print("entered valid FDSW for update")
        print("**********************************")
        return True

    else:
        print("**********************************")
        print("The software-version entered is not valid for this Component!")
        print("New version :" + new_version + " ,Old version: " + old_version)
        print(
            (
                "If you still want to install"
                " " + new_version + "select force_installation"
            )
        )
        print("**********************************")
        return False


# --------------------------------------------------------------------------- #
# --------------------------------------------------------------------------- #
"""
this method is not mandatory.
- We want to check if everything worked correctly
- check the version of the new installed FDSW
- umount the fs3 dictonary
- reboot the system
"""


def finish_execution():
    print("searching for new installed Software")
    print("The system will be rebooted")

    # don't remove ffs/ffs3 beacause of safty reasons
    cmd_1 = "ls /ffs/fs3"
    cmd_2 = "umount /ffs/fs3"
    cmd_3 = "reboot"
    commands = [cmd_1, cmd_2, cmd_3]

    # executing commands and get the new FDSW version
    files = installation.ssh_to_SM(commands)
    new_version = search_for_SW(files)

    print("**************************************")
    print("the new installed FDSW is: " + new_version)
    print("**************************************")


# --------------------------------------------------------------------------- #
# --------------------------------------------------------------------------- #

"""
input the Software which will be updated
this parameter is usually given by Jenkins
"""


def parse_args():
    parser = argparse.ArgumentParser(
        description="parsing some information about the Software"
    )

    parser.add_argument(
        "--swv", required=True,
        help="Software version to flash the systemmodul"
    )

    parser.add_argument(
        "--f", default=False, help="decide if the installation will be forced"
    )

    args = parser.parse_args()
    return args


###############################################################################
# -----------------------------------EXECUTION------------------------------- #
###############################################################################

# parsing inputs
inputs = parse_args()

# extracting software which shall be installed
FDSW_version_new = inputs.swv
print("**************************************")
print("The software which will be installed is: " + FDSW_version_new)
print("**************************************")

# check if the installation should be forced
force_installation = False
if inputs.f == "True" or inputs.f == "true":
    force_installation = True

# import help class
installation = Installation(path_to_FDSW)

# get information about version
get_version_information(FDSW_version_new)

# getting old software and preparing installation
try:
    files = installation.ssh_to_SM(comms_SM)
    current_SW = search_for_SW(files)
    print("**************************************")
    print("the current installed FDSW is: " + current_SW)
    print("**************************************")
except Exception as e:
    print("**************************************")
    print("*Could not connect to the system-modul!*")
    print("**************************************")
    print(e)
    raise Exception("no connection to system-modul")


# comparing old and new SW_version and make sure the correct SW was selected
if valid_FDSW_version(current_SW, FDSW_version_new) or force_installation:
    try:
        # getting newest Yaft version
        installation.init_YAFT()

        # transfer FDSW to YAFT-dictonary
        installation.transfer_SW(FDSW_version_new)

        # installing the FDSW on the SM
        installation.install_SW(FDSW_version_new)

        # umount and rebooot
        finish_execution()

        # remove transfered FDSW form yaft folder
        installation.remove_SW_from_YAFT(FDSW_version_new)

    except Exception as e:
        print(e)
        print("**************************")
        print("*The installation failed!*")
        print("**************************")

        # umount the FDSW partition
        print("reversing commands on SM")
        installation.ssh_to_SM(["umount /ffs/fs3"])
        raise Exception("could not install the software!")


else:
    # umount the FDSW partition
    print("reversing commands on SM")
    installation.ssh_to_SM(["umount /ffs/fs3"])
    raise Exception("No valid FDSW was entered for this system-module")


###############################################################################
# --------------------------------------END---------------------------------- #
###############################################################################
