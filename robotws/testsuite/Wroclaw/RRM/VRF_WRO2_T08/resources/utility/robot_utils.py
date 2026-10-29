from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError
from robot.running.context import EXECUTION_CONTEXTS


def get_robot_library(library):
    instance = BuiltIn().get_library_instance(library)
    if not instance:
        raise ImportError('Unable to access %s instance, check if library is imported' % instance)
    return instance


def get_robot_variable(variable_name, default_value=None):
    return BuiltIn().get_variable_value(f"${{{variable_name}}}", default_value)


def is_robot_running():
    try:
        var_val = get_robot_variable('xxxXfor_sure_not_existsXxxx')
        if var_val is None and EXECUTION_CONTEXTS.current is None:
            return False
        return True
    except RobotNotRunningError:
        return False


def set_robot_test_variable(variable_name, value):
    BuiltIn().set_test_variable(f"${{{variable_name}}}", value)
