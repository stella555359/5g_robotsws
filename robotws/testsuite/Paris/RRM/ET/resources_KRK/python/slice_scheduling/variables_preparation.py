# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author:  Kamil Bucki
:contact: kamil.bucki@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

import re
from typing import Dict

from robot.libraries.BuiltIn import BuiltIn

from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import logger_console
from testsuite.Paris.RRM.ET.resources_KRK.python.common_gnb import get_mrbts_nrbts_ids


def prepare_resource_group_parameters_variable(delta_dictionary):
    cell_tech = BuiltIn().get_variable_value('${CELL_TECHNOLOGY}')
    temp_dictionary = {}
    cell_list = delta_dictionary['nrcell'] if 'nrcell' in delta_dictionary else {}
    dn_list = delta_dictionary['dn_list'] if 'dn_list' in delta_dictionary else {}
    quotas_list = delta_dictionary['quotas'] if 'quotas' in delta_dictionary else {}
    sd_list = delta_dictionary['sd'] if 'sd' in delta_dictionary else {}
    sst_list = delta_dictionary['sst'] if 'sst' in delta_dictionary else {}
    mnc_list = delta_dictionary['mnc'] if 'mnc' in delta_dictionary else {}
    mcc_list = delta_dictionary['mcc'] if 'mcc' in delta_dictionary else {}

    default_cell_num = delta_dictionary['cell_params']['$nrCellId']
    if isinstance(default_cell_num, Dict):
        default_cell_num = default_cell_num[cell_tech]

    mrbts, nrbts = get_mrbts_nrbts_ids()
    for index, rg in dn_list.items():
        rg_id = __get_number_from_key(index)
        temp_dictionary[rg_id] = {'rg': rg, 'cell_num': default_cell_num,
                                  'bts_num': nrbts, 'mrbts_num': mrbts}
        if 'NRSPID' in rg:
            temp_dictionary[rg_id]['nrresgrp_id'] = rg_id
    for key, quota in quotas_list.items():
        rg_index = __get_number_from_key(key)
        if __check_if_min_quota(key=key):
            temp_dictionary[rg_index]['min_quota'] = quota
        elif __check_if_max_quota(key=key):
            temp_dictionary[rg_index]['max_quota'] = quota
    for key, sd in sd_list.items():
        rg_index = __get_number_from_key(key)
        if sd is not None:
            temp_dictionary[rg_index]['sd'] = sd
    for key, sst in sst_list.items():
        rg_index = __get_number_from_key(key)
        if sst is not None:
            temp_dictionary[rg_index]['sst'] = sst
    for key, mcc in mcc_list.items():
        rg_index = __get_number_from_key(key)
        if mcc is not None:
            temp_dictionary[rg_index]['mcc'] = mcc
    for key, mnc in mnc_list.items():
        rg_index = __get_number_from_key(key)
        if mnc is not None:
            temp_dictionary[rg_index]['mnc'] = mnc
    for key, cell in cell_list.items():
        rg_index = __get_number_from_key(key)
        if cell is not None:
            temp_dictionary[rg_index]['cell_num'] = cell

    rg_dict = __create_rg_name_dictionary(temp_dictionary)
    BuiltIn().set_test_variable('${RESOURCE_GROUP_PARAMS_DICT}', rg_dict)
    logger_console(rg_dict)
    return rg_dict


def __get_number_from_key(key, index=0):
    match = re.findall(r'\d+', key)
    if len(match) == 0:
        logger_console('Key not found!')
    elif len(match) < (index + 1):
        logger_console('Index out of range!')
    else:
        return int(match[index])


def __check_if_min_quota(key):
    return __check_if_str_exist_in(pattern='minQuota', text=key)


def __check_if_max_quota(key):
    return __check_if_str_exist_in(pattern='maxQuota', text=key)


def __check_if_str_exist_in(pattern, text):
    return bool(re.search(pattern, text))


def __create_rg_name_dictionary(dictionary):
    rg_dictionary = {}
    for value in dictionary.values():
        rg_name = value['rg']
        rg_dictionary[rg_name] = {}
        if 'min_quota' in value and 'max_quota' in value:
            rg_dictionary[rg_name]['quota'] = {'min': value['min_quota'], 'max': value['max_quota']}
        if 'mcc' in value and 'mnc' in value:
            rg_dictionary[rg_name]['mcc'] = value['mcc']
            rg_dictionary[rg_name]['mnc'] = value['mnc']
        if 'sd' in value and 'sst' in value:
            rg_dictionary[rg_name]['sd'] = value['sd']
            rg_dictionary[rg_name]['sst'] = value['sst']
        if 'cell_num' in value:
            rg_dictionary[rg_name]['cell_num'] = value['cell_num']
        if 'bts_num' in value:
            rg_dictionary[rg_name]['bts_num'] = value['bts_num']
        if 'mrbts_num' in value:
            rg_dictionary[rg_name]['mrbts_num'] = value['mrbts_num']
        if 'nrresgrp_id' in value:
            rg_dictionary[rg_name]['nrresgrp_id'] = value['nrresgrp_id']
    return rg_dictionary


def get_spid_values_from_delta(delta_dict):
    plmn_dict = get_plmn_from_delta(delta_dict)
    cfgSpidRange = delta_dict['cfgSpidRange']
    for key, value in cfgSpidRange.items():
        new_key = key.split('cfgSpidRange')[-1]
        value_list = value.split(',')
        for elem in value_list:
            if elem == 'none':
                plmn_dict[new_key].update({'spid': None})
                continue
            temp_spid_list = elem.split('-')
            if len(temp_spid_list) == 1:
                temp_spid_list = [int(elem)]
            elif len(temp_spid_list) == 2:
                a = temp_spid_list
                temp_spid_list = [i for i in range(int(a[0]), int(a[1]) + 1)]
            if 'spid' in plmn_dict[new_key]:
                plmn_dict[new_key]['spid'].extend(temp_spid_list)
            else:
                plmn_dict[new_key].update({'spid': temp_spid_list})
    BuiltIn().set_suite_variable('${CFG_SPID_RANGE_DICT}', plmn_dict)
    return plmn_dict


def get_plmn_from_delta(delta_dict):
    plmn = delta_dict['plmn']
    plmn_dict = dict()
    for key, value in plmn.items():
        if 'mcc' in key:
            new_key = key.split('$nrpmqapmcc')[-1]
            mcc = plmn[key]
            if new_key in plmn_dict:
                plmn_dict[new_key].update({'mcc': mcc})
            else:
                plmn_dict.update({new_key: {'mcc': mcc}})
        elif 'mnc' in key:
            new_key = key.split('$nrpmqapmnc')[-1]
            mnc = plmn[key]
            if new_key in plmn_dict:
                plmn_dict[new_key].update({'mnc': mnc})
            else:
                plmn_dict.update({new_key: {'mcc': mnc}})
    BuiltIn().set_suite_variable('${PLMN_DICT}', plmn_dict)
    return plmn_dict
