"""
Collector of Snapshot which utilizes taf.sbts.oam.coam.admin library. Implements common log collector API.

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G, AdminLTE
from .log_collector import LogCollector


class SnapshotCollector(LogCollector):
    def __init__(self, alias="snapshot"):
        super(SnapshotCollector, self).__init__(alias=alias)
        self._log_postfix = '_snapshot'
        self._log_extension = '.zip'
        self._cell = None
        self._admin_api = None

    def setup(self):
        pass

    def start_log_collecting(self):
        pass

    def stop_log_collecting(self):
        pass

    def download_log(self, filepath):
        filepath = self._prepare_log_name(filepath)
        with self._admin_api as admin_connection:
            admin_connection.get_snapshot(target_file_name=filepath)
        return filepath

    def shutdown(self):
        pass

    def set_logging_filter(self, filtering=None):
        self._cell = filtering

    def set_admin_context(self, admin_context):
        self._admin_api = admin_context


class Snapshot5GCollector(SnapshotCollector):
    def __init__(self, gnb_id=0, alias='snapshot_5g_collector'):
        super(Snapshot5GCollector, self).__init__(alias=alias)
        self._log_postfix = '_5g_snapshot'
        self._admin_api = Admin5G(gnb_id=gnb_id, alias=alias)


class SnapshotLTECollector(SnapshotCollector):
    def __init__(self, enb_id=0, alias="snapshot_lte_collector"):
        super(SnapshotLTECollector, self).__init__(alias=alias)
        self._log_postfix = '_lte_snapshot'
        self._admin_api = AdminLTE(enb_id=enb_id, alias=alias)
