# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Maciej Nowak
:contact: maciej.1.nowak@nokia.com
:maintainer: None
:contact: None
"""
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from taf.gnb.oam.megazone_client import megazone_client

import SISO_Utilities as utility
# import SISO_Timer as timer


@utility.raise_when_output_is_empty
def get_admin_cells_parameters(connection):
    """
    Returns dist_name values for all cells as a list
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: list of parameters of cells
    :rtype: list of dict of str
    """
    adm = admin()
    subcells_info_output = adm.get_subcells_info(connection=connection)

    dist_name_list = []

    for cell_groups, cell_groups_values in subcells_info_output.items():
        for nr_cell, nr_cell_values in cell_groups_values.items():
            temp_dict = nr_cell_values['NRCELL_R']['parameters']
            temp_dict["CELLGRP"] = cell_groups.split('-')[-1]
            temp_dict['CELLID'] = nr_cell.split('-')[-1]
            temp_dict['distName'] = nr_cell_values['NRCELL_R']['distName']
            dist_name_list.append(temp_dict)
    return dist_name_list


def get_number_of_ru(connection):
    """
    Returns number of available Radio Units
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: number of radio units
    :rtype: int
    """
    adm = admin()
    bts_info_output = adm.get_bts_info(connection=connection)

    return len(bts_info_output['radioModules']['rmod'])


def check_ru_parameter_status(dist_name, parameter, connection):
    """
    Returns status for parameter
    :param dist_name: MRBTS for Radio Unit
    :type dist_name: str
    :param parameter: parameter to be checked
    :type parameter: str
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: parameter value
    :rtype: str
    """
    adm = admin()
    frm_output = adm.get_frm(connection=connection)

    for elem in frm_output:
        if elem['id']['internal'] == dist_name:
            parameter_status = elem['status'][parameter]

    return parameter_status


@utility.raise_when_output_is_empty
def get_admin_cell_groups_index(connection):
    """
    Returns sorted list of Cell Group indexes from info model
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: sorted list of cell groups indexes
    :rtype list of int
    """
    cells_groups = get_admin_cell_groups(connection=connection)
    return [cells_group[-1] for cells_group in cells_groups]


@utility.raise_when_output_is_empty
def get_admin_cell_groups(connection):
    """
    Returns dist_name values for all cell groups as a list
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: list of dist_name values for all cell groups from admin info model
    :rtype: list of str
    """
    adm = admin()
    cells_groups = adm.get_bts_info(connection=connection)['cellsGroup']

    return [str(cells_group['id']['internal']) for cells_group in cells_groups]


def get_admin_cell_group_parameters(connection, group_name, cell_name):
    """
    Returns cell group parameters from info model

    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :param group_name: Cell group dist name
    :type group_name: str
    :param cell_name: dist_name of cell which is within cell group
    :type cell_name: str
    :return: cell group parameters
    :rtype dict
    """
    adm = admin()
    subcells_info_output = adm.get_subcells_info(connection=connection)
    return subcells_info_output[group_name][cell_name]['NRCELL_L']['parameters']


@utility.raise_when_output_is_empty
def get_admin_radio_index(connection):
    """
    Return radio index values for all radios as a list
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: list of radio index values for all cells from admin info model
    :rtype list of int
    """
    radios = get_admin_ru_mrbts_coam(connection)
    list_of_ru_indexes = [int(radio.split('-')[-1]) for radio in radios]
    return list_of_ru_indexes


@utility.raise_when_output_is_empty
def get_mrbts_by_operational_state(status, connection):
    """
    Returns MRBTS for RMOD by operational status
    :param status: ex. Enabled, Disabled
    :type status: str
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: list of MRBTS
    :rtype list of str
    """
    adm = admin()
    frm_output = adm.get_frm(connection=connection)

    return [rmod['id']['internal'] for rmod in frm_output if str(status) in rmod['status']['operationalState']]


@utility.raise_when_output_is_empty
# @timer.timer
def get_cells_info_admin(connection, cell_type="nr", timeout=10):
    """
     Get information about all cells, provided by M-plane (OAM).
    Currently the returned structures are different for 5G(nr) and 4G.

    :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    :param Union[int,str] timeout: Keyword execution timeout.
    :param AdminConnection connection: AdminConnection object or if used, string name alias
    :return dict: Dictionary with data for each available cell of given type.
                  More details (content of requestMessage is returned data):
                  https://onion.wroclaw.nsn-rdnet.net/branches/master/cli-docs/tutorial-getCellList.html
    """
    adm = admin()
    return adm.get_cells_info(cell_type=cell_type, timeout=timeout, connection=connection)


def get_bts_id_from_api(tl_topology, admin_api_log_dir='/tmp'):
    """
    Get bts ID

    :param tl_topology: type of test line topology, i.e. 'cOAM'
    :type tl_topology: str
    :param admin_api_log_dir: (optional) AdminAPI log dir
    :type admin_api_log_dir: Str
    :return: bts id, i.e. '1900'
    :rtype str
    """
    if tl_topology in ('CLOUD', 'eCPRI_CLOUD'):
        return _get_bts_id_from_api_megazone()
    if tl_topology == 'CLASSICAL':
        return _get_bts_id_from_api_coam(log_dir=admin_api_log_dir)


def _get_bts_id_from_api_coam(log_dir):
    ad = admin()
    bts_host, username, password = utility.get_details_to_login_from_init('http')
    ad.connect_to(bts_host=bts_host, username=username, password=password, bts_port=3600,
                  name='_ad_bts_id', admin_api_log_dir=log_dir)
    try:
        bts_id = ad.get_bts_info(connection='_ad_bts_id').get('mrbtsID')
    finally:
        ad.teardown(connection='_ad_bts_id')
    return bts_id


def _get_bts_id_from_api_megazone():
    mc = megazone_client()
    base_url, username, password = utility.get_details_to_login_from_init('http')
    mc.create_session(base_url=base_url, user=username, password=password, alias='_mc_bts_id')
    try:
        bts_id = mc.get_bts_info(attribute="id", session='_mc_bts_id')
    finally:
        mc.teardown_session(session='_mc_bts_id')
    return bts_id


def get_bts_name_from_bts_info(connection, coam=True):
    """
    Get's BTS Name through api on cOAM or Megazone.
    :param connection: AdminConnection/MegazoneConnection object or if used, string name alias/session.
    :param coam: (Optional) if True , return name of BTS for coam.
    :type coam: Bool
    :return: BTS name from api.
    :rtype: str
    :raises: KeyError if there is no 'name' key in returned bts info from api.
    """
    if coam:
        adm = admin()
        try:
            return adm.get_bts_info(connection=connection)['name']
        except KeyError:
            raise KeyError("Can not find name of BTS. Are You sure that You are connected to BTS?")
    else:
        megazone = megazone_client()
        try:
            return megazone.get_bts_info(session=connection)['name']
        except KeyError:
            raise KeyError("Can not find name of BTS. Are You sure that You are connected to BTS?")
