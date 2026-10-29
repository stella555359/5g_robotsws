# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Mariusz Waczynski
:contact: mariusz.waczynski@nokia.com
"""
import re
import time
from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed
from robot.api import logger
from tabulate import tabulate
from robot.libraries.OperatingSystem import OperatingSystem

LOCAL_MOID_BTS_CELL1 = 'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1'
LOCAL_MOID_BTS_CELL2 = 'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2'
LOCAL_MOID_BTS = 'PLMN-PLMN/MRBTS-1/NRBTS-1'
COUNTER_ID_UL_PDCP_SDU_DLY_CUUP = 'M55350C00027'
COUNTER_ID_UL_PDCP_SDU_SENT_SAP_TOT = 'M55350C00028'
COUNTER_ID_UL_PDCP_SDU_DLY_CUUP_PMQAP = 'M55159C00005'
COUNTER_ID_UL_PDCP_SDU_SENT_SAP_TOT_PMQAP = 'M55159C00006'
COUNTER_ID_DL_PDCP_SDU_DLY_CUUP = 'M55350C00023'
COUNTER_ID_DL_PDCP_SDU_SENT_TOT = 'M55350C00024'
COUNTER_ID_DL_PDCP_SDU_SENT_TOT_PMQAP = 'M55159C00002'
COUNTER_ID_DL_PDCP_SDU_DLY_CUUP_PMQAP = 'M55159C00001'
COUNTER_ID_DL_RLC_AM_DLY_AIR_IF = 'M55310C00002'
COUNTER_ID_DL_RLC_AM_SDU_TRANS_SUCC = 'M55310C00003'
COUNTER_ID_DL_RLC_AM_DLY_AIR_IF_PMQAP = 'M55158C00001'
COUNTER_ID_DL_RLC_AM_SDU_TRANS_SUCC_PMQAP = 'M55158C00002'
COUNTER_ID_UL_BURST_TOT_RLC = 'M55349C00021'
COUNTER_ID_UL_BURST_TOT_RLC_PMQAP = 'M55158C00005'
COUNTER_ID_DL_INIT_SCHD_DLY_GNB = 'M55350C00029'
COUNTER_ID_DL_INIT_BURST_PDCP = 'M55350C00030'
COUNTER_ID_DL_INIT_SCHD_DLY_GNB_PMQAP = 'M55159C00007'
COUNTER_ID_DL_INIT_BURST_PDCP_PMQAP = 'M55159C00008'
COUNTER_ID_DL_SDU_TX_SA_QOS_GRP_06 = 'M55319C11006'
COUNTER_ID_DL_SDU_TX_NSA_QOS_GRP_06 = 'M55319C01006'
COUNTER_ID_DL_DELAY_QOS_GRP_06 = 'M55319C09006'
COUNTER_ID_UL_PDCP_SDU_SNT_NGU_QOS_GRP_06 = 'M55327C03006'
COUNTER_ID_UL_PDCP_SDU_SNT_S1U_QOS_GRP_06 = 'M55315C02006'
COUNTER_ID_UL_DELAY_QOS_GRP_06 = 'M55319C10006'


def get_local_moid(cell_id):
    if cell_id == '1':
        local_moid = LOCAL_MOID_BTS_CELL1
    elif cell_id == '2':
        local_moid = LOCAL_MOID_BTS_CELL2
    else:
        raise ExecutionFailed(message="Cell ID {} is out of range".format(cell_id), continue_on_failure=True)
    return local_moid


def check_if_cell_and_pmqap_burst_has_expected_value(expected_value, margin='10%', local_moid=LOCAL_MOID_BTS_CELL1):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    ta5g_pm.wait_for_next_full_pm_interval()
    pm_counters = ta5g_pm.get_latest_unpacked_full_pm_counters_file()
    cell_total_burst = ta5g_pm.get_pm_counter_value(COUNTER_ID_UL_BURST_TOT_RLC, local_moid, pm_counters)
    if len(cell_total_burst) == 0:
        raise ExecutionFailed(
            message="The PM counter {} doesn't have values'".format(COUNTER_ID_UL_BURST_TOT_RLC),
            continue_on_failure=True,
        )
    pmqap_total_burst = ta5g_pm.get_pm_counter_value(COUNTER_ID_UL_BURST_TOT_RLC_PMQAP, local_moid, pm_counters)
    if len(pmqap_total_burst) == 0:
        raise ExecutionFailed(
            message="The PM counter {} doesn't have values'".format(COUNTER_ID_UL_BURST_TOT_RLC_PMQAP),
            continue_on_failure=True,
        )
    if cell_total_burst != pmqap_total_burst:
        raise ExecutionFailed(message='The values of delay for cell {} and for pmqap {} are different'.format(
            cell_total_burst, pmqap_total_burst), continue_on_failure=True)
    margin_range = calculate_value_margin(margin, expected_value)
    total_value = sum(cell_total_burst)
    statistic_table = [["Reached Level", "Expected Min", "Expected Max"],
                       [total_value, min(margin_range), max(margin_range)]]
    logger.console(tabulate(statistic_table))
    if (float(total_value) < min(margin_range)) or (float(total_value) > max(margin_range)):
        raise ExecutionFailed(
                message="Calculated delay doesn't have value in range ({} - {}) Current value - {:.1f}".format(
                    min(margin_range), max(margin_range), total_value),
                continue_on_failure=True,
            )


def check_if_burst_scheduling_cell_and_pmqap_dl_delay_has_expected_value(expected_range):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    ta5g_pm.wait_for_next_full_pm_interval()
    cell_avg_delay = calculate_average_delay_from_pm_counters(COUNTER_ID_DL_INIT_BURST_PDCP,
                                                              COUNTER_ID_DL_INIT_SCHD_DLY_GNB)
    pmqap_avg_delay = calculate_average_delay_from_pm_counters(COUNTER_ID_DL_INIT_BURST_PDCP_PMQAP,
                                                               COUNTER_ID_DL_INIT_SCHD_DLY_GNB_PMQAP)
    cell_and_pmqap_average_delay_should_be_equal(cell_avg_delay, pmqap_avg_delay)
    range = expected_range.split("-")
    print('Calculated dl cell delay {}'.format(cell_avg_delay))
    print('Calculated dl pmqap delay {}'.format(pmqap_avg_delay))
    statistic_table = [["Cell_Average_Delay", "PMQAP_Average_Delay"],
                       [round(cell_avg_delay, 3), round(pmqap_avg_delay, 3)]]
    logger.console(tabulate(statistic_table))
    if (float(cell_avg_delay) < float(range[0])) or (float(cell_avg_delay) > float(range[1])):
        raise ExecutionFailed(
                message="Calculated delay doesn't have value in range ({} - {}) Current value - {:.1f}".format(
                    range[0], range[1], cell_avg_delay),
                continue_on_failure=True,
            )


def check_if_rlc_am_cell_and_pmqap_dl_delay_has_expected_value(cell_id, expected_rlc_delay, margin='15%'):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    ta5g_pm.wait_for_next_full_pm_interval()
    local_moid = get_local_moid(cell_id)
    cell_avg_delay = calculate_average_delay_from_pm_counters(COUNTER_ID_DL_RLC_AM_SDU_TRANS_SUCC,
                                                              COUNTER_ID_DL_RLC_AM_DLY_AIR_IF, local_moid)
    pmqap_avg_delay = calculate_average_delay_from_pm_counters(COUNTER_ID_DL_RLC_AM_SDU_TRANS_SUCC_PMQAP,
                                                               COUNTER_ID_DL_RLC_AM_DLY_AIR_IF_PMQAP, local_moid)
    cell_and_pmqap_average_delay_should_be_equal(cell_avg_delay, pmqap_avg_delay)
    margin_range = calculate_value_margin(margin, expected_rlc_delay)
    print('Calculated dl cell delay {}'.format(cell_avg_delay))
    print('Calculated dl pmqap delay {}'.format(pmqap_avg_delay))
    statistic_table = [["Reached Level", "Expected Min", "Expected Max"],
                       [round(cell_avg_delay, 3), min(margin_range), max(margin_range)]]
    logger.console(tabulate(statistic_table))
    if (float(cell_avg_delay) < min(margin_range)) or (float(cell_avg_delay) > max(margin_range)):
        raise ExecutionFailed(
                message="Calculated delay doesn't have value in range ({} - {}) Current value - {:.1f}".format(
                    min(margin_range), max(margin_range), cell_avg_delay),
                continue_on_failure=True,
            )


def check_if_cell_and_pmqap_dl_delay_has_expected_value(expected_dl_delay, cell_id, margin='15%'):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    ta5g_pm.wait_for_next_full_pm_interval()
    local_moid = get_local_moid(cell_id)
    cell_avg_delay = calculate_average_delay_from_pm_counters(COUNTER_ID_DL_PDCP_SDU_SENT_TOT,
                                                              COUNTER_ID_DL_PDCP_SDU_DLY_CUUP, local_moid)
    pmqap_avg_delay = calculate_average_delay_from_pm_counters(COUNTER_ID_DL_PDCP_SDU_SENT_TOT,
                                                               COUNTER_ID_DL_PDCP_SDU_DLY_CUUP_PMQAP, local_moid)
    legacy_dl_delay = calculate_average_delay_from_legacy_pm_counters(COUNTER_ID_DL_SDU_TX_SA_QOS_GRP_06,
                                                                      COUNTER_ID_DL_SDU_TX_NSA_QOS_GRP_06,
                                                                      COUNTER_ID_DL_DELAY_QOS_GRP_06, LOCAL_MOID_BTS)
    cell_and_pmqap_average_delay_should_be_equal(cell_avg_delay, pmqap_avg_delay)
    compare_delay(legacy_dl_delay, cell_avg_delay)
    margin_range = calculate_value_margin(margin, expected_dl_delay)
    print('Calculated dl cell delay {}'.format(cell_avg_delay))
    print('Calculated dl pmqap delay {}'.format(pmqap_avg_delay))
    print('Calculated dl legacy delay {}'.format(legacy_dl_delay))
    statistic_table = [["Reached Level", "Legacy dl delay", "Expected Min", "Expected Max"],
                       [round(cell_avg_delay, 3), round(legacy_dl_delay, 3), min(margin_range), max(margin_range)]]
    logger.console(tabulate(statistic_table))
    if (float(cell_avg_delay) < min(margin_range)) or (float(cell_avg_delay) > max(margin_range)):
        raise ExecutionFailed(
                message="Calculated delay doesn't have value in range ({} - {}) Current value - {:.3f}".format(
                    min(margin_range), max(margin_range), cell_avg_delay),
                continue_on_failure=True,
            )


def check_if_cell_and_pmqap_ul_delay_has_expected_value(expected_ul_delay, margin='15%'):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    ta5g_pm.wait_for_next_full_pm_interval()
    cell_avg_delay = calculate_average_delay_from_pm_counters(COUNTER_ID_UL_PDCP_SDU_SENT_SAP_TOT,
                                                              COUNTER_ID_UL_PDCP_SDU_DLY_CUUP)
    pmqap_avg_delay = calculate_average_delay_from_pm_counters(COUNTER_ID_UL_PDCP_SDU_SENT_SAP_TOT,
                                                               COUNTER_ID_UL_PDCP_SDU_DLY_CUUP_PMQAP)
    legacy_ul_delay = calculate_average_delay_from_legacy_pm_counters(COUNTER_ID_UL_PDCP_SDU_SNT_NGU_QOS_GRP_06,
                                                                      COUNTER_ID_UL_PDCP_SDU_SNT_S1U_QOS_GRP_06,
                                                                      COUNTER_ID_UL_DELAY_QOS_GRP_06, LOCAL_MOID_BTS)
    cell_and_pmqap_average_delay_should_be_equal(cell_avg_delay, pmqap_avg_delay)
    compare_delay(legacy_ul_delay, cell_avg_delay)
    margin_range = calculate_value_margin(margin, expected_ul_delay)
    print('Calculated ul cell delay {}'.format(cell_avg_delay))
    print('Calculated ul pmqap delay {}'.format(pmqap_avg_delay))
    print('Calculated ul legacy delay {}'.format(legacy_ul_delay))
    statistic_table = [["Reached Level", "Legacy ul delay", "Expected Min", "Expected Max"],
                       [round(cell_avg_delay, 4), round(legacy_ul_delay, 4), min(margin_range), max(margin_range)]]
    logger.console(tabulate(statistic_table))
    if (float(cell_avg_delay) < min(margin_range)) or (float(cell_avg_delay) > max(margin_range)):
        raise ExecutionFailed(
                message="Calculated delay doesn't have value in range ({} - {}) Current value - {:.3f}".format(
                    min(margin_range), max(margin_range), cell_avg_delay),
                continue_on_failure=True,
            )


def cell_and_pmqap_average_delay_should_be_equal(cell_avg_delay, pmqap_avg_delay):
    if cell_avg_delay != pmqap_avg_delay:
        raise ExecutionFailed(message='The values of delay for cell {} and for pmqap {} are different'.format(
            cell_avg_delay, pmqap_avg_delay), continue_on_failure=True)


def calculate_average_delay_from_pm_counters(counter_id_total_packets, counter_id_total_delay,
                                             local_moid=LOCAL_MOID_BTS_CELL1):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    pm_counters = ta5g_pm.get_latest_unpacked_full_pm_counters_file()
    total_packets = ta5g_pm.get_pm_counter_value(counter_id_total_packets, local_moid, pm_counters)
    if len(total_packets) == 0:
        raise ExecutionFailed(
            message="The PM counter {} doesn't have values'".format(counter_id_total_packets),
            continue_on_failure=True,
        )
    total_delay = ta5g_pm.get_pm_counter_value(counter_id_total_delay, local_moid, pm_counters)
    if len(total_delay) == 0:
        raise ExecutionFailed(
            message="The PM counter {} doesn't have values'".format(counter_id_total_delay),
            continue_on_failure=True,
        )
    return total_delay[0]/total_packets[0]/1000


def calculate_value_margin(margin, value):
    margin = float(margin.strip('%')) / 100
    return float(value) * (1 - margin), float(value) * (1 + margin)


def get_ue_id():
    ta5g_ue_wts = BuiltIn().get_library_instance('ute_wtssim')
    get_active_ue_id = ta5g_ue_wts.execute_egate_command(cmd='ue_disp', pass_regexp='ACTIVE')
    OperatingSystem().create_file(path='/tmp/active_ue_id.txt', content=get_active_ue_id)
    ue_disp = open('/tmp/active_ue_id.txt')
    for ue_id in ue_disp:
        if re.search('ACTIVE', ue_id):
            return ue_id.split("ACTIVE")[0].strip().split(" ")[0]


def compare_delay(dealay_01, dealay_02, margin='2%'):
    margin = float(margin.strip('%')) / 100
    division = round(abs(1-dealay_01/dealay_02)*100, 1)
    if float(division) > float(margin):
        raise ExecutionFailed(
                message="Counters deviation is out of range. Expected max deviation {}. Current deviation - {:.1f}%"
                .format(margin, division),
                continue_on_failure=True,
            )


def start_ul_data_traffic_with_repetition(repeat):
    ta5g_ue_wts = BuiltIn().get_library_instance('ute_wtssim')
    ta5g_ue_wts.execute_egate_command(cmd='sim_debug_log level=6')
    ue_id = get_ue_id()
    if int(ue_id) <= 10:
        for x in range(int(repeat)):
            ta5g_ue_wts.execute_egate_command(cmd='trf_data_start ue={} pdu=1 qfi=1 dir=ul '
                                                  'mbps=150 seconds=20s'.format(ue_id))
            ta5g_ue_wts.execute_egate_command(cmd='trf_data_start ue={} pdu=1 qfi=1 dir=ul '
                                                  'mbps=150 seconds=20s trf_id=2'.format(ue_id))
            time.sleep(25)
    else:
        for x in range(int(repeat)):
            ta5g_ue_wts.execute_egate_command(cmd='trf_data_start ue={} id=2 dir=ul '
                                                  'mbps=160 seconds=10s'.format(ue_id))
            time.sleep(25)


def calculate_average_delay_from_legacy_pm_counters(counter_id_total_sa_packets, counter_id_total_nsa_packets,
                                                    counter_id_total_delay, local_moid=LOCAL_MOID_BTS_CELL1):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    pm_counters = ta5g_pm.get_latest_unpacked_full_pm_counters_file()
    total_packets = ta5g_pm.get_pm_counter_value(counter_id_total_sa_packets, local_moid, pm_counters)
    total_packets.append((ta5g_pm.get_pm_counter_value(counter_id_total_nsa_packets, local_moid, pm_counters))[0])
    if len(total_packets) == 0:
        raise ExecutionFailed(
            message="The PM counter {} and {} don't have value'".format(counter_id_total_sa_packets,
                                                                        counter_id_total_nsa_packets),
            continue_on_failure=True,
        )
    else:
        total_packets = [sum(total_packets)]
    total_delay = ta5g_pm.get_pm_counter_value(counter_id_total_delay, local_moid, pm_counters)
    if len(total_delay) == 0:
        raise ExecutionFailed(
            message="The PM counter {} doesn't have values'".format(counter_id_total_delay),
            continue_on_failure=True,
        )
    return total_delay[0]/total_packets[0]/1000


def verify_if_pm_counters_were_not_updated(local_moid=LOCAL_MOID_BTS_CELL1):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    ta5g_pm.wait_for_next_full_pm_interval()
    pm_counters = ta5g_pm.get_latest_unpacked_full_pm_counters_file()
    logger.console("Verify that counters are equal to zero")
    counter_list = open(__file__).readlines()[17:35]
    for counter in counter_list:
        if re.search('COUNTER_ID', counter):
            counter_id = counter.split('\'')[1]
            value = ta5g_pm.get_pm_counter_value(counter_id, local_moid, pm_counters)
            if value[0] != 0:
                raise ExecutionFailed(
                    message='The PM counter "{}" is not equal to zero'.format(counter_id),
                    continue_on_failure=True,
                )


def verify_if_pm_counters_exists(local_moid=LOCAL_MOID_BTS_CELL1):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    pm_counters = ta5g_pm.get_latest_unpacked_full_pm_counters_file()
    logger.console("Verification of the existence of counters")
    counter_list = open(__file__).readlines()[17:35]
    for counter in counter_list:
        if re.search('COUNTER_ID', counter):
            counter_id = counter.split('\'')[1]
            value = ta5g_pm.get_pm_counter_value(counter_id, LOCAL_MOID_BTS_CELL1, pm_counters)
            if len(value) == 0:
                raise ExecutionFailed(
                    message='The PM counter "{}" does not exists in moid: "{}"'.format(counter_id, local_moid),
                    continue_on_failure=True,
                )
