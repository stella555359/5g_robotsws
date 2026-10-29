import os
import threading
import codecs
import socket
import sys
import Pyro4
from pathlib import PurePosixPath, PureWindowsPath, PurePath, Path
from datetime import datetime
from sys import platform

DAEMON_HOST = "0.0.0.0"
DAEMON_PORT = 59125
PYRO_SERVER_NAME = "udp_log_capture"
SERVER_VERSION = 1
PYRO_LOGFILE = 'pyro.log'
PYRO_LOGLEVEL = 'DEBUG'
SERIALIZERS_ACCEPTED = ['pickle']
Pyro4.config.SERIALIZERS_ACCEPTED = SERIALIZERS_ACCEPTED
Pyro4.config.REQUIRE_EXPOSE = False
PYTHON_EXEC = "python"

DEFAULT_BASE_OUTPUT_DIR = "C:\\Temp\\Logs"
DEFAULT_IP_ADDRESSES_IP_PORT_LIST = [
    {
        'label': 'RMOD_1',
        'ip': '0.0.0.0',
        'port': 51001
    },
    {
        'label': 'RMOD_2',
        'ip': '0.0.0.0',
        'port': 51002
    }]
DEFAULT_GENERATE_SERVER_LOG = True


class UdpLogCapture(object):
    """
    Class used for collecting syslog traces.
    """
    def __init__(self, base_output_dir=DEFAULT_BASE_OUTPUT_DIR):
        """
        Will configure udp log capture
        :param ip_address_ip_port_list: list of dictionaries, contains each IP and associated port to capture from:
                                        [{'label': 'RMOD_1', 'ip': '0.0.0.0', 'port': 51001},
                                        {'label': 'RMOD_2', 'ip': '0.0.0.0', 'port': 51002}...]
        :param base_output_dir: string, Location on trace pc where to save traces.
        """

        self.capture_threads = []
        self.stop_events = []
        self.output_files = []
        self.output_file_objects = []
        self.LocalPath = PurePosixPath
        self.pltf = 'Linux'
        self.ip_address_ip_port_list = []
        self.base_output_dir = base_output_dir

        self.get_platform_type()
        if self.pltf not in ["Linux", "Windows"]:
            print("ERROR trace server: Unknown platform! Supported: Linux, Windows")
            return False
        self.ip_address_ip_port_list = []

    def get_platform_type(self):
        output = os.popen('uname').read()
        output = str(output).lower()

        if 'linux' in output:
            self.LocalPath = PurePosixPath
            self.pltf = 'Linux'
        elif 'cygwin' in output:
            self.LocalPath = PureWindowsPath
            self.pltf = 'Windows'
        elif platform in ("win32", "cli"):
            self.LocalPath = PureWindowsPath
            self.pltf = 'Windows'
        else:
            self.pltf = ''

    def _start_thread(self, function_name, **function_args):
        self.stop_events.append(threading.Event())
        self.capture_threads.append(threading.Thread(target=function_name, kwargs=function_args))
        self.capture_threads[-1].daemon = True
        self.capture_threads[-1].start()

    def _stop_thread(self, thread_index):
        self.capture_threads[thread_index].join(3.0)
        print("INFO trace server: Capture thread {} succesfully stopped!".format(str(thread_index)))

    def _create_output_files(self, base_dir, ip_addresses_and_ports_list):
        output_file_list = []
        try:
            Path(base_dir).mkdir(parents=True, exist_ok=True)
        except OSError as e:
            print(f"ERROR trace server: Could not create {base_dir}.")
            print(f"Check for disk full, missing user rights or other problems.")
            raise e
        for rmod in ip_addresses_and_ports_list:
            output_file = self.LocalPath(base_dir, f"{rmod['label']}_{rmod['ip']}_{rmod['port']}_UDPLog.txt")
            print(f"INFO trace server: Output file: {output_file}")
            if Path(output_file).is_file():
                current_date_time = datetime.now().strftime("%d.%m.%y__%H_%M_%S")
                new_name = f"old__{current_date_time}__{output_file.name}"
                new_output_file_path = self.LocalPath(output_file.parents[0], new_name)
                Path(output_file).rename(new_output_file_path)
            output_file_list.append(str(output_file))
        print(f"INFO trace server: Output file list {str(output_file_list)}")
        return output_file_list

    def start_traces(self, ip_address_ip_port_list=DEFAULT_IP_ADDRESSES_IP_PORT_LIST):
        """
        Starts all the capturing traces threads, closes trace files.
        """
        self.ip_address_ip_port_list = ip_address_ip_port_list
        print(f"INFO trace server: Ip addresses and ports: {self.ip_address_ip_port_list}")
        output_files = self._create_output_files(self.base_output_dir, self.ip_address_ip_port_list)
        self.output_files = output_files
        for rmod, output_file in zip(self.ip_address_ip_port_list, output_files):
            print(f"INFO trace server: Syslog trace start: IP:{rmod['ip']} Port:{rmod['port']} -> {output_file}")
            self._log_syslog_in_file(ip=rmod['ip'], port=rmod['port'], output_file=output_file)
        for f in self.output_file_objects:
            print(f'INFO trace server: Closed state of file {f} is {f.closed}')
        return True

    def stop_traces(self):
        """
        Stops all the capturing traces threads, closes trace files.
        """
        print("INFO trace server: Stopping all SysLog threads")
        for thread_index in range(len(self.capture_threads)):
            self.stop_events[thread_index].set()
        print("INFO trace server: Waiting all threads stop")
        for thread_index in range(len(self.capture_threads)):
            self._stop_thread(thread_index)
        print("INFO trace server: Closing all log files")
        for f in self.output_file_objects:
            f.close()
        self.output_files.append(str(self.server_log_file))
        return self.output_files

    def _log_syslog_in_file(self, ip, port, output_file):
        """
        Class method meant to write the syslog file locally
        """
        file_to_write = codecs.open(output_file, 'a', encoding='utf-8')
        self.output_file_objects.append(file_to_write)
        print(f"INFO trace server: Starting thread {len(self.stop_events)}: IP {ip} UDP Port {port}")
        self._start_thread(self._start_one_syslog_capture, ip=ip, udp_port=port,
                           FILE=file_to_write, thread_index=len(self.stop_events)-1)

    def _start_one_syslog_capture(self, ip, udp_port, FILE, thread_index):
        """
        Method used for creating a single Syslog capture (one UDP port)
        :param udp_port: listening UDP port number
        :param FILE: capture FILE in which to write syslog info
        :param thread_index: Index for thread number
        """
        sock = socket.socket(socket.AF_INET,  # Internet
                             socket.SOCK_DGRAM)  # UDP
        sock.bind((ip, udp_port))
        while not self.stop_events[thread_index].is_set():
            data_lines = []
            data, addr = sock.recvfrom(8192)
            if data and addr:
                data = data.replace(b"\0", b"")
                data = data.replace(b"\n", b"")
                data = f" [{addr[0]}] {data}"
                data = data.replace("\r", f"\r\n [{addr[0]}] ", (data.count("\r") - 1))
                data_lines = data.split("\r\n")
            for i in range(len(data_lines) - 1):
                current_time = datetime.now().strftime("%d.%m %H:%M:%S.%f")
                FILE.write(f"{current_time} {data_lines[i]}\r\n")
            # case of last element
            current_time = datetime.now().strftime("%d.%m %H:%M:%S.%f")
            FILE.write(f"{current_time} {data_lines[-1]}")
        return True


class OutputHandler(object):
    def __init__(self,
                 baselogfolder=DEFAULT_BASE_OUTPUT_DIR,
                 generate_server_log: bool = DEFAULT_GENERATE_SERVER_LOG):
        r"""
        Wrapper class for stdout.
        Will output stdout to file and a list. Needed because PYRO won't pipe prints from client back to server.
        Is exposed to PYRO by inheritance.
        """
        self.log_path = baselogfolder
        self.terminal = sys.stdout
        self.generate_server_log = generate_server_log
        self.server_log_file = PurePath(
            self.log_path,
            f"server__{self.server_name}__{datetime.now().strftime('%d.%m.%y__%H_%M_%S')}.log"
        )
        if self.generate_server_log:
            if not os.path.isdir(self.log_path):
                os.makedirs(self.log_path)
            self.log = open(self.server_log_file, 'wb', 0)

    def write(self, message):
        if message.find("\n") > -1:
            message_timestamp = f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}]"
            message = message.replace("\n", "\n"+message_timestamp)
        self.terminal.write(message)
        if self.generate_server_log:
            message_log = message.encode("ascii", "ignore")
            self.log.write(message_log)
            self.log.flush()

    def return_logfile(self):
        return None if not self.generate_server_log else self.log.name


class PyroServer(UdpLogCapture, OutputHandler):

    def __init__(self, local_server_name=PYRO_SERVER_NAME,
                 local_daemon_host=DAEMON_HOST,
                 local_daemon_port=DAEMON_PORT,
                 generate_server_log: bool = DEFAULT_GENERATE_SERVER_LOG):
        self.uri = None
        self.server_name = local_server_name
        self.pyro_host = local_daemon_host
        self.pyro_port = local_daemon_port
        self.generate_server_log = generate_server_log
        self.tc = None
        self.daemon = None
        self.is_running = False
        UdpLogCapture.__init__(self)
        OutputHandler.__init__(self, generate_server_log=generate_server_log)
        sys.stdout = self
        print(f"INFO pyro server: server_name = {self.server_name}")
        print(f"INFO pyro server: local_daemon_host = {self.pyro_host} local_daemon_port = {self.pyro_port}")
        pyro_version = self.check_server_pyro_version()
        print(f"INFO pyro server: Pyro version is: {pyro_version}")

    def start_server(self):
        self.daemon = Pyro4.Daemon(host=self.pyro_host, port=self.pyro_port)
        self.uri = self.daemon.register(self, objectId=self.server_name)
        self.is_running = True
        print(f"INFO Pyro server: uri = {self.uri}")
        print(f"INFO Pyro server: {self.server_name} pyro server running {self.running()}")
        self.daemon.requestLoop()

    def stop_server(self):
        self.is_running = False
        self.daemon.shutdown()

    def check_server_pyro_version(self):
        cmd = r'python -u -c "import Pyro4.constants as c; print(c.PROTOCOL_VERSION)"'
        return os.popen(cmd).read().rstrip()

    def running(self):
        return self.is_running


if __name__ == '__main__':
    local_server_name = PYRO_SERVER_NAME if len(sys.argv) < 2 else sys.argv[1]
    local_daemon_host = DAEMON_HOST if len(sys.argv) < 3 else sys.argv[2]
    local_daemon_port = DAEMON_PORT if len(sys.argv) < 4 else int(sys.argv[3])
    generate_server_log = DEFAULT_GENERATE_SERVER_LOG if len(sys.argv) < 5 else sys.argv[4] == "True"
    server = PyroServer(local_server_name, local_daemon_host, local_daemon_port,
                        generate_server_log)
    server.start_server()
    # server.start_traces(DEFAULT_IP_ADDRESSES_IP_PORT_LIST)
    # from time import sleep
    # sleep(20)
    # print(f"INFO: Server running state: {server.running()}")
    # files = server.stop_traces()
    # print(f"Output files: {files}")
    # server.stop_server()
