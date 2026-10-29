import os


def check_if_file_exists(file):
    return os.path.isfile(file)


def format_sw_version_for_admin_cli(sw_version):
    gnb_sw_version = sw_version.split('_')
    load = gnb_sw_version[2].lstrip('0')
    branch = gnb_sw_version[3].lstrip('0')
    version = gnb_sw_version[4].lstrip('0')
    return '.'.join([load, branch, version])
