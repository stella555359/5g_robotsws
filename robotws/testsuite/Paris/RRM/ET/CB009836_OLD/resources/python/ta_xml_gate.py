"""
This module provides a gate to install ta_xml during runtime.
The pax variable is modul global, keeping the imported ta_xml library

So instead of using
import ta_xml

You use

tad = None
def import_ta_xml():
    global tax
    tax = ta_xml_gate.install_and_import_ta_xml()

This will install ta_xml if not yet installed in current python installation
"""
from contextlib import contextmanager
from tempfile import gettempdir
import importlib
import os
import pkgutil
import subprocess
tax = None


@contextmanager
def temp_ta_xml_requirements_file():
    requirements = """ta_xml
    """
    requirements_file = os.path.join(gettempdir(), 'ta_xml_requirements.log')
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


def is_ta_xml_installed():
    return bool(pkgutil.find_loader('ta_xml'))


def install_and_import_ta_xml():
    if not is_ta_xml_installed():
        with temp_ta_xml_requirements_file() as requirement_file:
            install_requirements(requirement_file)
    return importlib.import_module('ta_xml')
