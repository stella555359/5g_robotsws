from robot.errors import ExecutionFailed
from robot.api import logger
from tabulate import tabulate
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources.common_keywords_vran import get_du_counter, get_cu_counter
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources.common_keywords_vran import calculate_value_margin

LOCAL_MOID_BTS = 'MRBTS-1/NRBTS-1'
LOCAL_MOID_CELL = 'MRBTS-1/NRBTS-1/NRCELL-1'
LOCAL_MOID_PMQAP = 'MRBTS-1/NRBTS-1/NRCELL-1/NRPMQAP-1'
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
COUNTER_ID_UL_PDCP_SDU_SNT_NGU_QOS_GRP_09 = 'M55327C03009'
COUNTER_ID_UL_PDCP_SDU_SNT_S1U_QOS_GRP_09 = 'M55315C02009'
COUNTER_ID_UL_DELAY_QOS_GRP_09 = 'M55319C10009'
COUNTER_ID_UL_DELAY_QOS_GRP_06 = 'M55319C10006'


def check_if_rlc_am_cell_and_pmqap_dl_delay_has_expected_value(cell_id, expected_rlc_delay, margin='15%'):
    local_moid = 'MRBTS-1/NRBTS-1/NRCELL-{}'.format(cell_id)
    local_moid_pmqap = 'MRBTS-1/NRBTS-1/NRCELL-{}/NRPMQAP-1'.format(cell_id)
    cell_avg_delay = calculate_average_delay_from_vdu_pm_counters(COUNTER_ID_DL_RLC_AM_SDU_TRANS_SUCC,
                                                                  COUNTER_ID_DL_RLC_AM_DLY_AIR_IF, local_moid)
    pmqap_avg_delay = calculate_average_delay_from_vdu_pm_counters(COUNTER_ID_DL_RLC_AM_SDU_TRANS_SUCC_PMQAP,
                                                                   COUNTER_ID_DL_RLC_AM_DLY_AIR_IF_PMQAP,
                                                                   local_moid_pmqap)
    cell_and_pmqap_average_delay_should_be_equal(cell_avg_delay, pmqap_avg_delay)
    margin_range = calculate_value_margin(margin, expected_rlc_delay)
    verify_calculated_delay(cell_avg_delay, pmqap_avg_delay, margin_range)


def check_if_burst_scheduling_cell_and_pmqap_dl_delay_has_expected_value_for_cloud(expected_range):
    cell_avg_delay = calculate_average_delay_from_vcu_pm_counters(COUNTER_ID_DL_INIT_BURST_PDCP,
                                                                  COUNTER_ID_DL_INIT_SCHD_DLY_GNB,
                                                                  LOCAL_MOID_CELL)
    pmqap_avg_delay = calculate_average_delay_from_vcu_pm_counters(COUNTER_ID_DL_INIT_BURST_PDCP_PMQAP,
                                                                   COUNTER_ID_DL_INIT_SCHD_DLY_GNB_PMQAP,
                                                                   LOCAL_MOID_PMQAP)
    cell_and_pmqap_average_delay_should_be_equal(cell_avg_delay, pmqap_avg_delay)
    range = list(map(int, expected_range.split("-")))
    verify_calculated_delay(cell_avg_delay, pmqap_avg_delay, range)


def check_if_cell_and_pmqap_burst_has_expected_value_for_cloud(expected_value, margin='10%'):
    cell_total_burst = get_du_counter(COUNTER_ID_UL_BURST_TOT_RLC, LOCAL_MOID_CELL)
    if cell_total_burst == 0:
        raise ExecutionFailed(
            message="The PM counter {} doesn't have values'".format(COUNTER_ID_UL_BURST_TOT_RLC),
            continue_on_failure=True,
        )
    pmqap_total_burst = get_du_counter(COUNTER_ID_UL_BURST_TOT_RLC_PMQAP, LOCAL_MOID_PMQAP)
    if pmqap_total_burst == 0:
        raise ExecutionFailed(
            message="The PM counter {} doesn't have values'".format(COUNTER_ID_UL_BURST_TOT_RLC_PMQAP),
            continue_on_failure=True,
        )
    if cell_total_burst != pmqap_total_burst:
        raise ExecutionFailed(message='The values of delay for cell {} and for pmqap {} are different'.format(
            cell_total_burst, pmqap_total_burst), continue_on_failure=True)
    margin_range = calculate_value_margin(margin, expected_value)
    total_value = cell_total_burst
    verify_calculated_delay(total_value, pmqap_total_burst, margin_range)


def check_vcu_cell_and_pmqap_dl_delay_has_expected_value(cell_id, expected_dl_delay, margin='15%'):
    local_moid = 'MRBTS-1/NRBTS-1/NRCELL-{}'.format(cell_id)
    local_moid_pmqap = 'MRBTS-1/NRBTS-1/NRCELL-{}/NRPMQAP-1'.format(cell_id)
    cell_avg_delay = calculate_average_delay_from_vcu_pm_counters(COUNTER_ID_DL_PDCP_SDU_SENT_TOT,
                                                                  COUNTER_ID_DL_PDCP_SDU_DLY_CUUP,
                                                                  local_moid)
    pmqap_avg_delay = calculate_average_delay_from_vcu_pm_counters(COUNTER_ID_DL_PDCP_SDU_SENT_TOT_PMQAP,
                                                                   COUNTER_ID_DL_PDCP_SDU_DLY_CUUP_PMQAP,
                                                                   local_moid_pmqap)
    legacy_dl_delay = calculate_average_delay_from_vcu_legacy_pm_counters(COUNTER_ID_DL_SDU_TX_SA_QOS_GRP_06,
                                                                          COUNTER_ID_DL_DELAY_QOS_GRP_06,
                                                                          LOCAL_MOID_BTS)
    cell_and_pmqap_average_delay_should_be_equal(cell_avg_delay, pmqap_avg_delay)
    compare_delay(legacy_dl_delay, cell_avg_delay)
    margin_range = calculate_value_margin(margin, expected_dl_delay)
    verify_calculated_delay(cell_avg_delay, pmqap_avg_delay, margin_range, legacy_delay=legacy_dl_delay)


def check_if_vcu_cell_and_pmqap_ul_delay_has_expected_value_sa(expected_ul_delay, margin='15%'):
    cell_avg_delay = calculate_average_delay_from_vcu_pm_counters(COUNTER_ID_UL_PDCP_SDU_SENT_SAP_TOT,
                                                                  COUNTER_ID_UL_PDCP_SDU_DLY_CUUP, LOCAL_MOID_CELL)
    pmqap_avg_delay = calculate_average_delay_from_vcu_pm_counters(COUNTER_ID_UL_PDCP_SDU_SENT_SAP_TOT_PMQAP,
                                                                   COUNTER_ID_UL_PDCP_SDU_DLY_CUUP_PMQAP,
                                                                   LOCAL_MOID_PMQAP)
    legacy_ul_delay = calculate_average_delay_from_vcu_pm_counters(COUNTER_ID_UL_PDCP_SDU_SNT_NGU_QOS_GRP_06,
                                                                   COUNTER_ID_UL_DELAY_QOS_GRP_06, LOCAL_MOID_BTS)
    cell_and_pmqap_average_delay_should_be_equal(cell_avg_delay, pmqap_avg_delay)
    compare_delay(legacy_ul_delay, cell_avg_delay)
    margin_range = calculate_value_margin(margin, expected_ul_delay)
    verify_calculated_delay(cell_avg_delay, pmqap_avg_delay, margin_range, legacy_delay=legacy_ul_delay)


def check_if_vcu_cell_and_pmqap_ul_delay_has_expected_value_nsa(expected_ul_delay, margin='15%'):
    cell_avg_delay = calculate_average_delay_from_vcu_pm_counters(COUNTER_ID_UL_PDCP_SDU_SENT_SAP_TOT,
                                                                  COUNTER_ID_UL_PDCP_SDU_DLY_CUUP, LOCAL_MOID_CELL)

    pmqap_avg_delay = calculate_average_delay_from_vcu_pm_counters(COUNTER_ID_UL_PDCP_SDU_SENT_SAP_TOT_PMQAP,
                                                                   COUNTER_ID_UL_PDCP_SDU_DLY_CUUP_PMQAP,
                                                                   LOCAL_MOID_PMQAP)

    legacy_ul_delay = calculate_average_delay_from_vcu_pm_counters(COUNTER_ID_UL_PDCP_SDU_SNT_S1U_QOS_GRP_09,
                                                                   COUNTER_ID_UL_DELAY_QOS_GRP_09, LOCAL_MOID_BTS)
    cell_and_pmqap_average_delay_should_be_equal(cell_avg_delay, pmqap_avg_delay)
    compare_delay(legacy_ul_delay, cell_avg_delay)
    margin_range = calculate_value_margin(margin, expected_ul_delay)
    verify_calculated_delay(cell_avg_delay, pmqap_avg_delay, margin_range, legacy_delay=legacy_ul_delay)


def calculate_average_delay_from_vdu_pm_counters(counter_id_total_packets, counter_id_total_delay, local_moid):
    total_packets = get_du_counter(counter_id_total_packets, local_moid)
    total_delay = get_du_counter(counter_id_total_delay, local_moid)
    return total_delay / total_packets / 1000


def calculate_average_delay_from_vcu_pm_counters(counter_id_total_packets, counter_id_total_delay, local_moid):
    total_packets = get_cu_counter(counter_id_total_packets, local_moid)
    total_delay = get_cu_counter(counter_id_total_delay, local_moid)
    return total_delay / total_packets / 1000


def calculate_average_delay_from_vcu_legacy_pm_counters(counter_id_total_sa_packets, counter_id_total_delay,
                                                        local_moid):
    sa_packets = get_cu_counter(counter_id_total_sa_packets, local_moid)
    total_delay = get_cu_counter(counter_id_total_delay, local_moid)
    return total_delay / sa_packets / 1000


def cell_and_pmqap_average_delay_should_be_equal(cell_avg_delay, pmqap_avg_delay):
    if cell_avg_delay != pmqap_avg_delay:
        raise ExecutionFailed(message='The values of delay for cell {} and for pmqap {} are different'.format(
            cell_avg_delay, pmqap_avg_delay), continue_on_failure=True)


def compare_delay(dealay_01, dealay_02, margin='2%'):
    margin = float(margin.strip('%')) / 100
    division = round(abs(1 - dealay_01 / dealay_02) * 100, 1)
    if float(division) > float(margin):
        raise ExecutionFailed(
            message="Counters deviation is out of range. Expected max deviation {}. Current deviation - {:.1f}%"
            .format(margin, division),
            continue_on_failure=True,
        )


def verify_calculated_delay(cell_delay, pmqap_delay, margin_range, legacy_delay=None):
    cell_avg_delay = round(cell_delay, 4)
    pmqap_avg_delay = round(pmqap_delay, 4)
    min_range = round(min(margin_range), 4)
    max_range = round(max(margin_range), 4)
    print('Calculated dl cell delay {}'.format(cell_avg_delay))
    print('Calculated dl pmqap delay {}'.format(pmqap_avg_delay))
    if legacy_delay:
        legacy_avg_delay = round(legacy_delay, 4)
        print('Calculated dl legacy delay {}'.format(legacy_avg_delay))
    statistic_table = [["Reached Level", "Expected Min", "Expected Max"],
                       [cell_avg_delay, min_range, max_range]]
    logger.console(tabulate(statistic_table))
    if cell_avg_delay < min_range or cell_avg_delay > max_range:
        raise ExecutionFailed(
            message="Calculated delay doesn't have value in range ({} - {}) Current value - {}".format(
                min_range, max_range, cell_avg_delay),
            continue_on_failure=True,
        )
