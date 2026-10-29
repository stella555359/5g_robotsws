"""
Collector of UE log from MediaTek UEs. Implements common log collector API. This collector invokes server script on
UE PC and provides client API to be used with elt_log_server.py

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

from .log_collector import UeLogCollector
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration, \
    convert_windows_path_to_cygwin


class EltLogCollector(UeLogCollector):
    _server_script_name = 'elt_log_server.py'
    _ue_app_id = 'ELT'

    def __init__(self, alias='elt'):
        super(EltLogCollector, self).__init__(alias=alias)
        self._current_filter = {}
        self._log_extension = '.json'
        self._log_postfix = '_elt_{}'

    def setup(self, with_upload=True, configuration=None):
        self._load_configuration(configuration)
        self.elt_database = TestlineConfiguration().get_elt_database_path()
        self.python = self.python.replace('27', '27-32bit')
        self._setup_remote_server(with_upload)
        self._connect_to_device()

    def shutdown(self):
        self._server.shutdown()
        self.executor.disconnect()
        self._current_filter = {}

    def _connect_to_device(self):
        self._server.connect_to_mediatek(self.diag_com, self.elt_database)

    def start_log_collecting(self):
        self.reset_log_collector()
        self._server.start_log_collecting(self.diag_com)

    def stop_log_collecting(self):
        self._server.stop_log_collecting(self.diag_com)

    def reset_log_collector(self):
        self._server.reset_log_collector(self.diag_com)

    def download_log(self, filepath):
        filepath = self._prepare_log_name(filepath)
        self._server.save_log_files(self.diag_com)
        logs_to_dl = self._server.get_log_paths(self.diag_com)
        downloaded_logs = []
        with self.executor as ue_pc:
            for i, log in enumerate(logs_to_dl):
                local_path = filepath.format(i)
                ue_pc.download_file(log, local_path=local_path, timeout=30)
                downloaded_logs.append(local_path)
        self._server.remove_recent_logs(self.diag_com)
        self.reset_log_collector()
        return downloaded_logs

    def set_logging_filter(self, filtering='ICD_OTA', codes=None):
        if 'SYS' in filtering.upper():
            self._server.subscribe_to_sys(self.diag_com, [codes])
            self._current_filter['SYS'] = [codes]
        else:
            codes = [int(code) for code in codes] if codes is not None else []
        if 'ICD' in filtering.upper():
            self._server.subscribe_to_icd(self.diag_com, codes)
            self._current_filter['ICD'] = codes
        if 'OTA' in filtering.upper():
            self._server.subscribe_to_ota(self.diag_com, codes)
            self._current_filter['OTA'] = codes

    def send_at_command(self, command):
        self._server.send_at_command(self.diag_com, command)

    def send_pcommand(self):
        self._server.send_pcommand(self.diag_com)

    def set_ip(self, serial_number=None):
        messages = self._server.inspect_queue(self.diag_com)
        for trace in messages:
            data = trace['data']
            if "+CGPADDR:" in data:
                ip_addr = data.split("\"")[1].strip()
                return self._server.set_ip(self.diag_com, ip_addr, serial_number)
        raise ValueError("Could not set IP, +CGPADDR SYS TRACE has not been found")
