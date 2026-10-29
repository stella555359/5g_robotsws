"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import re
import os
from datetime import datetime
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error, warning
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import EnvironmentIssue, ScriptIssue


class BlackBoxChecks:
    """
    Class for parsing and comparing content of BTS /ffs/run/config/lifedata/blackbox_firmware_* file. After CNI-93026
    the path will be /ffs/run/logs/lifetimedata/blackbox_firmware_* file. This file contains for example firmware
     versions.

    NOTE BlackBoxChecks is not called in common_resources.robot.
    """

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.ssh = BuiltIn().get_library_instance("SSH")
        self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        self.bts_status = BuiltIn().get_library_instance("BTSSTATUS")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.fsp_ips = BuiltIn().get_library_instance("FSP")
        self.blackbox_file_before_swdl = ""
        self.blackbox_file_after_swdl = ""
        self.firmware_and_versions_before = {}
        self.firmware_and_versions_after = {}
        self.firmware_update_block = {}

    def parse_blackbox_file_content(self, content, dictionary_to_update, add_prefix="", parse_duration=False):
        """
        Parse blackbox file content and return firmware versions.

        :param str content: Content of blackbox file.
        :param dict dictionary_to_update: Dictionary to update with firmware versions.
        :param str add_prefix: Prefix to add to firmware name. Needed for BBMOD firmware versions.
        :param bool parse_duration: If True, also parse firmware update durations. Default is False.
        :return dict: Dictionary with firmware versions.
        """
        if content:
            firmware_info = re.findall(r"Firmware:\s+\"\w+\"", content)
            content_list = content.split("Firmware:")
            for firmware in firmware_info:
                c = firmware.split("\"")
                self.logger.debug(f"{firmware},  {c}")
                for firmware_block in content_list:
                    if c[1] in firmware_block:
                        version_info = re.findall(r'^0x[\da-fA-F]+', firmware_block, re.MULTILINE)
                        self.logger.debug(version_info)
                        value_of_version = version_info if version_info else "No version found"
                        firmware_name = f"{add_prefix}_{c[1]}" if add_prefix else c[1]
                        dictionary_to_update[firmware_name] = value_of_version
                        if parse_duration:
                            self.firmware_update_block[firmware_name] = firmware_block
            if "XEON" in add_prefix:  # another search for ABIL XEONA and XEONB firmware version
                dictionary_to_update = self._parse_blackbox_from_abil_output(content, dictionary_to_update, add_prefix)
            # info(dictionary_to_update)
        else:
            info("Blackbox file content is empty. No firmware versions found.")
        return dictionary_to_update

    def _parse_firmware_update_durations(self, firmware_block, firmware):
        """
        Parse firmware update durations from a firmware block. Print the duration to eventlog and save to file
        firmware_updates.txt.

        :param str firmware_block: Content of a single firmware block.
        :param str firmware: Firmware name for logging purposes.
        :return list: List of dictionaries containing version, start time, end time, status, and duration.
        """
        update_durations = []
        # Pattern to match update lines with start and end times
        # 0x018d0bcd  runtime  2026-02-06T16:08:22.527Z  2026-02-06T16:09:25.689Z  OK  2026-02-06T16:13:48.054Z
        update_pattern = re.compile(
            r'^(0x[\da-fA-F]+)\s+runtime\s+(\d{4}-\d{2}-\d{2}T[\d:.]+Z)\s+(\d{4}-\d{2}-\d{2}T[\d:.]+Z)\s+(\S+)',
            re.MULTILINE
        )
        start_time = None
        end_time = None
        version = None
        start_time_str = ""
        end_time_str = ""
        status = ""
        for match in update_pattern.finditer(firmware_block):
            version, start_time_str, end_time_str, status = match.groups()
            try:  # Parse timestamps
                start_time = datetime.strptime(start_time_str, "%Y-%m-%dT%H:%M:%S.%fZ")
                end_time = datetime.strptime(end_time_str, "%Y-%m-%dT%H:%M:%S.%fZ")
            except Exception as e:  # Log parsing error but continue with other entries
                info(''.join(format_exception(type(e), e, e.__traceback__)))
                info(f"Error when parsing firmware update duration for {firmware}: {e}")
                continue
        if start_time and end_time:
            duration = end_time - start_time
            info(f"Firmware update duration for {firmware} version {version}: {duration} (Status: {status})\n\tStart "
                 f"time: {start_time_str}\n\tEnd time: {end_time_str}")
            file_path = os.path.join(self.logger.log_dir, "firmware_updates.txt")
            with open(file_path, "a") as f:
                f.write(f"{firmware} version {version}:\n\tStart time: {start_time_str}\n\tEnd time: "
                        f"{end_time_str}\n\tDuration: {duration}\n")
        else:
            info(f"No valid firmware update entries ('Start Time of Update'/'End Time of Update') found for {firmware} "
                 f"to parse durations.")

    @staticmethod
    def _parse_blackbox_from_abil_output(content, dictionary_to_update, add_prefix):
        latest_versions = {}
        # Find all update events with timestamp, app name, and version
        update_pattern = re.compile(
            r'(\d{4}-\d{2}-\d{2}T[\d:]+): Starting to update FW for ([^\n]+)\n.*?FW update OK, new version: ([^\n]+)',
            re.DOTALL
        )
        for match in update_pattern.finditer(content):
            timestamp_str, app, version = match.groups()
            timestamp = datetime.strptime(timestamp_str, "%Y-%m-%dT%H:%M:%S")
            app = app.strip()
            # Store only the latest by timestamp
            if app not in latest_versions or timestamp > latest_versions[app][0]:
                latest_versions[f"{add_prefix}_{app}"] = (timestamp, version.strip())
        for app, (_, version) in latest_versions.items():
            if app in dictionary_to_update:
                dictionary_to_update[app].append(version)
            else:
                dictionary_to_update[app] = [version]
        return dictionary_to_update

    def _get_content_from_blackbox_file(self, when, ssh_object=None):
        """
        Get blackbox file content before or after SWDL from BTS.

        :param str when: When to get the file content. Possible values are 'before' or 'after'.
        :param ssh_object: SSH connection object. If not given, will try to connect to SMOD with default parameters.
        :return str: Content of blackbox file.
        """
        content_file = ""
        try:
            command = "cat /ffs/run/logs/lifetimedata/blackbox_firmware_*"
            for try_time in range(1, 5):
                ssh_object = self._ssh_object_to_master_smod(ssh_object, when)
                if try_time == 4:
                    info("Unable to get blackbox file from /ffs/run/logs/lifetimedata, try to get it from older path "
                         "/ffs/run/config/lifedata.")
                    command = "cat /ffs/run/config/lifedata/blackbox_firmware_*"
                content_file = self.ssh.send_command_to_smod_by_ssh(command, enb_ssh=ssh_object, return_output=True,
                                                                    ssh_timeout=60, print_to_eventlog=False,
                                                                    raise_error=False, disconnect_ssh=False)
                if content_file and ("No such file or directory" not in content_file):
                    break
                if try_time == 1:
                    self.ssh.delete_known_host_file()
                else:
                    self.logger.debug("Unable to get content of blackbox_firmware* file. Kill all created SSH "
                                      "connections and remove all known_host and rsa_ids and try again.")
                    self.ssh.close_all_ssh_connections()
                    self.ssh.delete_known_host_file()
            if not content_file or (content_file and "No such file or directory" in content_file):
                info(f"Blackbox file content {when} SWDL is empty, the path is has changed or there are problems with "
                     f"connection. This will not fail the test, because we can still use syslog prints for checks.")
                return ""
            return content_file
        except Exception as e:
            info(''.join(format_exception(type(e), e, e.__traceback__)))
            info(f"Could not get blackbox file content from SMOD {when} SWDL because {e.__class__.__name__}:{e}\n"
                 f"This will not fail the test, because we can still use syslog prints for checks.")
            return ""

    def _get_black_box_from_bbmod(self, ssh_object, bbmod, when, soc="primary"):
        """
        Get blackbox file content from BBMOD before or after SWDL.

        :param object ssh_object: SSH connection object.
        :param object bbmod: BBMOD object.
        :param str when: When to get the file content. Possible values are 'before' or 'after'.
        :param str soc: If soc is 'primary' get primary soc IP. Default is 'primary'.
        :return str: Content of blackbox file.
        """
        if bbmod is None or not hasattr(bbmod, "name"):
            error("BBMOD object is not valid.")
            raise ScriptIssue("BBMOD object is not valid.")
        ssh_object = self._ssh_object_to_master_smod(ssh_object, when)
        try:
            content_file = ""
            command = "cat /run/blackbox/blackbox_firmware_*"
            if soc == "primary":  # returns ip of master soc
                fsp = self.fsp_ips.get_ip_of_selected_fsp(bbmod.name, selected_soc=bbmod.primary_soc,
                                                          smod_ssh=ssh_object)
            else:  # returns ip of selected soc
                fsp = self.fsp_ips.get_ip_of_selected_fsp(bbmod.name, selected_soc=soc, smod_ssh=ssh_object)
            if not fsp:
                error("FSP IP address is not valid.")
                raise ScriptIssue("FSP IP address is not valid.")
            fsp_object = self.ssh.connect_to_fsp(ssh_object, fsp, "toor4nsn", known_hosts=False, save_to_own_file=False)
            if fsp_object:
                content_file = self.ssh.send_command_to_fsp_by_ssh(fsp_object, command, ssh_timeout=60)
            if not content_file or (content_file and "No such file or directory" in content_file):
                info(f"Blackbox file was not get from {bbmod.name} {when} SWDL or it is empty. The path may be  has "
                     f"changed or there may be problems with ssh connection to the BBMOD. This will not fail the test, "
                     f"because we can still use syslog prints for checks.")
            info(f"Exit from {bbmod.name}/{bbmod.primary_soc if soc == 'primary' else soc}")
            self.ssh.send_command_to_fsp_by_ssh(fsp_object, "exit", ssh_timeout=60)
            return content_file
        except Exception as e:
            info(''.join(format_exception(type(e), e, e.__traceback__)))
            info(f"Could not get blackbox file content from BBMOD {bbmod.name} {when} SWDL because "
                 f"{e.__class__.__name__}:{e}\nThis will not fail the test, because we can still use syslog prints for"
                 f" checks.")
            return ""

    def get_content_from_blackbox_file_of_bbmod(self, when, ssh_object=None):
        """
        Get blackbox file content before or after SWDL from BTS.

        :param str when: When to get the file content. Possible values are 'before' or 'after'.
        :param ssh_object: SSH connection object. If not given, will try to connect to SMOD with default parameters.
        :return str: Content of blackbox file.
        """
        fsp_application_version = {}
        file_path = os.path.join(self.logger.log_dir, f"blackbox_files")
        try:
            for bbmod in self.bts.bbmods:
                if "ABIA" in bbmod.name:
                    info("ABIA BBMODs do not have blackbox files.")
                    continue
                ssh_object = self._ssh_object_to_master_smod(ssh_object, when)
                prefix = str(bbmod.name).replace(".", "_")
                content_file = self._get_black_box_from_bbmod(ssh_object, bbmod, when, soc="primary")
                parse_duration = True if when == "after" else False  # parse durations only after SWDL
                if content_file:
                    if 'ABIL' in prefix:  # XEONA applications, primary soc
                        if BuiltIn().get_variable_value("${WRITE_BLACKBOX_FILES_TO_LOGS}"):
                            with open(os.path.join(file_path, f"{prefix}_XEONA_blackbox_file_{when}_swdl.txt"),
                                      "w") as f:
                                f.write(content_file)
                        fsp_application_version = self.parse_blackbox_file_content(
                            content_file, fsp_application_version, add_prefix=f"{prefix}_XEONA",
                            parse_duration=parse_duration)
                        content_file = self._get_black_box_from_bbmod(ssh_object, bbmod, when, soc="XEONB")
                        if content_file:  # XEONB applications
                            if BuiltIn().get_variable_value("${WRITE_BLACKBOX_FILES_TO_LOGS}"):
                                with open(os.path.join(file_path, f"{prefix}_XEONB_blackbox_file_{when}_swdl.txt"),
                                          "w") as f:
                                    f.write(content_file)
                            fsp_application_version = self.parse_blackbox_file_content(
                                content_file, fsp_application_version, add_prefix=f"{prefix}_XEONB",
                                parse_duration=parse_duration)
                    else:
                        if BuiltIn().get_variable_value("${WRITE_BLACKBOX_FILES_TO_LOGS}"):
                            with open(os.path.join(file_path, f"{prefix}_blackbox_file_{when}_swdl.txt"), "w") as f:
                                f.write(content_file)
                        fsp_application_version = self.parse_blackbox_file_content(
                            content_file, fsp_application_version, add_prefix=f"{prefix}",
                            parse_duration=parse_duration)
                else:
                    warning(f"Blackbox file content of BBMOD {bbmod.name} {when} SWDL is empty.")
            #  info(f"FSP application versions from blackbox file of BBMODs {when} SWDL:\n{fsp_application_version}")
            return fsp_application_version
        except Exception as e:
            info(f"{''.join(self.logger.format_exception(type(e), e, e.__traceback__))}")
            info(f"Could not get blackbox file content from BBMODs {when} SWDL because {e.__class__.__name__}:{e}\n"
                 f"This will not fail the test, because we can still use syslog prints for checks.")
            return {}

    def _ssh_object_to_master_smod(self, ssh_object, when):
        ip = self.bts.default_smod_ip if self.bts else "192.168.255.129"
        if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
            ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        if not ssh_object or not self.ssh.check_if_pexpect_object_is_alive(ssh_object):
            self.logger.debug("SSH connection object is not given or it is not alive, connecting to SMOD "
                              "(get_content_from_blackbox_file_of_secondary)...")
            if self.collect_logs.rfs:
                remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
                other_master = BuiltIn().get_variable_value("${MASTER}") == "Other"
                # ip = self.bts.default_smod_ip
                if other_master:
                    ip = remote_mplane_ip
                self.ssh.delete_known_host_file()
                ssh_object = self.ssh.ssh_connection_to_given_ip(user_name="toor4nsn", ssh_password="oZPS0POrRieRtu",
                                                                 ip_to_connect=ip, name_for_log=f"{when}_blackbox",
                                                                 print_to_eventlog=False, raise_error=False)
            else:
                ssh_object = self.ssh.ssh_connection_to_given_ip(user_name="toor4nsn", ssh_password="oZPS0POrRieRtu",
                                                                 ip_to_connect=ip, name_for_log=f"{when}_blackbox",
                                                                 print_to_eventlog=False, raise_error=False)
        return ssh_object

    def get_content_from_blackbox_file_of_secondary(self, when, ssh_object=None):
        """
        Get blackbox file content from secondary SMOD before or after SWDL.

        :param str when: When to get the file content. Possible values are 'before' or 'after'.
        :param ssh_object: SSH connection object. If not given, will try to connect to SMOD with default parameters.
        :return dict: Dictionary with firmware versions from secondary SMOD. The keys are in format
                      "secondary_SMOD_FirmwareName" to distinguish
        """
        secondary_applications = {}
        if not self.bts.fullrack:
            info("Not a fullrack environment, secondary SMOD is not available.")
            return {}
        try:
            ssh_object = self._ssh_object_to_master_smod(ssh_object, when)
            ssh_object = self.ssh.connect_to_secondary_smod(ssh_object, self.bts.bts_side_is_right)
            if not ssh_object:
                info("SSH connection to secondary SMOD could not be established. Cannot get blackbox file from "
                     "secondary SMOD.")
            else:
                content = self._get_content_from_blackbox_file(when, ssh_object=ssh_object)
                if BuiltIn().get_variable_value("${WRITE_BLACKBOX_FILES_TO_LOGS}"):
                    file_path = os.path.join(self.logger.log_dir, f"blackbox_files")
                    with open(os.path.join(file_path, f"blackbox_file_secondary_{when}_swdl.txt"), "w") as f:
                        f.write(content)
                parse_duration = True if when == "after" else False  # parse durations only after SWDL
                secondary_applications = self.parse_blackbox_file_content(
                    content, secondary_applications, add_prefix=f"secondarySMOD",
                    parse_duration=parse_duration)
                info(f"Exit from secondary SMOD.")
                self.ssh.send_command_to_smod_by_ssh("exit", enb_ssh=ssh_object, ssh_timeout=60,
                                                     print_to_eventlog=False, raise_error=False, disconnect_ssh=False)
        except Exception as e:
            info(''.join(format_exception(type(e), e, e.__traceback__)))
            info(f"Could not get blackbox file content from secondary SMOD {when} SWDL because {e.__class__.__name__}:"
                 f"{e}\nThis will not fail the test, because we can still use syslog prints for checks.")
        return secondary_applications

    def get_blackbox_file_content_from_bts(self, when):
        """
        Get blackbox file content before or after SWDL from the BTS.

        :param str when: When to get the file content. Possible values are 'before' or 'after'.
        """
        if not self.bts_status:
            self.bts_status = BuiltIn().get_library_instance("BTSSTATUS")
        if not self.bts_status.airscale_product:
            info("SMOD is not an AirScale product. Blackbox file is not available.")
            return {}
        ssh_object = None
        file_path = os.path.join(self.logger.log_dir, f"blackbox_files")
        try:
            if BuiltIn().get_variable_value("${WRITE_BLACKBOX_FILES_TO_LOGS}"):
                if not os.path.exists(file_path):
                    os.makedirs(file_path)
            ip = self.bts.default_smod_ip if self.bts else "192.168.255.129"
            if self.collect_logs.rfs:
                remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
                other_master = BuiltIn().get_variable_value("${MASTER}") == "Other"
                if other_master:
                    ip = remote_mplane_ip
            ssh_object = self.ssh.ssh_connection_to_smod(name_for_log=f"blackbox_{when}_swdl", ip_to_connect=ip,
                                                         print_to_eventlog=True, raise_error=True)
            # NOTE that content includes also BBMOD firwmare versions because used * in the command
            if when == "before":
                self.blackbox_file_before_swdl = self._get_content_from_blackbox_file(when, ssh_object=ssh_object)
                if BuiltIn().get_variable_value("${WRITE_BLACKBOX_FILES_TO_LOGS}"):
                    with open(os.path.join(file_path, f"blackbox_file_{when}_swdl.txt"), "w") as f:
                        f.write(self.blackbox_file_before_swdl)
                self.firmware_and_versions_before = self.parse_blackbox_file_content(
                    self.blackbox_file_before_swdl, self.firmware_and_versions_before)
                if self.bts.fullrack:
                    self.logger.debug("Fullrack environment, getting blackbox file content from secondary SMOD.")
                    secondary_applications = self.get_content_from_blackbox_file_of_secondary(when,
                                                                                              ssh_object=ssh_object)
                    self.firmware_and_versions_before.update(secondary_applications)
                bbmod_applications = self.get_content_from_blackbox_file_of_bbmod(when, ssh_object=ssh_object)
                self.firmware_and_versions_before.update(bbmod_applications)
                info(self.firmware_and_versions_before)
                return self.firmware_and_versions_before
            elif when == "after":
                self.blackbox_file_after_swdl = self._get_content_from_blackbox_file(when, ssh_object=ssh_object)
                if BuiltIn().get_variable_value("${WRITE_BLACKBOX_FILES_TO_LOGS}"):
                    file_path = os.path.join(self.logger.log_dir, f"blackbox_files")
                    if not os.path.exists(file_path):
                        os.makedirs(file_path)
                    with open(os.path.join(file_path, f"blackbox_file_{when}_swdl.txt"), "w") as f:
                        f.write(self.blackbox_file_after_swdl)
                self.firmware_and_versions_after = self.parse_blackbox_file_content(
                    self.blackbox_file_after_swdl, self.firmware_and_versions_after, parse_duration=True)
                if self.bts.fullrack:
                    self.logger.debug("Fullrack environment, getting blackbox file content from secondary SMOD.")
                    secondary_applications = self.get_content_from_blackbox_file_of_secondary(when,
                                                                                              ssh_object=ssh_object)
                    self.firmware_and_versions_before.update(secondary_applications)
                bbmod_applications = self.get_content_from_blackbox_file_of_bbmod(when, ssh_object=ssh_object)
                self.firmware_and_versions_after.update(bbmod_applications)
                info(self.firmware_and_versions_after)
                return self.firmware_and_versions_after
            else:
                error("Invalid value for 'when' parameter. Use 'before' or 'after'.")
                raise ScriptIssue("Invalid value for 'when' parameter. Use 'before' or 'after'.")
        except Exception as e:
            info(''.join(format_exception(type(e), e, e.__traceback__)))
            info(f"Could not get blackbox file content from BTS {when} SWDL because {e.__class__.__name__}:{e}\n"
                 f"This will not fail the test, because we can still use syslog prints for checks.")
            return {}
        finally:
            self.ssh.disconnect_ssh_connection(ssh_object, print_to_eventlog=False)

    def compare_firmware_versions(self):
        """
        Compare firmware versions before SWDL and after SWDL if changes in versions then firmware update was made.
        """
        firmware_versions_changed = []
        if not self.bts_status:
            self.bts_status = BuiltIn().get_library_instance("BTSSTATUS")
        if not self.bts_status.airscale_product:
            info("SMOD is not an AirScale product. Blackbox file is not available. So firmware update cannot be "
                 "checked with blackbox file compare.")
            return False
        if not self.firmware_and_versions_before and not self.firmware_and_versions_after:
            info(info("No blackbox files, so no firmware update cannot be checked with blackbox file compare."))
            return False
        if not self.firmware_and_versions_before or not self.firmware_and_versions_after:
            info(f"Firmware versions are not available for comparison. Before SWDL {self.firmware_and_versions_before}"
                 f", After SWDL {self.firmware_and_versions_after}. Check that blackbox files are available in the "
                 f"environment.\nSo no firmware update cannot be checked with blackbox file compare.")
            return False
        for firmware in self.firmware_and_versions_before:
            if firmware in self.firmware_and_versions_after:
                if self.firmware_and_versions_before[firmware] != self.firmware_and_versions_after[firmware]:
                    info(f"Lists of {firmware} firmware versions are not identical. Check if versions in lists changed:"
                         f"\nBefore SWDL:\n\t{self.firmware_and_versions_before[firmware]}\nAfter SWDL:\n\t"
                         f"{self.firmware_and_versions_after[firmware]}")
                    diff = set(self.firmware_and_versions_after[firmware]) - set(
                        self.firmware_and_versions_before[firmware])
                    if diff:
                        self.logger.debug(f"Firmware version of {firmware} has changed to {diff}.")
                        # firmware_versions_changed.append(firmware)
                        self.logger.debug(f"Firmware versions of {firmware} are not identical in lists, but no changes"
                                          f"in versions. Get the latest versions and check if they are different.")
                    if (self.firmware_and_versions_after[firmware][-1] !=
                            self.firmware_and_versions_before[firmware][-1]):
                        info(f"Firmware version of {firmware} has changed from "
                             f"{self.firmware_and_versions_before[firmware][-1]} to "
                             f"{self.firmware_and_versions_after[firmware][-1]}.")
                        firmware_versions_changed.append(firmware)
                    else:
                        self.logger.debug(f"Firmware version of {firmware} has not changed, the latest versions are the"
                                          f" same")
            else:
                info(f"Firmware {firmware} is not found after SWDL for comparison. We do not know if it has changed.")
        if firmware_versions_changed:
            info(f"Firmware versions are updated to firmwares: {firmware_versions_changed} (according to blackbox file"
                 f" compare).")
            if self.firmware_update_block:
                for firmware in firmware_versions_changed:
                    if firmware in self.firmware_update_block:
                        self._parse_firmware_update_durations(self.firmware_update_block[firmware], firmware)
                        # info(f"Firmware update block for {firmware}:\n{self.firmware_update_block[firmware]}")
            return True
        else:
            info("Firmware versions are the same, no firmware update (according to blackbox file compare).")
            return False

    def clear_blackbox_variables(self):
        """
        Clear values in blackbox variables.
        """
        self.blackbox_file_before_swdl = ""
        self.blackbox_file_after_swdl = ""
        self.firmware_and_versions_before = {}
        self.firmware_and_versions_after = {}
        self.firmware_update_block = {}
        self.logger.debug("All blackbox variables are cleared.")
