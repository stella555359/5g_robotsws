# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author:  Kamil Bucki
:contact: kamil.bucki@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

from typing import Dict
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import logger_console
from robot.libraries.BuiltIn import BuiltIn
import re


def prepare_resource_group_parameters_variable(delta_dictionary):
    cell_tech = BuiltIn().get_variable_value("${CELL_TECHNOLOGY}")
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

    default_bts_num = '1'

    for index, rg in dn_list.items():
        rg_id = __get_number_from_key(index)
        temp_dictionary[rg_id] = {'rg': rg, 'cell_num': default_cell_num, 'bts_num': default_bts_num}
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
    BuiltIn().set_test_variable("${RESOURCE_GROUP_PARAMS_DICT}", rg_dict)
    logger_console(rg_dict)
    return rg_dict


def __get_number_from_key(key, index=0):
    m = re.findall(r'\d+', key)
    if len(m) == 0:
        logger_console("NIE WYKRYTUI")
    elif len(m) < (index + 1):
        logger_console("index poza zakresem")
    else:
        return int(m[index])


def __check_if_min_quota(key):
    return __check_if_str_exist_in(pattern='_minQuota', text=key)


def __check_if_max_quota(key):
    return __check_if_str_exist_in(pattern='_maxQuota', text=key)


def __check_if_str_exist_in(pattern, text):
    m = re.search(pattern, text)
    if m:
        return True
    else:
        return False


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
    return rg_dictionary
