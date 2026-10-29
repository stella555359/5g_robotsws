# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:mantainer: Michal Maczek, Kamil Bucki
:contact: michal.maczek@nokia.com, kamil.bucki@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import (
    logger_console, logger_console_info, logger_warning
)

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.pm_counters import (
    get_pm_counters_values,
    get_latest_values_for_specified_counters
)

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.counters import (
    get_latest_value_for_counters, get_latest_counter_value, get_list_of_counter_values
)
from robot.libraries.BuiltIn import BuiltIn


class CountersDirListDoesNotContainSuchIndexException(Exception):
    pass


class CounterValuesAreEmptyOrNoneException(Exception):
    pass


class ArgumentsAreNoneOrEmptyException(Exception):
    pass


class CounterValuesListSumDoesNotEqualToExpectedValueException(Exception):
    pass


class UnsupportedResourceGroupException(Exception):
    pass


class ValueOutOfRangeException(Exception):
    pass


class UnexpectedUtilizationRatioException(Exception):
    pass


class WrongUsedPrbsPercentValuesForMuMimoException(Exception):
    pass


class DifferentCounterListLengthException(Exception):
    pass


class DifferentCounterValuesAtListException(Exception):
    pass


class WrongPercentValueOfCounter1ComparedToCounter2Exception(Exception):
    pass


class VendorFileIsNotActivatedException(Exception):
    pass


class DssCountersNotCorrectException(Exception):
    pass


def __logger_console_double(msg):
    logger_console(msg)
    logger_console_info(msg)


def retrieve_counter_dir_through_timestamp(index=0):
    if not isinstance(index, int):
        index = int(index)
    dir_list = BuiltIn().get_variable_value("${COUNTER_DIRECTORY_LIST}")
    try:
        logger_console('Retrieved counter directory list, afterwards using index {}:\nList: {}'.format(
            index, dir_list
        ))
        BuiltIn().set_suite_variable("${COUNTER_DIR_VALIDATION}", dir_list[index])
    except IndexError as e:
        msg = 'Looking for index {} in counter dir list:\n{}\nExceptionError: {}'.format(index, dir_list, e)
        raise CountersDirListDoesNotContainSuchIndexException(msg)


def print_counters(counters):
    for counter in counters:
        logger_console("{} : {}".format(counter, BuiltIn().get_variable_value("$" + counter + "_DICT")))


def sum_up_all_counter_values_and_validate(counter_name, expected_sum):
    counter_values = BuiltIn().get_variable_value("${}_VALUES_LIST".format(counter_name))
    if not counter_values:
        msg = '{} does not contain any values!'.format(counter_name)
        logger_warning(msg)
        raise CounterValuesAreEmptyOrNoneException(msg)
    if not isinstance(expected_sum, int):
        expected_sum = int(expected_sum)

    sum_counter_values = sum(list(counter_values))

    if sum_counter_values == expected_sum:
        logger_console('{} counter values sum is equal to {}'.format(counter_name, expected_sum))
        return

    msg = '{} counter values sum is not equal to {}\nActual: {}\nValues: {}'.format(
        counter_name, expected_sum, sum_counter_values, counter_values
    )
    logger_warning(msg)
    raise CounterValuesListSumDoesNotEqualToExpectedValueException(msg)


def check_if_counter_values_are_zero(counter_name):
    sum_up_all_counter_values_and_validate(counter_name, 0)


def check_if_counters_values_are_non_zero(counter_name):
    try:
        sum_up_all_counter_values_and_validate(counter_name, 0)
    except CounterValuesListSumDoesNotEqualToExpectedValueException as e:
        logger_console("{} values are non-zero!".format(counter_name))


def check_if_every_counter_value_is_between_range(counter_name, sd, value_range, skip_first_value=True):
    counter_values = BuiltIn().get_variable_value("${}_VALUES_LIST".format(counter_name))
    if not counter_values:
        msg = '{} does not contain any values!'.format(counter_name)
        logger_warning(msg)
        raise CounterValuesAreEmptyOrNoneException(msg)

    if not sd or not value_range:
        msg = 'sd {} or value_range {} does not contain any value or are None!'.format(sd, value_range)
        logger_warning(msg)
        raise ArgumentsAreNoneOrEmptyException(msg)

    logger_console("{} values list for sd {} -> {}".format(counter_name, sd, counter_values))
    i = 0
    for value in counter_values:
        i += 1

        if value_range[sd]['min'] <= value <= value_range[sd]['max']:
            continue

        if value == 0:
            logger_warning('Found 0 in list for counter {} sd {}!'.format(counter_name, sd))
            continue

        if i == 1 and skip_first_value:
            msg = 'First value {} not in range {} for counter {} sd {}, but skipping as in flag.'
            logger_warning(msg)
            continue

        msg = 'Value {} not between range {} for counter {} sd {}'.format(value, value_range[sd], counter_name, sd)
        logger_warning(msg)
        raise DifferentCounterValuesAtListException(msg)


def save_calculated_and_counter_value_max_utilization_ratio_with_calculated_target_share():
    resource_group_params = BuiltIn().get_variable_value("${RESOURCE_GROUP_PARAMS_DICT}")
    active_quotas_list = __prepare_quotas_list(resource_group_params=resource_group_params)
    for rg, params in resource_group_params.items():
        values = __calculate_max_utilization_ratio_for_prbs(rg=rg, rg_params=params)
        ts = __calculate_target_share(quotas=params['quota'], active_quotas_list=active_quotas_list)

        calculated_name = '$MAX_UTI_RATIO_CALCULATED_SD_{}'.format(params['sd'])
        read_name = "$MAX_UTI_RATIO_COUNTER_VALUE_SD_{}".format(params['sd'])
        ts_name = "$MAX_UTI_RATIO_TARGET_SHARE_SD_{}".format(params['sd'])

        BuiltIn().set_suite_variable(calculated_name, values['calculated'])
        BuiltIn().set_suite_variable(read_name, values['max'])
        BuiltIn().set_suite_variable(ts_name, ts)

        logger_console('Saved variables:\n{} -> {}\n{} -> {}\n{} -> {}\n'.format(
            calculated_name, BuiltIn().get_variable_value(calculated_name),
            read_name, BuiltIn().get_variable_value(read_name),
            ts_name, BuiltIn().get_variable_value(ts_name)
        ))


def validate_if_vendor_file_activated(rg, counter, expected_value):
    logger_console("Checking if vendor file activated...")
    resource_group_params = BuiltIn().get_variable_value("${RESOURCE_GROUP_PARAMS_DICT}")
    rg_params = resource_group_params[rg]
    value = get_latest_counter_value(counter=counter, **rg_params)
    if __check_if_equal(margin=0, value=value, target_value=int(expected_value)):
        msg = "Vendor file activated"
        logger_console(msg)
    else:
        msg = "Vendor file is not activated. Value({}) of counter {} for {} is not equal {}".format(value,
                                                                                                    counter,
                                                                                                    rg,
                                                                                                    expected_value
                                                                                                    )
        raise VendorFileIsNotActivatedException(msg)
    return msg


def validate_utilization_for_rg(ts_margin, counter_utilization_margin, rg, rg_params, active_quotas_list,
                                is_gbr_tc=False):
    ts_margin = float(ts_margin)
    counter_utilization_margin = float(counter_utilization_margin)
    if len(active_quotas_list) <= 1:
        logger_console("Due to only one slice the Target share"
                       " is equal max quota. max quota = {}".format(rg_params['quota']['max'])
                       )
        ts = rg_params['quota']['max']
    else:
        ts = __calculate_target_share(quotas=rg_params['quota'], active_quotas_list=active_quotas_list)

    utilization_values = __calculate_max_utilization_ratio_for_prbs(rg=rg, rg_params=rg_params)
    status, msg = validate_utilization_ratio(ts_margin=ts_margin,
                                             counter_utilization_margin=counter_utilization_margin,
                                             counter_utilization=utilization_values['max'],
                                             calculated_utilization=utilization_values['calculated'],
                                             target_share=ts,
                                             rg=rg,
                                             raise_exception=False,
                                             is_gbr_tc=is_gbr_tc)
    return status, msg


def validate_prb_for_rg(rg, rg_params, prb_margin):
    prb_margin = float(prb_margin)

    prb_values = __calculate_available_prb_for_slice(rg=rg, rg_params=rg_params)
    prb_calculated = prb_values['calculated'] * 100
    logger_console("PrB values will be multiplied by 100\n"
                   "{} * 100 = {}".format(prb_values['calculated'], prb_calculated))
    prb_counter = prb_values['counter']
    validation_msg = ""
    status = __check_if_equal(margin=prb_margin, value=prb_calculated, target_value=prb_counter)
    if status is False:
        validation_msg = "\nCalculated prb ({}) not equal cunter prb value ({} +- {})".format(prb_calculated,
                                                                                              prb_counter,
                                                                                              prb_margin
                                                                                              )

    return status, validation_msg


def counter_e_prb_pooling_validation(ts_margin, prb_margin=50, counter_utilization_margin=2):
    resource_group_params = BuiltIn().get_variable_value("${RESOURCE_GROUP_PARAMS_DICT}")
    passed = True
    exception_msg = ''
    for rg, params in resource_group_params.items():
        logger_console("validating {}...".format(rg))
        active_quotas_list = [params['quota']]
        exception_msg = exception_msg + "\n*************{}*************\n".format(rg)
        uti_status, validation_msg = validate_utilization_for_rg(ts_margin=ts_margin,
                                                                 counter_utilization_margin=counter_utilization_margin,
                                                                 rg=rg,
                                                                 rg_params=params,
                                                                 active_quotas_list=active_quotas_list
                                                                 )

        if uti_status is False:
            passed = False
            exception_msg = exception_msg + validation_msg

        # prb_status, validation_msg = validate_prb_for_rg(rg=rg, rg_params=params, prb_margin=prb_margin)
        # if prb_status is False:
        #     passed = False
        #     exception_msg = exception_msg + validation_msg

    if passed is False:
        logger_console("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        logger_console(exception_msg)
        logger_console("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
        raise UnexpectedUtilizationRatioException(exception_msg)


def counter_e_prb_pooling_and_dss_validation(dss_expected_part, dss_margin):
    dss_margin = float(dss_margin)
    dss_expected_part = float(dss_expected_part)
    resource_group_params = BuiltIn().get_variable_value("${RESOURCE_GROUP_PARAMS_DICT}")

    cell_list = __get_cell_list_from_params(rg_params=resource_group_params)

    for cell in cell_list:
        ensure_e_dss_enabled_counters_contain_correct_values(
            cell=cell,
            expected_part=dss_expected_part,
            percentage_margin=dss_margin
        )


def __get_cell_list_from_params(rg_params):
    cell_list = []
    for params in rg_params.values():
        if 'cell_num' in params:
            cell_list.append(params['cell_num'])
    return cell_list


def __calculate_available_prb_for_slice(rg, rg_params):
    counters_period_time = BuiltIn().get_variable_value("${PM_COUNTERS_PERIOD_TIME}")
    if counters_period_time is None:
        counters_period_time = 300

    if 'SNSSAI' in rg:
        is_sa = True
    elif 'NRPLMN' in rg:
        is_sa = False
    else:
        msg = 'Unsupported resource group {}'.format(rg)
        raise UnsupportedResourceGroupException(msg)

    prb_available = "M55308C10005" if is_sa else None
    data_slot_counter = "M55308C00001" if is_sa else None
    available_for_slice_counter = "M55308C10007" if is_sa else None
    counter_list = [prb_available, data_slot_counter, available_for_slice_counter]

    counter_values = get_latest_value_for_counters(counters_list=counter_list, **rg_params)
    available_prb_per_slot_per_tti = float(float(counter_values[prb_available]) / counters_period_time / 1000)
    msg = 'Calculating available PRB per slice per slot for' \
          ' {} \n{} / 60 / 100\n{} / {} / 1000 = {}'.format(rg,
                                                            prb_available,
                                                            counter_values[prb_available],
                                                            counters_period_time,
                                                            available_prb_per_slot_per_tti
                                                            )
    logger_console(msg)
    calculated_av_prb = counter_values[data_slot_counter] * available_prb_per_slot_per_tti
    msg = 'Calculating available PRB with DK Data for' \
          ' {} \n{} * av_per_slot_per_tti * 100\n{} * {} * 100 = {}'.format(rg,
                                                                            data_slot_counter,
                                                                            counter_values[data_slot_counter],
                                                                            available_prb_per_slot_per_tti,
                                                                            calculated_av_prb
                                                                            )
    logger_console(msg)
    return {'calculated': calculated_av_prb, 'counter': counter_values[available_for_slice_counter]}


def __calculate_max_utilization_ratio_for_prbs(rg, rg_params):
    if 'SNSSAI' in rg:
        is_sa = True
    elif 'NRPLMN' in rg:
        is_sa = False
    else:
        msg = 'Unsupported resource group {}'.format(rg)
        raise UnsupportedResourceGroupException(msg)

    used_counter = "M55359C00000" if is_sa else "M55338C01001"
    availcounter = "M55308C10007" if is_sa else "M55338C01000"
    maxcounter = "M55359C00001" if is_sa else 'M55338C01002'
    counter_list = [used_counter, availcounter, maxcounter]

    counter_values = get_latest_value_for_counters(counters_list=counter_list, **rg_params)

    utilization_ratio = float(float(counter_values[used_counter]) / float(counter_values[availcounter])) * 100
    msg = 'Calculating utilization ratio for {} \n{} / {}\n{} / {} * 100 = {}'.format(rg,
                                                                                      used_counter,
                                                                                      availcounter,
                                                                                      counter_values[used_counter],
                                                                                      counter_values[availcounter],
                                                                                      utilization_ratio
                                                                                      )
    logger_console(msg)
    return {'calculated': utilization_ratio, 'max': counter_values[maxcounter]}


def validate_utilization_ratio(counter_utilization, calculated_utilization, ts_margin,
                               counter_utilization_margin, target_share, rg,
                               ignore_ts=False, raise_exception=False, is_gbr_tc=False):

    msg = "Validating utilization for {}.\nTarget Share = {}\nts_margin = +-{}\n" \
            "counter_utilization_margin = +-{}\ncounter utilization = {},\n" \
            "calculated utilization = {}\nIgnoring target share: {}".format(rg,
                                                                            target_share,
                                                                            ts_margin,
                                                                            counter_utilization_margin,
                                                                            counter_utilization,
                                                                            calculated_utilization,
                                                                            ignore_ts
                                                                            )
    logger_console(msg)
    msg = "Unsupported utilization of {}".format(rg)
    passed = True
    check_if_equal_ts_result = True if ignore_ts else False

    if __check_if_equal(margin=counter_utilization_margin,
                        value=counter_utilization,
                        target_value=target_share,
                        is_gbr_tc=is_gbr_tc) is check_if_equal_ts_result:
        passed = False
        msg = msg + "\nCounter utilization ({}) not equal target Share ({} +- {})".format(counter_utilization,
                                                                                          target_share,
                                                                                          counter_utilization_margin
                                                                                          )
    if __check_if_equal(margin=ts_margin,
                        value=calculated_utilization,
                        target_value=target_share,
                        is_gbr_tc=is_gbr_tc) is check_if_equal_ts_result:
        passed = False
        msg = msg + "\nCalculated utilization ({}) not equal " \
                    "Target Share ({} +- {})".format(calculated_utilization,
                                                     target_share,
                                                     ts_margin
                                                     )
    if __check_if_equal(margin=counter_utilization_margin,
                        value=calculated_utilization,
                        target_value=counter_utilization,
                        is_gbr_tc=is_gbr_tc) is False:
        passed = False
        msg = msg + "\nCalculated utilization ({}) not equal " \
                    "counter utilization ({} +- {})".format(calculated_utilization,
                                                            counter_utilization,
                                                            counter_utilization_margin
                                                            )
    if passed is False and raise_exception is True:
        raise UnexpectedUtilizationRatioException(msg)

    return passed, msg


def __check_if_equal(value, target_value, margin, raise_exception=False, is_gbr_tc=False):
    value = float(value)
    target_value = float(target_value)
    margin = float(margin)
    if ((target_value - margin <= value <= target_value + margin) and is_gbr_tc is False)\
            or ((target_value - margin >= value) and is_gbr_tc is True):
        return True
    else:
        if is_gbr_tc:
            msg = "Values too close to Target Share\nExpected: {}>\nActual: {}".format((target_value - margin), value)
        else:
            msg = "Values not equal {} < {} < {}".format((target_value - margin), value, (target_value + margin))
        if raise_exception:
            raise ValueOutOfRangeException(msg)
        logger_console(msg)
        return False


def __prepare_quotas_list(resource_group_params, rg_list=None):
    quotas_list = []
    for rg, params in resource_group_params.items():
        if rg_list is None or rg in rg_list:
            quotas_list.append(params['quota'])
    return quotas_list


def __calculate_target_share(quotas, active_quotas_list):
    if len(active_quotas_list) > 1:
        msg = 'Calculating minimum target share\nMain quota: {} \nAll quotas: {}'.format(quotas, active_quotas_list)
        logger_console(timestamp=False, prefix="-" * 20, msg=msg)
        main_max_quota = float(quotas['max'])
        main_min_quota = float(quotas['min'])
        sum_all_diff_max_min = 0
        sum_min_quota = 0

        for actvated_quotas in active_quotas_list:
            temp_min_quota = float(actvated_quotas['min'])
            temp_max_quota = float(actvated_quotas['max'])
            sum_min_quota += temp_min_quota
            sum_all_diff_max_min += (temp_max_quota - temp_min_quota)

        quota_1 = main_min_quota + ((main_max_quota - main_min_quota) / sum_all_diff_max_min) * (100 - sum_min_quota)
        quota_2 = main_max_quota

        if quota_1 < quota_2:
            target_share = quota_1
        else:
            target_share = quota_2
        logger_console(timestamp=False, prefix='', msg='Target share = {}\n'.format(target_share))
    else:
        logger_console("Due to only one slice the Target share"
                       " is equal max quota. max quota = {}".format(quotas['max']))
        target_share = quotas['max']
    return target_share


def __retrieve_latest_f_mu_mimo_counter_values():
    cell_num = BuiltIn().get_variable_value("${CELL_WITH_ACTIVATED_FEATURE_WEBEM}")
    plmns_info = BuiltIn().get_variable_value("${PLMNS_INFO_F_MU_MIMO}")
    sst_sd_info = BuiltIn().get_variable_value("${SST_SD_INFO_F_MU_MIMO}")

    used_prb_per_slice = []
    for i in range(len(sst_sd_info)):
        val = get_latest_counter_value(counter=BuiltIn().get_variable_value("${M55359C00000}"),
                                       cell_num=cell_num,
                                       mcc=plmns_info[i]['mcc'],
                                       mnc=plmns_info[i]['mnc'],
                                       sst=sst_sd_info[i]['sst'],
                                       sd=sst_sd_info[i]['sd'])
        used_prb_per_slice.append(val)

    used_prb_mu_mimo = get_latest_counter_value(counter=BuiltIn().get_variable_value("${M55308C10001}"),
                                                cell_num=cell_num)
    avail_prb_mu_mimo = get_latest_counter_value(counter=BuiltIn().get_variable_value("${M55308C10003}"),
                                                 cell_num=cell_num)
    avail_prb_for_slice_ware = get_latest_counter_value(counter=BuiltIn().get_variable_value("${M55308C10007}"),
                                                        cell_num=cell_num)

    return used_prb_per_slice, avail_prb_for_slice_ware, used_prb_mu_mimo, avail_prb_mu_mimo


def ensure_e_dss_enabled_counters_contain_correct_values(expected_part, cell, percentage_margin):
    logger_console('Ensuring -E DSS Enabled counters contain correct values for cell={}...'.format(cell))
    dat = get_pm_counters_values(['M55332C00001'])
    dl_slots_in_nr = get_latest_values_for_specified_counters(
        counter_ids_list=['M55332C00001'],
        path_filters='BTS/MRBTS-1/NRBTS-2/NRCELL-3/ENDSS',
        counters_data=dat
    )
    dl_slots_in_nr = dl_slots_in_nr['M55332C00001']

    dat = get_pm_counters_values(['M55332C00002'])
    dl_slots_in_nr_with_max_share = get_latest_values_for_specified_counters(
        counter_ids_list=['M55332C00002'],
        path_filters='BTS/MRBTS-1/NRBTS-2/NRCELL-3/ENDSS',
        counters_data=dat
    )
    dl_slots_in_nr_with_max_share = dl_slots_in_nr_with_max_share['M55332C00002']

    dat = get_pm_counters_values(['M55332C02001'])
    total_avail_dl_slots = get_latest_values_for_specified_counters(
        counter_ids_list=['M55332C02001'],
        path_filters='BTS/MRBTS-1/NRBTS-2/NRCELL-3/ENDSS',
        counters_data=dat
    )
    total_avail_dl_slots = total_avail_dl_slots['M55332C02001']

    exception_msg = '************** CELL NUM {} ***********'.format(cell)
    status = __check_if_equal(margin=0, value=dl_slots_in_nr, target_value=dl_slots_in_nr_with_max_share)
    if status is False:
        validation_msg = '\nValues of counters M55332C00001 is not equal value of counter M55332C00002 ' \
                         '{}!={}'.format(dl_slots_in_nr, dl_slots_in_nr_with_max_share)
        exception_msg = exception_msg + validation_msg
        raise DssCountersNotCorrectException(exception_msg)

    calculated = dl_slots_in_nr / total_avail_dl_slots * 100
    logger_console("M55332C00001 / M55332C02001 * 100\n {} / {} * 100 = {}".format(
        dl_slots_in_nr,
        total_avail_dl_slots,
        calculated
    ))

    status = __check_if_equal(margin=percentage_margin, value=calculated, target_value=expected_part)
    if status is False:
        validation_msg = "\nM55332C00001 / M55332C02001 * 100 = {} is not equal {} (=-{})".format(
            calculated,
            expected_part,
            percentage_margin
        )
        exception_msg = exception_msg + validation_msg
        raise DssCountersNotCorrectException(exception_msg)

    calculated = dl_slots_in_nr_with_max_share / total_avail_dl_slots * 100
    logger_console("M55332C00002 / M55332C02001 * 100\n {} / {} *100 = {}".format(
        dl_slots_in_nr_with_max_share,
        total_avail_dl_slots,
        calculated
    ))

    status = __check_if_equal(margin=percentage_margin, value=calculated, target_value=expected_part)
    if status is False:
        validation_msg = "\nM55332C00002 / M55332C02001 * 100 = {} is not equal {} (=-{})".format(
            calculated,
            expected_part,
            percentage_margin
        )
        exception_msg = exception_msg + validation_msg
        raise DssCountersNotCorrectException(exception_msg)


def __calculate_average_dl_tput_from_counter(tput_counter, counter_interval=60):
    div = (float(tput_counter) / float(125)) / float(counter_interval)
    logger_console("Calculation results:\n{} / 125 / {} = {}".format(tput_counter, div, counter_interval))
    return div


def ensure_h_ec2_gbr_load_counters_contain_correct_values(cell, mcc, mnc, bts_num):
    period = BuiltIn().get_variable_value("${PM_COUNTERS_PERIOD_TIME}")
    if period is None:
        period = 300

    logger_console("Ensuring -H EC2 GBR load counters contain correct values for"
                   "cell {} mcc {} mnc {} period {} bts_num {}...".format(cell, mcc, mnc, period, bts_num))
    M55326C02001 = BuiltIn().get_variable_value("$M55326C02001")
    M55138C01001 = BuiltIn().get_variable_value("$M55138C01001")
    M55138C01002 = BuiltIn().get_variable_value("$M55138C01002")

    # PDCP SDU user DL data volume per PLMN-ID - QoS Group 01
    used_dl_data = get_latest_counter_value(counter=M55326C02001, cell_num=cell, mcc=mcc, mnc=mnc, bts_num=bts_num)
    result = __calculate_average_dl_tput_from_counter(tput_counter=used_dl_data, counter_interval=period)

    logger_console("Calculated result for dl data tput: {}".format(result))

    # Counters for GBR bearers
    get_list_of_counter_values(counter=M55138C01001, set_variable=True, cell_num=cell, bts_num=bts_num)
    get_list_of_counter_values(counter=M55138C01002, set_variable=True, cell_num=cell, bts_num=bts_num)

    admissions_control_attemps_list = BuiltIn().get_variable_value("${}_VALUES_LIST".format(M55138C01001))
    admissions_control_success_list = BuiltIn().get_variable_value("${}_VALUES_LIST".format(M55138C01002))
    admissions_control_attemps_list = list(admissions_control_attemps_list)
    admissions_control_success_list = list(admissions_control_success_list)

    if len(admissions_control_attemps_list) != len(admissions_control_success_list):
        msg = "Lengths of control admissions and successes are not the same! {} != {}".format(
            len(admissions_control_attemps_list), len(admissions_control_success_list))
        logger_warning(msg)
        raise DifferentCounterListLengthException(msg)

    for i in range(len(admissions_control_attemps_list)):
        if admissions_control_attemps_list[i] != admissions_control_success_list[i]:
            msg = "Success attempts value does not equal to control attemps: {} != {}".format(
                admissions_control_attemps_list[i], admissions_control_success_list[i])
            logger_warning(msg)
            raise DifferentCounterValuesAtListException(msg)

    count_of_attemps = admissions_control_attemps_list.count(1)
    if count_of_attemps != 1:
        msg = 'Count of attemps other than expected: actual {} expected {}'.format(count_of_attemps, 1)
        logger_warning(count_of_attemps)
        raise DifferentCounterValuesAtListException(count_of_attemps)
