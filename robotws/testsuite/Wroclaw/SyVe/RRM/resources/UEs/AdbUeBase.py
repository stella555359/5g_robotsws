from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.TputChecker import TputChecker
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs as Os
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.TimeStamp import TimeStamp
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import execute_ssh_command, download_file
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AdbCommands import AdbCommands
from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AppServer import AppServer
from time import sleep, time
import re

TIME_FOR_UE_AFTER_INVOKING_ROOT_PRIVILEGES = 10


class AdbUeBase(object):

    UE_IP_ADDRESS_FIRST_OCTETS = "192.168"
    AIRPLANE_MODE_SETTING_APPEAR_TIMEOUT = 3
    UE_GUI_DELAY_TIMEOUT = 1
    SERVER_CLIENT_TIMEOUT = 5

    def __init__(self, id_):
        self.id = id_
        self.ute_id = self.id - 1
        self.ue = Env.UES[self.ute_id]
        self.ue_sn = self.ue.serial_number
        self.name = "UE_{}: {}".format(self.id, self.ue_sn)
        self.connection = self._get_ue_connection_params()
        self.ue_pc_ssh = None
        self._ue_ip = None
        self.known_pid_set = set()
        self.ue_iperf_server_pid_dict = {}
        self.ue_iperf_client_pid_dict = {}
        self.ue_iperf_server = "SERVER"
        self.ue_iperf_client = "CLIENT"
        self.adb = AdbCommands(self.ue_sn, self.get_iperf_path())
        self.change_airplane_mode_sequence = [self.adb.key_event_go_up,
                                              self.adb.key_event_go_down,
                                              self.adb.key_event_tap_pad_center,
                                              self.adb.key_event_go_back]
        self.appserver = AppServer(self.ue)
        self.is_prepared = False
        self.ping_log_name = None
        self.err_ping_log_name = None
        self.time_for_ping_traffic = None
        self.transfer_end_times = {}
        self.ports = {}

    def restart_ue(self):
        Logger.info("{} - will be restarted".format(self.name))
        self._make_sure_ue_is_authorized()
        self._execute_adb_command(self.adb.reboot)
        self._wait_for_ue_is_rebooting()
        self.wait_for_ue_rebooted()
        self._restart_adbd_with_root_permissions()

    def wait_for_ue_rebooted(self):
        self.ue_pc_ssh = Env().UES[self.ute_id].ssh_connection_details
        timeout = 121
        interval = 5
        for attempt in range(0, timeout, interval):
            sleep(interval)
            connected_devices = self._execute_adb_command(self.adb.devices)
            if self.ue_sn in connected_devices:
                Logger.info("{} - restarted after {}s".format(self.ue_sn, attempt+interval))
                return
        assert False, "UE '{}' missing after {}".format(self.ue_sn, timeout)

    def prepare_ue(self):
        """
        Reads Env parameters and performs necessary setup for the UE
        :return: None
        """
        self._make_sure_ue_is_authorized()
        self._restart_adbd_with_root_permissions()
        Logger.info("{}".format(self.name))
        self.is_prepared = True

    def attach(self):
        Logger.info(f"{self.name} - attaching...")
        if AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS in self._execute_adb_command(self.adb.get_grep_inet_in_ip_cmd):
            Logger.warning(f"{self.name} - Already attached")
            return
        self._make_sure_screen_is_on()
        self._execute_adb_command(self.adb.disable_airplane_mode())
        sleep(AdbUeBase.UE_GUI_DELAY_TIMEOUT)
        if int(self._execute_adb_command(self.adb.get_data_mode_state())) == 0:
            Logger.info(f"{self.name} - Data mode was switched off, switching data mode on...")
            self._execute_adb_command(self.adb.enable_data_mode())
        self._wait_for_ue_ip_address(timeout=120, interval=5)

    def detach(self):
        if not self.is_prepared:
            Logger.warning("UE {} was not prepared, please check with adb is it on the devices list".format(self.name))
            return
        Logger.info("{} - detaching...".format(self.name))
        if AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS in self._execute_adb_command(self.adb.get_grep_inet_in_ip_cmd):
            self.verify_ue_ip()
        elif int(self._execute_adb_command(self.adb.get_airplane_mode_on)) == 1:
            Logger.info("{} - Already detached".format(self.name))
            return
        self._execute_adb_command(self.adb.enable_airplane_mode())
        sleep(AdbUeBase.UE_GUI_DELAY_TIMEOUT)
        self._wait_for_cleared_ue_ip_address()
        self.ue_ip = None
        self._make_sure_screen_is_off()

    def start_ul_udp_transmission(self, duration, traffic_mb, data_name, **kwargs):
        self.ports[data_name] = self.appserver.get_free_port()
        Logger.info(f"{self.name} - Starting '{data_name}' uplink UDP {traffic_mb}Mbits "
                    f"for {self._get_duration_unit(duration)}")
        self.appserver.start_server_udp_transmission(data_name=data_name, port=self.ports[data_name], **kwargs)
        sleep(AdbUeBase.SERVER_CLIENT_TIMEOUT)
        self._start_ue_iperf_client(traffic_mb=traffic_mb, duration=duration, protocol="-u", data_name=data_name,
                                    port=self.ports[data_name], **kwargs)
        self.transfer_end_times[data_name] = TimeStamp().unix_timestamp + self._get_duration_time(duration)
        assert self.is_traffic_started(data_name), f"Traffic on {self.ue_sn} didn't started."

    def start_dl_udp_transmission(self, duration, traffic_mb, data_name, **kwargs):
        self.ports[data_name] = self.appserver.get_free_port()
        Logger.info(f"{self.name} - Starting '{data_name}' downlink UDP {traffic_mb}Mbits "
                    f"for {self._get_duration_unit(duration)}")
        self._start_ue_iperf_server(protocol="-u", data_name=data_name, port=self.ports[data_name], **kwargs)
        sleep(AdbUeBase.SERVER_CLIENT_TIMEOUT)
        self.appserver.start_client_udp_transmission(ue_ip=self.ue_ip, duration=duration, traffic_mb=traffic_mb,
                                                     port=self.ports[data_name], data_name=data_name, **kwargs)
        self.transfer_end_times[data_name] = TimeStamp().unix_timestamp + self._get_duration_time(duration)
        assert self.is_traffic_started(data_name), f"Traffic on {self.ue_sn} didn't started."

    def start_ul_tcp_transmission(self, duration, traffic_mb, data_name, **kwargs):
        self.ports[data_name] = self.appserver.get_free_port()
        Logger.info(f"{self.name} - Starting '{data_name}' uplink TCP {traffic_mb}Mbits "
                    f"for {self._get_duration_unit(duration)}")
        self.appserver.start_server_tcp_transmission(data_name=data_name, port=self.ports[data_name], **kwargs)
        sleep(AdbUeBase.SERVER_CLIENT_TIMEOUT)
        self._start_ue_iperf_client(traffic_mb=traffic_mb, duration=duration, protocol="", data_name=data_name,
                                    port=self.ports[data_name], **kwargs)
        self.transfer_end_times[data_name] = TimeStamp().unix_timestamp + self._get_duration_time(duration)
        assert self.is_traffic_started(data_name), f"Traffic on {self.ue_sn} didn't started."

    def start_dl_tcp_transmission(self, duration, traffic_mb, data_name, **kwargs):
        self.ports[data_name] = self.appserver.get_free_port()
        Logger.info(f"{self.name} - Starting '{data_name}' downlink TCP {traffic_mb}Mbits "
                    f"for {self._get_duration_unit(duration)}")
        self._start_ue_iperf_server(protocol="", data_name=data_name, port=self.ports[data_name], **kwargs)
        sleep(AdbUeBase.SERVER_CLIENT_TIMEOUT)
        self.appserver.start_client_tcp_transmission(ue_ip=self.ue_ip, duration=duration, traffic_mb=traffic_mb,
                                                     data_name=data_name, port=self.ports[data_name], **kwargs)
        self.transfer_end_times[data_name] = TimeStamp().unix_timestamp + self._get_duration_time(duration)
        assert self.is_traffic_started(data_name), f"Traffic on UE: {self.ue_sn} didn't started."

    def is_traffic_started(self, data_name, timeout=30):
        start_time = time()
        interval = 2
        get_traffic_file_content_cmd = f"cat LOG*{self.ue_sn}*{data_name}*"
        while start_time + timeout > time():
            output, error = execute_ssh_command(self.ue_pc_ssh, command=get_traffic_file_content_cmd)
            if "Mbits" in output:
                Logger.info(f"Throughput started on UE: {self.ue_sn}")
                return True
            Logger.debug(f"Traffic for UE: {self.ue_sn} not started for {int(time() - start_time)} seconds")
            sleep(interval)
        return False

    def generate_traffic_via_ping_from_ue(self, ping_name="PING", time_for_ping=60):
        self.time_for_ping_traffic = time_for_ping
        self.ping_log_name, self.err_ping_log_name = self.get_log_names(end_point="PING_FROM_UE", data_name=ping_name)
        self._ping_appserver()

    def stop_ping_and_check_results(self, lost_ping_percent=20):
        self._download_files_ping_results()
        self._remove_ping_log_ue_pc()
        return self._get_ping_log_summary(lost_ping_percent)

    def stop_ul_transmission(self, data_name):
        if self.transfer_end_times.get(data_name):
            self._stop_transmission(end_point=self.ue_iperf_client, data_name=data_name)
            del self.transfer_end_times[data_name]

    def stop_dl_transmission(self, data_name):
        if self.transfer_end_times.get(data_name):
            self._stop_transmission(end_point=self.ue_iperf_server, data_name=data_name)
            del self.transfer_end_times[data_name]

    def get_average_throughput(self, data_name, **kwargs):
        analyze_entries = kwargs['analyze_entries']
        self._download_files_matching_pattern("LOG*{}*{}*".format(self.ue_sn, data_name))
        self.appserver.download_files_by_pattern("LOG*{}*{}".format(self.ue_sn, data_name))
        return TputChecker().get_average_throughput(self._get_proper_log_file_path(data_name), analyze_entries)

    def get_maximum_throughput(self, data_name, **kwargs):
        analyze_entries = kwargs['analyze_entries']
        self._download_files_matching_pattern("LOG*{}*{}*".format(self.ue_sn, data_name))
        self.appserver.download_files_by_pattern("LOG*{}*{}".format(self.ue_sn, data_name))
        return TputChecker().get_maximum_throughput(self._get_proper_log_file_path(data_name), analyze_entries)

    def get_all_throughput_values(self, data_name, **kwargs):
        analyze_entries = kwargs['analyze_entries']
        self._download_files_matching_pattern("LOG*{}*{}*".format(self.ue_sn, data_name))
        self.appserver.download_files_by_pattern("LOG*{}*{}".format(self.ue_sn, data_name))
        return TputChecker().get_all_throughputs(self._get_proper_log_file_path(data_name), analyze_entries)

    def wait_for_data_transfer_end(self, data_name):
        TimeStamp.wait_for_the_unix_timestamp(self.transfer_end_times[data_name])
        Logger.info(f"Data transfer {data_name} has just ended")

    def try_to_get_and_remove_traffic_log_files(self):
        self._download_and_remove_traffic_files_for_the_endpoint(self.ue_iperf_server)
        self._download_and_remove_traffic_files_for_the_endpoint(self.ue_iperf_client)
        self.appserver.clean_the_appserver_environment()

    @property
    def ue_ip(self):
        if not self._ue_ip:
            self._ue_ip = self._get_ue_ip()
        return self._ue_ip

    @ue_ip.setter
    def ue_ip(self, new_ue_ip):
        self._ue_ip = new_ue_ip

    def verify_ue_ip(self):
        if not self._is_ue_ip_the_same():
            Logger.warning(f"{self.name} - IP changed since last time to {self.ue_ip}."
                           f" It means ue reattached or changed cell.")

    def get_log_names(self, end_point, data_name):
        time = TimeStamp().file_timestamp
        log = "LOG_{}_{}_UE_{}_{}.txt".format(self.ue_sn, end_point, data_name, time)
        err_log = "ERR_{}_{}_UE_{}_{}.txt".format(self.ue_sn, end_point, data_name, time)
        return log, err_log

    def make_phone_call(self, phone_number):
        Logger.info("{} - Calling: {}".format(self.name, phone_number))
        self._execute_adb_command(self.adb.make_phone_call(phone_number))

    def get_phone_call_status(self):
        return self._execute_adb_command(self.adb.get_phone_call_status())

    def hang_up_phone_call(self):
        Logger.info("{} - Hanging up the phone call".format(self.name))
        self._execute_adb_command(self.adb.hang_up_phone_call())

    def get_pci(self):
        return re.match(r'.*mPci\s?=\s?(\d+)', self._execute_adb_command(self.adb.get_service_state())).group(1)

    def get_mnci_cell_id(self):
        return re.match(r'.*mNci\s=\s(\d+)', self._execute_adb_command(self.adb.get_cell_info())).group(1)

    def get_band(self):
        return re.match(r'.*mBands\s?=\s?\[(\d+)\]', self._execute_adb_command(self.adb.get_service_state())).group(1)

    def get_tac(self):
        return re.match(r'.*mTac\s?=\s?(\d+)', self._execute_adb_command(self.adb.get_service_state())).group(1)

    def get_nrarfcn(self):
        return re.match(r'.*mNrArfcn\s=\s(\d+)', self._execute_adb_command(self.adb.get_service_state())).group(1)

    def get_plmn(self):
        return re.match(r'.*rRplmn=(\d+)', self._execute_adb_command(self.adb.get_service_state())).group(1)

    def get_rat(self):
        return re.match(r'.*getRilDataRadioTechnology=\d+\((.*)\)', self._execute_adb_command(
            self.adb.get_service_state())).group(1)

    def get_rsrp(self):
        return re.match(r'.*ssRsrp|.*rsrp\s?=\s?(-\d+)', self._execute_adb_command(self.adb.get_cell_info())).group(1)

    def get_rsrq(self):
        return re.match(r'.*ssRsrq|.*rsrq\s?=\s?(-\d+)', self._execute_adb_command(self.adb.get_cell_info())).group(1)

    def get_sinr(self):
        return re.match(r'.*ssSinr|.*rssnr\s?=\s?(\d+)', self._execute_adb_command(self.adb.get_cell_info())).group(1)

    def _restart_adbd_with_root_permissions(self):
        Logger.info("Restarting adb daemon on {} UE".format(self.name))
        self._execute_adb_command(self.adb.restart_adbd_with_root_permissions)
        sleep(TIME_FOR_UE_AFTER_INVOKING_ROOT_PRIVILEGES)

    def get_iperf_path(self):
        try:
            iperf_path = self.ue.iperf_details.iperf_path
        except AttributeError:
            iperf_path = self.ue.data_transfer.binary_path
        return iperf_path

    @staticmethod
    def _get_duration_unit(duration):
        return f"{duration}s" if str(duration).isdigit() else \
            f"{duration}Bytes of data" if str(duration).isupper() else f"{str(duration).upper()}bits of data"

    @staticmethod
    def _get_duration_time(duration):
        return duration if str(duration).isdigit() else 0

    def _download_and_remove_traffic_files_for_the_endpoint(self, endpoint):
        endpoint_files = "*{}_{}*".format(self.ue_sn, endpoint)
        self._download_files_matching_pattern(endpoint_files)
        self._try_to_remove_files_with_pattern_on_iperf(endpoint_files)

    def _make_sure_ue_is_authorized(self):
        self.ue_pc_ssh = Env().UES[self.ute_id].ssh_connection_details
        connected_devices = self._execute_adb_command(self.adb.devices)
        assert self.ue_sn in connected_devices, \
            "UE {} not found!!!\n{}".format(self.ue_sn, connected_devices)
        if "unauthorized" in connected_devices:
            self._execute_adb_command(self.adb.kill_server)
        self._execute_adb_command(self.adb.kill_all_iperf)

    def _wait_for_ue_is_rebooting(self):
        timeout = 20
        interval = 1
        for attempt in range(0, timeout, interval):
            sleep(interval)
            connected_devices = self._execute_adb_command(self.adb.devices)
            if self.ue_sn not in connected_devices:
                Logger.info("{} - rebooting...".format(self.ue_sn))
                return
        assert False, "UE '{}' is not rebooting after {}".format(self.ue_sn, timeout)

    def _start_ue_iperf_client(self, traffic_mb, duration, protocol, data_name, port, **kwargs):
        log, err_log = self.get_log_names(end_point=self.ue_iperf_client, data_name=data_name)
        adb_cmd = self.adb.get_iperf_client_command(protocol=protocol, connection=self.connection, duration=duration,
                                                    traffic_mb=traffic_mb, log=log, error_log=err_log,
                                                    port=port, **kwargs)
        self._execute_starting_adb_command(adb_cmd=adb_cmd, end_point=self.ue_iperf_client, data_name=data_name)

    def _start_ue_iperf_server(self, protocol, data_name, port, **kwargs):
        log, err_log = self.get_log_names(end_point=self.ue_iperf_server, data_name=data_name)
        adb_cmd = self.adb.get_iperf_server_command(protocol=protocol, port=port, log=log, error_log=err_log,
                                                    **kwargs)
        self._execute_starting_adb_command(adb_cmd=adb_cmd, end_point=self.ue_iperf_server, data_name=data_name)

    def _stop_transmission(self, end_point, data_name):
        Logger.info("Stopping {} iperf transmission".format(data_name))
        self._stop_iperf_process_for_transmission(end_point=end_point, data_name=data_name)
        self._download_and_clear_logs(end_point=end_point, data_name=data_name)
        self.appserver.stop_transmission(data_name, self.ports[data_name], ue_end_point=end_point)

    def _stop_iperf_process_for_transmission(self, end_point, data_name):
        pid = self.ue_iperf_server_pid_dict.get(data_name) if end_point == self.ue_iperf_server else \
            self.ue_iperf_client_pid_dict.get(data_name)
        if pid:
            self._execute_adb_command(self.adb.kill_iperf_pid.format(pid=int(pid)))
            self.known_pid_set.remove(pid)
        else:
            Logger.warning(f"{self.name} - There is no traffic to stop on UE!")

    def _execute_starting_adb_command(self, adb_cmd, end_point, data_name):
        cmd = "(nohup {} &); exit".format(adb_cmd)
        Logger.debug("Start {} CMD: {}".format(end_point, cmd))
        self._execute_adb_command(cmd)
        self._update_iperf_pid(end_point, data_name)

    def _update_iperf_pid(self, end_point, data_name):
        new_pid = self._get_new_iperf_pid()
        self._save_pid_to_proper_end_point_and_traffic_name(new_pid, end_point, data_name)

    def _get_new_iperf_pid(self):
        new_values = self._execute_adb_command(self.adb.pgrep_iperf)
        new_set_of_iperf_pid = set([value.strip("\r") for value in new_values.split("\n")])
        unique_pid = new_set_of_iperf_pid - self.known_pid_set
        self.known_pid_set.update(unique_pid)
        Logger.debug("Known iperf pid set is {}".format(self.known_pid_set))
        try:
            return list(unique_pid)[0]
        except IndexError:
            assert False, f"New unique IPERF pid was not found! " \
                          f"Latest iperf PIDs based on ADB are:\n {self._execute_adb_command(self.adb.pgrep_iperf)}"

    def _save_pid_to_proper_end_point_and_traffic_name(self, new_pid, end_point, data_name):
        if end_point == self.ue_iperf_server:
            self.ue_iperf_server_pid_dict[data_name] = new_pid
            Logger.debug("PID dict for data name '{}' is {}".format(data_name, self.ue_iperf_server_pid_dict))
        else:
            self.ue_iperf_client_pid_dict[data_name] = new_pid
            Logger.debug("PID dict for data name '{}' is {}".format(data_name, self.ue_iperf_client_pid_dict))

    def _get_proper_log_file_path(self, data_name):
        for log_name in Os.get_time_sorted_files_from_youngest_with_names_starting_with(Env().test_log_dir, "LOG"):
            if self.ue_iperf_server in log_name and data_name in log_name:
                return Os.join_path_elements(Env().test_log_dir, log_name)

    def _download_and_clear_logs(self, end_point, data_name):
        log_files_pattern = "*{}_{}_UE_{}*".format(self.ue_sn, end_point, data_name)
        self._download_files_matching_pattern(log_files_pattern)
        self._try_to_remove_files_with_pattern_on_iperf(log_files_pattern)

    def _download_files_matching_pattern(self, pattern):
        files, _ = execute_ssh_command(self.ue_pc_ssh, "ls -1 {}".format(pattern))
        if files.strip():
            for file_ in files.splitlines():
                Logger.debug("downloading from UE PC {}".format(file_))
                download_file(self.ue_pc_ssh, file_, Os.join_path_elements(Env().test_log_dir, file_))

    def _try_to_remove_files_with_pattern_on_iperf(self, pattern):
        execute_ssh_command(self.ue_pc_ssh, "rm -f {}".format(pattern))

    def _execute_adb_command(self, command):
        output, error = execute_ssh_command(self.ue_pc_ssh, command=command)
        Logger.debug("Executed ADB command: {} with:\noutput=({})\nerrors=({})".format(command, output, error))
        assert "device unauthorized" not in error, \
            "Device {} is ADB unauthorized and will not perform any action".format(self.ue_sn)
        return output

    def _make_sure_screen_is_on(self):
        if "OFF" in self._execute_adb_command(self.adb.get_screen_state):
            Logger.debug("{} - the screen was in the state OFF, waking it up".format(self.name))
            self._execute_adb_command(self.adb.key_event_wake_up + "&&" + self.adb.swipe_up)

    def _make_sure_screen_is_off(self):
        if "ON" in self._execute_adb_command(self.adb.get_screen_state):
            Logger.debug("{} - the screen was in the state ON, going to sleep".format(self.name))
            self._execute_adb_command(self.adb.key_event_sleep)

    def _change_airplane_mode(self):
        self._make_sure_screen_is_on()
        self._execute_adb_command(self.adb.key_event_home_button)
        self._execute_adb_command(self.adb.invoke_airplane_settings)
        sleep(AdbUeBase.AIRPLANE_MODE_SETTING_APPEAR_TIMEOUT)
        for action in self.change_airplane_mode_sequence:
            sleep(AdbUeBase.UE_GUI_DELAY_TIMEOUT)
            self._execute_adb_command(action)

    def _wait_for_ue_ip_address(self, timeout=20, interval=1):
        while timeout > 0:
            output = self._execute_adb_command(self.adb.get_grep_inet_in_ip_cmd)
            if AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS in output:
                Logger.info(f"{self.name} - IP assigned (UE attached) with address: {self.ue_ip}")
                assert int(self._execute_adb_command(self.adb.get_airplane_mode_on)) == 0, \
                    "{} - Airplane mode not switched off".format(self.name)
                return
            sleep(interval)
            timeout -= interval
        assert False, "{} - Ue IP not assigned, UE not attached".format(self.name)

    def _wait_for_cleared_ue_ip_address(self, timeout=20, interval=1):
        while timeout > 0:
            output = self._execute_adb_command(self.adb.get_grep_inet_in_ip_cmd)
            if AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS not in output:
                Logger.info("{} - IP removed (UE detached)".format(self.name))
                assert int(self._execute_adb_command(self.adb.get_airplane_mode_on)) == 1, \
                    "{} - Airplane mode not switched on".format(self.name)
                return
            sleep(interval)
            timeout -= interval
        assert False, "{} - Ue IP still assigned. Ue not detached".format(self.name)

    def _get_ue_ip(self):
        output = self._execute_adb_command(self.adb.get_grep_inet_in_ip_cmd)
        ue_ips = [ip.split("/")[0] for ip in output.split() if ip.startswith(AdbUeBase.UE_IP_ADDRESS_FIRST_OCTETS)]
        assert ue_ips, \
            "UE {} has lost connection to the base station".format(self.name)
        Logger.info("{} - IP address: {}".format(self.name, ue_ips[0]))
        return ue_ips[0]

    def _is_ue_ip_the_same(self):
        current_ip = self._get_ue_ip()
        if current_ip == self.ue_ip:
            return True
        self.ue_ip = current_ip
        return False

    def _ping_appserver(self):
        ping_appserver = f"(nohup adb -s {self.ue_sn} shell ping -c {self.time_for_ping_traffic} -i 1 " \
                         f"{self.connection} 1> {self.ping_log_name} 2>{self.err_ping_log_name} &); exit"
        execute_ssh_command(self.ue_pc_ssh, ping_appserver)
        Logger.info(f"Ping traffic is started from ue to appserver, time for traffic: {self.time_for_ping_traffic}s")

    def _download_files_ping_results(self):
        time_for_output_save = 3
        for _ in range(3):
            if "packets transmitted" not in execute_ssh_command(self.ue_pc_ssh, f"cat {self.ping_log_name}"):
                Logger.debug(f"Wait for logs save complete {time_for_output_save}s")
                sleep(time_for_output_save)
            break
        download_file(self.ue_pc_ssh, self.ping_log_name, Os.join_path_elements(Env().test_log_dir, self.ping_log_name))
        download_file(self.ue_pc_ssh, self.err_ping_log_name, Os.join_path_elements(Env().test_log_dir,
                                                                                    self.err_ping_log_name))

    def _get_ping_log_summary(self, lost_ping_percent):
        with open(Os.join_path_elements(Env().test_log_dir, self.ping_log_name), "r") as ping_file:
            ping_file_all_file = ping_file.read()
            if f"{self.time_for_ping_traffic} packets transmitted" in ping_file_all_file:
                ping_received = re.findall(r'\d+ received', ping_file_all_file)[0]
                percent_lost = lost_ping_percent * (self.time_for_ping_traffic/100)
                Logger.debug(f"Ping status {ping_received}")
                if int(ping_received.split()[0]) < int(self.time_for_ping_traffic - percent_lost):
                    Logger.warning(f"Ping lost package to high ping received: {ping_received}, expected percent lost:"
                                   f" {percent_lost} from {self.time_for_ping_traffic}")
            else:
                Logger.warning(f"Output is empty or some logs are missing. Please check the logs")
            ping_log_summary = re.findall(r'\d+ packets.+', ping_file_all_file)
            Logger.info(f"Ping log summary: {ping_log_summary}")
            return ping_log_summary

    def _remove_ping_log_ue_pc(self):
        remove_ping_logs = f"rm -f {self.ping_log_name} {self.err_ping_log_name}"
        out, err = execute_ssh_command(self.ue_pc_ssh, remove_ping_logs)
        Logger.debug(f"Remove ping log files: {self.ping_log_name} {self.err_ping_log_name} with:"
                     f"\noutput=({out})\nerrors=({err})")

    def _get_ue_connection_params(self):
        try:
            connection = self.ue.iperf_details.network_interface_address
        except AttributeError:
            connection = self.ue.data_transfer.app_server.bind_interface_ip
        return connection
