from contextlib import contextmanager
from robot.api import logger
from taf.ccs.aashell import aashell as AaShellLib
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
def aashell_context(alias):
    aashell_lib = PythonAaShellLib()
    aashell_lib.create_aashell_cli(name=alias)
    aashell_lib.setup(alias=alias)
    yield aashell_lib
    aashell_lib.teardown(alias=alias)


class ResourceUsage():
    """
    Listens for start and stop of test cases.
    This robot listener is for automatically running tests on not freed resources.
    The current used reources are checked with help of taf.ccs.aashell (get_resource_usage)
    The information is retrieved at start of a test case and at the end of a test case.
    With the end of the test case, the used reosurces are compared with each other.
    By default, the test case will fail, if the resources are different.
    This Robot library has an aditional parameter "fail_on_not_released_resources", which his by
    default set to True.
    """
    if "--dryrun" not in sys.argv:
        ROBOT_LIBRARY_SCOPE = 'GLOBAL'
        ROBOT_LISTENER_API_VERSION = 3

    def __init__(self, fail_on_not_released_resources=True):
        """
        Constructs the resource library robot listener
        :param fail_on_not_released_resources: Flag for enabling or disabling the failing of the test case
        """
        if "--dryrun" not in sys.argv:
            self.fail_on_not_released_resources = fail_on_not_released_resources
            self.ROBOT_LIBRARY_LISTENER = self
            self.level = 'suite'
            self.resources = dict()
        self.is_dryrun = '--dryrun' in sys.argv

    def start_test(self, data, result):
        """
        This function/callback collects the used resources at begin of the test case.
        Only in case of an existing tag "NoResUsag", the resources will not be collected and checked.
        """
        result.parent.metadata.update({'Hidden Checks': 'Detect Hanging Resources - Fail on Error: {}'
                                                        .format(self.fail_on_not_released_resources)})

        self.resources.clear()
        if 'NoResUsage' in data.tags or self.is_dryrun:
            return
        with aashell_context(alias='aashell_resource_usage') as aashell:
            self.resources['start'] = aashell.get_resources_usage(name='aashell_resource_usage')

    def end_test(self, data, result):
        """
        This function/callback collects the used resources at end of the test case.
        The resources between end and start of test cases are compared, the resources for "bufferPoolFreeCount"
        are ignored. If the resources are not matching, the command will produce a warning of will
        fail the test, depending on the libraries argument "fail_on_not_released_resources"
        Only in case of an existing tag "NoResUsag", the resources will not be collected and checked.
        """
        if 'NoResUsage' in data.tags or self.is_dryrun:
            return

        with aashell_context(alias='aashell_resource_usage') as aashell:
            self.resources['end'] = aashell.get_resources_usage(name='aashell_resource_usage')
            try:
                aashell.should_be_equal_as_resources(self.resources['start'],
                                                     self.resources['end'],
                                                     exclude='//bufferPoolFreeCount')

            except AssertionError:
                self.log_used_resources(data.name)
                if self.fail_on_not_released_resources:
                    result.status = "FAIL"
                    raise AssertionError('Resources before and after TC [{}] differ!'.format(data.name))
                else:
                    logger.warn('Resources before and after TC [{}] differ!'.format(data.name))

    def log_used_resources(self, tc_name):
        logger.warn('Resources Before TC {}: {}'.format(tc_name, self.resources['start']))
        logger.warn('Resources After TC {}: {}'.format(tc_name, self.resources['end']))
