"""
:copyright: Nokia Networks
:author: Damian Piasecki
:maintainer: Damian Piasecki
:contact: damian.piasecki@nokia.com
:team: MN_RAN_RD_VRF_KRK_11
"""

from taf.config.scf import scf

from variables import *

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import (
 logger_info,
 logger_console_info
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import (
    get_latest_file
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python import common_gnb
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn


def get_default_log_dir():
    """
    The function to get default directory for storing logs

    :return: (str) Path to the default directory for storing logs
    """
    try:
        return os.path.join(OUTPUT_DIR, SUITE_NAME, BuiltIn().get_variable_value("${TEST_NAME}"))
    except TypeError:
        logger_info('TEST_NAME variable is not available')
    return os.path.join(OUTPUT_DIR, SUITE_NAME)


def set_proper_vlan_id_in_base_scf(scf_path):
    """
    The function to set proper VLAN ID in the base SCF file

    :param scf_path: (str) Path to the SCF file
    """
    dist_name = "MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1"
    vlan_id = common_gnb.get_parameter_value_from_scf(dist_name=dist_name, parameter="vlanId")
    taf_scf_instance = scf()
    taf_scf_instance.load_scf(file_path=scf_path)
    taf_scf_instance.modify_scf_element(dist_name=dist_name, p_name="vlanId", value=vlan_id)
    taf_scf_instance.save_scf(file_path=scf_path)
    logger_console_info(f"SCFs: Vlan ID reconfigured to {vlan_id}")


def add_ccs_decode_to_wireshark():
    """
    The function to add CCS decode to Wireshark
    """
    basic_wireshark_path = "/usr/lib/x86_64-linux-gnu/wireshark/plugins"
    latest_path = get_latest_file(os.path.join(basic_wireshark_path, "*.*/epan"))
    ccs_decode = BuiltIn().get_variable_value("${CCS_DECODE_PATH}")
    OperatingSystem().run(f"sudo cp {ccs_decode} {latest_path}")
