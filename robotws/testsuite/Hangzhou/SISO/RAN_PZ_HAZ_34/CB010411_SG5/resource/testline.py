import struct
import socket
import os
import sys
import unittest
import logging
import re
from types import ModuleType
from robot.api.deco import keyword


def reform_coam_sw_version(version):
    """reform SW Version from COAM GNB to QC required form:
    from 5G19_FSMK_0000_018351_001507 to 5G_0.18351.1507
    from 5G19B_FDD_GNB_0008_001840_000327 to 5G19B_0.1840.327
    from SBTS21B_ENB_0000_210310_000024 to SBTS21B_ENB_0000_210310_000024
    from SBTS21B_ENB_9999_210310_000024 to SBTS00_ENB_9999_210310_000024"""
    subversions = version.split("_")
    if version.startswith("5G"):
        version = strip_version(subversions[-3:])
        if version[0] == "0":
            result = "_".join(["5G", version])
        else:
            result = "_".join([subversions[0], version])
    elif version.startswith("SBTS"):
        if subversions[2].startswith("9"):
            subversions[0] = "SBTS00"
        result = "_".join(subversions)
    else:
        raise Exception("Bad software version")
    return result


def strip_version(version):
    """remove 0 from sw version"""
    for i in range(len(version)):
        if version[i].lstrip("0") == "":
            version[i] = "0"
        else:
            version[i] = version[i].lstrip("0")
    return ".".join(version)


def identify_oam_type(cmd_output):
    """Author : Jing Liang"""
    if "succeeded" in cmd_output:
        # for kiwi vm output
        return "coam"
    elif "open" in cmd_output:
        # for ute vm output
        return "coam"
    elif "Connected" in cmd_output:
        # for newer ute vm output 19.02.2020
        return "coam"
    elif "No route to host" in cmd_output:
        raise Exception("No route to host or host not reachable")
    else:
        return "cloud_coam"


def increment_ip(ip, factor):
    """Author :"""
    int_ip = int(struct.unpack("!I", socket.inet_aton(str(ip)))[0])
    new_ip = socket.inet_ntoa(struct.pack("!I", int_ip + int(factor)))
    return new_ip


def get_testline():
    for module in list(sys.modules.copy().values()):
        if type(module) == ModuleType:
            if "tl" in dir(module):
                return os.path.basename(os.path.dirname(module.__file__))
    raise Exception("No Testline Module Loaded!")


def identify_module(sysinfo_extract):
    lines = sysinfo_extract.splitlines()
    for line in lines:
        pattern = re.compile(r"ID_00_MODULE_ID_\[(\d)\]=.(A[BS][IO][BEKLO])")
        matches = pattern.search(line)
        try:
            modules_detected = matches.groups()[1]
        except AttributeError:
            pass
    return modules_detected


def identify_node_id(output):
    """return nodeid from output of ps -ef | grep CCS_RT"""
    pattern = re.compile(r"nid=(\S{3,})")
    if pattern.search(output):
        return str(int(pattern.search(output).groups()[0], 16))
    pattern = re.compile(r"-n\s(\S{3, })")
    return str(int(pattern.search(output).groups()[0], 16))


def extract_ip(text):
    lines = text.splitlines()
    pattern = re.compile(r"(inet\s|inet\saddr:)(\d+\.\d+\.\d+\.\d+)")
    for line in lines:
        matches = pattern.search(line)
        try:
            ip = matches.groups()[-1]
            return ip
        except AttributeError:
            pass


if __name__ == "__main__":
    # Unittest
    class TestTestline(unittest.TestCase):
        def test_identify_oam_type(self):
            assert identify_oam_type("succeeded") == "coam"
            assert identify_oam_type("open") == "coam"
            assert identify_oam_type("hallo") == "megazone"
            self.assertRaises(
                Exception, identify_oam_type, "No route to host or host not reachable"
            )

        def test_increment_ip(self):
            assert increment_ip("128.129.3.4", 1) == "128.129.3.5"
            assert increment_ip("128.129.3.4", 2) == "128.129.3.6"
            # assert increment_ip("128.129.3.256", 2) == "128.129.4.1"    does not work

    unittest.main()
