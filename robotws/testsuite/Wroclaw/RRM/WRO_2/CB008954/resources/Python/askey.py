from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from robot.libraries.BuiltIn import BuiltIn
from moler.util.moler_test import MolerTest
from moler.exceptions import CommandFailure
from moler.device import DeviceFactory
import re


def _get_ue_config():
    tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
    return tl.ues[0]["UE_POOLS"]["AndroidUePool"]["inline_config"]["AT_BASED_UE_1"]["CONSTRUCTOR_PARAMETERS"]


ue_config = _get_ue_config()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def reboot_askey(sleep_value=180, check_address=False, subnet=None, interface_name=None):
    """
    Reboot Askey UE by using moler device.
    ue_confing.yaml is required and it should start with following keywords:

    UE_POOLS:
        AndroidUePool:
            inline_config:
                AT_BASED_UE_1:
                    CAPABILITIES:
                        - REAL_UE
                        - REAL_ANDROID_UE
                    CLASS: QualcommNoLicenseUe
                    CONSTRUCTOR_PARAMETERS:

    :param sleep_value: int, amount of time to get full capability back aftear reboot
    :param check_address: bool, check if UE get ip address from subnet
    :param subnet: str, the first three octets of the expected subnet in decimal e.g. "10.84.170"
    :param interface_name: str, UE's Interface name e.g. "Ethernet 8"
    :return:
    """
    device_pc = DeviceFactory.get_cloned_device("GNB0", "GNB0_UE_PC", initial_state="PROXY_PC")
    cmd_ssh = device_pc.get_cmd(cmd_name="ssh",
                                cmd_params={"login": ue_config["configuration"]["login"],
                                            "password": ue_config["configuration"]["password"],
                                            "host": ue_config["configuration"]["ue_pc_ip"],
                                            "expected_prompt": ".*",
                                            "options": '-o ServerAliveInterval=7 -o ServerAliveCountMax=15'})

    cmd_reboot = device_pc.get_cmd(cmd_name="bash",
                                   cmd_params={"bash": "adb -s {} reboot".format(ue_config["serial_number"]),
                                               "prompt": ".*"})

    cmd_exit = device_pc.get_cmd(cmd_name="exit", cmd_params={"expected_prompt": "ute.*"})

    cmd_netsh = device_pc.get_cmd(
        cmd_name="run_script",
        cmd_params={"script_command": 'netsh interface ipv4 show addresses {}'.format(interface_name),
                    "success_regex": (re.compile(r"IP\sAddress:\s+{}\.\d+".format(subnet))),
                    "prompt": "InterfaceMetric"})

    cmd_reboot_retry = device_pc.get_cmd(cmd_name="bash",
                                         cmd_params={"bash": "adb -s {} reboot".format(ue_config["serial_number"]),
                                                     "prompt": ".*"})

    cmd_netsh_retry = device_pc.get_cmd(cmd_name="run_script",
                                        cmd_params={"script_command": 'netsh interface ipv4 show addresses {}'
                                                                      ''.format(interface_name),
                                                    "success_regex": (
                                                        re.compile(r"IP\sAddress:\s+{}\.\d+".format(subnet))),
                                                    "prompt": "InterfaceMetric"})
    cmd_ssh(timeout=300)
    cmd_reboot(timeout=120)
    MolerTest.sleep(int(sleep_value))  # Wait until UE gets full capability back.
    if check_address:
        try:
            cmd_netsh(timeout=120)
        except CommandFailure:
            MolerTest.warning("UE did not get an IP address from the expected subnet: '{}'".format(subnet))
            cmd_reboot_retry(timeout=120)
            MolerTest.info('UE reboot as recovery action performed')
            MolerTest.sleep(int(sleep_value))
            cmd_netsh_retry(timeout=120)
    cmd_exit(timeout=120)
