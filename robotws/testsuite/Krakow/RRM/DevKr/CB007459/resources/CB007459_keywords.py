"""
:copyright: Nokia Networks
:author: Marek Kieltyka <marek.kieltyka@nokia.com>, Dawid Chuchnowski <dawid.chuchnowski@nokia.com>
:maintainer: Marek Kieltyka <marek.kieltyka@nokia.com>, Dawid Chuchnowski <dawid.chuchnowski@nokia.com>
"""

import logging
import time

from ta_egate_cmd_parser import ta_egate_cmd_parser
from ta5g_egate.interface import ta5g_egate
from ta5g_admin_operations import ta_admin_interface
from robot.api.deco import keyword
from robot.errors import ExecutionFailed
from ta_messaging.message_sources.message_sources_tshark_based import configure_iphy_interfaces
from ta_messaging.message_sources.message_sources_tshark_based import restore_default_iphy_interfaces
from ta_messaging.alias_factory import get_alias_factory


@keyword("Verify ${traffic_rate}MBps ${direction} traffic on ${bearer_type} split bearer-${bearer_id} for UE${ue_id}")
def verify_dc_bearer_traffic(traffic_rate, direction, bearer_type, bearer_id, ue_id):
    """
    Check average traffic rate on DC bearer
    :param traffic_rate: expected average traffic rate
    :param direction: dl|ul|bi
    :param bearer_type: all|mcg|scg
    :param bearer_id:
    :param ue_id:
    :return:
    """
    MBPS_1 = 1000000
    traffic_rate = int(traffic_rate) * MBPS_1
    ta_egate = ta_egate_cmd_parser()
    cmd = ta_egate.get_command('bearer_stats')
    bearer_stats_out = cmd(ue=ue_id, id=bearer_id, dir=direction, dc_cell_group=bearer_type).execute_and_parse()
    avg_data_rate = int(bearer_stats_out['Average data rate']['Value'].split('(')[0])
    if traffic_rate * 0.8 < avg_data_rate < traffic_rate * 1.2:
        logging.info('Average data traffic rate occurred as expected - equals to {} '.format(avg_data_rate))
    else:
        raise AssertionError('Unexpected average data traffic rate - equals to {} '.format(avg_data_rate))


def reach_onair_and_wait_for_x2_link_establishment(lua_cfg, logs_dirpath=None, timeout=1200, check_version=True):
    """
    Start egate service using .lua config file
    :param lua_cfg: File path of .lua config file
    :param logs_dirpath:
    :param timeout:
    :param check_version:
    :return:
    """
    ta5g_egate_interface = ta5g_egate()
    ta5g_egate_interface.start_wts_and_store_config_file_in_logs_dir(lua_cfg=lua_cfg,
                                                                     logs_dirpath=logs_dirpath,
                                                                     align_tac_values=False)
    wait_for_x2_link_established(timeout=timeout, check_version=check_version)


def enable_ue_capture_on_simulated_enb(enable=True):
    """
    Enable expectations in ta_messaging for AirPhone UEs RRC flow
    +------------------+-------+------------+------------+
    |     Example                                        |
    +==================+=======+============+============+
    | Enable UE Capture On Simulated Enb  enable=${True} |
    | Create UEs alias  alias=UE  id_type=wts            |
    | Expect Message Flow                                |
    | ...  UE_1:RRC_RRCConnectionReconfiguration         |
    | ...  alias=your_flow_alias                         |
    | ...  overall_timeout=30                            |
    +------------------+-------+------------+------------+
    :param enable:
    :return:
    """
    if enable:
        configure_iphy_interfaces(['any'])
    else:
        restore_default_iphy_interfaces()


def wait_for_x2_link_established(timeout, check_version=True):
    """
    :param timeout:
    :param check_version:
    """
    pass_regexp = 'ENB-1: X2AP Link with GNB-2.*is up'
    ta5g_egate_interface = ta5g_egate()
    ta5g_egate_interface._ute_wtssim_instance.execute_egate_command(
        cmd='start version_check={}'.format("on" if check_version else "off"),
        pass_regexp=pass_regexp,
        timeout=timeout
    )


def wait_for_all_cells_reach_onair(timeout='480'):
    """
    Wait for all cells reach on air, based on wait_until_all_cells_reach_onair from ta5g_commisioning library.
    Check for 'availabilityStatus' is changed accordingly to CNI-61110: "Online status
    can be deduced if the availabilityStatus parameter is not set with any value." LTE_OPR_REQ_31472
    https://nokia.sharepoint.com/:x:/s/MNTAG-MNTestAutomationGroup/Ebdp5kBv3HJOhL1YxHwQMN8Bf7e1Ud5I8epu6o0u_7BlQQ
    """
    with ta_admin_interface.admin_interface() as admin_client:
        time_step = 10
        time_start = time.time()
        while time.time() < time_start + int(timeout):
            all_cells_are_online = True
            for cell in admin_client.get_cells_info():
                try:
                    if cell['status']['availabilityStatus'] is not None \
                            and cell['status']['availabilityStatus'] != '' \
                            and cell['status']['availabilityStatus'].lower() != 'online':
                        all_cells_are_online = False
                except KeyError:    # if availabilityStatus is not present -> cell online
                    pass
            if all_cells_are_online:
                return True
            time.sleep(time_step)

    raise ExecutionFailed(message="Wrong number of cells OnAir!")


def kill_aliases():
    """
    Shutdown all stuff started by alias factory
    """
    get_alias_factory().shutdown()
