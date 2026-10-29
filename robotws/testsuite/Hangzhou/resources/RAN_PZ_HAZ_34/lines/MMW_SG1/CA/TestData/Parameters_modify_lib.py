"""
Author: Ding Binmei
Documentation: This file is used to control the logic for NIDD parameter modification
"""
__init__ = ["get_flexible_ca_mode_value",
            "generate_flexible_ca_mode_for_scf_modify",
            "generate_carrier_aggregation_support_list_for_scf_modify",
            "get_bts_info_from_scf_file",
            "generate_data_based_on_template",
            "get_dn_for_cells",
            "get_parameter_list_for_update_for_cells"
            ]
from robot.libraries.BuiltIn import BuiltIn
from taf.config.scf import scf
import logging
import json
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.bts.vran40.cloud_gnb as cloud_gnb
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_gnb_classical as coam_gnb_classical
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_parameter import *


scf = scf()
tl = BuiltIn().get_variable_value('${tl}')
DN_MRBTS = 'MRBTS-' + str(tl.gnbs[0].instance_id)
DN_NRBTS = DN_MRBTS + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
DN_NRDU1 = DN_NRBTS + '/NRDU-1'


def get_dn_for_cells(list_cell_id, dist_name=DN_NRBTS):
    list_dn_cells = []
    for cell_id in list_cell_id:
        cell_dist_name = dist_name + '/NRCELL-' + str(cell_id)
        list_dn_cells.append(cell_dist_name)
    return list_dn_cells


def get_dn_for_cells_for_gnb(list_cell_id, gnb_id='0'):

    DN_MRBTS = 'MRBTS-' + str(tl.gnbs[int(gnb_id)].instance_id)
    DN_NRBTS = DN_MRBTS + '/NRBTS-' + str(tl.gnbs[int(gnb_id)].global_bts_id)
    DN_NRDU1 = DN_NRBTS + '/NRDU-1'

    list_dn_cells = []
    for cell_id in list_cell_id:
        cell_dist_name = DN_NRBTS + '/NRCELL-' + str(cell_id)
        list_dn_cells.append(cell_dist_name)
    return list_dn_cells


def get_dn_for_nrrim_for_gnb(list_cell_id, gnb_id='0', profile_id='1'):

    DN_MRBTS = 'MRBTS-' + str(tl.gnbs[int(gnb_id)].instance_id)
    DN_NRBTS = DN_MRBTS + '/NRBTS-' + str(tl.gnbs[int(gnb_id)].global_bts_id)
    DN_NRDU1 = DN_NRBTS + '/NRDU-1'

    list_dn_cells = []
    for cell_id in list_cell_id:
        cell_dist_name = DN_NRBTS + '/NRCELL-' + \
            str(cell_id) + '/NRRIM_PROFILE-' + str(profile_id)
        list_dn_cells.append(cell_dist_name)
    return list_dn_cells


def get_flexible_ca_mode_value(program, is_dpa_enabled=None):
    """
    Get flexible ca mode value:
    On 21A no need to config for flexibleCAMode
    On 21B both MixedCAMode and BasicCAMode are supported
    On 21B later branches, BasicCAMode is not supported

    :param program:
    :param is_dpa_enabled: True/False/None
    :return:
    """
    is_dpa_enabled = False if is_dpa_enabled is None else bool(is_dpa_enabled)
    if is_dpa_enabled or program != "21B":
        flexible_ca_mode = "MixedCAMode"
    else:
        if program == '21A':
            flexible_ca_mode = None
        else:
            flexible_ca_mode = "BasicCAMode"
    return flexible_ca_mode


def generate_flexible_ca_mode_for_scf_modify(program, is_dpa_enabled=None, dist_name=DN_NRDU1):
    """

    :param program:
    :param is_dpa_enabled:
    :return:
    """
    flexible_ca_mode = get_flexible_ca_mode_value(
        program=program, is_dpa_enabled=is_dpa_enabled)
    list_paramters_for_update = []
    if flexible_ca_mode is not None:
        parameter_for_update = dict(
            value=flexible_ca_mode, dist_name=dist_name, p_name='flexibleCAMode')
        list_paramters_for_update.append(parameter_for_update)
    return list_paramters_for_update


def generate_carrier_aggregation_support_list_for_scf_modify(carrier_aggregation_support_list, dist_name=DN_NRDU1):
    """
    If need to modify via SCF, then the count for list value should be the same.
    EG. if original support for ca_Fdd_Fr1Tdd_Sa and ca_Fdd_Fr1Tdd_Nsa, then carrier_aggregation_support_list
    should include 2 types
    :param carrier_aggregation_support_list: should be in list format
    :return:
    """
    list_paramters_for_update = []
    for index, ca_support_list_value in enumerate(carrier_aggregation_support_list, 0):
        parameter_for_update = dict(value=ca_support_list_value, dist_name=dist_name,
                                    list_name='carrierAggregationSupportList', index=index)
        list_paramters_for_update.append(parameter_for_update)
    return list_paramters_for_update


def get_bts_info_from_scf_file(local_scf_file_path, dist_name=DN_NRBTS):
    """
    Get bts info from scf file. You can extend this method to return more needed info
    :param local_scf_file_path:
    :return:
    """
    list_p_name = ["mncLength", "gNbIdLength"]
    scf.load_scf(file_path=local_scf_file_path)
    dict_bts_info = {}
    for p_name in list_p_name:
        logging.debug("DN_NRBTS:{}, p_name:{}".format(dist_name, p_name))
        value = scf.get_value_from_scf(dist_name=dist_name, p_name=p_name)
        dict_bts_info[p_name] = value
    return dict_bts_info


def generate_nrrel_with_cell_for_scf_add(program, dist_name, cell_lcrid, gNbIdLength, mncLength):
    """
    :param  cell_name as FDD or TDD, then update dist_name and lcrId
    :return: list_paramters_to_add
    """
    if program == '22R4' or program == '23R1':
        list_paramters_to_add = [
            dict(dist_name=dist_name, version="NRBTSCL22R1_2109_102",
                 class_name="com.nokia.srbts.nrbts:NRREL"),
            dict(dist_name=dist_name,
                 p_name="cellIndividualSsbRsrpOffset", value="0dB"),
            dict(dist_name=dist_name,
                 p_name="cellIndividualSsbRsrqOffset", value="0dB"),
            dict(dist_name=dist_name, p_name="gNbId",
                 value=str(tl.gnbs[0].global_bts_id)),
            dict(dist_name=dist_name, p_name="gNbIdLength", value=gNbIdLength),
            dict(dist_name=dist_name, p_name="lcrId", value=cell_lcrid),
            dict(dist_name=dist_name, p_name="removeNotAllowed", value="false"),
            dict(dist_name=dist_name, p_name="sCellAdditionMethod", value="blind"),
            dict(dist_name=dist_name, p_name="nrRelId", value="1"),
            dict(dist_name=dist_name, p_name="handoverAllowedSA", value="allowed"),
            dict(dist_name=dist_name, p_name="nrDcAllowed", value="false"),
            dict(dist_name=dist_name, list_name="gnbPlmn",
                 elements=dict(mcc=tl.core.mcc, mnc=tl.core.mnc, mncLength=mncLength)),
        ]
    elif program == '23R2':
        list_paramters_to_add = [
            dict(dist_name=dist_name, version="NRBTSCL22R1_2109_102",
                 class_name="com.nokia.srbts.nrbts:NRREL"),
            dict(dist_name=dist_name,
                 p_name="cellIndividualSsbRsrpOffset", value="0dB"),
            dict(dist_name=dist_name,
                 p_name="cellIndividualSsbRsrqOffset", value="0dB"),
            dict(dist_name=dist_name, p_name="gNbId",
                 value=str(tl.gnbs[0].global_bts_id)),
            dict(dist_name=dist_name, p_name="gNbIdLength", value=gNbIdLength),
            dict(dist_name=dist_name, p_name="lcrId", value=cell_lcrid),
            dict(dist_name=dist_name, p_name="removeNotAllowed", value="false"),
            dict(dist_name=dist_name, p_name="sCellAdditionMethod", value="blind"),
            dict(dist_name=dist_name, p_name="sCellOperationalMode", value="dlOnly"),
            dict(dist_name=dist_name, p_name="nrRelId", value="1"),
            dict(dist_name=dist_name, p_name="handoverAllowedSA", value="allowed"),
            dict(dist_name=dist_name,
                 p_name="handoverAllowedSARedCap", value="forbidden"),
            dict(dist_name=dist_name, p_name="nrDcAllowed", value="false"),
            dict(dist_name=dist_name, list_name="gnbPlmn",
                 elements=dict(mcc=tl.core.mcc, mnc=tl.core.mnc, mncLength=mncLength)),
        ]
    else:
        list_paramters_to_add = [
            dict(dist_name=dist_name, version="NRBTSCL22R1_2109_102",
                 class_name="com.nokia.srbts.nrbts:NRREL"),
            dict(dist_name=dist_name,
                 p_name="cellIndividualSsbRsrpOffset", value="0dB"),
            dict(dist_name=dist_name,
                 p_name="cellIndividualSsbRsrqOffset", value="0dB"),
            dict(dist_name=dist_name, p_name="gNbId",
                 value=str(tl.gnbs[0].global_bts_id)),
            dict(dist_name=dist_name, p_name="gNbIdLength", value=gNbIdLength),
            dict(dist_name=dist_name, p_name="lcrId", value=cell_lcrid),
            dict(dist_name=dist_name, p_name="removeNotAllowed", value="false"),
            dict(dist_name=dist_name, p_name="sCellAdditionMethod", value="blind"),
            dict(dist_name=dist_name, p_name="sCellOperationalMode", value="dlOnly"),
            dict(dist_name=dist_name, p_name="nrRelId", value="1"),
            dict(dist_name=dist_name, p_name="handoverAllowedSA", value="allowed"),
            dict(dist_name=dist_name,
                 p_name="handoverAllowedSARedCap", value="allowed"),
            dict(dist_name=dist_name, p_name="isRplCellForPSCell", value="false"),
            dict(dist_name=dist_name, p_name="nrDcAllowed", value="false"),
            dict(dist_name=dist_name, list_name="gnbPlmn",
                 elements=dict(mcc=tl.core.mcc, mnc=tl.core.mnc, mncLength=mncLength)),
        ]
    return list_paramters_to_add


def generate_actK1Opt_for_scf_modify(program, dist_name, is_k1opt_enabled='true'):
    """

    :param program:
    :param is_k1opt_enabled: if 'true', 'intra-gNB' will be used for value 'actK1Opt' of on 23R1 branch.
    :return:
    """
    if program == '22R3' or program == '22R4':
        p_name = 'actK1OptForDPA'
        value = is_k1opt_enabled
    else:
        p_name = 'actK1Opt'
        if is_k1opt_enabled:
            value = 'intra-gNB'
        else:
            value = 'disabled'

    list_paramters_for_update = []
    parameter_for_update = dict(
        dist_name=dist_name, p_name=p_name, value=value)
    list_paramters_for_update.append(parameter_for_update)
    return list_paramters_for_update


def generate_data_based_on_template(data_template, **kwargs):
    """
    Author: Ding Binmei
    Generate parameter list for scf update/ online modification for parameters
    : param data_template
    """
    return json.loads(data_template.format(**kwargs))


def get_parameter_list_for_update_for_cells(data_template, list_cell_id, dist_name=DN_NRBTS, value=None, **kwargs):
    """
    Author: Ding Binmei
    Generate parameter list for SCF or rest api for provided cells. The only thing you will need to do is to
    provide data_template.
    :param data_template:
        String format like bellow:
        SCF_MODIFY_TEMPLATE_BASE_ALL_CELLS = '''
    [
        {{
            "dist_name":"{dist_name}",
            "p_name":"actCDrx",
            "value":"false"
        }}
    ]'''
    :param list_cell_id: e.g: [1,2,3]
    :param value: Use the value defined in data template if not input.
    :return:
        e.g: [{'dist_name': 'MRBTS-10152/NRBTS-10152/NRCELL-1', 'p_name': 'actCDrx', 'value': 'false'},
            {'dist_name': 'MRBTS-10152/NRBTS-10152/NRCELL-2','p_name': 'actCDrx', 'value': 'false'}]
    """
    list_params_cells = []
    list_cell_dn = get_dn_for_cells(
        list_cell_id=list_cell_id, dist_name=dist_name)
    for cell_dn in list_cell_dn:
        logging.debug("cell_dn:"+cell_dn)
        param_update_cell = generate_data_based_on_template(data_template=data_template, dist_name=cell_dn,
                                                            value=value, **kwargs)
        list_params_cells = list_params_cells + param_update_cell
    return list_params_cells


def get_nrrel_params_for_online_update_based_on_ca_group_mapping_config(ca_group_mapping, program='master'):
    """
    Author: Ding Binmei
    Generate params for nrrel update based on ca_group_mapping.
    Please note it will only generate the param list for update.
    You still need to call coam admin lib to take effecitve online
    :param ca_group_mapping: dict format configured in init file under commission folder
    {
        'pcell_id': 0,
        'gnb_connection_alias_pcell': 'GNB_OAM',
        'nrrel_info': [
            {
                'gnb_connection_alias': 'GNB_OAM',
                'nrrel_config': {    # This is used for update nrrel settings
                    4:{'sCellOperationalMode': 'dlAndUl', 'sCellAdditionMethod': 'blind'},
                    5:{'sCellOperationalMode': 'dlOnly', 'sCellAdditionMethod': 'blind'}
                }
            }
        ]
    }
    :return: E.G: {'object_to_add': [], 'param_to_add': [], 'param_to_upd': [], 'param_to_del': []}
    """
    connection_alias_source = ca_group_mapping['gnb_connection_alias_pcell']
    is_cloud = tl_info.has_cloudBts(tl)
    if is_cloud:
        source_gnb_relation_mapping = cloud_gnb.get_relation_mapping_between_cell_and_others_from_cu(
            connection=connection_alias_source)
    else:
        source_gnb_relation_mapping = coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids(
            connection_alias=connection_alias_source)
    param_update = {'object_to_add': [], 'param_to_add': [],
                    'param_to_upd': [], 'param_to_del': []}
    list_available_nrrel_id = coam_gnb_classical.get_available_nrrel_id_for_addition_operation(
        source_cell_id=ca_group_mapping['pcell_id'], source_gnb_relation_mapping=source_gnb_relation_mapping,
        connection_alias_source=connection_alias_source)
    param_update_k2_temp = get_nrrel_increasePUSCHPrepTimeULCA(ca_group_mapping=ca_group_mapping,
                                                               connection_alias=connection_alias_source)
    nrrel_id_search_index = 0
    for neighbor_cell_info in ca_group_mapping['nrrel_info']:
        connection_alias_neighbor = neighbor_cell_info['gnb_connection_alias']
        if is_cloud:
            neighbor_gnb_relation_mapping = cloud_gnb.get_relation_mapping_between_cell_and_others_from_cu(
                connection=connection_alias_neighbor)
        else:
            neighbor_gnb_relation_mapping = coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids(
                connection_alias=connection_alias_neighbor)
        nrrel_config = neighbor_cell_info['nrrel_config']
        for neighbor_cell_id in nrrel_config.keys():
            dict_exp_config = nrrel_config[neighbor_cell_id]
            param_update_temp = coam_gnb_classical.get_nrrel_params_for_online_update(
                source_cell_id=ca_group_mapping['pcell_id'], neighbor_cell_id=neighbor_cell_id,
                dict_exp_config=dict_exp_config, source_gnb_relation_mapping=source_gnb_relation_mapping,
                neighbor_gnb_relation_mapping=neighbor_gnb_relation_mapping,
                list_available_nrrel_id=list_available_nrrel_id,
                nrrel_id_search_index=nrrel_id_search_index,
                program=program,
                connection_alias_source=connection_alias_source,
                connection_alias_neighbor=connection_alias_neighbor)
            if param_update_temp['object_to_add']:
                param_update['object_to_add'].extend(
                    param_update_temp['object_to_add'])
                nrrel_id_search_index = nrrel_id_search_index + 1
            if param_update_temp['param_to_add']:
                param_update['param_to_add'].extend(
                    param_update_temp['param_to_add'])
            if param_update_temp['param_to_upd']:
                param_update['param_to_upd'].extend(
                    param_update_temp['param_to_upd'])
            if param_update_temp['param_to_del']:
                param_update['param_to_del'].extend(
                    param_update_temp['param_to_del'])
            if param_update_k2_temp['param_to_add']:
                for item in param_update_k2_temp['param_to_add']:
                    if item not in param_update['param_to_add']:
                        param_update['param_to_add'].append(item)
            if param_update_k2_temp['param_to_upd']:
                for item in param_update_k2_temp['param_to_upd']:
                    if item not in param_update['param_to_upd']:
                        param_update['param_to_upd'].append(item)
            if param_update_k2_temp['param_to_del']:
                for item in param_update_k2_temp['param_to_del']:
                    if item not in param_update['param_to_del']:
                        param_update['param_to_del'].append(item)
    return param_update


def get_nrrel_increasePUSCHPrepTimeULCA(ca_group_mapping, connection_alias='GNB_OAM'):
    """
    Author: Wang Yixiang
    Need to set increasePUSCHPrepTimeULCA=true if the cell is ULCA.

    In 23R2, k2 is changed to 3 if increasePUSCHPrepTimeULCA equals to true,
    otherwisek2 is not changed (false or not set). And we introduces this new PDL rule that TDD SCell for
    FDD PCell UL CA shall set NRCELL.increasePUSCHPrepTimeULCA to true, then it enforce K2=3 in this TDD SCell.

    :param ca_group_mapping: dict format configured in init file under commission folder
    {
        'pcell_id': 0,
        'gnb_connection_alias_pcell': 'GNB_OAM',
        'nrrel_info': [
            {
                'gnb_connection_alias': 'GNB_OAM',
                'nrrel_config': {    # This is used for update nrrel settings
                    4:{'sCellOperationalMode': 'dlAndUl', 'sCellAdditionMethod': 'blind'},
                    5:{'sCellOperationalMode': 'dlOnly', 'sCellAdditionMethod': 'blind'}
                }
            }
        ]
    }
    :return: E.G: {'object_to_add': [], 'param_to_add': [], 'param_to_upd': [], 'param_to_del': []}
    """
    is_cloud = tl_info.has_cloudBts(tl)
    if is_cloud:
        bts_type = 'du'
        gnb_relation_mapping = cloud_gnb.get_relation_mapping_between_cell_and_others(
            vdu_connection=connection_alias)
    else:
        bts_type = 'classical'
        gnb_relation_mapping = coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids(
            connection_alias=connection_alias)

    cell_list = gnb_relation_mapping.keys()

    ul_ca_cell_list = []
    nrrel_info = ca_group_mapping['nrrel_info']
    for nrrel in nrrel_info:
        nrrel_config = nrrel['nrrel_config']
        for k, v in nrrel_config.items():
            if v.get('sCellOperationalMode') == 'dlAndUl':
                ul_ca_cell_list.append(k)

    dict_nrrel_update = {'object_to_add': [], 'param_to_add': [
    ], 'param_to_upd': [], 'param_to_del': []}

    if ul_ca_cell_list != []:
        for cell_id in cell_list:
            if is_cloud:
                cell_dn = gnb_relation_mapping[cell_id]['detail_cells_info']['dist_names']['config']
            else:
                cell_dn = gnb_relation_mapping[cell_id]['detail_cells_info']['id']['configuration']
            for ul_ca_cell_id in ul_ca_cell_list:
                # dist_name = dist_name + "/NRCELL-{}".format(cell_id)
                k2_para = get_single_value_from_scf_file(parameter="increasePUSCHPrepTimeULCA",
                                                         dist_name=cell_dn,
                                                         config_type='configurationAndRuntimeObjects',
                                                         connection=connection_alias,
                                                         bts_type=bts_type,
                                                         timeout=30)
                if k2_para == [] and cell_id != ul_ca_cell_id:
                    # increasePUSCHPrepTimeULCA not exist and this cell not ULCA, and the para not need to set
                    pass
                elif k2_para == [] and cell_id == ul_ca_cell_id:
                    add_param = dict(dist_name=cell_dn, parameter="increasePUSCHPrepTimeULCA",
                                     value="true")
                    dict_nrrel_update['param_to_add'].append(add_param)
                elif k2_para == 'true' and cell_id == ul_ca_cell_id:
                    # increasePUSCHPrepTimeULCA=true and this cell is ulca cell
                    pass
                elif k2_para == 'false' and cell_id == ul_ca_cell_id:
                    update_param = dict(dist_name=cell_dn, parameter="increasePUSCHPrepTimeULCA",
                                        value="true")
                    dict_nrrel_update['param_to_upd'].append(update_param)
                elif k2_para == 'true' and cell_id != ul_ca_cell_id:
                    # increasePUSCHPrepTimeULCA=true and this cell is not ulca cell
                    update_param = dict(dist_name=cell_dn, parameter="increasePUSCHPrepTimeULCA",
                                        value="false")
                    dict_nrrel_update['param_to_upd'].append(update_param)
                elif k2_para == 'false' and cell_id != ul_ca_cell_id:
                    pass
                else:
                    raise AttributeError(
                        "get_nrrel_increasePUSCHPrepTimeULCA: please check!!")
    return dict_nrrel_update


def get_nrrel_params_for_online_update_based_on_ca_group_mapping_no_increasePUSCHPrepTimeULCA(
        ca_group_mapping, program='master', bts_type='classical', is_nrrel_id_needed=True):
    """
    Author: Liu Zheng
    Generate params for nrrel update based on ca_group_mapping.
    Please note it will only generate the param list for update.
    You still need to call coam admin lib to take effecitve online
    for CB009169, the increasePUSCHPrepTimeULCA is not configured
    :param ca_group_mapping: dict format configured in init file under commission folder
    {
        'pcell_id': 0,
        'gnb_connection_alias_pcell': 'GNB_OAM',
        'nrrel_info': [
            {
                'gnb_connection_alias': 'GNB_OAM',
                'nrrel_config': {    # This is used for update nrrel settings
                    4:{'sCellOperationalMode': 'dlAndUl', 'sCellAdditionMethod': 'blind'},
                    5:{'sCellOperationalMode': 'dlOnly', 'sCellAdditionMethod': 'blind'}
                }
            }
        ]
    }
    :param bts_type: classical/cu, for cloud, the modification is only on vCU.
    :param is_nrrel_id_needed: True/False. For cloud, if using online modify via provision/non-provision method,
     it should be False while adding nrrel MO. For others, leave it as True
    :return: E.G: {'object_to_add': [], 'param_to_add': [], 'param_to_upd': [], 'param_to_del': []}
    """
    connection_alias_source = ca_group_mapping['gnb_connection_alias_pcell']
    if bts_type == 'cu':
        is_nrrel_id_needed = False
        source_gnb_relation_mapping = cloud_gnb.get_relation_mapping_between_cell_and_others_from_cu(
            connection=connection_alias_source)
    else:
        source_gnb_relation_mapping = coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids(
            connection_alias=connection_alias_source)
    param_update = {'object_to_add': [], 'param_to_add': [],
                    'param_to_upd': [], 'param_to_del': []}
    list_available_nrrel_id = coam_gnb_classical.get_available_nrrel_id_for_addition_operation(
        source_cell_id=ca_group_mapping['pcell_id'], source_gnb_relation_mapping=source_gnb_relation_mapping,
        connection_alias_source=connection_alias_source)
#    param_update_k2_temp = get_nrrel_increasePUSCHPrepTimeULCA(ca_group_mapping=ca_group_mapping)
    nrrel_id_search_index = 0
    for neighbor_cell_info in ca_group_mapping['nrrel_info']:
        connection_alias_neighbor = neighbor_cell_info['gnb_connection_alias']
        if bts_type == 'cu':
            neighbor_gnb_relation_mapping = cloud_gnb.get_relation_mapping_between_cell_and_others_from_cu(
                connection=connection_alias_neighbor)
        else:
            neighbor_gnb_relation_mapping = coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids(
                connection_alias=connection_alias_neighbor)
        nrrel_config = neighbor_cell_info['nrrel_config']
        for neighbor_cell_id in nrrel_config.keys():
            dict_exp_config = nrrel_config[neighbor_cell_id]
            param_update_temp = coam_gnb_classical.get_nrrel_params_for_online_update(
                source_cell_id=ca_group_mapping['pcell_id'], neighbor_cell_id=neighbor_cell_id,
                dict_exp_config=dict_exp_config, source_gnb_relation_mapping=source_gnb_relation_mapping,
                neighbor_gnb_relation_mapping=neighbor_gnb_relation_mapping,
                list_available_nrrel_id=list_available_nrrel_id,
                nrrel_id_search_index=nrrel_id_search_index,
                program=program,
                connection_alias_source=connection_alias_source,
                connection_alias_neighbor=connection_alias_neighbor, is_nrrel_id_needed=is_nrrel_id_needed)
            if param_update_temp['object_to_add']:
                param_update['object_to_add'].extend(
                    param_update_temp['object_to_add'])
                nrrel_id_search_index = nrrel_id_search_index + 1
            if param_update_temp['param_to_add']:
                param_update['param_to_add'].extend(
                    param_update_temp['param_to_add'])
            if param_update_temp['param_to_upd']:
                param_update['param_to_upd'].extend(
                    param_update_temp['param_to_upd'])
            if param_update_temp['param_to_del']:
                param_update['param_to_del'].extend(
                    param_update_temp['param_to_del'])
    return param_update


def get_parameter_list_for_update_for_cells_for_gNB(data_template, list_cell_id, gnb_id='0', value=None, **kwargs):
    """
    Author: Wang Yixiang
    Generate parameter list for SCF or rest api for provided cells. The only thing you will need to do is to
    provide data_template.
    :param data_template:
        String format like bellow:
        SCF_MODIFY_TEMPLATE_BASE_ALL_CELLS = '''
    [
        {{
            "dist_name":"{dist_name}",
            "p_name":"actCDrx",
            "value":"false"
        }}
    ]'''
    :param list_cell_id: e.g: [1,2,3]
    :param value: Use the value defined in data template if not input.
    :return:
        e.g: [{'dist_name': 'MRBTS-10152/NRBTS-10152/NRCELL-1', 'p_name': 'actCDrx', 'value': 'false'},
            {'dist_name': 'MRBTS-10152/NRBTS-10152/NRCELL-2','p_name': 'actCDrx', 'value': 'false'}]
    """
    list_params_cells = []
    list_cell_dn = get_dn_for_cells_for_gnb(
        list_cell_id=list_cell_id, gnb_id=gnb_id)
    for cell_dn in list_cell_dn:
        logging.debug("cell_dn:"+cell_dn)
        param_update_cell = generate_data_based_on_template(data_template=data_template, dist_name=cell_dn,
                                                            value=value, **kwargs)
        list_params_cells = list_params_cells + param_update_cell
    return list_params_cells


def get_parameter_nrrim_for_cells_for_gNB(data_template, list_cell_id, gnb_id='0', value=None, **kwargs):
    """
    Author: Wang Yixiang
    Generate parameter list for SCF or rest api for provided cells. The only thing you will need to do is to
    provide data_template.
    :param data_template:
        String format like bellow:
        SCF_MODIFY_TEMPLATE_BASE_ALL_CELLS = '''
    [
        {{
            "dist_name":"{dist_name}",
            "p_name":"actCDrx",
            "value":"false"
        }}
    ]'''
    :param list_cell_id: e.g: [1,2,3]
    :param value: Use the value defined in data template if not input.
    :return:
    [{'dist_name': 'MRBTS-10152/NRBTS-10152/NRCELL-1/NRRIM_PROFILE-1', 'p_name': 'rsSetId', 'value': '100'},
    {'dist_name': 'MRBTS-10152/NRBTS-10152/NRCELL-2/NRRIM_PROFILE-1','p_name': 'rsSetId', 'value': '10'}]
    """
    list_params_cells = []
    list_nrrim_dn = get_dn_for_nrrim_for_gnb(
        list_cell_id=list_cell_id, gnb_id=gnb_id)
    for nrrim_dn in list_nrrim_dn:
        logging.debug("list_nrrim_dn:"+nrrim_dn)

        param_update_cell = generate_data_based_on_template(data_template=data_template, dist_name=nrrim_dn,
                                                            value=value, **kwargs)
        list_params_cells = list_params_cells + param_update_cell
    list_params_cells = convert_str_original_struct(list_params_cells)
    return list_params_cells


def convert_str_original_struct(list_params):
    """
    Author: Wang Yixiang
    example:elements is string, covert to list
    Input:
    [{'dist_name': 'MRBTS-11478/NRBTS-11478/NRCELL-1/NRRIM_PROFILE-1',
    'list_name': 'startRbForRs',
    'elements': "['30', '126']"}]
    :return:
    [{'dist_name': 'MRBTS-11478/NRBTS-11478/NRCELL-1/NRRIM_PROFILE-1',
    'list_name': 'startRbForRs',
    'elements': ['30', '126']}]
    """
    for i, item in enumerate(list_params):
        if 'elements' in item.keys():
            list_params[i]["elements"] = eval(list_params[i]["elements"])
    return list_params


def get_dn_for_rmods(list_ru_id, gnb_index=0, du_index=0):
    """
    Author: Lingxue Cui
    Generate dist name list for RMODs on gNB or vDU.
    :param list_ru_id: eg, [1, 2, 3]
    :return: E.G: ['MRBTS-37241/EQM-1/APEQM-1/RMOD-1',
                   'MRBTS-37241/EQM-1/APEQM-1/RMOD-2',
                   'MRBTS-37241/EQM-1/APEQM-1/RMOD-3']
    """

    is_cloud = tl_info.has_cloudBts(tl)
    if is_cloud:
        DN_MRBTS = 'MRBTS-' + \
            str(tl.gnbs[int(gnb_index)].dus[int(du_index)].instance_id)
    else:
        DN_MRBTS = 'MRBTS-' + str(tl.gnbs[int(gnb_index)].instance_id)

    list_dn_rmods = []
    for ru_index in list_ru_id:
        rmod_dist_name = DN_MRBTS + '/EQM-1/APEQM-1/RMOD-' + str(ru_index)
        list_dn_rmods.append(rmod_dist_name)
    return list_dn_rmods


def get_dn_for_channel_group_and_channels(lcr_id, number_of_channel_group, number_of_tx_channel=4,
                                          number_of_rx_channel=4, gnb_index=0, du_index=0):
    """
    Author: Lingxue Cui
    Generate dist name list for channel group and channels for specified nrcell.
    :param lcr_id: str, lcrId
    :param number_of_channel_group: int, total number of channel groups under LCELNR.
    :param number_of_tx_channel: int, DL number in nrCellType
    :param number_of_rx_channel: int, UL number in nrCellType
    :return: E.G: ['MRBTS-37241/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1',
                   'MRBTS-37241/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-2']
    """
    is_cloud = tl_info.has_cloudBts(tl)
    if is_cloud:
        DN_MRBTS = 'MRBTS-' + \
            str(tl.gnbs[int(gnb_index)].dus[int(du_index)].instance_id)
    else:
        DN_MRBTS = 'MRBTS-' + str(tl.gnbs[int(gnb_index)].instance_id)

    number_of_channel_group = int(number_of_channel_group)
    number_of_tx_channel = int(number_of_tx_channel)
    number_of_rx_channel = int(number_of_rx_channel)

    list_dn_channel_group = []
    list_dn_channel = []
    for channel_group_index in range(0, number_of_channel_group):
        channel_group_index = channel_group_index + 1
        channel_group_dist_name = DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-' + str(lcr_id)\
            + '/CHANNELGROUP-' + str(channel_group_index)
        list_dn_channel_group.append(channel_group_dist_name)
        for channel_index in range(0, number_of_tx_channel):
            channel_dist_name = channel_group_dist_name + \
                '/CHANNEL-' + str(channel_index+1)
            list_dn_channel.append(channel_dist_name)
        for channel_index in range(0, number_of_rx_channel):
            channel_index = channel_index + number_of_tx_channel
            channel_dist_name = channel_group_dist_name + \
                '/CHANNEL-' + str(channel_index+1)
            list_dn_channel.append(channel_dist_name)
    return list_dn_channel_group, list_dn_channel


def generate_parameters_for_channel_group_and_channels_for_scf_modify(lcr_id, list_ru_id, gnb_index=0, du_index=0,
                                                                      number_of_tx_channel=4, number_of_rx_channel=4,
                                                                      channel_group_starting_index=1):
    """
    Author: Lingxue Cui
    Generate parameters for scf modify for channel group and channels for specified nrcell.
    To add channel group and channels, MO MRBTS/MNL/MNLENT/CELLMAPPING/LCELNR need to be removed firstly.
    :param lcr_id: str or int, lcrId
    :param list_ru_id: list, eg. [1, 2, 3]
    :param number_of_tx_channel: int, DL number in nrCellType
    :param number_of_rx_channel: int, UL number in nrCellType
    :return: E.G: [{'dist_name': 'MRBTS-None/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1',
                    'p_name': 'antlDN', 'value': 'MRBTS-37241/EQM-1/APEQM-1/RMOD-1/ANTL-1'},
                    {'dist_name': 'MRBTS-None/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1',
                    'p_name': 'direction', 'value': 'TX'}],
                    [{'dist_name': 'MRBTS-None/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1',
                    'p_name': 'antlDN', 'value': 'MRBTS-37241/EQM-1/APEQM-1/RMOD-1/ANTL-1'},
                    {'dist_name': 'MRBTS-None/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1',
                    'p_name': 'direction', 'value': 'RX'}]
    """
    is_cloud = tl_info.has_cloudBts(tl)
    if is_cloud:
        DN_MRBTS = 'MRBTS-' + \
            str(tl.gnbs[int(gnb_index)].dus[int(du_index)].instance_id)
        version = 'MNLVDU24R3_2410_100'
    else:
        DN_MRBTS = 'MRBTS-' + str(tl.gnbs[int(gnb_index)].instance_id)
        version = 'MNL24R3_2410_100'

    number_of_tx_channel = int(number_of_tx_channel)
    number_of_rx_channel = int(number_of_rx_channel)

    list_dn_rmods = get_dn_for_rmods(list_ru_id=list_ru_id)
    list_mo_lcelnr = [
        dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-' + str(lcr_id),
             version=version, class_name="com.nokia.srbts.mnl:LCELNR"),
        dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-' + str(lcr_id),
             p_name='actSimplChConfMAA', value='false')
    ]
    if not is_cloud:
        list_mo_lcelnr = list_mo_lcelnr + [
            dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-' + str(lcr_id),
                 p_name='actAsiDistMimoNr', value='false')
        ]
    parameter_update_list = list_mo_lcelnr
    for index, rmod_dn in enumerate(list_dn_rmods):
        channel_group_index = index + channel_group_starting_index
        channel_group_dn = DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-' + str(lcr_id) + '/CHANNELGROUP-' \
            + str(channel_group_index)

        list_mo_channel_group = [
            dict(dist_name=channel_group_dn, version=version,
                 class_name="com.nokia.srbts.mnl:CHANNELGROUP")
        ]
        parameter_update_list = parameter_update_list + list_mo_channel_group
        for tx_index in range(0, number_of_tx_channel):
            channel_dn = channel_group_dn + '/CHANNEL-' + str(tx_index + 1)
            ant_dn = rmod_dn + '/ANTL-' + str(tx_index + 1)
            list_mo_channel = [
                dict(dist_name=channel_dn, version=version,
                     class_name="com.nokia.srbts.mnl:CHANNEL")
            ]
            parameter_update_channel_tx = [
                dict(dist_name=channel_dn, p_name='antlDN', value=ant_dn),
                dict(dist_name=channel_dn, p_name='direction', value='TX'),
            ]
            parameter_update_list = parameter_update_list + \
                list_mo_channel + parameter_update_channel_tx

        for rx_index in range(0, number_of_rx_channel):
            channel_dn = channel_group_dn + '/CHANNEL-' + \
                str(rx_index + number_of_tx_channel + 1)
            ant_dn = rmod_dn + '/ANTL-' + str(rx_index + 1)
            list_mo_channel = [
                dict(dist_name=channel_dn, version=version,
                     class_name="com.nokia.srbts.mnl:CHANNEL")
            ]
            parameter_update_channel_rx = [
                dict(dist_name=channel_dn, p_name='antlDN', value=ant_dn),
                dict(dist_name=channel_dn, p_name='direction', value='RX'),
            ]
            parameter_update_list = parameter_update_list + \
                list_mo_channel + parameter_update_channel_rx

    return parameter_update_list
