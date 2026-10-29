# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Maciej Nowak
:contact: maciej.1.nowak@nokia.com
:maintainer: None
:contact: None
"""
from taf.sbts.oam.coam.admin import admin
import SISO_Utilities as utility
from testsuite.SISO.Wroclaw.CommonKeywords.PythonKeywords.logger import log_input_and_output, log_suppression, \
    log_exception
from testsuite.SISO.Wroclaw.CommonKeywords.PythonKeywords.timer.timer import timer


@log_input_and_output
@utility.raise_when_output_is_empty
def get_admin_cells_mrbts(connection):
    """
    Returns dist_name values for all cells as a list
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: list of dist_name values for all cells from admin info model
    :rtype: list of str
    """
    adm = admin()
    subcells_info_output = adm.get_subcells_info(connection=connection)

    dist_name_list = []

    for cell_groups, cell_groups_values in subcells_info_output.items():
        for nr_cell, nr_cell_values in cell_groups_values.items():
            dist_name_list.append(nr_cell_values['NRCELL_R']['distName'])
    return dist_name_list


@log_input_and_output
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


@log_input_and_output
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


@log_input_and_output
@utility.raise_when_output_is_empty
def get_admin_rus_mrbts(connection):
    """
    Returns dist_name values for all cells as a list
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: list of dist_name values for all available Radio Units from admin info model
    :rtype: list of str
    """
    adm = admin()
    frm_output = adm.get_frm(connection=connection)

    return [elements['id']['internal'] for elements in frm_output]


@log_input_and_output
@utility.raise_when_output_is_empty
def get_admin_ru_mrbts(connection, rmod_id):
    """
    Returns dist_name values for selected ru
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :param rmod_id: rmod index, counts from 1, dist name example: .../RMOD_R-1, .../RMOD_R-2, .. .../RMOD_R-N
    :type rmod_id: int
    :return: dist_name values for selected Radio Units from admin info model
    :rtype: str
    :raises: KeyError if there is no dist_name related to selected rmod id.
    """
    for ru_dist_name in get_admin_rus_mrbts(connection):
        if 'RMOD_R-{}'.format(rmod_id) in ru_dist_name:
            return ru_dist_name
    raise KeyError("Can't find rmod_id on dist name list recovered from BTS.")


@log_input_and_output
@utility.raise_when_output_is_empty
def get_admin_rus_conf(connection):
    """
    Returns dist_name values for all radio units as a list
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: list of dist_name values for all available Radio Units from admin info model
    :rtype: list of str
    """
    adm = admin()
    frm_output = adm.get_frm(connection=connection)

    return [elements['id']['configuration'] for elements in frm_output]


@log_input_and_output
@utility.raise_when_output_is_empty
def get_admin_ru_conf(connection, rmod_id):
    """
    Returns dist_name values for selected radio unit
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :param rmod_id: rmod index, counts from 1, dist name example: .../RMOD-1, .../RMOD-2, .. .../RMOD-N
    :type rmod_id: int or str
    :return: dist_name value for selected Radio Unit from admin info model
    :rtype: str
    :raises: KeyError if there is no dist_name related to selected rmod id.
    """
    for ru_dist_name in get_admin_rus_conf(connection):
        if 'RMOD-{}'.format(rmod_id) in ru_dist_name:
            return ru_dist_name
    raise KeyError("Can't find rmod_id dist name in list recovered from BTS.")


@log_input_and_output
def check_ru_parameter_status(dist_name, parameter, connection):
    """
    Returns status for parameter
    :param dist_name: MRBTS for Radio Unit
    :type dist_name: str
    :param parameter: parameter to be checked
    :type parameter: str
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: parameter value, empty if not found
    :rtype: str
    """
    adm = admin()
    for elem in adm.get_frm(connection=connection):
        if elem['id']['internal'] == dist_name:
            status = elem['status'][parameter]
            return status
    log_suppression("parameter:{} not found".format(parameter))
    return ""


@log_input_and_output
@utility.raise_when_output_is_empty
def get_admin_cell_groups_parameters(connection):
    """
    Returns parameters for all cell groups as a list
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: list of all cell groups from admin info model
    :rtype: list of str
    """
    adm = admin()
    return adm.get_bts_info(connection=connection)['cellsGroup']


@log_input_and_output
def get_admin_first_cell_group_id(connection):
    """
    Returns id of first cell group
    :param connection: AdminConnection object or if used, string name alias
    :type connection: AdminConnection or str
    :return: id of first cell group as string
    :rtype: str
    """
    cell_groups_parameters = get_admin_cell_groups_parameters(connection)
    return cell_groups_parameters[0][u'name'].split('-')[1]


@log_input_and_output
def get_list_of_rus_based_on_selected_cell(list_of_cells_params, list_of_ru_ids):
    """
    Returns parameters for all rus related with provided cells
    :param list_of_cells_params: example: [{..., 'distName': '/.../NRCELL_R-1', 'frRefList': ['../RMOD-1']...}]
    :type list_of_cells_params: list
    :param list_of_ru_ids: list of tested rus, example: [0, 1, ...]
    :type list_of_ru_ids: list
    :return: list of rus: enumerated like in init file, example: [0, 1, ..]
    :rtype: list of str
    """
    list_of_rus = []
    for cell_params in list_of_cells_params:
        ru_id = int(str(cell_params['frRefList'][0]).split('-')[-1]) - 1
        if ru_id in list_of_ru_ids:
            list_of_rus.append(int(str(cell_params['frRefList'][0]).split('-')[-1]) - 1)
    return list_of_rus


@log_input_and_output
def get_list_of_rus_based_on_selected_cell_group(list_of_cells, list_of_cells_params, list_of_ru_ids):
    """
    Returns parameters for all rus related with provided cell groups
    :param list_of_cells: cells from cell group, example: [{..., u'nrCellList': [u'NRCELL-1'], ...}]
    :type list_of_cells: list
    :param list_of_cells_params: example: [{..., 'distName': '/.../NRCELL_R-1', 'frRefList': ['../RMOD-1']...}]
    :type list_of_cells_params: list
    :param list_of_ru_ids: list of tested rus, example: [0, 1, ...]
    :type list_of_ru_ids: list
    :return: list of rus: enumerated like in init file, example: [0, 1, ..]
    :rtype: list of str
    """
    list_of_rus = []
    for cells in list_of_cells:
        for cell in cells['nrCellList']:
            dist_name = cell.replace('NRCELL-', 'NRCELL_R-')
            for cell_param in list_of_cells_params:
                if dist_name in cell_param['distName']:
                    ru_id = int(cell_param['frRefList'][0].split('-')[-1]) - 1
                    if ru_id in list_of_ru_ids:
                        list_of_rus.append(ru_id)

    return list_of_rus


@log_input_and_output
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


@log_input_and_output
def get_radio_index(mrbts):
    return mrbts.split('-')[-1]


@log_input_and_output
@utility.raise_when_output_is_empty
def get_admin_radio_index(connection):
    """
    Return radio index values for all radios as a list
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: list of radio index values for all cells from admin info model
    :rtype list of int
    """
    radios = get_admin_rus_mrbts(connection)
    list_of_ru_indexes = [int(radio.split('-')[-1]) for radio in radios]
    return list_of_ru_indexes


@log_input_and_output
@utility.raise_when_output_is_empty
def get_ru_mrbts_by_operational_state(status, connection):
    """
    Returns MRBTS for RMODs by selected operational status
    :param status: ex. Enabled, Disabled
    :type status: str
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: list of MRBTS
    :rtype list of str
    """
    adm = admin()
    frm_output = adm.get_frm(connection=connection)
    return [rmod['id']['internal'] for rmod in frm_output if str(status) == rmod['status']['operationalState']]


@log_input_and_output
@utility.raise_when_output_is_empty
@timer()
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


@log_input_and_output
def get_bts_id_from_api(admin_api_log_dir='/tmp'):
    """
    Get bts ID

    :param admin_api_log_dir: (optional) AdminAPI log dir
    :type admin_api_log_dir: Str
    :return: bts id, i.e. '1900'
    :rtype str
    """
    alias = 'ad_get_id'
    ad = admin()
    bts_host, username, password, bts_port = utility.get_details_to_login_from_init('http')
    ad.connect_to(
        bts_host=bts_host,
        username=username,
        password=password,
        bts_port=bts_port,
        name=alias,
        admin_api_log_dir=admin_api_log_dir
    )
    try:
        bts_id = ad.get_bts_info(connection=alias).get('mrbtsID')
    finally:
        ad.teardown(connection=alias)
    return bts_id


@log_input_and_output
def get_bts_name_from_bts_info(connection):
    """
    Get's BTS Name through admin api.
    :param connection: AdminConnection object or if used, string name alias/session.
    :return: BTS name from api.
    :rtype: str
    :raises: KeyError if there is no 'name' key in returned bts info from api.
    """
    adm = admin()
    try:
        return adm.get_bts_info(connection=connection)['name']
    except KeyError:
        raise KeyError("Can not find name of BTS. Are You sure that You are connected to BTS?")


@log_input_and_output
def check_statuses_for_disabled_radio(connection='admin'):
    """
    confirms that all RFM states are correct: Disabled/not initialized/Unlocked/NotInstalled
    :param connection: AdminConnection object or if used, string name alias.
    :type connection: AdminConnection or str
    :return: verification results
    :rtype bool
    """
    mrbts_list = get_ru_mrbts_by_operational_state(status='Disabled', connection=connection)
    for mrbts in mrbts_list:
        adm_state = check_ru_parameter_status(dist_name=mrbts, parameter='administrativeState', connection=connection)
        av_state = check_ru_parameter_status(dist_name=mrbts, parameter='availabilityStatus', connection=connection)
        proc_state = check_ru_parameter_status(dist_name=mrbts, parameter='proceduralStatus', connection=connection)
        if adm_state != 'Unlocked' or av_state != 'NotInstalled' or proc_state != 'not initialized':
            log_exception("Incorrect status for disabled radio")
            log_exception(mrbts)
            return False
    return True
