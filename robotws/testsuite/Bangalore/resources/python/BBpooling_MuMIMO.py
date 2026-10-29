from robot.libraries.BuiltIn import BuiltIn, ExecutionFailed
from robot.utils import text as text_utils
import os.path


def check_if_sw_already_exists(path):
    exists = os.path.exists(path)
    return exists
