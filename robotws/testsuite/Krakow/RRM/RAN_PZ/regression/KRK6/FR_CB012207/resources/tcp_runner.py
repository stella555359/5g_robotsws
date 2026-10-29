"""
Module allows run TCP data transfer on CPE Qualcomm UE
"""

import uuid
import os
import re
import time
import random
import subprocess
import logging
from ute_common_abstract_core.aliases_registry import aliases_registry
from ute_common_abstract_core.config import Config
from taf.rfrl.common_resources.python.common_utilities import get_builtin_value


class DataTransferNotStartedError(Exception):
    """Throws when data transfer was not started."""


class ProcessManager:
    """Creates object to control executed commands in current OS."""

    @staticmethod
    def execute_command(command):
        """
        Executes command in current OS as new process.
        :param command: Command to execute
        :return: instance of process for executed command
        """
        process = subprocess.Popen(command,
                                   stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                   shell=True)
        logging.debug('Executed command : {}'.format(command))
        return process

    @staticmethod
    def wait_for_process(process):
        """
        Waits for given process. It returns std output if process ends with 0 status, otherwise std error.
        :param process: instance of Popen class which represents process
        :return: tuple of boolean process status ond output
        """
        stdout, stderr = process.communicate()
        if process.returncode == 0:
            return True, stdout.decode('utf-8')
        return False, stderr.decode('utf-8')


class UeManager(ProcessManager):

    def __init__(self, ue_pc_hostname, ue_pc_username, ue_pc_password):
        self.ue_pc_hostname = ue_pc_hostname
        self.ue_pc_username = ue_pc_username
        self.ue_pc_password = ue_pc_password
        self.ssh_process = None
        self.iperf_pid = ''
        self.output_log_file = ''

    def start(self, cmd):
        self.output_log_file = self._create_output_log_file_path(ue_pc=True)

        self.execute_command_on_ue_pc('route add 10.84.169.60 MASK 255.255.255.252 0.0.0.0 IF 12')
        time.sleep(5)

        self.ssh_process = self.execute_command_on_ue_pc(cmd, output_log_file=self.output_log_file,
                                                         moba_xterm_shell=True)
        time.sleep(0.8)
        self.iperf_pid = self._get_pid_of_executed_command(cmd)

    def stop(self):
        process = self.execute_command_on_ue_pc(f'taskkill /IM MobaXterm.exe /F')
        status, output = self.wait_for_process(process)
        if status:
            logging.info(f'Iperf with PID {self.iperf_pid} killed successfully on App Server.')
        else:
            logging.info(f'IGNORE BELOW MESSAGE FOR DOWNLINK DATA TRANSFER!\n'
                         f'Killing of iperf with PID {self.iperf_pid} failed on App Server: {output}')
        self.ssh_process.kill()

        self._download_iperf_log()

    def _download_iperf_log(self, timeout=10):

        new_output_log_file = self._create_output_log_file_path()
        ue_pc_command = f"sshpass -p {self.ue_pc_password} scp {self.ue_pc_username}@{self.ue_pc_hostname}:" \
                        f"{self.output_log_file} {new_output_log_file}"

        self.execute_command(ue_pc_command)

        while timeout >= 0:

            if os.path.isfile(new_output_log_file):
                ue_pc_command = f'rm -rf {self.output_log_file}'
                self.execute_command_on_ue_pc(ue_pc_command)

                self.output_log_file = new_output_log_file
                break

            time.sleep(1)
            timeout -= 1

    def get_iperf_output(self):
        """
        Read output of iperf command.
        :return: iperf output
        """

        with open(self.output_log_file, 'r') as fd:
            return fd.read()

    @staticmethod
    def _create_output_log_file_path(ue_pc=False):
        """
        Creates unique file name. File is located in OUTPUT DIRECTORY of robot suite.
        :return: path to file
        """

        if ue_pc:
            output_dir = r'/cygdrive/c/Users/pzkrk/AppData/Roaming/MobaXterm/home/'
        else:
            output_dir = get_builtin_value(param_name="OUTPUT DIR")
        filename = 'iperf_{}_ue.log'.format(uuid.uuid4())
        return os.path.join(output_dir, filename)

    def _get_pid_of_executed_command(self, cmd):
        """
        Returns PID of executed command. Command can be executed on UE PC or UE.
        :param cmd: command which was executed
        :return: pid as string or '-' char if pid was not found
        """
        search_cmd = 'WMIC PROCESS get Commandline,Processid | grep "{}"'.format(cmd)
        process = self.execute_command(search_cmd)
        status, output = self.wait_for_process(process)
        if status:
            return output.strip().split(cmd)[1].strip()
        logging.debug('Can not find PID of executed command: {}'.format(cmd))
        return '-'

    @property
    def iperf_port(self):
        """
        Searches free port of UE PC.
        Use case: ue in bridge mode
        :return: port if UE PC has free port, otherwise None
        """
        while True:
            port = random.randint(5100, 9999)
            cmd = 'netstat -an | grep "{}"'.format(port)
            process = self.execute_command(cmd)
            _, output = self.wait_for_process(process)
            if not output.strip():
                return port

    def execute_command_on_ue_pc(self, command, output_log_file='', moba_xterm_shell=False):
        """
        Executes given command on target device which is chosen based on ue_mode attribute. Command is executed via ssh.

        :param command: command to execute
        :param output_log_file: path to collect output of executed command (ssh output will be redirect to file)
        :param moba_xterm_shell: should bd executed in mobaxterm shell
        :return: process associated with executed command
        """

        if output_log_file:
            output_log_file = ' > {}'.format(output_log_file)  # TODO: add tee

        if moba_xterm_shell:
            command = f'\'/cygdrive/c/Program\\ Files\\ \\(x86\\)/Mobatek/MobaXterm/MobaXterm.exe -newtab ' \
                      f'"{command}{output_log_file}"\''
        else:
            command = f"'{command}'{output_log_file}"

        ue_pc_command = "sshpass -p {} ssh {}@{} {}".format(
            self.ue_pc_password, self.ue_pc_username, self.ue_pc_hostname, command
        )
        return self.execute_command(ue_pc_command)

    @property
    def ue_ip(self):
        """
        Reads IP assigned on UE_PC "Ethernet adapter Ethernet" interface (in Windows system).
        Use case: ue in bridge mode
        :return: IP address if UE-PC has assigned IP, otherwise empty string
        """
        cmd = 'ipconfig'
        process = self.execute_command_on_ue_pc(cmd)
        status, output = self.wait_for_process(process)
        if status:
            for ip in self._find_all_ue_pc_ips(output):
                if 'Mobile Broadband adapter Cellular' in ip['name']:
                    logging.info('Mobile Broadband Cellular ip address: {}'.format(ip['ip_address']))
                    return ip['ip_address']
        logging.info('Mobile Broadband Cellular ip address not found.')
        return '-'

    @staticmethod
    def _find_all_ue_pc_ips(ipconfig_output):
        """
        Finds IP address for all interfaces from Windows "ipconfig" command output.
        :param ipconfig_output: output of ipconfig
        :return: dict with IP address and Windows interface name
        """

        lines = ipconfig_output.splitlines()
        lines = filter(lambda x: x, lines)
        ip_address = ''
        name = ''
        print(lines)
        for line in lines:
            # Interface name
            is_interface_name = re.match(r'^[a-zA-Z0-9].*:$', line)
            if is_interface_name:
                if name and ip_address:
                    yield {"ip_address": ip_address, "name": name}
                ip_address = ''
                name = line.rstrip(':')
            line = line.strip().lower()
            if ':' not in line:
                continue
            value = line.split(':')[-1]
            value = value.strip()
            # IP Address
            is_ip_address = not ip_address and re.match(r'ipv4 address|autoconfiguration ipv4 address|ip address', line)
            if is_ip_address:
                ip_address = value
                ip_address = ip_address.replace('(preferred)', '')
                ip_address = ip_address.strip()
        if name and ip_address:
            yield {"ip_address": ip_address, "name": name}


class AppServerManager(ProcessManager):

    def __init__(self, app_server_hostname, app_server_username, app_server_password, app_server_bind_interface):
        self.hostname = app_server_hostname
        self.username = app_server_username
        self.password = app_server_password
        self.app_server_bind_interface = app_server_bind_interface
        self.ssh_process = None
        self.iperf_pid = ''
        self.output_log_file = ''

    def start(self, cmd):
        self.output_log_file = self._create_output_log_file_path()
        self.ssh_process = self.execute_command_on_app_server(cmd, output_log_file=self.output_log_file)
        time.sleep(0.8)
        self.iperf_pid = self._get_pid_of_executed_command(cmd)

    def stop(self):
        process = self.execute_command_on_app_server(f'kill -9 {self.iperf_pid}')
        status, output = self.wait_for_process(process)
        if status:
            logging.info(f'Iperf with PID {self.iperf_pid} killed successfully on App Server.')
        else:
            logging.info(f'IGNORE BELOW MESSAGE FOR DOWNLINK DATA TRANSFER!\n'
                         f'Killing of iperf with PID {self.iperf_pid} failed on App Server: {output}')
        self.ssh_process.kill()

    def get_iperf_output(self):
        """
        Read output of iperf command.
        :return: iperf output
        """
        with open(self.output_log_file, 'r') as fd:
            return fd.read()

    @property
    def iperf_port(self):
        """
        Returns free port of app server.
        :return: port
        """
        while True:
            port = random.randint(5100, 9999)
            cmd = "lsof -i:{} > /dev/null 2>&1 && echo 1 || echo 0".format(port)
            process = self.execute_command_on_app_server(cmd)
            _, output = self.wait_for_process(process)
            if output.strip() == '0':
                return port

    @staticmethod
    def _create_output_log_file_path():
        """
        Creates unique file name. File is located in OUTPUT DIRECTORY of robot suite.
        :return: path to file
        """

        output_dir = get_builtin_value(param_name="OUTPUT DIR")
        filename = 'iperf_{}_app_server.log'.format(uuid.uuid4())
        return os.path.join(output_dir, filename)

    def execute_command_on_app_server(self, command, output_log_file=''):
        """
        Executes given command on app server. Command is executed via ssh.

        :param command: command to execute
        :param output_log_file: path to collect output of executed command (ssh output will be redirect to file)
        :return: process associated with executed command
        """
        if output_log_file:
            output_log_file = ' > {}'.format(output_log_file)
        app_server_command = 'sshpass -p {} ssh {}@{} "{}"{}'.format(
            self.password, self.username, self.hostname, command, output_log_file
        )
        return self.execute_command(app_server_command)

    def _get_pid_of_executed_command(self, cmd):
        """
        Returns PID of executed command on app server.
        :param cmd: command which was executed
        :return: pid as string or '-' char if pid was not found
        """
        process = self.execute_command_on_app_server("ps -A -o pid,cmd | grep -v grep | grep '{}'".format(cmd))
        status, output = self.wait_for_process(process)
        if status:
            return output.strip().split(' ')[0].strip()
        return '-'


class DataTransfer:
    """Creates data transfer object."""

    def __init__(self, ue_pc_hostname, ue_pc_username, ue_pc_password,
                 app_server_hostname, app_server_username, app_server_password, app_server_bind_interface):
        self.ue_manager = UeManager(ue_pc_hostname, ue_pc_username, ue_pc_password)
        self.app_server_manager = AppServerManager(app_server_hostname, app_server_username, app_server_password,
                                                   app_server_bind_interface)
        self.direction = ''
        self.is_dl = False

    def start(self, app_server_cmd, ue_cmd):

        self.is_dl = '-c' in app_server_cmd

        if self.is_dl:
            iperf_port = self.ue_manager.iperf_port
        else:
            iperf_port = self.app_server_manager.iperf_port

        dynamic_options = {
            '<APP_SERVER_BIND_IP>': self.app_server_manager.app_server_bind_interface,
            '<APP_SERVER_IPERF_PORT>': iperf_port,
            '<UE_IP>': self.ue_manager.ue_ip,
            '<UE_IPERF_PORT>': iperf_port
        }

        app_server_cmd = self._fill_dynamic_options(app_server_cmd, dynamic_options)
        ue_cmd = self._fill_dynamic_options(ue_cmd, dynamic_options)

        logging.info(f'App server command: {app_server_cmd}')
        logging.info(f'UE command: {ue_cmd}')

        if self.is_dl:
            self.ue_manager.start(ue_cmd)
            self.app_server_manager.start(app_server_cmd)
        else:
            self.app_server_manager.start(app_server_cmd)
            self.ue_manager.start(ue_cmd)

    def stop(self):
        if self.is_dl:
            self.ue_manager.stop()
            self.app_server_manager.stop()
        else:
            self.app_server_manager.stop()
            self.ue_manager.stop()

    @staticmethod
    def _fill_dynamic_options(cmd, dynamic_options):

        for name, value in dynamic_options.items():
            cmd = cmd.replace(name, str(value))

        return cmd


class tcp_runner:
    """Robot library to schedule data transfer via adb and ssh tools on askey UE."""

    _data_transfers = {}

    def __init__(self):
        self.config = Config()

    def start_data_transfer(self, dt_name, ue_alias, app_server_cmd, ue_cmd):

        dt = self._create_data_transfer(ue_alias)
        dt.start(app_server_cmd, ue_cmd)

        self._data_transfers[dt_name] = dt

    def stop_data_transfer(self, dt_name):

        dt = self._data_transfers.get(dt_name)

        if dt is None:
            raise DataTransferNotStartedError(f'"{dt_name}" data transfer is not started.')

        dt.stop()

    def get_app_server_iperf_log_path(self, dt_name):

        dt = self._data_transfers.get(dt_name)

        if dt is None:
            raise DataTransferNotStartedError(f'"{dt_name}" data transfer is not started.')

        return dt.app_server_manager.output_log_file

    def get_ue_iperf_log_path(self, dt_name):

        dt = self._data_transfers.get(dt_name)

        if dt is None:
            raise DataTransferNotStartedError(f'"{dt_name}" data transfer is not started.')

        return dt.ue_manager.output_log_file

    def _create_data_transfer(self, ue_alias, ue_pool_name='TafUeAtPool'):

        ute_ue = aliases_registry()[ue_alias]
        ues_config = self.config.get_config()
        ue_config = (ues_config["UE_POOLS"][ue_pool_name]["inline_config"][ute_ue.name]['CONSTRUCTOR_PARAMETERS']
                     ['configuration'])

        dt = DataTransfer(
            ue_pc_hostname=ue_config['ue_pc_address'],
            ue_pc_username=ue_config['ue_pc_login'],
            ue_pc_password=ue_config['ue_pc_password'],
            app_server_hostname=ue_config['data_transfer']['iperf']['app_server']['address'],
            app_server_username=ue_config['data_transfer']['iperf']['app_server']['user'],
            app_server_password=ue_config['data_transfer']['iperf']['app_server']['password'],
            app_server_bind_interface=ue_config['data_transfer']['iperf']['app_server']['bind_interface_ip'],
        )

        return dt
