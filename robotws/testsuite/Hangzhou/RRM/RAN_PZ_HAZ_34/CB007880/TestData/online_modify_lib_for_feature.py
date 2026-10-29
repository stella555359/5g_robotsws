"""
Author: Ding Binmei
Description: Provide common keyword for online parameter operations for 7935 feature
"""
from robot.libraries.BuiltIn import BuiltIn
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.lib.get_bts_info as get_bts_info
# import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_parameter as coam_parameter
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_gnb_classical as coam_gnb_classical
from taf.sbts.oam.coam.admin import admin
import logging
import re
coam = admin()


def _get_params_to_delete_mo(list_dn):
    obj_to_del = []
    for dn in list_dn:
        obj_to_del.append({'dist_name': dn})
    return obj_to_del


def get_nrPosInfo_dn_for_cell(cell_id, connection_alias='GNB_OAM'):
    """
    Author: Ding Binmei
    Description: Get NRPOSINFO DN for a specific cell
    :param cell_id: cell_id
    :param connection_alias: connection alias
    :return: a list of dn_nrPosInfo
    E.G.:
        ['MRBTS-2126/NRBTS-37731/NRCELL-401/NRPOSINFO-2', 'MRBTS-2126/NRBTS-37731/NRCELL-401/NRPOSINFO-3']
    """
    list_mo_nrPosInfo = coam.get_parameter_by_class(class_name="NRPOSINFO", connection=connection_alias)
    list_dn_nrPosInfo = []
    for mo_nrPosInfo in list_mo_nrPosInfo:
        dn_nrPosInfo = mo_nrPosInfo["distName"]
        cell_id_in_dn = re.match(r".*NRCELL-(\d+)/NRPOSINFO", dn_nrPosInfo).group(1)
        if str(cell_id_in_dn) == str(cell_id):
            list_dn_nrPosInfo.append(dn_nrPosInfo)
    return list_dn_nrPosInfo


def get_params_to_update_from_super_cell_to_normal_cell(cell_id, connection="GNB_OAM"):
    """
    Author: Ding Binmei
    Description: Get params to update from super cell to normal cell
    Based on pdl validation. When disable super cell, the following parameters should be updated:
        prams to be updated:
        --NRCELL-401/actSuperCell=false
        --NRCELLGRP-401/numberOfTransmittedSsBlocks = 1 beam
        mos to be deleted: Can only leave one channel group one cell, can only leave one NRPOSINFO one cell
        --MRBTS-2121/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-401/CHANNELGROUP-2
        --MRBTS-2121/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-401/CHANNEL-1
        --MRBTS-2121/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-401/CHANNEL-2
        --MRBTS-2126/NRBTS-37731/NRCELL-401/NRPOSINFO-3
    :param cell_id: cell_id
    :param connection: connection alias
    :return: dict_params_to_disable_super_cell
    E.G:
    {
    "object_to_del": [
        {"dist_name": "MRBTS-2126/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-401/CHANNELGROUP-2"},
        {"dist_name": "MRBTS-2126/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-401/CHANNELGROUP-3"},
        {"dist_name": "MRBTS-2126/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-401/CHANNELGROUP-2/CHANNEL-1"},
        {"dist_name": "MRBTS-2126/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-401/CHANNELGROUP-2/CHANNEL-2"},
        {"dist_name": "MRBTS-2126/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-401/CHANNELGROUP-3/CHANNEL-1"},
        {"dist_name": "MRBTS-2126/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-401/CHANNELGROUP-3/CHANNEL-2"},
        {"dist_name": "MRBTS-2126/NRBTS-37731/NRCELL-401/NRPOSINFO-2"}
    ],
    "param_to_upd": [
        {"dist_name": "MRBTS-2126/NRBTS-37731/NRCELL-401", "parameter": "actSuperCell", "value": "false"},
        {"dist_name": "MRBTS-2126/NRBTS-37731/NRCELLGRP-401", "parameter": "numberOfTransmittedSsBlocks",
        "value": "1 beam"}]
    }
    """
    gnb_relation_mapping = coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids(
        connection_alias=connection)
    dict_params_to_disable_super_cell = {"param_to_upd": [], "object_to_del": []}
    dn_cell = param_modify_lib.DN_NRBTS + "/NRCELL-" + str(cell_id)
    dn_cell_grp = param_modify_lib.DN_NRBTS + "/NRCELLGRP-" + str(cell_id)
    # params to be updated
    list_params_to_update = [
        dict(dist_name=dn_cell, parameter='actSuperCell', value='false'),
        dict(dist_name=dn_cell_grp, parameter='numberOfTransmittedSsBlocks', value='1 beam')
    ]
    dict_params_to_disable_super_cell["param_to_upd"].extend(list_params_to_update)
    # params to be deleted: Additional channel groups and channels
    dict_dn_info_channel_groups_channels = (
        get_bts_info.get_dn_for_channel_groups_and_channels_based_on_cell_id(
            cell_id=cell_id, gnb_relation_mapping=gnb_relation_mapping, connection_alias=connection))
    logging.debug("dict_dn_info_channel_groups_channels is {}".format(dict_dn_info_channel_groups_channels))
    list_dn_channel_groups = dict_dn_info_channel_groups_channels["dn_channel_group"]
    list_dn_channel = dict_dn_info_channel_groups_channels["dn_channel"]
    dn_channel_grps_and_channels_to_be_deleted = []
    dn_channel_grps_to_be_deleted = []
    if len(list_dn_channel_groups) > 1:
        dn_channel_grps_to_be_deleted = list_dn_channel_groups[1:]
        dn_channel_grps_and_channels_to_be_deleted.extend(dn_channel_grps_to_be_deleted)
    for dn_channel in list_dn_channel:
        dn_channel_grp = re.match(r"(.*)/CHANNEL-", dn_channel).group(1)
        if dn_channel_grp in dn_channel_grps_to_be_deleted:
            dn_channel_grps_and_channels_to_be_deleted.append(dn_channel)
    logging.debug("dn_channel_grps_and_channels_to_be_deleted is {}".format(
        dn_channel_grps_and_channels_to_be_deleted))
    # params to be deleted: nrposinfo, should keep only one mo for nrposinfo-1 otherwise pdl validation fails
    list_dn_nrPosInfo = get_nrPosInfo_dn_for_cell(cell_id=cell_id, connection_alias=connection)
    logging.debug("list_dn_nrPosInfo is {}".format(list_dn_nrPosInfo))
    dn_nrPosInfo_to_be_deleted = []
    if len(list_dn_nrPosInfo) > 1:
        dn_nrPosInfo_to_be_deleted = sorted(list_dn_nrPosInfo)[1:]
        logging.debug("dn_nrPosInfo_to_be_deleted is {}".format(dn_nrPosInfo_to_be_deleted))
    all_dn_to_be_deleted = dn_channel_grps_and_channels_to_be_deleted + dn_nrPosInfo_to_be_deleted
    dict_params_to_disable_super_cell["object_to_del"].extend(_get_params_to_delete_mo(list_dn=all_dn_to_be_deleted))
    return dict_params_to_disable_super_cell


def get_srs_pos_config_params_for_update(
        list_cell_id, cSRS="50", comb="comb4", numberOfCS="2 cycle shifts",
        srsUePeriodicity="slots80"):
    """
    Author: Ding Binmei
    Description: Get srs pos config params for update. If cells are configured to same
    :param list_cell_id: a list of cell ids
    :param cSRS: cSRS value, default is 50
    :param comb: comb value, default is comb4
    :param numberOfCS: numberOfCS value, default is 2 cycle shifts
    :param srsUePeriodicity: srsUePeriodicity value, default is slots80
    :return: a list of dict params for srs config update
    E.G.:

    [
        {'dist_name': 'MRBTS-2126/NRBTS-37731/NRCELL-401', 'parameter': 'srsForPositioning',
         'value': [{'cSRS': '50', 'comb': 'comb4', 'numberOfCS': '2 cycle shifts', 'srsUePeriodicity': 'slots80'}]},
        {'dist_name': 'MRBTS-2126/NRBTS-37731/NRCELL-402', 'parameter': 'srsForPositioning',
         'value': [{'cSRS': '50', 'comb': 'comb4', 'numberOfCS': '2 cycle shifts', 'srsUePeriodicity': 'slots80'}]}
    ]
    """
    params_update_srs_config = []
    for cell_id in list_cell_id:
        dn_cell = param_modify_lib.DN_NRBTS + "/NRCELL-" + str(cell_id)
        params_update_srs_config.append(dict(
            dist_name=dn_cell, parameter="srsForPositioning",
            value=[dict(cSRS=str(cSRS), comb=comb, numberOfCS=numberOfCS, srsUePeriodicity=srsUePeriodicity)]))
    return params_update_srs_config
