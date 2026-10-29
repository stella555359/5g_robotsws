# -*- coding: utf-8 -*-
"""
2022/05/25 first version by @author: xiang.5.li@nokia-sbell.com
2022/05/25 TDRA checker for feature CB007601 Read rrc info from egate console log, use on AirPhone testline
2022/05/xx add read rrc info from X2 log use for keysight testline.
"""

import os
from testsuite.Beijing.ET.common.resources.lib.logger_et import LoggingEt
from testsuite.Beijing.ET.common.resources.lib.xml_file import ReadGnbScf
from testsuite.Beijing.ET.common.resources.lib.egate_file import ReadEgateByMessage
from testsuite.Beijing.ET.common.resources.lib.exception_et import RaiseExceptionEt
from testsuite.Beijing.ET.common.resources.lib.text_file import ReadPcapMessage

# os.chdir(sys.path[0])
"""
Following three lines about root have been commented because of ute cloud dry run
root =
root in
root in
"""


# add root folder before sys.path
# root = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))
# root in sys.path and sys.path.remove(root)
# root in sys.path or sys.path.insert(0, root)


class TdraChecker(object):
    def __init__(self, log_path='', scf_file='', egate_file='', x2_file=''):
        self.log_path = log_path
        self.scf_file = scf_file
        self.egate_file = egate_file
        self.x2_file = x2_file
        __logger_name = os.path.basename(__file__)
        self.log = LoggingEt(self.log_path, __logger_name).log()
        self.raise_exception = RaiseExceptionEt(self.log_path)
        self.scf_nrccell_1, self.scf_nrcellgrp_0, self.egate_rrc_cfg = None, None, None
        self.sliv9, self.sliv10, self.sliv11, self.sliv12, self.sliv13, self.sliv14 = \
            [99, 86], [96, 100], [82, 95], [68, 81], [54, 67], [40, 53]
        self.sliv_inverse = {'99': [1, 8], '86': [2, 7], '96': [1, 9], '100': [2, 8],
                             '82': [1, 10], '95': [2, 9], '68': [1, 11], '81': [2, 10],
                             '54': [1, 12], '67': [2, 11], '40': [1, 13], '53': [2, 12]}
        self.tdra_common_7601 = {"automatic": {"bi10": self.sliv13 + self.sliv14,
                                               "bi6": self.sliv13 + self.sliv14,
                                               "dl14_bi10": self.sliv13 + self.sliv14,
                                               "dl14_bi6": self.sliv13 + self.sliv14},
                                 "manual": {"bi10": self.sliv14,
                                            "bi6": self.sliv14,
                                            "dl14_primary_bi10": self.sliv14,
                                            "dl14_secondary_bi10": self.sliv13 + self.sliv14,
                                            "dl14_primary_bi6": self.sliv14,
                                            "dl14_secondary_bi6": self.sliv13 + self.sliv14, }}
        self.tdra_dedicate_7601 = {"automatic": {"bi10": self.sliv13 + self.sliv14 + self.sliv10 + self.sliv9,
                                                 "bi6": self.sliv13 + self.sliv14,
                                                 "dl14_bi10": self.sliv13 + self.sliv14 + self.sliv10,  # sliv9
                                                 "dl14_bi6": self.sliv13 + self.sliv14 + self.sliv10},  # sliv9
                                   "manual": {"bi10": self.sliv14 + self.sliv10,  # if first start symbole is 9 or sliv9
                                              "bi6": self.sliv14,
                                              "dl14_primary_bi10_sch": self.sliv14 + self.sliv13 + self.sliv10,  # sliv9
                                              "dl14_primary_bi10_nonsch": self.sliv14 + self.sliv10,
                                              "dl14_secondary_bi10": self.sliv13 + self.sliv14 + self.sliv10,  # sliv9
                                              "dl14_primary_bi6_sch": self.sliv14 + self.sliv13,
                                              "dl14_primary_bi6_non_sch": self.sliv14,
                                              "dl14_secondary_bi6": self.sliv13 + self.sliv14, }}
        self.tdra_common_8534_4ssb = {"automatic": {"bi10": self.sliv12 + self.sliv14,
                                                    "bi6": self.sliv12 + self.sliv14,
                                                    "dl14_bi10": self.sliv12 + self.sliv14,
                                                    "dl14_bi6": self.sliv12 + self.sliv14},
                                      "manual": {"bi10": self.sliv14,
                                                 "bi6": self.sliv14,
                                                 "dl14_primary_bi10": self.sliv14,
                                                 "dl14_secondary_bi10": self.sliv12 + self.sliv14,
                                                 "dl14_primary_bi6": self.sliv14,
                                                 "dl14_secondary_bi6": self.sliv12 + self.sliv14}}
        self.tdra_dedicate_8534_4ssb = {"automatic": {"bi10": self.sliv12 + self.sliv14 + self.sliv10,  # sliv9
                                                      "bi6": self.sliv12 + self.sliv14,  # sliv9
                                                      "dl14_bi10": self.sliv12 + self.sliv14 + self.sliv10,  # sliv9
                                                      "dl14_bi6": self.sliv12 + self.sliv14},  # sliv9
                                        "manual": {"bi10": self.sliv14 + self.sliv10,  # sliv9
                                                   "bi6": self.sliv14,
                                                   "dl14_primary_bi10_sch": self.sliv14 + self.sliv12 + self.sliv10,
                                                   # sliv9
                                                   "dl14_primary_bi10_nonsch": self.sliv14 + self.sliv10,
                                                   "dl14_secondary_bi10": self.sliv12 + self.sliv14 + self.sliv10,
                                                   # sliv9
                                                   "dl14_primary_bi6_sch": self.sliv14 + self.sliv12,  # sliv9
                                                   "dl14_primary_bi6_non_sch": self.sliv14,
                                                   "dl14_secondary_bi6": self.sliv12 + self.sliv14}}  # sliv9
        self.tdra_common_8534_6ssb = {"automatic": {"bi10": self.sliv12 + self.sliv14 + self.sliv13 + self.sliv10,
                                                    "bi6": self.sliv12 + self.sliv14 + self.sliv13 + self.sliv10,
                                                    "dl14_bi10": self.sliv12 + self.sliv14 + self.sliv13 + self.sliv10,
                                                    "dl14_bi6": self.sliv12 + self.sliv14 + self.sliv13 + self.sliv10},
                                      "manual": {"bi10": self.sliv14 + self.sliv13,
                                                 "bi6": self.sliv14 + self.sliv13,
                                                 "dl14_primary_bi10": self.sliv14 + self.sliv13,
                                                 "dl14_secondary_bi10":
                                                     self.sliv12 + self.sliv14 + self.sliv13 + self.sliv10,
                                                 "dl14_primary_bi6": self.sliv14 + self.sliv13,
                                                 "dl14_secondary_bi6":
                                                     self.sliv12 + self.sliv14 + self.sliv13 + self.sliv10}}
        self.tdra_dedicate_8534_6ssb = {
            "automatic": {"bi10": self.sliv12 + self.sliv14 + self.sliv13 + self.sliv10 + self.sliv9,
                          "bi6": self.sliv12 + self.sliv14 + self.sliv13 + self.sliv10,  # sliv9
                          "dl14_bi10": self.sliv12 + self.sliv14 + self.sliv13 + self.sliv10,  # sliv9
                          "dl14_bi6": self.sliv12 + self.sliv14 + self.sliv13 + self.sliv10},  # sliv9
            "manual": {"bi10": self.sliv14 + self.sliv13 + self.sliv10 + self.sliv9,
                       "bi6": self.sliv14 + self.sliv13,
                       "dl14_primary_bi10_sch": self.sliv14 + self.sliv13 + self.sliv12 + self.sliv10 + self.sliv9,
                       "dl14_primary_bi10_nonsch": self.sliv14 + self.sliv13 + self.sliv10 + self.sliv9,
                       "dl14_secondary_bi10": self.sliv14 + self.sliv13 + self.sliv12 + self.sliv10 + self.sliv9,
                       "dl14_primary_bi6_sch": self.sliv14 + self.sliv13 + self.sliv12 + self.sliv10,  # sliv9
                       "dl14_primary_bi6_non_sch": self.sliv14 + self.sliv13,
                       "dl14_secondary_bi6": self.sliv12 + self.sliv14 + self.sliv13 + self.sliv10}}  # sliv9

        self.auto_manual = None
        self.bi = None
        self.bi_slot = None
        self.csi_rs_period = None
        self.csi_rs_offset = None
        self.csi_rs_first_symbol = None
        self.ssb_blocks = None
        self.ssb_period = None
        self.ssb_offset = None
        self.trs_period = None
        self.trs_offset = []
        self.act_pdsch_ssb = None
        self.act_pdsch_trs = None
        self.bl14 = None
        self.primary_secondary = ''
        self.sch = ''
        self.report_common = []
        self.report_dedicate = []
        self.calc_common = []
        self.calc_dedicate = []
        self.sliv_key_common = ''
        self.sliv_key_dedicate = ''

        self.x2_info = []

        self.common_ok_cnt = 0
        self.common_error_cnt = 0
        self.dedicate_ok_cnt = 0
        self.dedicate_error_cnt = 0

    def get_scf_parameters(self):
        managedObject_distName = "MRBTS-1/NRBTS-1/NRCELL-1"
        paras = ["actCellCsirsTddOnSsbBf", "actCellCsiRsImTddNonBf", "cellCsiRsImLocationMode",
                 "actPdschAtSsbSlots", "actPdschRmCsirsForTracking",
                 "frameStructureType", "guardPeriodLength", "ulDlDataSlotRatio"]
        scf_obj = ReadGnbScf(self.log_path, self.scf_file, managedObject_distName, paras)
        self.scf_nrccell_1 = scf_obj.parser_scf_by_managed()
        self.log.info("scf_nrccell_1:%s" % self.scf_nrccell_1)
        managedObject_distName = "MRBTS-1/NRBTS-1/NRCELLGRP-0"
        paras = ["numberOfTransmittedSsBlocks", "ssBurstSetPeriod", "scs"]
        scf_obj = ReadGnbScf(self.log_path, self.scf_file, managedObject_distName, paras)
        self.scf_nrcellgrp_0 = scf_obj.parser_scf_by_managed()
        self.log.info("scf_nrcellgrp_0:%s" % self.scf_nrcellgrp_0)

    def get_egate_parameters(self):
        message_head = 'value RRCReconfiguration ::='
        anchor = ["nzp-CSI-RS-ResourceToAddModList", "pdsch-ConfigCommon", "pdsch-Config"]
        paras = ["nzp-CSI-RS-ResourceId", "periodicityAndOffset", "firstOFDMSymbolInTimeDomain", "startSymbolAndLength"]
        egate_obj = ReadEgateByMessage(log_path=self.log_path, egateFile=self.egate_file, message_head=message_head,
                                       anchor=anchor, paras=paras)
        self.egate_rrc_cfg = egate_obj.parser_egate_file()
        self.log.info("self.egate_rrc_cfg:%s" % (self.egate_rrc_cfg))

    def get_x2_parameters(self):
        message_anchor_paras = {
            "SgNBAdditionRequestAcknowledge": {
                "nzp-CSI-RS-ResourceToAddModList":
                    ["nzp-CSI-RS-ResourceId", "firstOFDMSymbolInTimeDomain", "periodicityAndOffset"],
                "pdsch-ConfigCommon: setup (1)": ["startSymbolAndLength##common"],
                "pdsch-Config: setup (1)": ['startSymbolAndLength##dedicate']
            }
        }
        if self.x2_file:
            self.x2_parser = ReadPcapMessage(self.log_path, self.x2_file, message_anchor_paras)
        self.x2ap_info = self.x2_parser.parser_pcap_file()
        self.log.info("x2 pcap:%s" % self.x2ap_info)

    def is_feature_7601(self):
        if "actCellCsiRsImTddNonBf" in self.scf_nrccell_1:
            if self.scf_nrccell_1['actCellCsiRsImTddNonBf'] == 'true':
                return True
            else:
                return False
        else:
            self.raise_exception.case_fail("Not find scf parameters:actCellCsiRsImTddNonBf!")
            return None

    def is_csi_rs_mode_automatic(self):
        if "cellCsiRsImLocationMode" in self.scf_nrccell_1:
            if self.scf_nrccell_1['cellCsiRsImLocationMode'] == 'automatic':
                return True
            else:
                return False
        else:
            self.raise_exception.case_fail("Not find scf parameters:cellCsiRsImLocationMode!")
            return None

    def is_7601_1ssb(self):
        if "numberOfTransmittedSsBlocks" in self.scf_nrcellgrp_0:
            if self.scf_nrcellgrp_0['numberOfTransmittedSsBlocks'] in ['1 beam', '2 beam']:
                return True
            else:
                return False
        else:
            self.raise_exception.case_fail("Not find scf parameters:numberOfTransmittedSsBlocks!")

    def is_8534_2ssb(self):
        if "numberOfTransmittedSsBlocks" in self.scf_nrcellgrp_0:
            if self.scf_nrcellgrp_0['numberOfTransmittedSsBlocks'] in ['1 beam', '2 beam']:
                return True
            else:
                return False
        else:
            self.raise_exception.case_fail("Not find scf parameters:numberOfTransmittedSsBlocks!")

    def is_8534_4ssb(self):
        if "numberOfTransmittedSsBlocks" in self.scf_nrcellgrp_0:
            if self.scf_nrcellgrp_0['numberOfTransmittedSsBlocks'] == '2 beams':
                return True
            else:
                return False
        else:
            self.raise_exception.case_fail("Not find scf parameters:numberOfTransmittedSsBlocks!")

    def is_8534_4ssb(self):
        if "numberOfTransmittedSsBlocks" in self.scf_nrcellgrp_0:
            if self.scf_nrcellgrp_0['numberOfTransmittedSsBlocks'] == '4 beams':
                return True
            else:
                return False
        else:
            self.raise_exception.case_fail("Not find scf parameters:numberOfTransmittedSsBlocks!")

    def is_8534_6ssb(self):
        if "numberOfTransmittedSsBlocks" in self.scf_nrcellgrp_0:
            if self.scf_nrcellgrp_0['numberOfTransmittedSsBlocks'] in '6 beams':
                return True
            else:
                return False
        else:
            self.raise_exception.case_fail("Not find scf parameters:numberOfTransmittedSsBlocks!")

    def is_csi_rs_mode_automatic(self):
        if "cellCsiRsImLocationMode" in self.scf_nrccell_1:
            if self.scf_nrccell_1['cellCsiRsImLocationMode'] == "automatic":
                return True
            else:
                return False
        else:
            self.raise_exception.case_fail("Not find scf parameters:numberOfTransmittedSsBlocks!")

    def tdd_frame_structure2bi(self):
        """
        get info from frame structure.
        BI10,BI6, DL14
        BI slot allocation.
        :return:
        """
        frame_structure_type = self.scf_nrccell_1['frameStructureType']
        guard_period_length = self.scf_nrccell_1['guardPeriodLength']
        uldl_data_slot_ratio = self.scf_nrccell_1['ulDlDataSlotRatio']
        if guard_period_length == '2Symbols':
            self.bi = 'bi10'
        elif guard_period_length == '4Symbols':
            self.bi = 'bi6'
        if frame_structure_type == "semiStatic":
            if uldl_data_slot_ratio == '1/4':
                self.bi_slot = [3, 8]
            elif uldl_data_slot_ratio == '3/7':
                self.bi_slot = [3, 7]
        elif frame_structure_type == "tdLte":
            self.bi_slot = [3]
        self.log.info("BI slot:%s" % self.bi_slot)

    def csi_rs_cfg(self):
        """get the csi-rs config from egate log."""
        period_offset = self.egate_rrc_cfg['nzp-CSI-RS-ResourceToAddModList'][0]['periodicityAndOffset'][0].split(':')
        self.csi_rs_period = int(period_offset[0][5:])
        self.csi_rs_offset = int(period_offset[1]) % 10
        self.csi_rs_first_symbol = int(
            self.egate_rrc_cfg['nzp-CSI-RS-ResourceToAddModList'][0]['firstOFDMSymbolInTimeDomain'][0])
        self.log.info("csi-rs period:%s, offset:%s, first_symobl:%s" %
                      (self.csi_rs_period, self.csi_rs_offset, self.csi_rs_first_symbol))

    def csi_rs_cfg_x2(self):
        """Get the csi-rs config from x2 log."""
        period_offset = self.x2ap_info[0]['periodicityAndOffset'][0].split(':')
        self.csi_rs_period = int(period_offset[0][5:])
        self.csi_rs_offset = int(period_offset[1]) % 10
        self.csi_rs_first_symbol = int(self.x2ap_info[0]['firstOFDMSymbolInTimeDomain'][0])
        self.log.info("csi-rs period:%s, offset:%s, first_symobl:%s" %
                      (self.csi_rs_period, self.csi_rs_offset, self.csi_rs_first_symbol))

    def ssb_cfg(self):
        ssb_scs = int(self.scf_nrcellgrp_0['scs'].split(' ')[0])
        ssb_period = int(self.scf_nrcellgrp_0['ssBurstSetPeriod'])
        self.ssb_period = int(ssb_period * int(ssb_scs / 15))
        self.ssb_blocks = int(self.scf_nrcellgrp_0['numberOfTransmittedSsBlocks'].split(' ')[0])
        self.ssb_offset = [i for i in range(int((self.ssb_blocks + 1) / 2))]
        self.log.info("ssb config, numberOfTransmittedSsBlocks:%s, ssBurstSetPeriod:%s, offset:%s" %
                      (self.ssb_blocks, self.ssb_period, self.ssb_offset))

    def trs_cfg(self):
        period_offset = self.egate_rrc_cfg['nzp-CSI-RS-ResourceToAddModList'][0]['periodicityAndOffset'][1:]
        self.trs_period = int(period_offset[0].split(':')[0][5:])
        for item in period_offset:
            offset = int(item.split(':')[1])
            if offset not in self.trs_offset:
                self.trs_offset.append(offset % 10)
        self.log.info("trs cfg, period:%s, offset:%s" % (self.trs_period, self.trs_offset))

    def trs_cfg_x2(self):
        """Get the trs config from x2 log."""
        csi_rs_cnt = 0
        for resource_id in self.x2ap_info[0]['nzp-CSI-RS-ResourceId']:
            if resource_id == "2":
                break
            else:
                csi_rs_cnt += 1
        # if self.is_8534_6ssb():
        #     period_offset = self.x2ap_info[0]['periodicityAndOffset'][4:]
        # else:
        #     period_offset = self.x2ap_info[0]['periodicityAndOffset'][1:]
        period_offset = self.x2ap_info[0]['periodicityAndOffset'][csi_rs_cnt:]
        self.trs_period = int(period_offset[0].split(':')[0][5:])
        for item in period_offset:
            offset = int(item.split(':')[1])
            if offset not in self.trs_offset:
                self.trs_offset.append(offset % 10)
        self.log.info("trs cfg x2, period:%s, offset:%s" % (self.trs_period, self.trs_offset))

    def act_pdsch_cfg(self):
        self.act_pdsch_ssb = self.scf_nrccell_1['actPdschAtSsbSlots']
        self.act_pdsch_trs = self.scf_nrccell_1['actPdschRmCsirsForTracking']

    def is_dl14(self):
        """
        if true:
            self.dl14 = 'dl14_'
        else:
            self.dl14 = ''
        :return:
        """
        if self.csi_rs_offset in self.bi_slot:
            self.dl14 = ''
        else:
            self.dl14 = 'dl14'

    def primary_secondary_select(self):
        self.primary_secondary = "secondary"
        if (self.trs_period <= self.csi_rs_period and self.csi_rs_offset in self.trs_offset) or \
                (self.ssb_period <= self.csi_rs_period and self.csi_rs_offset in self.ssb_offset):
            self.primary_secondary = "primary"

    def is_schedule(self):
        if self.act_pdsch_trs == 'true' and self.act_pdsch_ssb == 'true':
            self.sch = 'sch'
        else:
            self.sch = 'nonsch'

    def sliv_report(self):
        """Get sliv cfg from egate log."""
        self.report_common = [int(x) for x in self.egate_rrc_cfg['pdsch-ConfigCommon'][0]['startSymbolAndLength']]
        self.report_dedicate = [int(x) for x in self.egate_rrc_cfg['pdsch-Config'][0]['startSymbolAndLength']]
        self.log.info("gnb report common sliv egate:%s, dedicate sliv:%s" % (self.report_common, self.report_dedicate))

    def sliv_report_x2(self):
        """Get sliv cfg from x2 log."""
        length_com = len(self.x2ap_info[0]['startSymbolAndLength##common'])
        self.report_common = [int(x) for x in self.x2ap_info[0]['startSymbolAndLength##common']][0: int(length_com / 2)]
        self.report_dedicate = [int(x) for x in self.x2ap_info[0]['startSymbolAndLength##dedicate']]
        self.log.info("gnb report common sliv x2:%s, dedicate sliv:%s" % (self.report_common, self.report_dedicate))

    def generate_sliv_key_common(self):
        self.sliv_key_common = ''
        if self.auto_manual == "automatic":
            if self.dl14:
                self.sliv_key_common = self.dl14 + "_"
            if self.bi:
                self.sliv_key_common += self.bi
        elif self.auto_manual == "manual":
            if self.dl14:
                self.sliv_key_common = self.dl14 + "_"
                if self.primary_secondary:
                    self.sliv_key_common += self.primary_secondary + '_'
                if self.bi:
                    self.sliv_key_common += self.bi
            else:
                self.sliv_key_common = self.bi
        if self.sliv_key_common.endswith("_"):
            self.sliv_key_common = self.sliv_key[:-1]
        self.log.info("sliv key common:%s" % self.sliv_key_common)

    def generate_sliv_key_dedicate(self):
        self.sliv_key_dedicate = ''
        if self.auto_manual == "automatic":
            if self.dl14:
                self.sliv_key_dedicate = self.dl14 + "_"
            if self.bi:
                self.sliv_key_dedicate += self.bi
        if self.auto_manual == "manual":
            if self.dl14:
                self.sliv_key_dedicate = self.dl14 + "_"
                if self.primary_secondary:
                    self.sliv_key_dedicate += self.primary_secondary + "_"
                if self.bi:
                    self.sliv_key_dedicate += self.bi + "_"
                if self.sch and self.primary_secondary == "primary":
                    self.sliv_key_dedicate += self.sch
            else:
                self.sliv_key_dedicate = self.bi
        if self.sliv_key_dedicate.endswith("_"):
            self.sliv_key_dedicate = self.sliv_key_dedicate[:-1]
        self.log.info("sliv key dedicate:%s" % self.sliv_key_dedicate)

    def set_test_parameters(self):
        self.act_pdsch_trs = 'true'
        self.auto_manual = "manual"
        self.dl14 = 'dl14'
        self.bi = 'bi10'
        self.primary_secondary = 'primary'
        self.sch = "sch"

    def sliv_calc_7601(self):
        if self.auto_manual == "automatic":
            self.calc_common = self.tdra_common_7601[self.auto_manual][self.sliv_key_common]
            self.calc_dedicate = self.tdra_dedicate_7601[self.auto_manual][self.sliv_key_dedicate]
            if self.act_pdsch_trs == 'true' and self.dl14 == 'dl14':
                self.calc_dedicate += self.sliv9
        elif self.auto_manual == "manual":
            self.calc_common = self.tdra_common_7601[self.auto_manual][self.sliv_key_common]
            self.calc_dedicate = self.tdra_dedicate_7601[self.auto_manual][self.sliv_key_dedicate]
            if self.sliv_key_dedicate == "bi10" and self.csi_rs_first_symbol == 9:
                self.calc_dedicate = self.calc_dedicate + self.sliv9
            if self.act_pdsch_trs == 'true':
                if self.sliv_key_dedicate in ["dl14", "dl14_primary_bi10_sch", "dl14_secondary_bi10"]:
                    self.calc_dedicate = self.calc_dedicate + self.sliv9
                if self.sliv_key_dedicate == "bi10" and self.csi_rs_first_symbol < 9:
                    self.calc_dedicate = self.calc_dedicate + self.sliv9
        self.log.info("calc sliv, common sliv:%s, dedicate sliv:%s" % (self.calc_common, self.calc_dedicate))

    def sliv_calc_8534_4ssb(self):
        if self.auto_manual == "automatic":
            self.calc_common = self.tdra_common_8534_4ssb[self.auto_manual][self.sliv_key_common]
            self.calc_dedicate = self.tdra_dedicate_8534_4ssb[self.auto_manual][self.sliv_key_dedicate]
            if self.act_pdsch_trs == 'true':
                self.calc_dedicate += self.sliv9
        elif self.auto_manual == "manual":
            self.calc_common = self.tdra_common_8534_4ssb[self.auto_manual][self.sliv_key_common]
            self.calc_dedicate = self.tdra_dedicate_8534_4ssb[self.auto_manual][self.sliv_key_dedicate]
            if self.act_pdsch_trs == 'true':
                if self.sliv_key_dedicate in ["dl14_primary_bi10_sch", "dl14_secondary_bi10",
                                              "dl14_primary_bi6_sch", "dl14_secondary_bi6"]:
                    self.calc_dedicate = self.calc_dedicate + self.sliv9
        self.log.info("calc sliv, common sliv:%s, dedicate sliv:%s" % (self.calc_common, self.calc_dedicate))

    def sliv_calc_8534_6ssb(self):
        if self.auto_manual == "automatic":
            self.calc_common = self.tdra_common_8534_6ssb[self.auto_manual][self.sliv_key_common]
            self.calc_dedicate = self.tdra_dedicate_8534_6ssb[self.auto_manual][self.sliv_key_dedicate]
            if self.act_pdsch_trs == 'true' and self.sliv_key_dedicate in ['bi6', 'dl14_bi10', 'dl14_bi6']:
                self.calc_dedicate += self.sliv9
        elif self.auto_manual == "manual":
            self.calc_common = self.tdra_common_8534_6ssb[self.auto_manual][self.sliv_key_common]
            self.calc_dedicate = self.tdra_dedicate_8534_6ssb[self.auto_manual][self.sliv_key_dedicate]
            if self.act_pdsch_trs == 'true':
                if self.sliv_key_dedicate in ["dl14_primary_bi6_sch", "dl14_secondary_bi6"]:
                    self.calc_dedicate = self.calc_dedicate + self.sliv9
        self.log.info("calc sliv, common sliv:%s, dedicate sliv:%s" % (self.calc_common, self.calc_dedicate))

    def check_common(self):
        for sliv in self.calc_common:
            if sliv in self.report_common:
                self.common_ok_cnt += 1
            else:
                self.common_error_cnt += 1

    def check_dedicate(self):
        sliv_retx = []
        sliv2s_l = []
        sliv_retx_s_minus_1 = []
        for sliv in self.report_dedicate:
            if sliv in self.calc_dedicate:
                self.dedicate_ok_cnt += 1
            else:
                sliv_retx.append(sliv)
        # sliv => s and l => s-1, l => new sliv
        if sliv_retx:
            for item in sliv_retx:
                sliv2s_l.append(self.sliv_inverse[str(item)])
            for sl in sliv2s_l:
                if sl[0] == 2:
                    sum_sl = 1 + sl[1]
                    if sum_sl < 9:
                        self.dedicate_error_cnt += 1
                    else:
                        sliv_retx_s_minus_1.append(eval("self.sliv" + str(sum_sl))[0])
                else:
                    self.dedicate_error_cnt += 1

            for sliv in sliv_retx_s_minus_1:
                if sliv in self.report_dedicate:
                    self.dedicate_ok_cnt += 1
                else:
                    self.dedicate_error_cnt += 1
        self.log.info("sliv for retx: %s, SLIV for retx(s-1):%s" % (sliv_retx, sliv_retx_s_minus_1))

    def check_result(self):
        self.check_common()
        self.check_dedicate()
        if self.dedicate_ok_cnt == 0 or self.common_error_cnt > 0:
            self.raise_exception.case_fail("Common sliv error!")
        if self.dedicate_ok_cnt == 0 or self.dedicate_error_cnt > 0:
            self.raise_exception.case_fail("Dedicate TDRA error!")

    def tdra_7601(self):
        if self.is_7601_1ssb():
            self.auto_manual = self.scf_nrccell_1['cellCsiRsImLocationMode']
            self.tdd_frame_structure2bi()
            self.csi_rs_cfg()
            self.ssb_cfg()
            self.trs_cfg()
            self.act_pdsch_cfg()
            self.is_dl14()
            self.primary_secondary_select()
            self.is_schedule()
            self.sliv_report()
            # self.set_test_parameters()
            self.log.info("calc value, auto_manual:%s, dl14:%s, primary_secondary:%s, bi:%s, schedule:%s" %
                          (self.auto_manual, self.dl14, self.primary_secondary, self.bi, self.sch))
            self.generate_sliv_key_common()
            self.generate_sliv_key_dedicate()
            self.sliv_calc_7601()
            self.check_result()

    def tdra_8534_2ssb(self):
        self.auto_manual = self.scf_nrccell_1['cellCsiRsImLocationMode']
        self.tdd_frame_structure2bi()
        self.csi_rs_cfg_x2()
        self.ssb_cfg()
        self.trs_cfg_x2()
        self.act_pdsch_cfg()
        self.is_dl14()
        self.primary_secondary_select()
        self.is_schedule()
        self.sliv_report_x2()
        # self.set_test_parameters()
        self.log.info("calc value, auto_manual:%s, dl14:%s, primary_secondary:%s, bi:%s, schedule:%s" %
                      (self.auto_manual, self.dl14, self.primary_secondary, self.bi, self.sch))
        self.generate_sliv_key_common()
        self.generate_sliv_key_dedicate()
        self.sliv_calc_7601()
        self.check_result()

    def tdra_8534_4ssb(self):
        self.auto_manual = self.scf_nrccell_1['cellCsiRsImLocationMode']
        self.tdd_frame_structure2bi()
        self.csi_rs_cfg_x2()
        self.ssb_cfg()
        self.trs_cfg_x2()
        self.act_pdsch_cfg()
        self.is_dl14()
        self.primary_secondary_select()
        self.is_schedule()
        self.sliv_report_x2()
        # self.set_test_parameters()
        self.log.info("calc value, auto_manual:%s, dl14:%s, primary_secondary:%s, bi:%s, schedule:%s" %
                      (self.auto_manual, self.dl14, self.primary_secondary, self.bi, self.sch))
        self.generate_sliv_key_common()
        self.generate_sliv_key_dedicate()
        self.sliv_calc_8534_4ssb()
        self.check_result()

    def tdra_8534_6ssb(self):
        self.auto_manual = self.scf_nrccell_1['cellCsiRsImLocationMode']
        self.tdd_frame_structure2bi()
        self.csi_rs_cfg_x2()
        self.ssb_cfg()
        self.trs_cfg_x2()
        self.act_pdsch_cfg()
        self.is_dl14()
        self.primary_secondary_select()
        self.is_schedule()
        self.sliv_report_x2()
        # self.set_test_parameters()
        self.log.info("calc value, auto_manual:%s, dl14:%s, primary_secondary:%s, bi:%s, schedule:%s" %
                      (self.auto_manual, self.dl14, self.primary_secondary, self.bi, self.sch))
        self.generate_sliv_key_common()
        self.generate_sliv_key_dedicate()
        self.sliv_calc_8534_6ssb()
        self.check_result()

    def tdra_8534(self):
        if self.is_8534_2ssb():
            self.tdra_8534_2ssb()
        elif self.is_8534_4ssb():
            self.tdra_8534_4ssb()
        elif self.is_8534_6ssb():
            self.tdra_8534_6ssb()

    def tdra_checker(self):
        # print("x2log:", self.x2_file)
        self.get_scf_parameters()
        if self.x2_file and not self.is_feature_7601():
            self.get_x2_parameters()
        elif self.egate_file:
            self.get_egate_parameters()
        else:
            self.raise_exception.case_invalid("No egate or x2 log!")
        if self.is_feature_7601():
            self.tdra_7601()
        else:
            self.tdra_8534()
        self.raise_exception.case_pass("TDRA check PASS!")


def tdra_check_py(log_path='', scf_file='', egate_file='', x2_file=''):
    TdraChecker(log_path=log_path, scf_file=scf_file, egate_file=egate_file, x2_file=x2_file).tdra_checker()


if __name__ == "__main__":
    # log_path = r'C:\work\data\017-Feature\5G\8534\TDRA_log\CB007601_Auto_semiStatic_DL14'
    # scf_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\CB007601_Auto_semiStatic_DL14\scf.xml'
    # egate_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\CB007601_Auto_semiStatic_DL14\egate_console.log'
    # log_path = r'C:\work\data\017-Feature\5G\8534\TDRA_log\crt_1'
    # scf_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\crt_1\SCF_running.xml'
    # egate_file = r"C:\work\data\017-Feature\5G\8534\TDRA_log\crt_1\egate_console.log"
    # x2_file = r"C:\work\data\017-Feature\5G\8534\TDRA_log\crt_1\x2c.pcap.txt"
    # log_path = r'C:\work\data\017-Feature\5G\7601\CB007601-B_1-1_TC001_20220531172039049\
    # CB007601-B_1-1_TC001_Aperiodic_CSI_with_cell_speci'
    # scf_file = r'C:\work\data\017-Feature\5G\7601\CB007601-B_1-1_TC001_20220531172039049\
    # CB007601-B_1-1_TC001_Aperiodic_CSI_with_cell_speci\SCF_running.xml'
    # egate_file = r'C:\work\data\017-Feature\5G\7601\CB007601-B_1-1_TC001_20220531172039049\
    # CB007601-B_1-1_TC001_Aperiodic_CSI_with_cell_speci\egate_console.log'
    # x2_file = r'C:\work\data\017-Feature\5G\7601\CB007601-B_1-1_TC001_20220531172039049\
    # CB007601-B_1-1_TC001_Aperiodic_CSI_with_cell_speci\x2.pcap.txt'

    log_path = r'C:\work\data\017-Feature\5G\8534\TDRA_log\6SSB_manual_semiStatic_BISlot'
    scf_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\6SSB_manual_semiStatic_BISlot\SCF_running.xml'
    egate_file = r''
    x2_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\6SSB_manual_semiStatic_BISlot\x2gnp-2.txt'

    log_path = r'C:\work\data\017-Feature\5G\8534\TDRA_log\6SSB_manual_semiStatic_BISlot'
    scf_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\6SSB_manual_semiStatic_BISlot\SCF_running.xml'
    egate_file = r''
    x2_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\6SSB_manual_semiStatic_BISlot\x2gnp-2.txt'

    log_path = r'C:\work\data\017-Feature\5G\8534\TDRA_log\Auto_BI10_actpdsch_true'
    scf_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\Auto_BI10_actpdsch_true\SCF_running.xml'
    egate_file = r''
    x2_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\Auto_BI10_actpdsch_true\x2gnp-2.txt'

    log_path = r'C:\work\data\017-Feature\5G\8534\TDRA_log\Auto_DL14_actpdsch_true'
    scf_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\Auto_DL14_actpdsch_true\SCF_running.xml'
    egate_file = r''
    x2_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\Auto_DL14_actpdsch_true\x2gnp-2.txt'

    log_path = r'C:\work\data\017-Feature\5G\8534\TDRA_log\manual_BI10_actpdsch_true'
    scf_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\manual_BI10_actpdsch_true\SCF_running.xml'
    egate_file = r''
    x2_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\manual_BI10_actpdsch_true\x2gnp-2.txt'

    log_path = r'C:\work\data\017-Feature\5G\8534\TDRA_log\manual_DL14_primaryList_actpdsch_false'
    scf_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\manual_DL14_primaryList_actpdsch_false\SCF_running.xml'
    egate_file = r''
    x2_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\manual_DL14_primaryList_actpdsch_false\x2gnp-2.txt'

    log_path = r'C:\work\data\017-Feature\5G\8534\TDRA_log\manual_Dl14_secondaryList_actpdsch_true'
    scf_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\manual_Dl14_secondaryList_actpdsch_true\SCF_running.xml'
    egate_file = r''
    x2_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\manual_Dl14_secondaryList_actpdsch_true\x2gnp-2.txt'

    log_path = r'C:\work\data\017-Feature\5G\8534\TDRA_log\20220614_203509\CB008534_C_4-3-1_TC001'
    scf_file = (r'C:\work\data\017-Feature\5G\8534\TDRA_log\20220614_203509\CB008534_C_4-3-1_TC001\case_scripts'
                + r'\CB008534_C_4-3-1_TC001\resources\Configuration_scf_MRBTS-1_1_CB008534_6SSB_PCI180.xml')
    egate_file = r''
    x2_file = (r'C:\work\data\017-Feature\5G\8534\TDRA_log\20220614_203509\CB008534_C_4-3-1_TC001'
               + r'\tcpdump_20220614_204923\br0.pcap.txt')

    # log_path='/opt/ute/results/20220613_135534/CB008534-A_1-1_TC001_2SSBs_actPciBasedCsiImRandomization_true'
    # scf_file='/opt/ute/results/20220613_135534/CB008534-A_1-1_TC001_2SSBs_actPciBasedCsiImRandomization_true
    # /case_scripts/CB008534_A_1-1_TC001/resources/Configuration_scf_MRBTS-1_1_2SSB_20220609-1006.xml'
    # x2_file='/opt/ute/results/20220613_135534/CB008534-A_1-1_TC001_2SSBs_actPciBasedCsiImRandomization_true
    # /tcpdump_20220613_140957/br0.pcap.txt'

    # log_path = r'C:\work\data\017-Feature\5G\8534\TDRA_log\manual_DL14_primaryList_actpdsch_false'
    # scf_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\manual_DL14_primaryList_actpdsch_false\SCF_running.xml'
    # egate_file = r''
    # x2_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\manual_DL14_primaryList_actpdsch_false\x2gnp-2.txt'

    # log_path = r'C:\work\data\017-Feature\5G\8534\TDRA_log\manual_Dl14_secondaryList_actpdsch_true'
    # scf_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\manual_Dl14_secondaryList_actpdsch_true\SCF_running.xml'
    # egate_file = r''
    # x2_file = r'C:\work\data\017-Feature\5G\8534\TDRA_log\manual_Dl14_secondaryList_actpdsch_true\x2gnp-2.txt'
    # tdra_obj = TdraChecker(log_path=log_path, scf_file=scf_file, egate_file=egate_file, x2_file=x2_file)
    # tdra_obj.get_x2_parameters()
    tdra_check_py(log_path=log_path, scf_file=scf_file, x2_file=x2_file)
