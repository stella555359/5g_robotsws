# =====================================================================================================================
# This is a Python File, which helps to get common keywords
# ---------------------------------------------------------------------------------------------------------------------
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
import datetime
import os


def get_log_path():
    log_path = BuiltIn().get_variable_value('${LOG_PATH}', None)
    if log_path is None:
        log_path = os.path.join(BuiltIn().get_variable_value('${OUTPUT_DIR}'),
                                'Logs/{}'.format(datetime.datetime.now().strftime("%Y%m%d%H%M%S%f")))
        BuiltIn().set_suite_variable('${LOG_PATH}', log_path)
    if not os.path.exists(log_path):
        os.makedirs(log_path)
    return log_path
