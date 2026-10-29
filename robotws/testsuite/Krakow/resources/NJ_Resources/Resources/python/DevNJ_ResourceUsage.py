from contextlib import contextmanager
from robot.api import logger
from taf.ccs.aashell import aashell as AaShellLib
from robot.libraries.BuiltIn import BuiltIn
import json
import sys


class PythonAaShellLib(AaShellLib):

    def __init__(self, **kwargs):
        super(PythonAaShellLib, self).__init__(**kwargs)
        self._aliases = {}

    def set_alias(self, alias, obj):
        self._aliases[alias] = obj

    def get_alias_value(self, alias):
        return self._aliases[alias]

    def _create_builin(self):
        pass


@contextmanager
def aashell_context(alias, tech='5G'):
    aashell_lib = PythonAaShellLib()
    aashell_lib.create_aashell_cli(name=alias)
    aashell_lib.setup(alias=alias)
    yield aashell_lib
    aashell_lib.teardown(alias=alias)


class DevNJ_ResourceUsage():
    """
    The current used resources are checked with help of taf.ccs.aashell (get_resource_usage)
    The information is retrieved at start of a test case and at the end of a test case.
    With the end of the test case, the used resources are compared with each other.
    By default, the test case will fail, if the resources are different.
    This Robot library has an additional parameter "fail_on_not_released_resources", which by
    default set to True.
    """
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self, fail_on_not_released_resources=True):
        """
        :param fail_on_not_released_resources: Flag for enabling or disabling the failing of the test case
        """
        self.fail_on_not_released_resources = fail_on_not_released_resources
        self.resources = dict()
        self.tech = '5G'

    def start_get_resources_usage(self, check_hanging_resouce_flag=False):

        """
        Main Function:
            This function collects the used resources at begin of the test case
        Arguments:
            :param check_hanging_resouce_flag: flag to get resource uages or not, by default is False
        Return Value:
            None
        Examples:
            | Start Get Resources Usage | check_hanging_resouce_flag=${True} |
        Version:
            | Author | Version | Delivery Date | Comments |
            | Wang Cuicui | 1.0.0 | 2022/3/22 | First approved version by VA |

        """

        if not check_hanging_resouce_flag:
            logger.info('\n=====Dont checking hanging resource due to check_resouce_flag = {}====='.format(
                check_hanging_resouce_flag), also_console=True)
            return

        logger.info('\n=====Checking hanging resource due to check_resouce_flag = {}====='.format(
            check_hanging_resouce_flag), also_console=True)
        self.resources.clear()
        with aashell_context(alias='aashell_resource_usage', tech=self.tech) as aashell:
            self.resources['start'] = aashell.get_resources_usage(name='aashell_resource_usage')

    def end_get_resources_usage(self, check_hanging_resouce_flag=False):
        """
        Main Function:
            This function collects the used resources at end of the test case.
            The resources between end and start of test cases are compared, the resources for "bufferPoolFreeCount"
            are ignored. If the resources are not matching, the command will produce a warning of will
            fail the test, depending on the libraries argument "fail_on_not_released_resources"
        Arguments:
            :param check_hanging_resouce_flag: flag to get resource uages or not, by default is False
        Return Value:
            None
        Examples:
            | End Get Resources Usage | check_hanging_resouce_flag=${True} |
        Version:
            | Author | Version | Delivery Date | Comments |
            | Wang Cuicui | 1.0.0 | 2022/3/22 | First approved version by VA |

        """

        if not check_hanging_resouce_flag:
            logger.info('\n=====Dont checking hanging resource due to check_resouce_flag = {}====='.format(
                check_hanging_resouce_flag), also_console=True)
            return

        logger.info('\n=====Checking hanging resource due to check_resouce_flag = {}====='.format(
            check_hanging_resouce_flag), also_console=True)
        with aashell_context(alias='aashell_resource_usage', tech=self.tech) as aashell:
            self.resources['end'] = aashell.get_resources_usage(name='aashell_resource_usage')
            try:
                self.log_used_resources()
                aashell.should_be_equal_as_resources(self.resources['start'],
                                                     self.resources['end'],
                                                     exclude='//bufferPoolFreeCount')
            except AssertionError:
                if self.fail_on_not_released_resources:
                    raise AssertionError('\n=====Resources before and after TC are different!=====')
                else:
                    logger.info('\n=====Resources before and after TC are different!')

    def log_used_resources(self):
        builtin_obj = BuiltIn()
        hanging_resource_log_path = builtin_obj.get_variable_value('${TEST_LOG_DIR}')
        with open('{}/hanging_resource_start.json'.format(hanging_resource_log_path), 'w+') as f:
            json.dump(self.resources['start'], f)
        with open('{}/hanging_resource_end.json'.format(hanging_resource_log_path), 'w+') as f:
            json.dump(self.resources['end'], f)

        logger.info('\n=====Resources Before TC: {}====='.format(self.resources['start']), also_console=True)
        logger.info('\n=====Resources After TC: {}====='.format(self.resources['end']), also_console=True)
