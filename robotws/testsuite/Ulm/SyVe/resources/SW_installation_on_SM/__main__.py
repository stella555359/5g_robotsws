"""
Description: script to select components of Testlines.
The script will connect via ssh to the selected components
and then starting a installation.
Depending on the selected software the script install_FDSW or
install_SW is executed remotly

Author: Mathis Rost
Email: mathis.rost.ext@nokia.com
"""


###############################################################################
# -----------------------------------IMPORTS--------------------------------- #
###############################################################################

import argparse
import sys
import os
import subprocess
import paramiko

# import from the same package
try:
    sys.path.insert(0, "..")
    from installation import Installation
except ImportError:
    print("The required file 'installation.py' was not found in the dictonary")

try:
    sys.path.insert(0, "..")
    from generate_csv import Edit_table
except ImportError:
    print("The required file 'generate_csv.py' was not found in the dictonary")


###############################################################################
# -----------------------------------VARIABLES------------------------------- #
###############################################################################

# check if FDSW or a SW was selected
global FDSW
FDSW = False

# check if the installation is forced
global force_installation
force_installation = False

# Testline which will be updated
global testline

# location of the script
global path_to_script
path_to_script = ("/tmp/CRT/robotws/testsuite/Ulm/SyVe/"
                  "resources/SW_installation_on_SM")

###############################################################################
# ------------------------------------METHODS-------------------------------- #
###############################################################################

"""
The main Method will execute the script on all modules given by the inputs
The script to update the SW will be sequentially started through ssh
on every VM selected.
"""


def main():
    inputs = parse_args()

    # getting args
    modules = inputs.modules
    SW_version = inputs.swv
    global testline
    testline = inputs.tl
    force_installation = False
    if inputs.f == "true" or inputs.f == "True":
        force_installation = True

    print("**************************************")
    print("Inputs:")
    print("Modules: " + str(modules))
    print("SW: " + SW_version)
    print("TL: " + testline)
    print("Force installation: " + inputs.f)
    print("**************************************")

    # extraction informations about the vms
    installation = Installation("/mnt/etfiles/images")

    (name_VMs,
     ip_VMs,
     user_VMs,
     pw_VMs,
     main_VM_ip) = installation.get_systemcomponents(testline, modules)

    # check if the list of VMs is not empty.
    if len(name_VMs) == 0:
        print("**************************************")
        print("No components where found!")
        print("stopping execution of script.")
        print("**************************************")
        # raising exception
        raise Exception("No valid selected Testlines")

    # print the names of the selected components
    print("**************************************")
    print("the following components where found")
    for name in name_VMs:
        print(name)
    print("**************************************")

    ##################################
    # executing on selected components#
    ##################################
    print("Starting to install the SWs on the selected components")
    executing_on_VMs(
        name_VMs, ip_VMs, user_VMs,
        pw_VMs, main_VM_ip, SW_version,
        force_installation
    )


# --------------------------------------------------------------------------- #
# --------------------------------------------------------------------------- #

"""
Parsing the args!!
the args contain the software-version, modules and the current testline.
"""


def parse_args():
    parser = argparse.ArgumentParser(
        description="parsing some information about the Software"
    )

    parser.add_argument("--swv",
                        help="Software version to flash the systemmodul")

    parser.add_argument("--modules",
                        nargs="*",
                        default=["gNB_0"],
                        help="which GNB and ENB will be flashed")

    parser.add_argument("--tl",
                        help="Specify the testline which shall be updated")

    parser.add_argument("--f",
                        default="false",
                        help="decide if the installation will be forced")

    # parsing the args
    args = parser.parse_args()

    return args

# --------------------------------------------------------------------------- #
# --------------------------------------------------------------------------- #


def executing_on_VMs(
    name_VMs, ip_VMs, user_VMs,
    pw_VMs, main_VM_ip, SW_version,
    force_installation
):
    # check if a FDSW isntallation was selected
    FDSW = False
    if SW_version.startswith("FDSW") or force_installation:
        FDSW = True
        print("**************************************")
        print("A FDSW installation was selected.")
        print("**************************************")
    else:
        print("**************************************")
        print("A normal software-installation was selected")
        print("**************************************")

    # ssh client for VMs
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    # iterating over all selected VMs
    for i in range(len(ip_VMs)):
        # check if the selected VM is the main VM
        if ip_VMs[i] != main_VM_ip:
            print("updating " + name_VMs[i])
            print("connecting to " + ip_VMs[i])

            # putting important files for execution on remote VM
            files_to_copy = [os.path.join(path_to_script, file) for file in
                             ["install_FDSW.py",
                              "install_SW.py",
                              "installation.py"]]
            target = "/tmp"

            # upload files to VM from main-VM
            upload_files(ip_VMs[i], user_VMs[i],
                         pw_VMs[i], files_to_copy, target)

            # transport files via sftp
            print("**************************************")
            print("Putting files on remote VM (" + str(name_VMs[i]) + ")")
            print("**************************************")

            # command to execute on VMs
            # check if FDSW or a normal SW update shall be exectued
            cmd = ""
            if FDSW:
                cmd = (
                    "python /tmp/install_FDSW.py --swv"
                    " " + SW_version + " --f " + str(force_installation)
                )
            else:
                cmd = "python /tmp/install_SW.py --swv " + SW_version

            ssh.connect(
                ip_VMs[i], username=user_VMs[i],
                password=pw_VMs[i], banner_timeout=200
            )

            try:
                # executing command via ssh on the selected VMs
                stdin, stdout, stderr = ssh.exec_command(cmd)
                print("executed " + cmd)
                for line in stdout:
                    print(line[: line.rfind("/n")])

                # get return code
                code = stdout.channel.recv_exit_status()

                # checking return code if everything went ok
                if code == 0:
                    print("**************************************")
                    print("**************************************")
                    print(
                        ("succesfully upgraded softwar on SM of " +
                         str(name_VMs[i]))
                    )
                    print("closing ssh connection")
                    print("**************************************")
                    print("**************************************")

                else:
                    print("An error occured! returncode: ", code)
                    raise Exception("Could not execute the installation")

            except Exception as e:
                # make sure that ssh is closed!
                print(e)
                ssh.exec_command("rm /tmp/install_SW.py")
                ssh.exec_command("rm /tmp/install_FDSW.py")
                ssh.exec_command("rm /tmp/install_SW.py")
                print("closing connection!")
                ssh.close()
                raise Exception(e)

            # deleting temporary files
            print("**************************************")
            print("Deleting files on remote VM (" + str(name_VMs[i]) + ")")
            print("**************************************")

            ssh.exec_command("rm /tmp/install_SW.py")
            ssh.exec_command("rm /tmp/install_FDSW.py")
            ssh.exec_command("rm /tmp/install_SW.py")

            # closing connection
            ssh.close()

        else:

            # command to execute on VM
            # check if FDSW or a normal SW update shall be exectued
            cmd = ""
            if FDSW:
                cmd = (
                    "python " + path_to_script + "/install_FDSW.py --swv"
                    " " + SW_version + " --f " + str(force_installation)
                )
            else:
                cmd = ("python " + path_to_script +
                       "/install_SW.py --swv" " " + SW_version)

            try:
                print("executing script on main node " + str(name_VMs[i]))
                print("executing command: " + cmd)

                # executing command on the main VM
                p = subprocess.Popen(
                    cmd, shell=True, stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT
                )

                # print output of subprocess
                for line in p.stdout.readlines():
                    line = line.decode("utf8")
                    print(line[: line.rfind("/n")])
                p.wait()

                # get returncode of subprocess
                code = p.returncode

                # check if the return code is 0 which means success
                if code == 0:
                    print("**************************************")
                    print("**************************************")
                    print(
                        ("succesfully upgraded softwar on SM of " +
                         str(name_VMs[i]))
                    )
                    print("**************************************")
                    print("**************************************")
                else:
                    # show the returncode
                    print("An error occured! returncode: ", code)
                    raise Exception("Could not execute the installation")

            except Exception as e:
                print("Something went wrong with the execution of the script!")
                print("stopping the execution")
                raise Exception(e)


# --------------------------------------------------------------------------- #
# --------------------------------------------------------------------------- #


def upload_files(ip_address, user, password, files_to_upload, target_dir):
    # connect to server
    ssh = paramiko.Transport(ip_address)
    ssh.connect(username=user, password=password)
    sftp = paramiko.SFTPClient.from_transport(ssh)

    # iterating over files which will be uploaded
    for source_file in files_to_upload:
        _, filename = os.path.split(source_file)
        sftp.put(source_file, target_dir + '/' + filename)

    # close connection
    sftp.close()
    ssh.close()

###############################################################################
# ----------------------------------EXECUTION-------------------------------- #
###############################################################################


main()
