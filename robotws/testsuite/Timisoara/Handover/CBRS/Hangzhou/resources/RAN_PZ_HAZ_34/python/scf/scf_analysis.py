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
from taf.internal.scf import SCF
from testsuite.Timisoara.Handover.CBRS.Hangzhou.resources.RAN_PZ_HAZ_34.python.scf.variable.frame_structure import (
    FRAME_STRUCTURE_CORRESPOND_DICTIONARY,
)

__all__ = ["ScfAnalysis"]


class ScfAnalysis(object):
    def __init__(self):
        self.scf_path = None
        self.scf = None
        self._scf = None
        self.mrbtsID = None
        self.nrbtsID = None

    def setup(self, scf_path):
        """
        sscf setup
        :param scf_path: String: scf file path
        """
        self.scf_path = scf_path
        self.scf = scf()
        self._scf = SCF(scf_path=self.scf_path)
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
            rule = r".*MRBTS\" distName=\"MRBTS-(.*?)\" .*?version=\""
            mrbtsid = self.get_matched_id(rule=rule, xml=xml)
            rule = r".*NRBTS\" distName=\".*\/NRBTS-(.*?)\" .*?version=\"NRBTS"
            nrbtsid = self.get_matched_id(rule=rule, xml=xml)
            return mrbtsid, nrbtsid

    def get_cell_network_type_from_scf(self, cell_id):
        """
        get cell and cell network mapping
        :param cell_id: String or Int: cell id
        :return: celldeptype: string: cell network type
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        celldeptype = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="cellDepType"
        )
        return celldeptype

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
        return re.search(r"\d+", chbw).group(0)

    def get_actecpri72e_from_scf(self, cell_id):
        """
        Get actEcpri72e value from SCF.

        :param cell_id: String or Int: cell id
        :return: actEcpri72e: String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        return self.scf.get_value_from_scf(dist_name=dist_name, p_name="actEcpri72e")

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
        dist_name = self.get_cellgrp_distname_from_cell(cell_id=cell_id)
        beamset_num = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="numberOfTransmittedSsBlocks"
        )
        return beamset_num

    def get_basicBeamSet_from_scf(self, cell_id):
        """
        get basicBeamSet
        :param cell_id: String or Int: cell id
        :return: basicBeamSet: String: beamSet_2
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        basicBeamSet = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="basicBeamSet"
        )
        return basicBeamSet

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
        try:
            gscn = self.scf.get_value_from_scf(dist_name=dist_name, p_name="gscn")
        except Exception:
            gscn = self.scf.get_value_from_scf(
                dist_name=dist_name, p_name="gscnOrSsPbchArfcn"
            )
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

    def get_cellgrp_distname_from_cell(self, cell_id):
        """
        get ul fdm
        :param cell_id: String or Int: cell id
        :return: cellgrp_id: Int: cell group distname
        """
        all_mos = self._scf.raml.cmData.get_all_descendant_mos()
        patten = "MRBTS-" + self.mrbtsID + "/NRBTS-" + self.nrbtsID + "/NRCELLGRP-"
        cellgrp_distname_list = []
        for mo in all_mos:
            if patten in mo["distName"]:
                cellgrp_distname_list.append(mo["distName"])
        for cellgrp_distname in cellgrp_distname_list:
            if str(cell_id) in self.scf.get_all_values_from_scf(
                dist_name=cellgrp_distname, list_name="nrCellList"
            ):
                return cellgrp_distname

    def get_dl_dmrsadditionaliosition_from_scf(self, cell_id):
        """
        get dl dmrsadditionaliosition
        :param cell_id: String or Int: cell id
        :return: dl_dmrsadditionaliosition: String: true/false
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        dl_dmrsadditionaliosition = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="dlDMRSAdditionalPosition"
        )
        return dl_dmrsadditionaliosition

    def get_ul_dmrsadditionaliosition_from_scf(self, cell_id):
        """
        get ul dmrsadditionaliosition
        :param cell_id: String or Int: cell id
        :return: ul_dmrsadditionaliosition: String: true/false
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        ul_dmrsadditionaliosition = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="ulDMRSAdditionalPosition"
        )
        return ul_dmrsadditionaliosition

    def get_dl_ptrs_from_scf(self, cell_id):
        """
        get dl dmrsadditionaliosition
        :param cell_id: String or Int: cell id
        :return: actDlPtrs: String: true/false
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        actDlPtrs = self.scf.get_value_from_scf(dist_name=dist_name, p_name="actDlPtrs")
        return actDlPtrs

    def get_ul_ptrs_from_scf(self, cell_id):
        """
        get ul dmrsadditionaliosition
        :param cell_id: String or Int: cell id
        :return: actUlPtrs: String: true/false
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        actUlPtrs = self.scf.get_value_from_scf(dist_name=dist_name, p_name="actUlPtrs")
        return actUlPtrs

    def get_dlPtrsFreqDensityThresNrb0_from_scf(self, cell_id):
        """
        get dl dlPtrsFreqDensityThresNrb0
        :param cell_id: String or Int: cell id
        :return: dlPtrsFreqDensityThresNrb0: Int
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        dlPtrsFreqDensityThresNrb0 = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="dlPtrsFreqDensityThresNrb0"
        )
        return dlPtrsFreqDensityThresNrb0

    def get_dlPtrsFreqDensityThresNrb1_from_scf(self, cell_id):
        """
        get dlPtrsFreqDensityThresNrb1
        :param cell_id: String or Int: cell id
        :return: dlPtrsFreqDensityThresNrb1: Int
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        dlPtrsFreqDensityThresNrb1 = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="dlPtrsFreqDensityThresNrb1"
        )
        return dlPtrsFreqDensityThresNrb1

    def get_ulPtrsFreqDensityThresNrb0_from_scf(self, cell_id):
        """
        get ulPtrsFreqDensityThresNrb0
        :param cell_id: String or Int: cell id
        :return: ulPtrsFreqDensityThresNrb0: Int
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        ulPtrsFreqDensityThresNrb0 = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="ulPtrsFreqDensityThresNrb0"
        )
        return ulPtrsFreqDensityThresNrb0

    def get_ulPtrsFreqDensityThresNrb1_from_scf(self, cell_id):
        """
        get ulPtrsFreqDensityThresNrb1
        :param cell_id: String or Int: cell id
        :return: ulPtrsFreqDensityThresNrb1:  Int
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        ulPtrsFreqDensityThresNrb1 = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="ulPtrsFreqDensityThresNrb1"
        )
        return ulPtrsFreqDensityThresNrb1

    def get_scsSsb_from_scf(self, cell_id):
        """
        get ssbScs
        :param cell_id: String or Int: cell id
        :return: ssbScs:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        ssbScs = self.scf.get_value_from_scf(dist_name=dist_name, p_name="ssbScs")
        return re.search(r"\d+", ssbScs).group(0)

    def get_scs_from_scf(self, cell_id):
        """
        get scs
        :param cell_id: String or Int: cell id
        :return: scs:  String
        """
        dist_name = self.get_cellgrp_distname_from_cell(cell_id=cell_id)
        scs = self.scf.get_value_from_scf(dist_name=dist_name, p_name="scs")
        return re.search(r"\d+", scs).group(0)

    def get_type0CoresetConfigurationIndex_from_scf(self, cell_id):
        """
        get type0CoresetConfigurationIndex
        :param cell_id: String or Int: cell id
        :return: type0CoresetConfigurationIndex:  Int
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        type0CoresetConfigurationIndex = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="type0CoresetConfigurationIndex"
        )
        return type0CoresetConfigurationIndex

    def get_actBeamforming_from_scf(self, cell_id):
        """
        get actBeamforming
        :param cell_id: String or Int: cell id
        :return: actBeamforming:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        actBeamforming = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="actBeamforming"
        )
        return actBeamforming

    def get_actPerCsiReportBundlingTddFr1_from_scf(self, cell_id):
        """
        get actPerCsiReportBundlingTddFr1
        :param cell_id: String or Int: cell id
        :return: actPerCsiReportBundlingTddFr1:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        try:
            actPerCsiReportBundlingTddFr1 = self.scf.get_value_from_scf(
                dist_name=dist_name, p_name="actPerCsiReportBundlingTddFr1"
            )
        except Exception:
            actPerCsiReportBundlingTddFr1 = "False"
        return actPerCsiReportBundlingTddFr1

    def get_pucchF3ModulationScheme_from_scf(self, cell_id):
        """
        get pucchF3ModulationScheme
        :param cell_id: String or Int: cell id
        :return: pucchF3ModulationScheme:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        pucchF3ModulationScheme = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="pucchF3ModulationScheme"
        )
        return pucchF3ModulationScheme

    def get_dlMimoMode_from_scf(self, cell_id):
        """
        get dlMimoMode
        :param cell_id: String or Int: cell id
        :return: dlMimoMode:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        dlMimoMode = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="dlMimoMode"
        )
        return dlMimoMode

    def get_reqMinNumPuschPrb_from_scf(self, cell_id):
        """
        get reqMinNumPuschPrb
        :param cell_id: String or Int: cell id
        :return: reqMinNumPuschPrb:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        reqMinNumPuschPrb = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="reqMinNumPuschPrb"
        )
        return reqMinNumPuschPrb

    def get_pucchF3MaxCodeRate_from_scf(self, cell_id):
        """
        get pucchF3MaxCodeRate
        :param cell_id: String or Int: cell id
        :return: pucchF3MaxCodeRate:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        pucchF3MaxCodeRate = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="pucchF3MaxCodeRate"
        )
        num = re.search(r"\d+", pucchF3MaxCodeRate).group()
        pucchF3MaxCodeRate = int(num) / 100.0
        return pucchF3MaxCodeRate

    def get_srPeriodicity_from_scf(self, cell_id):
        """
        get srPeriodicity
        :param cell_id: String or Int: cell id
        :return: srPeriodicity:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        srPeriodicity = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="srPeriodicity"
        )
        return re.search(r"\d+", srPeriodicity).group(0)

    def get_ulMimoMode_from_scf(self, cell_id):
        """
        get ulMimoMode
        :param cell_id: String or Int: cell id
        :return: ulMimoMode:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        ulMimoMode = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="ulMimoMode"
        )
        return ulMimoMode

    def get_numberOfRxBeamforming_from_scf(self, cell_id):
        """
        get numberOfRxBeamforming
        :param cell_id: String or Int: cell id
        :return: numberOfRxBeamforming:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        numberOfRxBeamforming = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="numberOfRxBeamforming"
        )
        return numberOfRxBeamforming

    def get_msg1FrequencyStart_from_scf(self, cell_id):
        """
        get msg1FrequencyStart
        :param cell_id: String or Int: cell id
        :return: msg1FrequencyStart:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        msg1FrequencyStart = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="msg1FrequencyStart"
        )
        return msg1FrequencyStart

    def get_actLongPucchF1F3BfOnOranExtT6_from_scf(self, cell_id):
        """
        get actLongPucchF1F3BfOnOranExtT6
        :param cell_id: String or Int: cell id
        :return: actLongPucchF1F3BfOnOranExtT6:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        try:
            actLongPucchF1F3BfOnOranExtT6 = self.scf.get_value_from_scf(
                dist_name=dist_name, p_name="actLongPucchF1F3BfOnOranExtT6"
            )
        except Exception:
            actLongPucchF1F3BfOnOranExtT6 = "False"
        return actLongPucchF1F3BfOnOranExtT6

    def get_nrBtsBeamRefinementP2_from_scf(self, cell_id):
        """
        get nrBtsBeamRefinementP2
        :param cell_id: String or Int: cell id
        :return: nrBtsBeamRefinementP2:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        try:
            nrBtsBeamRefinementP2 = self.scf.get_value_from_scf(
                dist_name=dist_name, p_name="nrBtsBeamRefinementP2"
            )
        except Exception:
            nrBtsBeamRefinementP2 = "False"
        return nrBtsBeamRefinementP2

    def get_actLongPucchPhase2_from_scf(self, cell_id):
        """
        get actLongPucchPhase2
        :param cell_id: String or Int: cell id
        :return: actLongPucchPhase2:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        try:
            actLongPucchPhase2 = self.scf.get_value_from_scf(
                dist_name=dist_name, p_name="actLongPucchPhase2"
            )
        except Exception:
            actLongPucchPhase2 = "False"
        return actLongPucchPhase2

    def get_csiReportPeriodicity_from_scf(self, cell_id):
        """
        get csiReportPeriodicity
        :param cell_id: String or Int: cell id
        :return: csiReportPeriodicity:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        csiReportPeriodicity = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="csiReportPeriodicity"
        )
        return re.search(r"\d+", csiReportPeriodicity).group(0)

    def get_cellTechnology_from_scf(self, cell_id):
        """
        get cellTechnology
        :param cell_id: String or Int: cell id
        :return: cellTechnology:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        cellTechnology = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="cellTechnology"
        )
        return cellTechnology

    def get_actMultipleDedicatedBWPs_from_scf(self):
        """
        get actMultipleDedicatedBWPs
        :return: actMultipleDedicatedBWPs:  String
        """
        dist_name = "MRBTS-" + self.mrbtsID + "/NRBTS-" + self.nrbtsID
        try:
            actMultipleDedicatedBWPs = self.scf.get_value_from_scf(
                dist_name=dist_name, p_name="actMultipleDedicatedBWPs"
            )
        except Exception:
            actMultipleDedicatedBWPs = "False"
        return actMultipleDedicatedBWPs

    def get_actUlSrsBm_from_scf(self, cell_id):
        """
        get actUlSrsBm
        :return: actUlSrsBm:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        try:
            actUlSrsBm = self.scf.get_value_from_scf(
                dist_name=dist_name, p_name="actUlSrsBm"
            )
        except Exception:
            actUlSrsBm = "False"
        return actUlSrsBm

    def get_pucchModeSelect_from_scf(self, cell_id):
        """
        get pucchModeSelect
        :return: pucchModeSelect:  String,longPucch/shortPucch
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        pucchModeSelect = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="pucchModeSelect"
        )
        return pucchModeSelect

    def get_dlQam256PowerBackoffSub6_from_scf(self, cell_id):
        """
        get dlQam256PowerBackoffSub6
        :param cell_id: String or Int: cell id
        :return: pucchModeSelect:  String,longPucch/shortPucch
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        dlQam256PowerBackoffSub6 = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="dlQam256PowerBackoffSub6"
        )
        return dlQam256PowerBackoffSub6

    def get_pMax_from_scf(self, cell_id):
        """
        get pMax
        :param cell_id: String or Int: cell id
        :return: pMax:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        pMax = self.scf.get_value_from_scf(dist_name=dist_name, p_name="pMax")
        return pMax

    def get_physCellId_from_scf(self, cell_id):
        """
        get pMax
        :param cell_id: String or Int: cell id
        :return: physCellId:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        physCellId = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="physCellId"
        )
        return physCellId

    def generate_cell_info_list_from_scf(self, cell_mapping):
        """
        get pMax
        :param cell_mapping: Dict: A dictionary with cell_index as key and other ids as value
        :return: cell_info_list: List, cell_info_list: ["cell_id": *, "frame_structure": *, "bandwidth"*]
        """
        cell_info_list = []
        for cell_id in cell_mapping.keys():
            cell = cell_mapping[cell_id]["nrCellIdentity"]
            frame_structure = self.get_frame_structure_from_scf(cell_id=cell_id)
            bandwidth = self.get_band_from_scf(cell_id=cell_id)
            bandwidth = "{}MHz".format(bandwidth)
            nrcelltype = self.get_nrcell_type_from_scf(cell_id=cell_id)
            actec72e = self.get_actecpri72e_from_scf(cell_id=cell_id)
            technology = cell_mapping[cell_id]["technology"]
            cell_info = {
                "cell_id": cell,
                "frame_structure": frame_structure,
                "bandwidth": bandwidth,
                "technology": technology,
                "gene": "5G",
                "nrcelltype": nrcelltype,
                "actec": "7-2e" if actec72e == "true" else "7-2a",
            }
            cell_info_list.append(cell_info)
        return cell_info_list

    def get_actDynUlResAlloc_from_scf(self, cell_id):
        """
        get actDynUlResAlloc
        :param cell_id: String or Int: cell id
        :return: actDynUlResAlloc:  true/false
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        actDynUlResAlloc = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="actDynUlResAlloc"
        )
        return actDynUlResAlloc

    def get_actConnRrcPooling_from_scf(self):
        """
        get actConnRrcPooling
        :param cell_id: String or Int: cell id
        :return: actConnRrcPooling:  true/false
        """
        dist_name = "MRBTS-" + self.mrbtsID + "/NRBTS-" + self.nrbtsID
        actConnRrcPooling = self.scf.get_value_from_scf(
            dist_name=dist_name, p_name="actConnRrcPooling"
        )
        return actConnRrcPooling

    def get_actLongPucchResourceOpt_from_scf(self, cell_id):
        """
        get actLongPucchResourceOpt
        :return: actLongPucchResourceOpt:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        try:
            actLongPucchResourceOpt = self.scf.get_value_from_scf(
                dist_name=dist_name, p_name="actLongPucchResourceOpt"
            )
        except Exception:
            actLongPucchResourceOpt = "false"
        return actLongPucchResourceOpt

    def get_actSharedSr_from_scf(self, cell_id):
        """
        get actSharedSr
        :return: actSharedSr:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        try:
            actSharedSr = self.scf.get_value_from_scf(
                dist_name=dist_name, p_name="actSharedSr"
            )
        except Exception:
            actSharedSr = "false"
        return actSharedSr

    def get_pucchF1ResOccConf_from_scf(self, cell_id):
        """
        get pucchF1ResOccConf
        :return: pucchF1ResOccConf:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        try:
            pucchF1ResOccConf = self.scf.get_value_from_scf(
                dist_name=dist_name, p_name="pucchF1ResOccConf"
            )
        except Exception:
            pucchF1ResOccConf = "false"
        return pucchF1ResOccConf

    def get_actDynPdcchTd_from_scf(self, cell_id):
        """
        get actDynPdcchTd
        :return: actDynPdcchTd:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        try:
            actDynPdcchTd = self.scf.get_value_from_scf(
                dist_name=dist_name, p_name="actDynPdcchTd"
            )
        except Exception:
            actDynPdcchTd = "false"
        return actDynPdcchTd

    def get_actDynPdcchTdMode_from_scf(self, cell_id):
        """
        get actDynPdcchTdMode
        :return: actDynPdcchTdMode:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        try:
            actDynPdcchTdMode = self.scf.get_value_from_scf(
                dist_name=dist_name, p_name="actDynPdcchTdMode"
            )
        except Exception:
            actDynPdcchTdMode = "false"
        return actDynPdcchTdMode

    def get_actBbPoolTddFr1_from_scf(self):
        """
        get actBbPoolTddFr1
        :return: actBbPoolTddFr1:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
        )
        try:
            actBbPoolTddFr1 = self.scf.get_value_from_scf(
                dist_name=dist_name, p_name="actBbPoolTddFr1"
            )
        except Exception:
            actBbPoolTddFr1 = "false"
        return actBbPoolTddFr1

    def get_pucchNumberHarqAnPrbs_from_scf(self, cell_id):
        """
        get pucchNumberHarqAnPrbs
        :return: pucchNumberHarqAnPrbs:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        try:
            pucchNumberHarqAnPrbs = self.scf.get_value_from_scf(
                dist_name=dist_name, p_name="pucchNumberHarqAnPrbs"
            )
        except Exception:
            pucchNumberHarqAnPrbs = "none"
        return pucchNumberHarqAnPrbs

    def get_limitedBeamsPerStreamPerSlot_from_scf(self, cell_id):
        """
        get limitedBeamsPerStreamPerSlot
        :return: limitedBeamsPerStreamPerSlot:  String
        """
        dist_name = (
            "MRBTS-"
            + self.mrbtsID
            + "/NRBTS-"
            + self.nrbtsID
            + "/NRCELL-"
            + str(cell_id)
        )
        try:
            limitedBeamsPerStreamPerSlot = self.scf.get_value_from_scf(
                dist_name=dist_name, p_name="limitedBeamsPerStreamPerSlot"
            )
        except Exception:
            limitedBeamsPerStreamPerSlot = "none"
        return limitedBeamsPerStreamPerSlot
