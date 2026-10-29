# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Gall Anonim
:maintainer: Mateusz Bilewicz
:contact: mateusz.bilewicz@nokia.com
:team: MN_RAN_L2_SW_WRO_7_SG
"""

import os
from robot.libraries.Telnet import Telnet
from contextlib import contextmanager
import re
from ta5g_aashell import ta5g_aashell
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.utilities import logger_console


SCRIPT_PATH = "testsuite/Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO/resources/Python/AaShell/change_flag_value_aashell.sh"


class WrongFlagAaShellGivenException(Exception):
    pass


@contextmanager
def _telnet():
    tel = Telnet()
    tel.open_connection(host="192.168.255.129", port=15007)
    yield tel
    tel.close_all_connections()


def checking_aashell():
    with _telnet() as telnet:
        telnet.write_until_expected_output(text="rad -h", expected="Details:", timeout="5s", retry_interval="0.5s")


def run_aashell_cmd(cmd):
    """Runs given aashell command.

    :param cmd: aashell command, which will be executed
    :return: command output without AaShell prompt
    """
    logger_console(msg="Executing cmd: {}", prefix=" [Console, Aashell] ")
    cmd_output = ta5g_aashell().execute_aashell_command(command=cmd)
    return cmd_output


def set_flags_on_aashell(flags):
    """Sets given flags in aashell in non permament way.

    :param flags: dict, where key is a aashell flag, and its value is value of given flag
                    Ex. {"0x10040": "1", "0x10043": "0xC739", "0x10042": "0xC0A8FF7E"}
    """
    logger_console(msg="Iterating over all given flags and setting them...", prefix=" [Console, Aashell] ")
    for flag in flags:
        logger_console(msg="Setting flag {} to {} - not permament", prefix=" [Console, Aashell] ")
        ta5g_aashell().change_rad_param(param=flag, value=flags[flag], is_permanent=False)


def _is_in_proper_format(param):
    return re.match(r'0x[a-fA-F0-9]+', param)


def change_flag_value_at_aashell(flag=None, value=None, script_path=None):
    global SCRIPT_PATH
    if not script_path:
        script_path = SCRIPT_PATH

    if not _is_in_proper_format(param=flag):
        raise WrongFlagAaShellGivenException("{} is not in hexadecimal format!".format(flag))

    os.system("./{} {} {}".format(script_path, flag, value))
