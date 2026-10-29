import os
from queue import Queue
from time import time

import testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.cleaners as clean
import testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.sanity_checks as sanity
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.reporting_portal import report_to_reporting_portal
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.robot_utils import get_robot_variable, RobotNotRunningError
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger
from .log_threads import GatheringThread, AnalysisThread
from .meta_test_parser import MetaConfigParser, CommonConfig
from .robot_library import RobotLibrary
from .teardown import Teardown

teardown = Teardown()


class MetaTestInterface(RobotLibrary):
    def __init__(self, config_parser=MetaConfigParser, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.suite_dir = "/tmp"
        self.test_dir = None
        self.suite_time = None
        self.test_time = None
        self.testname = 'default_test'
        self._iterations = (0,)
        self.cfg_parser = config_parser()
        self.cfg = None
        self.common_cfg = CommonConfig()
        self.report_name = 'MetaTest'
        self.report_status = 'failed'

    def suite_setup(self, config=None):
        self.suite_time = time()
        self.load_config(config)
        self.load_robot_outputdir()
        MetaTestInterface.sanity_check_uepc()
        self.sanity_check_vm()

    def load_config(self, config=None):
        if config is None:
            config = TestlineConfiguration().yaml
        self.cfg_parser.parse(config)
        self.common_cfg = self.cfg_parser.common_config

    def load_robot_outputdir(self):
        try:
            self.suite_dir = get_robot_variable("${OUTPUT_DIR}")
        except RobotNotRunningError:
            self.suite_dir = os.getcwd()

    @staticmethod
    def load_robot_testname():
        try:
            return get_robot_variable("${TESTNAME}")
        except RobotNotRunningError:
            return "default_test"

    @staticmethod
    def sanity_check_uepc():
        sanity.kill_uepc_python_processes()

    def sanity_check_vm(self):
        sanity.check_vm_disk_space()
        clean.clear_tmp_if_needed()
        clean.clear_admin_api_logs(self.suite_dir)

    def test_setup(self, testname=None):
        self.test_time = time()
        if testname is None:
            testname = MetaTestInterface.load_robot_testname()
        self.testname = testname
        self.cfg = self.cfg_parser.tests.get(f"tc_{testname}", self.cfg_parser.default)
        self.test_dir = MetaTestInterface._create_subdirectory(testname, self.suite_dir)

    def run(self):
        self._execute_log_threads()

    def _execute_log_threads(self):
        queue = Queue(maxsize=20)
        gather_thread = GatheringThread(self.gather_logs, self._iterations, queue)
        analyze_thread = AnalysisThread(self.analyze_logs, queue)
        gather_thread.start()
        analyze_thread.start()
        try:
            analyze_thread.join()
        finally:
            gather_thread.stop()
            gather_thread.join()
        return analyze_thread.outcome

    def gather_logs(self, iteration):
        raise NotImplementedError

    def analyze_logs(self, logs):
        raise NotImplementedError

    @staticmethod
    def _create_subdirectory(name, root_dir):
        output_subdir = os.path.join(root_dir, name)
        if not os.path.exists(output_subdir):
            os.mkdir(output_subdir)
        return output_subdir

    def print_test_execution_time(self):
        logger.info(f"Test execution took {round((time() - self.test_time) / 60, 2)} min.", also_to_console=True)

    def print_suite_execution_time(self):
        logger.info(f"Suite execution took {round((time() - self.suite_time) / 3600, 2)} h.", also_to_console=True)

    def test_teardown(self):
        try:
            teardown('test')
        finally:
            teardown.reset_test_teardown()
            logger.log_background_messages()
            self.print_test_execution_time()

    def suite_teardown(self):
        try:
            teardown('suite')
        finally:
            teardown.reset_suite_teardown()
            if self.common_cfg.make_report:
                report_to_reporting_portal(self.report_name, self.report_status,
                                           self.common_cfg.hostname, self.common_cfg.tl_type)
            self.print_suite_execution_time()
