import json
from os import path, rename

from Pyro4 import Proxy, errors
from time import sleep, time
from abc import ABCMeta
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections as connections
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl


class SingletonELTCollector(ABCMeta):
    _instances = {}

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super(SingletonELTCollector, cls).__call__(*args, **kwargs)
        return cls._instances[cls]


class ELTLogCollector:
    __metaclass__ = SingletonELTCollector
    _server_script_name = 'elt_server_script.py'

    def __init__(self, with_initialisation=True, ue_id=0):
        self._python = None
        self._host = None
        self._pyro_port = 9091
        self._local_server_script = None
        self._remote_dir = 'c:/Users/wro5grrm/auto/'
        self._remote_server_script = None
        self._server_uri = None
        self._server = None
        self.diag_com = None
        self.ue_id = ue_id
        self._current_filter = {}
        self._start_log_timestamp, self._stop_log_timestamp = None, None
        self._log_postfix, self._log_extension = '_elt_{}', '.muxraw'
        if with_initialisation:
            self.ue_pc_conn = connections.connect_to_uepc()
            self.initialise_ELT(self.ue_id)

    @logged_keyword
    def collect_elt_logs(self, log_file_path=robot_globals.LOG_FILE_PATH):
        try:
            collected_txt_file = path.join(log_file_path, "logs.txt")
            collected_json_file = path.join(log_file_path, "logs.json")
            self.download_log(log_file_path)
            self.save_human_readable_log(collected_txt_file)
            rename(collected_txt_file, collected_json_file)
            with open(collected_json_file) as j:
                log_data = json.load(j)
            blog("ELT logs have been collected")
            return log_data
        except Exception:
            blog("Cannot collect logs, because ELT is not connected")

    @logged_keyword
    def teardown_elt_logger(self):
        try:
            self.shutdown()
            blog("ELT has been disconected")
        except Exception:
            blog("Cannot teardown ELT, because ELT is not connected")

    @logged_keyword
    def initialise_ELT(self, ue_id):
        self._python = '/cygdrive/c/Python37/python'
        self._host = tl.ues[ue_id].ssh_connection_details.addr
        self._pyro_port = 9091
        self._local_server_script = path.join(path.dirname(path.abspath(__file__)), self._server_script_name)
        self._remote_dir = 'c:/Users/wro5grrm/auto/'
        self._remote_server_script = path.join(self._remote_dir, self._server_script_name)
        self._server_uri = 'PYRO:ELT_LOG_SERVER@{}:{}'.format(self._host, self._pyro_port)
        self._server = Proxy(uri=self._server_uri)

        self.diag_com = tl.ues[ue_id].diag_com
        self._current_filter = {}
        self._start_log_timestamp, self._stop_log_timestamp = None, None
        self._log_postfix, self._log_extension = '_elt_{}', '.muxraw'
        self.ue_pc_conn = connections.connect_to_uepc()
        self.setup()
        self.set_logging_filter()
        blog("ELT has been initialized")

    def setup(self, with_upload=True):
        self.setup_remote_server(with_upload)
        self.connect_to_device()

    def shutdown(self):
        self._server.shutdown()
        self._start_log_timestamp = None
        self._stop_log_timestamp = None
        self._current_filter = {}

    def setup_remote_server(self, with_upload=True):
        if self.is_server_running():
            return
        cmd = '{} {} {} {}'.format(self._python, self._remote_server_script, self._host, self._pyro_port)
        if with_upload:
            self.create_remote_directory()
            self.upload_server_script()
        connections._ssh.send_command(command=cmd, connection=self.ue_pc_conn)
        self.wait_until_server_running(timeout=10)

    def create_remote_directory(self):
        dir_tree = path.join(self._remote_dir, 'logs')
        connections._ssh.execute(command='mkdir -p {}'.format(dir_tree), connection=self.ue_pc_conn)

    def upload_server_script(self):
        connections._ssh.upload_file(remote_path=self._remote_server_script, local_path=self._local_server_script,
                                     connection=self.ue_pc_conn)
        connections._ssh.assert_file_exists(remote_path=self._remote_server_script, connection=self.ue_pc_conn)

    def wait_until_server_running(self, timeout):
        time_threshold = time() + timeout
        while time() < time_threshold:
            if self.is_server_running():
                return True
            sleep(0.5)
        return False

    def is_server_running(self):
        try:
            output = self._server.greetings()
            assert 'hello' in output
        except errors.CommunicationError:
            return False
        except (AssertionError, AttributeError):
            return False
        return True

    def connect_to_device(self):
        blog('DIAG_PORT: ' + str(self.diag_com))
        self._server.connect_to_mediatek(self.diag_com)

    def start_log_collecting(self):
        self._start_log_timestamp = self._server.get_current_timestamp()

    def stop_log_collecting(self):
        self._stop_log_timestamp = self._server.get_current_timestamp()
        self.reset_log_collector()
        self._server.set_time_range(self.diag_com, self._start_log_timestamp, self._stop_log_timestamp)
        self._start_log_timestamp = self._stop_log_timestamp
        self._stop_log_timestamp = None

    def set_logging_filter(self, filtering='ICD_OTA', codes=None):
        codes = [int(code) for code in codes] if codes is not None else []
        if 'ICD' in filtering.upper():
            self._server.subscribe_to_icd(self.diag_com, codes)
            self._current_filter['ICD'] = codes
        if 'OTA' in filtering.upper():
            self._server.subscribe_to_ota(self.diag_com, codes)
            self._current_filter['OTA'] = codes

    def clear_logging_filters(self):
        self._current_filter = {}
        self.reset_log_collector()

    def reset_log_collector(self):
        self._server.reset_log_collector(self.diag_com)
        for filtering, codes in self._current_filter.items():
            self.set_logging_filter(filtering, codes)

    def download_log(self, filepath):
        message = self._server.get_next_message(self.diag_com, 10)
        while message:
            yield message
            message = self._server.get_next_message(self.diag_com, 10)

        filepath = self.prepare_log_name(filepath)
        self._server.save_log_files(self.diag_com)
        logs_to_dl = self._server.get_log_paths(self.diag_com)
        downloaded_logs = []

        for i, log in enumerate(logs_to_dl):
            local_path = filepath.format(i)
            connections._ssh.download_file(log, local_path=local_path, timeout=30, connection=self.ue_pc_conn)
            downloaded_logs.append(local_path)
        self._server.remove_recent_logs(self.diag_com)
        self.reset_log_collector()

    def prepare_log_name(self, log_prefix):
        if not log_prefix.endswith(self._log_extension):
            log_prefix += self._log_postfix + self._log_extension
        return log_prefix

    def save_human_readable_log(self, filepath):
        with open(filepath, 'w') as f:
            all_msgs = [x for x in self.get_all_messages()]
            f.write(json.dumps(all_msgs))
        self.reset_log_collector()

    def get_next_message(self, timeout=100):
        return self._server.get_next_message(self.diag_com, timeout)

    def get_all_messages(self):
        message = self._server.get_next_message(self.diag_com, 10)
        while message:
            yield message
            message = self._server.get_next_message(self.diag_com, 10)
