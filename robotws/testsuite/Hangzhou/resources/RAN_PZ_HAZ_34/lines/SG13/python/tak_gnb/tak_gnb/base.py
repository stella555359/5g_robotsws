# -*- coding: utf-8 -*-
"""
:created on: 2020-01-11

:copyright: Nokia
:author: Yao Yonna
:contact: yonna.yao@nokia-sbell.com
"""

import os
import logging
from taf.sbts.oam.coam.admin import admin
from taf.config.scf import scf
from tak_core import tak_core
from robot.libraries.BuiltIn import BuiltIn
from taf.gnb.oam.coam.vdu import Vdu
import re


class Base(object):
    """Config Gnb to expected status.
    """
    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        """"""
        self.ROBOT_LIBRARY_LISTENER = self
        self._py_path = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        self._tribe_top_path = os.path.dirname(os.path.dirname(os.path.dirname(self._py_path)))
        self._gnb_config_path = os.path.join(os.path.join(self._tribe_top_path, 'example'), 'config')

    def find_testline_base_scfc(self, scfc=None, remote_host=None):
        """return input parameter value of scfc if its value is not None
        else return the scfc path from RAN_L2_SW_CN_3/example/config
        """
        if str(scfc) == 'None':
            tl_type = self._get_testline_type(remote_host)
            scfc = self._read_scfc_file_name_in_common_config_path(tl_type, remote_host)
            if scfc == '':
                raise Exception("Don't find base scfc file.")
        return scfc

    def find_testline_base_wts_config(self, wts=None, remote=None):
        """return input parameter value of wts if its value is not None
        else return the wts path from suite value ${WTS_CFG_FULL_PATH}
        """
        if str(wts) == 'None':
            wts = BuiltIn().replace_variables("${WTS_CFG_FULL_PATH}")
        return wts

    def _get_testline_type(self, remote_host):
        out, err, rc = tak_core().execute("cat /opt/ute/reservation.json", remote_host)
        return eval(out)["testline_type"]

    def _read_scfc_file_name_in_common_config_path(self, remote_host):
        tl_type = self._get_testline_type(remote_host)
        scfc_path = "{}/{}/".format(self._gnb_config_path, tl_type)
        scfc_full_path, err, rc = tak_core().execute("ls {}*scfc*".format(scfc_path), remote_host)
        return scfc_full_path

    def change_vlan_id_in_scfc(self, src_scfc, dest_scfc_path, remote_host=None):
        tak_core().execute("mkdir -p {}".format(dest_scfc_path), remote_host)
        vlan_id = self._get_vlan_id_from_gnb(dest_scfc_path)
        logging.info("Gnb vlan id is {}".format(vlan_id))
        new_scfc = self._copy_base_scfc_to_log_path(src_scfc, dest_scfc_path)
        scfc_mod = self._update_vlan_id_in_base_scfc(new_scfc, vlan_id)
        return scfc_mod

    def _get_vlan_id_from_gnb(self, dest_path):
        gnb_scfc = "{}{}".format(dest_path, 'scfc_admin_collect.xml')
        self._get_scfc_from_gnb(dest_path, 'scfc_admin_collect.xml')
        scf_obj = scf()
        scf_obj.load_scf(gnb_scfc)
        dist_name = 'MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1'
        return scf_obj.get_value_from_scf(dist_name=dist_name, p_name='vlanId')

    def _update_vlan_id_in_base_scfc(self, scfc_file, vlan_id):
        scfc_obj = scf()
        scfc_obj.load_scf(scfc_file)
        dist_name = 'MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1'
        scfc_obj.modify_scf_element(value=vlan_id, dist_name=dist_name, p_name='vlanId')
        scfc_mod = os.path.join(os.path.split(scfc_file)[0], 'scfc_mod_vlanid.xml')
        scfc_obj.save_scf(file_path=scfc_mod)
        return scfc_mod

    def _copy_base_scfc_to_log_path(self, src_scfc, dest_scfc_path):
        logging.info("src_scfc:{};dest_scfc_path:{}".format(src_scfc, dest_scfc_path))
        os.system("cp {} {}".format(src_scfc, dest_scfc_path))
        return os.path.join(dest_scfc_path, src_scfc.split("/")[-1])

    def _get_scfc_from_gnb(self, save_path, scfc_name):
        try:
            bts_coam = admin()
            connection = bts_coam.connect_to(admin_api_log_dir='/tmp/')
            bts_coam.get_current_scf_file(local_dir_path=save_path, file_name=scfc_name, connection=connection)
        finally:
            bts_coam.teardown()


class VranBase(Base):
    """Config Gnb to expected status for vran2.0
    """
    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        """"""
        self.ROBOT_LIBRARY_LISTENER = self

    def vdu_change_vlan_ids_in_scfc(self, src_scfc, dest_scfc_path, remote_host=None, **oam_vdu):
        tak_core().execute("mkdir -p {}".format(dest_scfc_path), remote_host)
        vlan_ids = self._get_vlan_ids_from_tl_config()
        logging.info("Vdu vlan ids:{}".format(vlan_ids))
        new_scfc = self._copy_base_scfc_to_log_path(src_scfc, dest_scfc_path)
        scfc_mod = self._update_vlan_ids_in_base_scfc(new_scfc, vlan_ids)
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


def change_vlan_id_in_scfc(src_scfc, dest_scfc_path):
    return Base().change_vlan_id_in_scfc(src_scfc, dest_scfc_path)


def vdu_change_vlan_ids_in_scfc(src_scfc, dest_scfc_path, **oam_vdu):
    return VranBase().vdu_change_vlan_ids_in_scfc(src_scfc, dest_scfc_path, None, **oam_vdu)
