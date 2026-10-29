# -*- coding: utf-8 -*-
"""
Author:         Ding Binmei
Contact Mail:   binmei.ding@nokia-sbell.com
Description:    Functions based on coam.admin lib

"""
from taf.gnb.oam.coam.admin import admin
import logging

coam = admin()


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
    logging.debug("subcells_info: {}".format(subcells_info))
    dict_cells_info = get_relation_mapping_between_cell_index_and_cell_info(connection_alias=connection_alias)
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
                lcrId = cells_info[cell_name]['NRCELL_L']['parameters']['lcrId']
                physicalCellId = dict_cells_info[cell_index]['physicalCellId']
                cell_related_ids['cell_group_id'] = cell_group_id
                cell_related_ids['nrCellIdentity'] = nrCellIdentity
                cell_related_ids['lcrId'] = lcrId
                cell_related_ids['physicalCellId'] = physicalCellId
                cell_related_ids['detail_cells_info'] = dict_cells_info[cell_index]
                relation_mapping[cell_index] = cell_related_ids
                logging.debug("cell_index: {}, cell_group_id: {}, nrCellIdentity:{}, physicalCellId:{}".format(
                    cell_index, cell_group_id, nrCellIdentity, physicalCellId))
    return relation_mapping


def get_relation_mapping_between_cell_index_and_cell_info(connection_alias='GNB_OAM'):
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
