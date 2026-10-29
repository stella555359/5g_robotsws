from sw_info import SWBuildParsing
from robot.api import logger


def _required_basic_flags():
    udp_logging_flag = "0x10041=5\n"
    admin_dev_account_flag = "0x45005a=1\n"
    return [udp_logging_flag, admin_dev_account_flag]


def _required_trunk_flags():
    firewall_feature_flag = "\n0X1A1300=0\n"
    L2PS_parameter_flag = "\n0x590000=8\n"
    CPRT_parameter_flag = "\n0x5800BA=11\n"
    OAM_parameter_for_5G20A_interface_flag = "\n0x190131=0\n"

    ru_detection_1 = "\n0x4F00E1 = 1\n"
    ru_detection_2 = "\n0x420026 = 1\n"
    appDef_check_disable = "\n0x10063=1\n"

    return [firewall_feature_flag, L2PS_parameter_flag, CPRT_parameter_flag, OAM_parameter_for_5G20A_interface_flag,
            ru_detection_1, ru_detection_2, appDef_check_disable]


def _is_stream_800(sw_version):
    return "800" in SWBuildParsing(sw_version).get_stream_number()


def _assure_flags_are_present_in_sw_config(flags, sw_config_addr):
    with open(sw_config_addr, "a+") as swconfig_file:
        current = swconfig_file.readlines()
        missing = [needed for needed in flags if needed not in current]
        for flag in missing:
            logger.console("FLAG: " + flag)
        if missing:
            swconfig_file.write("\n")
        swconfig_file.writelines(missing)


def assure_sw_config_has_proper_flags(sw_ver):
    # required_basic_flags() + required_trunk_flags() if _is_stream_800(sw_ver) else _required_basic_flags()
    req_flags = _required_basic_flags()
    _assure_flags_are_present_in_sw_config(req_flags, "/home/ute/swconfig_from_bts.txt")


def _get_num_of_swconfig_lines():
    with open("/home/ute/swconfig_from_bts.txt") as swconfig:
        return len(swconfig.readlines())


def change_swconfig_file(sw_version):
    """checks if swconfig file was changed by size compare"""
    before = _get_num_of_swconfig_lines()
    assure_sw_config_has_proper_flags(sw_version)
    after = _get_num_of_swconfig_lines()
    return after > before
