# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:maintainer: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
"""

import re
from taf.sbts.oam.coam.admin import admin

coam = admin()


__all__ = ["get_all_cell_id_via_admin", "get_cell_distname_via_admin", "get_cellgrp_distname_via_admin",
           "get_ru_distname_via_admin", "get_freqbandindicatornr_via_admin", "get_cell_a_distname_via_admin",
           "get_modDNList_via_admin", "get_activate_beamforming_via_admin", "get_radio_protocal_via_admin",
           "get_physCellId_via_admin", "get_ru_product_name_via_admin", "get_ru_index_from_cell_id_via_admin",
           "perform_cell_group_lock_via_admin", "perform_cell_lock_via_admin", "perform_cell_unlock_via_admin",
           "perform_cell_group_unlock_via_admin", "get_lte_cell_data_via_admin"]


def get_cell_distname_via_admin(cell_id=1, timeout=10, connection='GNB_OAM'):
    """
    get cell distname
    :param cell_id: String or int: eg. cell id
    :param timeout : int: Timeout for the operation
    :param connection: String: AdminConnection object or if used, string name alias
    :return: distname: list: distname
    """
    objects = coam.get_managed_objects(class_name='NRCELL_R', timeout=timeout, connection=connection)
    distname = ''
    check_content = 'NRCELL_R-' + str(cell_id)
    for object in objects:
        cell_index = object['distName'].split("/")[-1]
        if check_content == cell_index:
            distname = object['distName']
            break
    return distname


def get_cell_a_distname_via_admin(cell_id=1, timeout=10, connection='GNB_OAM'):
    """
    get cell distname
    :param cell_id: String or int: eg. cell id
    :param timeout : int: Timeout for the operation
    :param connection: String: AdminConnection object or if used, string name alias
    :return: distname: list: distname
    """
    objects = coam.get_managed_objects(class_name='NRCELL_A', timeout=timeout, connection=connection)
    distname = ''
    check_content = 'NRCELL_A-' + str(cell_id)
    for object in objects:
        if check_content in object['distName']:
            distname = object['distName']
    return distname


def get_cellgrp_distname_via_admin(cellgrp_id=0, timeout=10, connection='GNB_OAM'):
    """
    get cell group distname
    :param cell_id: String or int: eg. cell id
    :param timeout : int: Timeout for the operation
    :param connection: String: AdminConnection object or if used, string name alias
    :return: distname: list: distname
    """
    objects = coam.get_managed_objects(class_name='NRCELLGRP_A', timeout=timeout, connection=connection)
    distname = ''
    check_content = 'NRCELLGRP_A-' + str(cellgrp_id)
    for object in objects:
        if check_content in object['distName']:
            distname = object['distName']
    return distname


def get_ru_distname_via_admin(ru_index=1, timeout=10, connection='GNB_OAM'):
    """
    get ru distname
    :param ru_index: String or int: eg. ru index
    :param timeout : int: Timeout for the operation
    :param connection: String: AdminConnection object or if used, string name alias
    :return: distname: list: distname
    """
    hw_info = coam.get_detected_hw_info(timeout=timeout, connection=connection)
    rmod_info = hw_info['radioModules']['rmod']
    for ru in rmod_info:
        ru_id_configuration = ru['id']['configuration']
        ru_id_runtime = ru['id']['runtime']
        get_ru_index = re.search("RMOD-(.)", ru_id_configuration).group(1)
        if str(get_ru_index) == str(ru_index):
            get_id = re.search("RMOD_R-(.)", ru_id_runtime).group(1)
            break
        else:
            get_id = ru_index
    objects = coam.get_managed_objects(class_name='RMOD_R', timeout=timeout, connection=connection)
    distname = ''
    check_content = 'RMOD_R-' + str(get_id)
    for object in objects:
        if check_content in object['distName']:
            distname = object['distName']
    return distname


def perform_cell_lock_via_admin(cell_id=1, get_timeout=10, lock_timeout=60, connection='GNB_OAM'):
    """
    lock cell
    :param cell_id: String or int: eg. cell id
    :param get_timeout : int: Timeout for the operation
    :param lock_timeout : int: Timeout for the operation
    :param connection: String: AdminConnection object or if used, string name alias
    """
    distname = get_cell_distname_via_admin(cell_id=cell_id, timeout=get_timeout, connection=connection)
    coam.lock(dist_name=distname, timeout=lock_timeout, connection=connection)


def perform_cell_unlock_via_admin(cell_id=1, get_timeout=10, lock_timeout=60, connection='GNB_OAM'):
    """
    unlock cell
    :param cell_id: String or int: eg. cell id
    :param get_timeout : int: Timeout for the operation
    :param lock_timeout : int: Timeout for the operation
    :param connection: String: AdminConnection object or if used, string name alias
    """
    distname = get_cell_distname_via_admin(cell_id=cell_id, timeout=get_timeout, connection=connection)
    coam.unlock(dist_name=distname, timeout=lock_timeout, connection=connection)


def perform_cell_group_lock_via_admin(cellgrp_id=0, get_timeout=10, lock_timeout=60, connection='GNB_OAM'):
    """
    lock cell group
    :param cellgrp_id: String or int: eg. cell group id
    :param get_timeout : int: Timeout for the operation
    :param lock_timeout : int: Timeout for the operation
    :param connection: String: AdminConnection object or if used, string name alias
    """
    distname = get_cellgrp_distname_via_admin(cellgrp_id=cellgrp_id, timeout=get_timeout, connection=connection)
    coam.lock_cell_group(dist_name=distname, timeout=lock_timeout, connection=connection)


def perform_cell_group_unlock_via_admin(cellgrp_id=0, get_timeout=10, lock_timeout=60, connection='GNB_OAM'):
    """
    unlock cell group
    :param cellgrp_id: String or int: eg. cell group id
    :param get_timeout : int: Timeout for the operation
    :param lock_timeout : int: Timeout for the operation
    :param connection: String: AdminConnection object or if used, string name alias
    """
    distname = get_cellgrp_distname_via_admin(cellgrp_id=cellgrp_id, timeout=get_timeout, connection=connection)
    coam.unlock_cell_group(dist_name=distname, timeout=lock_timeout, connection=connection)


def get_radio_protocal_via_admin(ru_index=1, timeout=10, connection='GNB_OAM'):
    """
    get radio protocal
    :param ru_index: String or int: eg. ru index
    :param get_timeout : int: Timeout for the operation
    :param lock_timeout : int: Timeout for the operation
    :param connection: String: AdminConnection object or if used, string name alias
    """
    distname = get_ru_distname_via_admin(ru_index=ru_index, timeout=timeout, connection=connection)
    currect_type = coam.get_parameters(dist_name=distname, pattern='l3Protocol', connection=connection)

    Radio_Protocol_Type = 'ECPRI' if 'ECPRI' in currect_type['l3Protocol'] else 'CPRI'
    return Radio_Protocol_Type


def get_activate_beamforming_via_admin(cell_id=1, timeout=10, connection='GNB_OAM'):
    """
    get activate beamforming
    :param cell_id: String or int: eg. cell id
    :param timeout : int: Timeout for the operation
    :param lock_timeout : int: Timeout for the operation
    :param connection: String: AdminConnection object or if used, string name alias
    """
    distname = get_cell_a_distname_via_admin(cell_id=cell_id, timeout=timeout, connection=connection)
    actBeamforming = coam.get_parameters(dist_name=distname, pattern='actBeamforming', connection=connection)
    return actBeamforming['actBeamforming']


def get_freqbandindicatornr_via_admin(cell_id=1, timeout=10, connection='GNB_OAM'):
    """
    get freqBandIndicatorNR
    :param cell_id: String or int: eg. cell id
    :param timeout : int: Timeout for the operation
    :param lock_timeout : int: Timeout for the operation
    :param connection: String: AdminConnection object or if used, string name alias
    """
    distname = get_cell_a_distname_via_admin(cell_id=cell_id, timeout=timeout, connection=connection)
    freqBandIndicatorNR = coam.get_parameters(dist_name=distname, pattern='freqBandIndicatorNR', connection=connection)
    return freqBandIndicatorNR['freqBandIndicatorNR']


def get_physCellId_via_admin(cell_id=1, timeout=10, connection='GNB_OAM'):
    """
    get physCellId
    :param cell_id: String or int: eg. cell id
    :param timeout : int: Timeout for the operation
    :param lock_timeout : int: Timeout for the operation
    :param connection: String: AdminConnection object or if used, string name alias
    """
    distname = get_cell_a_distname_via_admin(cell_id=cell_id, timeout=timeout, connection=connection)
    physCellId = coam.get_parameters(dist_name=distname, pattern='physCellId', connection=connection)
    return physCellId['physCellId']


def get_ru_product_name_via_admin(ru_index=1, timeout=10, connection='GNB_OAM'):
    """
    get ru product name
    :param cell_id: String or int: eg. cell id
    :param timeout : int: Timeout for the operation
    :param lock_timeout : int: Timeout for the operation
    :param connection: String: AdminConnection object or if used, string name alias
    """
    distname = get_ru_distname_via_admin(ru_index=ru_index, timeout=timeout, connection=connection)
    productName = coam.get_parameters(dist_name=distname, pattern='productName', connection=connection)
    return productName['productName']


def get_ru_index_from_cell_id_via_admin(cell_id=1, technology='nr', timeout=10, connection='GNB_OAM'):
    """
    get ru product name
    :param cell_id: String or int: eg. cell id
    :param technology: String: eg. nr or lte
    :param timeout : int: Timeout for the operation
    :param connection: String: AdminConnection object or if used, string name alias
    """
    output = coam.get_cells_info(cell_type=technology.lower(), timeout=timeout, connection=connection)
    ru_index = None
    for cell in output:
        if cell['globalCellId'] == cell_id:
            carrier = cell['carrierList'][0]
            try:
                ru_index = re.search(r'RMOD-(.\d*)', carrier['antennaLineId']['configuration']).group(1)
                return ru_index
            except Exception:
                print("not get ru_index for {}".format(cell_id))
    return ru_index


def get_modDNList_via_admin(cell_id=1, timeout=10, connection='GNB_OAM'):
    """
    get get_modDNList
    :param cell_id: String or int: eg. cell id
    :param timeout : int: Timeout for the operation
    :param connection: String: AdminConnection object or if used, string name alias
    """
    objects = coam.get_managed_objects(class_name='NRCELL_R', timeout=timeout, connection=connection)
    distname = ''
    check_content = 'NRCELL_R-' + str(cell_id)
    for object in objects:
        if check_content in object['distName']:
            distname = object['distName']
    modDNList = coam.get_parameters(dist_name=distname, pattern='modDNList', connection=connection)
    return modDNList['modDNList']


def get_all_cell_id_via_admin(ru_index=None, timeout=10, connection='GNB_OAM'):
    """
    get all cell list
    :param ru_index: String or int or None:
    :param timeout : int: Timeout for the operation
    :param connection: String: AdminConnection object or if used, string name alias
    """
    output = coam.get_cells_info(connection=connection, timeout=timeout)
    cell_list = []
    for cell in output:
        if ru_index is None:
            cell_list.append(cell['globalCellId'])
        else:
            carrier = cell['carrierList'][0]
            if 'RMOD-' + str(ru_index) in carrier['antennaLineId']['configuration']:
                cell_list.append(cell['globalCellId'])
    return cell_list


def get_lte_cell_data_via_admin(timeout=10, connection='GNB_OAM'):
    output = coam.get_cell_list(connection=connection, timeout=timeout)
    lte = output["cells"]["lte"]
    cell_list = []
    for c in lte:
        cell_list.append({
                "cell_id": c["eutranCellId"],
                "frame_structure": "",
                "bandwidth": c["channelBandwidth"].replace(" ", ""),
                "technology": c["technology"],
                "globalCellId": c["globalCellId"],
                "gene": "LTE",
        })
    return cell_list
