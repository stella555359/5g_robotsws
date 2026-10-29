from enum import Enum

AT_CFUN_ATTACH = "AT+CFUN=1"
AT_COPS_ATTACH = "AT+COPS=0"
AT_COPS_DETACH = "AT+COPS=2"
AT_CFUN_DETACH = "AT+CFUN=4"
AT_CFUN_GET = "AT+CFUN?"
AT_CGPADDR = "AT+CGPADDR"
AT_CGATT_ATTACH = "AT+CGATT=1"


class KeyEvent(Enum):
    KEYCODE_HOME = 3
    KEYCODE_BACK = 4
    KEYCODE_DPAD_UP = 19
    KEYCODE_DPAD_DOWN = 20
    KEYCODE_DPAD_CENTER = 23
    KEYCODE_APP_SWITCH = 187
    KEYCODE_SLEEP = 223
    KEYCODE_WAKEUP = 224


class AdbCommands(object):
    """
    Class contains mostly formatted with device SN adb commands to be executed on UE
    """

    def __init__(self, device_serial_number, iperf_path):
        self.sn = device_serial_number
        self.key_event_cmd = "adb -s {} shell input keyevent {}"
        self.at_cmd = "adb -s {} shell at_cmd {}"
        self.at_cli = "adb -s {} shell atcli {}"
        self.iperf_path = iperf_path
        self._iperf_version = None

    @property
    def devices(self):
        return "adb devices"

    @property
    def at_cmd_cops_attach(self):
        return self.at_cmd.format(self.sn, AT_COPS_ATTACH)

    @property
    def at_cli_cops_attach(self):
        return self.at_cli.format(self.sn, AT_COPS_ATTACH)

    @property
    def at_cmd_cfun_attach(self):
        return self.at_cmd.format(self.sn, AT_CFUN_ATTACH)

    @property
    def at_cli_cfun_attach(self):
        return self.at_cli.format(self.sn, AT_CFUN_ATTACH)

    @property
    def at_cmd_cops_detach(self):
        return self.at_cmd.format(self.sn, AT_COPS_DETACH)

    @property
    def at_cli_cops_detach(self):
        return self.at_cli.format(self.sn, AT_COPS_DETACH)

    @property
    def at_cmd_cfun_detach(self):
        return self.at_cmd.format(self.sn, AT_CFUN_DETACH)

    @property
    def at_cli_cfun_detach(self):
        return self.at_cli.format(self.sn, AT_CFUN_DETACH)

    @property
    def at_cmd_get_cgpaddr(self):
        return self.at_cmd.format(self.sn, AT_CGPADDR)

    @property
    def at_cli_get_cgpaddr(self):
        return self.at_cli.format(self.sn, AT_CGPADDR)

    @property
    def at_cli_cgatt_attach(self):
        return self.at_cli.format(self.sn, AT_CGATT_ATTACH)

    @property
    def at_cmd_get_cfun(self):
        return self.at_cmd.format(self.sn, AT_CFUN_GET)

    @property
    def at_cli_get_cfun(self):
        return self.at_cli.format(self.sn, AT_CFUN_GET)

    @property
    def key_event_go_up(self):
        return self.key_event_cmd.format(self.sn, KeyEvent.KEYCODE_DPAD_UP.value)

    @property
    def key_event_go_down(self):
        return self.key_event_cmd.format(self.sn, KeyEvent.KEYCODE_DPAD_DOWN.value)

    @property
    def key_event_go_back(self):
        return self.key_event_cmd.format(self.sn, KeyEvent.KEYCODE_BACK.value)

    @property
    def key_event_tap_pad_center(self):
        return self.key_event_cmd.format(self.sn, KeyEvent.KEYCODE_DPAD_CENTER.value)

    @property
    def key_event_home_button(self):
        return self.key_event_cmd.format(self.sn, KeyEvent.KEYCODE_HOME.value)

    @property
    def key_event_show_active_apps(self):
        return self.key_event_cmd.format(self.sn, KeyEvent.KEYCODE_APP_SWITCH.value)

    @property
    def key_event_wake_up(self):
        return self.key_event_cmd.format(self.sn, KeyEvent.KEYCODE_WAKEUP.value)

    @property
    def key_event_sleep(self):
        return self.key_event_cmd.format(self.sn, KeyEvent.KEYCODE_SLEEP.value)

    @property
    def invoke_airplane_settings(self):
        return "adb -s {} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS".format(self.sn)

    @property
    def get_grep_inet_in_ip_cmd(self):
        return "adb -s {} shell ip a | grep inet | grep -v rndis".format(self.sn)

    @property
    def get_screen_state(self):
        return "adb -s {} shell dumpsys display | grep mScreenState=".format(self.sn)

    @property
    def get_airplane_mode_on(self):
        return "adb -s {} shell settings get global airplane_mode_on".format(self.sn)

    @property
    def swipe_up(self):
        x1, y1 = 400, 1400
        x2, y2 = 400, 0
        duration_ms = 1000
        return "adb -s {sn} shell input swipe {x1} {y1} {x2} {y2} {duration}".format(
            sn=self.sn, x1=x1, y1=y1, x2=x2, y2=y2, duration=duration_ms)

    @property
    def swipe_down(self):
        x1, y1 = 400, 0
        x2, y2 = 400, 1000
        duration_ms = 1000
        return "adb -s {sn} shell input swipe {x1} {y1} {x2} {y2} {duration}".format(
            sn=self.sn, x1=x1, y1=y1, x2=x2, y2=y2, duration=duration_ms)

    @property
    def kill_server(self):
        return "adb kill-server"

    @property
    def kill_all_iperf(self):
        return "adb -s {sn} shell pkill iperf".format(sn=self.sn)

    @property
    def reboot(self):
        return "adb -s {sn} shell reboot".format(sn=self.sn)

    @property
    def restart_adbd_with_root_permissions(self):
        return "adb -s {sn} root".format(sn=self.sn)

    @property
    def pgrep_iperf(self):
        return "adb -s {sn} shell pgrep iperf".format(sn=self.sn)

    @property
    def kill_iperf_pid(self):
        return "adb -s {sn} shell kill -9 {{pid}}".format(sn=self.sn)

    def tap_on_screen(self, coordinates):
        return "adb -s {} shell input tap {} {}".format(self.sn, *coordinates)

    def get_iperf_server_command(self, protocol, port, log, error_log, **kwargs):
        """
        Function creates iperf command to start downlink traffic on UE
        :param report_interval: How often iperf will report to file
        :param protocol: UDP/TCP
        :param port: The server port for the server to listen on and the client to connect to
        :param log: Log file
        :param error_log: Error file
        :return: formatted adb command
        """
        iperf_path = self.iperf_path.replace("iperf3", "iperf") if kwargs.get("force_iperf2") else self.iperf_path
        tcp_window_size = "-w {}M".format(kwargs.get("tcp_window_size")) if kwargs.get("tcp_window_size") else ""
        return f"adb -s {self.sn}" \
               f" shell {iperf_path} -s -f m" \
               f" -p {port}" \
               f" -i {kwargs.get('interval', 1)}" \
               f" {tcp_window_size}" \
               f" {protocol} 1>{log} 2>{error_log}"

    def get_iperf_client_command(self, protocol, connection, duration, traffic_mb, port, log, error_log, **kwargs):
        """
        Function creates iperf client command to start traffic on UE
        :param report_interval: How often iperf will write logs to file
        :param protocol: UDP/TCP
        :param connection: Host to be connected (iperf server)
        :param duration: data traffic duration
        :param traffic_mb: Data throughput in Mbits
        :param buffer_len: length of buffers to read and write
        :param ttl: TTL
        :param tcp_window_mb: Sets the socket buffer sizes to the specified value
        :param port: The server port for the server to listen on and the client to connect to
        :param log: Log file
        :param error_log: Error file
        :param streams: The number of simultaneous connections to make to the server.
        :param reverse_mode: reversed client-server roles
        :return:
        """
        iperf_path = self.iperf_path.replace("iperf3", "iperf") if kwargs.get("force_iperf2") else self.iperf_path
        return f"adb -s {self.sn} shell {iperf_path} " \
               f"{self._get_reverse_param(kwargs.get('reverse_mode', False))} " \
               f"-f m " \
               f"-p {port} " \
               f"-i {kwargs.get('interval', 1)} " \
               f"-c {connection} " \
               f"{self._get_duration_or_data_size(duration)} " \
               f"-P {kwargs.get('streams_count', 1)} " \
               f"-b {traffic_mb}M " \
               f"-l {kwargs.get('buffer_len', '1024B')} " \
               f"-T {kwargs.get('ttl', 64)} " \
               f"-w {kwargs.get('tcp_window_size', 2)}M " \
               f"-M {kwargs.get('mtu_size', 1400)} " \
               f"{protocol} 1>{log} 2>{error_log}"

    def _get_duration_or_data_size(self, duration):
        if str(duration).isdigit():
            return f"-t {duration}"
        if str(duration).endswith(tuple("kmgKMG")):
            return f"-n {duration}"
        assert False, f"Duration: {duration} is not proper value to start iperf client on the UE"

    def _get_reverse_param(self, reverse_mode):
        if reverse_mode:
            assert self.iperf_version == "3", "Reverse tput cannot be started with iperf{} version," \
                                              " please check init file".format(self.iperf_version)
        return " -R" if reverse_mode else ""

    @property
    def iperf_version(self):
        if self._iperf_version is None:
            self._iperf_version = "3" if self.iperf_path[-1] == "3" else ""
        return self._iperf_version

    def make_phone_call(self, phone_number):
        return "adb -s {} shell am start -a android.intent.action.CALL -d tel:{}".format(self.sn, phone_number)

    def hang_up_phone_call(self):
        return "adb -s {} shell input keyevent KEYCODE_ENDCALL".format(self.sn)

    def get_phone_call_status(self):
        return "adb -s {} shell dumpsys telephony.registry | grep -m 1 mCallState".format(self.sn)

    def look_for_set_date_and_time_window(self):
        return "adb -s {} shell dumpsys window windows | grep com.android.phone".format(self.sn)

    def get_ue_screenshot_and_pass_to_file(self):
        return "adb -s {sn} exec-out screencap -p > screenshot_{sn}_ue.png".format(sn=self.sn)

    def get_ue_dumpsys_window_log_and_pass_to_file(self):
        return "adb -s {sn} shell dumpsys window > dumpsys_window_{sn}_ue.txt".format(sn=self.sn)

    def get_service_state(self):
        return "adb -s {} shell dumpsys telephony.registry | grep -m 1 mServiceState".format(self.sn)

    def get_cell_info(self):
        return "adb -s {} shell dumpsys telephony.registry | grep -m 1 mCellInfo".format(self.sn)

    def get_data_mode_state(self):
        return f"adb -s {self.sn} shell settings get global mobile_data"

    def enable_data_mode(self):
        return f"adb -s {self.sn} shell svc data enable"

    def enable_airplane_mode(self):
        return f"adb -s {self.sn} shell cmd connectivity airplane-mode enable"

    def disable_airplane_mode(self):
        return f"adb -s {self.sn} shell cmd connectivity airplane-mode disable"
