"""
This class has methods which are used by "install_SW.py" and "install_FDSW.py"

author: Mathis Rost
Email: mathis.rost.ext@nokia.com
"""


###############################################################################
# ------------------------------------IMPORTS-------------------------------- #
###############################################################################

import os
import paramiko
import importlib.util
import sys
import time
import re

try:
    import pexpect
except ImportError:
    os.system("pip install pexpect")
    import pexpect


class Installation:
    ###########################################################################
    # ----------------------------CLASS-VARIABLES---------------------------- #
    ###########################################################################

    # important paths
    path_to_config = "/tmp/CRT/testline_configuration"
    path_to_SW = "/mnt/etfiles/images"
    path_to_VM = "/home/ute"
    path_to_YAFT = "/home/ute/yaft"

    # ssh details for SM
    user = "toor4nsn"
    pw = "oZPS0POrRieRtu"
    ip = "192.168.255.129"
    port = 443

    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    ###########################################################################
    # -----------------------------CLASS-METHODS----------------------------- #
    ###########################################################################

    def __init__(self, path_to_SW):
        self.path_to_SW = path_to_SW

    # ----------------------------------------------------------------------- #
    # ----------------------------------------------------------------------- #

    def __string__(self):
        return f"{self.path_to_SW}"

    # ----------------------------------------------------------------------- #
    # ----------------------------------------------------------------------- #
    """
    get the ip adresses, pws, usernames of the remaining VMs.
    For the selected VMs the script will be started on the VM of gNB_0
    howoever we want to update it on all selected components
    This is done by importing the init file of the testline
    """

    def get_systemcomponents(self, testline, modules):

        # information about VMS
        name_VMs = []
        ip_VMs = []
        user_VMs = []
        pw_VMs = []

        path_to_config = "/tmp/CRT/testline_configuration"
        # set system path to config_data
        sys.path.append(path_to_config)
        # import testlines
        try:
            tl = importlib.import_module(testline)
            print("imported " + f"{tl}")
            print("extracting informations!")
        except Exception as e:
            print(e)
            print("Testline was not found")

        # selecting the required VMs
        selected_modules = []
        selected_modules_names = []

        for i in range(len(modules)):
            if modules[i] == "all":
                selected_modules = tl.tl.gnbs + tl.tl.enbs

                # saving names of the modules
                for i in range(len(tl.tl.gnbs)):
                    selected_modules_names.append("gNB_" + str(i))
                for i in range(len(tl.tl.enbs)):
                    selected_modules_names.append("eNB_" + str(i))

                print("all modules are selected")
                break

            elif modules[i] == "gNB_0":
                selected_modules.append(tl.tl.gnbs[0])
                selected_modules_names.append(modules[i])

            # check if the testline has more than 1 gNB
            elif modules[i] == "gNB_1":
                if len(tl.tl.gnbs) > 1:
                    selected_modules.append(tl.tl.gnbs[1])
                    selected_modules_names.append(modules[i])
                else:
                    print(("the selected " + modules[i] +
                          " does not exist on this TL"))
                    print("continue with selected modules")

            elif modules[i] == "eNB_0":
                selected_modules.append(tl.tl.enbs[0])
                selected_modules_names.append(modules[i])

            # check if the testline has more than 1 eNB
            elif modules[i] == "eNB_1":
                if len(tl.tl.enbs) > 1:
                    selected_modules.append(tl.tl.enbs[1])
                    selected_modules_names.append(modules[i])
                else:
                    print(("the selected " + modules[i] +
                          " does not exist on this TL"))
                    print("continue with selected modules")

            else:
                print("the module " + modules[i] + " is not a valid entry!")
                print("continue with valid entries")

        # extracting the information about the VMs
        for i in range(len(tl.tl.test_pcs)):
            if tl.tl.test_pcs[i].connections[0] in selected_modules:
                j = selected_modules.index(tl.tl.test_pcs[i].connections[0])

                name_VMs.append(selected_modules_names[j])

                ip_VMs.append(
                    str(tl.tl.test_pcs[i].default_ssh_connection_details.addr)
                )

                user_VMs.append(
                    str(tl.tl.test_pcs[i]
                        .default_ssh_connection_details.username)
                )

                pw_VMs.append(
                    str(tl.tl.test_pc.default_ssh_connection_details.password)
                )

        # getting the main VM
        main_VM_ip = f"{tl.tl.test_pc.default_ssh_connection_details.addr}"
        print("The main test_pc can be reached under " + main_VM_ip)

        return name_VMs, ip_VMs, user_VMs, pw_VMs, main_VM_ip

    # ----------------------------------------------------------------------- #
    # ----------------------------------------------------------------------- #

    """
    Executing commands via ssh on System modul
    Selecting all files which are found in a dictonary via ssh
    """

    def ssh_to_SM(self, commands):
        # Files where the softwareversion will be stored
        Files = []

        # creating ssh_connection
        self.ssh.connect(
            self.ip, username=self.user, password=self.pw, banner_timeout=200
        )

        try:
            for cmd in commands:
                # execute commands HERE
                stdin, stdout, stderr = self.ssh.exec_command(cmd)
                print("executed " + cmd)
                time.sleep(0.1)

                # if 'ls' then return th files in listed dict.
                if cmd == "ls" or cmd.startswith("ls"):
                    for line in stdout:
                        Files.append(line[: line.rfind("/n")])

        except Exception as e:
            print(e)
            raise Exception("Something went wrong with the SSH_connection")
            self.ssh.close()

        # closing the connection
        self.ssh.close()

        # returning the selected files
        return Files

    # ----------------------------------------------------------------------- #
    # ----------------------------------------------------------------------- #
    """
    getting the newest Yaft version on the VM.
    If Yaft is allready on the VM then the repository will be pulled
    """

    def init_YAFT(self):
        # boolean to check if yaft up-to-date
        yaft_allready_func = False

        # check if a yaft repository is allready on th VM
        files = os.listdir(self.path_to_VM)
        if "yaft" in files:
            # try to pull newest yaft verion.
            try:
                self.path_to_YAFT = self.path_to_VM + "/yaft"
                print("yaft repository was found!")
                print("executing: git -C " + self.path_to_YAFT + " pull")
                os.chdir(self.path_to_YAFT)
                os.system("git -C " + self.path_to_YAFT + " pull")
                time.sleep(2)
                print("**********************************")
                print("pulled yaft repository!")
                print("**********************************")
                yaft_allready_func = True

            except Exception:
                print("could not pull repository! " +
                      "Trying a different approach.")
                yaft_allready_func = False

        # no yaft repository was found
        # trying to copy the mounted version
        if not yaft_allready_func:
            print("YAFT folder not found /home/ute")
            print("copy YAFT folder ...")
            time.sleep(2)
            try:
                os.system("cp -r /mnt/etfiles/users/yaft /home/ute")
                print("execute: cp -r /mnt/etfiles/users/yaft /home/ute")
                time.sleep(2)
                print("**********************************")
                print("copied yaft dictonary!")
                print("**********************************")

            except Exception as e:
                print(e)
                print("**********************************")
                print("Could not initialize yaft!")
                print("**********************************")
                raise Exception("The yaft initialisiation went wrong!")

    # ----------------------------------------------------------------------- #
    # ----------------------------------------------------------------------- #

    def transfer_SW(self, SW_version):
        print("checking " + self.path_to_SW + " for zip-file of " + SW_version)
        try:
            files = os.listdir(self.path_to_SW)
        except Exception:
            files = []

        # patterns for downloadable zip
        pattern_SW = re.compile("(.)*" + SW_version +
                                "(.)*downloadable(.)*zip")

        # boolean for checking if the moving was successfull
        software_moved = False

        # checking if the desired SW is allready downloaded
        for f in files:
            if pattern_SW.fullmatch(f):
                try:
                    print("**********************************")
                    print("moving the SW-file.")
                    print("**********************************")

                    # command for copy file
                    command = (
                        "cp " + self.path_to_SW + "/" + f +
                        " " + self.path_to_YAFT
                    )
                    r = os.system(command)

                    # check return code
                    if r == 0:
                        software_moved = True

                except Exception as e:
                    print("Could not move SW-file!")
                    print("path to SW might be wrong!")
                    print(e)
                    print("stopping execution!")
                    raise Exception("could not move SW-file")
                break

        # the software needs to be downloaded manually
        if not software_moved:
            print("**********************************")
            print("The desired file is not contained in the dictonary!!!")
            print("Can not finish the job!")
            print("You might have to download the SW manually.")
            print("Visit https://wft.int.net.nokia.com/builds.")
            print("for FDSW: https://wft.int.net.nokia.com/FDSW/builds")
            print("Download newest version of :" + SW_version)
            print("Put it into " + self.path_to_SW)
            print("**********************************")

            # raising exeption
            raise Exception(
                "The selected Software was not found at //10.47.68.222/images."
            )

    # ----------------------------------------------------------------------- #
    # ----------------------------------------------------------------------- #

    def install_SW(self, SW_version):
        # install paramiko
        print("**********************************")
        print("Installing newest paramiko version")
        print("**********************************")
        os.system("python3 -m pip install paramiko")

        SW_zip = ""
        FDSW = False

        # getting the allready downloaded SW-version
        os.chdir(self.path_to_YAFT)
        Files = os.listdir(self.path_to_YAFT)

        # checking for SW in yaft folder
        pattern_SW = re.compile("(.)*" + SW_version +
                                "(.)*downloadable(.)*zip")

        for f in Files:
            if pattern_SW.fullmatch(f):
                print("found SW: ", f)
                SW_zip = f
                break

        # checking of SW_version was found
        if SW_zip == "":
            print("**********************************")
            print("the correct software was not found")
            print(
                (
                    "This can be fixed, by adding " +
                    SW_version +
                    " manually to the path " +
                    self.path_to_YAFT
                )
            )
            print("and then rerunning the job")
            print("the programm will now terminate")
            print("**********************************")

            raise Exception("no Software in yaft dictonary was found")

        # check if normal SW or FDSW was found
        if "FDSW" in SW_zip:
            FDSW = True
        else:
            FDSW = False

        # install Software
        os.chdir(self.path_to_YAFT)
        cmd = ""
        if FDSW:
            cmd = (
                "python3 " +
                self.path_to_YAFT +
                "/yaft.py --ask_for_password -i 192.168.255.129 "
                "--ignore_FSPs --clean_to_default "
                "--flash_failsafe_partition "
                "-R -z " + SW_zip
            )
        else:
            cmd = (
                "python3 " +
                self.path_to_YAFT +
                "/yaft.py --ask_for_password -i 192.168.255.129 "
                "--ignore_FSPs --clean_to_default -R -z " + SW_zip
            )

        try:
            print("the software will now be installed: ")
            print("executing " + cmd)
            time.sleep(3)

            # entering password if its required. Timeout 5 min
            child = pexpect.spawn(cmd, encoding="utf-8", timeout=300)
            child.logfile_read = sys.stdout

            child.expect("Password:")
            child.sendline(self.pw + "\n")

            # child.close()
            child.expect(pexpect.EOF)

            time.sleep(3)
        except Exception as e:
            if type(e) is pexpect.exceptions.EOF:
                print("**********************************")
                print("flashing is done, everything worked correctly!!!")
                print("**********************************")
            else:
                print("**********************************")
                print("something went wrong!!!")
                print("the program will now be terminated")
                print(
                    (
                        "to trigger the job again you might have to "
                        "remove /tmp/YAFT_lock on the System-modul"
                    )
                )
                print(
                    (
                        " This might be a yaft issue!"
                        " Please check yaft.log at " +
                        self.path_to_YAFT + "/log."
                    )
                )
                print("**********************************")
                raise Exception(
                    "The installation on the system-module failed."
                )

    # ----------------------------------------------------------------------- #
    # ----------------------------------------------------------------------- #

    def remove_SW_from_YAFT(self, SW_version_new):
        Files = os.listdir(self.path_to_YAFT)
        pattern = re.compile("(.)*" + SW_version_new + "*(.)*zip")

        # serching for .zip file in Yaft folder and removing it
        for f in Files:
            if pattern.fullmatch(f):
                print("remove " + SW_version_new +
                      " from " + self.path_to_YAFT)
                os.system("rm " + self.path_to_YAFT + "/" + f)


###############################################################################
# --------------------------------------END---------------------------------- #
###############################################################################
