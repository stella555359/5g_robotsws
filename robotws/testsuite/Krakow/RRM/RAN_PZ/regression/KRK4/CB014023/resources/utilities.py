import os
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.utilities import logger_info


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
