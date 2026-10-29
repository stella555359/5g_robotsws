import os
import re
import taf.config.scf as config_scf
from robot.api.logger import console

current_scf_path = 'current_scf.xml'
qt_scf_path = 'qt_scf.xml'


def delete_scf_file(path=current_scf_path):
    os.remove(path)


def get_value_from_scf_content(**kwargs):
    scf = config_scf.scf()
    scf.load_scf(current_scf_path)
    return scf.get_value_from_scf(**kwargs)


def get_values_from_scf_content(**kwargs):
    scf = config_scf.scf()
    scf.load_scf(current_scf_path)
    return scf.get_all_values_from_scf(**kwargs)


def get_version_from_scf_content(**kwargs):
    scf = config_scf.scf()
    scf.load_scf(qt_scf_path)
    return scf.get_mo_attribute(**kwargs)


def get_mo_id(scf_path, mo_name):
    """
    Get Managed Object id from SCF file.
    Usage:
    get_mo_id(scf_path, "MRBTS") return MRBTS id (e.g. 1900)
    get_mo_id(scf_path, "RMOD") return RMOD id (e.g. 1)

    :param scf_path: Path to SCF file.
    :type scf_path: str.
    :param mo_name: Managed Object name (e.g. MRBTS, NRBTS, RMOD, etc...)
    :type mo_name: str.
    :return: Managed Object ID.
    :rtype: str.
    """
    with open(scf_path, "r") as f:
        content = f.read()
        mo_id = None
        try:
            mo_id = str(re.search(pattern=r'(?<={0}-)\d+?(?=")'.format(mo_name.upper()), string=content).group())
        except AttributeError:
            console(f"Cannot find {mo_name} object id. None type object is returned")
        return mo_id
