# -*- coding: utf-8 -*-
"""
2022/09/01 first version by song.guo@nokia-sbell.com
           this is the checker to verify NumAllocCellPrb value on Prb Blanking feature with Pooling
2022/09/08 second version by song.guo@nokia-sbell.com
           add NumAllocCellPrb value on Dedicated Bwp feature with Pooling
"""

import unittest
from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser
from testsuite.Beijing.ET.common.resources.lib.checker import Checker


class InvalidInfo:
    NO_SCF_CONFIG = "No config found in scf config"
    NUM_ALLOC_CELL_PRB_DL_NOT_FOUND = 'Message type==numAllocCellPrbDl not found in tti_dl file'
    NUM_ALLOC_CELL_PRB_UL_NOT_FOUND = 'Message type==numAllocCellPrbUl not found in tti_ul file'
    ACT_POOLING_IS_WRONG = 'The parameter actSlowPrbPooling and actScheUePooling in scf is not the same'
    FEATURE_FLAG_IS_WRONG = 'The combined parameter actSpecificBwpSize and actPRBBlanking in scf is not right'
    CELL_TECHNOLOGY_IS_WRONG = 'the parameter cellTechnology in scf is not FDD'


class FailInfo:
    NUMALLOCCELLPRBDL_VALUE_WRONG_WITH_BLANKING_PRB = (
        "numAllocCellPrbDl: {num_of_allco_prb} != nonBlankingPrbDl: {non_blanking_prb}\n"
        "file: {filename}\nrecord: {record_id}")
    NUMALLOCCELLPRBUL_VALUE_WRONG_WITH_BLANKING_PRB = (
        "numAllocCellPrbUl: {num_of_allco_prb} != nonBlankingPrbUl: {non_blanking_prb}\n"
        "file: {filename}\nrecord: {record_id}")
    NUMALLOCCELLPRBDL_VALUE_WRONG_WITH_DEDICATED_PRB = (
        "numAllocCellPrbDl: {num_of_allco_prb} != dlDedicatedBwpPrb: {dl_dedicated_bwp_prb}\n"
        "file: {filename}\nrecord: {record_id}")
    NUMALLOCCELLPRBUL_VALUE_WRONG_WITH_DEDICATED_PRB = (
        "numAllocCellPrbUl: {num_of_allco_prb} != ulDedicatedBwpPrb: {ul_dedicated_bwp_prb}\n"
        "file: {filename}\nrecord: {record_id}")


class WarnInfo:
    NUMALLOCCELLPRBDL_VALUE_IS_NOT_INT = ("numAllocCellPrbDl:{num_of_allco_prb} in TTIDL log is not integer\n"
                                          "file:{filename}\nrecord:{record_id}")
    NUMALLOCCELLPRBUL_VALUE_IS_NOT_INT = ("numAllocCellPrbUl:{num_of_allco_prb} in TTIUL log is not integer\n"
                                          "file:{filename}\nrecord:{record_id}")


class CheckNumAllocCellPrb(Checker):

    def __init__(self, log_path, scf_file, pcap_file, tti_dl_file, tti_ul_file, *args, **kwargs):
        super().__init__(log_path, *args, **kwargs)
        self.scf_file = scf_file
        self.pcap_file = pcap_file
        self.tti_dl_file = tti_dl_file
        self.tti_ul_file = tti_ul_file
        self.scf_config = {}
        self.cell_setup_from_pacp = None
        self.init_info()

    def init_info(self):
        self.init_scf_config()
        self.init_cell_setup_from_pacp()

    def init_scf_config(self):
        scf_parser = InfoParser(filename=self.scf_file)
        scf_info = scf_parser.get_info(
            item_list=["MRBTS-1/NRBTS-1/NRCELL-1->nbrOfBlankedPRBsHighEdgeDL:",
                       "MRBTS-1/NRBTS-1/NRCELL-1->nbrOfBlankedPRBsHighEdgeUL:",
                       "MRBTS-1/NRBTS-1/NRCELL-1->nbrOfBlankedPRBsLowEdgeDL:",
                       "MRBTS-1/NRBTS-1/NRCELL-1->nbrOfBlankedPRBsLowEdgeUL:",
                       "MRBTS-1/NRBTS-1/NRCELL-1->cellTechnology:",
                       "actPRBBlanking:",
                       "actSlowPrbPooling:",
                       "actScheUePooling:",
                       "actSpecificBwpSize:"])
        self.validate_feature_switch(scf_info)
        self.scf_config['nbrOfBlankedPRBsHighEdgeDL'] = scf_info[0]['nbrOfBlankedPRBsHighEdgeDL']
        self.scf_config['nbrOfBlankedPRBsHighEdgeUL'] = scf_info[0]['nbrOfBlankedPRBsHighEdgeUL']
        self.scf_config['nbrOfBlankedPRBsLowEdgeDL'] = scf_info[0]['nbrOfBlankedPRBsLowEdgeDL']
        self.scf_config['nbrOfBlankedPRBsLowEdgeUL'] = scf_info[0]['nbrOfBlankedPRBsLowEdgeUL']
        self.scf_config['actPRBBlanking'] = scf_info[0]['actPRBBlanking']
        self.scf_config['actSpecificBwpSize'] = scf_info[0]['actSpecificBwpSize']
        self.logger.debug(self.scf_config)

    def validate_feature_switch(self, scf_info):
        self.logger.debug(scf_info)
        if not scf_info:
            self.case_invalid(InvalidInfo.NO_SCF_CONFIG)
        if scf_info[0]['cellTechnology'] != 'FDD':
            self.case_invalid(InvalidInfo.CELL_TECHNOLOGY_IS_WRONG)
        if scf_info[0]['actSlowPrbPooling'] != scf_info[0]['actScheUePooling']:
            self.case_invalid(InvalidInfo.ACT_POOLING_IS_WRONG)
        if scf_info[0]['actPRBBlanking'] == scf_info[0]['actSpecificBwpSize']:
            self.case_invalid(InvalidInfo.FEATURE_FLAG_IS_WRONG)

    def init_cell_setup_from_pacp(self):
        pcap_parser = InfoParser(filename=self.pcap_file)
        item_list = self.make_init_cell_setup_info_items()
        cell_setup_info = pcap_parser.get_info(item_list=item_list, filter_pattern=r'itf_l2_ps_cell_cellsetupreq')
        self.cell_setup_from_pacp = cell_setup_info[0]
        self.logger.debug(self.cell_setup_from_pacp)

    @staticmethod
    def make_init_cell_setup_info_items():
        return ["cellBwpList_item_1->uplinkBwp->bandwidth: as ulDedicatedBwpSize",
                "cellBwpList_item_1->downlinkBwp->bandwidth: as dlDedicatedBwpSize",
                "ulBandwidth_item_0()", "dlBandwidth()"]

    def verify_numalloccellprb(self):
        self.verify_numalloccellprb_dl()
        self.verify_numalloccellprb_ul()

    def verify_numalloccellprb_dl(self):
        parser = InfoParser(filename=self.tti_dl_file)
        result = parser.get_info(
            item_list=['type', 'numAllocCellPrbDl'], filter_expression="type=='dlTdSchedSubcellData'")
        if not result:
            self.case_invalid(InvalidInfo.NUM_ALLOC_CELL_PRB_DL_NOT_FOUND)
        self.counters['numAllocCellPrbDl'] = len(result)
        for item in result:
            if type(item['numAllocCellPrbDl']) is str:
                self.case_warning(
                    WarnInfo.NUMALLOCCELLPRBDL_VALUE_IS_NOT_INT, num_of_allco_prb=item['numAllocCellPrbDl'],
                    filename=self.tti_dl_file, record_id=item['item_id'])
            if self.scf_config['actPRBBlanking'] == 'true':
                non_blanking_prb = self.cell_setup_from_pacp['dlBandwidth']
                non_blanking_prb -= self.scf_config['nbrOfBlankedPRBsLowEdgeDL']
                non_blanking_prb -= self.scf_config['nbrOfBlankedPRBsHighEdgeDL']
                fail_info = FailInfo.NUMALLOCCELLPRBDL_VALUE_WRONG_WITH_BLANKING_PRB.format(
                    num_of_allco_prb=item['numAllocCellPrbDl'],
                    non_blanking_prb=non_blanking_prb,
                    filename=self.tti_dl_file, record_id=item['item_id'])
                self.assert_true('numAllocCellPrbDl = nonBlankingPrbDl',
                                 float(item['numAllocCellPrbDl']) == non_blanking_prb,
                                 fail_info)
            elif self.scf_config['actSpecificBwpSize'] == 'true':
                fail_info = FailInfo.NUMALLOCCELLPRBDL_VALUE_WRONG_WITH_DEDICATED_PRB.format(
                    num_of_allco_prb=item['numAllocCellPrbDl'],
                    dl_dedicated_bwp_prb=self.cell_setup_from_pacp['dlDedicatedBwpSize'],
                    filename=self.tti_dl_file, record_id=item['item_id'])
                self.assert_true('numAllocCellPrbDl = dlDedicatedBwpPrb',
                                 float(item['numAllocCellPrbDl']) == self.cell_setup_from_pacp['dlDedicatedBwpSize'],
                                 fail_info)

    def verify_numalloccellprb_ul(self):
        parser = InfoParser(filename=self.tti_ul_file)
        result = parser.get_info(
            item_list=['type', 'numAllocCellPrbUl'], filter_expression="type=='ulTdSchedSubcellData'")
        if not result:
            self.case_invalid(InvalidInfo.NUM_ALLOC_CELL_PRB_UL_NOT_FOUND)
        self.counters['numAllocCellPrbUl'] = len(result)
        for item in result:
            if type(item['numAllocCellPrbUl']) is str:
                self.case_warning(
                    WarnInfo.NUMALLOCCELLPRBUL_VALUE_IS_NOT_INT, num_of_allco_prb=item['numAllocCellPrbUl'],
                    filename=self.tti_ul_file, record_id=item['item_id'])
            if self.scf_config['actPRBBlanking'] == 'true':
                non_blanking_prb = self.cell_setup_from_pacp['ulBandwidth_item_0']
                non_blanking_prb -= self.scf_config['nbrOfBlankedPRBsLowEdgeUL']
                non_blanking_prb -= self.scf_config['nbrOfBlankedPRBsHighEdgeUL']

                fail_info = FailInfo.NUMALLOCCELLPRBUL_VALUE_WRONG_WITH_BLANKING_PRB.format(
                    num_of_allco_prb=item['numAllocCellPrbUl'],
                    non_blanking_prb=non_blanking_prb,
                    filename=self.tti_ul_file, record_id=item['item_id'])
                self.assert_true('numAllocCellPrbUl = nonBlankingPrbUl',
                                 float(item['numAllocCellPrbUl']) == non_blanking_prb,
                                 fail_info)
            elif self.scf_config['actSpecificBwpSize'] == 'true':
                fail_info = FailInfo.NUMALLOCCELLPRBUL_VALUE_WRONG_WITH_DEDICATED_PRB.format(
                    num_of_allco_prb=item['numAllocCellPrbUl'],
                    ul_dedicated_bwp_prb=self.cell_setup_from_pacp['ulDedicatedBwpSize'],
                    filename=self.tti_ul_file, record_id=item['item_id'])
                self.assert_true('numAllocCellPrbUl = ulDedicatedBwpPrb',
                                 float(item['numAllocCellPrbUl']) == self.cell_setup_from_pacp['ulDedicatedBwpSize'],
                                 fail_info)

    def verify(self):
        self.verify_numalloccellprb()
        self.case_pass()


def verify_numalloccellprb_pooling(log_path, scf_file, pcap_file, tti_dl_file, tti_ul_file, log_level=None):
    checker = CheckNumAllocCellPrb(log_path, scf_file, pcap_file, tti_dl_file, tti_ul_file, log_level=log_level)
    checker.verify()
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
