# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:mantainer: Mateusz Adamek, Anna Bien, Aleksandra Zbieg
:contact: mateusz.adamek@nokia.com, anna.bien@nokia.com, aleksandra.zbieg@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

import os
import paramiko
import traceback
import telnetlib
from robot.api import logger
from robot.libraries.Telnet import Telnet
from contextlib import contextmanager
import re
from ta5g_aashell import ta5g_aashell
from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import logger_console
from testsuite.Krakow.RRM.Airphone.resources.Python.common_gnb import reset_units_and_wait_for_radio_head_online
from testsuite.Krakow.RRM.Airphone.resources.Python.common_airphone import run_on_ap
from taf.rfrl.utilities.robot.general import get_builtin_value


SCRIPT_PATH = "testsuite/Krakow/RRM/Airphone/resources/Python/AaShell/change_flag_value_aashell.sh"
AASHELL_PROMPT = '\nAaShell>'.encode('ascii')


class WrongFlagAaShellGivenException(Exception):
    pass


@contextmanager
def _telnet():
    tel = Telnet()
    tel.open_connection(host="192.168.255.1", port=15007)
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


@contextmanager
def create_ssh_tunnel(telnet_dst_ip, telnet_dst_port, ssh_port=22, gnb_address=None):
    """
    Author: Anna Bien
    Contact: anna.bien@nokia.com
    Creation Date: 11.26.2021
    Modified Date: 24.05.2022

    Create tunnel for telnet over SSH connection.

    :param telnet_dst_ip: Destination IP of target board
    :param telnet_dst_port: Port for telnet connection
    :param ssh_port: Port for SSH connection
    :param gnb_address: IP address of gNB
    """
    tl = get_builtin_value(param_name="tl")
    gnb_address = gnb_address if gnb_address is not None else tl.gnbs[0].cu.oam_ssh_connection_details.addr
    username = tl.gnbs[0].cu.oam_ssh_connection_details.username
    password = tl.gnbs[0].cu.oam_ssh_connection_details.password
    client = paramiko.SSHClient()
    try:
        client.set_missing_host_key_policy(paramiko.MissingHostKeyPolicy())
        client.connect(hostname=gnb_address, username=username, password=password, port=ssh_port)
        transport = client.get_transport()
        tunnel = transport.open_channel('direct-tcpip', (telnet_dst_ip, telnet_dst_port), ('127.0.0.1', 0))
        yield tunnel
    except Exception:
        logger.error(traceback.format_exc())
    finally:
        tunnel.close()
        client.close()


def convert_fs_to_l1b(l1bypass_tag="0x225D:0x524A", ap_abil_boards=1, reset_trigger=True):
    """
    Author: Anna Bien
    Contact: anna.bien@nokia.com
    Creation Date: 11.26.2021
    Modified Date: 24.05.2022

    Function converts Fullstack to L1Bypass. Applicable only for ABIO board.
    Add L1B tag to ABIO board, iphy.xml and swconfig.txt

    :param l1bypass_tag: (string) L1Bypass tags to be set
    :param ap_abil_boards: (int) Number of ABIL boards in AirPhone.
    :param reset_trigger: (bool) Reset should be performed to enable changes.
    """
    if check_if_l1b_is_configured(l1bypass_tag):
        logger.info("L1Bypass already configured - skipping.")
        return True
    change_single_l1b_tag(l1bypass_tag=l1bypass_tag)
    set_l1b_in_iphy_and_swconfig(ap_abil_boards)
    if reset_trigger:
        reset_units_and_wait_for_radio_head_online()
    if not check_if_l1b_is_configured(l1bypass_tag):
        logger.error("Fullstack to L1Bypass conversion finished with errors.")
        return False
    logger.info("Fullstack to L1Bypass conversion finished successfully.", also_console=True)
    return True


def change_single_l1b_tag(gnb_address=None, l1bypass_tag=""):
    """
    Author: Aleksandra Zbieg
    Contact: aleksandra.zbieg@nokia.com
    Creation Date: 24.05.2022
    Modified Date:

    Function changes single L1Bypass tag.

    :param l1bypass_tag: (string) L1Bypass tags to be set
    :param gnb_address: (string) IP address of the gNB
    """

    try:
        with create_ssh_tunnel(telnet_dst_ip='0.0.0.0', telnet_dst_port=15007, gnb_address=gnb_address) as channel:
            telnet_client = telnetlib.Telnet()
            telnet_client.sock = channel
            telnet_client.write('tag -3w app.btsom.nts.L1BypassMap {}\n'.format(l1bypass_tag).encode('ascii'))
            telnet_client.write('quit\n'.encode('ascii'))
    except Exception as e:
        logger.error('Setting L1Bypass tag finished with errors!\n{}'.format(e))
    finally:
        telnet_client.close()


def set_l1b_in_iphy_and_swconfig(ap_abil_boards):
    """
    Author: Aleksandra Zbieg
    Contact: aleksandra.zbieg@nokia.com
    Creation Date: 24.05.2022
    Modified Date:

    Set L1B to true in iphy.xml and swconfig.txt

    :param ap_abil_boards: (int) Number of ABIL boards in AirPhone.
    """
    run_on_ap(r"grep -q 'L1' /rom/simmode/iphy.xml; [ $? -eq 0 ] || "
              r"sed -i -r 's/(.*AutoRebootOnLinkDown.*)/\1\n    <L1Bypass>true<\/L1Bypass>/g' /rom/simmode/iphy.xml")
    run_on_ap(r'grep -q "0x70685={}" /rom/swconfig.txt; [ $? -eq 0 ] || '
              r'echo "0x70685={}  # L1Bypass proxy" >> /rom/swconfig.txt'.format(ap_abil_boards, ap_abil_boards))


def check_if_l1b_is_configured(expected_l1bypass_gnb_tag='', expected_l1bypass_swconfig_tag=1, gnb_address=None):
    """
    Author: Anna Bien
    Contact: anna.bien@nokia.com
    Creation Date: 11.26.2021
    Modified Date: 25.05.2022

    Check if L1Bypass tags are set in aashell, swconfig.txt ang iphy.xml.

    :param expected_l1bypass_gnb_tag: (str) Check if provided tag is set.on gNB
    :param expected_l1bypass_swconfig_tag: (int) Check if provided tag is set in swconfig.txt
    :param gnb_address: (str) IP address of the gNB
    :return : True/False
    """
    if check_l1b_tag_in_aashell(gnb_address, expected_l1bypass_gnb_tag) and \
       check_l1b_in_swconfig_and_iphy(expected_l1bypass_swconfig_tag):
        return True
    return False


def check_l1b_tag_in_aashell(gnb_address, expected_l1bypass_gnb_tag=''):
    """
    Author: Aleksandra Zbieg
    Contact: aleksandra.zbieg@nokia.com
    Creation Date: 25.05.2022
    Modified Date:

    Check if L1Bypass tag is set on gNB aashell.

    :param expected_l1bypass_gnb_tag: (str) Tag that should be set on gNB
    :param gnb_address: (str) IP address of gNB
    :return : True/False
    """
    errors = []
    gnb_output = ''
    telnet_client = telnetlib.Telnet()
    try:
        with create_ssh_tunnel(telnet_dst_ip='0.0.0.0', telnet_dst_port=15007, gnb_address=gnb_address) as channel:
            telnet_client.sock = channel
            telnet_client.write('tag -a\n'.encode('ascii'))
            telnet_client.read_until(match='app.btsom.nts.L1BypassMap'.encode('ascii'), timeout=10)
            gnb_output = telnet_client.read_very_eager()
    except Exception as e:
        errors.append('Checking L1Bypass tag on gNB finished with error: {}'.format(e))
    finally:
        telnet_client.close()
    if not gnb_output:
        errors.append('L1Bypass tag is not configured in gNB')
    elif expected_l1bypass_gnb_tag and expected_l1bypass_gnb_tag not in str(gnb_output):
        errors.append('L1Bypass is configured with tag different than expected {}'.format(expected_l1bypass_gnb_tag))
    if errors:
        logger.info(errors)
        return False
    logger.info('L1Bypass is configured')
    return True


def check_l1b_in_swconfig_and_iphy(expected_l1bypass_swconfig_tag=1):
    """
    Author: Aleksandra Zbieg
    Contact: aleksandra.zbieg@nokia.com
    Creation Date: 25.05.2022
    Modified Date:

    Check if L1Bypass is configured in iphy.xml and swconfig files.

    :param expected_l1bypass_swconfig_tag: (int) Value of swconfig flag
    :return : True/False
    """
    errors = []
    _, iphy_output = run_on_ap('grep \\<L1Bypass\\>true\\<\\/L1Bypass\\> /rom/simmode/iphy.xml')
    if not iphy_output:
        errors.append('L1Bypass tag is not configured in iphy.xml file')
    _, swconfig_output = run_on_ap('grep 0x70685={} /rom/swconfig.txt'.format(expected_l1bypass_swconfig_tag))
    if not swconfig_output:
        errors.append('L1Bypass tag is not properly configured in swconfig.txt file')
    if errors:
        logger.info(errors)
        return False
    logger.info('L1Bypass is configured')
    return True


def set_rad_parameter_via_aashell(rad_param, value, permanent=False):
    """
    Author: Anna Bien
    Contact: anna.bien@nokia.com
    Creation Date: 08.02.2022
    Modified Date:

    Configure R&D parameter using Aashell.

    :param rad_param: (string) R&D parameter tag in hex e.g. 0x57000E
    :param value: (string) R&D parameter value in hex e.g. 0x100010
    :param permanent: (bool) Permanent change of R&D parameter
    """

    telnet_client = telnetlib.Telnet()
    command = 'rad {} {} {}\n'.format('-mwp' if permanent else '-mw', rad_param, value).encode('ascii')
    try:
        with create_ssh_tunnel(telnet_dst_ip='0.0.0.0', telnet_dst_port=15007) as tunnel:
            telnet_client.sock = tunnel
            telnet_client.write(command)
            result = telnet_client.read_until(match=AASHELL_PROMPT, timeout=10)
            logger.info("Command: {} output: {}".format(command, result))
    except Exception:
        logger.error(traceback.format_exc())
    finally:
        telnet_client.close()
    try:
        assert b'written succesfully' in result
    except AssertionError:
        raise RuntimeError('R&D parameter [{}] configuration with value {} has failed'.format(rad_param, value))
    logger.info(
        'R&D parameter [{}] configuration with value {} has finished successfully'.format(rad_param, value),
        also_console=True
    )


def get_rad_parameter_via_aashell(rad_param):
    """
    Author: Anna Bien
    Contact: anna.bien@nokia.com
    Creation Date: 08.02.2022
    Modified Date:

    Get R&D parameter value in hex using Aashell.

    :param rad_param: (string) R&D parameter tag in hex e.g. 0x57000E
    """

    def _parse_rad_parameter_value():
        param_value_regex = re.compile("[[]{}[]] .* = (0x[\\s\\S]+?)\r\n".format(rad_param))
        rad_param_value = param_value_regex.findall(result)[0]
        return rad_param_value

    telnet_client = telnetlib.Telnet()
    domain_dec = int(rad_param[2:4], 16)
    try:
        with create_ssh_tunnel(telnet_dst_ip='0.0.0.0', telnet_dst_port=15007) as tunnel:
            telnet_client.sock = tunnel
            telnet_client.write('rad -rm {} 0\n'.format(domain_dec).encode('ascii'))
            result = telnet_client.read_until(match=AASHELL_PROMPT, timeout=10).decode('ascii')
    except Exception:
        logger.error(traceback.format_exc())
        raise RuntimeError('Getting R&D parameter [{}] value has failed'.format(rad_param))
    finally:
        telnet_client.close()
    return _parse_rad_parameter_value()
