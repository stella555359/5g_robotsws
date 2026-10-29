import datetime
import os
from pathlib import Path


class LogStore(object):
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        self._suite_log_folder = ''
        self._test_log_folder = ''
        self._test_gnb_pcap_file = ''
        self._test_wts_pcap_file = ''
        self._gnb_collector = ''
        self._gnb_pdml = ''
        self.is_gnb_pcap_collected = False
        self.is_wts_pcap_collected = False

    def create_suite_log_folder(self, log_dir, suite_name):
        timestamp = datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
        suite_folder = "Logs-{}-{}".format(suite_name, timestamp)
        suite_log_folder = os.path.join(log_dir, suite_folder)
        os.mkdir(suite_log_folder)
        self.set_suite_log_folder(suite_log_folder)
        return

    def get_suite_log_folder(self):
        if not self._suite_log_folder:
            raise AssertionError('Suite Log Folder is not set')
        return self._suite_log_folder

    def set_suite_log_folder(self, suite_log_path):
        self._suite_log_folder = suite_log_path
        return

    def create_test_case_folder(self, test_case_path):
        testcase_folder = os.path.join(self.get_suite_log_folder(), test_case_path)
        os.mkdir(testcase_folder)
        self.set_test_log_folder(testcase_folder)

    def get_test_log_folder(self):
        if not self._test_log_folder:
            raise AssertionError('TestLog Folder is not set')
        return self._test_log_folder

    def set_test_log_folder(self, test_log_path):
        self._test_log_folder = test_log_path
        return

    def create_gnb_pcap_file(self, collector_name):
        self.set_gnb_pcap_collector(collector_name)
        gnb_pcap_file_path = Path(self.get_test_log_folder()) / collector_name / f"{collector_name}.pcap"
        self.set_gnb_pcap(gnb_pcap_file_path)
        return

    def get_gnb_pcap(self):
        return self._test_gnb_pcap_file

    def set_gnb_pcap(self, gnb_pcap_file):
        self._test_gnb_pcap_file = gnb_pcap_file
        print("gnb_pcap_file: ", self._test_gnb_pcap_file)
        return

    def set_gnb_pcap_collector(self, collector):
        self._gnb_collector = collector
        return

    def get_gnb_collector(self):
        return self._gnb_collector

    def set_gnb_pdml(self, pdml_file):
        self._gnb_pdml = pdml_file
        return

    def get_gnb_pdml(self):
        return self.gnb_pdml

    def get_wts_pcap(self):
        return self._test_wts_pcap_file

    def set_wts_pcap(self, wts_pcap):
        self._test_wts_pcap_file = wts_pcap

    def set_is_gnb_pcap_collected(self, value):
        self.is_gnb_pcap_collected = value

    def get_is_gnb_pcap_collected(self):
        return self.is_gnb_pcap_collected

    def set_is_wts_pcap_collected(self, value):
        self.is_wts_pcap_collected = value

    def get_is_wts_pcap_collected(self):
        return self.is_wts_pcap_collected
