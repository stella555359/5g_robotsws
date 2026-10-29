from mock import Mock
import sys
import types

module_name = 'robot.libraries.BuiltIn'
robot_builtin = types.ModuleType(module_name)
sys.modules[module_name] = robot_builtin


class BuiltIn(object):
    def get_variable_value(self, *args, **kwargs):
        return 'UTE'


robot_builtin.BuiltIn = BuiltIn
