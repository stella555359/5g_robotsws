# -*- coding: utf-8 -*-
"""
Author:         Ding Binmei
Contact Mail:   binmei.ding@nokia-sbell.com
Description:    Functions based on taf.gnb.oam.coam lib

"""
from taf.gnb.oam.coam.cu import cu
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.coam_gnb_classical as coam_gnb_classical
import cloud_online_modify as cloud_online_modify
from taf.rfrl.cbts.devices.vcu.base.vcu_cm_base import vCUCM
import logging
import time
vcu = cu()
rfrl_vcu_cm_base = vCUCM()


__all__ = ['get_nrrel_params_for_online_update_cloud',
           'get_remove_nrrel_mo_for_online_update_cloud',
           'delete_nrrel_mo']


def get_nrrel_params_for_online_update_cloud(
        source_cell_id, neighbor_cell_id, dict_exp_config,
        source_gnb_relation_mapping=None,
        neighbor_gnb_relation_mapping=None,
        connection_alias_source="OAM_CU0", connection_alias_neighbor="OAM_CU0",
        list_available_nrrel_id=None, nrrel_id_search_index=0, program='master'):
    """
    Author: Ding Binmei
    Generate parameters update for nrrel based on the expected values
    Please note it will only generate the param list for update.
    You still need to call bellow method to take effecitve online
    --   cloud_online_modify.online_modify_for_params_update_with_non_provision_method
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
        E.G: {'object_to_add': [], 'param_to_add': [], 'param_to_upd': [], 'param_to_del': []}
    """
    dict_nrrel_update = coam_gnb_classical.get_nrrel_params_for_online_update(
        source_cell_id=source_cell_id, neighbor_cell_id=neighbor_cell_id, dict_exp_config=dict_exp_config,
        source_gnb_relation_mapping=source_gnb_relation_mapping,
        neighbor_gnb_relation_mapping=neighbor_gnb_relation_mapping,
        connection_alias_source=connection_alias_source, connection_alias_neighbor=connection_alias_neighbor,
        list_available_nrrel_id=list_available_nrrel_id,
        nrrel_id_search_index=nrrel_id_search_index, program=program, is_nrrel_id_needed=False)
    return dict_nrrel_update


def get_remove_nrrel_mo_for_online_update_cloud(source_cell_id, neighbor_cell_id,
                                                source_gnb_relation_mapping=None,
                                                neighbor_gnb_relation_mapping=None,
                                                connection_alias_source="OAM_CU0",
                                                connection_alias_neighbor="OAM_CU0"):
    """
        Author: Ding Binmei
        Get nrrel MO for remove
        :param source_cell_id:
        :param neighbor_cell_id:
        :param source_gnb_relation_mapping:
        :param neighbor_gnb_relation_mapping:
        :param connection_alias_source:
        :param connection_alias_neighbor:
        :return: [{'dist_name': 'MRBTS-37241/NRBTS-37241/NRCELL-1/NRREL-1'}]
    """

    param_to_delete_nrrel = coam_gnb_classical.get_remove_nrrel_mo_for_online_update(
        source_cell_id=source_cell_id,
        neighbor_cell_id=neighbor_cell_id,
        source_gnb_relation_mapping=source_gnb_relation_mapping,
        neighbor_gnb_relation_mapping=neighbor_gnb_relation_mapping,
        connection_alias_source=connection_alias_source,
        connection_alias_neighbor=connection_alias_neighbor
    )
    return param_to_delete_nrrel


def delete_nrrel_mo(source_cell_id, neighbor_cell_id,
                    source_gnb_relation_mapping=None, neighbor_gnb_relation_mapping=None,
                    connection_alias_source="OAM_CU0", connection_alias_neighbor="OAM_CU0",
                    timeout=300, is_to_active_plan=True):
    """
    Author: Ding Binmei
    :param source_cell_id:
    :param neighbor_cell_id:
    :param source_gnb_relation_mapping:
    :param neighbor_gnb_relation_mapping:
    :param connection_alias_source:
    :param connection_alias_neighbor:
    :param timeout: timeout for wait for mo delete
    :param is_to_active_plan: True/ False
    :return:
    """
    param_to_delate_nrrel_classical_format = get_remove_nrrel_mo_for_online_update_cloud(
        source_cell_id=source_cell_id, neighbor_cell_id=neighbor_cell_id,
        source_gnb_relation_mapping=source_gnb_relation_mapping,
        neighbor_gnb_relation_mapping=neighbor_gnb_relation_mapping,
        connection_alias_source=connection_alias_source,
        connection_alias_neighbor=connection_alias_neighbor)
    cloud_online_modify.delete_mo_on_cu(list_mo_to_delete=param_to_delate_nrrel_classical_format,
                                        connection=connection_alias_source, timeout=timeout,
                                        is_to_active_plan=is_to_active_plan)
