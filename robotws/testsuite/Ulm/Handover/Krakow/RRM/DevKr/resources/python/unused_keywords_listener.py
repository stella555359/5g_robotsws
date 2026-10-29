import re
import collections
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger


def _get_robot_context():
    try:
        from robot.running.context import EXECUTION_CONTEXTS
        return EXECUTION_CONTEXTS.current
    except Exception:
        pass
    return None


def _is_dry_run():
    try:
        current_context = _get_robot_context()
        if current_context.dry_run:
            return True
    except Exception:
        pass
    return False


def _is_robot():
    try:
        current_context = _get_robot_context()
        if current_context is not None:
            return True
    except Exception:
        pass
    return False


class unused_keyword_listener(object):
    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self

    def _start_keyword(self, name, attrs):
        try:
            if CONSTANT_HEADERS['expect']['prefix'] in name:
                keyword_variables = re.findall(r'(\$\{.*?\})', name)
                for var in list(set(keyword_variables)):
                    var_value = BuiltIn().get_variable_value(var)
                    # logger.console("{}: {}".format(var, var_value))
                    name = name.replace(var, var_value)
                get_stack().appendleft(name)
        except Exception as e:
            logger.warn('unused_keyword_listener: exception: {}'.format(e))
