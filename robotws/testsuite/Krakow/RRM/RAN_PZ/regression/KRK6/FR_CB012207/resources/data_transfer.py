"""
Module allows run data transfer on UE Askey.
It is temporary solution while waiting on official fixing Askey plugin.
"""

import os
import time
import uuid
import re
import random
import subprocess
import logging
from ute_common_abstract_core.aliases_registry import aliases_registry
from ute_common_abstract_core.config import Config
from taf.rfrl.common_resources.python.common_utilities import get_builtin_value


class DataTransferArgumentError(Exception):
    """Throws when argument of data transfer is invalid."""
    pass


class DataTransferNotDefinedError(Exception):
    """Throws when data transfer was not started."""
    pass


class DataTransferVerificationError(Exception):
    """Throws when verification of data transfer failed."""
    pass


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
    def __init__(self, ue_pc_hostname, ue_pc_username, ue_pc_password, ue_mode):
        self.ue_pc_hostname = ue_pc_hostname
        self.ue_pc_username = ue_pc_username
        self.ue_pc_password = ue_pc_password
        self.ue_mode = ue_mode
        self.ssh_process = None
        self.iperf_pid = ''
        self.output_log_file = ''

    def start_iperf(self, **options):
        """
        Starts iperf for UE. Iperf will be started on UE if UE is configured in router mode.
        Iperf will be started on UE PC if UE is configured in bridge mode.
        :param options: options to run iperf
        :return: None
        """
        cmd = self._build_iperf_cmd(**options)
        if self.ue_mode == 'bridge':
            logging.info('UE mode is bridge. Iperf will be started on UE_PC.')
            cmd = cmd.replace('iperf', 'iperf.exe')
        self.output_log_file = self._create_output_log_file_path()
        self.ssh_process = self.execute_command(cmd, output_log_file=self.output_log_file)
        time.sleep(0.2)
        self.iperf_pid = self._get_pid_of_executed_command(cmd)
        logging.info('UE iperf pid: {}'.format(self.iperf_pid))

    def stop_iperf(self):
        """
        Stops iperf for UE. Iperf will be stopped on UE if UE is configured in router mode.
        Iperf will be stopped on UE PC if UE is configured in bridge mode.

        !!! It works with Windows UE-PC only !!!

        :return: None
        """
        cmd = 'kill -9 {}'.format(self.iperf_pid) if self.ue_mode == 'router' \
            else 'taskkill /F /T /PID {}'.format(self.iperf_pid)
        process = self.execute_command(cmd)
        status, output = self.wait_for_process(process)
        if status:
            logging.info('Iperf with PID {} killed successfully.'.format(self.iperf_pid))
        else:
            msg = 'IGNORE BELOW MESSAGE FOR UPLINK DATA TRANSFER!\nKilling of iperf with PID {} failed: {}.'
            logging.info(msg.format(self.iperf_pid, output))
        self.ssh_process.kill()

    def execute_command(self, command, output_log_file=''):
        """
        Executes given command on target device which is chosen based on ue_mode attribute. Command is executed via ssh.

        :param command: command to execute
        :param output_log_file: path to collect output of executed command (ssh output will be redirect to file)
        :return: process associated with executed command
        """
        if output_log_file:
            output_log_file = ' > {}'.format(output_log_file)  # TODO: add tee
        if self.ue_mode == 'router':
            ue_pc_command = "sshpass -p {} ssh {}@{} 'adb shell \"{}\"'{}".format(
                self.ue_pc_password, self.ue_pc_username, self.ue_pc_hostname, command, output_log_file
            )
        else:
            ue_pc_command = "sshpass -p {} ssh {}@{} '{}'{}".format(
                self.ue_pc_password, self.ue_pc_username, self.ue_pc_hostname, command, output_log_file
            )
        return super(UeManager, self).execute_command(ue_pc_command)

    def get_ip(self):
        """
        Returns IP assigned to UE. IP can be used to start iperf data transfer.
        :return: ip address
        """
        if self.ue_mode == 'router':
            ip = self._get_ue_ip()
        else:
            ip = self._get_ue_pc_ip()
        return ip

    def get_port(self):
        """
        Returns free port of UE.
        :return: port
        """
        if self.ue_mode == 'router':
            port = self._get_ue_port()
        else:
            port = self._get_ue_pc_port()
        return port

    def get_iperf_output(self):
        """
        Read output of iperf command.
        :return: iperf output
        """
        with open(self.output_log_file, 'r') as fd:
            return fd.read()

    def _get_ue_ip(self):
        """
        Reads IP assigned on UE interface (in android system). Use case: ue in router mode
        :return: IP address if ue has assigned IP, otherwise empty string
        """
        cmd = 'ip a | grep 10.8'
        process = self.execute_command(cmd)
        status, output = self.wait_for_process(process)
        if status:
            ue_ip = re.findall(r'[0-9]+(?:\.[0-9]+){3}', output)[0]
            return ue_ip
        return ''

    def _get_ue_pc_ip(self):
        """
        Reads IP assigned on UE_PC "Ethernet adapter Ethernet" interface (in Windows system).
        Use case: ue in bridge mode
        :return: IP address if UE-PC has assigned IP, otherwise empty string
        """
        cmd = 'ipconfig'
        process = self.execute_command(cmd)
        status, output = self.wait_for_process(process)
        if status:
            for ip in self._find_all_ue_pc_ips(output):
                if 'Ethernet adapter Ethernet' in ip['name']:
                    logging.info('UE PC ip address: {}'.format(ip['ip_address']))
                    return ip['ip_address']
        return ''

    def _get_ue_port(self):
        """
        Searches free port of UE.
        Use case: ue in router mode
        :return: port if UE has free port, otherwise None
        """
        command = 'cat /proc/net/udp'
        process = self.execute_command(command)
        status, output = self.wait_for_process(process)
        udp_ports = output if status else ''
        command = 'cat /proc/net/tcp'
        process = self.execute_command(command)
        status, output = self.wait_for_process(process)
        tcp_ports = output if status else ''
        while True:
            port = random.randint(5100, 9999)
            port_pattern = ':{}'.format(hex(port)[2:])
            if port_pattern not in udp_ports and port_pattern not in tcp_ports:
                return port

    def _get_ue_pc_port(self):
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

    def _get_pid_of_executed_command(self, cmd):
        """
        Returns PID of executed command. Command can be executed on UE PC or UE.
        :param cmd: command which was executed
        :return: pid as string or '-' char if pid was not found
        """
        if self.ue_mode == 'router':
            search_cmd = 'ps -ef ww | grep -v grep | grep \\"{}\\"'.format(cmd)
        else:
            search_cmd = 'WMIC PROCESS get Commandline,Processid | grep "{}"'.format(cmd)
        process = self.execute_command(search_cmd)
        status, output = self.wait_for_process(process)
        if status:
            return output.strip().split(' ')[0].strip() if self.ue_mode == 'router' \
                else output.strip().split(cmd)[1].strip()
        logging.debug('Can not find PID of executed command: {}'.format(cmd))
        return '-'

    @staticmethod
    def _build_iperf_cmd(**options):
        """
        Creates iperf command based on given options. Prepares command for client / server mode.
        :param options: options for iperf command
        :return: iperf command as string
        """
        iperf_command = IperfCommandBuilder(**options).build()
        return str(iperf_command)

    @staticmethod
    def _create_output_log_file_path():
        """
        Creates unique file name. File is located in OUTPUT DIRECTORY of robot suite.
        :return: path to file
        """
        output_dir = get_builtin_value(param_name="OUTPUT DIR")
        filename = 'iperf_{}_ue.log'.format(uuid.uuid4())
        return os.path.join(output_dir, filename)

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

    def start_iperf(self, **options):
        """
        Starts iperf for app server.
        :param options: options to run iperf
        :return: None
        """
        cmd = self._build_iperf_cmd(**options)
        self.output_log_file = self._create_output_log_file_path()
        self.ssh_process = self.execute_command_on_app_server(cmd, output_log_file=self.output_log_file)
        time.sleep(0.5)
        self.iperf_pid = self._get_pid_of_executed_command(cmd)
        logging.info('App Server iperf pid: {}'.format(self.iperf_pid))

    def stop_iperf(self):
        """
        Stops iperf for app server.
        :return: None
        """
        cmd = 'kill -9 {}'.format(self.iperf_pid)
        process = self.execute_command_on_app_server(cmd)
        status, output = self.wait_for_process(process)
        if status:
            logging.info('Iperf with PID {} killed successfully on App Server.'.format(self.iperf_pid))
        else:
            msg = 'IGNORE BELOW MESSAGE FOR DOWNLINK DATA TRANSFER!\n' \
                  'Killing of iperf with PID {} failed on App Server: {}'
            logging.info(msg.format(self.iperf_pid, output))
        self.ssh_process.kill()

    def get_ip(self):
        """
        Returns IP assigned to app server. IP can be used to start iperf data transfer.
        :return: ip address
        """
        return self.app_server_bind_interface

    def get_port(self):
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

    def get_iperf_output(self):
        """
        Read output of iperf command.
        :return: iperf output
        """
        with open(self.output_log_file, 'r') as fd:
            return fd.read()

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

    @staticmethod
    def _build_iperf_cmd(**options):
        """
        Creates iperf command based on given options. Prepares command for client / server mode.
        :param options: options for iperf command
        :return: iperf command as string
        """
        iperf_command = IperfCommandBuilder(**options).build()
        return str(iperf_command)

    @staticmethod
    def _create_output_log_file_path():
        """
        Creates unique file name. File is located in OUTPUT DIRECTORY of robot suite.
        :return: path to file
        """
        output_dir = get_builtin_value(param_name="OUTPUT DIR")
        filename = 'iperf_{}_app_server.log'.format(uuid.uuid4())
        return os.path.join(output_dir, filename)


class DataTransfer:
    """Creates data transfer object."""

    def __init__(self, ue_pc_hostname, ue_pc_username, ue_pc_password, ue_mode,
                 app_server_hostname, app_server_username, app_server_password, app_server_bind_interface):
        self.ue_manager = UeManager(ue_pc_hostname=ue_pc_hostname,
                                    ue_pc_username=ue_pc_username,
                                    ue_pc_password=ue_pc_password,
                                    ue_mode=ue_mode)
        self.app_server_manager = AppServerManager(app_server_hostname=app_server_hostname,
                                                   app_server_username=app_server_username,
                                                   app_server_password=app_server_password,
                                                   app_server_bind_interface=app_server_bind_interface)
        self.direction = ''
        self.protocol = ''

    def start(self, **options):
        """
        Starts data transfer. Runs iperf commands on UE/UE-PC (depends on UE mode) and app server.
        :param options: dict with data transfer configuration
        :return: None
        """
        self.direction = self._get_data_transfer_direction(**options)
        self.protocol = self._get_data_transfer_protocol(**options)
        if self.direction == 'ul':
            options['ip'] = self.app_server_manager.get_ip()
            options['port'] = self.app_server_manager.get_port() if 'port' not in options else options['port']
            app_server_options = dict(mode='server', **options)
            self.app_server_manager.start_iperf(**app_server_options)
            ue_options = dict(mode='client', **options)
            self.ue_manager.start_iperf(**ue_options)
        else:
            options['ip'] = self.ue_manager.get_ip()
            options['port'] = self.ue_manager.get_port() if 'port' not in options else options['port']
            ue_options = dict(mode='server', **options)
            self.ue_manager.start_iperf(**ue_options)
            app_server_options = dict(mode='client', **options)
            self.app_server_manager.start_iperf(**app_server_options)
        time.sleep(1)

    def stop(self):
        """
        Stops data transfer.
        :return: None
        """
        time.sleep(2)
        if self.direction == 'ul':
            self.ue_manager.stop_iperf()
            self.app_server_manager.stop_iperf()
        else:
            self.app_server_manager.stop_iperf()
            self.ue_manager.stop_iperf()

    def verify(self, **methods):
        """
        Verifies data transfer level.
        :param methods: dict which indicates method of verification,
                        e.g: argument name is name of method verification
                        and assigned value is tuple of arguments passed to method
        :return: None
        """
        app_server_iperf_output = self.app_server_manager.get_iperf_output()
        ue_iperf_output = self.ue_manager.get_iperf_output()
        logging.info('App server iperf output:\n{}'.format(app_server_iperf_output))
        logging.info('UE iperf output:\n{}'.format(ue_iperf_output.replace('\n\n', '\n')))
        if self.direction == 'ul':
            report = '\n'.join(app_server_iperf_output.strip().split('\n')[-5:])
        else:
            report = '\n'.join(ue_iperf_output.strip().split('\n')[-5:])
        if 'average_throughput' in methods:
            tput_min = methods.get('average_throughput')[0]
            tput_max = methods.get('average_throughput')[1]
            self._verify_average_throughput(report, tput_min, tput_max)

    def _verify_average_throughput(self, report, tput_min, tput_max):
        """
        Verifies if data transfer level is between given values.
        :param report: output of server iperf
        :param tput_min: minimum allowed value of data transmission level
        :param tput_max: maximum allowed value of data transmission level
        """
        tput = self._get_average_throughput_from_server_report(report, self.protocol)
        if not tput_min <= tput <= tput_max:
            raise DataTransferVerificationError(
                'Level of data transfer is out of range. Current level: {} Mbits/sec.'.format(tput))
        logging.info('Current level of data transfer: {} Mbits/sec.'.format(tput))

    @staticmethod
    def _get_average_throughput_from_server_report(report, protocol):
        """
        Cuts value of data transmission level from server iperf output.
        :param report: iperf server output
        :param protocol: direction of data transfer
        :return: value of data transfer
        """
        if 'out-of-order' in report:
            report = '\n'.join(report.strip().split('\n')[-2:-1])
            logging.debug('Received datagrams out-of-order.')
        logging.info('Checking report:\n{}\n'.format(report))
        # TODO: check if finish of iperf can be detected (TEMPORARY COMMENTED)
        # if 'Server Report' not in report and self.protocol == 'udp':
        #     raise DataTransferVerificationError(
        #           'Missing server report. Check if data transmission has finished and ue mode.')
        report_chunks = report.split()
        if len(report_chunks) < 6:
            raise DataTransferVerificationError('Server report can not be parsed.')
        tput_units = report_chunks[-1] if protocol == 'tcp' else report_chunks[-5]
        tput = report_chunks[-2] if protocol == 'tcp' else report_chunks[-6]
        if 'Mbits/sec' not in tput_units:
            raise DataTransferVerificationError(
                'Throughput in server report is not in Mbits/sec units. Current units: {}'.format(tput_units))
        try:
            tput = float(tput)
        except ValueError:
            raise DataTransferVerificationError(
                'Throughput level {} cannot be dumped to integer value.'.format(report_chunks[-2]))
        return tput

    @staticmethod
    def _get_data_transfer_direction(**options):
        """
        Gets data transfer direction from data transfer configuration parameters.
        :param options: data transfer configuration parameters
        :return: direction of data transfer
        """
        direction = options.get('direction')
        if direction is None:
            msg = 'Invalid value for "direction" argument: {}. Allowed values: ul , dl'.format(direction)
            raise DataTransferArgumentError(msg)
        return direction

    @staticmethod
    def _get_data_transfer_protocol(**options):
        """
        Gets data transfer protocol from data transfer configuration parameters.
        :param options: data transfer configuration parameters
        :return: protocol of data transfer
        """
        protocol = options.get('protocol')
        if protocol is None:
            msg = 'Invalid value for "protocol" argument: {}. Allowed values: tcp , udp'.format(protocol)
            raise DataTransferArgumentError(msg)
        return protocol


class DataTransferFactory:
    """Builds DataTransfer object based on ue and ue-pc configuration."""

    def __init__(self, config):
        self.config = config

    def create(self, ue_alias, ue_mode='router', ue_pool_name='TafUeAtPool'):
        """
        Creates ready to use data transfer.

        :param ue_alias: alias of ue registered in "Require Ue" keyword
        :param ue_mode: mode of Askey UE (router or bridge)
        :param ue_pool_name: ue pool (default support for AT plugin: TafUeAtPool)
        :return: prepared data transfer
        """
        ute_ue = aliases_registry()[ue_alias]
        ues_config = self.config.get_config()
        ue_config = ues_config["UE_POOLS"][ue_pool_name]["inline_config"][ute_ue.name][
            'CONSTRUCTOR_PARAMETERS']['configuration']
        dt = DataTransfer(
            ue_pc_hostname=ue_config['ue_pc_address'],
            ue_pc_username=ue_config['ue_pc_login'],
            ue_pc_password=ue_config['ue_pc_password'],
            ue_mode=ue_mode,
            app_server_hostname=ue_config['data_transfer']['iperf']['app_server']['address'],
            app_server_username=ue_config['data_transfer']['iperf']['app_server']['user'],
            app_server_password=ue_config['data_transfer']['iperf']['app_server']['password'],
            app_server_bind_interface=ue_config['data_transfer']['iperf']['app_server']['bind_interface_ip'],
        )
        return dt


class data_transfer:
    """Robot library to schedule data transfer via adb and ssh tools on askey UE."""

    _data_transfers = {}

    def __init__(self):
        self.config = Config()

    def start_data_transfer(self, dt_name, ue_alias, ue_mode, **options):
        """
        Starts data transfer on ue indicated by ue_alias. UE should be initialized in ute_ue library via
        'Require UE    <ue_alias>' keyword.

        :param dt_name: name to identify data transfer in future
        :param ue_mode: mode of Askey UE (router or bridge)
        :param ue_alias: name of ue
        :return: None
        """
        ue_mode = self._check_ue_mode(ue_mode)
        dt = DataTransferFactory(self.config).create(ue_alias, ue_mode)
        dt.start(**options)
        self._data_transfers[dt_name] = dt

    def stop_data_transfer(self, dt_name):
        """
        Stops given data transfer.

        :param dt_name: name of data transfer
        :return: None
        """
        dt = self._data_transfers.get(dt_name)
        if dt is None:
            raise DataTransferNotDefinedError('"{}" data transfer is not started.'.format(dt_name))
        dt.stop()

    def verify_average_throughput(self, dt_name, tput_min, tput_max):
        """
        Verifies if data transfer is between given range.

        :tput_min: minimum acceptable value of data transfer
        :tput_min: maximum acceptable value of data transfer
        :return: None
        """
        dt = self._data_transfers.get(dt_name)
        if dt is None:
            raise DataTransferNotDefinedError('"{}" data transfer is not started.'.format(dt_name))
        dt.verify(average_throughput=(int(tput_min), int(tput_max),))

    @staticmethod
    def _check_ue_mode(mode):
        """
        Checks UE mode has assigned valid value.
        :param mode: value of ue mode
        :return: passed value of mode if it is valid
        """
        if mode not in ('router', 'bridge'):
            raise DataTransferArgumentError(
                'UE can be configured in "router" (iperf scheduled on UE) or "bridge" (iperf scheduled on UE-PC) mode.')
        return mode


class IperfCommandBuilder:
    """Creates builder which prepares iperf 3 command (compatible with Linux and Android environment)."""

    def __init__(self, **options):
        self.options = options
        self.value = ''

    def build(self):
        """
        Builds iperf command. Command is prepared based on required options (mode, ip, port, duration*, protocol) and
        optional options (throughput, buffer, packet_size, packet, parallel, parallel_streams).

        * duration is required only in server mode

        :return: self
        """
        mode = self._get_mode()
        ip = self._get_ip()
        port = self._get_port()
        duration = self._get_duration()
        protocol = self._get_protocol()
        throughput = self._get_throughput()
        buffer = self._get_buffer()
        packet = self._get_packet()
        parallel = self._get_parallel()
        linux_congestion = self._get_linux_congestion()

        if mode == 'client':
            cmd_template = 'iperf -c {ip} -p {port} -t {duration} -i 1 ' \
                           '{protocol}{packet}{buffer}{parallel}{throughput}{linux_congestion}'
            self.value = cmd_template.format(
                ip=ip, protocol=protocol, packet=packet, port=port, duration=duration, parallel=parallel, buffer=buffer,
                throughput=throughput, linux_congestion=linux_congestion
            )
        else:
            cmd_template = 'iperf -s -B {bind} -p {port} -i 1 {protocol}'
            self.value = cmd_template.format(bind=ip, port=port, protocol=protocol)
        return self

    def _get_mode(self):
        """
        Gets iperf mode.

        :raises DataTransferArgumentError: if mode is missing in options or it is not set to client or server
        :return: client or server string
        """
        mode = self.options.get('mode')
        if mode not in ['client', 'server']:
            msg = 'Invalid value for "mode" argument: {}. Allowed values: ul , dl'.format(mode)
            raise DataTransferArgumentError(msg)
        return mode

    def _get_ip(self):
        """
        Gets ip.

        :raises DataTransferArgumentError: if ip is missing in options
        :return: ip address
        """
        ip = self.options.get('ip')
        if ip is None:
            msg = 'Invalid value for "ip" argument: {}'.format(ip)
            raise DataTransferArgumentError(msg)
        return ip

    def _get_port(self):
        """
        Gets port for server or client.

        :raises DataTransferArgumentError: if port is missing in options
        :return: port
        """
        port = self.options.get('port')
        if port is None:
            msg = 'Invalid value for "port" argument: {}'.format(port)
            raise DataTransferArgumentError(msg)
        return port

    def _get_duration(self):
        """
        Gets duration.

        :raises DataTransferArgumentError: if duration is missing in options
        :return: iperf duration
        """
        duration = self.options.get('duration')
        mode = self.options.get('mode')
        if duration is None and mode == 'client':
            msg = 'Invalid value for "duration" argument: {}'.format(duration)
            raise DataTransferArgumentError(msg)
        return duration

    def _get_protocol(self):
        """
        Gets protocol and prepares option to append to iperf command.

        :raises DataTransferArgumentError: if protocol is missing in options or it it not set to udp or tcp
        :return: iperf argument with protocol
        """
        protocol = self.options.get('protocol')
        if protocol == 'udp':
            iperf_option = '-u '
        elif protocol == 'tcp':
            iperf_option = ''
        else:
            msg = 'Invalid value for "protocol" argument: {}. Allowed values: tcp , udp'.format(protocol)
            raise DataTransferArgumentError(msg)
        return iperf_option

    def _get_throughput(self):
        """
        Gets throughput for udp mode.

        :return: throughput value
        """
        if self.options['protocol'] == 'udp':
            return '-b {} '.format(self.options['throughput'])
        return ''

    def _get_buffer(self):
        """
        Gets buffer value.

        :return: buffer value
        """
        if 'buffer' in self.options:
            return '-w {} '.format(self.options['buffer'])
        return ''

    def _get_packet(self):
        """
        Gets packet value.

        :return: packet value
        """
        if 'packet' in self.options or 'packet_size' in self.options:
            return '-M {} '.format(self.options['packet'] or self.options['packet_size'])
        return ''

    def _get_parallel(self):
        """
        Gets parallel value.

        :return: packet value
        """
        if 'parallel' in self.options or 'parallel_streams' in self.options:
            return '-P {} '.format(self.options['parallel'] or self.options['parallel_streams'])
        return ''

    def _get_linux_congestion(self):
        """
        Gets linux congestion value.

        :return: linux congestion value
        """
        if 'linux_congestion' in self.options:
            return '-Z {} '.format(self.options['linux_congestion'])
        return ''

    def __str__(self):
        return self.value


if __name__ == '__main__':
    import unittest
    from parameterized import parameterized

    class TestIperfOutputParsing(unittest.TestCase):

        @parameterized.expand([
            # FOR FUTURE
            # [
            #     "udp_dl_ue_report",
            #     ""
            # ],
            # [
            #     "udp_ul_ue_report",
            #     ""
            # ],
            # [
            #     "tcp_dl_ue_report",
            #     ""
            # ],
            # [
            #     "tcp_ul_ue_report",
            #     ""
            # ],
            [
                "udp_dl_ue_pc_report",
                "[  3] 50.0-51.0 sec  24.9 MBytes   209 Mbits/sec   0.055 ms    0/17792 (0%)\n"
                "[  3] 51.0-52.0 sec  25.0 MBytes   210 Mbits/sec   0.055 ms    0/17856 (0%)\n"
                "[  3] 52.0-53.0 sec  25.0 MBytes   210 Mbits/sec   0.055 ms    0/17833 (0%)\n"
                "[  3] 53.0-54.0 sec  25.0 MBytes   210 Mbits/sec   0.055 ms    0/17833 (0%)\n"
                "[  3] 54.0-55.0 sec  25.0 MBytes   210 Mbits/sec   0.055 ms    0/17833 (0%)\n"
                "[  3] 55.0-56.0 sec  24.9 MBytes   209 Mbits/sec   0.055 ms    0/17797 (0%)\n"
                "[  3] 56.0-57.0 sec  25.1 MBytes   210 Mbits/sec   0.055 ms    0/17869 (0%)\n"
                "[  3] 57.0-58.0 sec  24.9 MBytes   209 Mbits/sec   0.055 ms    0/17797 (0%)\n"
                "[  3] 58.0-59.0 sec  25.1 MBytes   210 Mbits/sec   0.055 ms    0/17869 (0%)\n"
                "[  3] 59.0-60.0 sec  25.0 MBytes   210 Mbits/sec   0.055 ms    0/17833 (0%)\n"
                "[  3]  0.0-60.0 sec  1.46 GBytes   210 Mbits/sec   0.344 ms  141/1069976 (0.013%)\n"
                "[  3]  0.0-60.0 sec  141 datagrams received out-of-order",
                "udp"
            ],
            [
                "udp_ul_ue_pc_report",
                "[  3] 52.0-53.0 sec  11.9 MBytes   100 Mbits/sec   0.124 ms    4/ 8511 (0.047%)\n"
                "[  3] 52.00-53.00 sec  6001 datagrams received out-of-order\n"
                "[  3] 53.0-54.0 sec  12.0 MBytes   100 Mbits/sec   0.145 ms    0/ 8533 (0%)\n"
                "[  3] 53.00-54.00 sec  6068 datagrams received out-of-order\n"
                "[  3] 54.0-55.0 sec  12.0 MBytes   100 Mbits/sec   0.141 ms    0/ 8542 (0%)\n"
                "[  3] 54.00-55.00 sec  6029 datagrams received out-of-order\n"
                "[  3] 55.0-56.0 sec  11.9 MBytes   100 Mbits/sec   2.600 ms    3/ 8507 (0.035%)\n"
                "[  3] 55.00-56.00 sec  6101 datagrams received out-of-order\n"
                "[  3] 56.0-57.0 sec  12.1 MBytes   102 Mbits/sec   0.076 ms    0/ 8631 (0%)\n"
                "[  3] 56.00-57.00 sec  6107 datagrams received out-of-order\n"
                "[  3] 57.0-58.0 sec  12.0 MBytes   101 Mbits/sec   2.081 ms    0/ 8544 (0%)\n"
                "[  3] 57.00-58.00 sec  6104 datagrams received out-of-order\n"
                "[  3] 58.0-59.0 sec  12.0 MBytes   101 Mbits/sec   1.411 ms    0/ 8571 (0%)\n"
                "[  3] 58.00-59.00 sec  6043 datagrams received out-of-order\n"
                "[  3]  0.0-60.0 sec   717 MBytes   100 Mbits/sec   1.023 ms  959/512566 (0.19%)\n"
                "[  3] 0.00-59.99 sec  363251 datagrams received out-of-order\n",
                "udp"
            ],
            [
                "tcp_dl_ue_pc_report",
                "",
                "tcp"
            ],
            [
                "tcp_ul_ue_pc_report",
                "",
                "tcp"
            ],
        ])
        def test_parser(self, _, report, protocol):
            value = DataTransfer._get_average_throughput_from_server_report(report, protocol)
            self.assertTrue(self._is_number(value))

        @staticmethod
        def _is_number(value):
            try:
                float(value)
                return True
            except ValueError:
                return False

    unittest.main()
