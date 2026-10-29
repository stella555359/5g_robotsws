# -*- coding: utf-8 -*
"""
Author: Cui Lingxue
Contacts: lingxue.cui@nokia-sbell.com
Description: methods for NIDD parameter online operations, modify, add, delete...
"""

import logging
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_parameter import *
import json
import taf.rfrl.cbts.devices.vdu.business.vdu_cm_business as vdu_cm_business
import taf.rfrl.cbts.devices.vcu.business.vcu_cm_business as vcu_cm_business


def online_modify_nidd_parameters_via_restapi(params_modify_dict, connection="GNB_OAM", timeout=60,
                                              skip_parameter_relation_errors=True, should_activate=True,
                                              bts_type='classical'):
    """
    Author: Cui Lingxue
    Description: Provide common keyword for nidd parameter operations including update, add, delete.
    If should_activate is true, all the configuration change will be activated together.
    :param params_modify_dict: dict contain nidd parameters to be modified. Eg:
    params_modify_dict = {
    'param_to_upd': [
                    {'dist_name': 'MRBTS-413/NRBTS-11171/NRCELL-1', 'parameter': 'actCDrx', 'value': 'true')},
                    {'dist_name': 'MRBTS-413/NRBTS-11171/NRCELL-1', 'parameter': 'drxProfile1',
                     'value': [{'drxInactivityTimer': '80ms', 'drxLongCycle': '160ms', 'drxOnDurationTimer': '10ms',
                                'drxRetransTimerDl': '0slot', 'drxRetransTimerUl': '0slot'}]}],
    'param_to_add': [
                    {'dist_name': 'MRBTS-413/NRBTS-11171/NRCELL-1', 'parameter': 'drxProfile1',
                     'value': [{'drxInactivityTimer': '80ms', 'drxLongCycle': '160ms', 'drxOnDurationTimer': '10ms',
                                'drxRetransTimerDl': '0slot', 'drxRetransTimerUl': '0slot'}]}],
    'object_to_add': [
                     {'dist_name': 'MRBTS-413/EQM-1/APEQM-1/CABINET-1/BBMOD-6', 'parameter': 'administrativeState',
                      'value': 'Unlocked'},
                     {'dist_name': 'MRBTS-413/EQM-1/APEQM-1/CABINET-1/BBMOD-6', 'parameter': 'fddNrCellConfigTradeoff',
                      'value': 'not used'},
                     {'dist_name': 'MRBTS-413/EQM-1/APEQM-1/CABINET-1/BBMOD-6', 'parameter': 'prodCodePlanned',
                      'value': '474020A.102'},
                     {'dist_name': 'MRBTS-413/EQM-1/APEQM-1/CABINET-1/BBMOD-6', 'parameter': 'useFullCapacity',
                      'value': 'true'}],
    'param_to_del': [{'dist_name': 'MRBTS-413/NRBTS-11171/NRCELL-1', 'parameter': 'drxProfile2'}],
    'object_to_del': [{'dist_name': 'MRBTS-413/EQM-1/APEQM-1/CABINET-1/BBMOD-6'}]
    }
    :param skip_parameter_relation_errors: Skip parameter relation errors.
    :param should_activate: is need to activate configuration change or not.
    :param timeout:  Time to wait for positive procedure result
    :param connection: AdminConnection object or if used, string name alias
            For cloud, need to specify CU/DU in connection name.
                    For CU, then CU should be exist and DU shouldn't, example input: OAM_CU0;
                    For DU, then DU should be exist, example input: OAM_gnb0_du0
    :param bts_type: classical, cu, du
    :return: raise exception if recommission failed, PASS - online parameter update
                  RESET_PASS - parameter update is successful and BTS is going to trigger reset
                  Note: No return for if bts_type is cu or du
    """
    modify_type = params_modify_dict.keys()
    delta_file_list_updated = []
    if "param_to_del" in modify_type:
        if params_modify_dict['param_to_del']:
            delta_file_del = create_delete_parameters_delta(parameters=params_modify_dict['param_to_del'],
                                                            connection=connection)
            delta_file_list_updated.append(delta_file_del['updated'])
    if "object_to_del" in modify_type:
        if params_modify_dict['object_to_del']:
            delta_file_del_obj = create_delete_objects_delta(parameters=params_modify_dict['object_to_del'],
                                                             connection=connection)
            delta_file_list_updated.append(delta_file_del_obj['updated'])
    if "param_to_add" in modify_type:
        if params_modify_dict['param_to_add']:
            delta_file_add = create_add_parameters_delta(parameters=params_modify_dict['param_to_add'],
                                                         connection=connection, bts_type=bts_type)
            delta_file_list_updated.append(delta_file_add['updated'])
    if "object_to_add" in modify_type:
        if params_modify_dict['object_to_add']:
            delta_file_add_obj = create_objects_delta(parameters=params_modify_dict['object_to_add'],
                                                      connection=connection)
            delta_file_list_updated.append(delta_file_add_obj['updated'])
    if "param_to_upd" in modify_type:
        if params_modify_dict['param_to_upd']:
            delta_file_upd = create_update_parameters_delta(parameters=params_modify_dict['param_to_upd'],
                                                            connection=connection, bts_type=bts_type)
            delta_file_list_updated.append(delta_file_upd['updated'])
    logging.debug("Delta files to be modified are {}".format(delta_file_list_updated))

    if not delta_file_list_updated:
        return "No NIDD modification is required. Nothing to do here."

    combined_json_data = []
    for json_file in delta_file_list_updated:
        file_obj = open(json_file, 'r')
        file_content = json.load(file_obj)
        combined_json_data.extend(file_content)
        file_obj.close()
    file_folder = delta_file_list_updated[0].rsplit(sep='/', maxsplit=1)[0]
    combined_json_file = file_folder + '/combined.json'
    logging.debug("combined_json_file is {}".format(combined_json_file))
    with open(combined_json_file, 'w') as f:
        json.dump(combined_json_data, f, indent=4, separators=(',', ':'))
    if bts_type == 'cu':
        commission_status = vcu_cm_business.fast_delta_commissioning_by_delta_json_file(
            json_file_path=combined_json_file, conn_alias=connection, timeout=timeout)
    elif bts_type == 'du':
        commission_status = vdu_cm_business.fast_delta_commission_with_delta_json_file(
            json_file_path=combined_json_file, conn_alias=connection, timeout=timeout)
    else:
        commission_status = perform_scf_delta_commission(
            delta_file=combined_json_file, timeout=timeout, connection=connection,
            skip_parameter_relation_errors=skip_parameter_relation_errors,
            should_activate=should_activate)
    return commission_status
