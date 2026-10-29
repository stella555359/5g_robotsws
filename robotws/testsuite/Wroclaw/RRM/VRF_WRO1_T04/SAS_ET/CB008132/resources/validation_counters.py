# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:mantainer: Michal Maczek, Kamil Bucki, Konrad Kucharzyk
:contact: michal.maczek@nokia.com, kamil.bucki@nokia.com, konrad.kucharzyk@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

from robot.libraries.BuiltIn import BuiltIn
from validation_general import (
    is_testcase_from_sa_b_suite, validate_given_slice_list, is_testcase_from_nsa_c_suite, is_testcase_vonr,
    is_testcase_ca_multiplmn_sa
)
import collections
import os
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import (
    save_json_file, load_json_file, create_dir_at_output_dir, list_all_files_in_directory
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.pm_counters import \
    get_pm_counters_values
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import (
    logger_console, logger_warning, get_current_date
)


class NoCounterAvailableException(Exception):
    pass


class CounterNotBetweenValuesWithMarginException(Exception):
    pass


class WrongUeIdGivenException(Exception):
    pass


class CounterCannotBeMatched(Exception):
    pass


class UnexpectedSuccessfulAdmissionCounterException(Exception):
    pass


class NoPrbsAvailableToConfiguredResourceGroup(Exception):
    pass


class NoPrbsAllocatedToConfiguredResourceGroup(Exception):
    pass


def __get_counter_values(counter):
    values = get_pm_counters_values(counter_ids_list=[counter])
    return values


def __retrieve_counter_values_iterating_over_keys(counter_dict, keys):
    rtn = counter_dict
    for k in keys:
        rtn = rtn[k]
    return rtn


def __retrieve_counter_values_per_sd_with_plmn(counter, counter_dict, slice_list, mcc, mnc, cell_num):
    if cell_num is None:
        cell_num = BuiltIn().get_variable_value("${CELL_WITH_ACTIVATED_FEATURE_INCREASED}")
    if mcc is None or mnc is None:
        mcc, mnc = BuiltIn().get_variable_value("${MCC_311}"), BuiltIn().get_variable_value("${MNC_489}")
        logger_warning("Using default mcc {} and mnc {} during counter {} retrieval...".format(mcc, mnc, counter))
    sd = BuiltIn().get_variable_value("${SD_VALUES}")
    if slice_list == 2 and is_testcase_from_nsa_c_suite() and is_testcase_vonr():
        sd_value = sd[0]
    else:
        sd_value = sd[slice_list]

    keys = ['BTS', 'CELLS', 'NRCELL-{}'.format(cell_num), 'MCC-{}_MNC-{}'.format(mcc, mnc),
            'SST-1_SD-{}'.format(sd_value), 'NL1SL', counter]
    logger_console("Displaying before key iteration:\nValues: {}".format(keys))
    return __retrieve_counter_values_iterating_over_keys(counter_dict=counter_dict, keys=keys)


def __retrieve_counter_values_per_cell(counter, counter_dict, cell_num):
    if cell_num is None:
        cell_num = BuiltIn().get_variable_value("${CELL_WITH_ACTIVATED_FEATURE_INCREASED}")
    keys = ['BTS', 'CELLS', 'NRCELL-{}'.format(cell_num), 'NCELA', counter]
    return __retrieve_counter_values_iterating_over_keys(counter_dict=counter_dict, keys=keys)


def __retrieve_counter_values_per_cell_racdu(counter, counter_dict, cell_num, mrbts=1, nrbts=1):
    if cell_num is None:
        cell_num = BuiltIn().get_variable_value("${CELL_WITH_ACTIVATED_FEATURE_INCREASED}")
    keys = ['BTS', 'MRBTS-{}'.format(mrbts), 'NRBTS-{}'.format(nrbts), 'NRCELL-{}'.format(cell_num), 'RACDU', counter]
    return __retrieve_counter_values_iterating_over_keys(counter_dict=counter_dict, keys=keys)


def __retrieve_counter_values_per_cell_nrlrlc(counter, counter_dict, cell_num):
    if cell_num is None:
        cell_num = BuiltIn().get_variable_value("${CELL_WITH_ACTIVATED_FEATURE_INCREASED}")
    keys = ['BTS', 'CELLS', 'NRCELL-{}'.format(cell_num), 'NLRLC', 'DL_RLC_VOL_TX_L_QOS_GRP_01', counter]
    return counter_dict
    # return __retrieve_counter_values_iterating_over_keys(counter_dict=counter_dict, keys=keys)


def __retrieve_counter_values_per_nrbts_with_plmn(counter, counter_dict, slice_list, mcc, mnc):
    if mcc is None or mnc is None:
        mcc, mnc = BuiltIn().get_variable_value("${MCC_311}"), BuiltIn().get_variable_value("${MNC_489}")
        logger_warning("Using default mcc {} and mnc {} during counter {} retrieval...".format(mcc, mnc, counter))
    nrbts = BuiltIn().get_variable_value("${NRBTS_ID}")
    sd = BuiltIn().get_variable_value("${SD_VALUES}")
    keys = ['BTS', 'BTS', 'NRBTS-{}'.format(nrbts), 'MCC-{}_MNC-{}'.format(mcc, mnc),
            'SST-1_SD-{}'.format(sd[slice_list]), 'NPSL', counter]
    return __retrieve_counter_values_iterating_over_keys(counter_dict=counter_dict, keys=keys)


def __retrieve_counter_values_per_nrdu_nhrlc(counter, counter_dict):
    nrbts = BuiltIn().get_variable_value("${NRBTS_ID}")
    keys = ['BTS', 'BTS', 'NRBTS-{}'.format(nrbts), 'NRDU-1', 'NHRLC', counter]
    return __retrieve_counter_values_iterating_over_keys(counter_dict=counter_dict, keys=keys)


def __retrieve_counter_values_per_nrbts_pdcp(counter, counter_dict):
    nrbts = BuiltIn().get_variable_value("${NRBTS_ID}")
    keys = ['BTS', 'BTS', 'NRBTS-{}'.format(nrbts), 'PDCP1', counter]
    return __retrieve_counter_values_iterating_over_keys(counter_dict=counter_dict, keys=keys)


def __retrieve_counter_values_per_plmn_per_nrasu(counter, counter_dict, resource_group):
    nrbts = BuiltIn().get_variable_value("${NRBTS_ID}")
    mcc, mnc = resource_group['MCC'], resource_group['MNC']
    keys = ['BTS', 'BTS', 'NRBTS-{}'.format(nrbts), 'MCC-{}_MNC-{}'.format(mcc, mnc), 'NRASU', counter]
    return __retrieve_counter_values_iterating_over_keys(counter_dict=counter_dict, keys=keys)


def __retrieve_counter_values_per_ncupl_with_plmn(counter, counter_dict, mcc=None, mnc=None, cell_num=None, **kwargs):
    if cell_num is None:
        cell_num = BuiltIn().get_variable_value("${CELL_WITH_ACTIVATED_FEATURE_INCREASED}")
    if mcc is None and mnc is None and ('resource_group' in kwargs and kwargs.get('resource_group') is not None):
        resource_group = kwargs.get('resource_group')
        mcc, mnc = resource_group['MCC'], resource_group['MNC']
    elif mcc is None or mnc is None:
        mcc, mnc = BuiltIn().get_variable_value("${MCC_311}"), BuiltIn().get_variable_value("${MNC_489}")
        logger_warning("Using default mcc {} and mnc {} during counter {} retrieval...".format(mcc, mnc, counter))
    keys = ['BTS', 'CELLS', 'NRCELL-{}'.format(cell_num), 'MCC-{}_MNC-{}'.format(mcc, mnc), 'NCUPL', counter]
    return __retrieve_counter_values_iterating_over_keys(counter_dict=counter_dict, keys=keys)


def __retrieve_counter_values(counter, counter_dict, slice_list=None, mcc=None, mnc=None, cell_num=None,
                              resource_group=None):
    M55359C00000 = BuiltIn().get_variable_value("${M55359C00000}")
    M55359C00001 = BuiltIn().get_variable_value("${M55359C00001}")
    M55308C10007 = BuiltIn().get_variable_value("${M55308C10007}")
    M55328C00003 = BuiltIn().get_variable_value("${M55328C00003}")
    M55310C01001 = BuiltIn().get_variable_value("${M55310C01001}")
    M55326C00001 = BuiltIn().get_variable_value("${M55326C00001}")
    M55338C01001 = BuiltIn().get_variable_value("${M55338C01001}")
    M55338C01000 = BuiltIn().get_variable_value("${M55338C01000}")
    M55115C00015 = BuiltIn().get_variable_value("${M55115C00015}")
    M55311C44008 = BuiltIn().get_variable_value("${M55311C44008}")
    M55319C02008 = BuiltIn().get_variable_value("${M55319C02008}")
    ca_counters = BuiltIn().get_variable_value("${COUNTERS_CA_LIST}")
    nsa_counters = BuiltIn().get_variable_value("${COUNTERS_STD_NSA_LIST}")
    if counter in M55359C00000 or counter in M55359C00001:
        logger_console('Retrieving counter {} with params: slice {} mcc {} mnc {} cell_num {}'.format(
            counter, slice_list, mcc, mnc, cell_num))
        return __retrieve_counter_values_per_sd_with_plmn(counter, counter_dict, slice_list, mcc, mnc, cell_num)
    elif counter in M55308C10007:
        return __retrieve_counter_values_per_cell(counter, counter_dict, cell_num)
    elif counter in M55328C00003:
        return __retrieve_counter_values_per_nrbts_with_plmn(counter, counter_dict, slice_list, mcc, mnc)
    elif counter in M55310C01001:
        return __retrieve_counter_values_per_cell_nrlrlc(counter, counter_dict, cell_num)
    elif counter in M55326C00001:
        return __retrieve_counter_values_per_plmn_per_nrasu(counter, counter_dict, resource_group)
    elif counter in ca_counters:
        return __retrieve_counter_values_per_nrdu_nhrlc(counter, counter_dict)
    elif counter in nsa_counters:
        return __retrieve_counter_values_per_ncupl_with_plmn(counter, counter_dict, mcc, mnc, cell_num,
                                                             resource_group=resource_group
                                                             )
    elif counter in M55338C01001 or counter in M55338C01000:
        return __retrieve_counter_values_per_ncupl_with_plmn(counter, counter_dict, mcc, mnc, cell_num)
    elif counter in M55115C00015:
        return __retrieve_counter_values_per_cell_racdu(counter, counter_dict, cell_num)
    elif counter in M55319C02008:
        return __retrieve_counter_values_per_nrbts_pdcp(counter, counter_dict)
    else:
        raise NoCounterAvailableException("Could not retrieve counter {} values!")


def __print_counter_dicts(counter, counter_dict):
    logger_console("\n{}\n{}\n".format(BuiltIn().get_variable_value("${}".format(counter)),
                                       BuiltIn().get_variable_value("${}".format(counter_dict))))


def __set_counter_variables_and_print_if_needed(counter, print_dict, outputdir=None, directory=None):
    BuiltIn().set_suite_variable("${}_DICT".format(counter),
                                 __get_counter_values(BuiltIn().get_variable_value("${}".format(counter))))

    if print_dict:
        __print_counter_dicts(counter, '{}_DICT'.format(counter))
    if outputdir:
        if directory:
            filename = os.path.join(outputdir, directory, "{}.json".format(counter))
        else:
            filename = os.path.join(outputdir, "{}_{}.json".format(counter, get_current_date()))
        content = BuiltIn().get_variable_value("${}_DICT".format(counter))
        logger_console("Saving {} to file {}...".format(counter, filename))
        save_json_file(filename, content)


def load_counters_from_files(counter_dir):
    files = list_all_files_in_directory(directory=counter_dir)
    for file in files:
        counter_name = os.path.splitext(file)[0]
        value = load_json_file(os.path.join(counter_dir, file))
        BuiltIn().set_suite_variable("${}_DICT".format(counter_name), value)


def set_all_counter_variables(print_dicts=False, outputdir=None, create_directory=False, additional_counters=None,
                              skip_sa_std=False):
    std = BuiltIn().get_variable_value("${COUNTERS_STD_LIST}")
    std_nsa = BuiltIn().get_variable_value("${COUNTERS_STD_NSA_LIST}")
    vonr = BuiltIn().get_variable_value("${COUNTERS_VONR_LIST}")
    ca = BuiltIn().get_variable_value("${COUNTERS_CA_LIST}")
    directory = None

    if create_directory and outputdir:
        path = create_dir_at_output_dir(outputdir=outputdir, dir_name='counters')
        directory = create_dir_at_output_dir(outputdir=path, dir_name=get_current_date())

    if not skip_sa_std:
        for s in std:
            __set_counter_variables_and_print_if_needed(s, print_dicts, outputdir, directory=directory)

    if is_testcase_from_nsa_c_suite():
        for s in std_nsa:
            __set_counter_variables_and_print_if_needed(s, print_dicts, outputdir, directory=directory)

    if is_testcase_vonr():
        for s in vonr:
            __set_counter_variables_and_print_if_needed(s, print_dicts, outputdir, directory=directory)

    if is_testcase_ca_multiplmn_sa():
        for s in ca:
            __set_counter_variables_and_print_if_needed(s, print_dicts, outputdir, directory=directory)
    if additional_counters is not None:
        for s in additional_counters:
            __set_counter_variables_and_print_if_needed(s, print_dicts, outputdir, directory=directory)


def __retrieve_latest_counter_value(counter_list):
    latest_val = counter_list[sorted(counter_list)[-1]]
    return latest_val


def __retrieve_max_counter_value(counter_list):
    max_val = max(counter_list.values())
    return max_val


def __retrieve_values_list(counters_dictionary):
    values_list = []
    counters_dictionary = collections.OrderedDict(sorted(counters_dictionary.items()))
    for v in counters_dictionary.values():
        values_list.append(v)
    return values_list


def __get_latest_counter_value(counter, slice_list, mcc, mnc, cell_num=None, resource_group=None):
    counter_dict = BuiltIn().get_variable_value('${}_DICT'.format(counter))
    msg = "Checking latest value counter {} " \
          "for: slice_list: {} mcc: {} mnc: {} cell_num: {}".format(counter, slice_list, mcc, mnc, cell_num)
    logger_console(msg=msg, prefix="", timestamp=False)
    values = __retrieve_counter_values(counter, counter_dict, slice_list, mcc, mnc, cell_num, resource_group)
    latest = __retrieve_latest_counter_value(values)
    msg = "Latest value = {}\n".format(latest)
    logger_console(msg=msg, prefix="", timestamp=False)
    return latest


def __get_max_counter_value(counter, slice_list, mcc=None, mnc=None, cell_num=None, resource_group=None):
    if counter is None:
        logger_warning("{} is None, so returning 0 to max value...".format(counter))
        return 0
    counter_dict = BuiltIn().get_variable_value('${}_DICT'.format(counter))
    values = __retrieve_counter_values(counter, counter_dict, slice_list, mcc, mnc, cell_num, resource_group)
    latest = __retrieve_max_counter_value(values)
    msg = "Max {} value in slice list {}:\nvalue: {}".format(counter, slice_list, latest)
    logger_console(msg)
    return latest


def __calculate_max_utilization_ratio(counter_used_prbs, counter_avail_prbs):
    result = float(counter_used_prbs) / float(counter_avail_prbs)
    div = result * float(100)
    msg = "Calculation max utilization ratio:\n{} / {} = {}\n".format(counter_used_prbs, counter_avail_prbs, result)
    logger_console(timestamp=False, prefix='', msg=msg)
    return div


def __validate_max_utilization_ratio(actual, expected, quotas, margin=None, raise_error=True):
    if margin is None:
        margin = margin if margin else BuiltIn().get_variable_value("${COUNTER_MAX_UTI_RATIO_MARGIN}")
    margin = float(margin)
    actual, expected = float(actual), float(expected)
    min_quota, max_quota = float(quotas['min']), float(quotas['max'])
    info = 'Calculated: {}, Counter: {}, minquota: {}, maxquota: {}, margin: {}'.format(actual, expected, min_quota,
                                                                                        max_quota, margin)
    if (
            min_quota - margin <= actual <= max_quota + margin and
            min_quota - margin <= expected <= max_quota + margin
    ):
        logger_console(timestamp=False, prefix='', msg='Ratios are between range of quotas! {}'.format(info))
        return
    msg = 'Ratios are not in range of quotas! {}'.format(info)
    if raise_error:
        raise CounterNotBetweenValuesWithMarginException(msg)
    else:
        logger_warning(msg)


def __ensure_max_utilization_ratio_for_prbs_per_slice_is_correct(used_slice_list,
                                                                 quotas,
                                                                 counter_used_prbs,
                                                                 counter_avail_prbs,
                                                                 counter_max_util=None,
                                                                 slice_list=0,
                                                                 mcc=None,
                                                                 mnc=None,
                                                                 cell_num=None,
                                                                 override_raise_error=False,
                                                                 margin=None,
                                                                 resourcegroup_dn=None,
                                                                 target_share=None):
    msg = "Ensuring Max Uti Ratio for Prbs per slice is correct for slicelist {} or resourcegroup {} cell: {}" + \
          " with counters {} {} {}, params: mcc {} mnc {}".format(
              slice_list, resourcegroup_dn, cell_num, counter_used_prbs, counter_avail_prbs, counter_max_util, mcc, mnc
          )
    logger_console(msg)

    slice_list = validate_given_slice_list(slice_list=slice_list)
    used_slice_list = validate_given_slice_list(slice_list=used_slice_list, decrease_value=True)

    counter_used_prbs = __get_latest_counter_value(counter_used_prbs, slice_list, mcc=mcc, mnc=mnc, cell_num=cell_num)
    counter_avail_prbs = __get_latest_counter_value(counter_avail_prbs, slice_list, mcc=mcc, mnc=mnc,
                                                    cell_num=cell_num)

    max_uti = __calculate_max_utilization_ratio(counter_used_prbs=counter_used_prbs,
                                                counter_avail_prbs=counter_avail_prbs)

    if counter_max_util is not None:
        counter_max_util = __get_latest_counter_value(counter_max_util, slice_list, mcc=mcc, mnc=mnc,
                                                      cell_num=cell_num)
    else:
        logger_warning("{} is None, so skipping validation of max uti counter...".format(counter_max_util))
        counter_max_util = max_uti
    raise_error = True if (override_raise_error or used_slice_list == slice_list) else False
    margin = margin if margin else BuiltIn().get_variable_value("${COUNTER_MAX_UTI_RATIO_MARGIN}")

    if resourcegroup_dn:
        slice_quotas_to_check = quotas[resourcegroup_dn]
    else:
        slice_quotas_to_check = quotas[used_slice_list]

    if target_share:
        __validate_target_share(target=target_share, max_uti=max_uti, margin=margin)

    __validate_max_utilization_ratio(actual=max_uti,
                                     expected=counter_max_util,
                                     quotas=slice_quotas_to_check,
                                     raise_error=raise_error,
                                     margin=margin)


def __ensure_max_utilization_ratio_for_prbs_per_slice_is_correct_with_resourcegroup_dn(quotas,
                                                                                       counter_used_prbs,
                                                                                       counter_avail_prbs,
                                                                                       counter_max_util=None,
                                                                                       slice_list=0,
                                                                                       mcc=None,
                                                                                       mnc=None,
                                                                                       cell_num=None,
                                                                                       margin=None,
                                                                                       resourcegroup_dn=None,
                                                                                       target_share=None):
    margin = margin if margin else BuiltIn().get_variable_value("${COUNTER_MAX_UTI_RATIO_MARGIN}")

    msg = "Ensuring Max Utilization Ratio for Prbs per Slice is correct for r" \
          "esourcegroup dn: {},  cell: {} with counters {} {} {}\n"
    msg = msg.format(resourcegroup_dn, cell_num, counter_used_prbs, counter_avail_prbs, counter_max_util)
    logger_console(prefix="-" * 15, msg=msg, timestamp=False)

    slice_list = validate_given_slice_list(slice_list=slice_list)

    counter_used_prbs = __get_latest_counter_value(counter_used_prbs, slice_list, mcc=mcc, mnc=mnc, cell_num=cell_num)
    counter_avail_prbs = __get_latest_counter_value(counter_avail_prbs, slice_list, mcc=mcc, mnc=mnc,
                                                    cell_num=cell_num)

    max_uti = __calculate_max_utilization_ratio(counter_used_prbs=counter_used_prbs,
                                                counter_avail_prbs=counter_avail_prbs)

    if counter_max_util is not None:
        counter_max_util = __get_latest_counter_value(counter_max_util, slice_list, mcc=mcc, mnc=mnc,
                                                      cell_num=cell_num)
    else:
        logger_warning(timestamp=False,
                       msg="{} is None, so skipping validation of max uti counter...".format(counter_max_util)
                       )
        counter_max_util = max_uti

    slice_quotas_to_check = quotas[resourcegroup_dn]

    if target_share:
        __validate_target_share(target=target_share, max_uti=max_uti, margin=margin)

    __validate_max_utilization_ratio(actual=max_uti,
                                     expected=counter_max_util,
                                     quotas=slice_quotas_to_check)


def ensure_max_utilization_ratio_for_prbs_per_slice_is_correct(quotas,
                                                               slice_list=0,
                                                               used_slice_list=None,
                                                               mcc=None,
                                                               mnc=None,
                                                               cell_num=None,
                                                               override_raise_error=False,
                                                               margin=None,
                                                               is_sa=True,
                                                               resourcegroup_dn=None,
                                                               target_share=None):
    used = "M55359C00000" if is_sa else "M55338C01001"
    avail = "M55308C10007" if is_sa else "M55338C01000"
    max = "M55359C00001" if is_sa else None
    if used_slice_list and resourcegroup_dn is None:
        __ensure_max_utilization_ratio_for_prbs_per_slice_is_correct(used_slice_list=used_slice_list,
                                                                     quotas=quotas,
                                                                     counter_used_prbs=used,
                                                                     counter_avail_prbs=avail,
                                                                     counter_max_util=max,
                                                                     slice_list=slice_list,
                                                                     mcc=mcc,
                                                                     mnc=mnc,
                                                                     cell_num=cell_num,
                                                                     override_raise_error=override_raise_error,
                                                                     margin=margin,
                                                                     resourcegroup_dn=resourcegroup_dn,
                                                                     target_share=target_share)
    elif resourcegroup_dn and used_slice_list is None:
        func = __ensure_max_utilization_ratio_for_prbs_per_slice_is_correct_with_resourcegroup_dn
        func(quotas=quotas,
             counter_used_prbs=used,
             counter_avail_prbs=avail,
             counter_max_util=max,
             slice_list=slice_list,
             mcc=mcc,
             mnc=mnc,
             cell_num=cell_num,
             margin=margin,
             resourcegroup_dn=resourcegroup_dn,
             target_share=target_share)


def ensure_max_utilization_ratio_for_prbs_per_slice_with_ue_is_correct(ue_id, quotas, plmn_list):
    override = BuiltIn().get_variable_value("${OVERR_ERR_RAISE_DURING_VONR_VALIDATION}") if 'VONR' in ue_id else None
    margin = BuiltIn().get_variable_value("${COUNTER_MAX_UTI_RATIO_VONR_MARGIN}") if 'VONR' in ue_id else None

    if BuiltIn().get_variable_value("${UE_ID_1}") in ue_id and is_testcase_from_sa_b_suite():
        ensure_max_utilization_ratio_for_prbs_per_slice_is_correct(slice_list=1, used_slice_list=2,
                                                                   mcc=plmn_list['1']['mcc'],
                                                                   mnc=plmn_list['1']['mnc'],
                                                                   quotas=quotas, override_raise_error=override,
                                                                   margin=margin, is_sa=True)
    if BuiltIn().get_variable_value("${UE_ID_2}") in ue_id and is_testcase_from_sa_b_suite():
        ensure_max_utilization_ratio_for_prbs_per_slice_is_correct(slice_list=2, used_slice_list=3,
                                                                   mcc=plmn_list['2']['mcc'],
                                                                   mnc=plmn_list['2']['mnc'],
                                                                   quotas=quotas, override_raise_error=override,
                                                                   margin=margin, is_sa=True)
    if BuiltIn().get_variable_value("${UE_ID_3}") in ue_id and is_testcase_from_sa_b_suite():
        ensure_max_utilization_ratio_for_prbs_per_slice_is_correct(slice_list=3, used_slice_list=4,
                                                                   mcc=plmn_list['3']['mcc'],
                                                                   mnc=plmn_list['3']['mnc'],
                                                                   quotas=quotas, override_raise_error=override,
                                                                   margin=margin, is_sa=True)
    if BuiltIn().get_variable_value("${UE_ID_4}") in ue_id and is_testcase_from_nsa_c_suite():
        ensure_max_utilization_ratio_for_prbs_per_slice_is_correct(slice_list=2, used_slice_list=3,
                                                                   mcc=plmn_list['4']['mcc'],
                                                                   mnc=plmn_list['4']['mnc'],
                                                                   quotas=quotas, override_raise_error=override,
                                                                   margin=margin, is_sa=True)
    if 'VONR_SA' in ue_id:
        ensure_max_utilization_ratio_for_prbs_per_slice_is_correct(slice_list=0, used_slice_list=1,
                                                                   mcc=plmn_list['1']['mcc'],
                                                                   mnc=plmn_list['1']['mnc'],
                                                                   quotas=quotas, override_raise_error=override,
                                                                   margin=margin, is_sa=True)
    if BuiltIn().get_variable_value("${UE_ID_11}") in ue_id:
        ensure_max_utilization_ratio_for_prbs_per_slice_is_correct(slice_list=1 if is_testcase_vonr() else 0,
                                                                   used_slice_list=2 if is_testcase_vonr() else 1,
                                                                   mcc=plmn_list['11']['mcc'],
                                                                   mnc=plmn_list['11']['mnc'],
                                                                   quotas=quotas, override_raise_error=override,
                                                                   margin=margin, is_sa=False)
    if BuiltIn().get_variable_value("${UE_ID_12}") in ue_id and is_testcase_vonr():
        ensure_max_utilization_ratio_for_prbs_per_slice_is_correct(slice_list=2 if is_testcase_vonr() else 1,
                                                                   used_slice_list=3 if is_testcase_vonr() else 2,
                                                                   mcc=plmn_list['12']['mcc'],
                                                                   mnc=plmn_list['12']['mnc'],
                                                                   quotas=quotas, override_raise_error=override,
                                                                   margin=margin, is_sa=False)
    if BuiltIn().get_variable_value("${UE_ID_13}") in ue_id and is_testcase_vonr():
        ensure_max_utilization_ratio_for_prbs_per_slice_is_correct(slice_list=3, used_slice_list=4,
                                                                   mcc=plmn_list['13']['mcc'],
                                                                   mnc=plmn_list['13']['mnc'],
                                                                   quotas=quotas, override_raise_error=override,
                                                                   margin=margin, is_sa=False)
    if '1_SA' in ue_id and is_testcase_from_nsa_c_suite():
        ensure_max_utilization_ratio_for_prbs_per_slice_is_correct(slice_list=1, used_slice_list=3,
                                                                   mcc=plmn_list['1']['mcc'],
                                                                   mnc=plmn_list['1']['mnc'],
                                                                   quotas=quotas, override_raise_error=override,
                                                                   margin=margin, is_sa=True)
    if '2_SA' in ue_id and is_testcase_from_nsa_c_suite():
        ensure_max_utilization_ratio_for_prbs_per_slice_is_correct(slice_list=0, used_slice_list=2,
                                                                   mcc=plmn_list['2']['mcc'],
                                                                   mnc=plmn_list['2']['mnc'],
                                                                   quotas=quotas, override_raise_error=override,
                                                                   margin=margin, is_sa=True)


def ensure_prbs_availability_per_plmn_nsa(used_resource_group, slice_list=0):
    logger_console("Ensuring PRBs are available to the configured NSA Resource Group {}".format(used_resource_group))
    prbs_available = __get_latest_counter_value("M55338C01000", slice_list, None, None, None, used_resource_group)
    if prbs_available <= 0:
        raise NoPrbsAvailableToConfiguredResourceGroup("PLMN-{} has no PRBs available for allocation"
                                                       .format(used_resource_group))


def ensure_prbs_allocation_per_plmn_nsa(used_resource_group, slice_list=0):
    logger_console("Ensuring PRBs are available to the configured NSA Resource Group {}".format(used_resource_group))
    prbs_allocated = __get_max_counter_value("M55338C01001", slice_list, None, None, None, used_resource_group)
    if prbs_allocated <= 0:
        raise NoPrbsAllocatedToConfiguredResourceGroup("PLMN-{} has no PRBs allocated"
                                                       .format(used_resource_group))


def __calculate_average_dl_tput_from_counter(tput_counter, counter_interval=60):
    div = (float(tput_counter) / float(125)) / float(counter_interval)
    logger_console("Calculation results:\n{} / 125 / {} = {}".format(tput_counter, div, counter_interval))
    return div


def __validate_dl_tput_per_slice(actual, expected, raise_error=True):
    actual, expected = float(actual), float(expected)
    margin = float(BuiltIn().get_variable_value("${COUNTER_TPUT_MARGIN}"))
    if expected - margin <= actual <= expected + margin:
        logger_console("Result {} is between actual tput {} with margin {}".format(actual, expected, margin))
        return
    msg = 'Result {} is different comparing to actual tput {} even with margin {}!'.format(actual, expected, margin)
    if raise_error:
        raise CounterNotBetweenValuesWithMarginException(msg)
    else:
        logger_warning(msg)


def ensure_dl_pdcp_per_slice_are_correct(expected_tput, used_slice_list, slice_list=0):
    logger_console("Ensuring DL per slice are correct in slice list {} with tput {}".format(slice_list, expected_tput))
    slice_list = validate_given_slice_list(slice_list)
    used_slice_list = validate_given_slice_list(slice_list=used_slice_list, decrease_value=True)
    max_val = __get_max_counter_value("M55328C00003", slice_list, mcc=None, mnc=None, cell_num=None)
    tput = __calculate_average_dl_tput_from_counter(tput_counter=max_val)
    __validate_dl_tput_per_slice(actual=tput,
                                 expected=expected_tput,
                                 raise_error=True if used_slice_list == slice_list else False)


def ensure_dl_pdcp_per_resource_group_are_correct_nsa(expected_tput, used_resource_group, quotas, slice_list=0):
    max_quota_sum = 0
    for key in quotas[1:]:
        max_quota_sum += int(key['max'])
    if max_quota_sum < 100:
        expected_tput = int(expected_tput) * max_quota_sum / 100
    logger_console("Ensuring DL per Resource Group are correct in PLMN list {} with tput {}".format(slice_list,
                                                                                                    expected_tput))
    tput = __calculate_average_dl_tput_from_counter(tput_counter=__get_max_counter_value("M55326C00001",
                                                                                         slice_list, None, None, None,
                                                                                         used_resource_group))
    __validate_dl_tput_per_slice(actual=tput,
                                 expected=expected_tput,
                                 raise_error=False)


def __get_tput_from_ca_counters(counter, slice_list):
    latest = __get_latest_counter_value(counter, slice_list, mcc=None, mnc=None, cell_num=None)
    tput = __calculate_average_dl_tput_from_counter(tput_counter=latest)
    return tput


def __calculate_usage_ratio_for_tput_ca_counter(actual_tput, max_tput):
    return (float(actual_tput) / float(max_tput)) * 100


def __ensure_tput_ratio_is_between_quotas(ratio, quotas, raise_error=True):
    margin = float(BuiltIn().get_variable_value("${COUNTER_CA_TPUT_RATIO_MARGIN}"))
    min_quota, max_quota = float(quotas['min']), float(quotas['max'])
    ratio = float(ratio)
    valid_msg = "{} - {} <= {} <= {} + {}".format(min_quota, margin, ratio, max_quota, margin)
    if min_quota - margin <= ratio <= max_quota + margin:
        logger_console("Ratios are between quotas with margin: {}".format(valid_msg))
        return
    msg = 'Ratios are not in range of quotas! {}'.format(valid_msg)
    logger_warning(msg)
    if raise_error:
        raise CounterNotBetweenValuesWithMarginException(msg)


def __compare_tput_counters_to_quotas_for_ue(counter_pcell, counter_scell, max_tput_pcell, max_tput_scell, quotas,
                                             slice_list, override_raise_error=False):
    tput_pcell = __get_tput_from_ca_counters(counter_pcell, slice_list)
    tput_scell = __get_tput_from_ca_counters(counter_scell, slice_list)
    logger_console("Retrieved counter values for pcell: {}, scell: {}".format(tput_pcell, tput_scell))
    ratio_pcell = __calculate_usage_ratio_for_tput_ca_counter(tput_pcell, max_tput_pcell)
    ratio_scell = __calculate_usage_ratio_for_tput_ca_counter(tput_scell, max_tput_scell)
    logger_console("Calculated ratio for pcell: {}, scell: {}".format(ratio_pcell, ratio_scell))
    __ensure_tput_ratio_is_between_quotas(ratio_pcell, quotas, raise_error=override_raise_error)
    __ensure_tput_ratio_is_between_quotas(ratio_scell, quotas, raise_error=override_raise_error)


def __compare_dl_pdcp_counter_value_to_quotas(max_tput_both_subcells, quotas, slice_list,
                                              override_raise_error=False, mcc=None, mnc=None):
    max_val = __get_max_counter_value("M55328C00003", slice_list, mcc=mcc, mnc=mnc, cell_num=None)
    tput = __calculate_average_dl_tput_from_counter(tput_counter=max_val)
    logger_console("Retrieved average DL tput from M55328C00003: {}".format(tput))
    ratio = __calculate_usage_ratio_for_tput_ca_counter(actual_tput=tput, max_tput=max_tput_both_subcells)
    logger_console('Calculated ratio for both cells (pcell + scell): {}'.format(ratio))
    __ensure_tput_ratio_is_between_quotas(ratio=ratio, quotas=quotas, raise_error=override_raise_error)


def __call_validation_keywords_for_ca(counter_pcell, counter_scell, quotas, slice_list, mcc=None, mnc=None):
    max_tput = BuiltIn().get_variable_value("${MAX_TPUT_BOTH_SUBCELLS}")
    override = not BuiltIn().get_variable_value("${OVERRIDE_ERROR_RAISE_DURING_CA_MAX_UTI_VALIDATION}")
    quotas_ue = quotas[slice_list]
    __compare_tput_counters_to_quotas_for_ue(counter_pcell=counter_pcell,
                                             counter_scell=counter_scell,
                                             max_tput_pcell=BuiltIn().get_variable_value("${MAX_TPUT_PCELL}"),
                                             max_tput_scell=BuiltIn().get_variable_value("${MAX_TPUT_SCELL}"),
                                             quotas=quotas_ue,
                                             slice_list=slice_list,
                                             override_raise_error=override)
    __compare_dl_pdcp_counter_value_to_quotas(max_tput_both_subcells=max_tput,
                                              quotas=quotas_ue,
                                              slice_list=slice_list,
                                              override_raise_error=override,
                                              mcc=mcc,
                                              mnc=mnc)
    ensure_max_utilization_ratio_for_prbs_per_slice_is_correct(slice_list=slice_list,
                                                               used_slice_list=slice_list + 1,
                                                               quotas=quotas,
                                                               override_raise_error=override,
                                                               mcc=mcc,
                                                               mnc=mnc)


def ensure_dl_pdcp_per_slice_with_ue_are_correct(ue_ids, quotas, plmn_list):
    if BuiltIn().get_variable_value("${UE_ID_1}") in ue_ids:
        __call_validation_keywords_for_ca(counter_pcell=BuiltIn().get_variable_value("${M55311C42006}"),
                                          counter_scell=BuiltIn().get_variable_value("${M55311C44006}"),
                                          quotas=quotas,
                                          slice_list=0,
                                          mcc=plmn_list['1']['mcc'],
                                          mnc=plmn_list['1']['mnc'])
    if BuiltIn().get_variable_value("${UE_ID_2}") in ue_ids:
        __call_validation_keywords_for_ca(counter_pcell=BuiltIn().get_variable_value("${M55311C42007}"),
                                          counter_scell=BuiltIn().get_variable_value("${M55311C44007}"),
                                          quotas=quotas,
                                          slice_list=1,
                                          mcc=plmn_list['2']['mcc'],
                                          mnc=plmn_list['2']['mnc'])
        logger_console(plmn_list['2']['mcc'] + ', ' + plmn_list['2']['mnc'])
    if BuiltIn().get_variable_value("${UE_ID_3}") in ue_ids:
        __call_validation_keywords_for_ca(counter_pcell=BuiltIn().get_variable_value("${M55311C42008}"),
                                          counter_scell=BuiltIn().get_variable_value("${M55311C44008}"),
                                          quotas=quotas,
                                          slice_list=2,
                                          mcc=plmn_list['3']['mcc'],
                                          mnc=plmn_list['3']['mnc'])


def __validate_sub_step(params):
    pass


def ensure_dl_pdcp_per_slice_with_ue_are_correct_3plmn_3ue(ue_ids, quotas, mcc_mnc_list, validation_dictionary,
                                                           validation_step):
    counter_list = BuiltIn().get_variable_value("${C_13_3PLMN_3UE_THROUGHPUT_COUNTERS_DICTIONARY}")
    max_tput_dictionary = BuiltIn().get_variable_value("${C_3PLMN_MAX_TPUT}")
    margin = int(BuiltIn().get_variable_value("${C_3PLMN_COUNTER_UTI_RATIO_MARGIN}"))
    scell = int(BuiltIn().get_variable_value("${C_3PLMN_SCELL}"))
    pcell = int(BuiltIn().get_variable_value("${C_3PLMN_PCELL}"))

    pcell_tput = int(max_tput_dictionary[validation_step]['pcell'])
    scell_tput = int(max_tput_dictionary[validation_step]['scell'])
    target_share_values = {}

    logger_console(prefix="*"*40, msg="Validation pdcp 3PLMN 3UE ------> step: {}".format(validation_step))
    for sub_step in validation_dictionary[validation_step]:
        msg = "Validation with params from validation_dictionary[{}]\n" \
              "Validation params: {}\n".format(validation_dictionary[validation_step].index(sub_step), sub_step)
        logger_console(timestamp=False, prefix="-"*30, msg=msg)

        __validate_sub_step(params=sub_step)

        rg_dn = sub_step['resourcegroup_dn']
        if len(sub_step['target_share_rg_dn']) > 0:
            if sub_step['cell_num'] not in target_share_values:
                target_share_values[sub_step['cell_num']] = {}

            main_quotas = quotas[rg_dn]
            all_quotas = [value for key, value in quotas.items() if key in sub_step['target_share_rg_dn']]
            target_share = __calculate_target_share(quotas=main_quotas, active_quotas_list=all_quotas)
            target_share_values[sub_step['cell_num']][rg_dn] = target_share
        else:
            target_share = None

        ensure_max_utilization_ratio_for_prbs_per_slice_is_correct(quotas=quotas,
                                                                   mcc=mcc_mnc_list[rg_dn]['mcc'],
                                                                   mnc=mcc_mnc_list[rg_dn]['mnc'],
                                                                   is_sa=sub_step['is_sa'],
                                                                   cell_num=sub_step['cell_num'],
                                                                   resourcegroup_dn=rg_dn,
                                                                   target_share=target_share)

    calculate_and_validate_tput_utilization(ts_values=target_share_values,
                                            counter_list=counter_list,
                                            mcc_mnc_list=mcc_mnc_list,
                                            cell_max_tput={scell: scell_tput, pcell: pcell_tput},
                                            margin=margin)


def ensure_dl_pdcp_per_slice_with_ue_are_correct_1plmn_3ue(ue_ids, quotas, mcc_mnc_list, validation_dictionary,
                                                           validation_step):
    counter_list = BuiltIn().get_variable_value("${C_12_1PLMN_3UE_THROUGHPUT_COUNTERS_DICTIONARY}")
    max_tput_dictionary = BuiltIn().get_variable_value("${C_3PLMN_MAX_TPUT}")
    margin = int(BuiltIn().get_variable_value("${C_3PLMN_COUNTER_UTI_RATIO_MARGIN}"))
    scell = int(BuiltIn().get_variable_value("${C_3PLMN_SCELL}"))
    pcell = int(BuiltIn().get_variable_value("${C_3PLMN_PCELL}"))

    pcell_tput = int(max_tput_dictionary[validation_step]['pcell'])
    scell_tput = int(max_tput_dictionary[validation_step]['scell'])
    target_share_values = {}

    logger_console(prefix="*"*40, msg="Validation pdcp 1PLMN 3UE ------> step: {}".format(validation_step))
    for sub_step in validation_dictionary[validation_step]:
        msg = "Validation with params from validation_dictionary[{}]\n" \
              "Validation params: {}\n".format(validation_dictionary[validation_step].index(sub_step), sub_step)
        logger_console(timestamp=False, prefix="-"*30, msg=msg)

        __validate_sub_step(params=sub_step)

        rg_dn = sub_step['resourcegroup_dn']
        if len(sub_step['target_share_rg_dn']) > 0:
            if sub_step['cell_num'] not in target_share_values:
                target_share_values[sub_step['cell_num']] = {}

            main_quotas = quotas[rg_dn]
            all_quotas = [value for key, value in quotas.items() if key in sub_step['target_share_rg_dn']]
            target_share = __calculate_target_share(quotas=main_quotas, active_quotas_list=all_quotas)
            target_share_values[sub_step['cell_num']][rg_dn] = target_share
        else:
            target_share = None

        ensure_max_utilization_ratio_for_prbs_per_slice_is_correct(quotas=quotas,
                                                                   mcc=mcc_mnc_list[rg_dn]['mcc'],
                                                                   mnc=mcc_mnc_list[rg_dn]['mnc'],
                                                                   is_sa=sub_step['is_sa'],
                                                                   cell_num=sub_step['cell_num'],
                                                                   resourcegroup_dn=rg_dn,
                                                                   target_share=target_share)

    calculate_and_validate_tput_utilization(ts_values=target_share_values,
                                            counter_list=counter_list,
                                            mcc_mnc_list=mcc_mnc_list,
                                            cell_max_tput={scell: scell_tput, pcell: pcell_tput},
                                            margin=margin)


def calculate_and_validate_tput_utilization(ts_values, counter_list, mcc_mnc_list, cell_max_tput, margin):
    values_to_validation = {}
    for cell, values in ts_values.items():
        ts_sum = 0
        tput_utilization = 0
        if cell not in values_to_validation:
            values_to_validation[cell] = {'rg_dn': {}}

        for rg_dn, ts in values.items():
            values_to_validation[cell]['rg_dn'][rg_dn] = {}
            ts_sum += ts
            value = __check_throughput(cell=cell,
                                       rg_dn=rg_dn,
                                       counter_dictionary=counter_list,
                                       mcc=mcc_mnc_list[rg_dn]['mcc'],
                                       mnc=mcc_mnc_list[rg_dn]['mnc'],
                                       slice=0)
            tput = float(value) / 60 / 125
            logger_console(prefix="", timestamp=False,
                           msg="Calculating Throughput: {} / 60 / 125 = {}".format(value, tput))
            max_tput = cell_max_tput[cell]
            tput_utilization = tput / max_tput * 100
            logger_console(prefix="", timestamp=False,
                           msg="Calculating throughput utilization: {} / {} * 100 = {}".format(
                               tput, max_tput, tput_utilization))

            values_to_validation[cell]['rg_dn'][rg_dn]['tput_utilization'] = tput_utilization
            values_to_validation[cell]['rg_dn'][rg_dn]['cell_max_tput'] = max_tput
            values_to_validation[cell]['rg_dn'][rg_dn]['tput'] = tput
            values_to_validation[cell]['rg_dn'][rg_dn]['ts'] = ts
        values_to_validation[cell]['rg_dn']['ts_sum'] = ts_sum
        values_to_validation[cell]['rg_dn']['tput_utilization_sum'] = tput_utilization
    validate_tput_utilization(checked_params=values_to_validation, margin=margin)


def validate_tput_utilization(checked_params, margin):
    for cell, params in checked_params.items():
        logger_console(timestamp=False, prefix='*'*20, msg='Validating tput utilization for cell {}'.format(cell))
        logger_console(timestamp=False, prefix='',
                       msg='utylization_sum: {}\nts_sum: {}\nrg_dn: {}\n'.format(
                           params['rg_dn']['tput_utilization_sum'], params['rg_dn']['ts_sum'], params['rg_dn']))

        for rg_dn, rg_dn_values in params['rg_dn'].items():
            logger_console(timestamp=False, prefix='*'*10,
                           msg='Presenting throughput utilization for cell: {} and rg_dn: {}'.format(cell, rg_dn))
        __compare_target_share_with_throughput_utilization(ts=params['rg_dn']['ts_sum'],
                                                           tput_uti=params['rg_dn']['tput_utilization_sum'],
                                                           margin=margin)


def __compare_target_share_with_throughput_utilization(ts, tput_uti, margin):
    margin = float(margin)
    ts, tput_uti = float(ts), float(tput_uti)
    logger_console(timestamp=False, prefix='\n*************', msg='Comparing throughput utilization to target share.')
    if ts - margin <= ts + margin:
        msg = 'Throughput utilization equal target_share. Throughput utilization: {} Target Share: {}(+-{})'.format(
            tput_uti, ts, margin)
        logger_console(timestamp=False, prefix='>>>>>>>>>>>>>>>>\n', msg=msg)
        return
    else:
        msg = 'Ratios is not equal target share! Ratios: {} Target Share: {}(+-{})'.format(tput_uti, ts, margin)
        raise CounterNotBetweenValuesWithMarginException(msg)


def __check_throughput(slice=None, mcc=None, mnc=None, counter=None, cell=None, rg_dn=None, counter_dictionary=None):
    if counter is None and cell is not None and rg_dn is not None and counter_dictionary is not None:
        counter = counter_dictionary[cell][rg_dn]
    value = __get_latest_counter_value(counter=counter, mcc=mcc, mnc=mnc, slice_list=slice, cell_num=cell)
    return value


def __calculate_target_share(quotas, active_quotas_list):
    msg = 'Calculating minimum target share\nMain quota: {} \nAll quotas: {}'.format(quotas, active_quotas_list)
    logger_console(timestamp=False, prefix="-" * 20, msg=msg)
    main_max_quota = float(quotas['max'])
    main_min_quota = float(quotas['min'])
    sum_all_diff_max_min = 0
    sum_min_quota = 0

    for activated_quotas in active_quotas_list:
        temp_min_quota = float(activated_quotas['min'])
        temp_max_quota = float(activated_quotas['max'])
        sum_min_quota += temp_min_quota
        sum_all_diff_max_min += (temp_max_quota - temp_min_quota)

    quota_1 = main_min_quota + ((main_max_quota - main_min_quota) / sum_all_diff_max_min) * (100 - sum_min_quota)
    quota_2 = main_max_quota

    if quota_1 < quota_2:
        target_share = quota_1
    else:
        target_share = quota_2
    logger_console(timestamp=False, prefix='', msg='Target share = {}\n'.format(target_share))
    return target_share


def __validate_target_share(target, max_uti, margin):
    margin = float(margin)
    target, max_uti = float(target), float(max_uti)
    logger_console(timestamp=False, prefix='\n****************', msg='Validating max ratio with target share')
    if target - margin <= max_uti <= target + margin:
        msg = 'Ratios equals target share. Ratios: {} Target Share: {}(+-{})'.format(max_uti, target, margin)
        logger_console(timestamp=False, prefix='>>>>>>>>>>>>>>>>\n', msg=msg)
        return
    else:
        msg = 'Ratios is not equal target share! Ratios: {} Target Share: {}(+-{})'.format(max_uti, target, margin)
        raise CounterNotBetweenValuesWithMarginException(msg)


def ensure_successful_radio_admissions_are_correct_by_dictionary(validation_dictionary, validation_step):
    msg = "Validation of Successful Radio Admissions by values in dictionary\nStep: {}\nDictionary: {}".format(
        validation_step, validation_dictionary)
    logger_console(prefix="*" * 40, msg=msg)
    for scell, params_list in validation_dictionary[validation_step].items():
        for params in params_list:
            ensure_successful_radio_admissions_are_correct(cell_num=params['cell'],
                                                           addmission_per_timestamp=params['addmission_per_timestamp'],
                                                           scell=scell)


def ensure_successful_radio_admissions_are_correct(cell_num, addmission_per_timestamp=[], scell='SCELL_1'):
    expected_admision_sum = 0
    actual_admision_sum = 0
    msg = "Validation of {} Successful Radio Admissions for cell: {}\naddmission_per_timestamp: {}".format(
        scell, cell_num, addmission_per_timestamp)
    logger_console(timestamp=False, prefix='-'*30, msg=msg)

    counter_values = __get_successful_radio_admissions_counters(cell_num=1, scell='SCELL_1')
    values_list = __retrieve_values_list(counter_values)

    actual_admission_count_list = [int(x) for x in values_list if int(x) != 0]

    for i in addmission_per_timestamp:
        expected_admision_sum += i

    for i in actual_admission_count_list:
        actual_admision_sum += i

    equal_admission_timestamp = True if len(actual_admission_count_list) == len(addmission_per_timestamp) else False
    equal_admission_sum = True if actual_admision_sum == expected_admision_sum else False
    equal_addmission_list = True if addmission_per_timestamp == actual_admission_count_list else False

    if equal_admission_timestamp and equal_admission_sum and equal_addmission_list:
        msg = "Successful radio admission equal expected values."
        logger_console(timestamp=False, prefix='>>>>>>>>>>>>>>>>\n', msg=msg)
    else:
        msg = "Unexpected successful radio admission values.\n Current: {}\n Expected(without 0): {}\n".format(
            values_list, addmission_per_timestamp)
        raise UnexpectedSuccessfulAdmissionCounterException(msg)


def __get_successful_radio_admissions_counters(cell_num, scell='SCELL_1'):
    if 'SCELL_1' == scell:
        counter = 'M55115C00015'
    else:
        msg = 'Cannot find counter for {}!'.format(scell)
        raise CounterCannotBeMatched(msg)
    msg = "Getting {} Successful Radio Admissions for cell {} by {} counter.\n".format(scell, cell_num, counter)
    logger_console(timestamp=False, prefix="-"*20, msg=msg)

    counter_dict = BuiltIn().get_variable_value('${}_DICT'.format(counter))

    counter_values = __retrieve_counter_values(counter=counter,
                                               counter_dict=counter_dict,
                                               cell_num=cell_num
                                               )
    return counter_values
