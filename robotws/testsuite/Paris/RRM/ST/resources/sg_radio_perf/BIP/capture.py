import re
import os.path


def log_message(**kwargs):
    return RobotBuiltIn().log(**kwargs)


def get_mirroring_scripts_path():
    _cfg_dir = os.path.dirname(os.path.abspath(__file__))
    dir_name = 'scripts'
    return os.path.join(_cfg_dir, dir_name)


def get_ABIO_mirroring_scripts_path():
    _cfg_dir = os.path.dirname(os.path.abspath(__file__))
    dir_name = 'scripts'
    return os.path.join(_cfg_dir, dir_name)
