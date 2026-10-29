from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs as Os
from testsuite.Wroclaw.SyVe.RRM.resources.Screen import Screen
from testsuite.Wroclaw.SyVe.RRM.resources.TimeStamp import TimeStamp
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import execute_ssh_command, download_file
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from taf.config.testline.connection_details import SshServiceDetails
import re


class AppServer(object):

    def __init__(self, ue):
        self._ue = ue
        self.ue_sn = self._ue.serial_number
        self.iperf_details = self._get_iperf_details()
        self.ssh = self._get_ssh_details()
        self.bind_ip = self._get_bind_ip()
        self.port_incrementator = self._get_initial_port()
        self._iperf_version = None
        self._sever_port = None
        self.log_prefix = "LOG_{}_".format(self.ue_sn)
        self.err_prefix = "ERR_{}_".format(self.ue_sn)
        self.client_file_prefix = self.log_prefix + "CLIENT_APPSERV_"
        self.server_file_prefix = self.log_prefix + "SERVER_APPSERV_"
        self.err_server_file_prefix = self.err_prefix + "SERVER_APPSERV_"
        self.err_client_file_prefix = self.err_prefix + "CLIENT_APPSERV_"
        self.client = "_CLIENT"
        self.server = "_SERVER"
        self.client_file_dict = {}
        self.server_file_dict = {}
        self.err_client_file_dict = {}
        self.err_server_file_dict = {}

    def clean_the_appserver_environment(self):
        self.download_files_by_pattern(self.log_prefix)
        self.download_files_by_pattern(self.err_prefix)
        self._try_to_remove_files_with_pattern_on_iperf(self.log_prefix)
        self._try_to_remove_files_with_pattern_on_iperf(self.err_prefix)
        self._try_to_remove_all_detached_screens_by_full_id()

    def start_server_udp_transmission(self, data_name, port, **kwargs):
        self._start_server(data_name=data_name, protocol="-u", port=port, **kwargs)

    def start_server_tcp_transmission(self, data_name, port, **kwargs):
        self._start_server(data_name=data_name, protocol="", port=port, **kwargs)

    def start_client_udp_transmission(self, ue_ip, duration, traffic_mb, data_name, port, **kwargs):
        self._start_client(ue_ip=ue_ip, duration=duration, traffic_mb=traffic_mb, data_name=data_name, port=port,
                           protocol="-u", **kwargs)

    def start_client_tcp_transmission(self, ue_ip, duration, traffic_mb, data_name, port, **kwargs):
        self._start_client(ue_ip=ue_ip, duration=duration, traffic_mb=traffic_mb, data_name=data_name, port=port,
                           protocol="", **kwargs)

    def stop_transmission(self, data_name, port, ue_end_point):
        self._kill_iperf_process(port)
        end_point = self._get_appserver_endpoint(ue_end_point)
        Logger.debug(f"APPServer Stopping the {end_point.strip('_')} transmission")
        self._delete_screen(end_point=end_point, data_name=data_name)
        self._download_and_remove_logs_on_iperf(data_name=data_name, end_point=end_point)

    def download_files_by_pattern(self, pattern):
        files, _ = self._execute_ssh_iperf_command("ls -1 {}*".format(pattern))
        if files.strip():
            for file_ in files.split("\n"):
                Logger.debug("downloading {} from APPSERVER".format(file_))
                download_file(self.ssh, file_, Os.join_path_elements(Env().test_log_dir, file_))

    def _start_client(self, ue_ip, duration, traffic_mb, data_name, protocol, port, **kwargs):
        screen_name = self._create_screen(end_point=self.client, data_name=data_name)
        time = TimeStamp().file_timestamp
        client_file = self.client_file_prefix + data_name + '_' + time + '.txt'
        self.client_file_dict[data_name] = client_file
        err_client_file = self.err_client_file_prefix + data_name + '_' + time + '.txt'
        self.err_client_file_dict[data_name] = err_client_file
        Logger.debug("APPServer Starting client {} transmission".format(data_name))
        self._execute_ssh_iperf_command(
            Screen.execute(name=screen_name,
                           command=self._get_the_client_command(ue_ip=ue_ip, duration=duration, port=port,
                                                                traffic_mb=traffic_mb, protocol=protocol,
                                                                data_name=data_name, **kwargs)))

    def _start_server(self, data_name, protocol, port, **kwargs):
        screen_name = self._create_screen(end_point=self.server, data_name=data_name)
        time = TimeStamp().file_timestamp
        server_file = self.server_file_prefix + data_name + '_' + time + '.txt'
        self.server_file_dict[data_name] = server_file
        err_server_file = self.err_server_file_prefix + data_name + '_' + time + '.txt'
        self.err_server_file_dict[data_name] = err_server_file
        Logger.debug("Starting Iperf Server transmission")
        self._execute_ssh_iperf_command(Screen.execute(name=screen_name,
                                                       command=self._get_the_server_command(protocol=protocol,
                                                                                            data_name=data_name,
                                                                                            port=port,
                                                                                            **kwargs)))

    def _download_and_remove_logs_on_iperf(self, data_name, end_point):
        if end_point == "SERVER":
            data_name_prefix = self.client_file_dict.get(data_name)
            err_data_name_prefix = self.err_client_file_dict.get(data_name)
        else:
            data_name_prefix = self.server_file_dict.get(data_name)
            err_data_name_prefix = self.err_server_file_dict.get(data_name)
        self._download_and_clear_iperf_logs(data_name_prefix, err_data_name_prefix)

    def _download_and_remove_server_logs_on_iperf(self, data_name):
        data_name_prefix = self.server_file_dict.get(data_name)
        err_data_name_prefix = self.err_server_file_dict.get(data_name)
        self._download_and_clear_iperf_logs(data_name_prefix, err_data_name_prefix)

    def _download_and_clear_iperf_logs(self, data_name_prefix, err_data_name_prefix):
        self.download_files_by_pattern(data_name_prefix)
        self.download_files_by_pattern(err_data_name_prefix)
        self._try_to_remove_files_with_pattern_on_iperf(data_name_prefix)
        self._try_to_remove_files_with_pattern_on_iperf(err_data_name_prefix)

    def _execute_ssh_iperf_command(self, command):
        Logger.debug("AppServer - executing '{}' command".format(command))
        output, error = execute_ssh_command(self.ssh, command)
        return output, error

    def _create_screen(self, end_point, data_name):
        screen_name = self._get_screen_name(end_point, data_name)
        Logger.debug("creating screen {}".format(screen_name))
        execute_ssh_command(self.ssh, Screen.create(screen_name))
        return screen_name

    def _delete_screen(self, end_point, data_name):
        screen_name = self._get_screen_name(end_point, data_name)
        Logger.debug("deleting screen {}".format(screen_name))
        execute_ssh_command(self.ssh, Screen.delete(screen_name))

    def _get_appserver_endpoint(self, ue_end_point):
        end_point = self.client if ue_end_point == "SERVER" else self.server
        return end_point

    def _get_screen_name(self, end_point, data_name):
        return self.ue_sn + end_point + '_' + data_name

    def _try_to_remove_all_detached_screens_by_full_id(self):
        screen_id_index = 0
        existing_screens, _ = execute_ssh_command(self.ssh, Screen.list_screens(self.ue_sn))
        if existing_screens:
            for screen_id in [screen_entry.split()[screen_id_index] for screen_entry in existing_screens.split("\n")]:
                execute_ssh_command(self.ssh, Screen.delete(screen_id))

    def _try_to_remove_files_with_pattern_on_iperf(self, pattern):
        execute_ssh_command(self.ssh, "rm -f {}*".format(pattern))

    def _get_the_client_command(self, ue_ip, duration, port, traffic_mb, data_name, protocol="", **kwargs):
        cmd = f'iperf{self.iperf_version}{self._get_reverse_param(kwargs.get("reverse_mode", False))} -f m ' \
              f'-c {ue_ip} ' \
              f'{self._get_duration_or_data_size(duration)} ' \
              f'-i {kwargs.get("interval", 1)} ' \
              f'-p {port} ' \
              f'-P {kwargs.get("streams_count", 1)} ' \
              f'-b {traffic_mb}M ' \
              f'-B {self.bind_ip} ' \
              f'-l {kwargs.get("buffer_len", "1024B")} ' \
              f'-T {kwargs.get("ttl", 64)} ' \
              f'-M {kwargs.get("mtu_size", 1400)} ' \
              f'{self._get_tcp_window_size(kwargs.get("get_tcp_window_size"))}' \
              f'{protocol} ' \
              f'1> {self.client_file_dict.get(data_name)} 2>{self.err_client_file_dict.get(data_name)} &'
        return cmd

    def _get_duration_or_data_size(self, duration):
        if str(duration).isdigit():
            return f"-t {duration}"
        if str(duration).endswith(tuple("kmgKMG")):
            Logger.info(f"AppServer client changed behavior to sent {self._get_duration_unit(duration)}")
            return f"-n {duration}"
        assert False, f"Duration: {duration} is not proper value to start iperf client on the AppServer"

    @staticmethod
    def _get_tcp_window_size(window_size):
        return f"-w {window_size}M " if window_size else ""

    @staticmethod
    def _get_duration_unit(duration):
        return f"{duration}s" if str(duration).isdigit() else \
            f"{duration}Bytes of data" if str(duration).isupper() else f"{str(duration).upper()}bits of data"

    def _get_reverse_param(self, reverse_mode):
        if reverse_mode:
            assert self.iperf_version == "3", "Reverse tput cannot be started with iperf{} version," \
                                              " please check init file".format(self.iperf_version)
        return " -R" if reverse_mode else ""

    def _get_the_server_command(self, protocol, data_name, port, **kwargs):
        iperf_ver = self.iperf_version.replace("iperf3", "iperf") if kwargs.get("force_iperf2") else self.iperf_version
        tcp_window_size = "-w {}M".format(kwargs.get("tcp_window_size")) if kwargs.get("tcp_window_size") else ""
        cmd = f"iperf{iperf_ver} -s -f m" \
              f" -p {port}" \
              f" -i {kwargs.get('interval', 1)}" \
              f" -B {self.bind_ip}" \
              f" {protocol}" \
              f" {tcp_window_size}" \
              f" 1> {self.server_file_dict.get(data_name)}" \
              f" 2>{self.err_server_file_dict.get(data_name)} &"
        return cmd

    def _kill_iperf_process(self, port):
        pid_to_kill = self._get_iperf_pid(port)
        if pid_to_kill:
            kill_cmd = "kill -9 {}".format(pid_to_kill)
            self._execute_ssh_iperf_command(kill_cmd)
            return
        Logger.debug("no pid to be killed on AppServer")

    def _get_iperf_pid(self, port):
        pid_pattern = re.compile(r'(pid=(\d+))')
        pid_number = pid_pattern.search(self._get_socket_state_for_iperf_port(port))
        Logger.debug(f"Socket state for iperf port result: {pid_number}")
        return pid_number.group(2) if pid_number else None

    def _get_socket_state_for_iperf_port(self, port):
        output, error = self._get_socket_state_for_port(port)
        Logger.debug("Port {} ss command output is {}".format(port, output))
        return output

    @property
    def iperf_version(self):
        if self._iperf_version is None:
            try:
                self._iperf_version = "3" if self._ue.iperf_details.iperf_path[-1] == "3" else ""
            except AttributeError:
                self._iperf_version = "3" if self._ue.data_transfer.binary_path[-1] == "3" else ""
        return self._iperf_version

    def get_free_port(self):
        _port = self.port_incrementator
        for _ in range(20):
            output, _ = self._get_socket_state_for_port(_port)
            if str(_port) in output:
                Logger.warning(f"Busy AppServer port {_port} found, incrementing by one")
                _port += 1
            else:
                break
        another_possible_free_port_shift = 1
        self.port_incrementator = _port + another_possible_free_port_shift
        return _port

    def _get_socket_state_for_port(self, port):
        return self._execute_ssh_iperf_command("/usr/sbin/ss -lpn 'sport = :{}'".format(port))

    def _get_iperf_details(self):
        try:
            iperf_details = self._ue.iperf_details
        except AttributeError:
            iperf_details = self._ue.data_transfer.app_server
        return iperf_details

    def _get_ssh_details(self):
        try:
            ssh_details = self.iperf_details.ssh_connection_details
        except AttributeError:
            ssh_details = SshServiceDetails(addr=self.iperf_details.address,
                                            username=self.iperf_details.user,
                                            password=self.iperf_details.password)
        return ssh_details

    def _get_bind_ip(self):
        try:
            bind_ip = self.iperf_details.network_interface_address
        except AttributeError:
            bind_ip = self.iperf_details.bind_interface_ip
        return bind_ip

    def _get_initial_port(self):
        try:
            port = self.iperf_details.port
        except AttributeError:
            import random
            port = random.choice([port_nr for port_nr in range(30000, 60000)])
        return port
