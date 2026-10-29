"""
Collector of UE log from Qualcomm UEs. Implements common log collector API. This collector invokes server script on
UE PC and provides client API to be used with qxdm_log_server.py

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration
from .log_collector import UeLogCollector, errors


class QxdmLogCollector(UeLogCollector):
    _server_script_name = 'qxdm_log_server.py'
    _ue_app_id = 'QXDM'
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self, alias='qxdm'):
        super(QxdmLogCollector, self).__init__(alias=alias)
        self.need_hdf_log = True
        self.need_txt_log = True
        self._is_logging_started = False
        self._log_extensions = ['.hdf', '.txt']
        self._log_postfix = '_qxdm'

    def setup(self, with_upload=True, configuration=None):
        self._load_configuration(configuration)
        self._setup_remote_server(with_upload)
        self.hold_licence('QXDM', '5G')
        if self.need_txt_log:
            self.hold_licence('QCAT', '5G')
        self._connect_to_device()

    def shutdown(self, release_licences=True):
        try:
            self._server.shutdown(release_licences)
        except errors.ConnectionClosedError:
            pass
        self.executor.disconnect()
        self._is_logging_started = False

    def _connect_to_device(self):
        self._server.connect_to_qxdm(self.diag_com)

    def set_logging_filter(self, dmc_path_or_filters=None):
        if dmc_path_or_filters is None:
            dmc_path_or_filters = TestlineConfiguration().get_dmc_path()
        self._server.set_log_mask(dmc_path_or_filters)

    def start_log_collecting(self):
        self._server.reset_logging()
        self._server.start_logging()

    def stop_log_collecting(self):
        self._server.stop_logging()
        if self.need_txt_log:
            self._server.convert_hdf_to_txt()

    def get_next_message(self, timeout=100):
        return self._server.get_next_item(timeout)

    def get_all_messages(self):
        message = self._server.get_next_item(10)
        while message is not None:
            yield message
            message = self._server.get_next_item(10)

    def clear_data_queue(self):
        self._server.clear_data_queue()

    def download_log(self, filepath):
        filepath = self._prepare_log_name(filepath)
        hdfs = self._download_hdf_logs(filepath) if self.need_hdf_log else []
        txts = self._download_txt_logs(filepath) if self.need_txt_log else []
        self._server.clear_recent_logs()
        return txts, hdfs

    def _download_hdf_logs(self, filepath):
        hdfs_downloaded = []
        with self.executor:
            for i, log in enumerate(self._server.get_hdf_log_paths()):
                local_path = filepath + '_{}.hdf'.format(i)
                self.executor.download_file(remote_path=log, local_path=local_path)
                hdfs_downloaded.append(local_path)
        return hdfs_downloaded

    def _download_txt_logs(self, filepath):
        txt_downloaded = []
        with self.executor:
            for i, log in enumerate(self._server.get_txt_log_paths()):
                local_path = filepath + '_{}.txt'.format(i)
                self.executor.download_file(remote_path=log, local_path=local_path)
                txt_downloaded.append(local_path)
        return txt_downloaded

    def get_licence(self, app='QXDM', tech='5G'):
        self._server.get_licence(app, tech)

    def hold_licence(self, app='QXDM', tech='5G', hold_minutes=1440):
        self._server.hold_licence(app, tech, hold_minutes)

    def change_licence_refresh_rate(self, new_rate_in_min):
        self._server.change_licence_refresh_rate(new_rate_in_min)

    def release_licence(self, app='QXDM', tech='5G'):
        self._server.release_licence(app, tech)

    def release_all_licences(self):
        self._server.release_all_licences()

    def _prepare_log_name(self, log_prefix):
        if log_prefix.endswith(self._log_extensions[0]) or log_prefix.endswith(self._log_extensions[1]):
            log_prefix = log_prefix[:-4] + self._log_postfix
        else:
            log_prefix += self._log_postfix
        return log_prefix
