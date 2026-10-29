# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Pawel Konieczny
:contact: pawel.konieczny@nokia.com
"""
from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed

LOCAL_MOID_BTS_CELL1 = 'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1'
LOCAL_MOID_BTS_CELL2 = 'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-2'
LOCAL_MOID_BTS = 'PLMN-PLMN/MRBTS-1/NRBTS-1'
PMQAP = 'PLMN-PLMN/MCC-311/MNC-489'
COUNTER_ID_PRB_USED_PUSCH_PLMN = 'M55338C00002'
COUNTER_ID_UL_PRB_UTIL_RATIO_DNOM_PLMN = 'M55338C00004'
COUNTER_ID_UL_PRB_USED_DATA_NRG = 'COUNTER_ID_UL_PRB_USED_DATA_NRG'
COUNTER_ID_UL_PRB_UTIL_RATIO_DNOM = 'M55910C00003'
COUNTER_ID_DL_PRB_UTIL_RATIO_DNOM_PLMN = 'M55338C00003'
COUNTER_ID_DL_PRB_USED_DATA_NRG = 'M55910C00001'
COUNTER_ID_DL_PRB_UTIL_RATIO_DNOM = 'M55910C00028'


def check_if_values_of_counters_covers_set_target_share(target_share=0.5, local_moid=LOCAL_MOID_BTS_CELL1,
                                                        pm_counter_numerator=COUNTER_ID_PRB_USED_PUSCH_PLMN,
                                                        pm_counter_denumerator=COUNTER_ID_UL_PRB_UTIL_RATIO_DNOM_PLMN,
                                                        pmqap=PMQAP, margin=0.015):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    pm_counters = ta5g_pm.get_latest_unpacked_raw_pm_counters_file()
    numerator = ta5g_pm.get_latest_pm_counter_value(pm_counter_numerator, local_moid, pm_counters, pmqap)
    if numerator == 0:
        raise ExecutionFailed(
            message="The PM counter {} has value 0".format(pm_counter_numerator),
            continue_on_failure=True,
        )
    denumerator = ta5g_pm.get_latest_pm_counter_value(pm_counter_denumerator, local_moid, pm_counters, pmqap)
    if denumerator == 0:
        raise ExecutionFailed(
            message="The PM counter {} has value 0".format(pm_counter_denumerator),
            continue_on_failure=True,
        )
    calculated_share = float(numerator) / float(denumerator)
    if calculated_share > target_share + margin:
        raise ExecutionFailed(message='The values of calculated share {} is bigger than set share {}'.format(
            calculated_share, target_share), continue_on_failure=True)
    elif calculated_share < target_share - margin:
        raise ExecutionFailed(message='The values of calculated share {} is lower than set share {}'.format(
            calculated_share, target_share), continue_on_failure=True)
    else:
        print('Numerator {} value {}'.format(pm_counter_numerator, numerator))
        print('Denumerator {} value {}'.format(pm_counter_denumerator, denumerator))
        print('Calculated share {}'.format(calculated_share))


def check_if_values_of_counters_have_bigger_target_share(target_share=0.5, local_moid=LOCAL_MOID_BTS_CELL1,
                                                         pm_counter_numerator=COUNTER_ID_PRB_USED_PUSCH_PLMN,
                                                         pm_counter_denumerator=COUNTER_ID_UL_PRB_UTIL_RATIO_DNOM_PLMN,
                                                         pmqap=PMQAP):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    pm_counters = ta5g_pm.get_latest_unpacked_raw_pm_counters_file()
    numerator = ta5g_pm.get_latest_pm_counter_value(pm_counter_numerator, local_moid, pm_counters, pmqap)
    if numerator == 0:
        raise ExecutionFailed(
            message="The PM counter {} has value 0".format(pm_counter_numerator),
            continue_on_failure=True,
        )
    denumerator = ta5g_pm.get_latest_pm_counter_value(pm_counter_denumerator, local_moid, pm_counters, pmqap)
    if denumerator == 0:
        raise ExecutionFailed(
            message="The PM counter {} has value 0".format(pm_counter_denumerator),
            continue_on_failure=True,
        )
    calculated_share = float(numerator) / float(denumerator)
    if calculated_share < target_share + 0.015:
        raise ExecutionFailed(message='The values of calculated share is only {}. Set target share: {}'.format(
            calculated_share, target_share), continue_on_failure=True)
    else:
        print('Numerator {} value {}'.format(pm_counter_numerator, numerator))
        print('Denumerator {} value {}'.format(pm_counter_denumerator, denumerator))
        print('Calculated share {}'.format(calculated_share))
