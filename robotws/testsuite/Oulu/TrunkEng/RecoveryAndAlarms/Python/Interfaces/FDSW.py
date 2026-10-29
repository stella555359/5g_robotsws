"""
:author: Essi Passoja
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import re
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error, warning
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (EnvironmentIssue, ScriptIssue)
from testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Resources.exceptions import UnexpectedPartitionActive, BTSSwIssue


class FDSW:

    asim = False

    def __init__(self):
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.scf = BuiltIn().get_library_instance("SCF")
        self.ssh = BuiltIn().get_library_instance("SSH")
        self.swconfig = BuiltIn().get_library_instance("SWCONFIG")
        self.fdsw_meta_set = False

    def check_fd_sw(self):
        """
        Check FD SW checks if fd sw checks if Factory Delivery SW was installed into the 3rd partition, mounts fs3
        partition and prints FDSW version, checks that there is no FD SW software in /ffs/fs1 or in /ffs/fs2, gets
         active partition and collects swconfig.txt file to control PC.
        """

        self.check_if_fd_sw_active()
        self.print_fd_sw_version()
        self.check_active_partition(fd_sw_not_in_fs1_or_fs2=True)
        self.check_active_partition()
        self.swconfig.collect_swconfig(local_path="/tmp")

    def _set_fdsw_metadata(self, output=""):
        """
        Set FDSW metadata sets Factory Delivery SW version to log.html.

        :param str output: Output of command to get Factory Delivery SW version.
        """
        if not output:
            output = self.ssh.send_command_to_ip_return_output("ls -lah /ffs/fs3", "BTS")
        fdsw_pattern = re.compile(r"TargetBD_.*_(?P<sw>FDSW.*)\.xml")
        match = fdsw_pattern.search(output)
        if match:
            fd_sw = match.group("sw")
            info(f"Factory Delivery SW version: {fd_sw}")
            BuiltIn().set_suite_metadata("FD SW Version", fd_sw, top=True)
            self.fdsw_meta_set = True
        else:
            info("Factory Delivery SW version was not found from output of ls -lah /ffs/fs3. It will be check and set "
                 "later to log.html in method check_partition_and_sw")

    def check_if_fd_sw_active(self):
        """Check if FD SW active checks if there is FDSW installed to third partition. If not, raise error."""
        info("Active SW: {}".format(self.bts.active_sw))
        info("Passive SW: {}".format(self.bts.passive_sw))
        output = self.ssh.send_command_to_ip_return_output("cat /proc/partitions", "BTS")
        if output:
            if "sda3" not in output:
                # check if ASIM in question
                output2 = self.ssh.send_command_to_ip_return_output("fdisk -l", "BTS")
                if "/dev/mmcblk0p3" not in output2:
                    error("sda3 was not found from /proc/partitions and /dev/mmcblk0p3 was not found from "
                          "output of fdisk -l. Factory Delivery SW was NOT installed into the 3rd partition, unable "
                          "to run this test and run Failsafe boot. Test environment issue.")
                    raise EnvironmentIssue
                else:
                    info("Factory Delivery SW was installed into the 3rd partition and Failsafe boot will "
                         "be possible (/dev/mmcblk0p3 was found from output of fdisk -l)")
                    FDSW.asim = True
            else:
                info("Factory Delivery SW was installed into the 3rd partition and Failsafe boot will "
                     "be possible (sda3 was found from /proc/partitions)")
        else:
            error("No output of SSH get. Check that SSH is enabled in your test environment. "
                  "Cannot run this test without SSH connection to FCT.")
            raise EnvironmentIssue

    def print_fd_sw_version(self, retry=0):
        """Print fd sw version"""
        self.ssh.send_command_to_ip_return_output("mkdir /ffs/fs3", "BTS")
        if FDSW.asim:
            mount_output = self.ssh.send_command_to_ip_return_output("mount /dev/mmcblk0p3 /ffs/fs3", "BTS")
        else:
            mount_output = self.ssh.send_command_to_ip_return_output("mount /dev/sda3 /ffs/fs3", "BTS")
        if mount_output:
            if "already mounted or mount point busy" in mount_output:
                if retry < 3:
                    ls_ffs_output = self.ssh.send_command_to_ip_return_output("ls -lah /ffs/ -w 160", "BTS")
                    if "fs3" in ls_ffs_output:
                        info("Partition fs3 is found from the /ffs -> fs3 is already mounted.")
                        if not self.fdsw_meta_set:
                            self._set_fdsw_metadata()
                        return
                    else:
                        info("Mount point was busy, wait 60s and retrying to mount /ffs/fs3")
                        BuiltIn().sleep("60s")
                        self.print_fd_sw_version(retry=retry+1)
                else:
                    error("Mount point was busy, tried to mount /ffs/fs3 3 times, unable to mount /ffs/fs3.")
        output = self.ssh.send_command_to_ip_return_output("ls -all /ffs/fs3", "BTS")
        info(output)
        if not self.fdsw_meta_set:
            self._set_fdsw_metadata(output)

    def check_active_partition(self, fsm="192.168.255.129", fd_sw_not_in_fs1_or_fs2=False, expected_partition=""):
        """
        Check active partition. Gets active partition and checks if there is FDSW software on fs1 or fs2 and checks
        if given partition is expected partition. If expected partition is not given, only active partition is checked.

        :param str fsm: FSM IP address, default is 192.168.255.129
        :param bool fd_sw_not_in_fs1_or_fs2: If True checks if there is FD SW software in /ffs/fs1 or in /ffs/fs2
        :param str expected_partition: Expected partition, if not given only active partition is checked
        """
        re_active_partition = re.compile(r".*run.*\s+->\s+/ffs/(?P<active_partition>.*)")
        active_partition = ""
        if fd_sw_not_in_fs1_or_fs2:
            info("Check that there is no FD SW software in /ffs/fs1 or in /ffs/fs2")
            fs1_output = self.ssh.send_command_to_ip_return_output("ls /ffs/fs1|grep TargetBD", "BTS")
            fs2_output = self.ssh.send_command_to_ip_return_output("ls /ffs/fs2|grep TargetBD", "BTS")
            if fs1_output and fs2_output:
                fs1_target_bds = fs1_output.split("\n")
                fs2_target_bds = fs2_output.split("\n")
                if any(i for i in fs1_target_bds if "FDSW" in i):
                    error("There is FDSW in fs1 -> preconditions, NOK")
                    raise EnvironmentIssue
                if any(i for i in fs2_target_bds if "FDSW" in i):
                    error("There is FDSW in fs2 -> preconditions, NOK")
                    raise EnvironmentIssue
                else:
                    info("There are RAT SWs installed in fs1 and fs2, as expected")
            else:
                error("Couldn't get SSH output, cannot check if there is FDSW in fs1 or fs2.")
        else:
            if fsm == "192.168.255.129":
                alias = "BTS"
            else:
                self.ssh.take_ssh_connection(fsm, "FSM")
                alias = "FSM"
            output_of_ssh_l = self.ssh.send_command_to_ip_return_output("ls -all /ffs/ -w 160", alias)
            if output_of_ssh_l:
                all_partitions = output_of_ssh_l.split("\n")
                for partition in all_partitions:
                    match = re_active_partition.match(partition)
                    if match and match.group("active_partition"):
                        active_partition = str(match.group("active_partition")).strip()
                        break
            if active_partition:
                if expected_partition:
                    if str(active_partition) == str(expected_partition):
                        info("Active partition is {} as expected.".format(active_partition))
                    else:
                        error("Unexpected partition was found as active. Expected that {} is active, "
                              "but found out that {} is active, NOK)".format(expected_partition, active_partition))
                        raise UnexpectedPartitionActive
                else:
                    info("Active partition is {}".format(active_partition))
            else:
                error("Couldn't find active partition, check SSH output and regex of script and "
                      "take contact to script developer. Used regex is: {}\n Output:\n {}".format(
                          re_active_partition, output_of_ssh_l))
                raise ScriptIssue
            if alias == "FSM":
                self.ssh.close_ssh_connection("FSM")
        return active_partition

    def corrupt_sw(self):
        """Corrupt sw corrupts SW from active and passive partition. SW is corrupted by removing BTSOM applications."""
        passive_partition = 'fs1'
        if not self.bts.active_partition:
            self.logger.debug("Active partition was not saved, call get_active_partition of BTS to get the information")
            self.bts.get_active_partition()
        self.logger.debug("Before corrupting take new ssh connection to BTS because there have been problems with it.")
        self.ssh.take_ssh_connection("192.168.255.129", alias="CORRUPT_SW")
        info("Corrupt SW from active partition {}".format(self.bts.active_partition))
        success = self.delete_applications_from_partition(self.bts.active_partition)
        if '1' in self.bts.active_partition:
            passive_partition = 'fs2'
        info("Corrupt SW from passive partition {}".format(passive_partition))
        self.ssh.send_command_to_ip_return_output("mount -o remount,rw /ffs/{}".format(passive_partition), "CORRUPT_SW")
        success = self.delete_applications_from_partition(passive_partition) and success
        if success:
            info("SW is successfully corrupted from active and from passive partition.")
        else:
            error("Problems when corrupting SW from active and from passive partition.")
        self.ssh.close_ssh_connection("CORRUPT_SW")
        return success

    def check_output_content(self, output, bts_folder):
        """
        Check output content checks if output contains BTSOM applications. If it does, remove them. If not,
        give warning.

        :param str output: Output of command ls to check if it contains BTSOM applications.
        :param str bts_folder: Folder to check if it contains BTSOM applications.
        """
        if not output:
            error("No output (command was 'ls {}')".format(bts_folder))
            raise BTSSwIssue
        elif output and "BTSOM" in output:
            info("Remove BTSOM applications with command: rm {}BTSOM*".format(bts_folder))
            self.ssh.send_command_to_ip_return_output("rm {}BTSOM*".format(bts_folder), "CORRUPT_SW")
        else:
            warning("No file that name has BTSOM is found from {} \n(it's content: {})\nThis is possibly due previous \
                    fallback tests and will not fail the test.".format(bts_folder, output))
            # raise BTSSwIssue

    def delete_applications_from_partition(self, partition):
        """
        Delete applications from partition. If there is BTSOM applications, remove them, if not raise warning.

        :param str partition: Partition to delete applications from. For example 'fs1' or 'fs2'.
        """
        success = True
        app_folder = "/ffs/{}/swpool/OAM/fsmr4-axm/".format(partition)  # ASIA
        board_config = "/ffs/{}/boardcfg/0/A/mcu-axm55xx/apps/".format(partition)
        output = self.ssh.send_command_to_ip_return_output("ls /ffs/{}/swpool/OAM/".format(partition), "CORRUPT_SW")
        if not output:
            error("No output for command 'ls /ffs/{}/swpool/OAM/'. Check if SSH connection is working."
                  "Unable to corrupt software".format(partition))
            raise BTSSwIssue
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        if self.bts.check_if_smod_type_in_environment("ASIB"):
            app_folder = "/ffs/{}/swpool/OAM/fsmr4-axm64/".format(partition)
            board_config = "/ffs/{}/boardcfg/0/A/mcu-axm55xx/apps/".format(partition)
        else:
            if "sm6-snowfish" in output:  # ASIL/ASOE
                app_folder = "/ffs/{}/swpool/OAM/sm6-snowfish/".format(partition)
                board_config = "/ffs/{}/boardcfg/0/A/mcu-asce/apps/".format(partition)
            if "sm7-marlin" in output:  # ASIM/ASOG/ASOH
                app_folder = "/ffs/{}/swpool/OAM/sm7-marlin/".format(partition)
                board_output = self.ssh.send_command_to_ip_return_output(
                    f"ls /ffs/{partition}/boardcfg/0/A/", "CORRUPT_SW")
                # ASIM
                if "mcu-fctq" in board_output:
                    board_config = f"/ffs/{partition}/boardcfg/0/A/mcu-fctq/apps/"
                # ASOG/ASOH
                if "mcu-asch" in board_output:
                    board_config = f"/ffs/{partition}/boardcfg/0/A/mcu-asch/apps/"
                if "mcu-fctq" not in board_output and "mcu-asch" not in board_output:
                    error("Unknown boardcfg. Check from used SMOD HW what path should be used here.")
        self.logger.debug("Application folder {} and board_config folder {}".format(app_folder, board_config))
        output = self.ssh.send_command_to_ip_return_output("ls {}".format(app_folder), "CORRUPT_SW")
        self.check_output_content(output, app_folder)
        output2 = self.ssh.send_command_to_ip_return_output("ls {}".format(board_config), "CORRUPT_SW")
        self.check_output_content(output2, board_config)
        return success

    def calculate_software_attempts_to_start(self):
        """
        Calculates that software attempts to start 3 times from active and 3 times from passive side
        """
        success = True
        restart_text = ""
        for i in range(1, 7):
            if success:
                if i in (1, 2, 3):
                    restart_text = "{}. try to start from corrupted active partition".format(i)
                elif i in (4, 5, 6):
                    j = int(i) - 3
                    restart_text = "{}. try to start from corrupted passive partition".format(j)
                info(restart_text)
                success = self.bts.ping_ip_until_disconnection_or_reconnection(
                    ip_to_ping="192.168.255.129", disconnection=False, time_to_wait=900, save_pings_to_file=True)
                if success:
                    success = self.bts.ping_ip_until_disconnection_or_reconnection(
                        ip_to_ping="192.168.255.129", disconnection=True, time_to_wait=900, save_pings_to_file=True)

                    if not success:
                        error("{} FAILED. Disconnection is not noticed by pinging of 192.168.255.129".format(
                            restart_text))
                else:
                    error("{} FAILED. Reconnection is not noticed by pinging of 192.168.255.129".format(restart_text))
            else:
                break
        return success
