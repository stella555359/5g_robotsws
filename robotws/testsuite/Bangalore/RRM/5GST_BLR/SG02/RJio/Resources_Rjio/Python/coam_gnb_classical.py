# -*- coding: utf-8 -*-
"""
Author:         Ding Binmei
Contact Mail:   binmei.ding@nokia-sbell.com
Description:    Functions based on coam.admin lib

"""
from taf.sbts.oam.coam.admin import admin
from taf.config.testline.info.testline_info import TestlineInfo
# import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.bts.vran40.cloud_gnb as cloud_gnb
import logging
import re
from robot.libraries.BuiltIn import BuiltIn

coam = admin()


def is_bts_cloud():
    """
    Judge if bts is cloud or classical
    :return: True/False
    """
    tl = BuiltIn().get_variable_value("${tl}")
    testline_info = TestlineInfo()
    return testline_info.has_cloudBts(tl)


def get_relation_mapping_between_cell_index_and_other_ids(connection_alias='GNB_OAM'):
    """
    Author: Ding Binmei
    Description: Get relation mapping between cell_index, cell_group,  nrCellIdentity.
    nrCellIdentity: Can be used for filtering cell related throughput
    All returned IDs will be in int format
    Extend detail_cells_info
    :param connection_alias:
    :return: A dictionary with cell_index as key and other ids as value:
    Example output: {cell_index1:
                         {cell_group_id:'0', nrCellIdentity: nrCellIdentity1, physicalCellId: physicalCellId1,
                         detail_cells_info:{XXXX}
                         },
                    cell_index2:
                         {cell_group_id:'0', nrCellIdentity: nrCellIdentity2, physicalCellId: physicalCellId2}}
    Actual output from cluster: {1: {b'cell_group_id': 0, b'nrCellIdentity': 16385, b'physicalCellId': 71},
                                2: {b'cell_group_id': 0, b'nrCellIdentity': 16386, b'physicalCellId': 72}}
    """
    subcells_info = coam.get_subcells_info(connection=connection_alias)
    # logging.debug("subcells_info: {}".format(subcells_info))

    dict_cells_info = get_relation_mapping_between_cell_index_and_cell_info(
        connection_alias=connection_alias
    )
    relation_mapping = {}

    dict_ru_sn_match_ru_index_init = get_ru_sn_match_with_ru_index_from_init_file(
        connection_alias=connection_alias
    )
    dict_rmod_index_match_rmod_sn_from_gnb = get_rmod_index_match_rmod_sn_from_gnb_conf(
        connection_alias=connection_alias
    )
    dict_rmod_bbmod_mapping_from_gnb = get_rmod_bbmod_mapping_from_gnb_conf(
        connection_alias=connection_alias
    )

    for cell_group_name in subcells_info.keys():
        cells_info = subcells_info[cell_group_name]
        list_cells_name = cells_info.keys()
        cell_group_id = int(cell_group_name.split("-")[-1])
        for cell_name in list_cells_name:
            cell_related_ids = {}
            if not cells_info[cell_name]:
                print("No cells info found for {}, skip".format(cell_name))
                continue
            else:
                cell_index = int(cell_name.split("-")[-1].strip())
                nrCellIdentity = cells_info[cell_name]["NRCELL_L"]["parameters"]["nrCellIdentity"]
                lcrId = cells_info[cell_name]["NRCELL_L"]["parameters"]["lcrId"]
                physicalCellId = dict_cells_info[cell_index]["physicalCellId"]

                ru_index_in_init = None
                try:
                    # rmod index used to get combined bbmod and rmod sn , rmod sn math to init file to get ru index
                    rmod_index_for_cell_from_gnb = _get_rmod_index_for_specific_cell(
                        detail_cells_info=dict_cells_info[cell_index]
                    )
                    # dict{rmod_index:serial_number} use rmod_index to get rmod sn
                    rmod_sn_for_cell_from_gnb = dict_rmod_index_match_rmod_sn_from_gnb[
                        str(rmod_index_for_cell_from_gnb)
                    ]
                    # dict{ru_sn:rmod_index}  use ru_sn to get rmon index with init file, which combined with PA port
                    ru_index_in_init = dict_ru_sn_match_ru_index_init[str(rmod_sn_for_cell_from_gnb)]
                except Exception as error:
                    if (ru_index_in_init is None and rmod_index_for_cell_from_gnb is not None):
                        ru_index_in_init = int(rmod_index_for_cell_from_gnb) - 1
                    logging.debug("Maybe RU just in SCF, not found with init get fail Exception {} ".format(error))

                bbmod_index = None
                try:
                    # rmod index used to get combined bbmod and rmod sn , rmod sn math to init file to get ru index
                    rmod_index_for_cell_from_gnb = _get_rmod_index_for_specific_cell(
                        detail_cells_info=dict_cells_info[cell_index])
                    # dict{RMOD_R - 2: BBMOD_R - 2} use rmod index to get BB mod index
                    bbmod_index = dict_rmod_bbmod_mapping_from_gnb[str(rmod_index_for_cell_from_gnb)]
                except Exception as error:
                    logging.debug("Maybe BB combined with Rmod meet error {} ".format(error))

                cell_related_ids["cell_group_id"] = cell_group_id
                cell_related_ids["nrCellIdentity"] = nrCellIdentity
                cell_related_ids["lcrId"] = lcrId
                cell_related_ids["physicalCellId"] = physicalCellId
                cell_related_ids["detail_cells_info"] = dict_cells_info[cell_index]
                cell_related_ids["ruIndex_in_init"] = ru_index_in_init
                cell_related_ids["bbMod_index"] = bbmod_index
                relation_mapping[cell_index] = cell_related_ids
                logging.info("cell_index: {}, cell_group_id: {}, nrCellIdentity:{}, physicalCellId:{}".format(
                    cell_index, cell_group_id, nrCellIdentity, physicalCellId))
    return relation_mapping


def _get_rmod_index_for_specific_cell(detail_cells_info):
    """
    Author: Dandan Fang
    Description: Get relation mapping between cell_index, rmod_index.
    Decode RMOD infor from sub_cell_info carrierList': [{'antennaLineId': {'configuration': 'MRBTS-255/EQM-1/
    APEQM-1/RMOD-1/PHYANT-1',
    return: rmod_index , 1 or 2
    """
    rmod_index = None
    try:
        rmod = detail_cells_info["carrierList"][0]["antennaLineId"]["configuration"]
        rmod_index = re.match(r".*RMOD-(\d+)", rmod).group(1)
    except Exception as error:
        logging.debug("cell {} 's rmod_index can not get fail Exception {} ".
                      format(detail_cells_info["physicalCellId"], error))
    return rmod_index


def get_rmod_index_match_rmod_sn_from_gnb_conf(connection_alias="GNB_OAM"):
    """
        Author: Dandan Fang
        Description: Get relation mapping between rmod_sn, rmod_index.
        Decode rmod_sn info with following cell info:
    "antenaUsageInfo": [], "productName": "AEHC", "productCode": "475124B.M01", "serialNumber": "L1204708776"},
    {"ports":
    [
    {"id": {"internal": "/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-2/ANTL_R-1",
            "configuration": "MRBTS-255/EQM-1/APEQM-1/RMOD-2/ANTL-1",
            "runtime": "MRBTS-255/EQM_R-1/APEQM_R-1/RMOD_R-2/ANTL_R-1"}, "label": "ANT1"},
    {"id": {"internal": "/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-2/ANTL_R-2",
            "configuration": "MRBTS-255/EQM-1/APEQM-1/RMOD-2/ANTL-2",
            "runtime": "MRBTS-255/EQM_R-1/APEQM_R-1/RMOD_R-2/ANTL_R-2"}, "label": "ANT2"}
            ....]
        :return: {'3': 'BL2220N403U', '4': 'EB2232R0674', '5': 'BL2145G1QC4',......}
        dict{rmod_index:serial_number}
    """
    frm_mapping = coam.get_frm(connection=connection_alias)
    rmod_sn_mapping = {}
    for element in frm_mapping:
        try:
            rmod = element["id"]["configuration"]
            rmod_index = re.match(r".*RMOD-(\d+)", rmod).group(1)
            serial_number = element["serialNumber"]
            rmod_sn_mapping[rmod_index] = serial_number
        except Exception as error:
            logging.debug("frm element {} get Exception {} ".format(element, error))
            continue
    return rmod_sn_mapping


def get_ru_sn_match_with_ru_index_from_init_file(connection_alias="GNB_OAM"):
    """
    Author: Dandan Fang
    Description: Get relation mapping between rmod_sn, rmod_index from testline init.py file.
    :return:  dict{ru_sn:rmod_index}   {'L1204708776': 0, 'BL2034G1HI5': 1}
    """
    tl = BuiltIn().get_variable_value("${tl}")
    bts_info = coam.get_bts_info(connection=connection_alias)
    gnb_index = 0  # default value defined.
    for gnb in tl.gnbs:
        if gnb.global_bts_id == bts_info["nrBtsId"]:
            gnb_index = tl.gnbs.index(gnb)

    ru_sn_match_with_ru_index_from_init = {}
    try:
        ru_list_from_init_file = tl.gnbs[gnb_index].dus[0].rus
    except Exception as error:
        logging.debug("ru_list_from_init_file get meet exception {} ".format(error))
        return None

    for element in ru_list_from_init_file:
        try:
            ru_index = ru_list_from_init_file.index(element)
            ru_sn = tl.gnbs[gnb_index].dus[0].rus[ru_index].serial_number
            ru_sn_match_with_ru_index_from_init[ru_sn] = ru_index
        except Exception as error:
            logging.debug("ru_sn{} get meet exception {} ".format(ru_sn, error))
            continue
    return ru_sn_match_with_ru_index_from_init


def get_rmod_bbmod_mapping_from_gnb_conf(connection_alias="GNB_OAM"):
    """
    Author: Dandan Fang
    :param connection_alias: default value as GNB_OAM
    :return:
    Info got form gNB COnfiguration, example as following:
    "firstEndPointId": {"internal": "/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/
    CABINET_R-1/BBMOD_R-2/RF1"
    "secondEndPointId": {"internal": "/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/
     RMOD_R-2/OPT_IF1"
     :return:  dict{RMOD_R-2:BBMOD_R-2} -->  {'2': '2', '1': '1'}
    """
    rmod_mapping = coam.get_detected_hw_info(connection=connection_alias)
    rmod_bbmod_mapping = {}
    for cable in rmod_mapping["cables"]:
        try:
            bbmod_port_id = cable["firstEndPointId"]["configuration"]
            rmod_port_id = cable["secondEndPointId"]["configuration"]
            if "BBMOD" in bbmod_port_id and "RMOD" in rmod_port_id:
                rmod_index = re.match(r".*RMOD-(\d+).*", rmod_port_id).group(1)
                bbmod_index = bbmod_port_id.split("/")[-2].split("-")[-1]
                bbmod_rf_mapping = bbmod_index
                rmod_bbmod_mapping[rmod_index] = bbmod_rf_mapping
            else:
                logging.debug(
                    "*** not valid info: bbmod:{},rmod:{}, skip ***".format(bbmod_port_id, rmod_port_id))
        except Exception as error:
            logging.debug("cable{} get bbmod or rmod meet exception {},Skip*** ".format(cable, error))
            continue
    return rmod_bbmod_mapping


def get_relation_mapping_between_cell_index_and_cell_info(connection_alias="GNB_OAM"):
    """
    Author: Ding Binmei
    Description: Get cell info between cell index and detail cell info
    :param connection_alias:
    :return: A dictionary with cell_index as key and detail cell_info as value
    Example output:{cell_index:{dict_detail_info}}
    {1: {'band': 'n260', 'carrierList': XX, 'physicalCellId': 71, 'status': XX}}
    """
    list_cells_info = coam.get_cells_info(connection=connection_alias)
    logging.debug("cells_info: {}".format(list_cells_info))
    cell_index_info_mapping = {}
    for cell_info in list_cells_info:
        cell_index = cell_info["globalCellId"]
        cell_index_info_mapping[cell_index] = cell_info
    return cell_index_info_mapping


def get_relation_mapping_between_cell_index_and_nrCellIdentity(connection_alias='GNB_OAM'):
    """
    Author: Liu Zheng
    Support for 19A, 19B and trunk
    Description: Get relation mapping between cell_index, cell_group,  nrCellIdentity.
    nrCellIdentity: Can be used for filtering cell related throughput and check the X2 status from enb to gnb.
    All returned IDs will be in int format
    :param connection_alias:
    :return: A dictionary with cell_index as key and other ids as value:
    Example output: {cell_index1:
                         {cell_group_id:'0', nrCellIdentity: nrCellIdentity1},
                    cell_index2:
                         {cell_group_id:'0', nrCellIdentity: nrCellIdentity2}}
    Actual output from cluster: {1: {b'cell_group_id': 0, b'nrCellIdentity': 16385},
                                2: {b'cell_group_id': 0, b'nrCellIdentity': 16386}}
    """
    subcells_info = coam.get_subcells_info(connection=connection_alias)
    logging.debug("subcells_info: {}".format(subcells_info))
    relation_mapping = {}
    for cell_group_name in subcells_info.keys():
        cells_info = subcells_info[cell_group_name]
        list_cells_name = cells_info.keys()
        cell_group_id = int(cell_group_name.split('-')[-1])
        for cell_name in list_cells_name:
            cell_related_ids = {}
            if not cells_info[cell_name]:
                print("No cells info found for {}, skip".format(cell_name))
                continue
            else:
                cell_index = int(cell_name.split("-")[-1].strip())
                nrCellIdentity = cells_info[cell_name]['NRCELL_L']['parameters']['nrCellIdentity']
                cell_related_ids['cell_group_id'] = cell_group_id
                cell_related_ids['nrCellIdentity'] = nrCellIdentity
                relation_mapping[cell_index] = cell_related_ids
                logging.debug("cell_index: {}, cell_group_id: {}, nrCellIdentity:{}".format(
                    cell_index, cell_group_id, nrCellIdentity))
    return relation_mapping


def get_cell_ids_based_on_cell_technology(connection_alias='GNB_OAM'):
    """
    Author: Ding Binmei
    list all cell ids for cell technology with TDD or FDD
    :param connection_alias:
    :return:  Example output: {'TDD': [1], 'FDD': [2, 3, 4]}
    """
    dict_cell_ids_tech = {"TDD": [], "FDD": []}
    dict_cells_info = get_relation_mapping_between_cell_index_and_cell_info(connection_alias=connection_alias)
    for cell_index in sorted(dict_cells_info.keys()):
        cell_tech = dict_cells_info[cell_index]["technology"]
        logging.debug("cell_index:{}, cell_tech:{}".format(cell_index, cell_tech))
        if cell_tech.upper() == "FDD":
            dict_cell_ids_tech["FDD"].append(cell_index)
        elif cell_tech.upper() == "TDD":
            dict_cell_ids_tech["TDD"].append(cell_index)
        else:
            raise Exception("Only TDD and FDD are supported. {} is not supported".format(cell_tech))
    return dict_cell_ids_tech


def get_parameters_under_nrbts_mo(connection_alias='GNB_OAM'):
    """
    Author: Ding Binmei
    Get parameters under NRBTS MO
    :param connection_alias:
    :return: return dict values as bellow
            {'mcsDeactSCellDl': None,
             'mcsDeactSCellUl': None,
             'minSourceUdpPort': None,
             'mnc': 260,
             'mncLength': 3
             ...
             }
    """
    is_cloud = is_bts_cloud()
    if is_cloud:
        dict_params = cloud_gnb.get_parameters_under_nrbts_mo_from_cu(cu_connection=connection_alias)
    else:
        mo_nrbts = coam.get_managed_objects(class_name="NRBTS_A", connection=connection_alias)
        dict_params = coam.get_parameters(dist_name=mo_nrbts[0]['distName'], connection=connection_alias)
    return dict_params


def get_nrrel_from_gnb(connection_alias='GNB_OAM'):
    """
    Author: Ding Binmei
    :param connection_alias:
    :return:
    Return data as bellow:
    [{'distName': '/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-7/SCF-1/MRBTS_A-413/NRBTS_A-11171/NRCELL_A-1/NRREL_A-1',
  'nrrel_id': '1',
  'parameters': {'cellIndividualSsbRsrpOffset': '0dB',
                 'cellIndividualSsbRsrqOffset': '0dB',
                 'gNbId': 11171,
                 'gNbIdLength': 32,
                 'gnbPlmn': {'mcc': 310, 'mnc': 260, 'mncLength': 3},
                 'handoverAllowedSA': 'allowed',
                 'lcrId': 4,
                 'nrDcAllowed': False,
                 'removeNotAllowed': False,
                 'sCellAdditionMethod': None,
                 'sCellOperationalMode': None,
                 ...},
  'short_distName': 'MRBTS-413/NRBTS-11171/NRCELL-1/NRREL-1'},...]

    """
    list_nrrel_mo = coam.get_managed_objects(class_name="NRREL_A", connection=connection_alias)
    list_nrrel_mo_update = []
    for nrrel_mo in list_nrrel_mo:
        dist_name = nrrel_mo["distName"]
        dn_nrrel = "MRBTS_A" + dist_name.split("MRBTS_A")[-1]
        dn_nrrel = dn_nrrel.replace("_A", "")
        nrrel_mo["short_distName"] = dn_nrrel
        nrrel_mo["nrrel_id"] = dn_nrrel.split("NRREL-")[-1]
        list_nrrel_mo_update.append(nrrel_mo)
    return list_nrrel_mo_update


def get_relation_mapping_for_nrrel_operations(source_gnb_relation_mapping=None,
                                              neighbor_gnb_relation_mapping=None,
                                              connection_alias_source='GNB_OAM',
                                              connection_alias_neighbor='GNB_OAM'):
    """
    Author: Ding Binmei
    For reduce research for cell relation mapping purpose. Only search if relation_mapping is None.
    If already provided, then using the existing relation mapping
    :param source_gnb_relation_mapping:
    :param neighbor_gnb_relation_mapping:
    :param connection_alias_source:
    :param connection_alias_neighbor:
    :return:
    """
    is_cloud = is_bts_cloud()
    if source_gnb_relation_mapping is None:
        if is_cloud is True:
            source_gnb_relation_mapping = cloud_gnb.get_relation_mapping_between_cell_and_others_from_cu(
                connection=connection_alias_source)
        else:
            source_gnb_relation_mapping = get_relation_mapping_between_cell_index_and_other_ids(
                connection_alias=connection_alias_source)
    if neighbor_gnb_relation_mapping is None:
        if connection_alias_source != connection_alias_neighbor:
            if is_cloud is True:
                neighbor_gnb_relation_mapping = cloud_gnb.get_relation_mapping_between_cell_and_others_from_cu(
                    connection=connection_alias_neighbor)
            else:
                neighbor_gnb_relation_mapping = get_relation_mapping_between_cell_index_and_other_ids(
                    connection_alias=connection_alias_neighbor)
        else:
            neighbor_gnb_relation_mapping = source_gnb_relation_mapping
            logging.info("neighbor_gnb_relation_mapping is same with source_gnb_relation_mapping")
    return source_gnb_relation_mapping, neighbor_gnb_relation_mapping


def get_nrrel_based_on_cell_id(source_cell_id,
                               neighbor_cell_id,
                               source_gnb_relation_mapping=None,
                               neighbor_gnb_relation_mapping=None,
                               connection_alias_source='GNB_OAM',
                               connection_alias_neighbor='GNB_OAM'
                               ):
    """
    Ding Binmei: Get NRREL based on provided source and neighbor cell id
    :param source_cell_id:
    :param neighbor_cell_id:
    :param source_gnb_relation_mapping:
    :param neighbor_gnb_relation_mapping:
    :param connection_alias_source:
    :param connection_alias_neighbor: Can be same with source connection
    :return: a dict as bellow:
    {'distName': '/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-5/SCF-1/MRBTS_A-413/NRBTS_A-11171/NRCELL_A-1/NRREL_A-2',
    'nrrel_id': '2',
     'parameters': {'cellIndividualSsbRsrpOffset': '0dB',
                    'cellIndividualSsbRsrqOffset': '0dB',
                    'gNbId': 11172,
                    'gNbIdLength': 32,
                    'gnbPlmn': {'mcc': 310, 'mnc': 260, 'mncLength': 3},
                    'handoverAllowedSA': 'allowed',
                    'lcrId': 4,
                    'nrDcAllowed': False,
                    'removeNotAllowed': False,
                    'sCellAdditionMethod': None,
                    'sCellOperationalMode': None,
                    'sCellPrio': None,
                    'tmpParam1': None,
                    ...},
     'short_distName': 'MRBTS-413/NRBTS-11171/NRCELL-1/NRREL-2'}
    """
    source_cell_id = int(source_cell_id)
    neighbor_cell_id = int(neighbor_cell_id)
    is_cloud = is_bts_cloud()
    source_gnb_relation_mapping, neighbor_gnb_relation_mapping = get_relation_mapping_for_nrrel_operations(
        source_gnb_relation_mapping=source_gnb_relation_mapping,
        neighbor_gnb_relation_mapping=neighbor_gnb_relation_mapping,
        connection_alias_source=connection_alias_source,
        connection_alias_neighbor=connection_alias_neighbor)
    if is_cloud:
        source_dn_cell = source_gnb_relation_mapping[source_cell_id]['detail_cells_info']['dist_names']['config']
        neighbor_dn_cell = neighbor_gnb_relation_mapping[neighbor_cell_id]['detail_cells_info']['dist_names'][
            'config']
        list_all_nrrel_mo = cloud_gnb.get_nrrel_on_cu(cu_connection=connection_alias_source)
    else:
        source_dn_cell = source_gnb_relation_mapping[source_cell_id]['detail_cells_info']['id']['configuration']
        neighbor_dn_cell = neighbor_gnb_relation_mapping[neighbor_cell_id]['detail_cells_info']['id'][
            'configuration']
        list_all_nrrel_mo = get_nrrel_from_gnb(connection_alias=connection_alias_source)
    neighbor_cell_lcrid = neighbor_gnb_relation_mapping[neighbor_cell_id]['lcrId']
    neighbor_nr_gNbId = int(neighbor_dn_cell.split('NRBTS-')[-1].split('/')[0])
    nrrel_filter_by_cell = None
    for nrrel_mo in list_all_nrrel_mo:
        dn_nrrel = nrrel_mo["short_distName"]
        is_source_dn_cell_equal = True if source_dn_cell == dn_nrrel.split('/NRREL')[0] else False
        is_lcrId_equal = True if str(neighbor_cell_lcrid) == str(nrrel_mo['parameters']['lcrId']) else False
        is_gnbId_equal = True if str(neighbor_nr_gNbId) == str(nrrel_mo['parameters']['gNbId']) else False
        logging.debug("get_nrrel_based_on_cell_id: Check if NRREL exist. is_source_dn_cell_equal:{}, "
                      "is_lcrId_equal:{}, is_gnbId_equal:{}".format(is_source_dn_cell_equal,
                                                                    is_lcrId_equal, is_gnbId_equal))
        if is_source_dn_cell_equal and is_lcrId_equal and is_gnbId_equal:
            nrrel_filter_by_cell = nrrel_mo
            logging.info("get_nrrel_based_on_cell_id: NRREL relation already exist.")
            break
    if nrrel_filter_by_cell is None:
        logging.info("get_nrrel_based_on_cell_id: NRREL relation does not exist")
    return nrrel_filter_by_cell


def get_nrrel_under_specific_cell(source_cell_id,
                                  source_gnb_relation_mapping=None, connection_alias_source='GNB_OAM',
                                  is_to_skip_sCellAdditionMethod_none_rel=False
                                  ):
    """
    Author: Ding Binmei
    Get nrrel info on specific cell id.
    :param source_cell_id:
    :param source_gnb_relation_mapping: If None, then will get real time mapping based on the provided connection
    :param connection_alias_source:
    :param is_to_skip_sCellAdditionMethod_none_rel: True/False.
        If set to true, then NRREL with sCellAdditionMethod value None will not be filtered out
    :return:
    E.G {'nrrel_ids': [1,2,...], 'nrrel_mo_info': [{},{}...]}
    """
    source_cell_id = int(source_cell_id)
    if source_gnb_relation_mapping is None:
        source_gnb_relation_mapping = get_relation_mapping_between_cell_index_and_other_ids(
            connection_alias=connection_alias_source)
    is_cloud = is_bts_cloud()
    if is_cloud:
        source_dn_cell = source_gnb_relation_mapping[source_cell_id]['detail_cells_info']['dist_names']['config']
        list_all_nrrel_mo = cloud_gnb.get_nrrel_on_cu(cu_connection=connection_alias_source)
    else:
        source_dn_cell = source_gnb_relation_mapping[source_cell_id]['detail_cells_info']['id']['configuration']
        list_all_nrrel_mo = get_nrrel_from_gnb(connection_alias=connection_alias_source)
    dict_nrrel_for_specific_cell = {'nrrel_ids': [], 'nrrel_mo_info': []}
    for nrrel_mo in list_all_nrrel_mo:
        dn_nrrel = nrrel_mo["short_distName"]
        nrrel_id = int(dn_nrrel.split('/NRREL-')[-1])
        try:
            sCellAdditionMethod = nrrel_mo["parameters"]["sCellAdditionMethod"]
        except KeyError:
            sCellAdditionMethod = None
        if source_dn_cell == dn_nrrel.split('/NRREL')[0]:
            if is_to_skip_sCellAdditionMethod_none_rel is True and sCellAdditionMethod is None:
                continue
            else:
                dict_nrrel_for_specific_cell['nrrel_ids'].append(nrrel_id)
                dict_nrrel_for_specific_cell['nrrel_mo_info'].append(nrrel_mo)
    return dict_nrrel_for_specific_cell


def get_available_nrrel_id_for_addition_operation(source_cell_id,
                                                  source_gnb_relation_mapping=None,
                                                  connection_alias_source='GNB_OAM'):
    """
    Ding Binmei:
    Get available nrrel id on specific cell id. It will be used for nrrel addition
    :param source_cell_id:
    :param source_gnb_relation_mapping: If None, then will get real time mapping based on the provided connection
    :param connection_alias_source:
    :return: list of all available values
    """
    dict_nrrel_for_specific_cell = get_nrrel_under_specific_cell(
        source_cell_id=source_cell_id, source_gnb_relation_mapping=source_gnb_relation_mapping,
        connection_alias_source=connection_alias_source
    )
    list_nrrel_id = dict_nrrel_for_specific_cell['nrrel_ids']
    list_all_supported_nrrel_id = list(range(1, 256))
    if list_nrrel_id:
        list_nrrel_id.sort()
        list_available_nrrel_id = list(set(list_all_supported_nrrel_id) - set(list_nrrel_id))
    else:
        list_available_nrrel_id = list_all_supported_nrrel_id
    return list_available_nrrel_id


def get_nrrel_add_param_for_online_update(source_cell_id, neighbor_cell_id, source_gnb_relation_mapping=None,
                                          neighbor_gnb_relation_mapping=None, connection_alias_source="GNB_OAM",
                                          connection_alias_neighbor="GNB_OAM", scell_addition_method="blind",
                                          scell_operational_mode="dlAndUl", scell_priority=None,
                                          list_available_nrrel_id=None, nrrel_id_search_index=0, program='master'):
    """
    Author: Ding Binmei
    Generate NRREL MO for online addition.
    :param source_cell_id:
    :param neighbor_cell_id:
    :param source_gnb_relation_mapping:
    :param neighbor_gnb_relation_mapping:
    :param connection_alias_source:
    :param connection_alias_neighbor:
    :param scell_addition_method: None, blind, covBasedA1
        If set to None, then it won't be added
    :param scell_operational_mode: None, dlOnly, dlAndUl
        If set to None, then it won't be added
    :param scell_priority: None, 1, 2
        If set to None, then it won't be added
    :param list_available_nrrel_id: If set to None, then it will get available nrrel id based on current GNB settings
    :param nrrel_id_search_index: Default to 0. Get from the available index list.
     (If you have multiple addition records, then you can control the nrrel id via this parameter)
    :param program: Extend as some mandatory parameters will be introduced in latest release,
     so use program to match params in each release. the default behavior will be the same
     with it is on trunk.
     field value can get from keyword gnb_classical_hangzhou.Get program version based on stream version
     Program value can be: '22R4', '23R1', 'master',...,
    :return: E.G. The returned value can be used for online addition directly
        [
        {'dist_name': 'MRBTS-413/NRBTS-11171/NRCELL-1/NRREL-3',
         'parameter': 'gNbId', 'value': '11171'},
        {'dist_name': 'MRBTS-413/NRBTS-11171/NRCELL-1/NRREL-3',
         'parameter': 'lcrId', 'value': '4'},
        ...
        ]
    """
    nrrel_id_search_index = int(nrrel_id_search_index)
    source_gnb_relation_mapping, neighbor_gnb_relation_mapping = \
        get_relation_mapping_for_nrrel_operations(
            source_gnb_relation_mapping=source_gnb_relation_mapping,
            neighbor_gnb_relation_mapping=neighbor_gnb_relation_mapping,
            connection_alias_source=connection_alias_source,
            connection_alias_neighbor=connection_alias_neighbor)
    source_cell_id = int(source_cell_id)
    neighbor_cell_id = int(neighbor_cell_id)
    is_cloud = is_bts_cloud()
    if is_cloud:
        source_dn_cell = source_gnb_relation_mapping[source_cell_id]['detail_cells_info']['dist_names']['config']
        neighbor_dn_cell = neighbor_gnb_relation_mapping[neighbor_cell_id][
            'detail_cells_info']['dist_names']['config']
    else:
        source_dn_cell = source_gnb_relation_mapping[source_cell_id]['detail_cells_info']['id']['configuration']
        neighbor_dn_cell = neighbor_gnb_relation_mapping[neighbor_cell_id]['detail_cells_info']['id']['configuration']
    if list_available_nrrel_id is None:
        list_available_nrrel_id = get_available_nrrel_id_for_addition_operation(
            source_cell_id=source_cell_id, source_gnb_relation_mapping=source_gnb_relation_mapping,
            connection_alias_source=connection_alias_source)
    nr_rel_id = list_available_nrrel_id[nrrel_id_search_index]
    dist_name_nrrel = source_dn_cell + '/NRREL-' + str(nr_rel_id)
    neighbor_lcrid = neighbor_gnb_relation_mapping[neighbor_cell_id]['lcrId']
    neighbor_bts_params = get_parameters_under_nrbts_mo(
        connection_alias=connection_alias_neighbor)
    logging.debug("source_dn_cell:{}, neighbor_dn_cell:{}".format(source_dn_cell, neighbor_dn_cell))
    neighbor_nr_gNbId = int(neighbor_dn_cell.split('NRBTS-')[-1].split('/')[0])
    neighbor_gNbIdLength = neighbor_bts_params['gNbIdLength']
    neighbor_mcc = neighbor_bts_params['mcc']
    neighbor_mnc = neighbor_bts_params['mnc']
    neighbor_mncLength = neighbor_bts_params['mncLength']

    param_to_add_nrrel = [
        {'dist_name': dist_name_nrrel, 'parameter': 'cellIndividualSsbRsrpOffset', 'value': '0dB'},
        {'dist_name': dist_name_nrrel, 'parameter': 'cellIndividualSsbRsrqOffset', 'value': '0dB'},
        {'dist_name': dist_name_nrrel, 'parameter': 'gNbId', 'value': str(neighbor_nr_gNbId)},
        {'dist_name': dist_name_nrrel, 'parameter': 'gNbIdLength', 'value': str(neighbor_gNbIdLength)},
        {'dist_name': dist_name_nrrel, 'parameter': 'lcrId', 'value': str(neighbor_lcrid)},
        {'dist_name': dist_name_nrrel, 'parameter': 'removeNotAllowed', 'value': 'false'},
        {'dist_name': dist_name_nrrel, 'parameter': 'nrRelId', 'value': str(nr_rel_id)},
        {'dist_name': dist_name_nrrel, 'parameter': 'gnbPlmn',
         'value': [{'mcc': neighbor_mcc, 'mnc': neighbor_mnc, 'mncLength': neighbor_mncLength}]},
        {'dist_name': dist_name_nrrel, 'parameter': 'handoverAllowedSA', 'value': 'allowed'}
    ]
    if is_cloud is False:
        param_to_add_nrrel = param_to_add_nrrel + \
                             [{'dist_name': dist_name_nrrel, 'parameter': 'nrDcAllowed', 'value': 'false'}]
    if program not in ['22R4', '23R1']:
        param_to_add_nrrel = \
            param_to_add_nrrel + \
            [{'dist_name': dist_name_nrrel, 'parameter': 'handoverAllowedSARedCap', 'value': 'forbidden'}]
    if program not in ['22R4', '23R1', '23R2']:
        param_to_add_nrrel = \
            param_to_add_nrrel + \
            [{'dist_name': dist_name_nrrel, 'parameter': 'isRplCellForPSCell', 'value': 'false'}]
    else:
        param_to_add_nrrel = param_to_add_nrrel
    if scell_addition_method is not None:
        add_scell_addition_method_param = {
            'dist_name': dist_name_nrrel, 'parameter': 'sCellAdditionMethod', 'value': scell_addition_method}
        param_to_add_nrrel.append(add_scell_addition_method_param)
    if scell_operational_mode is not None and program not in ['22R4', '23R1']:
        add_scell_operational_mode_param = {
            'dist_name': dist_name_nrrel, 'parameter': 'sCellOperationalMode', 'value': scell_operational_mode}
        param_to_add_nrrel.append(add_scell_operational_mode_param)
    if scell_priority is not None:
        add_scell_priority_param = {
            'dist_name': dist_name_nrrel, 'parameter': 'sCellPrio', 'value': scell_priority}
        param_to_add_nrrel.append(add_scell_priority_param)
    return param_to_add_nrrel


def get_remove_nrrel_mo_for_online_update(source_cell_id, neighbor_cell_id,
                                          source_gnb_relation_mapping=None,
                                          neighbor_gnb_relation_mapping=None,
                                          connection_alias_source="GNB_OAM", connection_alias_neighbor="GNB_OAM"):
    """
    Author: Ding Binmei
    Get nrrel MO for remove
    :param source_cell_id:
    :param neighbor_cell_id:
    :param source_gnb_relation_mapping:
    :param neighbor_gnb_relation_mapping:
    :param connection_alias_source:
    :param connection_alias_neighbor:
    :return:
    """
    source_cell_id = int(source_cell_id)
    neighbor_cell_id = int(neighbor_cell_id)
    source_gnb_relation_mapping, neighbor_gnb_relation_mapping = \
        get_relation_mapping_for_nrrel_operations(
            source_gnb_relation_mapping=source_gnb_relation_mapping,
            neighbor_gnb_relation_mapping=neighbor_gnb_relation_mapping,
            connection_alias_source=connection_alias_source,
            connection_alias_neighbor=connection_alias_neighbor)
    filtered_nrrel = get_nrrel_based_on_cell_id(
        source_cell_id=source_cell_id, neighbor_cell_id=neighbor_cell_id,
        source_gnb_relation_mapping=source_gnb_relation_mapping,
        neighbor_gnb_relation_mapping=neighbor_gnb_relation_mapping,
        connection_alias_source=connection_alias_source, connection_alias_neighbor=connection_alias_neighbor)
    if filtered_nrrel:
        dn_ca_nrrel = filtered_nrrel["short_distName"]
        param_to_delete_nrrel = [dict(dist_name=dn_ca_nrrel)]
        logging.info("get_remove_nrrel_mo_for_online_update: NRREL exist, remove info:{}".format(
            param_to_delete_nrrel))
    else:
        logging.info("get_remove_nrrel_mo_for_online_update:NRREL not filtered out, already removed")
        param_to_delete_nrrel = []
    return param_to_delete_nrrel


def get_nrrel_params_for_online_update(
        source_cell_id, neighbor_cell_id, dict_exp_config,
        source_gnb_relation_mapping=None,
        neighbor_gnb_relation_mapping=None,
        connection_alias_source="GNB_OAM", connection_alias_neighbor="GNB_OAM",
        list_available_nrrel_id=None, nrrel_id_search_index=0, program='master'):
    """
    Author: Ding Binmei
    Generate parameters update for nrrel based on the expected values
    Please note it will only generate the param list for update.
    You still need to call coam admin lib to take effecitve online
    :param source_cell_id:
    :param neighbor_cell_id:
    :param dict_exp_config: expected result for parameters in NRREL.
            None means to delete if previous param is with value added.
            E.G input: {'sCellOperationalMode': 'dlAndUl', 'sCellAdditionMethod': 'blind'}
    :param source_gnb_relation_mapping:
    :param neighbor_gnb_relation_mapping:
    :param connection_alias_source:
    :param connection_alias_neighbor:
    :param list_available_nrrel_id: If set to None, then it will get available nrrel id based on current GNB settings
    :param nrrel_id_search_index: Default to 0. Get from the available index list.
     (If you have multiple addition records, then you can control the nrrel id via this parameter)
    :return:
        E.G: {'object_to_add': [],
              'param_to_add': [
                    {'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                    'parameter': 'sCellAdditionMethod',
                    'value': 'blind'},
                    {'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1',
                     'parameter': 'sCellOperationalMode',
                     'value': 'dlAndUl'}],
                'param_to_upd': [],
                'param_to_del': []}
    """
    source_cell_id = int(source_cell_id)
    neighbor_cell_id = int(neighbor_cell_id)
    source_gnb_relation_mapping, neighbor_gnb_relation_mapping = \
        get_relation_mapping_for_nrrel_operations(
            source_gnb_relation_mapping=source_gnb_relation_mapping,
            neighbor_gnb_relation_mapping=neighbor_gnb_relation_mapping,
            connection_alias_source=connection_alias_source,
            connection_alias_neighbor=connection_alias_neighbor)
    filtered_nrrel = get_nrrel_based_on_cell_id(
        source_cell_id=source_cell_id, neighbor_cell_id=neighbor_cell_id,
        source_gnb_relation_mapping=source_gnb_relation_mapping,
        neighbor_gnb_relation_mapping=neighbor_gnb_relation_mapping,
        connection_alias_source=connection_alias_source, connection_alias_neighbor=connection_alias_neighbor)
    dict_nrrel_update = {'object_to_add': [], 'param_to_add': [], 'param_to_upd': [], 'param_to_del': []}
    logging.info("----------------------------get_nrrel_params_for_online_update------------------------")
    logging.info("Source_cell_id:{}, neighbor_cell_id: {}".format(source_cell_id, neighbor_cell_id))
    if filtered_nrrel:
        for param in dict_exp_config.keys():
            exp_param_value = dict_exp_config[param]
            try:
                act_param_value = filtered_nrrel['parameters'][param]
            except KeyError:
                act_param_value = None
            logging.info("get_nrrel_params_for_online_update--: "
                         "param:{}, exp_param_value:{}, act_param_value:{}".format(param,
                                                                                   exp_param_value, act_param_value))
            if exp_param_value != act_param_value:
                logging.info("get_nrrel_params_for_online_update--: Update NRREL param:{} is needed".format(param))
                if exp_param_value is None:
                    delete_param = dict(dist_name=filtered_nrrel['short_distName'], parameter=param)
                    dict_nrrel_update['param_to_del'].append(delete_param)
                elif act_param_value is None:
                    add_param = dict(dist_name=filtered_nrrel['short_distName'], parameter=param,
                                     value=exp_param_value)
                    dict_nrrel_update['param_to_add'].append(add_param)
                else:
                    update_param = dict(dist_name=filtered_nrrel['short_distName'], parameter=param,
                                        value=exp_param_value)
                    dict_nrrel_update['param_to_upd'].append(update_param)
            else:
                logging.info("get_nrrel_params_for_online_update--:"
                             "Update NRREL: Parameter: {} is as expected. No need to update.".format(param))
    else:
        if 'sCellPrio' in dict_exp_config.keys():
            scell_priority = dict_exp_config['sCellPrio']
        else:
            scell_priority = None

        if 'sCellAdditionMethod' in dict_exp_config.keys():
            scell_addition_method = dict_exp_config['sCellAdditionMethod']
        else:
            scell_addition_method = None

        if 'sCellOperationalMode' in dict_exp_config.keys():
            scell_operational_mode = dict_exp_config['sCellOperationalMode']
        else:
            scell_operational_mode = None

        add_param = get_nrrel_add_param_for_online_update(
            source_cell_id=source_cell_id, neighbor_cell_id=neighbor_cell_id,
            source_gnb_relation_mapping=source_gnb_relation_mapping,
            neighbor_gnb_relation_mapping=neighbor_gnb_relation_mapping,
            connection_alias_source=connection_alias_source,
            connection_alias_neighbor=connection_alias_neighbor,
            scell_addition_method=scell_addition_method,
            scell_operational_mode=scell_operational_mode,
            scell_priority=scell_priority,
            list_available_nrrel_id=list_available_nrrel_id,
            nrrel_id_search_index=nrrel_id_search_index,
            program=program
        )
        dict_nrrel_update['object_to_add'] = add_param
        logging.info("get_nrrel_params_for_online_update: NRREL not exist, add nrrel info: {}".format(
            dict_nrrel_update))
    return dict_nrrel_update


def get_all_the_cells_on_same_RU_with_specific_cell(source_cell_id, gnb_relation_mapping, connection_alias='GNB_OAM'):
    """
    Author: Cui Lingxue
    Get the nr cell id of all the cells on the same RU with the cell specified.
    For example, if 2 cells are configured on AEHC, NRCELL-1 and NRCELL-5.
    specified cell id is 1, then list [1, 5] will be return.
    :param source_cell_id: nr cell id of specified cell
    :return:
        E.G: [1, 5]l
    """
    source_cell_id = int(source_cell_id)
    if gnb_relation_mapping is None:
        gnb_relation_mapping = get_relation_mapping_between_cell_index_and_other_ids(connection_alias=connection_alias)
    ru_index = gnb_relation_mapping[source_cell_id]['ruIndex_in_init']
    cell_id_list_on_same_ru = []
    for cell_id in gnb_relation_mapping.keys():
        if gnb_relation_mapping[cell_id]['ruIndex_in_init'] == ru_index:
            cell_id_list_on_same_ru.append(cell_id)
    return cell_id_list_on_same_ru
