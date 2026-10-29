import re
import os.path


def get_template_fullname(config_filename):
    _cfg_dir = os.path.dirname(os.path.abspath(__file__))
    _dir_name = 'templates'
    _dir_path = os.path.join(_cfg_dir, _dir_name)
    return os.path.join(_dir_path, config_filename)
