"""
Functions for basic VM operations
:author: Marek Starzyk
:maintainer: Marek Starzyk
:contact: marek.starzyk@nokia.com
"""
import os
import socket
import re


def check_hostname():
    host = socket.gethostname().replace("-", "_")
    return host[0: -2] if re.search(r"_\d$", host) else host


def check_if_file_exist(path_to_file):
    return os.path.isfile(path_to_file)


def find_path():
    hostname = check_hostname()
    return f"/home/ute/testline_configuration/{hostname}"


def check_if_mumin_file():
    return f"{find_path()}/mumin.yaml" if check_if_file_exist(f"{find_path()}/mumin.yaml") else None


def init_path():
    return f"{find_path()}/__init__.py" if check_if_file_exist(f"{find_path()}/__init__.py") else None
