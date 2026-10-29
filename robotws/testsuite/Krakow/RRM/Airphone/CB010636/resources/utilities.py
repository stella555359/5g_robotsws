"""
:author: Anna Bien
:maintainer: Anna Bien
:owner_email: anna.bien@nokia.com
:team: I_5G_SW_MMW_PLKRK_04
:email: I_5G_SW_MMW_PLKRK_04@nokia.com
"""

import os
import re

from robot.libraries.BuiltIn import BuiltIn

from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import (
    logger_info, logger_warning, logger_debug, logger_console_info
)

from testsuite.Krakow.RRM.Airphone.resources.Python.swconfig import GnbSwconfigManager

from testsuite.Krakow.RRM.Airphone.CB010636.resources.variables import CPLANE_DEBUG_FLAGS


class NotSupportedTestName(Exception):
    pass


def get_log_dir(suite_log_dir=False):
    """
    Get default directory for storing logs.
    """

    output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    if not suite_log_dir:
        try:
            return os.path.join(output_dir, BuiltIn().get_variable_value("${TEST_NAME}"))
        except TypeError:
            logger_info(f'Logs collected in suite logs dir.')
    return os.path.join(output_dir, BuiltIn().get_variable_value("${SUITE_NAME}"))


def get_test_prefix():
    """
    :return: Test prefix extracted from test name in lowercase e.g. 'a_a1_01'`
    """

    test_name = BuiltIn().get_variable_value("${TEST_NAME}")
    prefix_pattern = re.compile('CB010636[-_]\\w*[-_]((\\w*[-_]){1,2}\\d*)[-_]')
    try:
        prefix = re.search(pattern=prefix_pattern, string=test_name).group(1).lower().replace('-', '_')
    except IndexError as group_not_found:
        logger_warning(f'Could not obtain test name prefix!')
        raise NotSupportedTestName(f'Test name: {test_name} does not align with prefix convention') \
            from group_not_found
    logger_debug(f'Test name prefix: {prefix}')
    return prefix


def disable_cprt_debug_logs():
    swconfig = GnbSwconfigManager()
    swconfig.delete_flags_from_swconfig(CPLANE_DEBUG_FLAGS)
