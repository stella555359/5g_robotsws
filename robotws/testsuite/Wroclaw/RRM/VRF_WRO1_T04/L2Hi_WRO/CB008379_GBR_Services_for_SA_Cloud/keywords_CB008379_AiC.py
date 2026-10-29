from robot.errors import ExecutionFailed
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources.common_keywords_vran import get_cu_counter

COUNTER_ID_DL_SDU_DISC_TMR_QOS_GRP_03 = 'M55320C20003'
COUNTER_ID_DL_DELAY_QOS_GRP_03 = 'M55319C09003'
COUNTER_ID_DL_SDU_TX_SA_QOS_GRP_03 = 'M55319C11003'


def check_aic_pm_counters_for_timer_discarding_and_pdcp_packet_delay():
    check_aic_timer_discarding(lower_packet_threshold=1000)
    check_dl_pdcp_sdu_delay(expected_delay_ms=110)


def check_aic_timer_discarding(lower_packet_threshold):
    num_sdu_disc = get_cu_counter(counter_id=COUNTER_ID_DL_SDU_DISC_TMR_QOS_GRP_03, local_moid='MRBTS-1/NRBTS-1')
    if int(num_sdu_disc) < int(lower_packet_threshold):
        raise ExecutionFailed(
             message="Number of sdu discard:{} due to timer discard is lower than {}".format(num_sdu_disc,
                                                                                             lower_packet_threshold),
             continue_on_failure=True)
    else:
        print('Number of SDU discards due to timer:{}'.format(num_sdu_disc))


def check_dl_pdcp_sdu_delay(expected_delay_ms):
    delay_counter_value = get_cu_counter(counter_id=COUNTER_ID_DL_DELAY_QOS_GRP_03, local_moid='MRBTS-1/NRBTS-1')
    sdu_num_counter_value = get_cu_counter(counter_id=COUNTER_ID_DL_SDU_TX_SA_QOS_GRP_03, local_moid='MRBTS-1/NRBTS-1')
    if sdu_num_counter_value == 0:
        raise ExecutionFailed(
            message="The PM counter DL_SDU_TX_SA_QOS_GRP_03 equals to 0'",
            continue_on_failure=True)
    pdcp_delay_ms = (int(delay_counter_value)/int(sdu_num_counter_value))/1000
    if int(pdcp_delay_ms) > int(expected_delay_ms):
        raise ExecutionFailed(
            message="The calculated delay {} from COUNTER_ID_DL_DELAY_QOS_GRP_03/COUNTER_ID_DL_SDU_TX_SA_QOS_GRP_03"
                    "is bigger that expected delay ms {} '".format(pdcp_delay_ms, expected_delay_ms),
            continue_on_failure=True)
    else:
        print('Calculated delay:{}'.format(pdcp_delay_ms))
