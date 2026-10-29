from robot.libraries.BuiltIn import BuiltIn


def get_robot_variable(variable_name):
    return BuiltIn().get_variable_value(variable_name)
