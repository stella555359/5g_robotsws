"""
:author:  Essi Passoja
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import os
import zipfile
import shutil
from datetime import datetime
import subprocess
import re
import glob
import json
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
                                                AdminApiNoResponseException, AdminApiConnectionClosedException,
                                                AdminApiTerminatedException)
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from taf.transport.ssh.exceptions import (CommandExecutionError, ConnectFailedError)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.collectors.core.entities.executor import (TimeoutError, ExecutionError)
from taf.rfrl.utilities.robot.general import get_builtin_value

if os.name != "nt":
    from taf.collectors.core import core
    from taf.collectors.btslog import btslog
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error, warning, Logger
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (EnvironmentIssue, FileNotFoundFromTestLogs,
                                                                        ScriptIssue, InvalidUserInput, WrongCellStates,
                                                                        SSHConnectionFailure)
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.RFS import RFS
from testsuite.Oulu.TrunkEng.Common.Python.Resources.WiresharkUsage import WiresharkUsage
import testsuite.Oulu.TrunkEng.Common.Python.Resources.GetFileFromArchivedFolder as GetFromArchived
import testsuite.Oulu.TrunkEng.Common.Python.Resources.ChangeSyslogSettings as ChangeSyslog

"""
Basic logs will be collected if 'Basic' keyword is given to 'logs', or if 'logs' is empty.
Tester can also define which logs to collect by giving a string to 'logs' with all collectable logs.
As an example:
    logs = "IMS Snapshot"          -->  collects IMS and Snapshot
    logs = "Basic" or "Basic logs  -->  collects IMS, Snapshot and Syslogs

'Basic' logs:
    IMS
    Snapshot
    Syslog

Special logs:
    Special log collection yet to be implemented.

"""


class CollectLogs:

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'  # Force single instance across all test suites

    ims_file_name = ""
    snapshot_file_name = ""
    snapshot_file_remote = ""
    html_report = {}
    loop_event_log = ""
    ims_get_after_swdl = False
    ims_file_name_after_swdl = ""
    ims_file_from_disconnection = ""
    syslog_log_folder = ""
    original_log_folder = ""
    original_ims_path = ""
    folders_for_zip_and_remove = []
    remote_vm_ip = ""
    remote_vm_pw = ""
    main_pid = 0
    zip_extra_file = ""
    do_not_move = []
    ongoing_ssh_commands = []
    smod_ip = "192.168.255.129"

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.bts_info = BuiltIn().get_library_instance("BTSINFO")
        self.bts_status = BuiltIn().get_library_instance("BTSSTATUS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.ssh = BuiltIn().get_library_instance("SSH")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.swconfig = BuiltIn().get_library_instance("SWCONFIG")
        self.syslog_search = None
        if os.name != "nt":
            self.core = core()
            self.syslog = btslog()
        self.rfs = BuiltIn().get_variable_value("${RFS}")
        self.success = True
        self.cell_operation = None
        self.ws = None
        if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
            CollectLogs.smod_ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")

    def get_debian_version_and_set_log_folder(self):
        """
        Get debian version of the test PC and set log folder accordingly.

        """
        self.logger.debug("Checking Debian version...")
        debian = 12
        pattern = re.compile(r".*Debian\s+GNU.Linux\s+(?P<debian>\d+)\s+.*")
        output = subprocess.check_output(r"lsb_release -d", shell=True)
        match = pattern.match(str(output))
        if match:
            debian = match.group("debian")
        # if int(debian) == 10 or int(debian) < 12:
        info(f"Debian version is {debian}. Syslogs are by default collected to folder /tmp/btslog2")
        CollectLogs.syslog_log_folder = "/tmp/btslog2"
        # else:
        #     info(f"Debian version is {debian}. Syslogs are collected to folder /tmp/btslog4")
        #     CollectLogs.syslog_log_folder = "/tmp/btslog4"
        new_syslog_path = ChangeSyslog.change_syslog_file_path()
        if new_syslog_path:
            info(f"SYSLOG_FILE_PATH suite variable was given. Syslog path changed to {new_syslog_path}")
            CollectLogs.syslog_log_folder = new_syslog_path
        if not self.syslog_search:
            self.syslog_search = BuiltIn().get_library_instance("SYSLOGSEARCH")
        self.logger.debug(f"Set path to self.syslog_search.btslog_dir to {CollectLogs.syslog_log_folder}")
        self.syslog_search.btslog_dir = CollectLogs.syslog_log_folder
        return CollectLogs.syslog_log_folder

    def start_log_collection(self, test_case="0", loop=0):
        """
        Start log collection.

        :param str test_case: Test case name.
        :param int loop: Loop number.
        """
        if CollectLogs.smod_ip == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                CollectLogs.smod_ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        self.logger.loop = loop
        self.logger.start_test_script_debug(test_case)
        self.setup_admin_connection()
        swconfig_path = self.swconfig.collect_swconfig(bts_ip=CollectLogs.smod_ip)
        self.bts_info.collect_bts_info()
        self.start_syslog_collection(swconfig_path=swconfig_path)
        if self.rfs or BuiltIn().get_variable_value("${HIGH_AVAILABILITY_ENVIRONMENT}", default=False):
            self.start_remote_syslog_collection()
        self.start_wireshark()
        suite_variables = BuiltIn().get_variables()
        if ("${SSH_COMMANDS_BEFORE_TEST}" in suite_variables or
                "@{SSH_COMMANDS_BEFORE_TEST}" in suite_variables):
            ssh_commands = BuiltIn().get_variable_value("${SSH_COMMANDS_BEFORE_TEST}")
            ssh_object = self.ssh.send_command_to_smod_by_ssh(
                ssh_commands, print_to_eventlog=True, disconnect_ssh=False)
            CollectLogs.add_ssh_object_to_list(ssh_object)

    @staticmethod
    def add_ssh_object_to_list(ssh_object):
        """Add ssh object to ongoing ssh commands list."""
        CollectLogs.ongoing_ssh_commands.append(ssh_object)

    def stop_log_collection(self, last_line_of_event, collect_logs, zip_logs=False):
        """
        Stop log collection and collect logs if collect_logs == True.

        :param int last_line_of_event: Last line of eventlog.
        :param bool collect_logs: If True, collects logs.
        :param bool zip_logs: If True, zips logs.
        :return tuple: html_report, success
        """
        suite_variables = BuiltIn().get_variables()
        info("Test has ended. Collect logs.")
        if collect_logs:
            if "${SSH_COMMANDS}" in suite_variables or "@{SSH_COMMANDS}" in suite_variables:
                ssh_commands = BuiltIn().get_variable_value("${SSH_COMMANDS}")
                self.ssh.send_command_to_smod_by_ssh(ssh_commands, print_to_eventlog=True)
            if "${SPECIAL_LOG}" in suite_variables or "@{SPECIAL_LOG}" in suite_variables:
                special_log = BuiltIn().get_variable_value("${SPECIAL_LOG}")
                self.special_log_collection(special_log, add_timestamp=True)
            self.collect_ims(CollectLogs.ims_file_name)
            self.remove_file(f"{self.logger.log_dir}/ims_history*")  # Removing all ims_history files
            self.collect_snapshot()
            if "${COLLECT_SYSINFO}" in BuiltIn().get_variables() and BuiltIn().get_variable_value("${COLLECT_SYSINFO}"):
                self.collect_sysinfo()
            else:
                self.logger.debug("Sysinfo will not be collected. COLLECT_SYSINFO is set to False.")
        else:
            if BuiltIn().get_variable_value("${COLLECT_ONLY_IMS}", default=False):
                self.collect_ims(CollectLogs.ims_file_name)
            if BuiltIn().get_variable_value("${COLLECT_ONLY_SNAPSHOT}", default=False):
                self.collect_snapshot()
        self.admin.teardown_admin(connection="log_admin")
        if self.rfs:
            self.admin.teardown_admin(connection="log_admin_remote")
        self.collect_syslog(collect_logs)
        if self.rfs:
            self.rename_logs_to_5g_or_4g()
        self.stop_wireshark()
        if CollectLogs.ongoing_ssh_commands:
            for ssh_obj in CollectLogs.ongoing_ssh_commands:
                self.ssh.disconnect_ssh_connection(ssh_obj)
            CollectLogs.ongoing_ssh_commands = []
        self.ssh.ssh.reset_cache()
        self.logger.stop_test_script_debug()
        self.write_eventlog_in_loops(last_line_of_event)
        if collect_logs and zip_logs:
            self.zip_all_logs()
        return self.html_report, self.success

    def log_admin_connection(self, ip=smod_ip):
        """
        Log admin connection setup.
        :param str ip: IP address of the BTS. Default is smod_ip.
        """
        if ip == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        if self.rfs:
            remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
            other_master = BuiltIn().get_variable_value("${MASTER}") == "Other"
            release = self.bts.get_sw_release_via_targetbd(lmp_ip=remote_mplane_ip)
            self.admin.setup_admin(bts_host=ip, update_interval=250,
                                   name="log_admin" if not other_master else "log_admin_remote",
                                   admin_api_log_dir=self.logger.create_admin_folder(), release=release)
            self.admin.setup_admin(bts_host=remote_mplane_ip, update_interval=250,
                                   name="log_admin" if other_master else "log_admin_remote",
                                   admin_api_log_dir=self.logger.create_admin_folder(), release=release)
        else:
            release = self.bts.get_sw_release_via_targetbd()
            self.admin.setup_admin(bts_host=ip, update_interval=250, name="log_admin",
                                   admin_api_log_dir=self.logger.create_admin_folder(), release=release)

    def setup_admin_connection(self):
        """
        Setup admin connection sets paths to snapshot_file_name and ims_file_name and creates admin connections to local
         and remote bts.
        """
        info("Setup admin connection for IMS/Snapshot collection.")
        if "Test_logs" not in self.logger.log_dir:
            info("No Test_logs in the name of test logs, update it before admin connection setup")
            self.logger.log_dir = self.logger.get_name_of_test_log_folder()
        info("Log dir: {}".format(self.logger.log_dir))
        CollectLogs.ims_file_name = os.path.join(self.logger.log_dir, self.get_target_name("IMS", file_type=".ims2"))
        CollectLogs.snapshot_file_name = os.path.join(self.logger.log_dir,
                                                      self.get_target_name("Snapshot", file_type=".zip"))
        try_ctr = 0
        while try_ctr <= 3:
            try:
                try_ctr += 1
                self.log_admin_connection()
                break
            except (AliasInUse, AdminApiConnectionClosedException, AliasLookupError) as e:
                try:
                    self.logger.debug(
                        f"AliasInUse, AliasLookupError or AdminApiConnectionClosedException Error during "
                        f"setup_admin_connection: {e.__class__.__name__}:{e}.")
                    self.logger.debug("Teardown admin before re-trying.")
                    self.admin.teardown_admin(connection="log_admin")
                    if self.rfs:
                        self.admin.teardown_admin(connection="log_admin_remote")
                    self.log_admin_connection()
                    break
                except (AliasInUse, AdminApiConnectionClosedException, AliasLookupError) as e:
                    info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                    error(f"Loop {self.logger.loop + 1}: Error during setup_admin_connection: "
                          f"{e.__class__.__name__}:{e}.")

    def start_syslog_collection(self, swconfig_path=""):
        """
        Starts syslog collection, uses btslog for collecting. Version of btslog should not matter.
        Log_dir refers here to the folder to which btslog saves the udp logs. In our tests, it is defined as
        /tmp/btslog. When manually starting btslog in UTE the folder is /tmp/btslog2 or /tmp/btslog4 depending on the
        version of btslog that is installed on the test pc. Log path can be changed with suite variable SYSLOG_FILE_PATH
        :param str swconfig_path: (OPTIONAL) If swconfig file is already collected and path to it is given, we will
                                  check if syslog is enabled in swconfig file before starting syslog collection. If not
                                  given, we will try to collect swconfig file and check if syslog is enabled in it. If
                                  there is no swconfig file or we are not able to verify that syslog is enabled in
                                  swconfig file, we will write an error to event log and continue with starting syslog.

        """
        if os.name != "nt":
            try:
                if not os.path.exists("/opt/btslog"):
                    error(f"Loop {self.logger.loop + 1}: BTSlog is not installed to path /opt/btslog -> unable to "
                          f"start syslog.")
                    raise EnvironmentIssue
                if not self.swconfig.check_that_there_is_flag_in_swconfig({"0x10041": "5"}, bts_ip=CollectLogs.smod_ip,
                                                                          sw_config_file_on_local_pc=swconfig_path):
                    error(f"Loop {self.logger.loop + 1}: We weren't able verify if syslog is enabled in swconfig.txt."
                          f"If there is no syslogs, BTSLog is not started, then check the swconfig.txt manually. "
                          f"Flag 0x10041=5 should be added to the file. Set KW_SUCCESS to false so we will have some "
                          f"logs to analyze.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    # raise EnvironmentIssue
                self.get_debian_version_and_set_log_folder()
                if not os.path.exists(CollectLogs.syslog_log_folder):
                    info(f"Folder {CollectLogs.syslog_log_folder} not found. Create it.")
                    os.mkdir(CollectLogs.syslog_log_folder)
                else:  # no need to check if just created folder
                    self.check_that_syslog_dir_is_empty()
                self._check_if_syslog_processes()
                info("Start syslog collection.")
                self.syslog.create_btslog_collector(name="syslog", log_dir=CollectLogs.syslog_log_folder,
                                                    start_timeout=180, syslog_timeout=180, teardown_timeout=180)
                self.core.setup_collectors(names="syslog")
                self.core.start_collectors(names="syslog")
                self.syslog.set_suite_alias("syslog")
                BuiltIn().sleep(5)
                content_of_syslog_folder = os.listdir(CollectLogs.syslog_log_folder)
                if not content_of_syslog_folder or (content_of_syslog_folder and
                                                    not any("SYSLOG_" in s_log for s_log in content_of_syslog_folder)):
                    info("No SYSLOG_ files in folder. BTSLog2 has a bug that syslog collection sometimes needs to be "
                         "stopped and restarted. Stop and start collectors again.")
                    self.core.stop_collectors(names="syslog")
                    BuiltIn().sleep(5)
                    self.core.start_collectors(names="syslog")
                    BuiltIn().sleep(5)
            except (AttributeError, TypeError, TimeoutError, FileNotFoundError, ExecutionError,
                    ValueError, OSError) as exception:
                if "No space left on device" in str(exception):
                    error(f"{exception.__class__.__name__}:{exception}")
                    self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                    BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")
                warning(f"Error during starting of syslog: {exception.__class__.__name__}:{exception}.")
                info(f"{''.join(format_exception(type(exception), exception, exception.__traceback__))}")
        else:
            warning("There is no support for Windows OS in taf syslog libraries, cannot start syslog.")

    def _ssh_to_remote_site_to_set_btslog_folder(self, remote_user, remote_pw, remote_vm_ip, remote_log_dir, re_try=0):
        """Ssh to remote site to set btslog folder"""
        try:
            output = self.ssh.connection_command_and_output(command=remote_log_dir, ip=remote_vm_ip,
                                                            username=remote_user, password=remote_pw)
            if "Is a directory" not in output:
                self.ssh.connection_command_and_output(command=f"mkdir {remote_log_dir}", ip=remote_vm_ip,
                                                       username=remote_user, password=remote_pw)
            else:
                content = self.ssh.connection_command_and_output(command=f"ls {remote_log_dir}", ip=remote_vm_ip,
                                                                 username=remote_user, password=remote_pw)
                content = content.replace("\n", "").replace("\t", "  ")
                info(f"Empty content of remote syslog folder {remote_log_dir}.\n (Content before clearing: {content}).")
                self.ssh.connection_command_and_output(
                    command=f"rm {remote_log_dir}/SYSLOG_* | rm {remote_log_dir}/BTSLOG_TRACE_*", ip=remote_vm_ip,
                    username=remote_user, password=remote_pw)
        except (CommandExecutionError, ConnectFailedError, AliasLookupError, TimeoutError, ExecutionError,
                EOFError, ValueError, AttributeError, SSHConnectionFailure) as ssh_error:
            if re_try >= 3:
                error(f"Problems with SSH in _ssh_to_remote_site_to_set_btslog_folder: {ssh_error.__class__.__name__}:"
                      f"{ssh_error}")
                info(f"{''.join(format_exception(type(ssh_error), ssh_error, ssh_error.__traceback__))}\nSet KW_SUCCESS"
                     f" to false so we will have logs to analyze.")
                BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            else:
                re_try += 1
                warning(f"Problems with SSH in _ssh_to_remote_site_to_set_btslog_folder:{ssh_error.__class__.__name__}:"
                        f"{ssh_error}. Re-try ({re_try}.).")
                info(f"{''.join(format_exception(type(ssh_error), ssh_error, ssh_error.__traceback__))}.")
                self._ssh_to_remote_site_to_set_btslog_folder(remote_user, remote_pw, remote_vm_ip, remote_log_dir,
                                                              re_try=re_try)

    def _check_if_btslog_is_running_on_remote(self, remote_user, remote_pw, remote_vm_ip, remote_log_dir, re_try=0):
        """Check if btslog is running on remote"""
        try:
            content = self.ssh.connection_command_and_output(command=f"ls {remote_log_dir}", ip=remote_vm_ip,
                                                             username=remote_user, password=remote_pw)
            if not content or (content and "SYSLOG_" not in content):
                info("No syslog files in remote syslog folder. BTSLog2 has a bug that syslog collection sometimes needs"
                     " to be stopped and restarted. Stop and start remote collectors again.")
                self.core.stop_collectors(names="syslog_remote")
                BuiltIn().sleep(5)
                self.core.start_collectors(names="syslog_remote")
                BuiltIn().sleep(5)
        except (CommandExecutionError, ConnectFailedError, AliasLookupError, TimeoutError, ExecutionError,
                EOFError, ValueError, AttributeError) as s_error:
            if re_try >= 3:
                info(f"{''.join(format_exception(type(s_error), s_error, s_error.__traceback__))}\nSet KW_SUCCESS to "
                     f"false so we will have logs to analyze.")
                error(f"Problems with SSH when checking if btslog is running on remote: {s_error.__class__.__name__}:"
                      f"{s_error}")
                BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            else:
                re_try += 1
                info(f"{''.join(format_exception(type(s_error), s_error, s_error.__traceback__))}.")
                warning(f"Problems with SSH when checking if btslog is running on remote:{s_error.__class__.__name__}:"
                        f"{s_error}. Re-try ({re_try}.).")
                self._ssh_to_remote_site_to_set_btslog_folder(remote_user, remote_pw, remote_vm_ip, remote_log_dir,
                                                              re_try=re_try)

    def start_remote_syslog_collection(self):
        """Start remote syslog collection"""
        info("Start remote syslog collection")
        remote_user = "ute"
        ip_pw = RFS().find_remote_vm_ip()
        info(f"Remote VM IP: {ip_pw[0]}")
        self.logger.debug(f"Pw in init is: {ip_pw[1]} it is not valid so using empty instead")
        CollectLogs.remote_vm_ip = str(ip_pw[0])
        CollectLogs.remote_vm_pw = ""
        self.logger.debug("Create folder for remote syslogs")
        print("Create folder for remote syslogs")
        os.makedirs("/home/ute/logs/remote_syslog", exist_ok=True)
        remote_log_dir = CollectLogs.syslog_log_folder
        try:
            self._ssh_to_remote_site_to_set_btslog_folder(remote_user, CollectLogs.remote_vm_pw,
                                                          CollectLogs.remote_vm_ip, remote_log_dir)
        except SSHConnectionFailure as ex:
            info(f"{''.join(format_exception(type(ex), ex, ex.__traceback__))}")
            warning(f"SSH connection to remote VM was not successful. {ex.__class__.__name__}:{ex}")
        try:
            # change BTSLog settings on remote VM
            info("Get BTSLog config file from remote VM and change BTSLog settings")
            config_file_from_remote = self.get_file_or_folder_by_scp(
                '/home/ute/btslog2/btslog.ini', CollectLogs.remote_vm_ip, "ute", CollectLogs.remote_vm_pw,
                local_dir="/tmp")
            info("Modify the btslog.ini file")
            ChangeSyslog.change_syslog_file_path(config_file_path=config_file_from_remote)
            self.upload_file_or_folder_by_scp('/home/ute/btslog2/btslog.ini', CollectLogs.remote_vm_ip, "ute",
                                              CollectLogs.remote_vm_pw, config_file_from_remote, scp_timeout=900)
            executor_remote = {"host": CollectLogs.remote_vm_ip, "user": remote_user,
                               "password": CollectLogs.remote_vm_pw}
            self.syslog.create_btslog_collector(name="syslog_remote", log_dir=remote_log_dir, executor=executor_remote,
                                                start_timeout=60, syslog_timeout=60)
            self.core.setup_collectors(names="syslog_remote")
            self.core.start_collectors(names="syslog_remote")
            self.syslog.set_suite_alias("syslog_remote")
        except (CommandExecutionError, ConnectFailedError, AliasLookupError, TimeoutError, ExecutionError,
                EOFError, ValueError, AttributeError, OSError) as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"Problems with starting remote bts collectors {e.__class__.__name__}:{e}")
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            if "No space left on device" in str(e):
                self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")
        BuiltIn().sleep(5)
        self._check_if_btslog_is_running_on_remote(remote_user, CollectLogs.remote_vm_pw, CollectLogs.remote_vm_ip,
                                                   remote_log_dir)

    def zip_all_logs(self, swdl_zip=False):
        """Zip all logs of loop to all_logs.zip."""
        if swdl_zip:
            if CollectLogs.folders_for_zip_and_remove:
                self.logger.debug("Content of folders_for_zip_and_remove: {}".format(
                    CollectLogs.folders_for_zip_and_remove))
                loop_eventlog = os.path.join(self.logger.log_dir, self.loop_event_log)
                for swdl_log in CollectLogs.folders_for_zip_and_remove:
                    self.copy_file_to_folder(loop_eventlog, swdl_log)
        else:
            if self.rfs:
                logs_to_be_collected = [os.path.join(self.logger.log_dir, self.loop_event_log)]
            else:
                logs_to_be_collected = [CollectLogs.snapshot_file_name,
                                        CollectLogs.ims_file_name,
                                        f"{self.logger.log_dir}/syslog/syslog_files.tgz",
                                        os.path.join(self.logger.log_dir, self.loop_event_log)]
            if CollectLogs.zip_extra_file:
                logs_to_be_collected.append(CollectLogs.zip_extra_file)
            if self.rfs:
                snapshots = self.check_if_file_is_in_logs(
                    "snapshot", path_for_search=self.logger.log_dir, return_file_path=True, return_multiple_files=True)
                ims_files = self.check_if_file_is_in_logs(
                    "IMS_", path_for_search=self.logger.log_dir, return_file_path=True, return_multiple_files=True)
                syslogs = self.check_if_file_is_in_logs(
                    "syslog_files.tgz", path_for_search=self.logger.log_dir, return_file_path=True,
                    return_multiple_files=True)
                logs_to_be_collected.extend(snapshots)
                logs_to_be_collected.extend(ims_files)
                logs_to_be_collected.extend(syslogs)
            zipped_file_name = "all_logs.zip"
            self.add_files_to_zip(zipped_file_name, logs_to_be_collected, remove_path_from_file=True)

    def collect_ims(self, ims_file=None, connection="log_admin", swdl=False, extra_name=""):
        """
        Collect ims file.

        :param str ims_file: Path to ims file.
        :param str connection: Admin connection name. Default is log_admin.
        :param bool swdl: If set True, doesn't write error and do not fail the test.
        :param str extra_name: Extra name for the ims file.

        :return str: Path to ims file.
        """
        info("Collect IMS logs.")
        if not ims_file and extra_name:
            ims_file = os.path.join(self.logger.log_dir, f"IMS_{extra_name}.ims2")
            if "CellPlanActivation_test" in extra_name:
                CollectLogs.zip_extra_file = os.path.join(self.logger.log_dir, f"IMS_{extra_name}.ims2")
        elif not ims_file:
            if not CollectLogs.ims_file_name:
                CollectLogs.ims_file_name = os.path.join(self.logger.log_dir, self.get_target_name(
                    "IMS", file_type=".ims2"))
            ims_file = CollectLogs.ims_file_name
        output = self.try_to_collect_log("IMS logs", file_path=ims_file, connection_name=connection)
        if output != "IMS logs OK":
            if swdl:
                info("IMS logs could not be collected, error {}. This will not fail the test because connection to "
                     "BTS may be lost after SWDL before collection of ims2 is completed.".format(output))
            else:
                output = self.try_to_collect_log("IMS logs", file_path=ims_file, connection_name=connection,
                                                 try_time=2)
                if output != "IMS logs OK":
                    error(f"Loop {self.logger.loop + 1}: IMS logs could not be collected, error {output}.")
                    self.success = False
                else:
                    info("IMS was successfully saved to: {}".format(ims_file))
                    if not CollectLogs.ims_file_name:
                        CollectLogs.ims_file_name = ims_file
        else:
            if swdl:
                CollectLogs.ims_get_after_swdl = True
            info("IMS file was successfully saved to: {}".format(ims_file))
            if not CollectLogs.ims_file_name:
                CollectLogs.ims_file_name = ims_file
        return ims_file

    def _restart_admin_and_try_collect_log(self, log_to_collect, file_path="", connection_name="log_admin", try_time=0,
                                           extra_name="", coverage="Full", reg_exp_filter=None, no_rfs=False):
        """Restart admin connection and try to collect log again."""
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        self.bts.reset_admin_connection(admin=connection_name)
        if self.rfs and not no_rfs:
            self.bts.reset_admin_connection(admin="log_admin_remote")
        BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
        self.try_to_collect_log(log_to_collect=log_to_collect, file_path=file_path,
                                connection_name=connection_name, try_time=try_time, extra_name=extra_name,
                                coverage=coverage, reg_exp_filter=reg_exp_filter, no_rfs=no_rfs, retry=1)

    def try_to_collect_log(self, log_to_collect, file_path="", connection_name="log_admin", try_time=0,
                           extra_name="", coverage="Full", reg_exp_filter=None, no_rfs=False, just_remote=False,
                           retry=0):
        """
        This try to collect log includes error handling.

        :param str log_to_collect: Name of the log to collect.
        :param str file_path: Path to file.
        :param str connection_name: Admin connection name. Default is log_admin.
        :param int try_time: How many times to try to collect log.
        :param str extra_name: Extra name for the file.
        :param str coverage: Coverage for snapshot. e.g. FullWithoutRFLogs. Default is Full.
        :param str reg_exp_filter: Regular expression filter for snapshot.
        :param bool no_rfs: If set True, doesn't collect logs from remote RFS.
        :param bool just_remote: If set True, collects log only from remote BTS.
        :param int retry: If retry is 0 and error code 6 occurs then tries to collect logs again.
        :return str: Output of the log collection.
        """
        if try_time != 0:
            info("{}. try to collect {}.".format(try_time, log_to_collect))
        try:
            if log_to_collect == "Snapshot":
                f_name_path = os.path.join(self.logger.log_dir, self.get_target_name("Snapshot", file_type=".zip"))
                # CollectLogs.snapshot_file_name
                if extra_name:
                    f_name_path = f_name_path.replace(".zip", "_{}.zip".format(extra_name))
                elif file_path:
                    f_name_path = file_path
                CollectLogs.snapshot_file_name = f_name_path
                if not just_remote:  # doesn't collect from the tested side if just_remote is True
                    self.admin.get_snapshot(f_name_path, timeout=1200, connection=connection_name, coverage=coverage,
                                            reg_exp_filter=reg_exp_filter)
                    info("Snapshot collected to {}".format(f_name_path))
                if self.rfs and not no_rfs:
                    CollectLogs.snapshot_file_remote = CollectLogs.snapshot_file_name.replace(".zip", "_remote.zip")
                    self.admin.get_snapshot(CollectLogs.snapshot_file_remote, timeout=1200,
                                            connection="log_admin_remote", coverage=coverage,
                                            reg_exp_filter=reg_exp_filter)
                    info(f"Snapshot from remote collected to {CollectLogs.snapshot_file_remote}")
            elif log_to_collect == "IMS logs":
                if not file_path:
                    file_path = os.path.join(self.logger.log_dir, self.get_target_name("IMS", file_type=".ims2"))
                if extra_name:
                    file_path = file_path.replace(".ims2", "_{}.ims2".format(extra_name))

                self.admin.collect_infomodel_log_from_current_session(file_path, timeout=900,
                                                                      connection=connection_name)
                if self.rfs and not no_rfs:
                    self.admin.collect_infomodel_log_from_current_session(file_path.replace(".ims2", "_remote.ims2"),
                                                                          timeout=900, connection="log_admin_remote")
                    info(f"IMS was successfully saved from remote to: {file_path.replace('.ims2', '_remote.ims2')}")
            return "{} OK".format(log_to_collect)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
                AdminApiNoResponseException, AdminApiConnectionClosedException,
                AdminApiTerminatedException, AliasLookupError, OSError) as exception:
            tb = ''.join(format_exception(type(exception), exception, exception.__traceback__))
            info(tb)
            if "No space left on device" in str(exception):
                self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                error(f"{exception.__class__.__name__}:{exception}")
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")
            if "ErrorCode: 69" in tb or "No collection files exist." in tb:
                warning(f"{log_to_collect} could not be collected, error: {exception.__class__.__name__}:{exception}\n"
                        f"\nErrorCode 69 means that there has been timeout error. WAIT 15min.")
                BuiltIn().sleep(900)
            elif "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    warning(f"{log_to_collect} could not be collected, error: {exception.__class__.__name__}:"
                            f"{exception}\nRestart admin connection and try again.")
                    self._restart_admin_and_try_collect_log(log_to_collect, file_path=file_path,
                                                            connection_name=connection_name, try_time=try_time,
                                                            extra_name=extra_name, coverage=coverage,
                                                            reg_exp_filter=reg_exp_filter, no_rfs=no_rfs)
            elif exception.__class__.__name__ == "AdminApiProcedureTimeoutException":
                warning(f"Timeout when collecting {log_to_collect}, error {exception.__class__.__name__}:{exception}."
                        f" Try again.")
            elif exception.__class__.__name__ in ("AdminApiProcedureFailureException", "AdminApiNoResponseException"):
                warning("{} could not be collected, error: {}:{}\n{}. Try again.".format(
                    log_to_collect, exception.__class__.__name__, exception, tb))
            else:
                warning("{} could not be collected, no connection to admin. Error: {}:{}\n{}. Restart admin "
                        "connection and try again.".format(log_to_collect, exception.__class__.__name__, exception, tb))
                if retry == 0:
                    self._restart_admin_and_try_collect_log(log_to_collect, file_path=file_path,
                                                            connection_name=connection_name, try_time=try_time,
                                                            extra_name=extra_name, coverage=coverage,
                                                            reg_exp_filter=reg_exp_filter, no_rfs=no_rfs)
            return exception.__class__.__name__

    def collect_snapshot(self, extra_name="", snapshot_path="", connection_name="log_admin", coverage="Full",
                         reg_exp_filter=None, no_rfs=False, just_remote=False):
        """
        Collect snapshot file.

        :param str extra_name: Extra name for snapshot file.
        :param str snapshot_path: Special path to snapshot file.
        :param str connection_name: Admin connection name. Default is log_admin.
        :param str coverage: Snapshot coverage. e.g. FullWithoutRFLogs. Default is Full.
        :param str reg_exp_filter: Regular expression filter for snapshot.
        :param bool no_rfs: If set True, doesn't collect snapshot from remote RFS.
        :param bool just_remote: If set True, collects snapshot only from remote BTS.
        """
        if (CollectLogs.snapshot_file_name and
                os.path.exists(CollectLogs.snapshot_file_name) and os.path.isfile(CollectLogs.snapshot_file_name) and
                os.path.getsize(CollectLogs.snapshot_file_name) > 5000):
            info(f"Snapshot is already collected '{CollectLogs.snapshot_file_name}'. No need to collect it again.")
            return
        info("Collecting Snapshot...")
        output = ""
        try_time = 0
        while try_time < 4 and output != "Snapshot OK":
            try_time += 1
            if try_time == 1:
                output = self.try_to_collect_log("Snapshot", extra_name=extra_name, file_path=snapshot_path,
                                                 connection_name=connection_name, coverage=coverage,
                                                 reg_exp_filter=reg_exp_filter, no_rfs=no_rfs, just_remote=just_remote)
            else:
                output = self.try_to_collect_log("Snapshot", try_time=try_time, extra_name=extra_name,
                                                 file_path=snapshot_path, connection_name=connection_name,
                                                 coverage=coverage, reg_exp_filter=reg_exp_filter, no_rfs=no_rfs)
            if (CollectLogs.snapshot_file_name and os.path.exists(CollectLogs.snapshot_file_name) and
                    os.path.isfile(CollectLogs.snapshot_file_name) and os.path.getsize(
                        CollectLogs.snapshot_file_name) > 6000):
                self.logger.debug(f"Snapshot is now collected '{CollectLogs.snapshot_file_name}' exit while loop.")
                output = "Snapshot OK"
                break
        if output != "Snapshot OK":
            warning(f"Loop {self.logger.loop + 1}: Could not collect snapshot by admin connection, error {output}.")
            info("Try to collect snapshot by using ssh.")
            snapshot_by_ssh_success = self.collect_special_snapshot(re_attempt=True, extra_name=extra_name)
            if not snapshot_by_ssh_success:
                info("Snapshot could not be collected from SSH. Check if BTS is still reachable and replies to ping and"
                     " try again.")
                snapshot_by_ssh_success = self.collect_special_snapshot(re_attempt=True, extra_name=extra_name,
                                                                        check_reply_to_ping=True)
            if not snapshot_by_ssh_success:
                error(f"Loop {self.logger.loop + 1}: Snapshot could not be collected. Not by admin nor by ssh.")
            else:
                info(f"Snapshot could not be collected from admin (error {output}), but \nwe were able to collect the "
                     f"snapshot successfully by ssh.")
            self.success = False
            return
        info("Snapshot was successfully saved.")

    def collect_special_snapshot(self, smod=None, re_attempt=True, bts_ip=smod_ip, extra_name="",
                                 check_reply_to_ping=False):
        """
        Collect special snapshot collects snapshot by using ssh command instead of admin command.

        :param smod: SMOD object from which to collect special snapshot.
        :param bool re_attempt: If set True, tries to collect snapshot again.
        :param str bts_ip: BTS IP address.
        :param str extra_name: Extra name for the snapshot file.
        :param bool check_reply_to_ping: If set True, checks if bts_ip replies to ping.
        """
        log_name = ""
        if bts_ip == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                bts_ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        if check_reply_to_ping:
            if not self.bts:
                self.bts = BuiltIn().get_library_instance("BTS")
            if not self.bts.ping_ip_until_disconnection_or_reconnection(
                    ip_to_ping=bts_ip, disconnection=False, time_to_wait=600, save_pings_to_file=True,
                    boolean_return=True, ping_answers=3, ignore_rfs_ip_changes=False):
                error(f"Unable to collect snapshot by ssh, because {bts_ip} does not reply to ping.")
                return ""
        if smod:
            info(f"Collecting special snapshot from {smod.name}...")
        else:
            self.logger.debug("No smod given")
            info(f"Collecting special snapshot from {bts_ip}...")
        output = self.ssh.send_command_to_smod_by_ssh(
            ["telnet localhost 15007", "log -a -z special_snapshot.zip"], return_output=True, ssh_timeout=600,
            print_to_eventlog=False, name_for_log="collect_special_snapshot", ip_to_connect=bts_ip)
        if "Log collection finished" in output:
            info("Special snapshot is saved in /ram -folder. Download it to log directory.")
            log_path = self.logger.log_dir
            if not os.path.exists(log_path):
                if "loop" in self.logger.log_dir:
                    log_path = self.logger.log_dir[:self.logger.log_dir.rfind("/loop")]
                    if not os.path.exists(log_path):
                        log_path = self.logger.log_dir[:self.logger.log_dir.rfind("/")]
            f_name = "special_snapshot.zip" if not extra_name else f"{extra_name}_snapshot.zip"
            log_name = os.path.join(log_path, f_name)
            # self.ssh.download_file(
            #     "/ram/special_snapshot.zip", os.path.join(self.logger.log_dir, "special_snapshot.zip"))
            # Collect logs to test folder
            self.get_file_or_folder_by_scp("/ram/special_snapshot.zip", bts_ip, "toor4nsn", "oZPS0POrRieRtu",
                                           local_dir=log_name, update_name=False)
        elif re_attempt:
            info("Special snapshot collection failed. Try again.")
            self.collect_special_snapshot(smod=smod, re_attempt=False, bts_ip=bts_ip, extra_name=extra_name)
        else:
            info("Special snapshot collection failed.")
            return ""
        return log_name

    @staticmethod
    def _swap_file_names(file1, file2):
        try:
            temp_file = file1 + '.temp'
            os.rename(file1, temp_file)
            os.rename(file2, file1)
            os.rename(temp_file, file2)
        except OSError as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"{e.__class__.__name__}:{e}")
            if "No space left on device" in str(e):
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def collect_syslog(self, collect_logs=True):
        """
        Stop syslog and collect syslog files from /tmp/btslog2 or /tmp/btslog4, path depends of debian version.
        :param bool collect_logs: If set False, doesn't collect logs.
        """
        if os.name != "nt":
            try:
                info("Stop btslog.")
                self.core.stop_collectors(names="syslog")
                if self.rfs:
                    self.core.stop_collectors(names="syslog_remote")
                if collect_logs or BuiltIn().get_variable_value("${COLLECT_ONLY_SYSLOG}", default=False):
                    info("Collect syslogs.")
                    self.core.collect_collectors(names="syslog", target_dir=self.logger.log_dir)
                    if self.rfs or BuiltIn().get_variable_value("${HIGH_AVAILABILITY_ENVIRONMENT}", default=False):
                        self.core.collect_collectors(names="syslog_remote", target_dir=self.logger.log_dir)
                        other_master = BuiltIn().get_variable_value("${MASTER}") == "Other"
                        if other_master:
                            self._swap_file_names(f"{self.logger.log_dir}/syslog/syslog_files.tgz",
                                                  f"{self.logger.log_dir}/syslog_remote/syslog_files.tgz")
                    info(f"Syslogs were saved to: {self.logger.log_dir}/syslog")
                self.core.teardown_collectors(names="syslog", force=True)
                if self.rfs or BuiltIn().get_variable_value("${HIGH_AVAILABILITY_ENVIRONMENT}", default=False):
                    self.core.teardown_collectors(names="syslog_remote", force=True)
                # clear found syslog prints to avoid printing them again in next loop
                if not self.syslog_search:
                    self.syslog_search = BuiltIn().get_library_instance("SYSLOGSEARCH")
                self.syslog_search.found_syslog_prints = {}
            except (AttributeError, TypeError, TimeoutError, FileNotFoundError, ExecutionError,
                    ValueError, OSError) as exception:
                info(f"{''.join(format_exception(type(exception), exception, exception.__traceback__))}")
                if "No space left on device" in str(exception):
                    self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                    error(f"{exception.__class__.__name__}:{exception}")
                    BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")
                warning(f"Error during Syslogs collection: {exception.__class__.__name__}:{exception}.")
                info("Because there were exception during stopping of syslog, ensure that syslog really is stopped.")
                self._check_if_syslog_processes()
                info(f"Because there were {exception.__class__.__name__}, we need to try to get syslogs again.")
                syslog_files = self.get_all_files_from_directory(CollectLogs.syslog_log_folder)
                self.add_files_to_zip("syslogs.zip", syslog_files)  # Local folder
                if self.rfs or BuiltIn().get_variable_value("${HIGH_AVAILABILITY_ENVIRONMENT}", default=False):
                    remote_syslog_files = self.get_all_files_from_directory("/home/ute/logs/remote_syslog")
                    if remote_syslog_files:
                        self.add_files_to_zip("remote_syslogs.zip", remote_syslog_files)
                    else:
                        info("No logs in local /home/ute/logs/remote_syslog. Try to get folder from remote VM with scp")
                        syslog_filepath = self.get_file_or_folder_by_scp(
                            CollectLogs.syslog_log_folder, CollectLogs.remote_vm_ip, "ute", CollectLogs.remote_vm_pw,
                            local_dir="/home/ute/logs/remote_syslog")
                        remote_syslog_files = self.get_all_files_from_directory(syslog_filepath)
                        if remote_syslog_files:
                            self.add_files_to_zip("remote_syslogs.zip", remote_syslog_files)
        else:
            warning("There is no support for Windows OS in taf syslog libraries, cannot collect syslog.")

    def collect_sysinfo(self):
        """Collect sysinfo from the BTS used for testing"""
        info("Collect sysinfo.")
        try:
            # sysinfo = self.ssh.connection_command_and_output("sysinfo", alias="SYSINFO", timeout="120 s")
            sysinfo = self.ssh.send_command_to_smod_by_ssh("sysinfo", return_output=True, print_to_eventlog=False,
                                                           ssh_timeout=600, name_for_log="to_smod_get_sysinfo")
            with open(os.path.join(self.logger.log_dir, "sysinfo.txt"), "w") as log:
                log.write(sysinfo)
        except CommandExecutionError as e:
            warning(f"Sysinfo.txt log was not collected: {e}\n"
                    f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    def check_that_syslog_dir_is_empty(self):
        """Check that syslog dir is empty. If not, delete all files from it."""
        self.logger.debug("Check that there are no syslog from previous test runs. If is, delete them.")
        stuff_in_dir = os.listdir(CollectLogs.syslog_log_folder)
        if stuff_in_dir:
            self.logger.debug(
                f"Old files {stuff_in_dir} found from {CollectLogs.syslog_log_folder}. Delete them before "
                f"starting syslog.")
            for sf in stuff_in_dir:
                if "SYSLOG_" in sf or "BTSLOG_TRACE_" in sf or "syslog_files.tgz" in sf:
                    os.remove(os.path.join(CollectLogs.syslog_log_folder, sf))
            self.logger.debug(
                "Old files removed. Content of dir {}: {}.".format(
                    CollectLogs.syslog_log_folder, os.listdir(CollectLogs.syslog_log_folder)))
        else:
            self.logger.debug("Syslog dir is empty, no logs from previous test runs.")

    def get_last_line_of_eventlog(self):
        """Get index of the latest line of eventlog."""
        last_line_index = 0
        self.logger.debug("Path to eventlog is {}, getting last line...".format(self.logger.get_path_of_eventlog()))
        if not self.logger.get_path_of_eventlog():
            error(f"Loop {self.logger.loop + 1}: There is no eventlog!")
            raise EnvironmentIssue
        with open(self.logger.get_path_of_eventlog(), "r") as f:
            lines = f.read().splitlines()
            if lines:
                last_line = lines[-1]
                last_line_index = lines.index(last_line)
                self.logger.debug('Last line: {}'.format(last_line))
                info("Index of last line of eventlog is {}".format(last_line_index))
            else:
                warning("Eventlog is empty! Cannot get last line of eventlog.")
        return last_line_index

    def write_eventlog_in_loops(self, start_line_of_eventlog):
        """
        Write eventlog in loops.
        :param int start_line_of_eventlog: Line from which eventlog is written in the loop.
        """
        self.loop_event_log = "Eventlog_{}_loop_{}.log".format(
            get_builtin_value("TEST NAME").replace(' ', '_'), self.logger.loop+1)

        info("Write from line {} to new loop eventlog file {}".format(start_line_of_eventlog, self.loop_event_log))
        with open(self.logger.get_path_of_eventlog(), "r") as master_event, \
                open(os.path.join(self.logger.log_dir, self.loop_event_log), "w") as loop_event:
            self.logger.debug("Reading and in writing in write_eventlog_in_loops")
            lines = master_event.read().splitlines()
            lines_to_loop_event = lines[start_line_of_eventlog:]
            for loop_line in lines_to_loop_event:
                loop_event.write("{}\n".format(loop_line))

    def get_ute_cloud_init_file(self):
        """Copy ute cloud init file to logs."""
        CollectLogs.main_pid = os.getpid()
        self.logger.debug("Main PID: {}".format(CollectLogs.main_pid))
        if self.bts.path_to_ute_env_init:
            command = "cp {} {}/ute_env_init_file.txt".format(self.bts.path_to_ute_env_init, self.logger.suite_folder)
            handle = os.popen("{}".format(command))
            output = "".join(handle.readlines())
            handle.close()
            info("Copy ute cloud init file to logs: {}".format(output))
        else:
            info("There is no path to __init__.py file, will not collect it ")

    @staticmethod
    def get_target_name(name, file_type=""):
        """
        Add timestamp to given file.
        :param str name: Name of the file, for example Snapshot.
        :param str file_type: Type of the file, for example .zip.
        """
        time = datetime.now().strftime("%Y%m%d_%H%M%S")
        return "{}_{}{}".format(name, time, file_type)

    def move_file_to_folder(self, path_to_file_to_move, new_file_path):
        """
        Move file from to another folder.

        :param str path_to_file_to_move: Path to file to move.
        :param str new_file_path: New path for file.
        """
        try:
            print(f"Move {path_to_file_to_move} to {new_file_path}")
            self.logger.debug(f"Move {path_to_file_to_move} to {new_file_path}")
            shutil.move(path_to_file_to_move, new_file_path)
            print("File moved")
            return new_file_path
        except (shutil.Error, shutil.ExecError, shutil.ReadError, TypeError, AttributeError, FileNotFoundError) as e:
            print(''.join(format_exception(type(e), e, e.__traceback__)))
            return None

    def copy_file_or_folder_to_another_location(self, source_path, destination_path):
        """
        Copy file or folder to another location
        """
        try:
            if not os.path.exists(source_path):
                error(f"Source path {source_path} does not exist. Cannot copy file or folder.")
                return None
            print(f"Copy {source_path} to {destination_path}")
            self.logger.debug(f"Copy {source_path} to {destination_path}")
            shutil.copytree(source_path, destination_path, dirs_exist_ok=True)
        except (shutil.Error, shutil.ExecError, shutil.ReadError, TypeError, AttributeError, FileNotFoundError) as e:
            print(''.join(format_exception(type(e), e, e.__traceback__)))
            return None

    def move_disconnection_logs_to_admin_folder(self):
        """Move disconnect logs to admin folder."""
        log_files = os.listdir(self.logger.log_dir)
        base_names = []
        if CollectLogs.do_not_move:
            for nm in CollectLogs.do_not_move:
                base_names.append(os.path.basename(nm))
        self.logger.debug("Move listdir: {}".format(log_files))
        print("Move listdir: {}".format(log_files))
        if CollectLogs.do_not_move:
            print(f"Do not move: {CollectLogs.do_not_move}")
        for log_file in log_files:
            if os.path.isdir(os.path.join(self.logger.log_dir, log_file)):
                inner_folder = os.path.join(self.logger.log_dir, log_file)
                folder_in_log_files = os.listdir(inner_folder)
                for file_in_folder in folder_in_log_files:
                    if "_disconnect_at_" in file_in_folder:
                        if os.path.basename(file_in_folder) in base_names:
                            print(f"{file_in_folder} is used to KPI calculations. Do not move it to admin folder.")
                        elif "admin" not in folder_in_log_files:
                            if "admin" in log_files:
                                self.move_file_to_folder(os.path.join(inner_folder, file_in_folder),
                                                         os.path.join(self.logger.log_dir, "admin", file_in_folder))
                        else:
                            self.move_file_to_folder(os.path.join(inner_folder, file_in_folder),
                                                     os.path.join(inner_folder, "admin", file_in_folder))
            if "_disconnect_at_" in log_file:
                if os.path.basename(log_file) in base_names:
                    print(f"{log_file} was used to KPI calculations. Do not move it to admin folder.")
                else:
                    self.move_file_to_folder(os.path.join(self.logger.log_dir, log_file),
                                             os.path.join(self.logger.log_dir, "admin", log_file))

    def get_snapshot_and_delete_it(self):
        """
        Collect snapshot file and when collected deletes it. Used for cleaning purposes.
        """
        extra_snapshot_file = os.path.join(self.logger.log_dir, "ExtraSnapshot.zip")
        info("Collect extra snapshot to {}".format(extra_snapshot_file))
        self.collect_snapshot(snapshot_path=extra_snapshot_file)
        # snapshot = Snapshot()  # import needed, example usage
        # snapshot.check_ru_startup_info_print(extra_snapshot_file)
        info("Delete collected snapshot ({})".format(extra_snapshot_file))
        self.remove_file(extra_snapshot_file)

    def get_snapshot_and_ims_log(self, admin_connection="log_admin", info_text="before cleaning step", extra_name=""):
        """
        Collects snapshot file and ims2 log file. Useful for example before calling cleaning step.

        :param str admin_connection: Name of admin connection from which ims and snapshots are collected. Default
                                     value log_admin
        :param str info_text: Default value 'before cleaning step' can be given to tell to user why this is collected.
        :param str extra_name: Extra name for the files.
        """
        info("Collect snapshot and ims2 log {}.".format(info_text))
        f_time = datetime.now().strftime("%Y%m%d_%H%M%S")
        ims_file_path = os.path.join(self.logger.log_dir, "IMS_{}_{}.ims2".format(f_time, extra_name))
        self.collect_ims(ims_file=ims_file_path, connection=admin_connection)
        extra_snapshot_file = os.path.join(self.logger.log_dir, "Snapshot_{}_{}.zip".format(f_time, extra_name))
        self.collect_snapshot(snapshot_path=extra_snapshot_file, connection_name=admin_connection)
        info("Ims2 and snapshot logs collected.")

    def remove_file(self, path_to_file):
        """If file exists, deletes it."""
        if "*" in path_to_file:
            command = "rm -rf {}".format(path_to_file)
            handle = os.popen("{}".format(command))
            output = "".join(handle.readlines())
            handle.close()
            self.logger.debug("Removed files output: {}".format(output))
        else:
            if os.path.exists(path_to_file):
                command = "rm {}".format(path_to_file)
                handle = os.popen("{}".format(command))
                output = "".join(handle.readlines())
                handle.close()
                self.logger.debug("Remove file: {}".format(output))
            else:
                warning("File {} to be deleted doesn't exists. Cannot delete file.".format(path_to_file))

    def get_all_files_from_directory(self, dir_to_zip):
        """
        Gets all files from the given directory to list.

        :param str dir_to_zip: Directory that's all files are searched and added to list.
        :return list: List of files in the directory.
        """
        if not os.path.exists(dir_to_zip):
            error(f"Loop {self.logger.loop + 1}: Invalid path {dir_to_zip}. It doesn't exists.")
            raise EnvironmentIssue
        files_in_dir = []
        for root, directories, files in os.walk(dir_to_zip):  # walk through directory and subdirectories
            for filename in files:
                filepath = os.path.join(root, filename)  # form the full filepath.
                files_in_dir.append(filepath)
        self.logger.debug(f"Files in {dir_to_zip} are: {files_in_dir}")
        return files_in_dir

    def add_files_to_zip(self, name_for_zip, files_to_zip, remove_path_from_file=False, compress_level=None):
        """
        Adds files to zip.

        :param str name_for_zip: Name for the zip for example syslogs_truck_roll.zip
        :param list files_to_zip: List of files to be zipped for example ['/tmp/btslog4/SYSLOG_2.LOG',
                                  '/tmp/btslog4/SYSLOG_3.LOG']
        :param bool remove_path_from_file: Removes paths from files for zip
        :param int compress_level: Compression level for zip. Default is None.
        """
        try:
            zip_path = os.path.join(self.logger.log_dir, name_for_zip)
            with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED, compresslevel=compress_level) as zipf:
                for file in files_to_zip:
                    if os.path.exists(file):
                        if remove_path_from_file:
                            zipf.write(file, os.path.basename(file))
                        else:
                            zipf.write(file)
                        self.logger.debug(f"File to be added to zip: {file}")
                    else:
                        warning(f"File that should be be added to zip: {file} doesn't exists. Cannot be included in "
                                f"the zip.")
            self.logger.debug(f"All files zipped to {zip_path}")
        except OSError as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"{e.__class__.__name__}:{e}")
            if "No space left on device" in str(e):
                self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def check_if_file_is_in_logs(self, filename_to_search, path_for_search="", return_file_path=False,
                                 return_multiple_files=False, print_walk=False, file_of_remote=False,
                                 files_renamed_to_5g4g=True):
        """
        Check if file is in logs.

        :param str filename_to_search: Filename to search. For example "snapshot"
        :param str path_for_search: Path where to search. Default is empty and then the test case folder will be checked
        :param bool return_file_path: If set True, returns file path, otherwise returns True/False
        :param bool return_multiple_files: If set True, returns list of files, otherwise returns only one file path.
        :param bool print_walk: Print walk items to log.html and to test_script_debug*.txt
        :param bool file_of_remote: If check is done before renaming and we want to check the file of remote set to True
        :param bool files_renamed_to_5g4g: Default is True, but if check is done before renaming set this to false.
        :return bool/str/list: True if file is found, False if not or if return_file_path then path to the found file.
        """
        if path_for_search:
            tc_path = path_for_search
        else:
            tc_path = self._safe_split(self.logger.log_dir, "/loop_")[0]
        multiple_files = []
        if not filename_to_search:
            error(f"Loop {self.logger.loop + 1}: Filename to search is empty.")
            raise ScriptIssue("Filename to search is empty.")
        if print_walk:
            print(f"tc_path: {tc_path}")
            self.logger.debug(f"tc_path: {tc_path}")
        for log_path, folders_in_path, log_files in os.walk(tc_path):  # walk through directory and subdirectories
            if print_walk:
                print(f"log_path: {log_path}\nfolders_in_path: {folders_in_path}\nlog_files: {log_files}")
                self.logger.debug(f"log_path: {log_path}\nfolders_in_path: {folders_in_path}\nlog_files: {log_files}")
            if log_files:
                for f in log_files:
                    if filename_to_search.lower() in f.lower():
                        self.logger.debug(f"File {filename_to_search} found from logs ({log_path}/{f}).")
                        print(f"File {filename_to_search} found from logs ({log_path}/{f}).")
                        if return_file_path:
                            if return_multiple_files:
                                multiple_files.append(os.path.join(log_path, f))
                            else:
                                # Distinction of 4G and 5G snapshots for ims_analyser
                                if self.rfs and "snapshot" in filename_to_search.lower():
                                    master = BuiltIn().get_variable_value("${MASTER}")
                                    if master and (
                                            ("This" in master and "5G" in f) or ("Other" in master and "4G" in f)):
                                        return os.path.join(log_path, f)
                                    # if check is done before renaming using this check
                                    elif not files_renamed_to_5g4g:
                                        if (not file_of_remote and "remote" not in f.lower()) or (
                                                file_of_remote and "remote" in f.lower()):
                                            return os.path.join(log_path, f)
                                        else:
                                            continue
                                    else:
                                        continue
                                return os.path.join(log_path, f)
                        else:
                            return True
        if multiple_files:
            return multiple_files
        self.logger.debug(f"File {filename_to_search} not found from logs.")
        print(f"File {filename_to_search} not found from logs.")
        if return_file_path:
            return ""
        return False

    @staticmethod
    def remove_folder(folder, files_to_keep=None):
        """
        Delete folder and all it's content.

        :param str folder: Folder that will be destroyed.
        :param list files_to_keep: List of part of file names that will not be deleted.
        """
        if files_to_keep:
            for file_name in os.listdir(folder):
                if not any(file_part in file_name for file_part in files_to_keep):
                    file_path = os.path.join(folder, file_name)
                    if os.path.isdir(file_path):
                        shutil.rmtree(file_path)
                    else:
                        os.remove(file_path)
        else:  # this should be much faster
            if os.path.exists(folder):
                print("Remove folder: {}".format(folder))
                command = "rm -rf {}".format(folder)
                handle = os.popen("{}".format(command))
                output = "".join(handle.readlines())
                handle.close()
                print(f"Output when removing folder {folder}: {output}")
            else:
                warning(f"Folder {folder} to be destroyed doesn't exists. Cannot delete folder.")

    def delete_test_log_folder(self):
        """
        Destroys the test log folder and all it's content.
        """
        tc_path = self.logger.log_dir.split("/loop_")[0]
        info(f"Delete test log folder: {tc_path}")
        self.remove_folder(tc_path)
        print(f"Test log folder {tc_path} was destroyed.")

    def zip_and_delete_folders(self, folder_name):
        """
        Zip and delete folders.

        :param str folder_name: Name of the folder to zip and delete.
        """
        try:
            admin_folders = self._find_folders(folder_name)
            for folder in admin_folders:
                # Create a zip file with the same name as the folder
                zip_filename = folder + '.zip'
                with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
                    for root, _, files in os.walk(folder):
                        for file_name in files:
                            file_path = os.path.join(root, file_name)
                            arc_name = os.path.relpath(file_path, folder)
                            zipf.write(file_path, arc_name)
                # Delete the original unzipped folder
                shutil.rmtree(folder)
        except OSError as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"{e.__class__.__name__}:{e}")
            if "No space left on device" in str(e):
                self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def _check_if_syslog_processes(self):
        """
        Check if there are syslog processes active and kill them.
        """
        self.give_command_to_terminal("pgrep btslog")
        self.give_command_to_terminal("sudo pkill btslog")

    def _decode_subprocess_outs(self, outs):
        """Decode subprocess outs. Sometimes there may be illegal chars that cannot be decoded with UTF-8"""
        try:
            decoded_outs = outs.decode('utf-8')
        except UnicodeDecodeError as ex:
            self.logger.debug(f"{ex.__class__.__name__}:{ex}")
            decoded_outs = outs.decode('latin-1')
        return decoded_outs

    def give_command_to_terminal(self, command, print_to_eventlog=False, return_output=False, command_timeout=3600):
        """
        Give command to terminal of control PC.

        :param str command: Command to give to terminal.
        :param bool print_to_eventlog: If set True prints command and output to eventlog.
        :param bool return_output: If set True returns output of command.
        :param int command_timeout: Time that it is allowed to be stuck waiting for response
        """
        if print_to_eventlog:
            info(f"Give command: {command}")
        else:
            self.logger.debug(f"Give command: {command}")
        try:
            result = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                    timeout=command_timeout)
            print(f"Command output: outs={result.stdout},  errs={result.stderr}")
            decoded_outs = self._decode_subprocess_outs(result.stdout)
            if print_to_eventlog:
                info(f"Output of command:\n{decoded_outs}")
            else:
                self.logger.debug(f"Output of command:\n{decoded_outs}")
            if return_output:
                return decoded_outs
        except (subprocess.TimeoutExpired, subprocess.SubprocessError, subprocess.CalledProcessError, ValueError,
                AttributeError) as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"Loop {self.logger.loop + 1}: '{e.__class__.__name__}:{e}' when giving command: {command}.")
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            # raise EnvironmentIssue

    def _find_folders(self, folder_name):
        """
        Find all folders with given folder name from test logs.

        :param str folder_name: Name of the folder to find.
        """
        admin_folders = []
        for root, dirs, files in os.walk(self.logger.suite_folder):
            for directory in dirs:
                if folder_name in directory:
                    admin_folders.append(os.path.join(root, directory))
        self.logger.debug(f"Found {folder_name} folders: {admin_folders}")
        return admin_folders

    def wait_cells_disabled_collect_ims(self, admin_connection="log_admin", wait_cells_disabled="180"):
        """
        Wait that cells are disabled and when they are collect IMS log. If cells are not disabled, do not collect ims
        log or do not reset admin connection. If IMS log successfully collected reset admin connection. If problems to
        collect ims log, do not reset admin connection.

        :param str admin_connection: Admin connection that will be reset. Default is log_admin.
        :param str wait_cells_disabled: How many seconds to wait that cells are disabled. Default is 180.
        """
        CollectLogs.ims_file_name_after_swdl = ""
        if not self.cell_operation:
            self.cell_operation = BuiltIn().get_library_instance("CELLS")
        try:
            info(f"Wait max {wait_cells_disabled}s for all cells to be disabled.")
            self.cell_operation.wait_for_cells_faulty(wait_cells_disabled, admin_connection=admin_connection)
        except WrongCellStates as e:
            info(f"Loop {self.logger.loop + 1}: Error when waiting for cells to be disabled before collecting ims2: "
                 f"{e.__class__.__name__}:{e}. Set KW_SUCCESS to false so we will have logs to analyze.")
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
        if self.cell_operation.cell_states_are_expected:
            # info("All cells are disabled, collect IMS log.")
            try:
                im_path = os.path.join(self.logger.log_dir, self.get_target_name(
                    "IMS_BEFORE_SW_ACTIVATION_RESET", file_type=".ims2"))
                self.collect_ims(im_path, connection=admin_connection, swdl=True)
                if CollectLogs.ims_get_after_swdl:
                    CollectLogs.ims_file_name_after_swdl = im_path
                    print("IMS log was successfully collected after SWDL.")
                    # self.admin.reset_admin(connection=admin_connection)
                    CollectLogs.ims_get_after_swdl = False
                else:
                    info("IMS log was not successfully collected after SWDL, do not reset admin connection.")
            except OSError as e:
                info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                error(f"{e.__class__.__name__}:{e}")
                if "No space left on device" in str(e):
                    self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                    BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")
        else:
            info("All cells are not disabled, do not collect IMS log and do not reset admin connection.")

    def get_file_or_folder_from_bts_to_test_logs(self, path_to_file_or_folder, bts_ip=smod_ip, local_dir="",
                                                 extra_name="", scp_timeout=1800, add_timestamp=False):
        """
        Collect file or folder from BTS to test log folder.

        :param str path_to_file_or_folder: Path to file or folder in BTS, for example /tmp/debug_ps_startup.log
                                           or /var/log.
        :param str bts_ip: IP address of BTS, default is 192.168.255.129.
        :param str local_dir: Local directory where to save the file or folder, for example /tmp. If empty uses default
                              test log folder.
        :param str extra_name: Extra name for the file or folder, for example "debug_ps_startup".
        :param int scp_timeout: Default value is 1800 seconds.
        :param bool add_timestamp: If set True, adds timestamp to collected file/folder name.
        :return str: If successful: name of file/folder in test logs
        """
        if not path_to_file_or_folder:
            error(f"Loop {self.logger.loop + 1}: Path to file or folder is empty, cannot collect file or folder from "
                  f"BTS.")
            raise ScriptIssue("Path to file or folder is empty, cannot collect file or folder from BTS.")
        if bts_ip == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                bts_ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        return self.get_file_or_folder_by_scp(path_to_file_or_folder, bts_ip, "toor4nsn", "oZPS0POrRieRtu",
                                              local_dir=local_dir, extra_name=extra_name, scp_timeout=scp_timeout,
                                              add_timestamp=add_timestamp)

    def get_file_or_folder_by_scp(self, path_to_file_or_folder, ip, user_name, password, local_dir="",
                                  update_name=True, extra_name="", scp_timeout=1800, add_timestamp=False):
        """
        Collect file or folder from the given location.

        :param str path_to_file_or_folder: Path to file or folder in BTS, for example /tmp/debug_ps_startup.log
                                           or /var/log.
        :param str ip: IP address, for example is 192.168.255.129.
        :param str user_name: Username used to ssh connection to location from where the file/folder is collected
        :param str password: Password used to ssh connection to location from where the file/folder is collected
        :param str local_dir: Local directory where to save the file or folder, for example /tmp. If empty log dir used.
        :param bool update_name: If set True, name of the file/folder is updated to log dir.
        :param str extra_name: Extra name for the file or folder, for example "debug_ps_startup".
        :param int scp_timeout: Default value is 1800 seconds
        :param bool add_timestamp: If set True, adds timestamp to collected file/folder name.
        :return str: If successful: name of file/folder in test logs
        """
        try:
            if not path_to_file_or_folder:
                error(f"Loop {self.logger.loop + 1}: Path to file or folder is empty, cannot collect file or folder "
                      f"from given {ip}.")
                raise ScriptIssue("Path to file or folder is empty, cannot collect file or folder.")
            target_dir = self.logger.log_dir if not local_dir else local_dir
            if update_name:
                if path_to_file_or_folder[-1] == "/":
                    if extra_name:
                        name_for_log = os.path.join(
                            target_dir,
                            f'{extra_name}_{path_to_file_or_folder[path_to_file_or_folder[:-1].rfind("/") + 1:-1]}')
                    else:
                        name_for_log = os.path.join(target_dir,
                                                    path_to_file_or_folder[path_to_file_or_folder[:-1].rfind("/")+1:-1])
                else:
                    if extra_name:
                        name_for_log = os.path.join(
                            target_dir,
                            f'{extra_name}_{path_to_file_or_folder[path_to_file_or_folder.rfind("/") + 1:]}')
                    elif add_timestamp:
                        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                        name_for_log = os.path.join(
                            target_dir,
                            f'{timestamp}_{path_to_file_or_folder[path_to_file_or_folder.rfind("/") + 1:]}')
                    else:
                        name_for_log = os.path.join(target_dir,
                                                    path_to_file_or_folder[path_to_file_or_folder.rfind("/")+1:])
            else:
                name_for_log = target_dir
            # info("Get {} (from {}) to {}.".format(path_to_file_or_folder, ip, name_for_log))
            fn = self._get_file_by_scp(path_to_file_or_folder, name_for_log, ip, user_name, password, scp_timeout)
            self.logger.debug(f"fn: {fn}")
            # self.give_command_to_terminal(
            #     f"sshpass -p '{password}' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "
            #     f"-r {user_name}@{ip}:{path_to_file_or_folder} {name_for_log}")
            BuiltIn().sleep("1s")
            if os.path.exists(name_for_log):
                info(f"File or folder was successfully collected to {name_for_log}")
                return name_for_log
            else:
                error(f"Loop {self.logger.loop + 1}: Path {name_for_log} doesn't exist, unable to get file or folder.")
            return None
        except OSError as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"{e.__class__.__name__}:{e}")
            if "No space left on device" in str(e):
                self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def upload_file_or_folder_by_scp(self, path_to_file_or_folder, ip, user_name, password, file_on_local,
                                     scp_timeout=900):
        """
        Upload file or folder by scp to the given location.

        :param str path_to_file_or_folder: Path to file or folder in local, for example /home/ute/btslog2/btslog.ini
        :param str ip: IP address, for example is 100.68.194.114.
        :param str user_name: Username used to ssh connection to location to where the file/folder is uploaded
        :param str password: Password used to ssh connection to location to where the file/folder is uploaded
        :param str file_on_local: Local directory from where to upload the file or folder, for example /tmp/btslog.ini
        :param int scp_timeout: Default value is 900 seconds
        :return str: If successful: name of file/folder in test logs
        """
        try:
            self._upload_file_via_scp(password, file_on_local, ip, user_name, path_to_file_or_folder,
                                      scp_timeout=scp_timeout)
        except (OSError, AttributeError, FileNotFoundError, FileExistsError) as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"{e.__class__.__name__}:{e}")
            if "No space left on device" in str(e):
                self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def _get_file_by_scp(self, path_to_file_or_folder, name_for_log, ip, user_name, password, scp_timeout):
        """
        Get file by scp
        """
        try:
            info("Get {} (from {}) to {}.".format(path_to_file_or_folder, ip, name_for_log))
            try_time = 1
            while try_time < 5:
                if password:
                    self.give_command_to_terminal(
                        f"sshpass -p '{password}' scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "
                        f"-o ConnectTimeout={scp_timeout} -r {user_name}@{ip}:{path_to_file_or_folder} "
                        f"{name_for_log}")
                else:
                    self.give_command_to_terminal(
                        f"scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "
                        f"-o ConnectTimeout={scp_timeout} -r {user_name}@{ip}:{path_to_file_or_folder} "
                        f"{name_for_log}")
                if try_time != 1:
                    self.logger.debug(f"Scp was not successful. Try to get file/folder with scp {try_time}. try")
                    self.ssh.delete_known_host_file()
                BuiltIn().sleep("1s")
                if os.path.exists(name_for_log):
                    self.logger.debug(f"File/folder was successfully collected to {name_for_log}")
                    break
                try_time += 1
            if os.path.exists(name_for_log):
                return name_for_log
        except (OSError, AttributeError, TypeError) as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"Could not get '{path_to_file_or_folder}' from '{ip}' because {e.__class__.__name__}:{e}")
            if "No space left on device" in str(e):
                self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")
        return None

    def _upload_file_via_scp(self, pw, file_on_local, ip, user, filename, scp_timeout=900):
        """Upload file via scp helper method."""
        if not file_on_local:
            error(f"Loop {self.logger.loop + 1}: Path to file or folder of local PC is empty, cannot upload file or "
                  f"folder to given {ip}.")
            raise ScriptIssue
        if not ip:
            error(f"Loop {self.logger.loop + 1}: IP address is empty, cannot upload file or folder to given location.")
            raise ScriptIssue
        if not user:
            error(f"Loop {self.logger.loop + 1}: Username is empty, cannot upload file or folder to given location.")
            raise ScriptIssue
        if not filename:
            filename = file_on_local
        info(f"Upload {file_on_local} from local PC to {filename} of {ip}.")
        if pw:
            self.give_command_to_terminal(f"sshpass -p '{pw}' scp -o StrictHostKeyChecking=no -o "
                                          f"UserKnownHostsFile=/dev/null -o ConnectTimeout={scp_timeout} "
                                          f"-r {file_on_local} {user}@{ip}:{filename}", return_output=True)
        else:
            self.give_command_to_terminal(f"scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "
                                          f"-o ConnectTimeout={scp_timeout} -r {file_on_local} "
                                          f"{user}@{ip}:{filename}", return_output=True)

    def upload_file_or_folder_to_bts(self, path_to_file_or_folder_in_pc, path_to_file_or_folder_in_bts,
                                     bts_ip=smod_ip):
        """
        Upload file or folder from local PC to BTS.

        :param str path_to_file_or_folder_in_pc: Path to file or folder in local PC, for example /home/ute/test.txt
        :param str path_to_file_or_folder_in_bts: Path to file or folder in BTS, for example /tmp/test.txt
        :param str bts_ip: IP address of BTS, default is 192.168.255.129.
        """
        if not path_to_file_or_folder_in_pc:
            error(f"Loop {self.logger.loop + 1}: Path to file or folder of local PC is empty, cannot upload file or "
                  f"folder to BTS.")
            raise ScriptIssue
        if not path_to_file_or_folder_in_bts:
            error(f"Loop {self.logger.loop + 1}: Path to file or folder of BTS is empty, cannot upload file or folder "
                  f"to BTS.")
            raise ScriptIssue
        if bts_ip == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                bts_ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        info("Upload {} from PC to {} of BTS.".format(path_to_file_or_folder_in_pc, path_to_file_or_folder_in_bts))
        output = self.give_command_to_terminal(
            "sshpass -p 'oZPS0POrRieRtu' scp -r {} toor4nsn@{}:{}".format(path_to_file_or_folder_in_pc, bts_ip,
                                                                          path_to_file_or_folder_in_bts),
            return_output=True)
        if "No route to host" in output:
            warning(f"Loop {self.logger.loop + 1}: SCP command returns 'No route to host'. Check ssh connections."
                    f"Cannot upload {path_to_file_or_folder_in_pc} to {path_to_file_or_folder_in_bts} of BTS.")

    def kill_all_admin_connections(self):
        """Method that tries to kill all node process that are found from the terminal of control PC."""
        self.logger.debug("Try to kill all node processes that are found from the environment.")
        self.give_command_to_terminal("pgrep node")
        self.give_command_to_terminal("sudo pkill node")

    def special_log_collection(self, special_log, bts_ip=smod_ip, add_timestamp=False):
        """
        Collects special log from the BTS to test logs folder.

        :param str/list special_log: Name of the log to be collected or list of names. Can be file or folder. Name
                                     should be exact, or it can end with * if some file in question for example
                                     /ffs/run/logs/PR754653-IR13-debug-log*
        :param bool add_timestamp: If set True, adds timestamp to collected file/folder name.
        :param str bts_ip: Default is 192.168.255.129.
        """
        if bts_ip == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                bts_ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        if isinstance(special_log, str):
            self._collect_special_log(special_log, bts_ip, add_timestamp=add_timestamp)
        if isinstance(special_log, list):
            for log in special_log:
                self._collect_special_log(log, bts_ip, add_timestamp=add_timestamp)
        info("Special log collection done.")

    @staticmethod
    def clear_swdl_path_variables():
        """
        Clear swdl path variables method Clears path names for ims2 files and snapshot variables used in SWDL tests.
        """
        print("Clear IMS collection variables")
        CollectLogs.ims_get_after_swdl = False
        CollectLogs.ims_file_name_after_swdl = ""
        CollectLogs.ims_file_name = ""
        CollectLogs.ims_file_from_disconnection = ""
        CollectLogs.snapshot_file_name = ""
        CollectLogs.snapshot_file_remote = ""
        BuiltIn().set_suite_variable("${CALCULATE_KPI}", "${True}")

    def _collect_special_log(self, special_log, bts_ip, add_timestamp=False):
        """
        Collect special user given logs from the BTS.
        """
        if "/" not in special_log:
            error(f"Loop {self.logger.loop + 1}: Given path is not valid, no / found from the path: {special_log}")
            raise InvalidUserInput
        if special_log[-1] == "*":
            all_files_in_dir = self.ssh.get_content_of_folder_of_smod(special_log[:special_log[:-1].rfind("/")],
                                                                      full_path=True)
            if all_files_in_dir:
                for log_file in all_files_in_dir:
                    if special_log[:-1] in log_file:
                        self.get_file_or_folder_from_bts_to_test_logs(log_file, bts_ip, add_timestamp=add_timestamp)
            else:
                error("Loop {}: Folder {} is empty, cannot collect files {}".format(
                    self.logger.loop + 1, special_log[:special_log[:-1].rfind("/")], special_log))
        else:
            self.get_file_or_folder_from_bts_to_test_logs(special_log, bts_ip, add_timestamp=add_timestamp)

    def create_new_log_folder(self, name_for_folder):
        """
        Create new folder inside log folder.
        :param str name_for_folder: For example T1
        """
        try:
            self.logger.debug(f"Save current log folder ({self.logger.log_dir}) to CollectLogs.original_log_folder "
                              f"folder (current value {CollectLogs.original_log_folder})")
            CollectLogs.original_log_folder = self.logger.log_dir
            new_folder = os.path.join(self.logger.log_dir, name_for_folder)
            if not os.path.exists(new_folder):
                os.mkdir(new_folder)
                info(f"New folder {new_folder} created.")
                Logger.log_dir = new_folder
                CollectLogs.original_ims_path = CollectLogs.ims_file_name
                CollectLogs.ims_file_name = os.path.join(new_folder, self.get_target_name("IMS", file_type=".ims2"))
                info(f"Update ims file path to the new folder {CollectLogs.ims_file_name}")
                self.logger.debug(f"Add filename {self.logger.log_dir} to folders_for_zip_and_remove list: "
                                  f"{CollectLogs.folders_for_zip_and_remove})")
                CollectLogs.folders_for_zip_and_remove.append(self.logger.log_dir)
            else:
                warning(f"Folder {new_folder} already exists.")
        except (OSError, AttributeError, TypeError) as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"{e.__class__.__name__}:{e}")
            if "No space left on device" in str(e):
                self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def zip_and_remove_log_folder(self, path_to_log_folder, name_for_zip, compress_level=None):
        """
        Zip and remove log folder.

        :param str path_to_log_folder: Path to log folder.
        :param str name_for_zip: Name for the zip file.
        :param int compress_level: Compression level for zip. Default is None.
        """
        try:
            if os.path.exists(path_to_log_folder):
                files_in_folder = self.get_all_files_from_directory(path_to_log_folder)
                self.add_files_to_zip(f"{name_for_zip}.zip", files_in_folder, remove_path_from_file=True,
                                      compress_level=compress_level)
                self.logger.debug(f"Remove unzipped folder: {path_to_log_folder}")
                self.remove_folder(path_to_log_folder)
            else:
                warning(f"Folder {path_to_log_folder} doesn't exist, cannot zip it.")
        except (OSError, AttributeError, TypeError) as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"{e.__class__.__name__}:{e}")
            if "No space left on device" in str(e):
                self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def switch_to_original_log_folder(self, log_folder_to_set=""):
        """
        Switch to use original log folder.
        """
        if not log_folder_to_set:
            info(f"Switch back from {self.logger.log_dir} to test log folder {CollectLogs.original_log_folder}.")
            Logger.log_dir = CollectLogs.original_log_folder
            info(f"Change ims file path back to original {CollectLogs.original_ims_path}")
            CollectLogs.ims_file_name = CollectLogs.original_ims_path
        else:
            info(f"Switch from {self.logger.log_dir} to test log folder {log_folder_to_set}.")
            Logger.log_dir = log_folder_to_set
            ims_path = os.path.join(log_folder_to_set, self.get_target_name("IMS", file_type=".ims2"))
            self.logger.debug(f"Change ims file path from {CollectLogs.ims_file_name} to {ims_path}")
            print(f"Change ims file path from {CollectLogs.ims_file_name} to {ims_path}")
            CollectLogs.ims_file_name = ims_path

    def add_file_to_zip(self, zipped_folders, file_to_add_to_zip):
        """
        Add file to zip.

        :param list zipped_folders: Zips to where file needs to be added.
        :param str file_to_add_to_zip: File to be added to zip.
        """
        try:
            if not os.path.exists(file_to_add_to_zip) or not os.path.isfile(file_to_add_to_zip):
                error(f"Loop {self.logger.loop + 1}: File {file_to_add_to_zip} doesn't exist or it's not a file.")
                raise FileNotFoundFromTestLogs
            for zipped_folder in zipped_folders:
                with zipfile.ZipFile(zipped_folder, 'a', zipfile.ZIP_DEFLATED) as zipf:
                    zipf.write(file_to_add_to_zip, os.path.basename(file_to_add_to_zip))
                self.logger.debug(f"File {file_to_add_to_zip} added to {zipped_folder}")
            print(f"File {file_to_add_to_zip} added to zipped folders ({zipped_folders}).")
        except OSError as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"{e.__class__.__name__}:{e}")
            if "No space left on device" in str(e):
                self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def copy_file_to_folder(self, file_to_copy, destination_folder=""):
        """
        Copy file to folder. If file or folder doesn't exist raise error.

        :param str file_to_copy: File to copy.
        :param str destination_folder: Folder where file will be copied. If empty then file will be copied to test logs.
        """
        try:
            if not os.path.exists(file_to_copy):
                error(f"Loop {self.logger.loop + 1}: File {file_to_copy} doesn't exist, cannot copy it.")
                raise FileNotFoundFromTestLogs
            if not destination_folder or not os.path.exists(destination_folder):
                self.logger.debug("Destination_folder is not given, using test logs folder as destination.")
                destination_folder = self.logger.log_dir
            self.logger.debug("Copy file {} to folder {}.".format(file_to_copy, destination_folder))
            name_for_file_to_folder = self._safe_split(file_to_copy, "/")[-1]
            new_destination = os.path.join(destination_folder, name_for_file_to_folder)
            try:
                if file_to_copy == new_destination:
                    self.logger.debug(f"File '{file_to_copy}' already is in the requested destination. No need to copy")
                    print(f"File '{file_to_copy}' already is in the requested destination. No need to copy.")
                else:
                    shutil.copy(file_to_copy, new_destination)
            except (shutil.Error, shutil.SameFileError) as e:
                error(f"Loop {self.logger.loop + 1}: Error during copying file {file_to_copy} to {new_destination}: "
                      f"{e.__class__.__name__}:{e} was raised.\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                raise EnvironmentIssue(f"Error during copying file {file_to_copy} to {new_destination}: "
                                       f"{e.__class__.__name__}")
            self.logger.debug(f"File {file_to_copy} copied to {new_destination}.")
        except OSError as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"{e.__class__.__name__}:{e}")
            if "No space left on device" in str(e):
                self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def clear_swdl_variables(self):
        """
        Clear SWDL variable
        """
        self.logger.debug(f"Before clearing value is {CollectLogs.folders_for_zip_and_remove}")
        CollectLogs.folders_for_zip_and_remove = []
        self.logger.debug(f"After clearing value is {CollectLogs.folders_for_zip_and_remove}")

    def start_wireshark(self):
        """Start Wireshark method starts TShark."""
        if "${WS_DEVICE_OR_IP}" in BuiltIn().get_variables() and BuiltIn().get_variable_value("${WS_DEVICE_OR_IP}"):
            if self.ws is None:
                self.ws = WiresharkUsage()
            self.logger.debug("Start Wireshark.")
            self.ws.start_wireshark_thread()
        else:
            print("Wireshark parameter WS_DEVICE_OR_IP is not given -> WS logs will not be collected.")

    def stop_wireshark(self):
        """Stop Wireshark method stops TShark."""
        if "${WS_DEVICE_OR_IP}" in BuiltIn().get_variables() and BuiltIn().get_variable_value("${WS_DEVICE_OR_IP}"):
            if self.ws is None:
                self.ws = WiresharkUsage()
            self.logger.debug("Stop Wireshark.")
            self.ws.stop_wireshark_thread()
        else:
            print("Wireshark parameter WS_DEVICE_OR_IP is not given -> WS log is not collected, no need to stop.")

    def move_redundant_logs_for_tester_to_new_folder(self):
        """
        Moves logs that are not essential for the tester to a new folder to keep a cleaner folder

        Files to move is initiated with files/folders that don't have changing names. Other files such as
        test_script_debug* can be found by using glob.glob(filename).
        """

        new_dir = f"{self.logger.log_dir}/for_developers"
        files_to_move = [f"{self.logger.log_dir}/ping_logs", f"{self.logger.log_dir}/ssh_logs",
                         f"{self.logger.log_dir}/admin.zip", f"{self.logger.log_dir}/process_and_mem_prints.txt"]
        cell_request_files = [f"{self.logger.log_dir}/{file}" for file in os.listdir(self.logger.log_dir) if
                              re.search(r"looped_wait_for_cells_(faulty|up)_requests_\d+_\d+.txt", file)]
        if cell_request_files:
            self.add_files_to_zip("cell_requests.zip", cell_request_files, remove_path_from_file=True)
            files_to_move.append(f"{self.logger.log_dir}/cell_requests.zip")
            # Remove cell request files after zipping
            for cell_file in cell_request_files:
                os.remove(cell_file)
        test_script_debug = glob.glob(f"{self.logger.log_dir}/test_script_debug*")
        ims_files_to_move = [file for file in os.listdir(self.logger.log_dir) if
                             re.search(r"IMS_\d+_\d+_(?!remote\.ims2).*", file)]
        files_to_move.extend(test_script_debug)
        files_to_move.extend(ims_files_to_move)
        try:
            if not os.path.exists(new_dir):
                info(f"New directory {new_dir} doesn't exist. Creating it")
                os.mkdir(new_dir)
        except OSError as e:
            error(f"{e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            if "No space left on device" in str(e):
                self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")
        try:
            for file in files_to_move:
                destination_path = f"{new_dir}/{os.path.basename(file)}"
                if os.path.exists(destination_path):
                    if os.path.isdir(destination_path):
                        info(f"Folder {destination_path} already exists, adding files from {file} folder to it.")
                        for item in os.listdir(file):
                            shutil.move(os.path.join(file, item), destination_path)
                        continue
                    else:
                        info(f"File {destination_path} already exists, renaming the file to move it")
                        new_file = os.path.join(self.logger.log_dir, f"1_{os.path.basename(file)}")
                        os.rename(file, new_file)
                        file = new_file

                if os.path.exists(file):
                    shutil.move(file, new_dir)
        except (shutil.Error, OSError) as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"Error happened during moving files to new folder: {e.__class__.__name__}: {e}")
            if "No space left on device" in str(e):
                self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")
            raise ScriptIssue

    def get_current_log_folder(self):
        """Get current log folder."""
        return self.logger.log_dir

    def rename_logs_to_5g_or_4g(self):
        """
        Rename logs to 5G or 4G depending on the used technology.
        """
        if self.bts.check_if_5g_environment():
            info("Used remote technology is 4G, rename remote logs to 4G.")
            self._rename_files_in_folder(used_remote_technology="4G")
        else:
            info("Used remote technology is 5G, rename remote logs to 5G.")
            self._rename_files_in_folder(used_remote_technology="5G")

    def _rename_files_in_folder(self, used_remote_technology):
        """
        Rename files in folder based on the used remote technology (4G or 5G).

        :param used_remote_technology: Used remote technology, 4G or 5G.
        """
        used_technology = "4G" if used_remote_technology == "5G" else "5G"
        print(f"DEBUG: used_technology={used_technology}  used_remote_technology={used_remote_technology}")
        self._rename_files(used_remote_technology, used_technology)
        self._rename_syslog_folders(used_remote_technology, used_technology)

    def _rename_files(self, used_remote_technology, used_technology):
        """
        Rename individual files in the log directory.

        :param used_remote_technology: Used remote technology, 4G or 5G.
        :param used_technology: Used technology, 4G or 5G.
        """
        try:
            for root, _, files in os.walk(self.logger.log_dir):
                for file in files:
                    if file.endswith((".ims2", ".zip", ".xml")):
                        old_file_path = os.path.join(root, file)
                        new_file_path = self._get_new_file_path(file, old_file_path, used_remote_technology,
                                                                used_technology)
                        if new_file_path:
                            os.rename(old_file_path, new_file_path)
                            info(f"Renamed: {old_file_path} to {new_file_path}")
        except OSError as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"{e.__class__.__name__}:{e}")
            if "No space left on device" in str(e):
                self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def _get_new_file_path(self, file, old_file_path, used_remote_technology, used_technology):
        """
        Get the new file path based on the file type and technology.

        :param file: The original file name.
        :param old_file_path: The original file path.
        :param used_remote_technology: Used remote technology, 4G or 5G.
        :param used_technology: Used technology, 4G or 5G.
        :return: The new file path.
        """
        if "remote" in file:
            return os.path.join(os.path.dirname(old_file_path), file.replace("remote", used_remote_technology))
        elif file.endswith(".ims2"):
            return old_file_path.replace(".ims2", f"_{used_technology}.ims2")
        elif file.endswith(".zip"):
            return old_file_path.replace(".zip", f"_{used_technology}.zip")
        elif file.endswith(".xml"):
            return old_file_path.replace(".xml", f"_{used_technology}.xml")
        return None

    @staticmethod
    def _rename_path(old_name, new_name):
        """
        Rename path

        :param str old_name: Path to be renamed
        :param str new_name: New name for the path
        """
        try:
            if os.path.exists(old_name):
                os.renames(old_name, new_name)
                info(f"Renamed: {old_name} to {new_name}")
            else:
                error(f"Cannot rename {old_name} to {new_name}, the path doesn't exists")
        except OSError as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"{e.__class__.__name__}:{e}")
            if "No space left on device" in str(e):
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def _rename_syslog_folders(self, used_remote_technology, used_technology):
        """
        Rename syslog folders based on the used remote technology.

        :param used_remote_technology: Used remote technology, 4G or 5G.
        :param used_technology: Used technology, 4G or 5G.
        """
        syslogs = self.check_if_file_is_in_logs(
            "syslog_files.tgz", path_for_search=self.logger.log_dir, return_file_path=True,
            return_multiple_files=True)
        for syslog in syslogs:
            if "syslog_remote" in syslog:
                new_syslog_remote = syslog.replace(
                    "syslog_remote/syslog_files.tgz",
                    f"syslog_{used_remote_technology}/{used_remote_technology}_syslog_files.tgz")
                self._rename_path(syslog, new_syslog_remote)
            else:
                new_syslog = syslog.replace(
                    "syslog/syslog_files.tgz",
                    f"syslog_{used_technology}/{used_technology}_syslog_files.tgz")
                self._rename_path(syslog, new_syslog)

    def get_file_from_zip_or_tar(self, filename_to_get, archived_path=None, folder_to_extract=None, upper_folder=None,
                                 upper_upper_folder=None, add_name_to_get_file="", not_in_name="", extra_name="",
                                 get_multiple_files=False, print_if_not_found=True):
        """
        Get file from zip or tar. Extracts a file that name has user given 'filename_to_get' in it from the given zip or
         tar file.

        :param str filename_to_get: Name of the file to extract from the zip/tar.
        :param str archived_path: Path to the zip file. If Nope then uses snapshot_file_name.
        :param str folder_to_extract: Directory to extract the file to. Default is to the current log directory.
        :param str upper_folder: If file should be in specific folder the folder or part of the folder name can be given
                                 here. (OPTIONAL)
        :param str upper_upper_folder: If file should be in specific folder under another specific folder the folder or
                                       part of the folder name can be given here. (OPTIONAL)
        :param str add_name_to_get_file: If you want to get multiple files from different folder to logs you can add
                                         extra name with this parameter. (OPTIONAL)
        :param str not_in_name: If you want to specify what should not be in the name. (OPTIONAL)
        :param str extra_name: Use this if you want to give extra name for example because file has same name in other
                               folder and both are needed. (OPTIONAL)
        :param bool get_multiple_files: If set to True, returns a list of paths to the extracted files. otherwise,
                                        returns single path or None.
        :param bool print_if_not_found: If False will not print info if nothing is found.
        :return str/list: Path to the extracted file, list of files or None if no such file is found.
        """
        try:
            if archived_path is None:
                self.logger.debug(
                    f"No path given to archived file, using snapshot path {CollectLogs.snapshot_file_name}")
                if not os.path.exists(CollectLogs.snapshot_file_name) or os.path.isfile(CollectLogs.snapshot_file_name):
                    info("Snapshot file is not get, collect it")
                    self.collect_snapshot()
                archived_path = CollectLogs.snapshot_file_name
            if folder_to_extract is None:
                self.logger.debug(f"No path given to folder, using current log path {self.logger.log_dir}")
                folder_to_extract = self.logger.log_dir
            if add_name_to_get_file is None:
                add_name_to_get_file = ""
            if extra_name is None:
                extra_name = ""
            return GetFromArchived.get_file_from_archived_folder(filename_to_get, archived_path=archived_path,
                                                                 folder_to_extract=folder_to_extract,
                                                                 upper_folder=upper_folder,
                                                                 upper_upper_folder=upper_upper_folder,
                                                                 add_name_to_get_file=add_name_to_get_file,
                                                                 not_in_name=not_in_name,
                                                                 extra_name=extra_name,
                                                                 get_multiple_files=get_multiple_files,
                                                                 print_if_not_found=print_if_not_found)
        except OSError as e:
            error(f"{e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            if "No space left on device" in str(e):
                self.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def check_if_ims2_files_are_collected(self, ims_file_name=""):
        """
        Check if ims2 files are collected. If not, collect them.

        :param str ims_file_name: Name of the ims file to check. If empty, uses CollectLogs.ims_file_name.
        """
        if ims_file_name:
            swdl_log_name = f"IMS_of_{ims_file_name.replace(' ', '_')}.ims2"
            self.logger.debug(f"Check if given ims file {swdl_log_name} is collected.")
            if self.check_if_file_is_in_logs(swdl_log_name, path_for_search=self.logger.log_dir):
                self.logger.debug(f"IMS file is already collected to {swdl_log_name}.")
                return
            else:
                log_name = os.path.join(self.logger.log_dir, swdl_log_name)
                info(f"IMS file {swdl_log_name} is not collected, collect it.")
                self.collect_ims(ims_file=log_name)
        else:
            if not os.path.isfile(CollectLogs.ims_file_name):
                if self.check_if_file_is_in_logs(CollectLogs.ims_file_name):
                    self.logger.debug(f"IMS file is already collected to {CollectLogs.ims_file_name}.")
                    return
                info("IMS file is not collected, collect it.")
                self.collect_ims()
            else:
                self.logger.debug(f"IMS file is already collected to {CollectLogs.ims_file_name}.")

    @staticmethod
    def _safe_split(value, sep):
        """Safely split values that may be None; returns list from splitting str(value)."""
        if value is None:
            return [""]
        return str(value).split(sep)

    def make_summary_of_kpis(self, radio_name):
        """
        Add summaries of reset radio KPIs to a summary txt file.

        :param str radio_name: Name of the radio from which the summary of KPIs is collected.
        """
        kpi_summary = []
        search_dir = os.path.abspath(os.path.join(self.logger.log_dir, os.pardir, os.pardir))
        summary_filename = 'radio_succession_reset_kpi_summary.txt'
        for root, _, files in os.walk(search_dir):
            if re.sub(r'[^a-zA-Z0-9]', '',
                      str(radio_name)).lower() not in re.sub(r'[^a-zA-Z0-9]', '',
                                                             str(os.path.basename(root))).lower():
                continue
            for file in files:
                if file.endswith('.txt') and 'kpi' in file.lower() and file != summary_filename:
                    file_path = os.path.join(root, file)
                    with open(file_path, 'r') as f:
                        try:
                            data = json.load(f)
                            for kpi_name, kpi_data in data.items():
                                if isinstance(kpi_data, dict) and "avg" in kpi_data:
                                    avg = kpi_data["avg"]
                                    kpi_summary.append((kpi_name, avg))
                        except Exception as e:
                            info(f"Failed to parse {file_path}: {e}")
        summary_path = os.path.join(search_dir, summary_filename)
        with open(summary_path, 'a') as summary_file:
            for kpi_name, avg in kpi_summary:
                summary_file.write(f"{radio_name}: {kpi_name}: {avg}\n")
        info(f"KPI summary written to {summary_path}")

    def check_if_ims2_is_ok(self, ims_file_path="", print_to_eventlog=False):
        """
        Check if ims2 is ok. Check if given file is corrupted, if file is not given, uses CollectLogs.ims_file_name.
        If file is not found or it's empty, returns False. If file is found and can be read with Ims2LogReader,
        returns True.

        :param str ims_file_path: Path to the ims2 file to check. If empty, uses CollectLogs.ims_file_name.
        :param bool print_to_eventlog: Print to eventlog if true and everything ok else just to debug log. Default is
                                       False.
        """
        if not ims_file_path:
            ims_file_path = CollectLogs.ims_file_name
        if not ims_file_path or not os.path.isfile(ims_file_path) or not ims_file_path.endswith(".ims2"):
            warning(f"IMS2 file '{ims_file_path}' does not exist or is not ims2 file.")
            return False
        if os.path.getsize(ims_file_path) == 0:
            warning(f"IMS2 file '{ims_file_path}' is empty, may be corrupted.")
            return False
        try:
            from taf.analyzer.ims2 import Ims2LogReader
            Ims2LogReader.from_file(file_path=ims_file_path)
            if print_to_eventlog:
                info(f"IMS2 file '{ims_file_path}' is valid.")
            else:
                self.logger.debug(f"IMS2 file '{ims_file_path}' is valid.")
                print(f"IMS2 file '{ims_file_path}' is valid.")
            return True
        except Exception as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            warning(f"IMS2 file '{ims_file_path}' is corrupted: {e.__class__.__name__}:{e}")
            return False
