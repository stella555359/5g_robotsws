# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Mariusz Waczynski
:contact: mariusz.waczynski@nokia.com
"""
from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed


LOCAL_MOID_BTS_CELL1 = 'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1'
COUNTER_ID_DL_PDCP_VOL_UE_TPUT_QOS06 = 'M55350C01006'
COUNTER_ID_DL_PDCP_VOL_UE_TPUT_5G_QOS06 = 'M55350C03006'
COUNTER_ID_DL_PDCP_VOL_UE_TPUT_LTE_QOS06 = 'M55350C05006'
COUNTER_ID_DL_PDCP_TIME_UE_TPUT_QOS06 = 'M55350C00006'

COUNTER_ID_UL_RLC_VOL_UE_TPUT_QOS06 = 'M55349C01006'
COUNTER_ID_UL_RLC_TIME_UE_TPUT_QOS06 = 'M55349C00006'

COUNTER_ID_MAX_UL_RLC_UE_TPUT = 'M55349C02001'

COUNTER_ID_MAX_DL_PDCP_BURST_TPUT = 'M55350C02001'
COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_5GLEG = 'M55350C04001'
COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_LTELEG = 'M55350C06001'

COUNTER_ID_MEAS_PERIOD_NR_MAC_SDU_REPORT = 'M55309C00001'
COUNTER_ID_DL_MAC_SDU_VOL_DTCH = 'M55309C01001'
COUNTER_ID_UL_MAC_SDU_VOL_DTCH = 'M55309C02001'
COUNTER_ID_MAC_DTCH_CELL_THP_DL_MAX = 'M55309C12001'
COUNTER_ID_MAC_DTCH_CELL_THP_UL_MAX = 'M55309C12002'


def check_throughput_counters_for_sa_ue(dl_tput, ul_tput,  local_moid=LOCAL_MOID_BTS_CELL1, margin="1%"):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    ta5g_pm.wait_for_next_full_pm_interval()
    pm_counters = ta5g_pm.get_latest_unpacked_full_pm_counters_file()
    DL_PDCP_VOL_UE_TPUT_QOS06 = get_counter_values(COUNTER_ID_DL_PDCP_VOL_UE_TPUT_QOS06, local_moid,
                                                   pm_counters)
    DL_PDCP_VOL_UE_TPUT_5G_QOS06 = get_counter_values(COUNTER_ID_DL_PDCP_VOL_UE_TPUT_5G_QOS06, local_moid,
                                                      pm_counters)
    DL_PDCP_VOL_UE_TPUT_LTE_QOS06 = get_counter_values(COUNTER_ID_DL_PDCP_VOL_UE_TPUT_LTE_QOS06, local_moid,
                                                       pm_counters)
    check_counter_value(COUNTER_ID_DL_PDCP_VOL_UE_TPUT_LTE_QOS06, DL_PDCP_VOL_UE_TPUT_LTE_QOS06, 0)
    DL_PDCP_TIME_UE_TPUT_QOS06 = get_counter_values(COUNTER_ID_DL_PDCP_TIME_UE_TPUT_QOS06, local_moid,
                                                    pm_counters)
    DL_PDCP_VOL_UE_TPUT_QOS06_SUM = sum(DL_PDCP_VOL_UE_TPUT_QOS06)
    DL_PDCP_VOL_UE_TPUT_5G_QOS06_SUM = sum(DL_PDCP_VOL_UE_TPUT_5G_QOS06)
    DL_PDCP_TIME_UE_TPUT_QOS06_SUM = sum(DL_PDCP_TIME_UE_TPUT_QOS06)
    if DL_PDCP_TIME_UE_TPUT_QOS06_SUM != 0:
        PDCP_UE_TPUT_QOS06 = DL_PDCP_VOL_UE_TPUT_QOS06_SUM / DL_PDCP_TIME_UE_TPUT_QOS06_SUM
        PDCP_VOL_UE_TPUT_5G = DL_PDCP_VOL_UE_TPUT_5G_QOS06_SUM / DL_PDCP_TIME_UE_TPUT_QOS06_SUM
    else:
        PDCP_UE_TPUT_QOS06 = 0
        PDCP_VOL_UE_TPUT_5G = 0

    check_ip_scheduled_throughput_based_on_counter_value('DL_PDCP_VOL/TIME_UE_TPUT_QOS06', PDCP_UE_TPUT_QOS06, dl_tput)
    check_ip_scheduled_throughput_based_on_counter_value('DL_PDCP_VOL_5G/TIME_UE_TPUT_QOS06', PDCP_VOL_UE_TPUT_5G,
                                                         dl_tput)
    UL_RLC_VOL_UE_TPUT_QOS06 = get_counter_values(COUNTER_ID_UL_RLC_VOL_UE_TPUT_QOS06, local_moid,
                                                  pm_counters)
    UL_RLC_TIME_UE_TPUT_QOS06 = get_counter_values(COUNTER_ID_UL_RLC_TIME_UE_TPUT_QOS06, local_moid,
                                                   pm_counters)
    UL_RLC_VOL_UE_TPUT_QOS06_SUM = sum(UL_RLC_VOL_UE_TPUT_QOS06)
    UL_RLC_TIME_UE_TPUT_QOS06_SUM = sum(UL_RLC_TIME_UE_TPUT_QOS06)

    if UL_RLC_TIME_UE_TPUT_QOS06_SUM != 0:
        RLC_UE_TPUT_QOS06 = UL_RLC_VOL_UE_TPUT_QOS06_SUM / UL_RLC_TIME_UE_TPUT_QOS06_SUM
    else:
        RLC_UE_TPUT_QOS06 = 0

    check_ip_scheduled_throughput_based_on_counter_value('RLC_VOL_UE_TPUT/UL_RLC_TIME_UE_TPUT', RLC_UE_TPUT_QOS06,
                                                         ul_tput)
    MAX_DL_PDCP_BURST_TPUT = get_counter_values(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT, local_moid,
                                                pm_counters)
    check_counter_value(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT, MAX_DL_PDCP_BURST_TPUT, dl_tput, margin="5%")
    MAX_DL_PDCP_BURST_TPUT_5GLEG = get_counter_values(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_5GLEG, local_moid,
                                                      pm_counters)
    check_counter_value(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_5GLEG, MAX_DL_PDCP_BURST_TPUT_5GLEG, dl_tput, margin="5%")
    MAX_DL_PDCP_BURST_TPUT_LTELEG = get_counter_values(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_LTELEG, local_moid,
                                                       pm_counters)
    check_counter_value(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_LTELEG, MAX_DL_PDCP_BURST_TPUT_LTELEG, 0)


def all_thput_counters_should_be_equal_to_0(local_moid=LOCAL_MOID_BTS_CELL1):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    ta5g_pm.wait_for_next_full_pm_interval()
    pm_counters = ta5g_pm.get_latest_unpacked_full_pm_counters_file()
    DL_PDCP_VOL_UE_TPUT_QOS06 = get_counter_values(COUNTER_ID_DL_PDCP_VOL_UE_TPUT_QOS06, local_moid,
                                                   pm_counters)
    DL_PDCP_VOL_UE_TPUT_5G_QOS06 = get_counter_values(COUNTER_ID_DL_PDCP_VOL_UE_TPUT_5G_QOS06, local_moid,
                                                      pm_counters)
    DL_PDCP_VOL_UE_TPUT_LTE_QOS06 = get_counter_values(COUNTER_ID_DL_PDCP_VOL_UE_TPUT_LTE_QOS06, local_moid,
                                                       pm_counters)
    DL_PDCP_TIME_UE_TPUT_QOS06 = get_counter_values(COUNTER_ID_DL_PDCP_TIME_UE_TPUT_QOS06, local_moid,
                                                    pm_counters)
    check_counter_value(COUNTER_ID_DL_PDCP_VOL_UE_TPUT_QOS06, DL_PDCP_VOL_UE_TPUT_QOS06, 0)
    check_counter_value(COUNTER_ID_DL_PDCP_VOL_UE_TPUT_5G_QOS06, DL_PDCP_VOL_UE_TPUT_5G_QOS06, 0)
    check_counter_value(COUNTER_ID_DL_PDCP_VOL_UE_TPUT_LTE_QOS06, DL_PDCP_VOL_UE_TPUT_LTE_QOS06, 0)
    check_counter_value(COUNTER_ID_DL_PDCP_TIME_UE_TPUT_QOS06, DL_PDCP_TIME_UE_TPUT_QOS06, 0)

    UL_RLC_VOL_UE_TPUT_QOS06 = get_counter_values(COUNTER_ID_UL_RLC_VOL_UE_TPUT_QOS06, local_moid,
                                                  pm_counters)
    UL_RLC_TIME_UE_TPUT_QOS06 = get_counter_values(COUNTER_ID_UL_RLC_TIME_UE_TPUT_QOS06, local_moid,
                                                   pm_counters)
    check_counter_value(COUNTER_ID_UL_RLC_VOL_UE_TPUT_QOS06, UL_RLC_VOL_UE_TPUT_QOS06, 0)
    check_counter_value(COUNTER_ID_UL_RLC_TIME_UE_TPUT_QOS06, UL_RLC_TIME_UE_TPUT_QOS06, 0)

    MAX_DL_PDCP_BURST_TPUT = get_counter_values(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT, local_moid,
                                                pm_counters)
    check_counter_value(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT, MAX_DL_PDCP_BURST_TPUT, 0)
    MAX_DL_PDCP_BURST_TPUT_5GLEG = get_counter_values(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_5GLEG, local_moid,
                                                      pm_counters)
    check_counter_value(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_5GLEG, MAX_DL_PDCP_BURST_TPUT_5GLEG, 0)
    MAX_DL_PDCP_BURST_TPUT_LTELEG = get_counter_values(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_LTELEG, local_moid,
                                                       pm_counters)
    check_counter_value(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_LTELEG, MAX_DL_PDCP_BURST_TPUT_LTELEG, 0)


def check_throughput_counters_for_nsa_ue_x2(dl_tput, ul_tput,  local_moid=LOCAL_MOID_BTS_CELL1, margin="1%"):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    ta5g_pm.wait_for_next_full_pm_interval()
    pm_counters = ta5g_pm.get_latest_unpacked_full_pm_counters_file()
    DL_PDCP_VOL_UE_TPUT_QOS06 = get_counter_values(COUNTER_ID_DL_PDCP_VOL_UE_TPUT_QOS06, local_moid,
                                                   pm_counters)
    DL_PDCP_VOL_UE_TPUT_5G_QOS06 = get_counter_values(COUNTER_ID_DL_PDCP_VOL_UE_TPUT_5G_QOS06, local_moid,
                                                      pm_counters)
    DL_PDCP_VOL_UE_TPUT_LTE_QOS06 = get_counter_values(COUNTER_ID_DL_PDCP_VOL_UE_TPUT_LTE_QOS06, local_moid,
                                                       pm_counters)
    check_counter_value(COUNTER_ID_DL_PDCP_VOL_UE_TPUT_5G_QOS06, DL_PDCP_VOL_UE_TPUT_5G_QOS06, 0)
    DL_PDCP_TIME_UE_TPUT_QOS06 = get_counter_values(COUNTER_ID_DL_PDCP_TIME_UE_TPUT_QOS06, local_moid,
                                                    pm_counters)
    DL_PDCP_VOL_UE_TPUT_QOS06_SUM = sum(DL_PDCP_VOL_UE_TPUT_QOS06)
    DL_PDCP_VOL_UE_TPUT_5G_QOS06_SUM = sum(DL_PDCP_VOL_UE_TPUT_5G_QOS06)
    DL_PDCP_VOL_UE_TPUT_LTE_QOS06_SUM = sum(DL_PDCP_VOL_UE_TPUT_LTE_QOS06)
    DL_PDCP_TIME_UE_TPUT_QOS06_SUM = sum(DL_PDCP_TIME_UE_TPUT_QOS06)
    print('DL_PDCP_VOL_UE_TPUT_QOS06 - {} , DL_PDCP_VOL_UE_TPUT_5G_QOS06 - {} , DL_PDCP_TIME_UE_TPUT_QOS06 - {}'
          .format(DL_PDCP_VOL_UE_TPUT_QOS06_SUM, DL_PDCP_VOL_UE_TPUT_5G_QOS06_SUM, DL_PDCP_TIME_UE_TPUT_QOS06_SUM))
    PDCP_UE_TPUT_QOS06 = DL_PDCP_VOL_UE_TPUT_QOS06_SUM/DL_PDCP_TIME_UE_TPUT_QOS06_SUM
    PDCP_VOL_UE_TPUT_LTE = DL_PDCP_VOL_UE_TPUT_LTE_QOS06_SUM/DL_PDCP_TIME_UE_TPUT_QOS06_SUM
    check_ip_scheduled_throughput_based_on_counter_value('DL_PDCP_VOL+TIME_UE_TPUT_QOS06', PDCP_UE_TPUT_QOS06, dl_tput)
    check_ip_scheduled_throughput_based_on_counter_value('DL_PDCP_VOL_LTE+TIME_UE_TPUT_QOS06',
                                                         PDCP_VOL_UE_TPUT_LTE,
                                                         dl_tput)
    UL_RLC_VOL_UE_TPUT_QOS06 = get_counter_values(COUNTER_ID_UL_RLC_VOL_UE_TPUT_QOS06, local_moid,
                                                  pm_counters)
    UL_RLC_TIME_UE_TPUT_QOS06 = get_counter_values(COUNTER_ID_UL_RLC_TIME_UE_TPUT_QOS06, local_moid,
                                                   pm_counters)
    UL_RLC_VOL_UE_TPUT_QOS06_SUM = sum(UL_RLC_VOL_UE_TPUT_QOS06)
    UL_RLC_TIME_UE_TPUT_QOS06_SUM = sum(UL_RLC_TIME_UE_TPUT_QOS06)
    RLC_UE_TPUT_QOS06 = UL_RLC_VOL_UE_TPUT_QOS06_SUM/UL_RLC_TIME_UE_TPUT_QOS06_SUM
    check_ip_scheduled_throughput_based_on_counter_value('RLC_VOL_UE_TPUT/UL_RLC_TIME_UE_TPUT', RLC_UE_TPUT_QOS06,
                                                         ul_tput)
    MAX_DL_PDCP_BURST_TPUT = get_counter_values(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT, local_moid,
                                                pm_counters)
    check_counter_value(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT, MAX_DL_PDCP_BURST_TPUT, dl_tput, margin="10%")
    MAX_DL_PDCP_BURST_TPUT_5GLEG = get_counter_values(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_5GLEG, local_moid,
                                                      pm_counters)
    check_counter_value(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_5GLEG, MAX_DL_PDCP_BURST_TPUT_5GLEG, 0)
    MAX_DL_PDCP_BURST_TPUT_LTELEG = get_counter_values(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_LTELEG, local_moid,
                                                       pm_counters)
    check_counter_value(COUNTER_ID_MAX_DL_PDCP_BURST_TPUT_LTELEG, MAX_DL_PDCP_BURST_TPUT_LTELEG,
                        dl_tput, margin="10%")


def check_throughput_counters_for_nsa_ue_f1u(dl_tput, ul_tput,  local_moid=LOCAL_MOID_BTS_CELL1, margin="1%"):
    check_throughput_counters_for_sa_ue(dl_tput, ul_tput, local_moid, margin)


def calculate_value_margin(margin, value):
    margin = float(margin.strip('%')) / 100
    return float(value) * (1 - margin), float(value) * (1 + margin)


def get_counter_values(counter_id, local_moid, pm_counter_file):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    counter_values = ta5g_pm.get_pm_counter_value(counter_id, local_moid, pm_counter_file)
    if len(counter_values) == 0:
        raise ExecutionFailed(
            message="The PM counter {} doesn't have values'".format(counter_id),
            continue_on_failure=True,
        )
    else:
        return counter_values


def check_counter_value(counter_id, pm_counters_values, expected_value,  margin='10%'):
    margin_range = calculate_value_margin(margin, expected_value)
    if not isinstance(pm_counters_values, list):
        values = [pm_counters_values]
    else:
        values = pm_counters_values
    for counter_value in values:
        if (float(counter_value) < min(margin_range)) or (float(counter_value) > max(margin_range)):
            raise ExecutionFailed(
                message="The PM counter {} doesn't have value in range ({} - {}) Current value - {}".format(
                    counter_id, min(margin_range), max(margin_range), counter_value
                ),
                continue_on_failure=True,
            )


def check_ip_scheduled_throughput_based_on_counter_value(counter_id, pm_counters_values, expected_value_kbps,
                                                         margin='10%'):
    expected_value_mbps = int(expected_value_kbps)/1000
    margin_range = calculate_value_margin(margin, expected_value_mbps)
    if not isinstance(pm_counters_values, list):
        values = [pm_counters_values]
    else:
        values = pm_counters_values
    for counter_value in values:
        if (float(counter_value) < min(margin_range)) or (float(counter_value) > max(margin_range)):
            raise ExecutionFailed(
                message="The PM counter {} doesn't have value in range ({} - {}) Current value - {}".format(
                    counter_id, min(margin_range), max(margin_range), counter_value
                ),
                continue_on_failure=True,
            )


def check_mac_throughput_counters_for_dl(filepath):
    actual_value_for_MEAS_PERIOD_NR_MAC_SDU_REPORT = get_counter_values(
        counter_id=COUNTER_ID_MEAS_PERIOD_NR_MAC_SDU_REPORT,
        local_moid=LOCAL_MOID_BTS_CELL1,
        pm_counter_file=filepath)
    actual_value_for_DL_MAC_SDU_VOL_DTCH = get_counter_values(counter_id=COUNTER_ID_DL_MAC_SDU_VOL_DTCH,
                                                              local_moid=LOCAL_MOID_BTS_CELL1,
                                                              pm_counter_file=filepath)
    actual_value_for_MAC_DTCH_CELL_THP_DL_MAX = get_counter_values(counter_id=COUNTER_ID_MAC_DTCH_CELL_THP_DL_MAX,
                                                                   local_moid=LOCAL_MOID_BTS_CELL1,
                                                                   pm_counter_file=filepath)
    if int(actual_value_for_MAC_DTCH_CELL_THP_DL_MAX[0])\
            <= int(actual_value_for_DL_MAC_SDU_VOL_DTCH[0]/actual_value_for_MEAS_PERIOD_NR_MAC_SDU_REPORT[0]):
        raise ExecutionFailed(
            message='The PM counter {} are not smaller than average volume transferred per second'.format(
                'M55309C12001'),
            continue_on_failure=True,)


def check_mac_throughput_counters_for_ul(filepath):
    actual_value_for_MEAS_PERIOD_NR_MAC_SDU_REPORT = get_counter_values(
        counter_id=COUNTER_ID_MEAS_PERIOD_NR_MAC_SDU_REPORT,
        local_moid=LOCAL_MOID_BTS_CELL1, pm_counter_file=filepath)
    actual_value_for_UL_MAC_SDU_VOL_DTCH = get_counter_values(counter_id=COUNTER_ID_UL_MAC_SDU_VOL_DTCH,
                                                              local_moid=LOCAL_MOID_BTS_CELL1,
                                                              pm_counter_file=filepath)
    actual_value_for_MAC_DTCH_CELL_THP_UL_MAX = get_counter_values(counter_id=COUNTER_ID_MAC_DTCH_CELL_THP_UL_MAX,
                                                                   local_moid=LOCAL_MOID_BTS_CELL1,
                                                                   pm_counter_file=filepath)
    if actual_value_for_MAC_DTCH_CELL_THP_UL_MAX[0]\
            <= int(actual_value_for_UL_MAC_SDU_VOL_DTCH[0]/actual_value_for_MEAS_PERIOD_NR_MAC_SDU_REPORT[0]):
        raise ExecutionFailed(
            message='The PM counter {} are not smaller than average volume transferred per second'.format(
                'M55309C12002'),
            continue_on_failure=True,
        )


def check_if_pm_counters_have_the_same_value(first_counter_id, second_counter_id):
    if first_counter_id != second_counter_id:
        raise ExecutionFailed(
                message='The values of PM counters {} are different'.format(
                    first_counter_id),
                continue_on_failure=True,
                )


def check_if_pm_counter_have_value_lower_than_other(first_counter_id, second_counter_id):
    if first_counter_id == 0 and first_counter_id < second_counter_id:
        raise ExecutionFailed(
                message='The values of PM counters {} are value not lower than other {}'.format(
                    first_counter_id, second_counter_id),
                continue_on_failure=True,
                )
