import re

from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AdbUeBase import AdbUeBase
from testsuite.Wroclaw.SyVe.RRM.resources.TimeStamp import TimeStamp
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs as Os
from time import sleep
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.TputChecker import TputChecker

ADB_AT_CMD_SUCCESS = "OK"
ADB_AT_CMD_ERROR = "ERROR"
ADB_AT_CMD_FAILURE_MSG = "AT command '{}' not successful via ADB\n{}"
ADB_AT_HANDLING_TIME = 5


class AskeyAtAdbFactory(AdbUeBase):

    def __init__(self, id_):
        super(AskeyAtAdbFactory, self).__init__(id_)
        self.name = "UE_{}: Askey {}".format(self.id, self.ue_sn)

    def attach(self):
        Logger.info("{} - attaching...".format(self.name))
        self._execute_at_command_via_adb(self.adb.at_cmd_cfun_attach)
        workaround_pause_between_commands = 3
        sleep(workaround_pause_between_commands)
        self._execute_at_command_via_adb(self.adb.at_cmd_cops_attach)
        self._wait_for_ue_ip_address(timeout=30, interval=3)

    def detach(self):
        if not self.is_prepared:
            Logger.warning("UE {} was not prepared, please check with adb is it on the devices list".format(self.name))
            return
        if AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS in self._execute_adb_command(self.adb.at_cmd_get_cgpaddr):
            self.verify_ue_ip()
        elif "CFUN: 4" in self._execute_adb_command(self.adb.at_cmd_get_cfun):
            Logger.info("{} - Already detached".format(self.name))
            return
        Logger.info("{} - detaching...".format(self.name))
        self._execute_at_command_via_adb(self.adb.at_cmd_cops_detach)
        self._execute_at_command_via_adb(self.adb.at_cmd_cfun_detach)
        self.ue_ip = None

    def start_dl_udp_transmission(self, duration, traffic_mb, data_name, **kwargs):
        self.ports[data_name] = self.appserver.get_free_port()
        Logger.info("{} - Starting '{}'  downlink UDP {}Mbits for {}s".format(self.name, data_name,
                                                                              traffic_mb, duration))
        self.appserver.start_server_tcp_transmission(data_name=data_name, port=self.ports[data_name],
                                                     report_interval=1)  # iperf3 must start with tcp for udp
        sleep(AdbUeBase.SERVER_CLIENT_TIMEOUT)
        self._start_ue_iperf_client(traffic_mb=traffic_mb, duration=duration, protocol="-u", data_name=data_name,
                                    port=self.ports[data_name], reverse_mode=True, **kwargs)
        self.transfer_end_times[data_name] = TimeStamp().unix_timestamp + (duration if str(duration).isdigit() else 0)
        assert self.is_traffic_started(data_name), f"Traffic on {self.ue_sn} didn't started."

    def start_ul_udp_transmission(self, duration, traffic_mb, data_name, **kwargs):
        self.ports[data_name] = self.appserver.get_free_port()
        Logger.info("{} - Starting '{}' uplink UDP {}Mbits for {}s".format(self.name, data_name, traffic_mb, duration))
        self.appserver.start_server_tcp_transmission(data_name=data_name, port=self.ports[data_name],
                                                     report_interval=1)  # iperf3 must start with tcp for udp
        sleep(AdbUeBase.SERVER_CLIENT_TIMEOUT)
        self._start_ue_iperf_client(traffic_mb=traffic_mb, duration=duration, protocol="-u", data_name=data_name,
                                    port=self.ports[data_name], **kwargs)
        self.transfer_end_times[data_name] = TimeStamp().unix_timestamp + duration
        assert self.is_traffic_started(data_name), f"Traffic on {self.ue_sn} didn't started."

    def start_dl_tcp_transmission(self, duration, traffic_mb, data_name, **kwargs):
        self.ports[data_name] = self.appserver.get_free_port()
        Logger.info("{} - Starting '{}' downlink TCP {}Mbits for {}s".format(self.name, data_name,
                                                                             traffic_mb, duration))
        self.appserver.start_server_tcp_transmission(data_name=data_name, report_interval=1,
                                                     port=self.ports[data_name])
        sleep(AdbUeBase.SERVER_CLIENT_TIMEOUT)
        self._start_ue_iperf_client(traffic_mb=traffic_mb, duration=duration, protocol="", data_name=data_name,
                                    port=self.ports[data_name], reverse_mode=True, **kwargs)
        self.transfer_end_times[data_name] = TimeStamp().unix_timestamp + (duration if str(duration).isdigit() else 0)
        assert self.is_traffic_started(data_name), f"Traffic on {self.ue_sn} didn't started."

    def stop_dl_transmission(self, data_name):
        self._stop_transmission(end_point=self.ue_iperf_client, data_name=data_name)
        del self.transfer_end_times[data_name]

    def get_average_throughput(self, data_name, **kwargs):
        analyze_entries = kwargs['analyze_entries']
        self._download_files_matching_pattern("LOG*{}*".format(data_name))
        self.appserver.download_files_by_pattern("LOG*{}".format(data_name))
        return TputChecker().get_average_throughput(self._get_proper_log_file_path(
            data_name, kwargs.get('client_log_check')), analyze_entries)

    def _get_proper_log_file_path(self, data_name, client_log_check=True):
        client_or_server = self.ue_iperf_client if client_log_check else self.ue_iperf_server
        for log_name in Os.get_time_sorted_files_from_youngest_with_names_starting_with(Env().test_log_dir, "LOG"):
            if client_or_server in log_name and data_name in log_name:
                return Os.join_path_elements(Env().test_log_dir, log_name)

    def _execute_at_command_via_adb(self, command):
        for _ in range(3):
            output = self._execute_adb_command(command)
            assert ADB_AT_CMD_ERROR not in output, ADB_AT_CMD_FAILURE_MSG.format(command, output)
            if ADB_AT_CMD_SUCCESS in output:
                Logger.debug("Command '{}' executed".format(command))
                break
            sleep(ADB_AT_HANDLING_TIME)
            Logger.debug("Retrying {} command".format(command))

    def _wait_for_ue_ip_address(self, timeout=20, interval=1):
        while timeout > 0:
            output = self._execute_adb_command(self.adb.at_cmd_get_cgpaddr)
            if AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS in output:
                Logger.info("{} - IP {} assigned (UE attached)".format(self.name, self.ue_ip))
                return
            sleep(interval)
            timeout -= interval
        assert False, "{} - Ue IP not assigned, UE not attached".format(self.name)

    def _get_ue_ip(self):
        output = self._execute_adb_command(self.adb.at_cmd_get_cgpaddr)
        ue_ips = re.search(r'({}\.\d+\.\d+)'.format(AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS), output)
        assert ue_ips, \
            "UE {} has lost connection to the base station".format(self.name)
        Logger.info("{} - IP address: {}".format(self.name, ue_ips.group(0)))
        return ue_ips.group(0)
