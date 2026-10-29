import os
import shutil
# from ute_fsmaccess import ute_fsmaccess
from ta5g_pm_counters import ta5g_pm_counters
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.logs_collector_2xgnb import LogsCollector
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CB014023.resources.variables import GNB2_IP
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.file_management import change_file_name


class LogsCollectorWrapper(LogsCollector):
    """
    Inherits from LogsCollector class and provides overridden methods for single gNB.
    """

    def __init__(self):
        super().__init__(GNB2_IP)
        self.default_scf1_filename = 'default_scf_gnb1.xml'
        self.default_scf2_filename = 'default_scf_gnb2.xml'
        self.default_iphy_filename = 'default_iphy.xml'

    def collect_default_scfs(self):
        """
        Save default scfs in suite logs directory.
        Note: Function needs to be called in suite setup.
        """

        self.collect_scfs(
            scf_gnb1_filename=self.default_scf1_filename,
            scf_gnb2_filename=self.default_scf2_filename
        )

    def collect_default_iphy(self):
        """
        Save default iphy in suite logs directory.
        """

        log_dir = self._get_log_dir(suite_log_dir=True)
        self._get_iphy(log_dir)
        change_file_name(
            old_name=os.path.join(log_dir, 'iphy.xml'),
            new_name=os.path.join(log_dir, self.default_iphy_filename)
        )

    def create_test_log_directory(self):
        """
        Clear test log directory if exists.
        Note: Must be executed within test case working space
        """

        logs_path = self._get_log_dir()
        if os.path.exists(logs_path):
            shutil.rmtree(logs_path)
        os.mkdir(logs_path)

    def download_counters_reports(self, counters_type='pm', wait_for_next_interval=True):
        """
        Download RD or PM reports from gNB, e.g. RD.BTS-1.20220929.075500.ANY.xml.gz

        :param counters_type: (str) 'rd' or 'pm'
        :param wait_for_next_interval: (bool)
        """

        pm_counters_instance = ta5g_pm_counters()
        counters_type = counters_type.lower()
        if counters_type == 'rd':
            report_filepath = pm_counters_instance.get_next_unpacked_raw_rd_counters_file(
                output_dirpath=os.path.join(self._get_log_dir(), f'{counters_type}_counters'))
        elif counters_type == 'pm':
            if wait_for_next_interval:
                pm_counters_instance.wait_for_next_full_pm_interval()
            report_filepath = pm_counters_instance.get_latest_unpacked_full_pm_counters_file(
                output_dirpath=os.path.join(self._get_log_dir(), f'{counters_type}_counters'))
        else:
            raise ValueError(f'Not supported value for parameter counters_type: {counters_type}')
        self._validate_if_log_files_exist(
            [f'{counters_type}_counters/{os.path.basename(report_filepath)}']
        )
        return report_filepath
