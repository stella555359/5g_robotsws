"""
Collector of Btslog which utilizes taf.sw.syslog library. Implements common log collector API.

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

import os
import shutil
import tempfile

from taf.sw.syslog import syslog

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import \
    TestlineConfiguration

from .log_collector import LogCollector

_tl = TestlineConfiguration()


class BtslogCollector(LogCollector):
    def __init__(self, alias="btslog"):
        super(BtslogCollector, self).__init__(alias=alias)
        self.host_ip = "127.0.0.1"
        self.interface_ip = "192.168.255.126"
        self._api = syslog()
        self._log_postfix = "_SYSLOG"
        self._log_extension = ".LOG"
        self._log_dir = "/tmp"
        self._log_name = "syslog.LOG"
        self._staging_dir = None
        self._staged_log_path = None

    def setup(self):
        pass

    def _clear_staging(self):
        self._staged_log_path = None
        if self._staging_dir and os.path.isdir(self._staging_dir):
            shutil.rmtree(self._staging_dir, ignore_errors=True)
        self._staging_dir = None

    def _find_staged_log_file(self, staging_dir):
        direct = os.path.join(staging_dir, self._log_name)
        if os.path.isfile(direct):
            return direct
        for root, _, files in os.walk(staging_dir):
            for name in files:
                if name == self._log_name or name.upper().endswith(".LOG"):
                    return os.path.join(root, name)
        raise FileNotFoundError(
            "No syslog log file under {!r} (expected {!r} or *.LOG)".format(staging_dir, self._log_name)
        )

    def start_log_collecting(self):
        self._clear_staging()
        self._api.start_syslog(self._log_dir, self._log_name, ip=self.interface_ip, host_ip=self.host_ip,
                               alias=self.alias)

    def stop_log_collecting(self):
        self._clear_staging()
        self._staging_dir = tempfile.mkdtemp(prefix="btslog_{}_".format(self.alias), dir="/tmp")
        self._api.collect_syslog_results(destination=self._staging_dir, unzip=True, alias=self.alias)
        self._staged_log_path = self._find_staged_log_file(self._staging_dir)

    def download_log(self, filepath):
        filepath = self._prepare_log_name(filepath)
        if not self._staged_log_path or not os.path.isfile(self._staged_log_path):
            raise RuntimeError(
                "No staged btslog file for alias {!r}; call stop_log_collecting first.".format(self.alias)
            )
        dest_dir = os.path.dirname(filepath)
        if dest_dir:
            os.makedirs(dest_dir, exist_ok=True)
        shutil.move(self._staged_log_path, filepath)
        self._clear_staging()
        return filepath

    def shutdown(self):
        self._api.teardown_all_aliases_for_syslog()

    def set_logging_filter(self, filtering):
        pass


class Btslog5GCollector(BtslogCollector):
    def __init__(self, alias="btslog_5g"):
        super(Btslog5GCollector, self).__init__(alias=alias)
        self._log_postfix = "_5g_SYSLOG"
        self.host = _tl.get_nr_test_pc_connection_details()["hostname"]


class BtslogLTECollector(BtslogCollector):
    def __init__(self, alias="btslog_lte"):
        super(BtslogLTECollector, self).__init__(alias=alias)
        self._log_postfix = "_lte_SYSLOG"
        self.host_ip = _tl.get_lte_test_pc_connection_details()["hostname"]
