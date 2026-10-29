# -*- coding: utf-8 -*-
"""
:created on: 2020-01-11

:copyright: Nokia
:author: Yao Yonna
:contact: yonna.yao@nokia-sbell.com
"""

import os
import logging
from taf.config.scf import scf
from robot.libraries.BuiltIn import BuiltIn
from taf.gnb.oam.coam.vdu import Vdu
import re


class VranBase():
    """Config Gnb to expected status for vran2.0
    """
    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        """"""
        self.ROBOT_LIBRARY_LISTENER = self

    def vdu_change_vlan_ids_in_scfc(self, dest_scfc_path, **oam_vdu):
        vlan_ids = self._get_vlan_ids_from_tl_config()
        logging.info("Vdu vlan ids:{}".format(vlan_ids))
        scfc_mod = self._update_vlan_ids_in_base_scfc(dest_scfc_path, vlan_ids)
        return scfc_mod

    def _get_vlan_ids_from_tl_config(self):
        return BuiltIn().get_variable_value("${VLAN_IDS}")

    def _get_vlan_ids_from_vdu(self, dest_path, **oam_vdu):
        vdu_scfc = "{}{}".format(dest_path, 'scfc_admin_collect.xml')
        self._get_scfc_from_vdu(dest_path, 'scfc_admin_collect.xml', **oam_vdu)
        scf_obj = scf()
        scf_obj.load_scf(vdu_scfc)
        dist_name_1 = 'MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1'
        dist_name_2 = 'MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2'
        return scf_obj.get_value_from_scf(dist_name=dist_name_1, p_name='vlanId'), scf_obj.get_value_from_scf(
            dist_name=dist_name_2, p_name='vlanId')

    def _get_scfc_from_vdu(self, save_path, scfc_name, **oam_vdu):
        try:
            oam_vdu_obj = Vdu()
            oam_vdu_obj.connect_to(**oam_vdu)
            oam_vdu_obj.get_current_plan_file(local_dir_path=save_path, filename=scfc_name,
                                              vdu_connection=oam_vdu['connection_name'])
        finally:
            oam_vdu_obj.disconnect(vdu_connection=oam_vdu['connection_name'])

    def _update_vlan_ids_in_base_scfc(self, scfc_file, vlan_ids):
        scfc_obj = scf()
        cell_distnames = self._get_cell_dist_names(scfc_file)
        scfc_obj.load_scf(scfc_file)
        for dist_name in cell_distnames:
            scfc_obj.modify_scf_element(value=vlan_ids[0], dist_name=dist_name, p_name='vlanId')
        scfc_mod = os.path.join(os.path.split(scfc_file)[0], 'scfc_mod_vlanid.xml')
        scfc_obj.save_scf(file_path=scfc_mod)
        return scfc_mod

    def _get_cell_dist_names(self, scfc_file):
        with open(scfc_file) as f:
            con = f.read()
        return re.findall('class="com.nokia.srbts.mnl:LCELNR" distName="(.*)" operation', con)


def vdu_change_vlan_ids_in_scfc(src_scfc, dest_scfc_path, **oam_vdu):
    return VranBase().vdu_change_vlan_ids_in_scfc(src_scfc, dest_scfc_path, None, **oam_vdu)
