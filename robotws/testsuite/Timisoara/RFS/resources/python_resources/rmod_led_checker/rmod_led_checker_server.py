import os
import threading
import codecs
import serial
import sys
import Pyro4
from pathlib import PurePosixPath, PureWindowsPath, PurePath, Path
from datetime import datetime
from sys import platform
from time import sleep

DAEMON_HOST = "0.0.0.0"
DAEMON_PORT = 59127
PYRO_SERVER_NAME = "rmod_led_checker"
SERVER_VERSION = 1
PYRO_LOGFILE = 'pyro.log'
PYRO_LOGLEVEL = 'DEBUG'
SERIALIZERS_ACCEPTED = ['pickle']
Pyro4.config.SERIALIZERS_ACCEPTED = SERIALIZERS_ACCEPTED
Pyro4.config.REQUIRE_EXPOSE = False
PYTHON_EXEC = "python"

DEFAULT_BASE_OUTPUT_DIR = "C:\\Temp\\Logs"
DEFAULT_RMOD_LABEL_COM_PORT_DICT = {
    'RMOD_1': {
        'host_ip': '0.0.0.0',
        'host_user': 'rfsharing',
        'host_password': 'Nokia2022!@1',
        'com_port': 'COM6',
        'baud_rate': 115200,
        'LED_NUMBERS': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
        'LED_THRESHOLDS': {0: 10000, 1: 10000},
        'MEASUREMENT_SEPARATOR': ';'
    }
}
DEFAULT_GENERATE_SERVER_LOG = True


class RmodLedChecker(object):
    """
    Class used for collecting syslog traces.
    """
    def __init__(self, base_output_dir=DEFAULT_BASE_OUTPUT_DIR):
        """
        Will configure rmod led checker parameters

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
        self.read_output_dict = {}

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
        print(f"INFO trace server: Capture thread {thread_index} successfully stopped!")

    def _create_output_files(self, base_dir, rmod_label_com_port_dict):
        output_file_list = []
        try:
            Path(base_dir).mkdir(parents=True, exist_ok=True)
        except OSError as e:
            print(f"ERROR trace server: Could not create {base_dir}")
            print("Check for disk full, missing user rights or other problems.")
            raise e
        for rmod_label in rmod_label_com_port_dict:
            output_file = self.LocalPath(
                base_dir,
                f"{rmod_label}_{rmod_label_com_port_dict[rmod_label]['com_port']}_Serial_LED_Log.txt")
            print(f"INFO trace server: Output file: {output_file}")
            if Path(output_file).is_file():
                current_date_time = datetime.now().strftime("%d.%m.%y__%H_%M_%S")
                new_name = f"old__{current_date_time}__{output_file.name}"
                new_output_file_path = self.LocalPath(output_file.parents[0], new_name)
                Path(output_file).rename(new_output_file_path)
            output_file_list.append(str(output_file))
        print(f"INFO trace server: Output file list {output_file_list}")
        return output_file_list

    def remove_multiple_com_ports(self, rmod_label_com_port_dict):
        """
        Remove multiple com ports from the dictionary
        """
        print(f"INFO trace server: RMOD label com port dict = {rmod_label_com_port_dict}")
        elapsed_rmod_label_list = []
        for rmod_label, com_port_dict in rmod_label_com_port_dict.items():
            if rmod_label in elapsed_rmod_label_list:
                continue
            rmod_label_list = []
            print(f"INFO trace server: RMOD label = {rmod_label} com port dict = {com_port_dict}")
            for rmod_label_2, com_port_dict_2 in rmod_label_com_port_dict.items():
                print(f"INFO trace server: RMOD label 2 = {rmod_label_2} com port dict 2 = {com_port_dict_2}")
                if rmod_label_2 != rmod_label and com_port_dict['com_port'] == com_port_dict_2['com_port']:
                    rmod_label_list.append(rmod_label_2)
                    elapsed_rmod_label_list.append(rmod_label_2)
                    print(f"INFO trace server: Will remove label = {rmod_label_2}")
            print("INFO trace server: Creating associated_rmod_labels")
            rmod_label_com_port_dict[rmod_label]['associated_rmod_labels'] = '_'.join(rmod_label_list)
        print("INFO trace server: Removing above labels")
        for rmod_label in elapsed_rmod_label_list:
            del rmod_label_com_port_dict[rmod_label]
        elapsed_rmod_label_list = []
        new_label_dict = {}
        for rmod_label in rmod_label_com_port_dict:
            content = rmod_label_com_port_dict[rmod_label]
            if 'associated_rmod_labels' in content and content['associated_rmod_labels']:
                new_label = rmod_label + '_' + content['associated_rmod_labels']
                print(f"INFO trace server: New label = {new_label} content = {content}")
                new_label_dict[new_label] = content
                elapsed_rmod_label_list.append(rmod_label)
        print("INFO trace server: Removing old labels and adding new ones")
        rmod_label_com_port_dict.update(new_label_dict)
        for rmod_label in elapsed_rmod_label_list:
            del rmod_label_com_port_dict[rmod_label]
            print(f"INFO trace server: Deleted label {rmod_label}")
        return rmod_label_com_port_dict

    def start_traces(self, rmod_label_com_port_dict={}):
        """
        Starts all the capturing traces threads, closes trace files.
        """
        print("INFO trace server: Remove multiple com ports")
        rmod_label_com_port_dict = self.remove_multiple_com_ports(rmod_label_com_port_dict)

        self.rmod_label_com_port_dict = rmod_label_com_port_dict
        print(f"INFO trace server: RMOD labels and com ports: {self.rmod_label_com_port_dict}")
        output_files = self._create_output_files(self.base_output_dir, self.rmod_label_com_port_dict)
        self.output_files = output_files
        self._start_supervisor_thread()
        for rmod_label, output_file in zip(self.rmod_label_com_port_dict, output_files):
            print(f"INFO trace server: Serial LED trace start: RMOD label:{rmod_label}->{output_file}")
            self._log_serial_trace_in_file(
                rmod_label=rmod_label,
                com_port=self.rmod_label_com_port_dict[rmod_label]['com_port'],
                baud_rate=self.rmod_label_com_port_dict[rmod_label]['baud_rate'],
                separator=self.rmod_label_com_port_dict[rmod_label]['MEASUREMENT_SEPARATOR'],
                output_file=output_file
            )
        for f in self.output_file_objects:
            print(f'INFO trace server: Closed state of file {f} is {f.closed}')
        return True

    def stop_traces(self):
        """
        Stops all the capturing traces threads, closes trace files.
        """
        print("INFO trace server: Stopping all serial trace threads")
        for thread_index in range(len(self.capture_threads)):
            self.stop_events[thread_index].set()
        print("INFO trace server: Waiting all threads stop")
        for thread_index in range(len(self.capture_threads)):
            self._stop_thread(thread_index)
        print("INFO trace server: Stopping supervisor thread")
        self._stop_supervisor_thread()
        print("INFO trace server: Closing all log files")
        for f in self.output_file_objects:
            f.close()
        self.output_files.append(str(self.server_log_file))
        return self.output_files

    def get_read_output_dict(self, rmod_label=""):
        """
        Method to get read output dictionary for a given RMOD SN.

        :param rmod_label: RMOD SN for which the check is performed
        :return: Dictionary: { RMOD_SN: [sample1, sample2, ...] }
        """
        result = {}
        if rmod_label:
            found_label = ""
            for label in self.read_output_dict:
                if rmod_label in label:
                    found_label = label
                    break
            if found_label:
                print(f"INFO trace server: Found label = {found_label}")
                result = self.read_output_dict[found_label][:-2:]
        else:
            for label in self.read_output_dict:
                result[label] = self.read_output_dict[label][:-2:]
        return result

    def clear_read_output_dict(self, ledmap, rmod_label=""):
        """
        Method to clear read output dictionary for a given RMOD SN.

        :param ledmap: LED map
        :param rmod_label: RMOD SN for which the check is performed
        """
        labels = self.read_output_dict.keys()
        for label in labels:
            if rmod_label:
                if rmod_label in label:
                    samples_to_be_removed = []
                    for sample_nbr, sample in enumerate(self.read_output_dict[label][:-2:]):
                        for index in ledmap:
                            sample[index-1] = -1
                            check_sample = any([x != -1 for x in sample])
                            if not check_sample:
                                samples_to_be_removed.append(sample_nbr)
                    for sample_nbr in samples_to_be_removed:
                        print(f"INFO trace server: Removing sample {sample_nbr} for label {label}")
                        del self.read_output_dict[label][sample_nbr]
                print(f"INFO trace server: Cleared read output for label {rmod_label}")
                print(f"INFO trace server: Read output {self.read_output_dict[label]}")
            else:
                self.read_output_dict[label] = self.read_output_dict[label][-1::]
                print(f"INFO trace server: Read output {self.read_output_dict[label]}")

    def _log_serial_trace_in_file(self, rmod_label, com_port, baud_rate, separator, output_file):
        """
        Class method meant to write the LED device serial trace into a local file
        """
        file_to_write = codecs.open(output_file, 'a', encoding='utf-8')
        self.output_file_objects.append(file_to_write)
        print(f"INFO trace server: Starting thread {len(self.stop_events)}: COM {com_port} OUT file {output_file}")
        self._start_thread(self._start_one_serial_capture, rmod_label=rmod_label,
                           com_port=com_port, baud_rate=baud_rate, separator=separator,
                           FIL=file_to_write, thread_index=len(self.stop_events) - 1)

    def _start_supervisor_thread(self):
        print("INFO trace server: Starting supervisor thread")
        self.stop_supervisor_event = threading.Event()
        self.supervisor_thread = threading.Thread(target=self._start_supervisor)
        self.supervisor_thread.daemon = True
        self.supervisor_thread.start()

    def _start_supervisor(self):
        while not self.stop_supervisor_event.is_set():
            print(
                f"INFO trace server - supervisor thread: Capture thread number on server "
                f"{str(self.rmod_label_com_port_dict.keys())}: {len(self.capture_threads)}"
            )
            capture_threads_without_end_message = [x for x in self.stop_events if not x.is_set()]
            capture_threads_with_end_message = [x for x in self.stop_events if x.is_set()]
            print(
                f"INFO trace server - supervisor thread: "
                f"{len(capture_threads_without_end_message)} Threads WITHOUT stop event"
            )
            print(
                f"INFO trace server - supervisor thread: "
                f"{len(capture_threads_with_end_message)} Threads WITH stop event"
            )
            print(f"INFO trace server - read output dict: {len(*self.get_read_output_dict().values())}")
            sleep(1)

    def _stop_supervisor_thread(self):
        self.supervisor_thread.join(3.0)
        print("INFO trace server - supervisor thread: Succesfully stopped!")

    def _start_one_serial_capture(self, rmod_label, com_port, baud_rate, separator, FIL, thread_index):
        """
        Method used for creating a single Serial LED trace capture (one COM port)
        :param rmod_label: RMOD label
        :param com_port: listening COM port number
        :param FILE: capture FILE in which to write serial LED trace info
        :param thread_index: Index for thread number
        """
        print(f"INFO trace server: start one serial trace capture {rmod_label} {com_port}")
        try:
            ser = serial.Serial(com_port, baud_rate, timeout=2)
            ser.isOpen()
        except serial.SerialException as e:
            print(f"ERROR trace server {rmod_label} {com_port}: Serial port error: {e}")
            return False
        except Exception as e:
            print(f"ERROR trace server {rmod_label} {com_port}: Unknown error: {e}")
            return False
        print(f"INFO trace server {rmod_label} {com_port}: serial port opened")

        data_lines = ""
        self.read_output_dict[rmod_label] = [[]]
        print(f"Thread stop flag status {rmod_label} {com_port}: {self.stop_events[thread_index].is_set()}")
        while not self.stop_events[thread_index].is_set():
            try:
                data = ser.read()
            except serial.SerialException as e:
                print(f"ERROR trace server {rmod_label} {com_port}: Serial port error: {e}")
                break
            except Exception as e:
                print(f"ERROR trace server {rmod_label} {com_port}: Unknown error: {e}")
                break
            if data:
                # print(f"Trace server {rmod_label} {com_port} Read char from serial port:{data.decode()}")
                data_lines += data.decode()
                data_lines_split = data_lines.split("\r\n")
                if len(data_lines_split) > 1:
                    for i in range(len(data_lines_split) - 1):
                        current_time = datetime.now().strftime("%d.%m %H:%M:%S.%f")
                        FIL.write(f"{current_time} {data_lines_split[i]}\r\n")
                        FIL.flush()
                        print(f"Trace server {rmod_label} {com_port} Read from serial port:{data_lines_split[i]}")
                        if data_lines_split[i].strip():
                            number_list = data_lines_split[i].strip(r"\s"+separator).split(separator)
                            self.read_output_dict[rmod_label].insert(-1, number_list)
                data_lines = data_lines_split[-1]
                number_list = data_lines.strip(r"\s"+separator).split(separator)
                self.read_output_dict[rmod_label][-1] = number_list
        current_time = datetime.now().strftime("%d.%m %H:%M:%S.%f")
        FIL.write(f"{current_time} {data_lines}")
        FIL.flush()
        print(f"Trace server {rmod_label} {com_port} Last from serial port:{self.read_output_dict[rmod_label][-1]}")
        ser.close()
        FIL.close()
        return True


class OutputHandler(object):
    def __init__(self,
                 baselogfolder=DEFAULT_BASE_OUTPUT_DIR,
                 generate_server_log: bool = DEFAULT_GENERATE_SERVER_LOG):
        """
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
            message = message.replace("\n", "\n" + message_timestamp)
        self.terminal.write(message)
        if self.generate_server_log:
            message_log = message.encode("ascii", "ignore")
            self.log.write(message_log)
            self.log.flush()

    def return_logfile(self):
        return None if not self.generate_server_log else self.log.name


class PyroServer(RmodLedChecker, OutputHandler):

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
        RmodLedChecker.__init__(self)
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
#    server.start_traces(DEFAULT_RMOD_LABEL_COM_PORT_DICT)
#    print(f"INFO: Server running state: {server.running()}")
#    from time import sleep
#    sleep(2400)
#    files = server.stop_traces()
#    print(f"Output files: {files}")
#    server.stop_server()
