from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed
from collections import OrderedDict
from robot.api import logger
from tabulate import tabulate

LOCAL_MOID_BTS_CELL1 = 'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1'
COUNTER_ID_UL_RLC_VOL_UE_TPUT_PMQAP = 'M55353C00001'
COUNTER_ID_UL_RLC_VOL_UE_TPUT_QOS06 = 'M55349C01006'
COUNTER_ID_UL_RLC_TIME_UE_TPUT_PMQAP = 'M55353C01001'
COUNTER_ID_UL_RLC_TIME_UE_TPUT_QOS06 = 'M55349C00006'
COUNTER_ID_DL_PDCP_VOL_UE_TPUT_QOS06 = 'M55350C01006'
COUNTER_ID_DL_PDCP_VOL_UE_TPUT_PMQAP = 'M55352C01001'
COUNTER_ID_DL_PDCP_TIME_UE_TPUT_PMQAP = 'M55352C00001'
COUNTER_ID_DL_PDCP_TIME_UE_TPUT_QOS06 = 'M55350C00006'
COUNTER_ID_DL_PDCP_VOL_UE_TPUT_LTE_QOS06 = 'M55350C05006'
COUNTER_ID_NSA_DL_VOL_SNT_CU_F1 = 'M55350C00043'
COUNTER_ID_NSA_UL_VOL_RCV_CU_F1 = 'M55350C00044'
COUNTER_ID_NSA_DL_VOL_SNT_CU_X2 = 'M55350C00045'
COUNTER_ID_NSA_UL_VOL_RCV_CU_X2 = 'M55350C00046'
COUNTER_ID_DL_VOL_SNT_F1_PMQAP = 'M55362C00003'
COUNTER_ID_UL_VOL_RCV_F1_PMQAP = 'M55362C00004'
COUNTER_ID_DL_PDCP_VOL_SNT_X2_PMQAP = 'M55364C00003'
COUNTER_ID_UL_PDCP_VOL_RCV_X2_PMQAP = 'M55364C00004'


class PmCountersValidator(object):

    def get_counter_values(self, counter_id, local_moid, pm_counters_file):
        ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
        counter_values = ta5g_pm.get_pm_counter_value(counter_id, local_moid, pm_counters_file)
        if len(counter_values) == 0:
            raise ExecutionFailed(
                message="The PM counter {} doesn't have values'".format(counter_id),
                continue_on_failure=True,
            )
        return counter_values

    def verify_if_pm_counter_has_exactly_value(self, counter_id, pm_counters_values, expected_value, margin='1%'):
        margin_range = calculate_value_margin(margin, expected_value)
        if isinstance(pm_counters_values, list):
            values = pm_counters_values
        else:
            values = [pm_counters_values]
        for counter_value in values:
            if (float(counter_value) < min(margin_range)) or (float(counter_value) > max(margin_range)):
                raise ExecutionFailed(
                    message="The PM counter {} doesn't have value in range ({} - {}) Current value - {}".format(
                        counter_id, min(margin_range), max(margin_range), counter_value
                    ),
                    continue_on_failure=True,
                )

    def verify_if_latest_pm_counter_is_lower_than_the_given_value(self, counter_id, value, local_moid,
                                                                  pm_counters_file):
        logger.console("Counter {} verification".format(counter_id))
        actual_value = self.get_counter_values(counter_id=counter_id, local_moid=local_moid,
                                               pm_counters_file=pm_counters_file)
        logger.trace(
            'The PM counter {} actual value: {}, expected value: {}'.format(counter_id, actual_value, value), html=True
        )
        if actual_value >= int(value):
            raise ExecutionFailed(
                message='The PM counter {} actual value: {} is not lower than {}'.format(
                    counter_id, actual_value, value
                ),
                continue_on_failure=True,
            )

    def verify_if_latest_pm_counter_is_bigger_than_the_given_value(self, counter_id, value, local_moid,
                                                                   pm_counters_file):
        logger.console("Counter {} verification".format(counter_id))
        actual_value = self.get_counter_values(counter_id=counter_id, local_moid=local_moid,
                                               pm_counters_file=pm_counters_file)
        logger.trace(
            'The PM counter {} actual value: {}, expected value: {}'.format(counter_id, actual_value, value), html=True
        )
        list_value = map(int, str(value))
        if actual_value <= list(list_value):
            raise ExecutionFailed(
                message='The PM counter {} actual value: {} is not bigger than {}'.format(
                    counter_id, actual_value, value
                ),
                continue_on_failure=True,
            )

    def verify_if_latest_pm_counter_has_exact_value(self, counter_id, value, local_moid, pm_counters_file):
        logger.console("Counter {} verification".format(counter_id))
        actual_value = self.get_counter_values(counter_id=counter_id, local_moid=local_moid,
                                               pm_counters_file=pm_counters_file)
        logger.trace(
            'The PM counter {} actual value: {}, expected value: {}'.format(counter_id, actual_value, value), html=True
        )
        if actual_value != int(value):
            raise ExecutionFailed(
                message='The PM counter {} actual value: {} is not equal to {}'.format(counter_id,
                                                                                       actual_value, value),
                continue_on_failure=True,
            )


def check_if_values_of_pm_counters_are_equivalent(first_counter_id, second_counter_id, pm_counters_file,
                                                  LOCAL_MOID_BTS_CELL1='PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1'):

    actual_value_for_first_counter_id = PmCountersValidator().get_counter_values(counter_id=first_counter_id,
                                                                                 local_moid=LOCAL_MOID_BTS_CELL1,
                                                                                 pm_counters_file=pm_counters_file)
    actual_value_for_second_counter_id = PmCountersValidator().get_counter_values(counter_id=second_counter_id,
                                                                                  local_moid=LOCAL_MOID_BTS_CELL1,
                                                                                  pm_counters_file=pm_counters_file)

    if all(actual_value_for_first_counter_id == 0 for actual_value_for_first_counter_id in
           actual_value_for_first_counter_id) or \
       all(actual_value_for_second_counter_id == 0 for actual_value_for_second_counter_id in
           actual_value_for_second_counter_id):
        raise ExecutionFailed(
            message='The values of PM counters {} {} or {}{} are equal to 0'.format(
                first_counter_id, actual_value_for_first_counter_id, second_counter_id,
                actual_value_for_second_counter_id),
            continue_on_failure=True,
        )
    elif actual_value_for_first_counter_id != actual_value_for_second_counter_id:
        raise ExecutionFailed(
            message='The values of PM counters {} {} and {}{} are different'.format(
                first_counter_id, actual_value_for_first_counter_id, second_counter_id,
                actual_value_for_second_counter_id),
            continue_on_failure=True,
        )


def get_sum_of_counter_value_from_qos_group(counters_id_list, local_moid, pm_counters_file):
    counters_value_dict = OrderedDict()
    for id_counter in counters_id_list:
        counters_value_dict[id_counter] = (PmCountersValidator().get_counter_values(counter_id=id_counter,
                                                                                    local_moid=local_moid,
                                                                                    pm_counters_file=pm_counters_file))
    return sum(counters_value_dict.values())


def get_value_of_ue_tput_counter_tot(counter_id_tot, local_moid, pm_counters_file):
    return PmCountersValidator().get_counter_values(counter_id=counter_id_tot, local_moid=local_moid,
                                                    pm_counters_file=pm_counters_file)


def compare_all_qos_group_counters_and_ue_tput_tot_counters(counters_id_list_qos_group, counter_id_tot):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    ta5g_pm.wait_for_next_full_pm_interval()
    pm_counters_file = ta5g_pm.get_latest_unpacked_full_pm_counters_file()
    actual_value_for_qos_group = get_sum_of_counter_value_from_qos_group(counters_id_list_qos_group,
                                                                         LOCAL_MOID_BTS_CELL1, pm_counters_file)
    actual_value_for_tot = get_value_of_ue_tput_counter_tot(counter_id_tot, LOCAL_MOID_BTS_CELL1, pm_counters_file)
    if actual_value_for_qos_group != actual_value_for_tot:
        raise ExecutionFailed(
            message='The values of PM counters {} and {} are different'.format(
                actual_value_for_qos_group, actual_value_for_tot),
            continue_on_failure=True,
        )


def check_pmqap_counters_for_dl_and_ul(LOCAL_MOID_BTS_CELL1='PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1'):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    ta5g_pm.wait_for_next_full_pm_interval()
    pm_counters_file = ta5g_pm.get_latest_unpacked_full_pm_counters_file()
    PmCountersValidator().verify_if_latest_pm_counter_is_bigger_than_the_given_value(
        COUNTER_ID_DL_PDCP_VOL_UE_TPUT_PMQAP, 0, LOCAL_MOID_BTS_CELL1, pm_counters_file)
    PmCountersValidator().verify_if_latest_pm_counter_is_bigger_than_the_given_value(
        COUNTER_ID_DL_PDCP_TIME_UE_TPUT_PMQAP, 0, LOCAL_MOID_BTS_CELL1, pm_counters_file)
    PmCountersValidator().verify_if_latest_pm_counter_is_bigger_than_the_given_value(
        COUNTER_ID_UL_RLC_VOL_UE_TPUT_PMQAP, 0, LOCAL_MOID_BTS_CELL1, pm_counters_file)
    DL_PDCP_VOL_UE_TPUT_QOS06 = PmCountersValidator().get_counter_values(COUNTER_ID_DL_PDCP_VOL_UE_TPUT_QOS06,
                                                                         LOCAL_MOID_BTS_CELL1, pm_counters_file)
    DL_PDCP_TIME_UE_TPUT_QOS06 = PmCountersValidator().get_counter_values(COUNTER_ID_DL_PDCP_TIME_UE_TPUT_QOS06,
                                                                          LOCAL_MOID_BTS_CELL1, pm_counters_file)
    DL_PDCP_VOL_UE_TPUT_PMQAP = PmCountersValidator(). \
        get_counter_values(counter_id=COUNTER_ID_DL_PDCP_VOL_UE_TPUT_PMQAP, local_moid=LOCAL_MOID_BTS_CELL1,
                           pm_counters_file=pm_counters_file)
    DL_PDCP_TIME_UE_TPUT_PMQAP = PmCountersValidator(). \
        get_counter_values(counter_id=COUNTER_ID_DL_PDCP_TIME_UE_TPUT_PMQAP, local_moid=LOCAL_MOID_BTS_CELL1,
                           pm_counters_file=pm_counters_file)

    if int(DL_PDCP_VOL_UE_TPUT_PMQAP[0]) != int(DL_PDCP_VOL_UE_TPUT_QOS06[0]):
        raise ExecutionFailed(
            message='The PM PMQAP counter {} are not the same as legacy'.format(
                'DL_PDCP_VOL_UE_TPUT_PMQAP'),
            continue_on_failure=True,
        )
    if int(DL_PDCP_TIME_UE_TPUT_PMQAP[0]) != int(DL_PDCP_TIME_UE_TPUT_QOS06[0]):
        raise ExecutionFailed(
            message='The PM PMQAP counter {} are not the same as legacy'.format(
                'DL_PDCP_TIME_UE_TPUT_PMQAP'),
            continue_on_failure=True,
        )

    UL_RLC_VOL_UE_TPUT_QOS06 = PmCountersValidator(). \
        get_counter_values(COUNTER_ID_UL_RLC_VOL_UE_TPUT_QOS06, LOCAL_MOID_BTS_CELL1, pm_counters_file)
    UL_RLC_TIME_UE_TPUT_QOS06 = PmCountersValidator(). \
        get_counter_values(COUNTER_ID_UL_RLC_TIME_UE_TPUT_QOS06, LOCAL_MOID_BTS_CELL1, pm_counters_file)
    UL_RLC_VOL_UE_TPUT_PMQAP = PmCountersValidator(). \
        get_counter_values(COUNTER_ID_UL_RLC_VOL_UE_TPUT_PMQAP, LOCAL_MOID_BTS_CELL1, pm_counters_file)
    UL_RLC_TIME_UE_TPUT_PMQAP = PmCountersValidator(). \
        get_counter_values(COUNTER_ID_UL_RLC_TIME_UE_TPUT_PMQAP,
                           LOCAL_MOID_BTS_CELL1, pm_counters_file)

    if int(UL_RLC_VOL_UE_TPUT_PMQAP[0]) != int(UL_RLC_VOL_UE_TPUT_QOS06[0]):
        raise ExecutionFailed(
            message='The PM PMQAP counter {} are not the same as legacy'.format(
                'UL_RLC_VOL_UE_TPUT_PMQAP'),
            continue_on_failure=True,
        )
    if int(UL_RLC_TIME_UE_TPUT_PMQAP[0]) != int(UL_RLC_TIME_UE_TPUT_QOS06[0]):
        raise ExecutionFailed(
            message='The PM PMQAP counter {} are not the same as legacy'.format(
                'UL_RLC_TIME_UE_TPUT_PMQAP'),
            continue_on_failure=True,
        )


def check_pmqap_counters_values(nrpmqap_ids, pm_counters_file):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    counter_values = []
    for pmqap in range(1, int(nrpmqap_ids)+1):
        pmqap_counters_values_list = ta5g_pm.verify_if_latest_pm_counters_from_the_list_are_bigger_than_the_given_value(
            [COUNTER_ID_UL_RLC_VOL_UE_TPUT_PMQAP, COUNTER_ID_UL_RLC_TIME_UE_TPUT_PMQAP,
             COUNTER_ID_DL_PDCP_VOL_UE_TPUT_PMQAP, COUNTER_ID_DL_PDCP_TIME_UE_TPUT_PMQAP], 0,
            local_moid=f'PLMN-PLMN/NRPMQAP-{pmqap}',
            filepath=pm_counters_file)
        counter_values.append(pmqap_counters_values_list)
    return counter_values


def check_if_pm_counters_are_in_expected_value_range(counter_id, local_moid, min_val, max_val):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    pm_counters_file = ta5g_pm.get_latest_unpacked_full_pm_counters_file()
    actual_value = ta5g_pm.get_pm_counter_value(counter_id, local_moid, pm_counters_file)
    statistic_table = [["Reached value", "Expected Min", "Expected Max"],
                       [actual_value[0], min_val, max_val]]
    logger.console(tabulate(statistic_table))
    if (actual_value[0] < int(min_val)) or (actual_value[0] > int(max_val)):
        raise ExecutionFailed(
                message="Counter value is not in expected range ({} - {}) Current value - {}".format(
                    min_val, max_val, actual_value[0]),
                continue_on_failure=True,
            )
    return actual_value


def check_tput_f1_counters_for_dl_and_ul(LOCAL_MOID_BTS_CELL1='PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1'):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    ta5g_pm.wait_for_next_full_pm_interval()
    pm_counters_file = ta5g_pm.get_latest_unpacked_full_pm_counters_file()
    PmCountersValidator().verify_if_latest_pm_counter_is_bigger_than_the_given_value(
        COUNTER_ID_NSA_DL_VOL_SNT_CU_F1, 0, LOCAL_MOID_BTS_CELL1, pm_counters_file)
    PmCountersValidator().verify_if_latest_pm_counter_is_bigger_than_the_given_value(
        COUNTER_ID_NSA_UL_VOL_RCV_CU_F1, 0, LOCAL_MOID_BTS_CELL1, pm_counters_file)
    PmCountersValidator().verify_if_latest_pm_counter_is_bigger_than_the_given_value(
        COUNTER_ID_DL_VOL_SNT_F1_PMQAP, 0, LOCAL_MOID_BTS_CELL1, pm_counters_file)
    PmCountersValidator().verify_if_latest_pm_counter_is_bigger_than_the_given_value(
        COUNTER_ID_UL_VOL_RCV_F1_PMQAP, 0, LOCAL_MOID_BTS_CELL1, pm_counters_file)
    NSA_DL_VOL_SNT_CU_F1 = PmCountersValidator().get_counter_values(COUNTER_ID_NSA_DL_VOL_SNT_CU_F1,
                                                                    LOCAL_MOID_BTS_CELL1, pm_counters_file)
    NSA_UL_VOL_RCV_CU_F1 = PmCountersValidator().get_counter_values(COUNTER_ID_NSA_UL_VOL_RCV_CU_F1,
                                                                    LOCAL_MOID_BTS_CELL1, pm_counters_file)
    DL_VOL_SNT_F1_PMQAP = PmCountersValidator().get_counter_values(COUNTER_ID_DL_VOL_SNT_F1_PMQAP,
                                                                   LOCAL_MOID_BTS_CELL1, pm_counters_file)
    UL_VOL_RCV_F1_PMQAP = PmCountersValidator().get_counter_values(COUNTER_ID_UL_VOL_RCV_F1_PMQAP,
                                                                   LOCAL_MOID_BTS_CELL1, pm_counters_file)

    if int(NSA_DL_VOL_SNT_CU_F1[0]) != int(DL_VOL_SNT_F1_PMQAP[0]):
        raise ExecutionFailed(
            message='The PM PMQAP counter {} are not the same as legacy'.format(
                'DL_VOL_SNT_F1_PMQAP'),
            continue_on_failure=True,
        )
    if int(NSA_UL_VOL_RCV_CU_F1[0]) != int(UL_VOL_RCV_F1_PMQAP[0]):
        raise ExecutionFailed(
            message='The PM PMQAP counter {} are not the same as legacy'.format(
                'UL_VOL_RCV_F1_PMQAP'),
            continue_on_failure=True,
        )


def check_tput_x2_counters_for_dl_and_ul(LOCAL_MOID_BTS_CELL1='PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1'):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    ta5g_pm.wait_for_next_full_pm_interval()
    pm_counters_file = ta5g_pm.get_latest_unpacked_full_pm_counters_file()
    PmCountersValidator().verify_if_latest_pm_counter_is_bigger_than_the_given_value(
        COUNTER_ID_NSA_DL_VOL_SNT_CU_X2, 0, LOCAL_MOID_BTS_CELL1, pm_counters_file)
    PmCountersValidator().verify_if_latest_pm_counter_is_bigger_than_the_given_value(
        COUNTER_ID_NSA_UL_VOL_RCV_CU_X2, 0, LOCAL_MOID_BTS_CELL1, pm_counters_file)
    PmCountersValidator().verify_if_latest_pm_counter_is_bigger_than_the_given_value(
        COUNTER_ID_DL_PDCP_VOL_SNT_X2_PMQAP, 0, LOCAL_MOID_BTS_CELL1, pm_counters_file)
    PmCountersValidator().verify_if_latest_pm_counter_is_bigger_than_the_given_value(
        COUNTER_ID_UL_PDCP_VOL_RCV_X2_PMQAP, 0, LOCAL_MOID_BTS_CELL1, pm_counters_file)
    NSA_DL_VOL_SNT_CU_X2 = PmCountersValidator().get_counter_values(COUNTER_ID_NSA_DL_VOL_SNT_CU_X2,
                                                                    LOCAL_MOID_BTS_CELL1, pm_counters_file)
    NSA_UL_VOL_RCV_CU_X2 = PmCountersValidator().get_counter_values(COUNTER_ID_NSA_UL_VOL_RCV_CU_X2,
                                                                    LOCAL_MOID_BTS_CELL1, pm_counters_file)
    DL_PDCP_VOL_SNT_X2_PMQAP = PmCountersValidator().get_counter_values(COUNTER_ID_DL_PDCP_VOL_SNT_X2_PMQAP,
                                                                        LOCAL_MOID_BTS_CELL1, pm_counters_file)
    UL_PDCP_VOL_RCV_X2_PMQAP = PmCountersValidator().get_counter_values(COUNTER_ID_UL_PDCP_VOL_RCV_X2_PMQAP,
                                                                        LOCAL_MOID_BTS_CELL1, pm_counters_file)

    if int(NSA_DL_VOL_SNT_CU_X2[0]) != int(DL_PDCP_VOL_SNT_X2_PMQAP[0]):
        raise ExecutionFailed(
            message='The PM PMQAP counter {} are not the same as legacy'.format(
                'DL_PDCP_VOL_SNT_X2_PMQAP'),
            continue_on_failure=True,
        )
    if int(NSA_UL_VOL_RCV_CU_X2[0]) != int(UL_PDCP_VOL_RCV_X2_PMQAP[0]):
        raise ExecutionFailed(
            message='The PM PMQAP counter {} are not the same as legacy'.format(
                'UL_PDCP_VOL_RCV_X2_PMQAP'),
            continue_on_failure=True,
        )
