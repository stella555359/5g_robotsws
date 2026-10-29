"""
This module provides a gate to install ta_ssh_telnet during runtime.
The pd variable is modul global, keeping the imported ta_ssh_telnet library

So instead of using
import ta_ssh_telnet

You use

tad = None
def import_ta_ssh_telnet():
    global tad
    tad = ta_ssh_telnet_gate.install_and_import_ta_ssh_telnet()

This will install ta_ssh_telnet if not yet installed in current python installation
"""
from contextlib import contextmanager
from tempfile import gettempdir
import importlib
import os
import pkgutil
import subprocess
tad = None


@contextmanager
def temp_ta_ssh_telnet_requirements_file():
    requirements = """ta_ssh_telnet
    """
    requirements_file = os.path.join(gettempdir(), 'ta_ssh_telnet_requirements.log')
    with open(requirements_file, 'w') as req_file:
        req_file.write(requirements)

    try:
        yield requirements_file
    finally:
        os.remove(requirements_file)


def install_requirements(requirements_file):
    try:
        subprocess.call(['pip', 'install', '--no-deps', '-r', requirements_file])
    except Exception as e:
        raise AssertionError("Error installing requirements " + str(e))


def is_ta_ssh_telnet_installed():
    return bool(pkgutil.find_loader('ta_ssh_telnet'))


def install_and_import_ta_ssh_telnet():
    if not is_ta_ssh_telnet_installed():
        with temp_ta_ssh_telnet_requirements_file() as requirement_file:
            install_requirements(requirement_file)
    return importlib.import_module('ta_ssh_telnet')
