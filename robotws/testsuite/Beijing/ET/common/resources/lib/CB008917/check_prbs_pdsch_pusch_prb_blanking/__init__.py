# -*- coding: utf-8 -*-
"""
2022/08/29 first version by song.guo@nokia-sbell.com
           this is the checker to verify Prbs of Pdsch and Pusch on Prb Blanking feature
"""

import math
import unittest
from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser
from testsuite.Beijing.ET.common.resources.lib.checker import Checker


class InvalidInfo:
    NO_SCF_CONFIG = "No config found in scf config"
    SCF_CONFIG_NO_DEDICATED_BWP = "No dedicated bwpType found in scf config"
    DL_FD_SCHED_DATA_NOT_FOUND = 'Message type==dlFdSchedData not found in tti_dl file'
    UL_FD_SCHED_DATA_NOT_FOUND = 'Message type==ulFdSchedData not found in tti_ul file'
    ACT_PRB_BLANKING_IS_OFF = 'The parameter actPRBBlanking in scf is not "true"'


class FailInfo:
    START_PRB_OVERFLOW = "StartPrb: {start_prb} < RB_Low: {rb_start}\nfile:{filename}\nrecord:{record_id}"
    NUM_OF_PRB_OVERFLOW = ("StartPrb + NumOfPrb: {end_prb} > RB_High: {rb_end}\n"
                           "file: {filename}\nrecord: {record_id}")


class WarnInfo:
    PRB_VALUE_IS_NOT_INT = ("StartPrb:{start_prb} or NumOfPrb:{num_of_prb} in TTI log is not integer\n"
                            "file:{filename}\nrecord:{record_id}")


class CheckPrbsPdschPuschPrbBlanking(Checker):

    def __init__(self, log_path, scf_file, pcap_file, tti_dl_file, tti_ul_file, *args, **kwargs):
        super().__init__(log_path, *args, **kwargs)
        self.scf_file = scf_file
        self.pcap_file = pcap_file
        self.tti_dl_file = tti_dl_file
        self.tti_ul_file = tti_ul_file
        self.scf_config = {}
        self.cell_setup_from_pacp = None
        self.pdsch_low_edge = None
        self.pdsch_high_edge = None
        self.pusch_low_edge = None
        self.pusch_high_edge = None
        self.init_info()

    def init_info(self):
        self.init_scf_config()
        self.init_cell_setup_from_pacp()

    def init_scf_config(self):
        scf_parser = InfoParser(filename=self.scf_file)
        scf_info = scf_parser.get_info(
            item_list=["MRBTS-1/NRBTS-1/NRCELL-1->cellBwpList->bwpDN:[]",
                       "MRBTS-1/NRBTS-1/NRCELL-1->nbrOfBlankedPRBsHighEdgeDL:",
                       "MRBTS-1/NRBTS-1/NRCELL-1->nbrOfBlankedPRBsHighEdgeUL:",
                       "MRBTS-1/NRBTS-1/NRCELL-1->nbrOfBlankedPRBsLowEdgeDL:",
                       "MRBTS-1/NRBTS-1/NRCELL-1->nbrOfBlankedPRBsLowEdgeUL:",
                       "actPRBBlanking:"])
        self.validate_feature_switch(scf_info)
        self.scf_config['nbrOfBlankedPRBsHighEdgeDL'] = scf_info[0]['nbrOfBlankedPRBsHighEdgeDL']
        self.scf_config['nbrOfBlankedPRBsHighEdgeUL'] = scf_info[0]['nbrOfBlankedPRBsHighEdgeUL']
        self.scf_config['nbrOfBlankedPRBsLowEdgeDL'] = scf_info[0]['nbrOfBlankedPRBsLowEdgeDL']
        self.scf_config['nbrOfBlankedPRBsLowEdgeUL'] = scf_info[0]['nbrOfBlankedPRBsLowEdgeUL']
        scf_dedicated_bwp_config, dedicated_bwp_profile = self.get_scf_bwp_config(scf_info, scf_parser)
        self.validate_scf_config(scf_dedicated_bwp_config)
        scf_parser = InfoParser(filename=self.scf_file)
        scf_info = scf_parser.get_info(
            item_list=[dedicated_bwp_profile+"/PDSCH-1->pdschRat0RbgConfig:"])
        self.scf_config['pdschRat0RbgConfig'] = scf_info[0]['pdschRat0RbgConfig']
        self.logger.debug(self.scf_config)

    def validate_feature_switch(self, scf_info):
        self.logger.debug(scf_info)
        if not scf_info:
            self.case_invalid(InvalidInfo.NO_SCF_CONFIG)
        if scf_info[0]['actPRBBlanking'] != 'true':
            self.case_invalid(InvalidInfo.ACT_PRB_BLANKING_IS_OFF)

    @staticmethod
    def get_scf_bwp_config(scf_info, scf_parser):
        for node in scf_info[0]['bwpDN']:
            item_to_check = "bwpType:"
            item_list = [node + '->' + item_to_check]
            scf_config = scf_parser.get_info(item_list=item_list)
            if scf_config[0]['bwpType'] == 'dedicated':
                return scf_config, node

    def validate_scf_config(self, scf_config):
        self.logger.debug(scf_config)
        if not scf_config:
            self.case_invalid(InvalidInfo.NO_SCF_CONFIG)
        if scf_config[0]['bwpType'] != 'dedicated':
            self.case_invalid(InvalidInfo.SCF_CONFIG_NO_DEDICATED_BWP)

    def init_cell_setup_from_pacp(self):
        pcap_parser = InfoParser(filename=self.pcap_file)
        item_list = self.make_init_cell_setup_info_items()
        cell_setup_info = pcap_parser.get_info(item_list=item_list, filter_pattern=r'itf_l2_ps_cell_cellsetupreq')
        self.cell_setup_from_pacp = cell_setup_info[0]
        self.logger.debug(self.cell_setup_from_pacp)

    @staticmethod
    def make_init_cell_setup_info_items():
        return ["cellBwpList_item_1->longPucchNumPuschPrb_item_0: as longPucchNumPuschPrb",
                "cellBwpList_item_1->longPucchStartPuschPrb_item_0: as longPucchStartPuschPrb",
                "ulBandwidth()",
                "dlBandwidth()"]

    def get_pdsch_real_high_low_edge(self):
        pdsch_rbg_size = None
        if self.scf_config['pdschRat0RbgConfig'] == 'config1':
            pdsch_rbg_size = 4
        elif self.scf_config['pdschRat0RbgConfig'] == 'config2':
            pdsch_rbg_size = 8
        self.pdsch_low_edge = pdsch_rbg_size * math.ceil(self.scf_config['nbrOfBlankedPRBsLowEdgeDL']/pdsch_rbg_size)
        self.pdsch_high_edge = pdsch_rbg_size * int(
            (self.cell_setup_from_pacp['dlBandwidth']-self.scf_config['nbrOfBlankedPRBsHighEdgeDL'])/pdsch_rbg_size)-1

    def get_pusch_real_high_low_edge(self):
        self.pusch_low_edge = self.cell_setup_from_pacp['longPucchStartPuschPrb']
        self.pusch_high_edge = (self.cell_setup_from_pacp['longPucchStartPuschPrb'] +
                                self.cell_setup_from_pacp['longPucchNumPuschPrb'] - 1)

    def verify_prb_range(self):
        self.verify_prb_range_dl()
        self.verify_prb_range_ul()

    def verify_prb_range_dl(self):
        self.get_pdsch_real_high_low_edge()
        parser = InfoParser(filename=self.tti_dl_file)
        result = parser.get_info(item_list=['type', 'numOfPrb', 'startPrb', 'dciFormat'],
                                 filter_expression="type=='dlFdSchedData' and dciFormat=='DL_11'")
        if not result:
            self.case_invalid(InvalidInfo.DL_FD_SCHED_DATA_NOT_FOUND)
        self.counters['dlFdSchedData'] = len(result)
        self.verify_prb_low_and_high(self.pdsch_low_edge, self.pdsch_high_edge, result, self.tti_dl_file)

    def verify_prb_range_ul(self):
        self.get_pusch_real_high_low_edge()
        parser = InfoParser(filename=self.tti_ul_file)
        result = parser.get_info(item_list=['type', 'numOfPrb', 'startPrb', 'dciFormat'],
                                 filter_expression="type=='ulFdSchedData' and dciFormat=='UL_01'")
        if not result:
            self.case_invalid(InvalidInfo.UL_FD_SCHED_DATA_NOT_FOUND)
        self.counters['ulFdSchedData'] = len(result)
        self.verify_prb_low_and_high(self.pusch_low_edge, self.pusch_high_edge, result, self.tti_ul_file)

    def verify_prb_low_and_high(self, rb_low, rb_high, result, filename):
        for item in result:
            # print("startPrb:(%s), rb_start:(%s)" % (repr(item['startPrb']), repr(rb_start)))
            if type(item['startPrb']) is str:
                self.case_warning(WarnInfo.PRB_VALUE_IS_NOT_INT, num_of_prb=item['numOfPrb'],
                                  start_prb=item['startPrb'],
                                  filename=filename, record_id=item['item_id'])
            fail_info = FailInfo.START_PRB_OVERFLOW.format(rb_start=rb_low, start_prb=float(item['startPrb']),
                                                           filename=filename, record_id=item['item_id'])
            self.assert_true('startPrb >= rb_low', float(item['startPrb']) >= rb_low, fail_info)
            fail_info = FailInfo.NUM_OF_PRB_OVERFLOW.format(rb_end=rb_high,
                                                            end_prb=float(item['startPrb'])+float(item['numOfPrb'])-1,
                                                            filename=filename, record_id=item['item_id'])
            self.assert_true('numOfPrb + startPrb <= rb_high',
                             (float(item['numOfPrb']) + float(item['startPrb']) - 1) <= rb_high, fail_info)

    def verify(self):
        self.verify_prb_range()
        self.case_pass()


def verify_prbs_pdsch_pusch_prb_blanking(log_path, scf_file, pcap_file, tti_dl_file, tti_ul_file, log_level=None):
    checker = CheckPrbsPdschPuschPrbBlanking(log_path, scf_file, pcap_file, tti_dl_file, tti_ul_file,
                                             log_level=log_level)
    checker.verify()
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
