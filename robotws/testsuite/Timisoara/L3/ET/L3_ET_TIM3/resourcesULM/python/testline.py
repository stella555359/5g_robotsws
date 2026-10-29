import struct
import socket
import os
import sys
import unittest
import logging
import re
from types import ModuleType
from robot.api.deco import keyword
from taf.config.testline import RealEnb
from taf.transport.ssh import ssh


def reform_coam_sw_version(version):
    """reform SW Version from COAM GNB to QC required form:
    from 5G19_FSMK_0000_018351_001507 to 5G_0.18351.1507
    from 5G19B_FDD_GNB_0008_001840_000327 to 5G19B_0.1840.327
    from SBTS21B_ENB_0000_210310_000024 to SBTS21B_ENB_0000_210310_000024
    from SBTS21B_ENB_9999_210310_000024 to SBTS00_ENB_9999_210310_000024

    from vDUCNF_0.300.xxx to vDUCNF00_0.300.xxx
    from vDUCNF22R4_0.300.xxx to vDUCNF00_0.300.xxx

    from vCUCNF_0.250.xxx to vCUCNF00_0.250.xxx
    from vCUCNF22R4_0.250.xxx to vCUCNF00_0.250.xxx"""
    subversions = version.split('_')
    if version.startswith('5G'):
        version = strip_version(subversions[-3:])
        if version[0] == '0':
            result = '_'.join(['5G', version])
        else:
            result = '_'.join([subversions[0], version])
    elif version.startswith('SBTS'):
        if subversions[2].startswith('9'):
            subversions[0] = 'SBTS00'
        result = '_'.join(subversions)
    elif version.startswith('vCUCNF'):
        if re.match('vCUCNF([0-9]+R[0-9])?_0', version):
            result = '_'.join(['vCUCNF00'] + subversions[1:])
        else:
            result = version
    elif version.startswith('vDUCNF'):
        if re.match('vDUCNF([0-9]+R[0-9])?_0', version):
            result = '_'.join(['vDUCNF00'] + subversions[1:])
        else:
            result = version
    else:
        raise Exception("Bad software version")
    return result


def strip_version(version):
    """remove 0 from sw version"""
    for i in range(len(version)):
        if version[i].lstrip('0') == '':
            version[i] = '0'
        else:
            version[i] = version[i].lstrip('0')
    return '.'.join(version)


def increment_ip(ip, factor):
    """Author : """
    int_ip = int(struct.unpack('!I', socket.inet_aton(str(ip)))[0])
    new_ip = socket.inet_ntoa(struct.pack('!I', int_ip+int(factor)))
    return new_ip


def get_testline():
    for module in sys.modules.copy().values():
        if type(module) == ModuleType:
            if "tl" in dir(module):
                logging.debug("Debug testline name: " + module.__file__)
                return os.path.basename(os.path.dirname(module.__file__))
    raise Exception('No Testline Module Loaded!')


def get_sysinfo(connection, capu_id=None):
    """
    Get the sysinfo lines filtered with ID_00_MODULE_ID_ for later determination of
    the type of the system module
    :param connection: The alias of the ssh connection
    :param capu_id: The id of the capacity unit. If None, the sysinfo of the main unit is fetched.
    """
    if capu_id is not None:
        command = 'echo "timeout 0.1 sysinfo | grep ID_00_MODULE_ID_" | bsh {}:0'.format(capu_id+1)
    else:
        command = 'timeout 1 sysinfo | grep ID_00_MODULE_ID_'
    result = ssh().execute(command=command, connection=connection, timeout='60 s')
    return result


def identify_module(connection, capu_id=None):
    """
    Identify the module type (ASIB, ASIL, ASOE, ...)
    :param connection: The alias or connection object of the taf.config.ssh connection
    :param capu_id: The id of the capacity unit. If None, the module tpye of the main unit is identified.
    """
    sysinfo_extract = get_sysinfo(connection, capu_id)
    pattern = re.compile(r'ID_00_MODULE_ID_\[(\d)\]=.(A[BS][IO][BEKLMNOP])')
    matches = pattern.search(sysinfo_extract)

    try:
        if matches:
            modules_detected = matches.groups()[1]
            return modules_detected
    except AttributeError:
        pass

    logging.warn("identify_module: Unable to identify system module")


def identify_node_id(output):
    """return nodeid from output of ps -ef | grep CCS_RT"""
    pattern = re.compile(r'nid=(\S{3,})')
    if pattern.search(output):
        return str(int(pattern.search(output).groups()[0], 16))
    pattern = re.compile(r'-n\s(\S{3, })')
    return str(int(pattern.search(output).groups()[0], 16))


def extract_ip(text):
    lines = text.splitlines()
    pattern = re.compile(r'(inet\s|inet\saddr:)(\d+\.\d+\.\d+\.\d+)')
    for line in lines:
        matches = (pattern.search(line))
        try:
            ip = matches.groups()[-1]
            return ip
        except AttributeError:
            pass


def is_realenb(obj):
    return type(obj) == RealEnb


if __name__ == "__main__":
    # Unittest
    class TestTestline(unittest.TestCase):
        def test_increment_ip(self):
            assert increment_ip("128.129.3.4", 1) == "128.129.3.5"
            assert increment_ip("128.129.3.4", 2) == "128.129.3.6"
            # assert increment_ip("128.129.3.256", 2) == "128.129.4.1"    does not work

    unittest.main()
