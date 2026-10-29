"""
author/contact:   krzysztof.1.wrobel@nokia.com, I_MN_RAN_PZ1_WRO_7_SG_GMS <I_MN_RAN_PZ1_WRO_7_SG@internal.nsn.com>
Description:      functions to tracking params in csv
"""
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import execute_ssh_command
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AdbUeBase import AdbUeBase
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AdbCommands import AT_CFUN_ATTACH, AT_CFUN_DETACH, AT_CFUN_GET
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AskeyAtAdbFactory import ADB_AT_CMD_SUCCESS, ADB_AT_CMD_ERROR, \
    ADB_AT_HANDLING_TIME
from time import sleep

SMAWAVE_CMD_AT = "ssh -o StrictHostKeyChecking=no root@{ip} atcmd /dev/ttyUSB1 115200 {at}"
SMAWAVE_CMD_BASH = "ssh root@{ip} {shell_cmd}"
AT_CGPADDR_IPADDRESS = "AT+CGPADDR"
GET_PID_SMAWAVE = "pgrep iperf"
KILL_IPERF = "kill -9 {pid}"


class SmWaveAtFactory(AdbUeBase):

    def __init__(self, id_):
        super(SmWaveAtFactory, self).__init__(id_)
        self.name = "UE_{}: SmaWave {}".format(id_, self.ue_sn)
        self.ue_pc_ssh = Env().UES[self.ute_id].ssh_connection_details
        self.smawave_ip = self.ue_sn.split("_")[-1]

    def attach(self):
        self._execute_at_command_via_ssh(SMAWAVE_CMD_AT.format(ip=self.smawave_ip, at=AT_CFUN_ATTACH))
        self._wait_for_ue_ip_address()

    def detach(self):
        output = self._execute_at_command_via_ssh(SMAWAVE_CMD_AT.format(ip=self.smawave_ip, at=AT_CGPADDR_IPADDRESS))
        if AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS in output:
            self.verify_ue_ip()
        elif "CFUN: 4" in self._execute_at_command_via_ssh(SMAWAVE_CMD_AT.format(ip=self.smawave_ip, at=AT_CFUN_GET)):
            Logger.info("{} - Already detached".format(self.name))
            return
        self._execute_at_command_via_ssh(SMAWAVE_CMD_AT.format(ip=self.smawave_ip, at=AT_CFUN_DETACH))
        self._wait_for_ue_ip_address_cleared()
        self.ue_ip = None

    def _execute_at_command_via_ssh(self, command):
        attempt_cmd_at = []
        for _ in range(3):
            output, errors = execute_ssh_command(self.ue_pc_ssh, command)
            if ADB_AT_CMD_SUCCESS in output:
                Logger.debug("Command '{}' executed".format(command))
                return output
            elif ADB_AT_CMD_ERROR in output:
                attempt_cmd_at.append(ADB_AT_CMD_ERROR)
                Logger.debug("Retrying {} command".format(command))
                Logger.debug("Output: \n {},\nError: \n{}").format(output, errors)
                sleep(ADB_AT_HANDLING_TIME)
            else:
                assert not errors, "Execution of command failed: \n {}".format(command)
        assert ADB_AT_CMD_ERROR in attempt_cmd_at[-1], \
            "All execution of AT command failed: \n {}, attempts {}".format(command, attempt_cmd_at)

    def _wait_for_ue_ip_address(self, timeout=40, interval=3):
        while timeout > 0:
            output = self._execute_at_command_via_ssh(SMAWAVE_CMD_AT.format(ip=self.smawave_ip,
                                                                            at=AT_CGPADDR_IPADDRESS))
            if AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS in output:
                Logger.info("{} - IP {} assigned (UE attached)".format(self.name, self.ue_ip))
                return
            sleep(interval)
            timeout -= interval
        assert False, "{} - Ue IP not assigned, UE not attached".format(self.name)

    def _wait_for_ue_ip_address_cleared(self, timeout=40, interval=3):
        while timeout > 0:
            output = self._execute_at_command_via_ssh(SMAWAVE_CMD_AT.format(ip=self.smawave_ip,
                                                                            at=AT_CGPADDR_IPADDRESS))
            if AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS not in output:
                Logger.info("{} - IP removed (UE detached)".format(self.name))
                return
            sleep(interval)
            timeout -= interval
        assert False, "{} - Ue IP still assigned. Ue not detached".format(self.name)

    def _start_ue_iperf_client(self, traffic_mb, duration, data_name, port, protocol="-u", **kwargs):
        Logger.info("traffic_mb {}   duration {}   data_name {}".format(traffic_mb, duration, data_name, protocol))
        log, err_log = self.get_log_names(end_point=self.ue_iperf_client, data_name=data_name)
        adb_cmd = self.adb.get_iperf_client_command(protocol=protocol, connection=self.connection, duration=duration,
                                                    traffic_mb=traffic_mb, log=log, error_log=err_log,
                                                    port=port, **kwargs).split("shell")[1]
        self._execute_starting_adb_command(adb_cmd=format(SMAWAVE_CMD_BASH.format(ip=self.smawave_ip,
                                                                                  shell_cmd=adb_cmd)),
                                           end_point=self.ue_iperf_client, data_name=data_name)

    def _start_ue_iperf_server(self, protocol, data_name, port, **kwargs):
        log, err_log = self.get_log_names(end_point=self.ue_iperf_server, data_name=data_name)
        adb_cmd = self.adb.get_iperf_server_command(protocol=protocol, port=port, log=log,
                                                    error_log=err_log, **kwargs).split("shell")[1]
        self._execute_starting_adb_command(adb_cmd=format(SMAWAVE_CMD_BASH.format(ip=self.smawave_ip,
                                                                                  shell_cmd=adb_cmd)),
                                           end_point=self.ue_iperf_server, data_name=data_name)

    def _get_new_iperf_pid(self):
        new_values = self._execute_adb_command(SMAWAVE_CMD_BASH.format(ip=self.smawave_ip, shell_cmd=GET_PID_SMAWAVE))
        new_set_of_iperf_pid = set([value.strip("\r") for value in new_values.split("\n")])
        unique_pid = new_set_of_iperf_pid - self.known_pid_set
        self.known_pid_set.update(unique_pid)
        Logger.debug("Known iperf pid set is {}".format(self.known_pid_set))
        return list(unique_pid)[0]

    def _stop_iperf_process_for_transmission(self, end_point, data_name):
        pid = self.ue_iperf_server_pid_dict.get(data_name) if end_point == self.ue_iperf_server else \
            self.ue_iperf_client_pid_dict.get(data_name)
        self._execute_adb_command(SMAWAVE_CMD_BASH.format(ip=self.smawave_ip,
                                                          shell_cmd=KILL_IPERF.format(pid=int(pid))))
        self.known_pid_set.remove(pid)

    def _get_ue_ip(self):
        output = self._execute_at_command_via_ssh(SMAWAVE_CMD_AT.format(ip=self.smawave_ip,
                                                                        at=AT_CGPADDR_IPADDRESS))
        assert AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS in output, \
            "UE {} has lost connection to the base station".format(self.name)
        return output.split('"')[1]
