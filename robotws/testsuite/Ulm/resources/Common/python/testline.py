import struct
import socket
import os
import sys
import unittest
import logging
import re
from types import ModuleType
from taf.config.testline import RealEnb
from taf.transport.ssh import ssh
import ip_utils
import ipaddress

logger = logging.getLogger()


def reform_coam_sw_version(version):
    """reform SW Version from COAM GNB to QC required form:
    from 5G19_FSMK_0000_018351_001507 to 5G_0.18351.1507
    from 5G19B_FDD_GNB_0008_001840_000327 to 5G19B_0.1840.327
    from SBTS21B_ENB_0000_210310_000024 to SBTS21B_ENB_0000_210310_000024
    from SBTS21B_ENB_9999_210310_000024 to SBTS00_ENB_9999_210310_000024"""
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
        if isinstance(module, ModuleType):
            if "tl" in dir(module):
                logging.debug("Debug testline name: " + module.__file__)
                return os.path.basename(os.path.dirname(module.__file__))
    raise Exception('No Testline Module Loaded!')


def get_cpu_ip(connection, board_id, cpu_id):
    """
    Determines the IPv6 address of a specific CPU on a given board.

    This function maps the numeric board ID to its corresponding board name,
    constructs and executes the appropriate command to retrieve the IP address
    for the specified CPU, and validates the resulting IP.

    Args:
        connection: An active SSH connection object used as a proxy for the command execution.
        board_id (int or str): The numeric ID of the board (0 = FCT, 1 = FSP1, 2 = FSP2, 3 = FSP3).
                               Can be passed as integer or string.
        cpu_id (int or str): The ID of the CPU on the board. Can be integer or string.

    Returns:
        str: A validated IPv6 address string associated with the specified board and CPU.

    Raises:
        AssertionError: If no valid IP address could be determined.

    Example:
        >>> ip = get_cpu_ip(connection, board_id=1, cpu_id=0)
        >>> print(ip)
        'fe80::1a2b:3c4d:5e6f:7g8h'
    """

    board = {0: "FCT", 1: "FSP1", 2: "FSP2", 3: "FSP3"}[int(board_id)]

    ip_determination_command = f"backplane-ip -6 -c {cpu_id} {board}"
    backplane_ip_output = ssh().execute(command=ip_determination_command, connection=connection, timeout='60 s')
    ip = extract_ip(backplane_ip_output)

    if not ip_utils.is_valid_ip(ip):
        raise AssertionError(f"No IP could be determined for board {board} cpu {cpu_id}")

    logger.info(f"IP: for board_id {board_id} and cpu_id {cpu_id} is {ip}")
    return ip


def execute_on_cpu(command, connection, board_id, cpu_id):

    ip = get_cpu_ip(connection, board_id, cpu_id)

    board_connection = ssh().connect_to(hostname=ip,
                                        username="toor4nsn",
                                        password="oZPS0POrRieRtu",
                                        proxy=connection)

    logger.info("Executing %s on %s" % (command, ip))
    result = ssh().execute(command)

    ssh().disconnect(connection=board_connection)

    return result


def get_sysinfo(connection, capu_id=None):
    """
    Get the sysinfo lines filtered with ID_00_MODULE_ID_ for later determination of
    the type of the system module
    :param connection: The alias of the ssh connection
    :param capu_id: The id of the capacity unit. If None, the sysinfo of the main unit is fetched.
    """
    if capu_id is not None:
        command = 'timeout 0.1 sysinfo | grep ID_00_MODULE_ID_'
        result = execute_on_cpu(command=command, connection=connection, board_id=int(capu_id)+1, cpu_id=0)
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
    pattern = re.compile(r'ID_00_MODULE_ID_\[(\d)\]=.(A[BS][IO][A-Z])')
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
    """Extract the first valid IPv4 or IPv6 address from a given text string.
    Args:
        text (str): The input text containing potential IP addresses.
    Returns:
        str or None: The first valid IP address found, or None if no valid IP is present.
    """
    line_tokens = text.split()
    for item in line_tokens:
        if len(item) < 1:
            continue
        try:
            ip = ipaddress.IPv6Address(item)
            return str(ip)
        except ipaddress.AddressValueError:
            pass

        try:
            ip = ipaddress.IPv4Address(item)
            return str(ip)
        except ipaddress.AddressValueError:
            pass


def is_realenb(obj):
    return isinstance(obj, RealEnb)


if __name__ == "__main__":
    # Unittest
    class TestTestline(unittest.TestCase):
        def test_increment_ip(self):
            assert increment_ip("128.129.3.4", 1) == "128.129.3.5"
            assert increment_ip("128.129.3.4", 2) == "128.129.3.6"
            # assert increment_ip("128.129.3.256", 2) == "128.129.4.1"    does not work

    unittest.main()
