import socket
import os
import imp
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError


def _validate_file(filepath):
    assert os.path.isfile(filepath), "FileNotFoundError: [Errno 2] No such file or directory: {}".format(filepath)
    return filepath


def import_testline_configuration_file():
    filepath = _validate_file("/home/ute/testline_configuration/{tl_name}/__init__.py".format(
            tl_name=socket.gethostname().replace('-', '_')))
    imp.load_source('tl_file', filepath)
    from tl_file import tl
    return tl


def import_selected_testline_configuration_file(tl_name):
    filepath = _validate_file("/home/ute/testline_configuration/{}/__init__.py".format(tl_name))
    imp.load_source('tl_file', filepath)
    from tl_file import tl
    return tl


try:
    tl = BuiltIn().get_variable_value("${tl}")
except RobotNotRunningError:
    tl = import_testline_configuration_file()
