from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsAdminApi import BtsAdminApi
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData
from testsuite.Wroclaw.SyVe.RRM.resources.TimeStamp import TimeStamp

GNB_ID = TestEnvData().GNB_ID


class BtsSnapshot(object):

    def collect_snapshot_if_the_test_fails(self):
        """
        Tries to collect snapshot if the test fails
        :return: None
        """
        self._collect_snapshot_if(execution_status_to_be_checked="${TEST_STATUS}",
                                  snapshot_path=TestEnvData().test_log_dir)

    def collect_snapshot_if_the_suite_fails(self):
        """
        Tries to collect snapshot if any test in the suite fails
        :return: None
        """
        self._collect_snapshot_if(execution_status_to_be_checked="${SUITE_STATUS}",
                                  snapshot_path=TestEnvData.OUTPUT_DIR)

    def collect_snapshot(self, snapshot_path):
        """
        Function collects BTS Snapshot using Admin Api
        :return: None
        """
        file_path = self._get_snapshot_filepath_with_current_timestamp(snapshot_path)
        Logger.info("Collecting BTS Snapshot: {}".format(file_path))
        with BtsAdminApi() as api:
            api.get_snapshot(target_file_name=file_path, timeout=600)

    def _collect_snapshot_if(self, execution_status_to_be_checked, snapshot_path):
        from robot.libraries.BuiltIn import BuiltIn
        if BuiltIn().get_variable_value(execution_status_to_be_checked) == "FAIL":
            BtsAdminApi().wait_for_admin_connection_possibility()
            self.collect_snapshot(snapshot_path)

    @staticmethod
    def _get_snapshot_filepath_with_current_timestamp(snapshot_path):
        filename_with_current_timestamp = 'Snapshot_MRBTS-{}_{}.zip'.format(GNB_ID, TimeStamp().file_timestamp)
        return VmOs().join_path_elements(snapshot_path, filename_with_current_timestamp)
