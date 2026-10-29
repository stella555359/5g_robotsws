from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.facade import LogCollectorFacade
from .robot_library import RobotLibrary
from .teardown import Teardown


_teardown = Teardown()


class LogCollector(RobotLibrary):
    def __init__(self):
        super().__init__()
        self._verification_logs = LogCollectorFacade()
        self._test_logs = LogCollectorFacade()

    def add_verification_collector(self, collector, alias):
        self._verification_logs.add_collector(collector, alias)

    def add_test_collector(self, collector, alias):
        self._test_logs.add_collector(collector, alias)

    def setup_all_collectors(self):
        self.setup_test_collectors()
        self.setup_verification_collectors()

    def setup_verification_collectors(self):
        self._verification_logs.setup_log_collectors()
        _teardown.schedule_test_teardown_function('Teardown verification collectors',
                                                  self._verification_logs.shutdown_log_collectors, [])

    def setup_test_collectors(self):
        self._test_logs.setup_log_collectors()
        _teardown.schedule_test_teardown_function('Teardown test collectors',
                                                  self._test_logs.shutdown_log_collectors, [])

    def start_verification_collectors(self):
        self._verification_logs.start_log_collecting()
        _teardown.schedule_test_teardown_function('Stop verification collectors',
                                                  self._verification_logs.stop_log_collecting, [])

    def start_test_collectors(self):
        self._test_logs.start_log_collecting()
        _teardown.schedule_test_teardown_function('Stop test collectors', self._test_logs.stop_log_collecting, [])

    def stop_verification_collectors(self):
        self._verification_logs.stop_log_collecting()
        _teardown.recall_test_teardown_function('Stop verification collectors')

    def stop_test_collectors(self):
        self._test_logs.stop_log_collecting()
        _teardown.recall_test_teardown_function('Stop test collectors')

    def download_verification_logs(self, log_prefix):
        return self._verification_logs.download_logs(log_prefix=log_prefix)

    def download_test_logs(self, log_prefix):
        return self._test_logs.download_logs(log_prefix=log_prefix)

    def teardown_all_collectors(self):
        self.teardown_verification_collectors()
        self.teardown_test_collectors()

    def teardown_verification_collectors(self):
        self._verification_logs.shutdown_log_collectors()
        _teardown.recall_test_teardown_function('Teardown verification collectors')

    def teardown_test_collectors(self):
        self._test_logs.shutdown_log_collectors()
        _teardown.recall_test_teardown_function('Teardown test collectors')
