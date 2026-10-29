# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Pawel Konieczny
:contact: pawel.konieczny@nokia.com
"""
from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed

LOCAL_MOID_BTS_CELL1 = 'PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1'
COUNTER_ID_DL_RLC_VOL_TX_H_QOS_GRP_06 = 'M55311C01006'
COUNTER_ID_DL_RLC_PDU_RETX_H_QOS_GRP_06 = 'M55311C06006'


def check_if_proportion_between_m55311c06006_and_m55311c01006_is_better_than_without_cni80040(
        local_moid=LOCAL_MOID_BTS_CELL1, margin="1%"):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    ta5g_pm.wait_for_next_full_pm_interval()
    pm_counters = ta5g_pm.get_latest_unpacked_full_pm_counters_file()
    DL_RLC_VOL_TX_H_QOS_GRP_06 = get_counter_values(COUNTER_ID_DL_RLC_VOL_TX_H_QOS_GRP_06, local_moid,
                                                    pm_counters)
    DL_RLC_PDU_RETX_H_QOS_GRP_06 = get_counter_values(COUNTER_ID_DL_RLC_PDU_RETX_H_QOS_GRP_06, local_moid,
                                                      pm_counters)
    check_counter_incrementation(COUNTER_ID_DL_RLC_VOL_TX_H_QOS_GRP_06, DL_RLC_VOL_TX_H_QOS_GRP_06)
    check_counter_incrementation(COUNTER_ID_DL_RLC_PDU_RETX_H_QOS_GRP_06, DL_RLC_PDU_RETX_H_QOS_GRP_06)
    DL_RLC_VOL_TX_H_QOS_GRP_06_SUM = sum(DL_RLC_VOL_TX_H_QOS_GRP_06)
    DL_RLC_PDU_RETX_H_QOS_GRP_06_SUM = sum(DL_RLC_PDU_RETX_H_QOS_GRP_06)
    counters_proportion = DL_RLC_VOL_TX_H_QOS_GRP_06_SUM / DL_RLC_PDU_RETX_H_QOS_GRP_06_SUM
    if counters_proportion < 100:
        raise ExecutionFailed(
            message="proportion between DL_RLC_VOL_TX_H_QOS_GRP_06 - {} , and DL_RLC_PDU_RETX_H_QOS_GRP_06 - {} , "
                    "is -  {} instead of over 100 ".format(DL_RLC_VOL_TX_H_QOS_GRP_06_SUM,
                                                           DL_RLC_PDU_RETX_H_QOS_GRP_06_SUM,
                                                           counters_proportion),
            continue_on_failure=True,
        )
    else:
        pass


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


def check_counter_incrementation(counter_id, pm_counters_values, ):
    if not isinstance(pm_counters_values, list):
        values = [pm_counters_values]
    else:
        values = pm_counters_values
    for counter_value in values:
        if float(counter_value) == 0:
            raise ExecutionFailed(message="The PM counter {} doesn't have value bigger than 0",
                                  continue_on_failure=True,
                                  )
