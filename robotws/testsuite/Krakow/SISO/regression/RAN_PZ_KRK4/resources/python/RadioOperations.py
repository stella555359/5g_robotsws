"""
Operations on gNB Radio Unit.

:copyright: Nokia Networks
:author: Rafal Kawa
:contact: rafal.kawa@nokia.com
:maintainer: rafal.kawa@nokia.com
"""

import datetime
import logging
import os.path
import re
import time

from copy import copy
from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification
from taf.rfrl.bts.helpers.compare_statuses import verify_statuses, unify_statuses
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.utilities.tl_config import get_radio_serial_number
from taf.rfrl.utilities.transfer_files import download_files
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations


class RadioOperations(GnbRuOperations):
    """
    Radio Unit operations.

    This class provides various operations related to Radio Unit.
    """

    def __init__(self, ):
        """
        Initializes the RadioOperations class.
        """
        super().__init__()
        self._ru_operations = None
        self._alarm_operations = None
        super(GnbRuOperations, self).__init__()

    @property
    def alarm_operations(self):
        """
        Returns the GnbAlarmVerification instance.
        If the instance does not exist, it creates a new one and returns it.
        Returns:
            GnbAlarmVerification: The GnbAlarmVerification instance.
        """
        if self._alarm_operations is None:
            self._alarm_operations = GnbAlarmVerification()
        return self._alarm_operations

    def get_radio_unit_serial_number(self, gnb_id=0, du_id=0, ru_id=1):
        """
        Retrieves the serial number of a specific radio unit.

        Args:
            gnb_id (int, optional): The ID of the GNB. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            ru_id (int, optional): The ID of the radio unit. Defaults to 1.

        Returns:
            str: The serial number of the specified radio unit.

        Raises:
            Exception: If the specified radio unit is not found.
        """
        rus = self.get_all_radio_unit_info(bts_id=gnb_id, du_id=du_id)
        ru_sn = [ru.get("serialNumber") for ru in rus if f"RMOD-{ru_id}" in ru.get("id").get("configuration")]
        if ru_sn:
            logging.info(f"Found 'RMOD-{ru_id}' serialNumber: '{ru_sn}'")
            return ru_sn[0]
        else:
            raise Exception(f"Not found 'RMOD-{ru_id}' in 'GNB-{gnb_id}' configuration: '{rus}'")

    @staticmethod
    def verify_radio_startup_time(time_radio_readiness, time_radio_reset, target_startup_time=130):
        """
        Verifies if the radio startup time is within the target time.

        Args:
            time_radio_readiness (datetime, mandatory): The time when the radio is ready.
            time_radio_reset (datetime, mandatory): The time when the radio was reset.
            target_startup_time (int, optional): The target startup time in seconds. Defaults to 130.

        Raises:
            Exception: If the startup time exceeds the target startup time.
        """
        # Calculate the startup time
        startup_time = datetime.timedelta.total_seconds(time_radio_readiness - time_radio_reset)

        if startup_time < target_startup_time:
            logging.info(f"Passed. Radio Unit startup time: {startup_time}s is less than {target_startup_time}s.")
        else:
            raise Exception(f"Failed. Radio Unit startup time '{startup_time}'s is over target time "
                            f"'{target_startup_time}'s.")

    @load_moler_configuration_from_tl()
    def kill_radio_unit_process(self, process_name, signal="SIGTERM", bts_id=0, du_id=0, ru_id=0, timeout=120):
        """
        Kills a process on the specified radio unit using the pkill command.

        Args:
            process_name (str): The name of the process to kill.
            signal (str): The signal to send to the process (e.g., 'SIGKILL', 'SIGTERM', 'SIGSEGV', '9', '15', '11').
            bts_id (int, optional): BTS ID - id related to Test Line configuration. Defaults to 0.
            du_id (int, optional): Distributed Unit (DU) ID - id related to Test Line configuration. Defaults to 0.
            ru_id (int): The ID of the radio unit - id related to Test Line configuration. Defaults to 0.
            timeout (int, optional): Timeout for the pkill command in seconds. Defaults to 120.

        Returns:
            object: Result of the pkill command execution.

        Returns:
            None
        """
        device = self.get_ru_device(bts_id=bts_id, du_id=du_id, ru_id=ru_id)
        cmd_pkill = device.get_cmd(cmd_name="sudo",
                                   cmd_params={"cmd_object": device.get_cmd(
                                       cmd_name='pkill',
                                       cmd_params={"name": f"-{signal} {process_name}"})})
        return cmd_pkill(timeout=timeout)

    @load_moler_configuration_from_tl()
    def execute_frmonshell_action(self, action_name, node="/", agent_type=None, agent_instance_path=None,
                                  init_parameter=None, bts_id=0, du_id=0, ru_id=0, timeout=60):
        """
        Executes frmonShellClient action.

        Args:
            action_name (str): The name of the action to execute.
            node (str, optional): The node on which to execute the action. Defaults to "/".
            agent_type (str, optional): The type of the agent. Defaults to None.
            agent_instance_path (str, optional): The path to the agent instance. Defaults to None.
            init_parameter (str, optional): The initialization parameter. Defaults to None.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            ru_id (int, optional): The ID of the radio unit - id related to Test Line configuration. Defaults to 0.
            timeout (int, optional): The timeout for the action in seconds. Defaults to 60.

        Returns:
            object: The result of the action execution.
        """
        device = self.get_ru_device(bts_id=bts_id, du_id=du_id, ru_id=ru_id)
        device.goto_state("FRMONSHELL")
        cmd_action = device.get_cmd(cmd_name='action',
                                    cmd_params={"action_name": f"{action_name}",
                                                "node": f"{node}",
                                                "agent_type": f"{agent_type}",
                                                "agent_instance_path": f"{agent_instance_path}",
                                                "init_parameter": f"{init_parameter}"})
        return cmd_action(timeout=timeout)

    @load_moler_configuration_from_tl()
    def replace_text_on_ru_file(self, re_old_value, new_value, file_path, bts_id=0, du_id=0, ru_id=0, timeout=120):
        """
        Replaces text in a file on the radio unit.

        This method uses the `sed` command to replace text in a specified file on the radio unit.

        Args:
            re_old_value (str): The regex pattern of the old value to be replaced.
            new_value (str): The new value to replace the old value.
            file_path (str): The path to the file on the radio unit.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            ru_id (int, optional): The ID of the radio unit - id related to Test Line configuration. Defaults to 0.
            timeout (int, optional): The timeout for the `sed` command in seconds. Defaults to 120.

        Returns:
            object: The result of the `sed` command execution.
        """
        device = self.get_ru_device(bts_id=bts_id, du_id=du_id, ru_id=ru_id)
        cmd_sed = device.get_cmd(cmd_name="sudo",
                                 cmd_params={"cmd_object": device.get_cmd(
                                     cmd_name='sed',
                                     cmd_params={"input_files": [f"{file_path}"],
                                                 "options": f"-i 's/{re_old_value}/{new_value}/g'"})})
        return cmd_sed(timeout=timeout)

    def set_rfsw_rad_flag(self, flag, value, options, success_regex=None, bts_id=0, du_id=0, ru_id=0, timeout=120):
        """
        Sets the RFSW RAD flag on the radio unit.

        This method uses the `ccsShell.sh` script to set the RFSW RAD flag on the specified radio unit.

        Args:
            flag (str): The flag to set.
            value (str): The value to set for the flag.
            options (str): The options to use with the `rad` command.
            success_regex (str, optional): The regex pattern to verify the success of the command. Defaults to None.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            ru_id (int, optional): The ID of the radio unit - id related to Test Line configuration. Defaults to 0.
            timeout (int, optional): The timeout for the command in seconds. Defaults to 120.

        Returns:
            object: The result of the command execution.
        """
        device = self.get_ru_device(bts_id=bts_id, du_id=du_id, ru_id=ru_id)
        cmd_sed = device.get_cmd(cmd_name='run_script',
                                 cmd_params={"script_command": f"ccsShell.sh rad -{options} {flag} {value}",
                                             "success_regex": success_regex})
        return cmd_sed(timeout=timeout)

    def set_multiple_rfsw_rad_flags(self, flags_dict, bts_id=0, du_id=0, ru_id=0, timeout=120):
        """
        Sets multiple RFSW RAD flags on the radio unit.

        Args:
            flags_dict (dict): A dictionary where keys are flags and values are dictionaries with:
                               - value (str): The value to set for the flag.
                               - options (str): The options to use with the `rad` command.
                               - success_regex (str, optional): The regex pattern to verify the success of the command.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            ru_id (int, optional): The ID of the radio unit. Defaults to 0.
            timeout (int, optional): The timeout for each command in seconds. Defaults to 120.

        Returns:
            list: A list of results for each flag set operation.
        """
        results = []
        for flag, params in flags_dict.items():
            value = params.get("value")
            options = params.get("options")
            success_regex = params.get("success_regex", None)
            result = self.set_rfsw_rad_flag(flag=flag, value=value, options=options, success_regex=success_regex,
                                            bts_id=bts_id, du_id=du_id, ru_id=ru_id, timeout=timeout)
            results.append(result)
        return results

    def get_ru_fan_info(self, ru_id=0, bts_id=0, du_id=0):
        """
        Retrieves the fan information for a specific radio unit.

        This method fetches the fan status information for the specified radio unit (RU)
        by matching the serial number of the RU.

        Args:
            ru_id (int, optional): The ID of the radio unit - id related to Test Line configuration. Defaults to 0.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.

        Returns:
            list: A list of fan status information for the specified radio unit.
        """
        ru_serial = get_radio_serial_number(bts_id=bts_id, du_id=du_id, ru_id=ru_id)
        return [ru['fanStatus']['fans'] for ru in self.get_all_radio_unit_info(
            bts_id=bts_id, du_id=du_id) if ru.get('serialNumber') == ru_serial][0]

    def verify_ru_fan_statuses(self, fan_id=1, ru_id=0, bts_id=0, du_id=0, operational_state=None,
                               administrative_state=None, usage_state=None):
        """
        Verifies the statuses of a specific fan in a radio unit.

        This method checks the operational, administrative, and usage states of a specified fan
        in a radio unit (RU) and verifies if they match the expected statuses.

        Args:
            fan_id (int, optional): The runtime ID of the fan. Defaults to 1.
            ru_id (int, optional): The ID of the radio unit - id related to Test Line configuration. Defaults to 0.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            operational_state (str, optional): The expected operational state of the fan. Defaults to None.
            administrative_state (str, optional): The expected administrative state of the fan. Defaults to None.
            usage_state (str, optional): The expected usage state of the fan. Defaults to None.

        Raises:
            ValueError: If the expected statuses are empty or if the fan information is not found.
        """
        passed_args = copy(locals())
        var_key_mapping = {
            'operational_state': "operationalState",
            'administrative_state': "administrativeState",
            'usage_state': "usageState",
        }
        expected_statuses = {}
        for arg_name, arg_value in passed_args.items():
            if arg_name in var_key_mapping.keys() and arg_value is not None:
                expected_statuses[var_key_mapping[arg_name]] = arg_value
        if not expected_statuses:
            raise ValueError("Expected statuses are empty - please pass at least one of status/state to check")

        all_fans = self.get_ru_fan_info(ru_id=ru_id, bts_id=bts_id, du_id=du_id)
        logging.info(f"RU{ru_id} fans statuses: {all_fans}")
        fan_info = [fan for fan in all_fans if fan['name'] == f"FAN_R-{fan_id}"]
        if not fan_info:
            raise ValueError(f"Unable to find FAN_R-{fan_id} information in RU{ru_id}: {all_fans}")

        unify_statuses(fan_info[0]['stateInfo'], required_keys=expected_statuses.keys())
        verify_statuses(expected_statuses=expected_statuses, received_statuses=fan_info[0]['stateInfo'],
                        device=fan_info[0]['distName'])
        logging.info(f"All RU{ru_id} fans statuses are as expected")

    def get_ru_configuration_id(self, bts_id=0, du_id=0, ru_id=0):
        """
        Retrieves the configuration ID of a specific radio unit.

        This method fetches the configuration ID of the specified radio unit (RU)
        by matching the serial number of the RU.

        Args:
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            ru_id (int, optional): The ID of the radio unit. Defaults to 0.

        Returns:
            int: The configuration ID of the specified radio unit.

        Raises:
            ValueError: If the specified radio unit is not found.
        """
        ru_serial = get_radio_serial_number(bts_id=bts_id, du_id=du_id, ru_id=ru_id)
        ru_config = [ru['id']['configuration'] for ru in
                     self.get_all_radio_unit_info(bts_id=bts_id, du_id=du_id) if
                     ru['serialNumber'] == ru_serial]
        if ru_config:
            logging.info(f"Found 'RU{ru_id}' configuration: '{ru_config}'")
            _re_id = re.compile(r'RMOD-(?P<ru_id>\d+)', re.I)
            return int(_re_id.search(ru_config[0]).group('ru_id'))
        else:
            raise ValueError(f"Not found 'RMOD: {ru_serial}' in 'GNB{bts_id}' configuration.")

    def collect_radio_unit_log(self, cmd_params="-c full -a", remote_dir="/run", success_regex=None, bts_id=0, du_id=0,
                               ru_id=0, timeout=120):
        """
        Collects the log from a specified radio unit (RU).

        This method initiates the log collection process on the specified RU, compresses the log into a zip file,
        and downloads it to the local directory.

        Args:
            cmd_params (str, optional): The parameters for the log command. Defaults to "-c full -a".
            remote_dir (str, optional): The directory on the RU where the log file is stored. Defaults to "/run".
            success_regex (str, optional): The regex pattern to verify the success of log command. Defaults to None.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the Distributed Unit. Defaults to 0.
            ru_id (int, optional): The ID of the Radio Unit. Defaults to 0.
            timeout (int, optional): The timeout for the log collection command in seconds. Defaults to 120.

        Returns:
            None
        """
        device = self._ru_operations.get_ru_device(bts_id=bts_id, du_id=du_id, ru_id=ru_id)
        log_name = f'log_RU{ru_id}_{time.strftime("%Y%m%d_T%H%M%S", time.localtime())}.zip'
        cmd_log = device.get_cmd(cmd_name='run_script',
                                 cmd_params={"script_command": f"log {cmd_params} -z {log_name}",
                                             "success_regex": success_regex})
        cmd_log(timeout=timeout)
        self.download_file_from_ru(remote_file=log_name, remote_dir=remote_dir, remove_source_file=True,
                                   bts_id=bts_id, du_id=du_id, ru_id=ru_id)

    def wait_for_fault_activation_and_capture_radio_unit_log(self, fault_id, awaiting_time=3600):
        """
        Waits for a specific fault activation and captures the radio unit log.

        This method waits for the activation of a specified fault ID within a given time frame.
        Once the fault is activated, it captures the log from the radio unit.

        Args:
            fault_id (int): The ID of the fault to wait for.
            awaiting_time (int, optional): The maximum time to wait for fault activation in seconds. Defaults to 3600.

        Returns:
            None
        """
        self.alarm_operations.wait_for_alarm_activation(fault_id=fault_id, awaiting_time=awaiting_time)
        self.collect_radio_unit_log()

    @load_moler_configuration_from_tl()
    def download_file_from_ru(self, remote_file, remote_dir, local_dir=None, new_file_name=None,
                              remove_source_file=False, bts_id=0, du_id=0, ru_id=0, timeout=180):
        """
        Downloads a file from the radio unit.

        This method downloads a specified file from the radio unit (RU) to a local directory.
        It also provides options to rename the file locally and remove the source file from the RU.

        Args:
            remote_file (str): The name of the file to download from the RU.
            remote_dir (str): The directory on the RU where the file is located.
            local_dir (str, optional): The local directory to save file. Defaults to the value of 'LOG_PATH'.
            new_file_name (str, optional): The new name for the downloaded file. Defaults to None.
            remove_source_file (bool, optional): Whether to remove the source file from the RU. Defaults to False.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            ru_id (int, optional): The ID of the RU. Defaults to 0.
            timeout (int, optional): The timeout for the download operation in seconds. Defaults to 180.

        Returns:
            None
        """
        local_dir = local_dir or get_builtin_value('LOG_PATH')
        download_files(local_dir=local_dir, remote_file=remote_file,
                       device_name=self.ssh_ru_alias.format(bts_id, du_id, ru_id), remote_dir=remote_dir,
                       from_state="RU", timeout=timeout, remove_source_file=remove_source_file, log_level='error',
                       new_file_name=new_file_name)

    def execute_command(self, command, success_regex=None, bts_id=0, du_id=0, ru_id=0, timeout=120):
        """
        Executes one or multiple commands on the radio unit.

        Args:
            command (str | list): The command or list of commands to execute.
            success_regex (str, optional): The regex pattern to verify the success of the command. Defaults to None.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            ru_id (int, optional): The ID of the radio unit - id related to Test Line configuration. Defaults to 0.
            timeout (int, optional): The timeout for the command in seconds. Defaults to 120.

        Returns:
            list: A list of results for each executed command.
        """
        device = self.get_ru_device(bts_id=bts_id, du_id=du_id, ru_id=ru_id)
        results = []

        # Ensure commands are handled as a list
        commands = command if isinstance(command, list) else [command]

        for cmd in commands:
            cmd_obj = device.get_cmd(cmd_name='run_script',
                                     cmd_params={"script_command": f"{cmd}",
                                                 "success_regex": success_regex})
            results.append(cmd_obj(timeout=timeout))

        return results

    def check_fault_in_history_log(self, raw_fault_id, fault_type="active", file_name="fault_history_log_temp.txt",
                                   file_dir="/ram", local_dir=None, ignored_faults=None, bts_id=0, du_id=0, ru_id=0):
        """
        Checks if any fault ID from the provided list is present in the fault history log.
        Raises an exception if unexpected alarms are found and are not in the ignored_faults list.

        Args:
            raw_fault_id (str | list): Fault ID or list of fault IDs to check.
            fault_type (str): Type of faults to check ("active" or "inactive"). Defaults to "active".
            file_name (str): Name of the fault history log file. Defaults to "fault_history_log_temp.txt".
            file_dir (str): Directory of the fault history log file in RU filesystem. Defaults to "/ram".
            local_dir (str): Local directory to download the log file. Defaults to None - uses value of 'LOG_PATH'.
            ignored_faults (list, optional): List of fault IDs to ignore. Defaults to None.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            ru_id (int, optional): The ID of the radio unit - id related to Test Line configuration. Defaults to 0.

        Raises:
            ValueError: If none of the fault IDs are found or unexpected alarms are present and not in ignored_faults.
        """
        # Ensure fault_id is a list
        fault_ids = raw_fault_id if isinstance(raw_fault_id, list) else [raw_fault_id]

        # Parse the fault history log
        parsed_faults = self.parse_downloaded_fault_history_log(
            fault_type=fault_type, file_name=file_name, file_dir=file_dir,
            local_dir=local_dir, bts_id=bts_id, du_id=du_id, ru_id=ru_id
        )
        logging.info(f"'{fault_type.capitalize()}' fault(s) in '{file_name}': '{parsed_faults}'.")

        # Filter out ignored faults
        if ignored_faults:
            parsed_faults = [fault for fault in parsed_faults if
                             not any(re.search(ign_fault, fault['id']) for ign_fault in ignored_faults)]

        # Check for matching fault IDs
        found_faults = [f_id for f_id in fault_ids if
                        any(re.search(f_id, parsed_fault['id']) for parsed_fault in parsed_faults)]
        if not found_faults:
            raise ValueError(f"Expected '{fault_type}' faults not detected in '{file_name}': '{fault_ids}'.")

        # Check for unexpected faults
        unexpected_faults = [parsed_fault['id'] for parsed_fault in parsed_faults if
                             not any(re.search(f_id, parsed_fault['id']) for f_id in fault_ids)]
        if unexpected_faults:
            raise ValueError(f"Unexpected alarms found in '{file_name}': {unexpected_faults}")

        logging.info(f"Expected '{fault_type.capitalize()}' fault(s) found in '{file_name}': '{found_faults}'.")

    def verify_fault_history_log_empty(self, fault_type="active", file_name="fault_history_log_temp.txt",
                                       file_dir="/ram", local_dir=None, ignored_faults=None,
                                       bts_id=0, du_id=0, ru_id=0):
        """
        Verifies if the fault history log is empty.

        Args:
            fault_type (str): The type of faults to check ("active" or "inactive").
            file_name (str): Name of the fault history log file.
            file_dir (str): Directory of the fault history log file.
            local_dir (str, optional): Local directory to download the log file.
            ignored_faults (list, optional): List of fault IDs to ignore. Defaults to None.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            ru_id (int, optional): The ID of the radio unit. Defaults to 0.

        Raises:
            ValueError: If the fault history log section is not empty.
        """
        faults = self.parse_downloaded_fault_history_log(
            fault_type=fault_type, file_name=file_name, file_dir=file_dir,
            local_dir=local_dir, bts_id=bts_id, du_id=du_id, ru_id=ru_id
        )

        if not faults:
            logging.info(f"Section '{fault_type}' faults in '{file_name}' is empty.")
            return

        if ignored_faults:
            faults = [fault for fault in faults if
                      not any(re.search(ign_fault, fault['id']) for ign_fault in ignored_faults)]

        if faults:
            raise ValueError(f"Found not allowed '{fault_type}' faults in '{file_name}': '{faults}'")

    def parse_downloaded_fault_history_log(self, fault_type="active", file_name="fault_history_log_temp.txt",
                                           file_dir="/ram", local_dir=None, bts_id=0, du_id=0, ru_id=0):
        """
        Downloads the fault history log and parses it.

        Args:
            fault_type (str): The type of faults to check ("active" or "inactive").
            file_name (str): Name of the fault history log file.
            file_dir (str): Directory of the fault history log file in RU filesystem.
            local_dir (str): Local directory to download the log file.
            bts_id (int, optional): The ID of the BTS. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            ru_id (int, optional): The ID of the radio unit. Defaults to 0.

        Returns:
            list: A list of parsed faults from the log file.
        """
        local_dir = local_dir or get_builtin_value('LOG_PATH')
        new_name = file_name.replace(".txt", f"_{time.strftime('%Y-%m-%d_T%H:%M:%S')}.txt")
        self.download_file_from_ru(remote_file=file_name, remote_dir=file_dir, local_dir=local_dir,
                                   new_file_name=new_name, remove_source_file=False,
                                   bts_id=bts_id, du_id=du_id, ru_id=ru_id)
        return self.parse_fault_history_log(file_name=new_name, file_dir=local_dir, fault_type=fault_type)

    @staticmethod
    def parse_fault_history_log(file_name, file_dir, fault_type):
        """
        Parses active or inactive faults from the fault history log file.

        Args:
            file_name (str): Name of the fault history log file.
            file_dir (str): Directory of the fault history log file.
            fault_type (str): Type of faults to extract ("active" or "inactive").

        Returns:
            list: A list of dictionaries containing fault details.
        """
        if fault_type.lower() not in {"active", "inactive"}:
            raise ValueError("Invalid fault_type. Use 'active' or 'inactive'.")

        section_start = f"{fault_type.capitalize() if fault_type == 'active' else 'InActive'} faults:"
        section_end = "InActive faults:" if fault_type == "active" else "Fault events:"
        fault_pattern = re.compile(
            r"^<(?P<timestamp>\S+)>\s+(?P<id>\w+\s+\(\d+\))\s+(?P<source>[\w:]+)\s+(?P<severity>\w+)"
            r"\s+(?P<num_of_faults>\d+)"
        )

        faults = []
        in_section = False

        with open(os.path.join(file_dir, file_name), "r") as file:
            for line in file:
                line = line.strip()
                if section_start in line:
                    in_section = True
                    continue
                if in_section and section_end in line:
                    break
                if in_section:
                    match = fault_pattern.match(line)
                    if match:
                        faults.append({
                            "timestamp": match.group("timestamp"),
                            "id": match.group("id").strip(),
                            "source": match.group("source").strip(),
                            "severity": match.group("severity").strip(),
                            "num_of_faults": int(match.group("num_of_faults"))
                        })

        return faults

    def get_cell_info_from_ru(self, ru_id=0, info='dn', bts_id=0, du_id=0):
        """
        Retrieves specific information about cells associated with a given radio unit (RU).

        Args:
            ru_id (int): The ID of the radio unit based on test line configuration file.
            info (str): The key of the cell information to retrieve ('id', 'dn', or 'runtime'). Default is 'dn'.
            bts_id (int): The ID of the base station. Default is 0.
            du_id (int): The ID of the distributed unit. Default is 0.

        Returns:
            list: A list of the requested cell information for the specified RU.
        """
        return [
            cell[info]
            for ru_rel in self._get_ru_cell_relation(bts_id=bts_id, du_id=du_id)
            if str(ru_rel['id']) == str(self.get_ru_configuration_id(bts_id=bts_id, du_id=du_id, ru_id=ru_id))
            for cell in ru_rel['cells']
        ]
