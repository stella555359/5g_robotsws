from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed

COUNTER_ID_DL_SDU_DISC_TMR_QOS_GRP_20 = 'M55320C20020'
COUNTER_ID_DL_DELAY_QOS_GRP_20 = 'M55319C09020'
COUNTER_ID_DL_SDU_TX_SA_QOS_GRP_20 = 'M55319C11020'
LOCAL_MOID = 'PLMN-PLMN/MRBTS-1/NRBTS-1'


def check_if_counters_have_any_value(counter_values):
    if len(counter_values) == 0:
        raise ExecutionFailed(
            message="The PM counter doesn't have values",
            continue_on_failure=True)
    else:
        return counter_values


def get_pm_counter_file():
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    ta5g_pm.wait_for_next_full_pm_interval()
    ta5g_pm.wait_for_next_full_pm_interval()
    pm_counter_file = ta5g_pm.get_latest_unpacked_full_pm_counters_file()
    return pm_counter_file


def check_timer_discarding(lower_packet_threshold, pm_counter_file):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    num_sdu_disc = ta5g_pm.get_latest_pm_counter_value(
        COUNTER_ID_DL_SDU_DISC_TMR_QOS_GRP_20, LOCAL_MOID, pm_counter_file)
    if int(num_sdu_disc) < int(lower_packet_threshold):
        raise ExecutionFailed(
             message="Number of sdu discard:{} due to timer discard is lower than {}".format(num_sdu_disc,
                                                                                             lower_packet_threshold))
    else:
        print('Number of SDU discards due to timer:{}'.format(num_sdu_disc))


def check_dl_pdcp_sdu_delay(expected_delay_ms, pm_counter_file):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    delay_counter_value = ta5g_pm.get_latest_pm_counter_value(
        COUNTER_ID_DL_DELAY_QOS_GRP_20, LOCAL_MOID, pm_counter_file)
    sdu_num_counter_value = ta5g_pm.get_latest_pm_counter_value(
        COUNTER_ID_DL_SDU_TX_SA_QOS_GRP_20, LOCAL_MOID, pm_counter_file)
    if sdu_num_counter_value == 0:
        raise ExecutionFailed(
            message="The PM counter DL_SDU_TX_SA_QOS_GRP_20 equals to 0'",
            continue_on_failure=True)
    pdcp_delay_ms = (delay_counter_value/sdu_num_counter_value)/1000
    if int(pdcp_delay_ms) > int(expected_delay_ms):
        raise ExecutionFailed(
            message="The calculated delay {} from COUNTER_ID_DL_DELAY_QOS_GRP_20/COUNTER_ID_DL_SDU_TX_SA_QOS_GRP_20 "
                    "is bigger that expected delay ms {} '".format(pdcp_delay_ms, expected_delay_ms),
            continue_on_failure=True)
    else:
        print('Calculated delay:{}'.format(pdcp_delay_ms))


def check_pm_counters_for_timer_discarding_and_pdcp_packet_delay():
    pm_file = get_pm_counter_file()
    check_timer_discarding(lower_packet_threshold=1000, pm_counter_file=pm_file)
    check_dl_pdcp_sdu_delay(expected_delay_ms=110, pm_counter_file=pm_file)
