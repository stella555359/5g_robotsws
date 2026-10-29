# -*- coding: utf-8 -*-
"""
Author:         Ding Binmei
Contact Mail:   binmei.ding@nokia-sbell.com
Description:    Functions based on taf.gnb.oam.coam lib

"""
from taf.gnb.oam.coam.vdu import vdu
from taf.gnb.oam.coam.cu import cu
from taf.rfrl.cbts.devices.vcu.base.vcu_cm_base import vCUCM
import logging

vdu = vdu()
vcu = cu()
rfrl_vcu_cm_base = vCUCM()

__all__ = ['get_relation_mapping_between_cell_and_others',
           'get_relation_mapping_between_cell_and_others_from_cu',
           'get_mo_parameters',
           'get_parameters_under_nrbts_mo_from_cu',
           'get_nrrel_on_cu',
           'get_ru_info_from_vdu',
           'get_cells_status_on_vdu'
           ]


def get_relation_mapping_between_cell_and_others(vdu_connection="OAM_gnb0_du0"):
    """
    Ding Binmei
    Get relation mapping between cell id and others, info get from DU part
    cell_group_id, lcrId, physicalCellId are all included in detail_cell_info
    rmod id, rmod info are all included in detail_ru_info
    :param vdu_connection: alias for vdu connection via rest api
    :return:
     {1: # refers to cell id
        {   'cell_group_id': '1',
            'nrCellIdentity': '610156545',
            'lcrId': '1',
            'physicalCellId': '212'
            'detail_cell_info': {
                            'band': 'n77',
                            'blocking_state': 'Unblocked',
                            'cell_group_id': '1',
                            'dist_names': {'config': 'MRBTS-37241/NRBTS-37241/NRCELL-1',
                                           'runtime': None},
                            'id': '1',
                            'name': 'NRCELL-1',
                            'nr_cell_identity': '610156545',
                            'nrarfcn': '656666',
                            'technology': 'TDD',
                            ...},
            'detail_ru_info': {
                          'ant_ports': [xxx],
                          'cell_ids': ['1'],
                          'dist_names': {'config': 'MRBTS-37241/EQM-1/APEQM-1/RMOD-1',
                                         'runtime': 'MRBTS-37241/EQM_R-1/APEQM_R-1/RMOD_R-1'},
                          'id': '1',
                          'interface_type': 'eCPRI',
                          'product_code': '475927A.101',
                          'product_name': 'AWHQX',
                          'serial_number': 'EB2241R1272',
                          'technology_type': 'TDD'}
        }
    }
    """
    list_cells_info = vdu.get_vdu_cells_status(vdu_connection=vdu_connection)
    relation_mapping = {}
    for cell_info in list_cells_info:
        cell_related_info = {}
        cell_id = int(cell_info['id'])
        ru_info = get_ru_info_by_cell_id(cell_id=cell_id, vdu_connection=vdu_connection)
        lcrId = vdu.search_parameter_of_current_plan(mo_dn=cell_info['dist_names']['config'], para_name='lcrId',
                                                     vdu_connection=vdu_connection)
        # In order to align with classical, actually cell info are included in detail_cells_info
        cell_related_info['nrCellIdentity'] = cell_info['nr_cell_identity']
        cell_related_info['cell_group_id'] = cell_info['cell_group_id']
        cell_related_info['lcrId'] = lcrId
        cell_related_info['physicalCellId'] = cell_info['physical_layer_cell_id']
        cell_related_info['detail_cells_info'] = cell_info
        cell_related_info['detail_ru_info'] = ru_info
        relation_mapping[cell_id] = cell_related_info
    return relation_mapping


def get_ru_info_by_cell_id(cell_id, vdu_connection="OAM_gnb0_du0"):
    """
    Author: Ding Binmei
    :param cell_id:
    :param vdu_connection: alias for vdu connection via rest api
    :return: in dict format as bellow:
        {
                          'ant_ports': [xxx],
                          'cell_ids': ['1'],
                          'dist_names': {'config': 'MRBTS-37241/EQM-1/APEQM-1/RMOD-1',
                                         'runtime': 'MRBTS-37241/EQM_R-1/APEQM_R-1/RMOD_R-1'},
                          'id': '1',
                          'interface_type': 'eCPRI',
                          'product_code': '475927A.101',
                          'product_name': 'AWHQX',
                          'serial_number': 'EB2241R1272',
                          'technology_type': 'TDD'}
    """
    list_rus_info = vdu.get_rmods_status(vdu_connection=vdu_connection)
    logging.debug("list_rus_info:{}".format(list_rus_info))
    cell_id = str(cell_id)
    ru_info_for_cell = {}
    for ru_info in list_rus_info:
        if ru_info['cell_ids'] is not None:
            if cell_id in ru_info['cell_ids']:
                ru_info_for_cell = ru_info
    if len(ru_info_for_cell) == 0:
        logging.error("No RU info found for cell id: {}".format(cell_id))
    return ru_info_for_cell


def get_ru_info_from_vdu(vdu_connection="OAM_gnb0_du0"):
    """
    Author: Ding Binmei
    :param vdu_connection:
    :return: {'rmod_id':{rmod_info}}
    """
    list_rus_info = vdu.get_rmods_status(vdu_connection=vdu_connection)
    dict_ru_info = {}
    for ru_info in list_rus_info:
        rmod_id = ru_info['id']
        dict_ru_info[rmod_id] = ru_info
    return dict_ru_info


def get_relation_mapping_between_cell_and_others_from_cu(connection="OAM_CU0"):
    """
    Author: Ding Binmei
    Get relation mapping between cell id and others, info get from CU part
    :param connection:
    :return:
     {1: {'cell_group_id': '1',
     'detail_cells_info': {'administrative_state': 'Unlocked',
                           'cell_group_id': '1',
                           'cell_name': None,
                           'dist_names': {'config': 'MRBTS-37241/NRBTS-37241/NRCELL-1'},
                           'id': '1',
                           'name': 'NRCELL-1',
                           'nr_cell_identity': '610156545',
                           'nrarfcn': '510006',
                           'operational_state': 'disabled',
                           'physical_layer_cell_id': '212',
                           'technology': 'TDD'},
     'lcrId': 1,
     'nrCellIdentity': '610156545',
     'physicalCellId': '212'},{}}
    """
    list_cells_info = vcu.get_cells_statuses(connection=connection)
    relation_mapping = {}
    for cell_info in list_cells_info:
        cell_related_info = {}
        cell_id = int(cell_info['id'])
        cell_mo_info = get_mo_parameters(mo_dist_name=cell_info['dist_names']['config'], connection=connection)
        lcrId = cell_mo_info['lcrId']
        # In order to align with classical, actually cell info are included in detail_cells_info
        cell_related_info['nrCellIdentity'] = cell_info['nr_cell_identity']
        cell_related_info['cell_group_id'] = cell_info['cell_group_id']
        cell_related_info['lcrId'] = lcrId
        cell_related_info['physicalCellId'] = cell_info['physical_layer_cell_id']
        cell_related_info['detail_cells_info'] = cell_info
        relation_mapping[cell_id] = cell_related_info
    logging.info("cell mapping info: {}".format(relation_mapping))
    return relation_mapping


def get_mo_parameters(mo_dist_name, connection='OAM_CU0', bts_type='cu'):
    """
    Author: Ding Binmei
    Get parameters and return with key, value format.
    Tested with VCU: NRREL, NRBTS; VDU: NRBTS, NRCELL.
    :param mo_dist_name: like /MRBTS-XX/NRBTS-XX
    :param connection:
    :param bts_type: cu/du
    :return:
    {   'param1': 'value1',
        'param2': [{'sub_param1': 'sub_value1', 'sub_param2': 'sub_value2'}],...
    }
    """
    if bts_type == 'cu':
        mo_detail_params = vcu.get_parameters(dist_name=mo_dist_name, connection=connection)
    elif bts_type == 'du':
        mo_detail_params = vdu.get_managed_object_parameters_of_current_plan(dist_name=mo_dist_name,
                                                                             vdu_connection=connection)
    else:
        raise Exception("Unsupported bts_type, only cu / du is supported")
    dict_mo = {}
    for param in mo_detail_params['parameters']:
        param_type = param['parameter_type']
        logging.info("--------------------------{}".format(param))
        if param_type == 'simple':

            simple_param = _convert_data_to_dict(param=param['simple_parameter'])
            dict_mo[simple_param['name']] = simple_param['value']
        elif param_type == 'simpleList':
            simple_param = _convert_data_to_dict(param=param['simple_list_parameter'])
            dict_mo[simple_param['name']] = simple_param['value']
        else:
            complex_param = _convert_data_to_dict(param=param['complex_parameter'])
            complex_param_name = complex_param['name']
            complex_param_sub_items = _get_complex_param(list_param_items=list(complex_param['value']))
            dict_mo[complex_param_name] = complex_param_sub_items
    return dict_mo


def _convert_data_to_dict(param):
    """
    Author: Ding Binmei
    For CU, DU returned parameter data, some are in obj format, need to use to_dict() to do conversion
    :param param:
    :return:
    """
    if isinstance(param, dict):
        return param
    else:
        return param.to_dict()


def _get_complex_param(list_param_items):
    """
    Author: Ding Binmei
    :param list_param_items:
    :return:
    """
    list_complex_params = []
    for param in list_param_items:
        dict_complex_params = {}
        param = _convert_data_to_dict(param=param)
        for complex_param in param['structureParameters']:
            complex_param_sub_item_name = complex_param['simpleParameter']['name']
            complex_param_sub_item_value = complex_param['simpleParameter']['value']
            dict_complex_params[complex_param_sub_item_name] = complex_param_sub_item_value
        list_complex_params.append(dict_complex_params)
    return list_complex_params


def get_parameters_under_nrbts_mo_from_cu(cu_connection='OAM_CU0'):
    """
    Author: Ding Binmei
    :param cu_connection:
    :return: dict format as bellow:
        {'mcc': '460',
         'mnc': '2',
         'mncLength': '2',
         'neutralPlmnEnabled': 'false',
         'ngCplane': [{'ipV4AddressDN1': 'MRBTS-37241/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1'}],
         ...
        }
    """
    cu_info = vcu.get_cu_state(connection=cu_connection)
    mrbts_id = cu_info['mrbts_id']
    nrbts_id = cu_info['nrbts_id']
    nrbts_mo_dist_name = 'MRBTS-{}/NRBTS-{}'.format(mrbts_id, nrbts_id)
    nrbts_mo_info = get_mo_parameters(mo_dist_name=nrbts_mo_dist_name,
                                      connection=cu_connection, bts_type='cu')
    return nrbts_mo_info


def get_nrrel_on_cu(cu_connection='OAM_CU0'):
    """
    Author: Ding Binmei
    :param connection_alias:
    :return:
    Return data as bellow:
    [{'nrrel_id': '1',
      'parameters': {'cellIndividualSsbRsrpOffset': '0dB',
                     'cellIndividualSsbRsrqOffset': '0dB',
                     'gNbId': 11171,
                     'gNbIdLength': 32,
                     'gnbPlmn': [{'mcc': 310, 'mnc': 260, 'mncLength': 3}],
                     'handoverAllowedSA': 'allowed',
                     'lcrId': 4,
                     'nrDcAllowed': False,
                     'removeNotAllowed': False,
                     'sCellAdditionMethod': None,
                     'sCellOperationalMode': None,
                     ...},
       'short_distName': 'MRBTS-413/NRBTS-11171/NRCELL-1/NRREL-1'},...]
    """
    dict_nrrel_info = vcu.search_parameters_of_current_plan(parameter_name='nrRelId', connection=cu_connection)
    list_nrrel_mo = []
    if dict_nrrel_info['total'] != 0:
        list_nrrel_info = dict_nrrel_info['items']
        for nrrel_info in list_nrrel_info:
            nrrel_dist_name = nrrel_info['distname']
            nrrel_id = nrrel_info['parameter']['simple_parameter']['value']
            dict_nrrel_mo = {}
            dict_nrrel_mo['short_distName'] = nrrel_dist_name
            dict_nrrel_mo['nrrel_id'] = nrrel_id
            dict_nrrel_mo['parameters'] = get_mo_parameters(mo_dist_name=nrrel_dist_name,
                                                            connection=cu_connection, bts_type='cu')
            list_nrrel_mo.append(dict_nrrel_mo)
    return list_nrrel_mo


def get_cells_status_on_vdu(vdu_connection="OAM_gnb0_du0"):
    """
    Author: Lingxue Cui
    Get cells status from vdu and re-index by cell id.
    :param vdu_connection:
    Return dict as below:
    {'1': {'administrative_state': 'Unlocked',
           'availability_status': 'dependency',
           'band': 'n77',
           'blocking_state': 'Unblocked',
           'cell_group_id': '1',
           'ch_bw': '100MHz',
           'ch_bw_dl': None,
           'ch_bw_ul': None,
           'dist_names': {'config': 'MRBTS-37241/NRBTS-37241/NRCELL-1',
                          'runtime': None},
           'dl_mimo_mode': '4x4 or 4x2 Closed Loop Spatial Multiplexing',
           'name': 'NRCELL-1',
           'nr_cell_identity': '610156545',
           'nrarfcn': '664366',
           'nrarfcn_dl': None,
           'nrarfcn_ul': None,
           'operational_state': 'disabled',
           'p_max': '23',
           'physical_layer_cell_id': '471',
           'procedural_status': 'configured',
           'technology': 'TDD',
           'ul_mimo_mode': 'Closed loop Spatial Multiplexing (2x2)'
           }
    }
    """
    list_cells_info = vdu.get_vdu_cells_status(vdu_connection=vdu_connection)

    dict_cells_info = {}
    for cell_info in list_cells_info:
        cell_id = str(cell_info['id'])
        del cell_info['id']
        print(cell_info)
        dict_cells_info[cell_id] = cell_info
    return dict_cells_info
