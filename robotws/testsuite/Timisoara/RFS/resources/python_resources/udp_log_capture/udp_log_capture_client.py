import os
import functools
import re
import contextlib
import signal
import Pyro4
import taf.transport.ssh as taf_ssh
import traceback
import yaml
from pathlib import Path, PureWindowsPath, PurePosixPath
from time import monotonic, sleep
from udp_log_capture_server import DAEMON_HOST, DAEMON_PORT, PYTHON_EXEC, PYRO_SERVER_NAME, \
    DEFAULT_IP_ADDRESSES_IP_PORT_LIST, DEFAULT_GENERATE_SERVER_LOG

FOLDERS_BLACKLISTED_FROM_TRANSFER = ['__.*__', '\\..*']
FILES_BLACKLISTED_FROM_TRANSFER = ['__.*__', '\\..*']
DEFAULT_FILE_TRANSFER_TIMEOUT = 30
DEFAULT_SSH_TIMEOUT = 90


class UdpLogCaptureTimeoutError(TimeoutError):
    """Raised when Udp Log Capture operation exceeds the specified timeout."""
    pass


# Flag set by the timeout signal handler when SIGALRM fires. Used to convert exceptions
# from underlying libraries (e.g. SSH auth failure after EINTR) into UdpLogCaptureTimeoutError.
_timeout_alarm_fired = False


# Timeout mechanism implemented by Cursor generative AI
def _timeout_signal_handler(signum, frame):
    """Signal handler for SIGALRM: sets flag and raises UdpLogCaptureTimeoutError."""
    global _timeout_alarm_fired
    _timeout_alarm_fired = True
    raise UdpLogCaptureTimeoutError(
        "UDP Log Capture operation timed out (signal SIGALRM, elapsed time exceeded timeout)")


@contextlib.contextmanager
def _udp_log_capture_timeout(timeout):
    """
    Reusable context manager that enforces a wall-clock timeout on the enclosed block.

    - Sets up SIGALRM (Linux only) so that blocking C-level calls are also interrupted.
    - Computes a monotonic deadline used by _check_timeout() for cooperative checks.
    - Converts any non-timeout exception that occurs while the alarm has fired into
      UdpLogCaptureTimeoutError so callers always see a consistent error type.

    Usage::

        with _udp_log_capture_timeout(30) as deadline:
            self._check_timeout(deadline)
            ...  # your code here

    :param timeout: Seconds until the timeout fires, or None for no limit.
    :yields: deadline – absolute monotonic time of expiry, or None when timeout is None.
    :raises UdpLogCaptureTimeoutError: when the timeout is exceeded.
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
    except UdpLogCaptureTimeoutError:
        raise
    except Exception as e:
        if use_signal and _timeout_alarm_fired:
            raise UdpLogCaptureTimeoutError(
                "UDP Log Capture operation timed out (signal SIGALRM, elapsed time exceeded timeout)") from e
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
        except (UdpLogCaptureTimeoutError, TimeoutError):
            raise
        except Pyro4.errors.CommunicationError as e:
            print(f"ERROR: {str(e)}")
            return ""
        except Exception as e:
            print(f"ERROR: {str(e)}")
            traceback.print_exc()
            return ""
    return func


class udp_log_capture_client:

    def __init__(self, vm_source_folder="", pc_target_folder="c:/udp_log_capture",
                 vm_logs_folder="/tmp", upload_code_to_pc: bool = True,
                 pc_pyro_host=DAEMON_HOST, pc_pyro_port=DAEMON_PORT,
                 pyro_server_name=PYRO_SERVER_NAME, generate_server_log=DEFAULT_GENERATE_SERVER_LOG):

        self.all_remote_host_dict = {}
        self.current_host_dict = {}

        self.vm_source_folder = vm_source_folder or os.path.dirname(os.path.realpath(__file__))
        self.pc_target_folder = pc_target_folder
        self.vm_logs_folder = vm_logs_folder
        self.upload_code_to_pc = upload_code_to_pc
        self.pc_pyro_host = pc_pyro_host
        self.pc_pyro_port = pc_pyro_port
        self.pyro_server_name = pyro_server_name
        self.pc_target_application = "udp_log_capture_server.py"
        self.RemotePath = PureWindowsPath
        self.LocalPath = PurePosixPath
        self.generate_server_log = generate_server_log
        self.ip_address_ip_port_list = DEFAULT_IP_ADDRESSES_IP_PORT_LIST
        self.application_parent_folder = ""
        self.application_path = ""
        self.restart_server = True

    def connect_ssh(self, host_object, timeout=None):
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

    def disconnect_ssh(self, host_object):
        if host_object["ssh_session_object"] is not None and host_object["ssh_session_object"].is_connected:
            host_object["ssh_session_object"].disconnect()

    def is_pyro_connected(self, host_object):
        try:
            print(f"INFO pyro client: pyro connected = {host_object['pyro_client_object'].running()}")
            return host_object["pyro_client_object"].running()
        except Exception as e:
            print(f"INFO pyro client: pyro not connected.")
            print(f"INFO pyro message: {e}")
            return False

    def upload_dir(self, current_host_dict, source_path='', destination_path='', timeout=30):
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
                    self.upload_file_to_remote_ssh_host(host_object=self.current_host_dict,
                                                        local_path=path,
                                                        remote_path=destination_path,
                                                        timeout=timeout)
                elif path.is_dir() and self._dir_file_is_not_blacklisted(path):
                    cmd_output = current_host_dict["ssh_session_object"].execute(
                        f'mkdir -p {destination_path.as_posix() / path.name}')
                    print(f'INFO pyro client: mkdir -p {destination_path.as_posix()} output target PC: {cmd_output}')
                    self.upload_dir(current_host_dict, source_path, destination_path)

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

    def connect_pyro(self, host_object):
        """
         Method to start pyro server on remote host and create pyro object used by pyro client to connect.
        """
        print("INFO pyro client: Creating pyro object")
        self._check_pyro_obj(host_object)
        print("INFO pyro client: Check if pyro server is already running")
        pyro_connected = self.is_pyro_connected(host_object)
        if pyro_connected and self.restart_server:
            print(f"INFO pyro client: Pyro server running. Stopping b/c restart_server = {self.restart_server}")
            self.disconnect_pyro(host_object)
            pyro_connected = self.is_pyro_connected(host_object)
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
        self.is_pyro_connected(host_object)

    def _ensure_ssh_connected(self, host_object, timeout=None):
        if not host_object["ssh_session_object"]:
            self.connect_ssh(host_object, timeout=timeout)
        elif host_object["ssh_session_object"]:
            if not host_object["ssh_session_object"].is_connected:
                self.connect_ssh(host_object, timeout=timeout)

    def _check_timeout(self, deadline):
        """
        Raise UdpLogCaptureTimeoutError if deadline has passed.
        :param deadline: Absolute time from monotonic() or None for no timeout
        """
        if deadline is not None and monotonic() >= deadline:
            raise UdpLogCaptureTimeoutError(
                "UDP Log Capture operation timed out (elapsed time exceeded timeout)")

    def upload_file_to_remote_ssh_host(self, host_object, local_path, remote_path, timeout=None):
        self._ensure_ssh_connected(host_object)
        timeout = timeout or DEFAULT_FILE_TRANSFER_TIMEOUT
        return host_object["ssh_session_object"].files.put(local_path=str(local_path),
                                                           remote_path=str(remote_path / local_path.name),
                                                           timeout=timeout)

    def download_file_from_remote_ssh_host(self, host_object, remote_path, local_path, timeout=None):
        self._ensure_ssh_connected(host_object)
        timeout = timeout or DEFAULT_FILE_TRANSFER_TIMEOUT
        print(f"INFO pyro client: downloading: {str(remote_path)} -> {str(local_path / remote_path.name)}")
        return host_object["ssh_session_object"].files.get(remote_path=str(remote_path),
                                                           local_path=str(local_path / remote_path.name),
                                                           timeout=timeout)

    def download_file_list(self, host_object, remote_path_list, local_path, timeout=None):
        timeout = timeout or DEFAULT_FILE_TRANSFER_TIMEOUT
        for remote_file in remote_path_list:
            self.download_file_from_remote_ssh_host(host_object,
                                                    self.RemotePath(remote_file),
                                                    self.LocalPath(local_path),
                                                    timeout=timeout)

    @catch_exception
    def disconnect_pyro(self, host_object):
        host_object["pyro_client_object"].stop_server()

    @catch_exception
    def check_server_pyro_version(self, host_object, repeat_number: int = 3):
        server_pyro = ""
        repeat_index = 0
        output = ""
        while not server_pyro and repeat_index < repeat_number:
            if not self.is_pyro_connected(host_object):
                sleep(3)
                continue
            output = host_object["pyro_client_object"].check_server_pyro_version()
            repeat_index += 1
            sleep(3)
        return output

    def check_client_pyro_version(self):
        cmd = 'python -u -c "import Pyro4.constants as c; print(c.PROTOCOL_VERSION)"'
        output = os.popen(cmd).read().rstrip()
        return output

    def start_udp_traces_for_multiple_hosts(self,
                                            config_yaml_path="",
                                            interfaces_dict="",
                                            log_folder="/tmp",
                                            timeout=300):
        with _udp_log_capture_timeout(timeout) as deadline:
            self._check_timeout(deadline)
            with open(config_yaml_path) as fd:
                udp_log_settings = yaml.safe_load(fd)["UDP_LOG_Settings"]
            print(f"INFO pyro client: udp config file = {str(udp_log_settings)}")
            rmod_labels = [*udp_log_settings.keys()]
            host_dict = {}
            print(f"INFO pyro client: {str(rmod_labels)}")
            for label in rmod_labels:
                if not interfaces_dict[f"RMOD_{label}"]["lmi"]:
                    print(f"INFO pyro client: skipping RMOD_{label} due to no LMI info in __init__.py")
                    continue
                lmi_data = interfaces_dict[f"RMOD_{label}"]["lmi"]
                rmod_data_from_config_yaml = udp_log_settings[f"{label}"]
                print(f"INFO pyro client: RMOD {label} = {str(rmod_data_from_config_yaml)}")
                print(f"INFO pyro client: RMOD {label} IP = {rmod_data_from_config_yaml['ip']}. Updating IP to 0.0.0.0")
                if f'{str(rmod_data_from_config_yaml["ip"]).lower()} ' in ["null ", "none ", " "]:
                    rmod_data_from_config_yaml["ip"] = "0.0.0.0"

                print(f"INFO pyro client: RMOD_{label}:")
                print(f"INFO pyro client: {str(lmi_data)}")

                one_host_dict = host_dict.pop(
                    lmi_data.lmi.host.default_ssh_connection_details.addr,
                    {}
                )
                one_host_dict["username"] = lmi_data.lmi.host.default_ssh_connection_details.username
                one_host_dict["password"] = lmi_data.lmi.host.default_ssh_connection_details.password
                one_host_rmod_list = one_host_dict.pop("rmod_list", [])
                rmod_dict = {
                    "label": label,
                    "ip": rmod_data_from_config_yaml["ip"],
                    "port": rmod_data_from_config_yaml["port"]
                }
                print(f"INFO pyro client: RMOD dict = {str(rmod_dict)}")
                one_host_rmod_list.append(rmod_dict)
                one_host_dict["rmod_list"] = one_host_rmod_list
                host_dict[lmi_data.lmi.host.default_ssh_connection_details.addr] = one_host_dict
            print("INFO pyro client ======================================")
            print(f"INFO pyro client: {str(host_dict)}")
            print("INFO pyro client --------------------------------------")
            for host in host_dict:
                self._check_timeout(deadline)
                folder = Path(log_folder, f"UDP_LOGS_PC_{host}")
                print(f"INFO pyro client: creating local path {folder}")
                if not os.path.isdir(folder):
                    os.makedirs(folder)
                self.start_udp_traces(pyro_server_name=host,
                                      pc_ip=host,
                                      pc_user=host_dict[host]["username"],
                                      pc_password=host_dict[host]["password"],
                                      vm_logs_folder=folder,
                                      ip_address_ip_port_list=host_dict[host]["rmod_list"],
                                      deadline=deadline)

    @catch_exception
    def start_udp_traces(self, pc_ip="", pc_port: int = 22, pc_user="", pc_password="",
                         pc_target_folder="", vm_logs_folder="", pc_pyro_host="",
                         pc_pyro_port="", pyro_server_name="",
                         ip_address_ip_port_list=[], restart_server=True, deadline=300):
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
            "ip_address_ip_port_list": ip_address_ip_port_list or self.ip_address_ip_port_list,
            "ssh_session_object": None,
            "pyro_client_object": None,
            "application_path": application_path or self.application_path,
            "trace_files": []
        }
        print(f"INFO pyro client: host dict = {str(self.current_host_dict)}")
        self._check_timeout(deadline)
        print(f"INFO pyro client: Starting ssh connection to {self.current_host_dict['ip']}")
        self._ensure_ssh_connected(self.current_host_dict)
        self._check_timeout(deadline)
        self.upload_dir(self.current_host_dict, destination_path=self.current_host_dict['target_folder'])
        self._check_timeout(deadline)
        print(f"INFO: Starting pyro server: {self.current_host_dict['ip']} -> {self.current_host_dict['pyro_host']}"
              f" {self.current_host_dict['pyro_port']}")
        self.connect_pyro(self.current_host_dict)
        self._check_timeout(deadline)
        print(f"INFO pyro client: Checking local and server {self.current_host_dict['ip']} Pyro4 version")
        local_pyro = self.check_client_pyro_version()
        print(f"INFO pyro client: Local Pyro4 version: {local_pyro}")
        server_pyro = self.check_server_pyro_version(self.current_host_dict)
        print(f"INFO pyro client: Server Pyro4 version: {server_pyro}")
        if local_pyro != server_pyro:
            print("WARNING pyro client: Local pyro different from server pyro. Application might work abnormally")
        else:
            print("INFO pyro client: Local Pyro4 same version as server Pyro4.")
        self._check_timeout(deadline)
        print(f"INFO pyro client: {self.current_host_dict['ip_address_ip_port_list']}")
        self.current_host_dict["pyro_client_object"].start_traces(self.current_host_dict["ip_address_ip_port_list"])
        self.all_remote_host_dict.update({self.current_host_dict["ip"]: self.current_host_dict})
        self.current_host_dict = {}

    @catch_exception
    def stop_udp_traces(self, logs_folder="", timeout=30):
        with _udp_log_capture_timeout(timeout) as deadline:
            self._check_timeout(deadline)
            print(f"INFO pyro client: all remote hosts {str(self.all_remote_host_dict)}")
            host_objects = list(self.all_remote_host_dict.values())
            for host_object in host_objects:
                try:
                    self._check_timeout(deadline)
                    host_object["vm_logs_folder"] = logs_folder or host_object["vm_logs_folder"]
                    host_object["trace_files"].extend(host_object["pyro_client_object"].stop_traces())
                    print(f"INFO pyro client: Saved trace files {str(host_object['trace_files'])}")
                    self._check_timeout(deadline)
                    self.download_file_list(host_object, host_object['trace_files'],
                                            host_object["vm_logs_folder"], 300)
                    print(f"INFO pyro client: Stopping pyro server on {host_object['ip']}")
                finally:
                    self.disconnect_pyro(host_object)
                    self.disconnect_ssh(host_object)

# if __name__ == "__main__":
#      x = udp_log_capture_client()
#      x.start_udp_traces(pyro_server_name='10.5.53.176', pc_ip='10.5.53.176', pc_port=22, pc_user='rfsharing',
#                         pc_password='Nokia2022!@1',
#                         vm_logs_folder="/home/ute/test_results_vale")
#      x.start_udp_traces(pyro_server_name='10.5.53.43', pc_ip='10.5.53.43', pc_port=22, pc_user='rfsharing',
#                         pc_password='Nokia2022!@1',
#                         vm_logs_folder="/home/ute/test_results_vale")
#      sleep(15)
#      x.stop_udp_traces()
