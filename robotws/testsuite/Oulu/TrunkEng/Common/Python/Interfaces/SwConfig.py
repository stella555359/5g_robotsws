"""
:author: Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import os
import re
from traceback import format_exception
from paramiko.ssh_exception import SSHException
from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh.exceptions import CommandExecutionError
from taf.internal.aliasing.exceptions import AliasLookupError
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, warning, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (EnvironmentIssue, ScriptIssue,
                                                                        SSHConnectionFailure)


class SwConfig:
    """
    SwConfig is used for changing flags to swconfig.txt file and checking flag values.

    SwConfig is called in common_resources.robot. If the class is already initiated once, import robot
    BuiltIn
        >> from robot.libraries.BuiltIn import BuiltIn
    and call with
        >> BuiltIn().get_library_instance("SWCONFIG")
    """
    site_reset_needed = False

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.ssh = BuiltIn().get_library_instance("SSH")
        self.collect_logs = None

    @staticmethod
    def _safe_split(value, sep):
        """Safely split values that may be None; returns list from splitting str(value)."""
        if value is None:
            return [""]
        return str(value).split(sep)

    def collect_swconfig(self, local_path="", bts_ip="192.168.255.129"):
        """
        Collects swconfig.txt file from BTS to test logs or if local_path is given to the path.

        :param str local_path: (Optional) Path to where the swconfig.txt will be saved.
        :param str bts_ip: Ip of BTS, default is 192.168.255.129.
        """
        if bts_ip == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                bts_ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        loop = f"Loop {self.logger.loop + 1}: " if self.logger.loop else ""
        if not self.collect_logs:
            self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        info("Collect swconfig.txt.")
        try:
            return self.collect_logs.get_file_or_folder_from_bts_to_test_logs(
                "/ffs/run/swconfig.txt", bts_ip=bts_ip, local_dir=local_path, scp_timeout=300)
        except (AttributeError, TypeError, ValueError) as swconf:
            warning(f"{loop}swconfig.txt was not get to test logs: {swconf.__class__.__name__}:{swconf}")
            info(f"{''.join(format_exception(type(swconf), swconf, swconf.__traceback__))}")

    def check_that_there_is_flag_in_swconfig(self, flag_value_dict, bts_ip="192.168.255.129",
                                             sw_config_file_on_local_pc=""):
        """
        Checks that there is flag in swconfig verifies that flag and it's value are found from the swconfig.txt file.

        :param dictionary flag_value_dict: Flag that is checked as a key and value as a expected flag value.
        :param str bts_ip: Default 192.168.255.129.
        :param str sw_config_file_on_local_pc: (Optional) If swconfig.txt file is already collected to local pc, give
                                               path to the file here. If not given, swconfig.txt will be collected with
                                               ssh command.
        :return bool: Returns True if flag and value are expected and False if not.
        """
        loop = f"Loop {self.logger.loop + 1}: " if self.logger.loop else ""
        if sw_config_file_on_local_pc and os.path.exists(sw_config_file_on_local_pc) and os.path.isfile(
                sw_config_file_on_local_pc):
            with open(sw_config_file_on_local_pc, "r") as f:
                output = f.read()
        else:
            output = ""
            if bts_ip == "192.168.255.129":
                if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                    bts_ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
            try:
                output = self.ssh.send_command_to_smod_by_ssh("cat /ffs/run/swconfig.txt", return_output=True,
                                                              print_to_eventlog=False, name_for_log="check_flags",
                                                              ip_to_connect=bts_ip, raise_error=False)
                if not output:
                    info("SSH output was not get with pexpect methods, try with the TAF ssh library")
                    output = self.ssh.connection_command_and_output("cat /ffs/run/swconfig.txt", alias="CHECK_FLAGS")
            except (CommandExecutionError, AliasLookupError, SSHException, TypeError, TimeoutError, AttributeError,
                    SSHConnectionFailure) as e:
                info(f"Content of swconfig.txt was not get: {e.__class__.__name__}:{e}"
                     f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        if not output:
            warning(f"{loop}No output get with SSH to command: cat /ffs/run/swconfig.txt")
            return False
        if "No such file or directory" in output:
            error(f"{loop}There is no swconfig.txt file in /ffs/run/ -folder.")
            raise EnvironmentIssue
        output = SwConfig._safe_split(output, "\n")
        nok_flags = []
        for flag in flag_value_dict:
            flag_pattern = re.compile(r"^(?!#).*({})\s*=\s*(\w*)\s*.*".format(flag))
            for row in output:
                match = flag_pattern.match(row)
                if match:
                    if flag_value_dict[flag] != match.group(2):
                        error("{}Flag {} has value {} in swconfig.txt, not value {} as expected. NOK.".format(
                            loop, flag, match.group(2), flag_value_dict[flag]))
                        nok_flags.append(flag)
                    else:
                        info("Flag {} has value {} in swconfig.txt, as expected. OK.". format(
                            flag, flag_value_dict[flag]))
        return False if nok_flags else True

    def add_flags_via_telnet(self, flag_value_dict, ip="192.168.255.129"):
        """
        Adds flags to BTS on the run, without need of reset.

        :param dictionary flag_value_dict: Flag that is added as a key and value as an expected flag value.
        :param str ip: Ip of BTS. Default 192.168.255.129
        """
        if ip == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        try:
            commands = ["telnet localhost 15007"]
            if not flag_value_dict:
                error("Dictionary including flag and value of flag is missing.")
                raise ScriptIssue
            for flag in flag_value_dict:
                info(f"Flag {flag} will be set to value {flag_value_dict[flag]}.")
                commands.append(f"rad -pw {flag} {flag_value_dict[flag]}")
            self.ssh.send_command_to_smod_by_ssh(commands, return_output=False, ssh_timeout=60, print_to_eventlog=True,
                                                 name_for_log="add_flags", ip_to_connect=ip)
            self.logger.debug("Flags set.")
        except (CommandExecutionError, AliasLookupError, SSHException, SSHConnectionFailure) as e:
            warning(f"Problems when changing flags: {e.__class__.__name__}:{e}\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    def add_and_remove_flags_with_swconfig(self, flag_value_dict, add_flag=True, bts_ip="192.168.255.129"):
        """
        Adds/removes flags from the swconfig.txt file by manipulating the file. NOTE reset is needed for changed
        swconfig.txt to be activated

        :param dictionary flag_value_dict: Flag that is added/removed as a key and value as a flag value. If remove in
                                           question give empty string as value.
        :param bool add_flag: Default is True, flag is added to swconfig.txt. If flag is wanted to be removed set
                              add_flag to False.
        :param str bts_ip: IP of BTS, default is 192.168.255.129.
        """
        if bts_ip == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                bts_ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        self.collect_swconfig(local_path="/tmp", bts_ip=bts_ip)
        file_content = ""
        SwConfig.site_reset_needed = False
        if os.path.exists("/tmp/swconfig.txt"):
            with open("/tmp/swconfig.txt", "r") as f:
                file_content = f.read()
        else:
            error("Unable to get swconfig file from BTS. Cannot manipulate it.")
        if file_content:
            for flag in flag_value_dict:
                if flag not in file_content:
                    if add_flag:
                        info("Add {} = {} to end of the swconfig file.".format(
                            flag, flag_value_dict[flag]))
                        with open("/tmp/swconfig.txt", "a") as nf:
                            nf.write("\n{} = {} \n".format(flag, flag_value_dict[flag]))
                        SwConfig.site_reset_needed = True
                    else:
                        warning(f"Flag {flag} that was requested to be removed was not found from the file.")
                else:
                    info("Flag {} was found from the swconfig.".format(flag))
                    file_content = SwConfig._safe_split(file_content, "\n")
                    flag_pattern = re.compile(r".*({})\s*=\s*(\w*)\s*.*".format(flag))
                    new_content = []
                    for row in file_content:
                        match = flag_pattern.match(row)
                        if match:
                            if add_flag:
                                if match.group(2) == flag_value_dict[flag]:
                                    info("Flag already has the same value in swconfig as requested.")
                                else:
                                    info("Change {} = {} to the file.".format(flag, flag_value_dict[flag]))
                                    row = row.replace("{}".format(match.group(2)), "{}".format(flag_value_dict[flag]))
                                    SwConfig.site_reset_needed = True
                            else:
                                info("Remove {} from the file".format(row))
                                row = ""
                                SwConfig.site_reset_needed = True
                        new_content.append(row)
                    self.logger.debug("New content of swconfig.txt: {}".format(new_content))
                    with open("/tmp/swconfig.txt", 'w') as nc_f:
                        nc_f.write("\n".join(new_content))
            if SwConfig.site_reset_needed:
                info("Changes in swconfig, upload it to BTS")
                self.upload_file_to_bts()
            else:
                info("No changes in swconfig, no need to upload it to BTS.")

    def upload_file_to_bts(self, local_file_path="/tmp/swconfig.txt", remote_file_path="/ffs/run/swconfig.txt",
                           ip_of_bts="192.168.255.129"):
        """
        Uploads file from local computer to bts.

        :param str local_file_path: Path to file in local computer. Default value /tmp/swconfig.txt.
        :param str remote_file_path: Path to file in bts. Default value /ffs/run/swconfig.txt.
        :param str ip_of_bts: Ip of bts. Default value is 192.168.255.129.
        """
        if ip_of_bts == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                ip_of_bts = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        if not self.collect_logs:
            self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        try:
            # info("Upload file {} to bts {}".format(local_file_path, remote_file_path))
            # self.ssh.connection_and_upload_file(local_file_path, remote_file_path)
            self.collect_logs.upload_file_or_folder_to_bts(local_file_path, remote_file_path, bts_ip=ip_of_bts)
        except (CommandExecutionError, SSHException, AttributeError, TypeError, TimeoutError, FileNotFoundError) as e:
            warning(f"Error while uploading file to bts: {e.__class__.__name__}:{e}\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    def check_that_max_allowed_fsp_recovery_is_set_to_default(self):
        max_resets = self.get_max_allowed_fsp_recovery_amount()
        if max_resets == 3:
            info("Max FSP resets is 3. OK.")
            return True
        else:
            error("Max FSP resets is not 3. NOK. Do not continue the test.")
            raise EnvironmentIssue("Max FSP reset is not set to 3, check flags in swconfig.")

    def get_max_allowed_fsp_recovery_amount(self):
        rad_params = self.get_rad_params()
        for flag in ["0x500002", "0x500017", "0x500018"]:
            if flag in rad_params.keys():
                info(f"Max allowed reset amount is set to {rad_params[flag]} with flag {flag}.\n"
                     f"0x500002 = FSP recovery reset, 0x500017 = FSP Warm reset, 0x500018 = FSP Power reset")
                return rad_params[flag]
        info(f"None of the known flags is found from radParams. Assume there is no flag and the default FSP recovery "
             f"reset counter is in use: 3 (0x500002 = FSP recovery reset, 0x500017 = FSP Warm reset, "
             f"0x500018 = FSP Power reset)")
        return 3

    def get_rad_params(self):
        rad_params = self.admin.get_bts_rad_parameters(parameters_type="Requested", connection="default")
        rad_params_dict = {}
        for flag in rad_params:
            rad_params_dict[flag['flag']] = int(flag['value'], 16)
        info(f"Found RadParams are: {rad_params_dict}")
        return rad_params_dict

    @staticmethod
    def site_reset_is_needed():
        """Method to check if there are changes in swconfig and if site reset is needed."""
        if SwConfig.site_reset_needed:
            info("Changes in swconfig, site reset is needed to activate changes.")
            return True
        else:
            info("No changes in swconfig, no need to give site reset.")
            return False
