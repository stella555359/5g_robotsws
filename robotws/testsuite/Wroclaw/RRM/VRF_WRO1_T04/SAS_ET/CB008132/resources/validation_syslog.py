# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:mantainer: Michal Maczek, Kamil Bucki
:contact: michal.maczek@nokia.com, kamil.bucki@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import (
    logger_console, logger_warning
)
from validation_general import (
    ensure_it_is_file_stream, regexp_in_stream_exists, validate_single_quotas, regexp_item_equal_values_in_stream
)


class DifferentCountOfQuotasThanExpectedException(Exception):
    pass


class DifferentCountOfPlmnThanMAtchedQuotas(Exception):
    pass


def ensure_slice_aware_scheduler_is_activated():
    syslog_path = BuiltIn().get_variable_value('${SYSLOG_OUTPUT_PATH}')
    logger_console("Ensuring SliceAwareScheduler exists in: {}".format(syslog_path))
    stream = ensure_it_is_file_stream(syslog_path)
    regexp_in_stream_exists(text=BuiltIn().get_variable_value('${VALID_SYSLOG_FEATURE_ACTIVATED}'),
                            stream=stream,
                            path=syslog_path)


def ensure_plmn_config_list_exist():
    syslog_path = BuiltIn().get_variable_value('${SYSLOG_OUTPUT_PATH}')
    logger_console("Ensuring PlmnConfigList exists in: {}".format(syslog_path))
    stream = ensure_it_is_file_stream(syslog_path)
    regexp_in_stream_exists(text=BuiltIn().get_variable_value('${VALID_SYSLOG_PLMN_CONFIG_LIST}'),
                            stream=stream,
                            path=syslog_path)


def __retrieve_quotas_from_cell_setup_req(syslog_path):
    stream = ensure_it_is_file_stream(syslog_path)
    match = regexp_in_stream_exists(regexp=BuiltIn().get_variable_value('${VALID_SYSLOG_QUOTAS_CONFIG_REGEXP}'),
                                    stream=stream,
                                    path=syslog_path)
    return [
        {
            "min": match.group("MINQUOTA_1"),
            "max": match.group("MAXQUOTA_1")
        },
        {
            "min": match.group("MINQUOTA_2"),
            "max": match.group("MAXQUOTA_2")
        }
    ]


def ensure_quotas_contain_correct_values_for_single_NSA_slice(slices):
    expected = [{"min": '0', "max": '100'}, slices[0]]
    ensure_quotas_contain_correct_values(expected)


def __retrieve_quotas_from_one_slice_req(syslog_path):
    stream = ensure_it_is_file_stream(syslog_path)
    match = regexp_in_stream_exists(regexp=BuiltIn().get_variable_value('${VALID_SYSLOG_CONFIG_REGEXP_SECOND_SLICE}'),
                                    stream=stream,
                                    path=syslog_path)
    return {
        "min": match.group("MINQUOTA"),
        "max": match.group("MAXQUOTA")
    }


def __retrieve_single_quotas_for_plmns(syslog_path, plmns):
    stream = ensure_it_is_file_stream(syslog_path)
    regexp = BuiltIn().get_variable_value('${VALID_SYSLOG_CONFIG_REGEXP_SINGLE_QUOTA}')
    match = regexp_item_equal_values_in_stream(regexp=regexp,
                                               stream=stream,
                                               item='PLMN',
                                               values=plmns)
    plmns_quota = {key: {"min": value["MINQUOTA"], "max": value["MAXQUOTA"]} for key, value in match.items()}
    return plmns_quota


def __retrieve_double_quotas_for_plmns(syslog_path, plmns):
    regexp_1st = BuiltIn().get_variable_value('${VALID_SYSLOG_CONFIG_REGEXP_DOUBLE_QUOTA_1ST_REGEXP}')
    regexp_2nd = BuiltIn().get_variable_value('${VALID_SYSLOG_CONFIG_REGEXP_DOUBLE_QUOTA_2ND_REGEXP}')
    regexp_list = [regexp_2nd, regexp_1st]

    plmns_quota = {plmn: [] for plmn in plmns}

    for regexp in regexp_list:
        stream = ensure_it_is_file_stream(syslog_path)
        for plmn in plmns:
            match = regexp_item_equal_values_in_stream(regexp=regexp,
                                                       stream=stream,
                                                       item='PLMN',
                                                       values=[plmn]
                                                       )
            quotas_in_syslog = [{"min": value["MINQUOTA"], "max": value["MAXQUOTA"]} for value in match.values()]

            for quota_in_syslog in quotas_in_syslog:
                if quota_in_syslog not in plmns_quota[plmn]:
                    plmns_quota[plmn].append(quota_in_syslog)
    logger_console(plmns_quota)

    return plmns_quota


def ensure_quotas_contain_correct_values(expected):
    syslog_path = BuiltIn().get_variable_value('${SYSLOG_OUTPUT_PATH}')
    logger_console("Ensuring Quotas contain correct values in: {}".format(syslog_path))
    actual = __retrieve_quotas_from_cell_setup_req(syslog_path=syslog_path)
    if len(actual) != len(expected):
        raise DifferentCountOfQuotasThanExpectedException("{} != {}".format(len(actual), len(expected)))
    for i in range(len(actual)):
        validate_single_quotas(actual=actual[i], expected=expected[i])


def ensure_quotas_contain_correct_values_for_2_NSA_slices(slices):
    pass


def ensure_quotas_contain_correct_values_for_all_slices(slices, resourceGroup_dn_list, plmn_list, hardcoded_quota,
                                                        valid_hardcoded_quota=True):
    ensure_quotas_contain_correct_values_for_all_nrplmn_single_quota(slices=slices,
                                                                     resourceGroup_dn_list=resourceGroup_dn_list,
                                                                     plmn_list=plmn_list,
                                                                     hardcoded_quota=hardcoded_quota,
                                                                     valid_hardcoded_quota=valid_hardcoded_quota)

    ensure_quotas_contain_correct_values_for_all_snssai_double_quota(slices=slices,
                                                                     resourceGroup_dn_list=resourceGroup_dn_list,
                                                                     plmn_list=plmn_list,
                                                                     hardcoded_quota=hardcoded_quota,
                                                                     valid_hardcoded_quota=valid_hardcoded_quota)


def ensure_quotas_contain_correct_values_for_all_nrplmn_single_quota(slices,
                                                                     resourceGroup_dn_list,
                                                                     plmn_list,
                                                                     hardcoded_quota,
                                                                     valid_hardcoded_quota=True):
    syslog_path = BuiltIn().get_variable_value('${SYSLOG_OUTPUT_PATH}')
    nrplmn_plmn_list_with_single_quota =\
        [plmn for plmn in plmn_list if 'NRPLMN' in resourceGroup_dn_list[plmn_list.index(plmn)]]
    nrplmn_resourceGroup_dn_list =\
        [resourceGroup_dn for resourceGroup_dn in resourceGroup_dn_list if 'NRPLMN' in resourceGroup_dn]

    if len(nrplmn_plmn_list_with_single_quota) > 0:
        single_quotas = __retrieve_single_quotas_for_plmns(syslog_path=syslog_path,
                                                           plmns=nrplmn_plmn_list_with_single_quota)
        if len(single_quotas) != len(nrplmn_plmn_list_with_single_quota):
            msg = "Plmn list: {} ; Resource grop dn list: {}; Matched quotas: {}".format(
                nrplmn_plmn_list_with_single_quota, nrplmn_resourceGroup_dn_list, single_quotas
            )
            logger_warning(msg)
            raise DifferentCountOfPlmnThanMAtchedQuotas(msg)

        logger_console('Detected single quotas: {}'.format(single_quotas))
        for plmn_id in nrplmn_plmn_list_with_single_quota:
            plmn_array_index = nrplmn_plmn_list_with_single_quota.index(plmn_id)
            validate_single_quotas(actual=single_quotas[plmn_id],
                                   expected=slices[nrplmn_resourceGroup_dn_list[plmn_array_index]])


def ensure_quotas_contain_correct_values_for_all_snssai_double_quota(slices, resourceGroup_dn_list, plmn_list,
                                                                     hardcoded_quota, valid_hardcoded_quota=True):
    syslog_path = BuiltIn().get_variable_value('${SYSLOG_OUTPUT_PATH}')
    snssai_plmn_list_with_double_quota =\
        [plmn for plmn in plmn_list if 'SNSSAI' in resourceGroup_dn_list[plmn_list.index(plmn)]]
    snssai_resourceGroup_dn_list =\
        [resourceGroup_dn for resourceGroup_dn in resourceGroup_dn_list if 'SNSSAI' in resourceGroup_dn]

    if len(snssai_plmn_list_with_double_quota) > 0:
        double_quotas = __retrieve_double_quotas_for_plmns(syslog_path=syslog_path,
                                                           plmns=snssai_plmn_list_with_double_quota)
        if len(double_quotas) != len(snssai_plmn_list_with_double_quota):
            msg = "Plmn list: {} ; Resource grop dn list: {}; Matched quotas: {}".format(
                snssai_plmn_list_with_double_quota, snssai_resourceGroup_dn_list, double_quotas
            )
            logger_warning(msg)
            raise DifferentCountOfPlmnThanMAtchedQuotas(msg)

        logger_console('Detected double quotas: {}'.format(double_quotas))
        for plmn_id in snssai_plmn_list_with_double_quota:
            plmn_array_index = snssai_plmn_list_with_double_quota.index(plmn_id)
            validate_single_quotas(actual=double_quotas[plmn_id][0],
                                   expected=slices[snssai_resourceGroup_dn_list[plmn_array_index]])
            if valid_hardcoded_quota:
                validate_single_quotas(actual=double_quotas[plmn_id][1], expected=hardcoded_quota)
