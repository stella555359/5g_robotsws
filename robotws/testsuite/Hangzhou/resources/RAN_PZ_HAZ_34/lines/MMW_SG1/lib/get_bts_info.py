# -*- coding: utf-8 -*-
"""
Author:         Ding Binmei
Contact Mail:   binmei.ding@nokia-sbell.com
Description:    Functions based on coam.admin lib

"""
import logging

from taf.sbts.oam.coam.admin import admin
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_gnb_classical as coam_gnb_classical
import re
coam = admin()

__all__ = ["get_dn_for_channel_groups_and_channels_based_on_cell_id", "get_nrriminfo_based_on_cell_id"]


def get_dn_for_channel_groups_and_channels_based_on_cell_id(
        cell_id, gnb_relation_mapping=None, connection_alias='GNB_OAM'):
    """
    Author: Ding Binmei
    Description: Get dn_channel_group and dn_channel based on cell_id
    :param cell_id: cell_id for NRBTS
    :param gnb_relation_mapping:
    :param connection_alias: connection_alias for ssl connection
    :return: dict_dn_info
    E.G.
    {
        "dn_channel_group": [
            "MRBTS-2126/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-401/CHANNELGROUP-1",
            "MRBTS-2126/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-401/CHANNELGROUP-2", ...
        ],
        "dn_channel": [
            "MRBTS-2126/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-401/CHANNELGROUP-1/CHANNEL-1",
            "MRBTS-2126/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-401/CHANNELGROUP-1/CHANNEL-2", ...
        ]
    }
    """
    if gnb_relation_mapping is None:
        gnb_relation_mapping = coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids(
            connection_alias=connection_alias)
    dict_dn_info = {"dn_channel_group": [], "dn_channel": []}
    cell_id = int(cell_id)
    lcrId = gnb_relation_mapping[cell_id]["lcrId"]
    channel_info_list = coam.get_parameter_by_class(class_name="CHANNEL", connection=connection_alias)
    for channel_info in channel_info_list:
        dn_channel = channel_info["distName"]
        lcrId_in_channel_info = re.match(r".*LCELNR-(\d+)/CHANNELGROUP", dn_channel).group(1)
        if str(lcrId_in_channel_info) == str(lcrId):
            dn_channel_group = re.match(r"(.*)/CHANNEL-", dn_channel).group(1)
            if dn_channel_group not in dict_dn_info["dn_channel_group"]:
                dict_dn_info["dn_channel_group"].append(dn_channel_group)
            dict_dn_info["dn_channel"].append(dn_channel)
    return dict_dn_info


def get_nrriminfo_based_on_cell_id(cell_id, connection_alias='GNB_OAM'):
    """
    Author: Cheng Catherine
    Description: get nrriminfo based on cell id
    :param cell_id: cell_id
    :param connection_alias: connection_alias for ssl connection
    :return: dict nrriminfo, e.g.
    {
        "asymmetricState": "not asymmetric",
        "dlMutingState": {"pdcchMutingStatus": None, "pdschMutingStatus": None},
        "riState": "no RI",
        "rimRsSetIdType1": [],
        "rimRsSetIdType2": []
    }
    """
    dict_nrriminfo = {}
    nrriminfo_list_get = coam.get_managed_objects(class_name="NRRIMINFO_R", connection=connection_alias)
    for nrriminfo_object_get in nrriminfo_list_get:
        nrriminfo_distname_get = nrriminfo_object_get["distName"]
        cell_distname_expect = "NRCELL_R-" + str(cell_id) + "/NRRIMINFO_R"
        if cell_distname_expect in nrriminfo_distname_get:
            dict_nrriminfo = nrriminfo_object_get["parameters"]
            break
    return dict_nrriminfo
