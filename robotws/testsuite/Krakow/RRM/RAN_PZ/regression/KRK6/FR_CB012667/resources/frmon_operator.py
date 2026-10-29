"""
FrmonOperator module.
Module for managing feature CB012667 on RU devices through frmon shell operations.

:author: Dawid Dabrowski Mateusz Potoniec
:contact: dawid.dabrowski@nokia.com mateusz.potoniec@nokia.com
:maintainer: dawid.dabrowski@nokia.com mateusz.potoniec@nokia.com
"""
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations
from moler.exceptions import CommandTimeout, CommandFailure

from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.logger import custom_logger as logger


class FrmonOperator:

    def __init__(self):
        self.ru_operations = GnbRuOperations()

        self.create_agent_command = {
            'action_name': 'create',
            'node': '/',
            'agent_type': 'ConfigAccess',
            'agent_instance_path': '/CI/ConfigAccess',
            'init_parameter': '/module'
        }

        self.fetch_file_command = {
            'action_name': 'fetch',
            'node': '/CI/ConfigAccess',
            'agent_type': 'DECODED',
            'agent_instance_path': '"hw_capabilities.bin"',
            'init_parameter': '"/tmp/hw_capabilities.json"'
        }

        self.store_file_command = {
            'action_name': 'store',
            'node': '/CI/ConfigAccess',
            'agent_type': 'PERMANENT DECODED',
            'agent_instance_path': '"hw_capabilities.bin"',
            'init_parameter': '"/tmp/hw_capabilities.json"'
        }

        self.delete_file_command = {
            'action_name': 'delete',
            'node': '/CI/ConfigAccess',
            'agent_type': '',
            'agent_instance_path': '"hw_capabilities.bin"',
            'init_parameter': ''
        }

        self.terminate_command = {
            'action_name': 'terminate',
            'node': '/CI/ConfigAccess',
            'agent_type': '',
            'agent_instance_path': '',
            'init_parameter': ''
        }

        self.device = None

    def turn_on_feature(self, bts_id=0, du_id=0, ru_id=0):
        """
        Enable feature CB012667 on RU.

        :param bts_id: ID of the BTS
        :param du_id: ID of the DU
        :param ru_id: ID of the RU
        """

        self.log_in_to_ru(bts_id=bts_id, du_id=du_id, ru_id=ru_id)

        try:
            self.enter_frmon_shell()
            self.execute_frmon_command(command=self.create_agent_command)
            self.execute_frmon_command(command=self.fetch_file_command)
            self.enter_ru_shell()
            self.turn_on_feature_in_file()
            self.enter_frmon_shell()
            self.execute_frmon_command(command=self.store_file_command)
            self.execute_frmon_command(command=self.terminate_command)
            self.enter_ru_shell()
        except Exception as e:
            self.enter_ru_shell()
            self.terminate_frmon_agent_after_exception()
            raise e
        finally:
            self.log_out_from_ru()

    def turn_off_feature(self, bts_id=0, du_id=0, ru_id=0):
        """
        Disable feature CB012667 on RU.

        :param bts_id: ID of the BTS
        :param du_id: ID of the DU
        :param ru_id: ID of the RU
        """

        self.log_in_to_ru(bts_id=bts_id, du_id=du_id, ru_id=ru_id)

        try:
            self.enter_frmon_shell()
            self.execute_frmon_command(command=self.create_agent_command)
            self.execute_frmon_command(command=self.fetch_file_command)
            self.enter_ru_shell()
            self.turn_off_feature_in_file()
            self.enter_frmon_shell()
            self.execute_frmon_command(command=self.store_file_command)
            self.execute_frmon_command(command=self.terminate_command)
            self.enter_ru_shell()
        except Exception as e:
            self.enter_ru_shell()
            self.terminate_frmon_agent_after_exception()
            raise e
        finally:
            self.log_out_from_ru()

    def terminate_frmon_agent_after_exception(self):
        """
        Terminate frmon agent after exception occurs.

        Attempts to enter frmon shell and terminate ConfigAccess agent.
        Handles CommandTimeout gracefully if shell is already active.
        """
        logger.log_info_to_console("Terminating frmon agent after exception", log_hierarchy=2)
        try:
            self.enter_frmon_shell()
            self.execute_frmon_command(command=self.terminate_command)
            self.enter_ru_shell()
        except (CommandTimeout, CommandFailure):
            self.execute_frmon_command(command=self.terminate_command)
            self.enter_ru_shell()
        logger.log_info_to_console("Frmon agent terminated after exception", log_hierarchy=2)

    @load_moler_configuration_from_tl()
    def log_in_to_ru(self, bts_id=0, du_id=0, ru_id=0):
        """
        Log in to RU device.

        :param bts_id: ID of the BTS
        :param du_id: ID of the DU
        :param ru_id: ID of the RU
        """
        if self.device is None:
            self.device = self.ru_operations.get_ru_device(bts_id=bts_id, du_id=du_id, ru_id=ru_id)
            self.enter_ru_shell()

    def log_out_from_ru(self):
        """
        Log out from RU device.

        Resets device, connection and prompt attributes to None.
        """
        self.device = None

    def enter_frmon_shell(self):
        """
        Enter frmon shell on RU device.
        """
        self.device.goto_state("FRMONSHELL")

    def enter_ru_shell(self):
        """
        Enter RU shell (exit from frmon shell).
        """
        self.device.goto_state("RU")

    def command_to_string(self, command):
        """
        Convert command dictionary to readable string format.

        :param command: Dictionary with frmon command parameters
        :return: String representation of the command
        """
        action = command.get('action_name', '')
        node = command.get('node', '')
        agent_type = command.get('agent_type', '')
        agent_path = command.get('agent_instance_path', '')
        init_param = command.get('init_parameter', '')

        parts = [node, 'action', action]
        if agent_type:
            parts.append(agent_type)
        if agent_path:
            parts.append(agent_path)
        if init_param:
            parts.append(init_param)

        return ' '.join(parts)

    def execute_frmon_command(self, command):
        """
        Execute command in frmon shell.

        :param command: Dictionary with frmon command parameters
        :return: Command execution result
        """
        try:
            frmon_cmd = self.device.get_cmd(cmd_name="action", cmd_params=command)
            result = frmon_cmd()
            command_str = self.command_to_string(command)
            logger.log_info_to_console(
                f"Executed frmon command '{command_str}': {result}",
                log_hierarchy=2
            )
            return result
        except (CommandTimeout, CommandFailure) as e:
            command_str = self.command_to_string(command)
            logger.log_warn_to_console(f"Failed to execute frmon command '{command_str}'", log_hierarchy=2)
            raise e

    def turn_on_feature_in_file(self):
        """
        Turn on feature in configuration file.

        Changes CARRIER_CREATION_IN_FREERUN value from 1 to 0.

        :return: Command execution result
        """
        return self.change_feature_in_file(old_value="0", new_value="1")

    def turn_off_feature_in_file(self):
        """
        Turn off feature in configuration file.

        Changes CARRIER_CREATION_IN_FREERUN value from 0 to 1.

        :return: Command execution result
        """
        return self.change_feature_in_file(old_value="1", new_value="0")

    def change_feature_in_file(self, old_value, new_value):
        """
        Change feature value in configuration file.

        Modifies CARRIER_CREATION_IN_FREERUN defaultValue
        in /tmp/hw_capabilities.json.

        :param old_value: Current value to replace
        :param new_value: New value to set
        :return: Command execution result
        """
        logger.log_info_to_console(
            f"Changing CARRIER_CREATION_IN_FREERUN in json file "
            f"from {old_value} to {new_value}",
            log_hierarchy=2
        )
        sed_command = (
            rf"sudo sed -i '/\"name\": \"CARRIER_CREATION_IN_FREERUN\"/ "
            rf"{{ N; s/\(\"defaultValue\": \){old_value},/\1{new_value},/; }}' "
            rf"/tmp/hw_capabilities.json"
        )

        cmd = self.device.get_cmd(
            cmd_name="run_script",
            cmd_params={"script_command": sed_command}
        )
        return cmd()
