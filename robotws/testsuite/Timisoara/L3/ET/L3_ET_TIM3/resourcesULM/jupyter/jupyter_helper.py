from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError
import importlib
import os
import subprocess
import sys


def get_module_name():
    host_name, _ = subprocess.Popen(['hostname'], stdout=subprocess.PIPE).communicate()
    return host_name.decode('UTF-8').strip().replace('-', '_')


def set_robotws_path(robotws_path):
    if not os.path.exists(robotws_path):
        raise AssertionError("The path does not exist: [{}] path to robotws not found!".
                             format(robotws_path))
    sys.path.append(robotws_path)


def import_config_module(module_name, tl_config_path):
    if not os.path.exists(tl_config_path):
        raise AssertionError("The path does not exist: [{}] repository of testline_configuration not found!".
                             format(tl_config_path))
    sys.path.append(tl_config_path)
    return importlib.import_module(module_name)


def get_host_ip():
    host_ip, _ = subprocess.Popen(['hostname', '-i'], stdout=subprocess.PIPE).communicate()
    return host_ip.decode('UTF-8').strip()


def load_local_testline_config(tl_config_path='/home/ute/testline_configuration'):
    module_name = get_module_name()
    mm = import_config_module(module_name, tl_config_path)
    try:
        BuiltIn().set_suite_variable('${tl}', mm.tl)
    except RobotNotRunningError:
        pass
