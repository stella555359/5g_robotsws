"""
This Module provides the TestlineInformation Object to provide access
to frequently used information from testline configuration.

Usage:

    *** Settings ***
    Library   testline_information.py

    *** Test Cases ***
    Test determine testline deployment type
        Log To Console   TL Deployment: ${TL_INFO.deployment_type(node_id=0, node_type='gnb')}

"""
from robot.libraries import BuiltIn
from robot.libraries.BuiltIn import RobotNotRunningError
import logging
import sys

logger = logging.getLogger()


def get_robot_variable(variable_name):
    """
    Returns the content of the given robot variable name.
    If robot is not running, an AssertionError will be thrown.

    :param variable_name: the robot variable name, i.e. '${tl}'
    """
    robot_builtin = BuiltIn.BuiltIn()
    try:
        return robot_builtin.get_variable_value(variable_name)
    except RobotNotRunningError:
        raise AssertionError("The library taf.ul.hanging_resources should be used in robot tests!")


def get_testline_configuration():
    """
    Returns the testline configuration from the current running robot context.
    If robot is not running, None will be returned.
    This library is to be expected to be used from robot keywords.
    Hence it will throw an Error, if used without a robot run.

    TODO: Give a descriptive error message, if the variable was not found!
    """
    tl_config = get_robot_variable('${tl}')
    assert tl_config is not None, "The test should be run with a testline configuration!"
    return tl_config


class TestlineInformation:
    """
    Data Container for testline information needed to be retrieved.
    """

    def __init__(self):
        self.__tl = None

    @property
    def tl(self):
        if self.__tl is None:
            self.__tl = get_testline_configuration()
        return self.__tl

    def deployment_type(self, node_id=0, node_type='gnb'):
        """
        Returns the testline deployment type depending on the testline configuration.
        """
        nodes = {'gnb': self.tl.gnbs,
                 'enb': self.tl.enbs}[node_type]

        node = nodes[node_id]

        if node.__class__.__name__ == 'ClassicalBts':
            deployment = 'classical'
        elif node.__class__.__name__ == 'RealEnb':
            deployment = 'classical'
        elif node.__class__.__name__ == 'LTEEmuEnb':
            deployment = 'simulated'
        elif node.dus[0].__class__.__name__ == 'VDU':
            deployment = 'aic'
        else:
            if '--dryrun' not in sys.argv:
                logger.warn("Unknown Testline Deployment!")
            deployment = 'unknown'

        return deployment


class testline_information(object):
    """
    Robot listener for creation and maintenance of the global variable ${TL_INFO}
    This class shall only be used to
    - instanciate the variable TL_INFO
    - maintain test suite or test case specific arguments of TL_INFO
    """
    if "--dryrun" not in sys.argv:
        ROBOT_LISTENER_API_VERSION = 3

    def __init__(self):
        if "--dryrun" not in sys.argv:
            self.robot_builtin = BuiltIn.BuiltIn()
            self.ROBOT_LIBRARY_LISTENER = self
            self.tl_info = TestlineInformation()
            self.robot_builtin.set_global_variable('${TL_INFO}', self.tl_info)

    def start_suite(self, data, result):
        pass

    def end_suite(self, data, result):
        pass

    def start_test(self, data, result):
        pass

    def end_test(self, data, result):
        pass
