# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Alexandre Cunha
:contact: alexandre.cunha@nokia.com
:maintainer: None
:contact: None
"""
import json
import taf.gnb.oam.coam.vdu.interface as vdu
import taf.gnb.oam.coam.cu.interface as cu
from robot.libraries.BuiltIn import BuiltIn
from collections import defaultdict


def convert_param_list_to_cu_param_list(param_list):
    result_data = defaultdict(list)
    for item in param_list:
        result_data[item['dist_name']].append({'operation_type': 'replace',
                                               'parameter_path': '/' + item['p_name'],
                                               'value': item['value']})
    for key, value in result_data.items():
        yield key, value


def get_mouuid_from_dist_name(dist_name, delta_plan_id, connection):
    """
    Get the managed object uuid from the distname
    Based on Sylvia implementation for testsuite/Ulm/ET/5GC000480/keyword_AIC_CU.robot

    :param dist_name: distname from the managed object. e.g. MRBTS-1/MNL-1
    :param delta_plan_id: the ID of the delta plan
    :param connection: the connection instance
    :return: mouuid
    """
    name_list = dist_name.split('/')
    parent_mo_uuid = None
    delta_plan_tree = cu.cu().get_delta_plan_tree_diff(delta_plan_id, connection)
    for name in name_list:
        for mo_info in delta_plan_tree["created"]:
            if mo_info["parent_mo_uuid"] == parent_mo_uuid and mo_info["name"] == name:
                parent_mo_uuid = mo_info["mo_uuid"]
                break
    BuiltIn().log_to_console("distName: %s -> mo_uuid: %s" % (dist_name, parent_mo_uuid))
    return parent_mo_uuid


def update_parameters_of_delta_plan_cu(delta_plan_id, param_list, connection):
    """
    Update parameters of the specified delta plan for cu
    The format for the params given to taf vcu interface is like the example below:
             [{"operation_type":"replace"
               "parameter_path":"/lssConfig/lssPortNo",
               "value":"some_value"}, ...]
    if the operation result is not "success" or "ongoing" for each distname
    the keyword will fail

    :param delta_plan_id: the ID of the delta plan
    :param param_list: list of parameters to change. Each parameter is a dictionary
                       and contains as keys: value, dist_name, p_name
    :param connection: the connection instance
    """
    for dist_name, paramlist in convert_param_list_to_cu_param_list(
            param_list):
        dict_para_change = cu.cu().update_parameters_of_delta_plan(
            plan_id=delta_plan_id,
            mo_uuid=get_mouuid_from_dist_name(dist_name, delta_plan_id, connection),
            parameter_change_list=paramlist,
            connection=connection
        )
        result = cu.cu().get_action_state_of_updating_parameters_of_delta_plan(
            plan_id=delta_plan_id,
            action_id=dict_para_change['action_id'],
            connection=connection
        )
        BuiltIn().log_to_console(result)
        BuiltIn().log_to_console("parameters: %s" % str(paramlist))
        if not (result['status'] == 'success' or result['status'] == 'ongoing'):
            BuiltIn().fail(msg="CU commissioning failed")


def convert_param_list_to_vdu_param_dict(param_list):
    result_data = defaultdict(dict)
    for item in param_list:
        result_data[item['dist_name']][item['p_name']] = item['value']
    for key, value in result_data.items():
        yield key, value


def update_parameters_of_delta_plan_vdu(delta_plan_id, param_list, connection):
    """
    Update parameters of the specified delta plan for vdu
    The format for the params given to taf vdu interface is like the example below:
             {"swResetLevel":"0", "swResetComment":"reset by bts", ...}
    if the operation result is not "success" or "ongoing" for each distname
    the keyword will fail

    :param delta_plan_id: the ID of the delta plan
    :param param_list: list of parameters to change. Each parameter is a dictionary
                       and contains as keys: value, dist_name, p_name
    :param connection: the connection instance
    """
    for dist_name, paramdict in convert_param_list_to_vdu_param_dict(
            param_list):
        dict_para_change = vdu.vdu().update_vdu_parameter_of_delta_plan(
            plan_id=delta_plan_id,
            mo_dn=dist_name,
            updated_paras_dict=paramdict,
            operation='replace',
            vdu_connection=connection
        )
        result = vdu.vdu().get_update_paras_action_status_of_delta_plan(
            plan_id=delta_plan_id,
            action_id=dict_para_change['action_id'],
            vdu_connection=connection
        )
        BuiltIn().log_to_console(result)
        BuiltIn().log_to_console("parameters: %s" % str(paramdict))
        if not (result['status'] == 'success' or result['status'] == 'ongoing'):
            BuiltIn().fail(msg="vDU commissioning failed")


def convert_parameters_to_aic_m2m_payload(param_list):
    payload_dict = {}
    for paramdict in param_list:
        payload_dict[paramdict['parameterName']] = paramdict['value']
    return json.dumps(payload_dict)


def admin_to_aic_json(admin_json_file):
    """
    Convert the format of json from admin to aic (CU-OAM-ASM-LICENSED REST API)
    Admin specification is described here:
        https://onion.wroclaw.nsn-rdnet.net/branches/master/cli-docs/tutorial-recommission.html
    CU-OAM-ASM-LICENSED REST API:
        http://10.181.164.25:8080/?urls.primaryName=CU-OAM-ASM-LICENSED-REST_openapi#
            /m2mPlan/m2mProvisionForDeltaPlanByMoChanges

    :param admin_json_file: filename with path to json in admin format
    :return: data structure formated according to REST API
    """
    with open(admin_json_file) as admin_json:
        admin_json_struct = json.load(admin_json)
        aic_m2m = []
        for distname_dict in admin_json_struct:
            aic_distname_dict = {}
            aic_distname_dict['operation_type'] = distname_dict['operation']
            aic_distname_dict['dist_name'] = distname_dict['distName']
            aic_distname_dict['class_name'] = distname_dict['distName'].split('/')[-1].split('-')[0]
            aic_distname_dict['payload'] = convert_parameters_to_aic_m2m_payload(distname_dict['parameters'])
            aic_m2m.append(aic_distname_dict)
            BuiltIn().log_to_console(aic_distname_dict)
    return aic_m2m
