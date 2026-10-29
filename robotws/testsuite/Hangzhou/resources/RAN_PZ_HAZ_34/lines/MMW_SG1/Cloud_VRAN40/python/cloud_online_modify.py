"""
Author: Ding Binmei
Documentation: Support online modify with non-provision method.
Recommend to use it instead of provision method, it's aligned with webEM operations
"""


from taf.gnb.oam.coam.cu import cu
from taf.rfrl.cbts.devices.vcu.base.vcu_cm_base import vCUCM
import taf.rfrl.cbts.devices.vcu.business.vcu_cm_business as rfrl_vcu_cm_business
import taf.rfrl.cbts.devices.vdu.business.vdu_cm_business as rfrl_vdu_cm_business
import logging
import time
import json

vcu = cu()
rfrl_vcu_cm_base = vCUCM()

__all__ = [
    # support list type: add/update/delete params, support for a single type of operation
    'convert_update_param_format_to_aic_format',
    # support dict type: Can add/update/delete params together
    'convert_classical_data_format_to_aic_param_update_format',
    # Only tested on vcu, including data convert and delta params activation after modify
    'online_modify_for_params_update_with_non_provision_method',
    'delete_mo_on_cu'
           ]


def convert_classical_data_format_to_aic_param_update_format(params_to_modify):
    """
    Author: Ding Binmei

    :param params_to_modify:
    {
    'param_to_add': [{'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                   'parameter': 'sCellAdditionMethod', 'value': 'blind'},
                  {'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                   'parameter': 'sCellOperationalMode','value': 'dlOnly'}],
    'param_to_upd': [{'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                   'parameter': 'handoverAllowedSA', 'value': 'forbidden'}]} ],
    'param_to_del': [{'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                   'parameter': 'sCellAdditionMethod'},
                  {'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                   'parameter': 'sCellOperationalMode'}],
    'object_to_add': [{'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                    'parameter': 'cellIndividualSsbRsrpOffset',
                    'value': '0dB'},
                   {'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                    'parameter': 'cellIndividualSsbRsrqOffset',
                    'value': '0dB'},
                   {'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                    'parameter': 'gNbId',
                    'value': '37241'},
                   {'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                    'parameter': 'gNbIdLength',
                    'value': '22'},
                   {'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                    'parameter': 'lcrId',
                    'value': '2'},
                   {'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                    'parameter': 'removeNotAllowed',
                    'value': 'false'},
                   {'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                    'parameter': 'gnbPlmn',
                    'value': [{'mcc': '460', 'mnc': '2', 'mncLength': '2'}]},
                   {'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                    'parameter': 'handoverAllowedSA',
                    'value': 'allowed'},
                   {'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                    'parameter': 'nrDcAllowed',
                    'value': 'false'},
                   {'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                    'parameter': 'handoverAllowedSARedCap',
                    'value': 'forbidden'},
                   {'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                    'parameter': 'isRplCellForPSCell',
                    'value': 'false'},
                   {'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                    'parameter': 'sCellAdditionMethod',
                    'value': 'blind'},
                   {'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                    'parameter': 'sCellOperationalMode',
                    'value': 'dlOnly'}]
    }
    :return:
    [
        ['MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
            {'sCellAdditionMethod': 'blind', 'sCellOperationalMode': 'dlOnly'}, 'add'],
        ['MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
            {'handoverAllowedSA': 'forbidden'}, 'replace'],
        ['MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
            {'sCellAdditionMethod': '', 'sCellOperationalMode': ''}, 'remove'],
        ['MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
            {'cellIndividualSsbRsrpOffset': '0dB',
            'cellIndividualSsbRsrqOffset': '0dB',
            'gNbId': '37241',
            'gNbIdLength': '22',
            'lcrId': '2',
            'removeNotAllowed': 'false',
            'gnbPlmn': [{'mcc': '262', 'mnc': '3', 'mncLength': '2'}]
            'handoverAllowedSA': 'allowed',
            'handoverAllowedSARedCap': 'forbidden',
            'isRplCellForPSCell': 'false',
            'sCellAdditionMethod': 'blind',
            'sCellOperationalMode': 'dlOnly'}, 'add']
    ]
    """
    modify_type = params_to_modify.keys()
    final_aic_format = []
    if "object_to_add" in modify_type:
        if params_to_modify['object_to_add']:
            final_aic_format.extend(convert_update_param_format_to_aic_format(
                list_params_to_update=params_to_modify['object_to_add'], operation_type="add"))
    if "param_to_add" in modify_type:
        if params_to_modify['param_to_add']:
            final_aic_format.extend(convert_update_param_format_to_aic_format(
                list_params_to_update=params_to_modify['param_to_add'], operation_type="add"))
    if "param_to_upd" in modify_type:
        if params_to_modify['param_to_upd']:
            final_aic_format.extend(convert_update_param_format_to_aic_format(
                    list_params_to_update=params_to_modify['param_to_upd'], operation_type="replace"))
    if "param_to_del" in modify_type:
        if params_to_modify['param_to_del']:
            final_aic_format.extend(convert_update_param_format_to_aic_format(
                list_params_to_update=params_to_modify['param_to_del'], operation_type="remove"))
    logging.info("convert_classical_data_format_to_aic_param_update_format, current format:{}".format(
        final_aic_format))
    return final_aic_format


def online_modify_for_params_update_with_non_provision_method(params_to_modify, connection="OAM_CU0", bts_type="cu"):
    """
    Author: Ding Binmei
    TODO: Currently this keyword only tested on vCU, we can also extend to VDU if there is such necessity
    :param params_to_modify: same format as in method convert_classical_data_format_to_aic_param_update_format
                            please refer to the documentation part
    :param connection:
    :return:
    """
    final_aic_format = convert_classical_data_format_to_aic_param_update_format(params_to_modify=params_to_modify)
    logging.debug("update bts_type:{}".format(bts_type))
    if final_aic_format:
        if bts_type == 'cu':
            rfrl_vcu_cm_business.delta_commissioning_step_by_step(
                delta_data_list=final_aic_format, conn_alias=connection)
        else:
            rfrl_vdu_cm_business.delta_commission_step_by_step(
                delta_data_list=final_aic_format, conn_alias=connection)
    else:
        logging.info("NIDD values are as expected, no need to update")


def convert_update_param_format_to_aic_format(list_params_to_update, operation_type):
    """
    Author: Ding Binmei
    Support to convert multiple MOs.
    :param list_params_to_update:
              --same format as in method convert_classical_data_format_to_aic_param_update_format
                please refer to the documentation part for param_to_add/param_to_update/param_to_del/
                object_to_add
    :param operation_type: remove, add, replace, revert
    :return: format which can be used in method vcu_cm_business.delta_commissioning_step_by_step
    --param_to_add:
    ['MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
            {'sCellAdditionMethod': 'blind', 'sCellOperationalMode': 'dlOnly'}, 'add']
    --param_to_upd:
    [['MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1', {'handoverAllowedSA': 'allowed'}, 'replace']
    --param_to_del:
    ['MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
            {'sCellAdditionMethod': '', 'sCellOperationalMode': ''}, 'remove']
    --object_to_add: Please note nrDcAllowed only valid for classical bts.
    [['MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
            {'cellIndividualSsbRsrpOffset': '0dB',
            'cellIndividualSsbRsrqOffset': '0dB',
            'gNbId': '37241',
            'gNbIdLength': '22',
            'lcrId': '2',
            'removeNotAllowed': 'false',
            'gnbPlmn': [{'mcc': '262', 'mnc': '3', 'mncLength': '2'}]
            'handoverAllowedSA': 'allowed',
            'handoverAllowedSARedCap': 'forbidden',
            'isRplCellForPSCell': 'false',
            'sCellAdditionMethod': 'blind',
            'sCellOperationalMode': 'dlOnly'}, 'add']]

    """
    dict_mo_param_info = {}
    for param_info in list_params_to_update:
        mo_dist_name = param_info['dist_name']
        if mo_dist_name not in dict_mo_param_info.keys():
            dict_mo_param_info[mo_dist_name] = [param_info]
        else:
            dict_mo_param_info[mo_dist_name].append(param_info)
    list_aic_format_for_mos = []
    for single_mo in dict_mo_param_info.keys():
        aic_format_single_mo = _convert_update_param_data_format_to_aic_format_single_mo(
            list_params_to_update_single_mo=dict_mo_param_info[single_mo], operation_type=operation_type)
        list_aic_format_for_mos.append(aic_format_single_mo)
        logging.debug("update MO:{}, detail_info:{}".format(single_mo, aic_format_single_mo))
    return list_aic_format_for_mos


def _convert_update_param_data_format_to_aic_format_single_mo(list_params_to_update_single_mo, operation_type):
    """
    Author: Ding Binmei
    Support for single mo
    :param list_params_to_update_single_mo:
    :param operation_type: remove, add, replace, revert
    :return:
    """
    dict_params_info = {}
    for param_info in list_params_to_update_single_mo:
        param_name = param_info['parameter']
        try:
            param_value = param_info['value']
        except KeyError:
            logging.debug("No value exist for parameter: {}, this is for remove action".format(param_name))
            param_value = ''
        dict_params_info[param_name] = param_value
    mo_dist_name = list_params_to_update_single_mo[0]['dist_name']
    aic_one_mo_format = [mo_dist_name, dict_params_info, operation_type]
    return aic_one_mo_format


def convert_delete_mo_format_to_json_format(list_mo_to_delete):
    """
    Author: Ding Binmei
    :param list_mo_to_delete: [{'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1'},
                               {'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-2'}]

    return with json format in string:
    '[{"distName": "MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1", "operation": "delete", "parameters": []},
      {"distName": "MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-2", "operation": "delete", "parameters": []}]'
    """
    delta_file = []
    for dict_mo_dist_name in list_mo_to_delete:
        mo_to_delete_new_format = {
            "distName": dict_mo_dist_name['dist_name'], "operation": "delete", "parameters": []}
        delta_file.append(mo_to_delete_new_format)
    delta_file_json = json.dumps(delta_file)
    logging.info("delta_file_json format:{}".format(delta_file_json))
    return delta_file_json


def delete_mo_on_cu(list_mo_to_delete, connection="OAM_CU0", timeout=300,
                    is_to_active_plan=True):
    """
    Author: Ding Binmei
    :param list_mo_to_delete: [{'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1'}]
    :param connection:
    :param timeout: timeout for wait for mo delete
    :param is_to_active_plan: True/ False
    :return:
    """
    if list_mo_to_delete:
        delta_file_json = convert_delete_mo_format_to_json_format(list_mo_to_delete=list_mo_to_delete)
        vcu.perform_delta_recommissioning(
            delta_file=delta_file_json,
            wait_for_completion=True,
            should_activate=is_to_active_plan,
            timeout=timeout,
            connection=connection)
    else:
        logging.info("delete_mo_on_cu: No MO need to be deleted, skip the delete operation")
