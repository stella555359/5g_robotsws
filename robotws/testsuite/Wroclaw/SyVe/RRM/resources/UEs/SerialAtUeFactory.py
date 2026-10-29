"""
This resource is meant to be used with 5G modems that does not run Android or Linux and
use AT commands over serial port.
To use this resource you have to know on which COM port the modem is available (it can be modem port or
application port) and the baudrate it uses (if modem is connected by USB this does not matter, but it's safe to check
using PuTTY or other terminal if given baudrate works fine). Also, you need to have Serialcommand app on UE PC, added
to PATH. You can download it here:
https://confluence.ext.net.nokia.com/display/CV/SerialCommand+-+simple+AT+command+terminal
"""

from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import execute_ssh_command
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AdbUeBase import AdbUeBase
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AdbCommands import AT_CFUN_ATTACH, AT_CFUN_DETACH, AT_CFUN_GET
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AskeyAtAdbFactory import ADB_AT_CMD_SUCCESS, ADB_AT_CMD_ERROR, \
    ADB_AT_HANDLING_TIME
from time import sleep

AT_CGPADDR_IPADDRESS = "AT+CGPADDR"
GET_PID_IPERF = "ps aux | grep iperf | awk '{print $2}'"


class SerialAtUeFactory(AdbUeBase):
    def __init__(self, id_):
        super(SerialAtUeFactory, self).__init__(id_)
        self.name = f"UE_{id_}: Generic serial AT UE {self.ue_sn}"
        self.ue_pc_ssh = Env().UES[self.ute_id].ssh_connection_details
        self._serial_baudrate = None
        self._serial_port = None

    @property
    def serial_port(self):
        return self._serial_port

    @serial_port.setter
    def serial_port(self, port_name):
        if not port_name.startswith("COM"):
            raise ValueError("Invalid value - please enter proper COM port name, eg. COM21")
        self._serial_port = port_name

    @property
    def serial_baudrate(self):
        return self._serial_baudrate

    @serial_baudrate.setter
    def serial_baudrate(self, baudrate):
        if not baudrate.isnumeric():
            raise ValueError("Invalid value - please enter numeric value of baudrate")
        self._serial_baudrate = baudrate

    def attach(self):
        self._execute_at_command_via_ssh(AT_CFUN_ATTACH)
        self._wait_for_ue_ip_address()

    def detach(self):
        output = self._execute_at_command_via_ssh(AT_CGPADDR_IPADDRESS)
        if AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS in output:
            self.verify_ue_ip()
        elif "CFUN: 4" in self._execute_at_command_via_ssh(AT_CFUN_GET):
            Logger.info(f"{self.name} - Already detached")
            return
        self._execute_at_command_via_ssh(AT_CFUN_DETACH)
        self._wait_for_ue_ip_address_cleared()
        self.ue_ip = None

    def _execute_at_command_via_ssh(self, at_command):
        attempt_cmd_at = []
        command = f"serialcommand {self._serial_port} {self._serial_baudrate} {at_command}"
        for _ in range(3):
            output, errors = execute_ssh_command(self.ue_pc_ssh, command)
            if ADB_AT_CMD_SUCCESS in output:
                Logger.debug(f"Command '{command}' executed")
                return output
            elif ADB_AT_CMD_ERROR in output:
                attempt_cmd_at.append(ADB_AT_CMD_ERROR)
                Logger.debug(f"Retrying {command} command")
                Logger.debug(f"Output: \n {output},\nError: \n{errors}")
                sleep(ADB_AT_HANDLING_TIME)
            else:
                assert not errors, f"Execution of command failed: \n {command}"
        assert ADB_AT_CMD_ERROR in attempt_cmd_at[-1], \
            f"All execution of AT command failed: \n {command}, attempts {attempt_cmd_at}"

    def _wait_for_ue_ip_address(self, timeout=40, interval=3):
        while timeout > 0:
            output = self._execute_at_command_via_ssh(AT_CGPADDR_IPADDRESS)
            if AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS in output:
                Logger.info(f"{self.name} - IP {self.ue_ip} assigned (UE attached)")
                return
            sleep(interval)
            timeout -= interval
        assert False, f"{self.name} - Ue IP not assigned, UE not attached"

    def _wait_for_ue_ip_address_cleared(self, timeout=40, interval=3):
        while timeout > 0:
            output = self._execute_at_command_via_ssh(AT_CGPADDR_IPADDRESS)
            if AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS not in output:
                Logger.info(f"{self.name} - IP removed (UE detached)")
                return
            sleep(interval)
            timeout -= interval
        assert False, f"{self.name} - Ue IP still assigned. Ue not detached"

    def _execute_starting_command(self, cmd, end_point, data_name):
        ssh_cmd = f"(nohup {cmd} &); exit"
        Logger.debug(f"Start {end_point} CMD: {ssh_cmd}")
        execute_ssh_command(self.ue_pc_ssh, command=ssh_cmd)
        self._update_iperf_pid(end_point, data_name)

    def _start_ue_iperf_client(self, traffic_mb, duration, data_name, port, protocol="-u", **kwargs):
        Logger.info(f"traffic_mb {traffic_mb}   duration {duration}   data_name {data_name}  protocol {protocol}")
        log, err_log = self.get_log_names(end_point=self.ue_iperf_client, data_name=data_name)
        iperf_cmd = self.adb.get_iperf_client_command(protocol=protocol, connection=self.connection, duration=duration,
                                                      traffic_mb=traffic_mb, log=log, error_log=err_log,
                                                      port=port, **kwargs).split("shell")[1]
        self._execute_starting_command(cmd=iperf_cmd, end_point=self.ue_iperf_client, data_name=data_name)

    def _start_ue_iperf_server(self, protocol, data_name, port, **kwargs):
        log, err_log = self.get_log_names(end_point=self.ue_iperf_server, data_name=data_name)
        iperf_cmd = self.adb.get_iperf_server_command(protocol=protocol, port=port, log=log,
                                                      error_log=err_log, **kwargs).split("shell")[1]
        self._execute_starting_command(cmd=iperf_cmd, end_point=self.ue_iperf_server, data_name=data_name)

    def _get_new_iperf_pid(self):
        new_values = execute_ssh_command(self.ue_pc_ssh, command=GET_PID_IPERF)
        new_set_of_iperf_pid = set([value.strip("\r") for value in new_values.split("\n")])
        unique_pid = new_set_of_iperf_pid - self.known_pid_set
        self.known_pid_set.update(unique_pid)
        Logger.debug(f"Known iperf pid set is {self.known_pid_set}")
        return list(unique_pid)[0]

    def _stop_iperf_process_for_transmission(self, end_point, data_name):
        pid = self.ue_iperf_server_pid_dict.get(data_name) if end_point == self.ue_iperf_server else \
            self.ue_iperf_client_pid_dict.get(data_name)
        execute_ssh_command(self.ue_pc_ssh, command=f"kill -9 {pid}")
        self.known_pid_set.remove(pid)

    def _get_ue_ip(self):
        output = self._execute_at_command_via_ssh(AT_CGPADDR_IPADDRESS)
        assert AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS in output, \
            f"UE {self.name} has lost connection to the base station"
        return output.split('"')[1]
