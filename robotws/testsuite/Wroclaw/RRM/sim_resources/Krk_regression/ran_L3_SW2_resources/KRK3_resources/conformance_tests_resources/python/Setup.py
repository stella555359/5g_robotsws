from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
import logging


def console(str):
    logger.console(str)
    logging.info(str)


class Setup(object):
    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self
        self.test_status = {}
        self.automaticTeardown = False

    def setTestTeardownFlag(self, flag):
        self.automaticTeardown = flag
        BuiltIn().run_keyword("Set Suite Variable", "${automaticTeardown}")

    def start_test(self, name, attributes):
        self.curTestName = name
        self.failDuToDepend = False

    def depends(self, name):
        test_name_lower_case = name.lower()
        if test_name_lower_case not in self.test_status:
            BuiltIn().log('Test {} depends on TC {} that was not ran'.format(self.curTestName, name), "WARN")
        elif self.test_status[test_name_lower_case] != "PASS":
            self.failDuToDepend = True
            BuiltIn().fail('Test {} depends on TC {} that was FAILED'.format(self.curTestName, name))
        return True

    def end_test(self, name, args):
        status = args['status']
        self.test_status[name.lower()] = status
        if not self.failDuToDepend and self.automaticTeardown in ['True', 'FirstFail']:
            if self.automaticTeardown == 'FirstFail' and status == 'FAIL':
                self.automaticTeardown = False
            BuiltIn().run_keyword("Test Teardown")
