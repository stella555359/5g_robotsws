# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:maintainer: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
"""

import re
from taf.config.scf import scf
from testsuite.migration.Hangzhou.resources.RAN_PZ_HAZ_34.python.scf.variable.frame_structure import (
    FRAME_STRUCTURE_CORRESPOND_DICTIONARY,
)

__all__ = ["ScfAnalysis"]


class ScfAnalysis(object):
    def __init__(self):
        self.scf_path = None
        self.scf = None
        self.mrbtsID = None
        self.nrbtsID = None

    def setup(self, scf_path):
        """
        sscf setup
        :param scf_path: String: scf file path
        """
        self.scf_path = scf_path
        self.scf = scf()
        self.scf.load_scf(self.scf_path)
        self.mrbtsID, self.nrbtsID = self.get_mrbtsid_and_nrbtsid()

    def get_matched_id(self, rule, xml):
        """
        filter id by regular rule
        :param rule: String: regular rule
        :param xml: String: scf file content
        :return: id: String: filter result
        """
        list = re.findall(rule, xml)
        id = ""
        id = id.join(list)
        return id

    def get_mrbtsid_and_nrbtsid(self):
        """
        filter mrbtsid and nrbtsid by regular rule
        :return: mrbtsid: String: filter result after MRBTS-
                 nrbtsid: String: filter result after NRBTS-
        """
        with open(self.scf_path, "r+") as f:
            xml = f.read()
            rule = r".*MRBTS\" distName=\"MRBTS-(.*?)\" version=\""
            mrbtsid = self.get_matched_id(rule=rule, xml=xml)
            rule = r".*NRBTS\" distName=\".*\/NRBTS-(.*?)\" version=\"NRBTS"
            nrbtsid = self.get_matched_id(rule=rule, xml=xml)
            return mrbtsid, nrbtsid

    def get_cell_network_type_from_scf(self, cell_id):
        """
        get cell and cell network mapping
        :param cell_id: String or Int: cell id
        :return: cell_network_mapping: Dict: mapping result
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        cell_network_mapping = {}
        celldeptype = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="cellDepType"
        )
        cell_network_mapping[cell_id] = celldeptype
        return cell_network_mapping

    def get_bwpDN_from_scf(self, cell_id, index=0):
        """
        get BWP name with cell
        :param cell_id: String or Int: cell id
        :param index: Int: cell id
        :return: bwpDN: String: MRBTS-x/NRBTS-x/BWP_PROFILE-x
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        bwpDN = self.scf.get_value_from_scf(
            dist_name=dist_name, list_name="cellBwpList", p_name="bwpDN", index=index
        )
        return bwpDN

    def get_band_from_scf(self, cell_id):
        """
        get cell band
        :param cell_id: String or Int: cell id
        :return: chbw.strip('MHz'): String: 20/40/50, ...
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        chbw = self.scf.get_value_from_scf(dist_name=dist_name, p_name="chBw")
        return chbw.strip("MHz")

    def get_prach_index_from_scf(self, cell_id):
        """
        get prach index
        :param cell_id: String or Int: cell id
        :return: prachConfigurationIndex: String: 97/98, ...
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        prachConfigurationIndex = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="prachConfigurationIndex"
        )
        return prachConfigurationIndex

    def get_beamset_num_from_scf(self, cell_id):
        """
        get beam num
        :param cell_id: String or Int: cell id
        :return: beamset_num: String: 2 beams
        """
        cellgrp_id = str(int(cell_id) - 1)
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELLGRP-"
            + cellgrp_id
        )
        beamset_num = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="numberOfTransmittedSsBlocks"
        )
        return beamset_num

    def get_nrcell_type_from_scf(self, cell_id):
        """
        get cell type
        :param cell_id: String or Int: cell id
        :return: nrCellType: String: 4DL2UL/2DL2UL, ...
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        nrCellType = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="nrCellType"
        )
        return nrCellType

    def get_dl_modulation_from_scf(self, cell_id):
        """
        get 256Qam enable status
        :param cell_id: String or Int: cell id
        :return: actDl256Qam: String: True/False
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        actDl256Qam = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="actDl256Qam"
        )
        return actDl256Qam

    def get_gnb_cu_type_from_scf(self):
        """
        get gNbCuType
        :param cell_id: String or Int: cell id
        :return: gNbCuType: String: NA/NSA/BOTH
        """
        dist_name = "MRBTS-" + self.mrbtsID + "/NRBTS-" + self.nrbtsID
        gNbCuType = self.scf.get_value_from_scf(dist_name=dist_name, p_name="gNbCuType")
        return gNbCuType

    def get_nrarfcn_from_scf(self, cell_id):
        """
        get nrarfcn
        :param cell_id: String or Int: cell id
        :return: nrarfcn: String: 633334, ...
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        nrarfcn = self.scf.get_value_from_scf(dist_name=dist_name, p_name="nrarfcn")
        return nrarfcn

    def get_gscn_from_scf(self, cell_id):
        """
        get gscn
        :param cell_id: String or Int: cell id
        :return: gscn: String: 633334, ...
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        gscn = self.scf.get_value_from_scf(dist_name=dist_name, p_name="gscn")
        return gscn

    def get_frame_structure_from_scf(
        self,
        cell_id,
        frame_structure_check_dictionary=FRAME_STRUCTURE_CORRESPOND_DICTIONARY,
    ):
        """
        get cell frame structure
        :param cell_id: String or Int: cell id
        :param frame_structure_check_dictionary: List: frame structure detail list
        :return: frame_structure: String: 1208_GP1_A1/1070_GP1_A3, ...
        """
        frame_structure_keys = [
            "frameStructureType",
            "guardPeriodLength",
            "lteToNrFrameShift",
            "tdLteUlDlConfig",
            "ulDlDataSlotRatio",
            "timingAdvanceOffset",
        ]
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        frame_structure_dict = {}
        for key in frame_structure_keys:
            try:
                value = self.scf.get_value_from_scf(dist_name=dist_name, p_name=key)
                frame_structure_dict[key] = value
            except Exception:
                continue
        frame_structure = ""
        for key, value in frame_structure_check_dictionary.items():
            keys = value.keys()
            flag = True
            for key_1 in keys:
                if (
                    key_1 in frame_structure_dict.keys()
                    and value[key_1] == frame_structure_dict[key_1]
                ):
                    flag = flag
                else:
                    flag = False
            if flag is True:
                frame_structure = key
        return frame_structure

    def get_dl_fdm_from_scf(self, cell_id):
        """
        get dl fdm
        :param cell_id: String or Int: cell id
        :return: dl_fdm: String: true/false
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        dl_fdm = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="actDlDataDmrsFdm"
        )
        return dl_fdm

    def get_ul_fdm_from_scf(self, cell_id):
        """
        get ul fdm
        :param cell_id: String or Int: cell id
        :return: ul_fdm: String: true/false
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        ul_fdm = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="actUlDataDmrsFdm"
        )
        return ul_fdm
