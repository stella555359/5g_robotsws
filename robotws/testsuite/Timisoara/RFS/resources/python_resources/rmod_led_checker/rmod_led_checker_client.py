import os
import signal
import functools
import re
import contextlib
import Pyro4
import taf.transport.ssh as taf_ssh
import traceback
import yaml
import datetime
from pathlib import Path, PureWindowsPath, PurePosixPath
from time import sleep, monotonic
from rmod_led_checker_server import DAEMON_HOST, DAEMON_PORT, PYTHON_EXEC, PYRO_SERVER_NAME, \
    DEFAULT_RMOD_LABEL_COM_PORT_DICT, DEFAULT_GENERATE_SERVER_LOG


FOLDERS_BLACKLISTED_FROM_TRANSFER = ['__.*__', '\\..*']
FILES_BLACKLISTED_FROM_TRANSFER = ['__.*__', '\\..*']
DEFAUT_VM_LOGS_FOLDER = "/tmp"
DEFAULT_SSH_TIMEOUT = 90
DEFAULT_FILE_TRANSFER_TIMEOUT = 30


class LedCheckerTimeoutError(TimeoutError):
    """Raised when a LED monitoring operation exceeds the specified timeout."""
    pass


# Flag set by the timeout signal handler when SIGALRM fires. Used to convert exceptions
# from underlying libraries (e.g. SSH auth failure after EINTR) into LedCheckerTimeoutError.
_timeout_alarm_fired = False


# Timeout mechanism implemented by Cursor generative AI
def _timeout_signal_handler(signum, frame):
    """Signal handler for SIGALRM: sets flag and raises LedCheckerTimeoutError."""
    global _timeout_alarm_fired
    _timeout_alarm_fired = True
    raise LedCheckerTimeoutError(
        "LED monitoring operation timed out (signal SIGALRM, elapsed time exceeded timeout)")


@contextlib.contextmanager
def _led_timeout(timeout):
    """
    Reusable context manager that enforces a wall-clock timeout on the enclosed block.

    - Sets up SIGALRM (Linux only) so that blocking C-level calls are also interrupted.
    - Computes a monotonic deadline used by _check_timeout() for cooperative checks.
    - Converts any non-timeout exception that occurs while the alarm has fired into
      LedCheckerTimeoutError so callers always see a consistent error type.

    Usage::

        with _led_timeout(30) as deadline:
            self._check_timeout(deadline)
            ...  # your code here

    :param timeout: Seconds until the timeout fires, or None for no limit.
    :yields: deadline – absolute monotonic time of expiry, or None when timeout is None.
    :raises LedCheckerTimeoutError: when the timeout is exceeded.
    """
    global _timeout_alarm_fired
    deadline = (monotonic() + timeout) if timeout is not None else None
    use_signal = timeout is not None
    if use_signal:
        _timeout_alarm_fired = False
        old_handler = signal.signal(signal.SIGALRM, _timeout_signal_handler)
        signal.alarm(int(timeout))
    try:
        yield deadline
    except LedCheckerTimeoutError:
        raise
    except Exception as e:
        if use_signal and _timeout_alarm_fired:
            raise LedCheckerTimeoutError(
                "LED monitoring operation timed out (signal SIGALRM, elapsed time exceeded timeout)") from e
        raise
    finally:
        if use_signal:
            signal.alarm(0)
            signal.signal(signal.SIGALRM, old_handler)
            _timeout_alarm_fired = False


def catch_exception(f):
    @functools.wraps(f)
    def func(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except (LedCheckerTimeoutError, TimeoutError):
            raise
        except Pyro4.errors.CommunicationError as e:
            print(f"ERROR: {e}")
            return ""
        except Exception as e:
            print(f"ERROR: {e}")
            traceback.print_exc()
            return ""
    return func


class rmod_led_checker_client:

    def __init__(self, vm_source_folder="", pc_target_folder="c:/rmod_led_checker",
                 vm_logs_folder="", upload_code_to_pc: bool = True,
                 pc_pyro_host=DAEMON_HOST, pc_pyro_port=DAEMON_PORT,
                 pyro_server_name=PYRO_SERVER_NAME, generate_server_log=DEFAULT_GENERATE_SERVER_LOG):

        self.all_remote_host_dict = {}
        self.current_host_dict = {}

        self.vm_source_folder = vm_source_folder or os.path.dirname(os.path.realpath(__file__))
        self.pc_target_folder = pc_target_folder
        self.vm_logs_folder = vm_logs_folder or DEFAUT_VM_LOGS_FOLDER
        self.upload_code_to_pc = upload_code_to_pc
        self.pc_pyro_host = pc_pyro_host
        self.pc_pyro_port = pc_pyro_port
        self.pyro_server_name = pyro_server_name
        self.pc_target_application = "rmod_led_checker_server.py"
        self.RemotePath = PureWindowsPath
        self.LocalPath = PurePosixPath
        self.generate_server_log = generate_server_log
        self.application_parent_folder = ""
        self.application_path = ""
        self.restart_server = True

    def _connect_ssh(self, host_object, timeout=None):
        timeout = timeout or DEFAULT_SSH_TIMEOUT
        host_object["ssh_session_object"] = taf_ssh.connect(hostname=host_object["ip"],
                                                            username=host_object["username"],
                                                            password=host_object["password"],
                                                            port=host_object["port"],
                                                            key_path=None,
                                                            timeout=timeout,
                                                            proxy=None,
                                                            look_for_keys=True,
                                                            allow_agent=True)

    def _disconnect_ssh(self, host_object):
        if host_object["ssh_session_object"] is not None and host_object["ssh_session_object"].is_connected:
            host_object["ssh_session_object"].disconnect()

    def _is_pyro_connected(self, host_object):
        try:
            pyro_server_running = host_object['pyro_client_object'].running()
            print(f"INFO pyro client: pyro connected = {pyro_server_running}")
            return pyro_server_running
        except Exception as e:
            print(f"INFO pyro client: pyro not connected.")
            print(f"INFO pyro message: {e}")
            return False

    def _upload_dir(self, current_host_dict, source_path='', destination_path=''):
        if not self.upload_code_to_pc:
            print(f"INFO pyro client: Upload code to PC = {self.upload_code_to_pc}")
        else:
            print(f"INFO pyro client: Uploading code from {source_path} to path {destination_path}")
            self.vm_source_folder = source_path or self.vm_source_folder
            source_path = Path(self.vm_source_folder)
            self.pc_target_folder = destination_path or self.pc_target_folder
            print(f"INFO pyro client: PC target folder = {self.pc_target_folder}")
            destination_path = self.RemotePath(self.pc_target_folder)

            print(f'INFO pyro client: Starting copy: from {source_path} to remote {destination_path}')
            destination_path /= source_path.name
            self._ensure_ssh_connected(current_host_dict)
            cmd_output = current_host_dict["ssh_session_object"].execute(
                f"mkdir -p {destination_path.as_posix()}")
            print(f'INFO pyro client: mkdir -p {destination_path.as_posix()} output on target PC: {cmd_output}')
            for path in source_path.iterdir():
                print('INFO pyro client: Current path:', path)
                if path.is_file() and self._dir_file_is_not_blacklisted(path):
                    self._upload_file_to_remote_ssh_host(host_object=self.current_host_dict,
                                                         local_path=path,
                                                         remote_path=destination_path)
                elif path.is_dir() and self._dir_file_is_not_blacklisted(path):
                    cmd_output = current_host_dict["ssh_session_object"].execute(
                        f'mkdir -p {destination_path.as_posix() / path.name}')
                    print(f'INFO pyro client: mkdir -p {destination_path.as_posix()} output target PC: {cmd_output}')
                    self._upload_dir(current_host_dict, source_path, destination_path)

    def _dir_file_is_not_blacklisted(self, path):
        if path.is_file():
            BLACKLIST = FILES_BLACKLISTED_FROM_TRANSFER
        elif path.is_dir():
            BLACKLIST = FOLDERS_BLACKLISTED_FROM_TRANSFER
        match_list = [re.match(item, path.name) for item in BLACKLIST]
        if any(match_list):
            print(f"INFO pyro client: {path.name} is blacklisted")
        else:
            print(f"INFO pyro client: {path.name} not blacklisted")
        return not any(match_list)

    def _start_pyro_server(self, host_object):
        server_name = host_object["pyro_server_name"] or PYRO_SERVER_NAME
        application_path = host_object["application_path"] or self.application_path
        pc_pyro_host = host_object["pyro_host"] or self.pc_pyro_host
        pc_pyro_port = host_object["pyro_port"] or self.pc_pyro_port
        generate_server_log = self.generate_server_log
        cmd = f"{PYTHON_EXEC} -u {application_path} {server_name} {pc_pyro_host} {pc_pyro_port} " \
              + f"{generate_server_log}"
        print(f"INFO pyro client: {cmd}")
        self.current_host_dict["ssh_session_object"].send_command(cmd)

    def _connect_pyro(self, host_object):
        """
         Method to start pyro server on remote host and create pyro object used by pyro client to connect.
        """
        print("INFO pyro client: Creating pyro object")
        self._check_pyro_obj(host_object)
        print("INFO pyro client: Check if pyro server is already running")
        pyro_connected = self._is_pyro_connected(host_object)
        if pyro_connected and self.restart_server:
            print(f"INFO pyro client: Pyro server running. Stopping b/c restart_server = {self.restart_server}")
            self._disconnect_pyro(host_object)
            pyro_connected = self._is_pyro_connected(host_object)
            print(f"INFO pyro client: pyro_connected = {pyro_connected}")
        if not pyro_connected:
            print("INFO pyro client: Pyro server not running. Starting remote pyro server")
            self._start_pyro_server(host_object)
            sleep(5)
        else:
            print(f"INFO pyro client: Pyro4 server is already running")
        print("INFO pyro client: _check_pyro_obj")
        self._check_pyro_obj(host_object)

    def _check_pyro_obj(self, host_object):
        """
        Method to create and set pyro client object attribute based on provided URI
        :return:  pyro client object
        """
        Pyro4.DETAILED_TRACEBACK = True
        Pyro4.config.PICKLE_PROTOCOL_VERSION = 2
        print(f"INFO pyro client: uri is: {host_object['uri']}")
        if host_object["pyro_client_object"] is None:
            p = Pyro4.Proxy(host_object["uri"])
            p._pyroMaxRetries = 0
            p._pyroTimeout = 0
            p._pyroSerializer = "pickle"
            host_object["pyro_client_object"] = p
        self._is_pyro_connected(host_object)

    def _ensure_ssh_connected(self, host_object, timeout=None):
        if not host_object["ssh_session_object"]:
            self._connect_ssh(host_object, timeout=timeout)
        elif host_object["ssh_session_object"]:
            if not host_object["ssh_session_object"].is_connected:
                self._connect_ssh(host_object, timeout=timeout)

    def _check_timeout(self, deadline):
        """
        Raise LedCheckerTimeoutError if deadline has passed.
        :param deadline: Absolute time from monotonic() or None for no timeout
        """
        if deadline is not None and monotonic() >= deadline:
            raise LedCheckerTimeoutError(
                "LED monitoring operation timed out (elapsed time exceeded timeout)")

    def _upload_file_to_remote_ssh_host(self, host_object, local_path, remote_path, timeout=None):
        self._ensure_ssh_connected(host_object=host_object)
        timeout = timeout or DEFAULT_FILE_TRANSFER_TIMEOUT
        return host_object["ssh_session_object"].files.put(local_path=str(local_path),
                                                           remote_path=str(remote_path / local_path.name),
                                                           timeout=timeout)

    def _download_file_from_remote_ssh_host(self, host_object, remote_path, local_path, timeout=None):
        self._ensure_ssh_connected(host_object=host_object)
        timeout = timeout or DEFAULT_FILE_TRANSFER_TIMEOUT
        print(f"INFO pyro client: downloading: {remote_path} -> {local_path / remote_path.name}")
        return host_object["ssh_session_object"].files.get(remote_path=str(remote_path),
                                                           local_path=str(local_path / remote_path.name),
                                                           timeout=timeout)

    def _download_file_list(self, host_object, remote_path_list, local_path, timeout=None):
        timeout = timeout or DEFAULT_FILE_TRANSFER_TIMEOUT
        for remote_file in remote_path_list:
            self._download_file_from_remote_ssh_host(host_object,
                                                     self.RemotePath(remote_file),
                                                     self.LocalPath(local_path),
                                                     timeout=timeout)

    @catch_exception
    def _disconnect_pyro(self, host_object):
        host_object["pyro_client_object"].stop_server()

    @catch_exception
    def _check_server_pyro_version(self, host_object, repeat_number: int = 3):
        server_pyro = ""
        repeat_index = 0
        output = ""
        while not server_pyro and repeat_index < repeat_number:
            if not self._is_pyro_connected(host_object):
                sleep(3)
                continue
            output = host_object["pyro_client_object"].check_server_pyro_version()
            repeat_index += 1
            sleep(3)
        return output

    def _check_client_pyro_version(self):
        cmd = 'python -u -c "import Pyro4.constants as c; print(c.PROTOCOL_VERSION)"'
        output = os.popen(cmd).read().rstrip()
        return output

    def start_led_monitoring_for_multiple_hosts(self,
                                                config_yaml_path="",
                                                log_folder="",
                                                timeout=600):
        """
        Method to start LED monitoring for all hosts from configuration YAML file
        :param config_yaml_path: Path to the configuration YAML file
        :param log_folder: Logs folder on VM where trace files will be copied at the end
        :param timeout: Maximum time in seconds for the whole operation (None = no limit).
                       LedCheckerTimeoutError is raised if elapsed time exceeds this value.
                       Uses SIGALRM on Linux (e.g. Debian) to interrupt blocking calls.
        """
        with _led_timeout(timeout) as deadline:
            self._check_timeout(deadline)
            with open(config_yaml_path) as fd:
                self.rmod_led_check_settings = yaml.safe_load(fd)
            print(f"INFO pyro client: LED Check Settings file = {self.rmod_led_check_settings}")
            rmod_labels = [*self.rmod_led_check_settings.keys()]
            host_dict = {}
            print(f"INFO pyro client: {rmod_labels}")

            for rmod_label in rmod_labels:
                rmod_data_from_config_yaml = self.rmod_led_check_settings[f"{rmod_label}"]
                print(f"INFO pyro client: RMOD {rmod_label} = {rmod_data_from_config_yaml}")
                print(f"INFO pyro client: RMOD {rmod_label} IP = {rmod_data_from_config_yaml['host_ip']}")

                one_host_dict = host_dict.pop(
                    rmod_data_from_config_yaml['host_ip'],
                    {}
                )

                one_host_dict["host_user"] = rmod_data_from_config_yaml['host_user'] or one_host_dict["host_user"]
                one_host_dict["host_password"] = rmod_data_from_config_yaml['host_password'] \
                    or one_host_dict["host_password"]
                one_host_dict["rmod_port_dict"] = {} if "rmod_port_dict" not in one_host_dict \
                    else one_host_dict["rmod_port_dict"]
                one_host_dict["rmod_port_dict"][rmod_label] = {
                    'com_port': rmod_data_from_config_yaml['com_port'],
                    'baud_rate': int(rmod_data_from_config_yaml['baud_rate']),
                    'MEASUREMENT_SEPARATOR': rmod_data_from_config_yaml['MEASUREMENT_SEPARATOR']
                }
                print(f"INFO pyro client: HOST dict = {one_host_dict}")

                host_dict[rmod_data_from_config_yaml['host_ip']] = one_host_dict
                print(f"INFO pyro client: HOST dict = {host_dict}")

            print("INFO pyro client ======================================")
            print(f"INFO pyro client: {host_dict}")
            print("INFO pyro client --------------------------------------")
            for host in host_dict:
                self._check_timeout(deadline)
                timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
                folder = Path(log_folder or self.vm_logs_folder, f"RMOD_LED_CHECK_PC_{host}_{timestamp}")
                print(f"INFO pyro client: creating local path {folder}")
                if not os.path.isdir(folder):
                    os.makedirs(folder)
                self.start_led_monitoring(pyro_server_name=host,
                                          pc_ip=host,
                                          pc_user=host_dict[host]["host_user"],
                                          pc_password=host_dict[host]["host_password"],
                                          vm_logs_folder=folder,
                                          rmod_label_com_port_dict=host_dict[host]["rmod_port_dict"],
                                          deadline=deadline)

    @catch_exception
    def start_led_monitoring(self, pc_ip="", pc_port: int = 22, pc_user="", pc_password="",
                             pc_target_folder="", vm_logs_folder="", pc_pyro_host="",
                             pc_pyro_port="", pyro_server_name="",
                             rmod_label_com_port_dict={}, restart_server=True, deadline=300):
        """
        Method to start LED monitoring for a single host

        :param pc_ip: PC IP address
        :param pc_port: PC port for ssh connection
        :param pc_user: PC user for ssh connection
        :param pc_password: PC password for ssh connection
        :param pc_target_folder: PC target folder for code transfer
        :param vm_logs_folder: Logs folder on VM where trace files will be copied at the end
        :param pc_pyro_host: PC Pyro host
        :param pc_pyro_port: PC Pyro port
        :param pyro_server_name: Pyro server name
        :param rmod_label_com_port_dict: RMOD label com port dictionary
        :param restart_server: Restart server if it is already running
        :param deadline: Absolute time (monotonic()) when operation must stop; None = no timeout
        """
        self._check_timeout(deadline)
        pc_pyro_host = pc_pyro_host or self.pc_pyro_host
        pc_pyro_port = pc_pyro_port or self.pc_pyro_port
        pyro_server_name = pyro_server_name or self.pyro_server_name
        pc_target_folder = pc_target_folder or self.pc_target_folder
        self.application_parent_folder = Path(self.vm_source_folder).name
        self.restart_server = restart_server
        print(f"INFO pyro client: local application parent folder {self.application_parent_folder}")
        application_path = self.RemotePath(pc_target_folder,
                                           self.application_parent_folder,
                                           self.pc_target_application).as_posix()
        print(f"INFO pyro client: remote application path {application_path}")

        self.current_host_dict = {
            "ip": pc_ip,
            "port": pc_port,
            "username": pc_user,
            "password": pc_password,
            "pyro_host": pc_pyro_host,
            "pyro_port": pc_pyro_port,
            "target_folder": pc_target_folder,
            "vm_logs_folder": vm_logs_folder or self.vm_logs_folder,
            "pyro_server_name": pyro_server_name,
            "uri": f"PYRO:{pyro_server_name}@{pc_ip}:{pc_pyro_port}",
            "rmod_label_com_port_dict": rmod_label_com_port_dict or DEFAULT_RMOD_LABEL_COM_PORT_DICT,
            "ssh_session_object": None,
            "pyro_client_object": None,
            "application_path": application_path or self.application_path,
            "trace_files": []
        }
        print(f"INFO pyro client: host dict = {self.current_host_dict}")

        self._check_timeout(deadline)
        print(f"INFO pyro client: Starting ssh connection to {self.current_host_dict['ip']}")
        self._ensure_ssh_connected(self.current_host_dict)
        self._check_timeout(deadline)
        self._upload_dir(self.current_host_dict, destination_path=self.current_host_dict['target_folder'])
        self._check_timeout(deadline)
        print(f"INFO: Starting pyro server: {self.current_host_dict['ip']} -> {self.current_host_dict['pyro_host']}"
              f" {self.current_host_dict['pyro_port']}")
        self._connect_pyro(self.current_host_dict)
        self._check_timeout(deadline)
        print(f"INFO pyro client: Checking local and server {self.current_host_dict['ip']} Pyro4 version")
        local_pyro = self._check_client_pyro_version()
        print(f"INFO pyro client: Local Pyro4 version: {local_pyro}")
        server_pyro = self._check_server_pyro_version(self.current_host_dict)
        print(f"INFO pyro client: Server Pyro4 version: {server_pyro}")
        if local_pyro != server_pyro:
            print("WARNING pyro client: Local pyro different from server pyro. Application might work abnormally")
        else:
            print("INFO pyro client: Local Pyro4 same version as server Pyro4.")
        self._check_timeout(deadline)
        self.current_host_dict["pyro_client_object"].start_traces(self.current_host_dict["rmod_label_com_port_dict"])
        self.all_remote_host_dict.update({self.current_host_dict["ip"]: self.current_host_dict})
        print(f"INFO pyro client: all remote host dict = {self.all_remote_host_dict}")
        self.current_host_dict = {}

    @catch_exception
    def stop_led_monitoring(self, timeout=30):
        """
        Method to stop LED monitoring for all hosts
        :param timeout: Maximum time in seconds for the whole operation (None = no limit).
                       LedCheckerTimeoutError is raised if elapsed time exceeds this value.
                       Uses SIGALRM on Linux (e.g. Debian) to interrupt blocking calls.
        """
        with _led_timeout(timeout) as deadline:
            self._check_timeout(deadline)
            self.read_output_dict = {}
            print(f"INFO pyro client: all remote hosts {self.all_remote_host_dict}")
            host_objects = list(self.all_remote_host_dict.values())
            for host_object in host_objects:
                try:
                    self._check_timeout(deadline)
                    self.read_output_dict.update(host_object["pyro_client_object"].get_read_output_dict())
                    print(f"INFO pyro client: Read output dict = {self.read_output_dict}")
                    host_object["vm_logs_folder"] = host_object["vm_logs_folder"]
                    host_object["trace_files"].extend(host_object["pyro_client_object"].stop_traces())
                    print(f"INFO pyro client: Saved trace files {host_object['trace_files']}")
                    self._check_timeout(deadline)
                    self._download_file_list(host_object, host_object['trace_files'], host_object["vm_logs_folder"])
                    print(f"INFO pyro client: Stopping pyro server on {host_object['ip']}")
                finally:
                    self._disconnect_pyro(host_object)
                    self._disconnect_ssh(host_object)

    def check_LED_stable_states_in_interval(self, rmod_label, expected_value_map={}, timeout=30):
        """
        Method to check LED stable states in a given interval

        :param rmod_label: RMOD SN for which the check is performed
        :param expected_value_map: Dictionary - OR - String: { LED_1: 1/0 (1 for ON, 0 for OFF), LED_2: 1/0 ...}
        :param timeout: Maximum time in seconds for the whole operation (None = no limit).
                       LedCheckerTimeoutError is raised if elapsed time exceeds this value.
                       Uses SIGALRM on Linux (e.g. Debian) to interrupt blocking calls.

        Returns:
            tuple: (result, unexpected_states_collection)
            result: True if the LED states are stable, False otherwise
            unexpected_states_collection: Dictionary: { line_nbr: [LED_1, LED_2, ...] }
        """
        with _led_timeout(timeout) as deadline:
            unexpected_states_collection = {}
            result = False

            if not expected_value_map:
                print(f"INFO pyro client analysis: Expected values are not provided")
                return unexpected_states_collection
            print("INFO pyro client (check_LED_stable_states_in_interval): Starting")
            print(f"INFO pyro client (check_LED_stable_states_in_interval): Args: {rmod_label} {expected_value_map}")
            if isinstance(expected_value_map, str):
                expected_value_map = eval(expected_value_map)
            expected_value_map = self._convert_expected_value_LED_numbers_to_int(expected_value_map)

            self._check_timeout(deadline)
            host = self.rmod_led_check_settings[rmod_label]['host_ip']
            print(f"INFO pyro client analysis: all remote host dict = {self.all_remote_host_dict}")
            host_object = self.all_remote_host_dict[host]
            read_output = host_object["pyro_client_object"].get_read_output_dict(rmod_label)
            unexpected_states = []
            if read_output:
                print(f"INFO pyro client analysis: Read output = {read_output}")
            else:
                print(f"INFO pyro client analysis: Read output is empty")
                return expected_value_map.keys()

            ledmap = self.rmod_led_check_settings[rmod_label]["LED_NUMBERS"]
            print(f"INFO pyro client analysis: LED map = {ledmap} {type(ledmap)}")
            threshold = self.rmod_led_check_settings[rmod_label]["LED_THRESHOLDS"]
            print(f"INFO pyro client analysis: Thresholds = {threshold} {type(threshold)}")

            unexpected_states_collection = {}
            read_output_filtered = self._eliminate_non_float_values(read_output)
            print(f"INFO pyro client analysis: Expected values = {expected_value_map}")
            for line_nbr, read_line in enumerate(read_output_filtered):
                self._check_timeout(deadline)
                unexpected_states = self._check_led_states_reading(threshold, ledmap, read_line, expected_value_map)
                if unexpected_states:
                    unexpected_states_collection[line_nbr] = unexpected_states

            if unexpected_states_collection:
                print(f"INFO pyro client analysis: Unexpected states = {unexpected_states_collection}")
            else:
                print(f"INFO pyro client analysis: No unexpected states")
                result = True
            return result, unexpected_states_collection

    def check_LED_states_occurence_in_interval(self, rmod_label, expected_value_map={}, timeout=30):
        """
        Method to check LED states occurrence in a given interval.
        At least 1 time the value for one of the LEDs should occur.
        Not all expected values for each LED should occur in the same sample.

        :param rmod_label: RMOD SN for which the check is performed
        :param expected_value_map: Dictionary - OR - String: { LED_1: 1/0 (1 for ON, 0 for OFF), LED_2: 1/0 ...}
        :param timeout: Maximum time in seconds for the whole operation (None = no limit).
                       LedCheckerTimeoutError is raised if elapsed time exceeds this value.
                       Uses SIGALRM on Linux (e.g. Debian) to interrupt blocking calls.

        Returns:
            tuple: (result, sparse_match_dict)
            result: True if the LED states occurrence is found, False otherwise
            sparse_match_dict: Dictionary: { LED_1: 1/0 (1 for ON, 0 for OFF), LED_2: 1/0 ...}
        """
        with _led_timeout(timeout) as deadline:
            sparse_match_dict = {}
            result = False
            unexpected_states_collection = {}

            if not expected_value_map:
                print(f"INFO pyro client analysis: Expected values are not provided")
                return result, unexpected_states_collection
            print("INFO pyro client (check_LED_states_occurence_in_interval): Starting")
            if isinstance(expected_value_map, str):
                expected_value_map = eval(expected_value_map)
            expected_value_map = self._convert_expected_value_LED_numbers_to_int(expected_value_map)

            self._check_timeout(deadline)
            host = self.rmod_led_check_settings[rmod_label]['host_ip']
            host_object = self.all_remote_host_dict[host]
            read_output = host_object["pyro_client_object"].get_read_output_dict(rmod_label)

            if read_output:
                print(f"INFO pyro client analysis: Read output = {read_output}")
            else:
                print(f"INFO pyro client analysis: Read output is empty")
                for led_nbr in expected_value_map.keys():
                    sparse_match_dict[led_nbr] = 0
                return result, sparse_match_dict

            ledmap = self.rmod_led_check_settings[rmod_label]["LED_NUMBERS"]
            print(f"INFO pyro client analysis: LED map = {ledmap} {type(ledmap)}")
            threshold = self.rmod_led_check_settings[rmod_label]["LED_THRESHOLDS"]
            print(f"INFO pyro client analysis: Thresholds = {threshold} {type(threshold)}")

            read_output_filtered = self._eliminate_non_float_values(read_output)
            print(f"INFO pyro client analysis: Expected values = {expected_value_map}")

            invalid_leds = [led for led in expected_value_map if led not in ledmap]
            if invalid_leds:
                raise ValueError(f"Invalid LED numbers {invalid_leds} not found in "
                                 f"ledmap {ledmap} for RMOD {rmod_label}")

            for led_nbr in expected_value_map.keys():
                sparse_match_dict[led_nbr] = 0

            for row_index, read_line in enumerate(read_output_filtered):
                self._check_timeout(deadline)
                sparse_match_list = self._check_led_states_reading(threshold,
                                                                   ledmap,
                                                                   read_line,
                                                                   expected_value_map,
                                                                   sparse_match=True)
                print(f"INFO pyro client analysis: Sparse match sample = {sparse_match_list}")
                for col_index, led_nbr in enumerate(ledmap):
                    if led_nbr in expected_value_map:
                        sparse_match_dict[led_nbr] = sparse_match_dict[led_nbr] or sparse_match_list[col_index]

            if sum(sparse_match_dict.values()) == len(expected_value_map):
                print(f"INFO pyro client analysis: All LEDs match expected values")
                sparse_match_dict = {}
                result = True
            else:
                print(f"INFO pyro client analysis: Some LEDs do not match expected values")
            return result, sparse_match_dict

    def get_LED_measurements_in_interval(self, rmod_label, timeout=30):
        """
        Method to get LED measurements in a given interval without interpretation.

        :param rmod_label: RMOD SN for which the check is performed
        :param timeout: Maximum time in seconds for the whole operation (None = no limit).
                       LedCheckerTimeoutError is raised if elapsed time exceeds this value.
                       Uses SIGALRM on Linux (e.g. Debian) to interrupt blocking calls.

        Returns:
            list: List of LED measurements
        """
        with _led_timeout(timeout) as deadline:
            print("INFO pyro client analysis(get_LED_measurements_in_interval): Starting")
            self._check_timeout(deadline)
            host = self.rmod_led_check_settings[rmod_label]['host_ip']
            host_object = self.all_remote_host_dict[host]
            read_output = host_object["pyro_client_object"].get_read_output_dict(rmod_label)
            unexpected_states = []
            if read_output:
                print(f"INFO pyro client analysis: Read output = {read_output}")
            else:
                print(f"INFO pyro client analysis: Read output is empty")
                return []
            ledmap = self.rmod_led_check_settings[rmod_label]["LED_NUMBERS"]
            print(f"INFO pyro client analysis: LED map = {ledmap} {type(ledmap)}")
            threshold = self.rmod_led_check_settings[rmod_label]["LED_THRESHOLDS"]
            print(f"INFO pyro client analysis: Thresholds = {threshold} {type(threshold)}")

            read_output_filtered = self._eliminate_non_float_values(read_output)
            print(f"INFO pyro client analysis: Led output = {read_output_filtered}")

            read_values_list = []
            for line_nbr, read_line in enumerate(read_output_filtered):
                self._check_timeout(deadline)
                read_values = self._check_led_states_reading(threshold, ledmap, read_line)
                read_values_list.append(read_values)

            return read_values_list

    def get_current_LED_states(self, rmod_label, timeout=30):
        """
        Method to get current LED states (from latest measurement only).

        :param rmod_label: RMOD SN for which the check is performed
        :param timeout: Maximum time in seconds for the whole operation (None = no limit).
                       LedCheckerTimeoutError is raised if elapsed time exceeds this value.
                       Uses SIGALRM on Linux (e.g. Debian) to interrupt blocking calls.

        Returns:
            list: List of LED states (1 for ON, 0 for OFF) of last LED reading
        """
        with _led_timeout(timeout) as deadline:
            self._check_timeout(deadline)
            host = self.rmod_led_check_settings[rmod_label]['host_ip']
            host_object = self.all_remote_host_dict[host]
            read_output = host_object["pyro_client_object"].get_read_output_dict(rmod_label)
            print("INFO pyro client analysis(get_current_LED_states): Starting")
            if read_output:
                read_line = read_output[-1]
                print(f"INFO pyro client analysis: Read output = {read_output}")
                print(f"INFO pyro client analysis: Useful line = {read_line}")
            else:
                read_line = []
                print(f"INFO pyro client analysis: Read output is empty")
                return []
            ledmap = self.rmod_led_check_settings[rmod_label]["LED_NUMBERS"]
            print(f"INFO pyro client analysis: LED map = {ledmap}")

            threshold = self.rmod_led_check_settings[rmod_label]["LED_THRESHOLDS"]
            print(f"INFO pyro client analysis: Threshold = {threshold}")

            self._check_timeout(deadline)
            read_output_filtered = self._eliminate_non_float_values(read_output[-1::])
            states = self._check_led_states_reading(threshold, ledmap, read_line)

            return states

    def _convert_expected_value_LED_numbers_to_int(self, expected_value_map):
        result = {}
        if not any([isinstance(key, str) for key in expected_value_map]):
            return expected_value_map
        else:
            for key in expected_value_map:
                value = expected_value_map[key]
                result[int(key)] = value
            return result

    def _eliminate_non_float_values(self, read_output):
        """
        Helper method to eliminate non-float values from read output.

        :param read_output: Read output

        Returns:
            list: List of float values, -1 in place where non-float values were read from serial port
        """
        for line_nbr, read_line in enumerate(read_output):
            for index, element in enumerate(read_line):
                try:
                    float(element)
                except ValueError:
                    read_output[line_nbr][index] = -1
        print(f"Filtered for non-float values: {read_output}")
        return read_output

    def _check_led_states_reading(self, threshold, ledmap, read_line, expected_value_map={}, sparse_match=False):
        """
        Helper method to check LED states reading.

        :param threshold: Threshold for LED states
        :param ledmap: LED map
        :param read_line: Read line
        :param expected_value_map: Dictionary: { LED_1: 1/0 (1 for ON, 0 for OFF), LED_2: 1/0 ...}
        :param sparse_match: Sparse match flag

        Returns:
            matched_for_sparse_match: List of 1/0 values, 1 for ON, 0 for OFF, in place
            where the states are matched for sparse match
        """
        unexpected_states = []
        filtered_line = [
            -1 if index > len(read_line)
            else -1 if float(read_line[index - 1]) == -1
            else 0 if float(read_line[index - 1]) < threshold[0]
            else 1 if float(read_line[index - 1]) > threshold[1]
            else float(read_line[index - 1]) for index in ledmap
        ]
        if expected_value_map:
            matched_for_sparse_match = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            print(f"Filtered for threshold values: {filtered_line}")
            for value, index in zip(filtered_line, ledmap):
                if index not in expected_value_map:
                    continue
                elif value != -1 and not sparse_match and value != expected_value_map[index]:
                    unexpected_states.append(index)
                elif sparse_match and value != -1 and value == expected_value_map[index]:
                    matched_for_sparse_match[index - 1] = 1

        if not expected_value_map:
            return filtered_line
        elif not sparse_match:
            return unexpected_states
        elif sparse_match:
            print(f"INFO pyro client analysis: Matched for sparse match = {matched_for_sparse_match}")
            return [matched_for_sparse_match[led - 1] for led in ledmap]

    def clear_read_buffer(self, rmod_label=""):
        """
        Method to clear read buffer for a given RMOD SN.

        :param rmod_label: RMOD SN for which the check is performed
        """
        print("INFO pyro client analysis(clear_read_buffer): Starting")
        host = self.rmod_led_check_settings[rmod_label]['host_ip']
        host_object = self.all_remote_host_dict[host]
        ledmap = self.rmod_led_check_settings[rmod_label]["LED_NUMBERS"]
        print(f"INFO pyro client analysis: Clearing read buffer for leds {ledmap}")
        host_object["pyro_client_object"].clear_read_output_dict(ledmap, rmod_label)
