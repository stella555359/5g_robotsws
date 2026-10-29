# -*- coding: utf-8 -*-
"""
2022/09/19 first version by song.guo@nokia-sbell.com
    this is the checker to verify pdcch coreset and initial bwp on scell
2022/09/20 second version by song.guo@nokia-sbell.com
    add distinguish cellDepType
"""

import re
import unittest
from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser
from testsuite.Beijing.ET.common.resources.lib.checker import Checker


class Const:
    BWP_SIZE = 275
    CORESET0_SET_TDD_MAP = [
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 2, 'Offset': 0},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 2, 'Offset': 1},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 2, 'Offset': 2},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 2, 'Offset': 3},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 2, 'Offset': 4},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 3, 'Offset': 0},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 3, 'Offset': 1},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 3, 'Offset': 2},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 3, 'Offset': 3},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 3, 'Offset': 4},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 1, 'Offset': 12},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 1, 'Offset': 14},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 1, 'Offset': 16},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 2, 'Offset': 12},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 2, 'Offset': 14},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 2, 'Offset': 16}
    ]
    CORESET0_SET_FDD_MAP = [
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 2, 'Offset': 0},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 2, 'Offset': 2},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 2, 'Offset': 4},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 3, 'Offset': 0},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 3, 'Offset': 2},
        {'CORESET multi pattern': 1, 'Num of RB': 24, 'Num of Symbol': 3, 'Offset': 4},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 1, 'Offset': 12},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 1, 'Offset': 16},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 2, 'Offset': 12},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 2, 'Offset': 16},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 3, 'Offset': 12},
        {'CORESET multi pattern': 1, 'Num of RB': 48, 'Num of Symbol': 3, 'Offset': 16},
        {'CORESET multi pattern': 1, 'Num of RB': 96, 'Num of Symbol': 1, 'Offset': 38},
        {'CORESET multi pattern': 1, 'Num of RB': 96, 'Num of Symbol': 2, 'Offset': 38},
        {'CORESET multi pattern': 1, 'Num of RB': 96, 'Num of Symbol': 3, 'Offset': 38}
    ]


class InvalidInfoScell:
    NO_SCF_CONFIG = "Scell,No config found in scf config"
    SCF_CONFIG_NO_INITIAL_BWP = "Scell,No initial bwpType found in scf config"
    NO_UE = "Scell,No valid UE in emil file"
    RB_SIZE_CHECK_NOT_IMPLEMENTED = "Scell,RbSize check for {rb_size_str} not implemented"
    RB_START_CHECK_NOT_IMPLEMENTED = "Scell,rb_start check for {rb_start_str} not implemented"
    DL_RB_SIZE_NOT_FOUND = "Scell,DlRbSize not found but UlRbSize is 'sameAsDl"
    DL_RB_START_NOT_FOUND = "Scell,DlRbStart not found but UlRbStart is 'sameAsDl"
    FEATURE_FLAG_IS_WRONG = 'Scell,The parameter actSpecificBwpSize in scf is not right'
    ALL_RB_IS_INVALID = 'Scell,RbSize = allRb, which is not allowed when actSpecificBwpSize is true'
    NO_CELL_SETUP_INFO = "Scell,No cell setup info"
    CELL_DEP_TYPE_INVALID = "Scell cellDepType is wrong"


class FailInfoScell:
    LOCATION_AND_BW_UNMATCH = "Scell,Calculated Location and Bandwidth from SCF does not match that from emil"
    LOCATION_AND_BW_UL_DIFFERENT = ("Scell,The values of Location and Bandwidth for UL initial BWP"
                                    " on different message are not the same")
    LOCATION_AND_BW_DL_DIFFERENT = ("Scell,The values of Location and Bandwidth for DL initial BWP"
                                    " on different message are not the same")
    CORESET_DEDICATED_FREQUENCY_DOMAIN_INFO_DIFFERENT = ("Scell,The values of frequency Domain Resources"
                                                         " on different message are not the same")
    CORESET_DEDICATED_FREQUENCY_DOMAIN_DIFFERENT_ON_UE = ("Scell,The values of frequency Domain Resources"
                                                          " between SA and NSA UE are not the same")
    LOCATION_AND_BW_FROM_EMIL_DIFFERENT_ON_UE = ("Scell,The values of Location and Bandwidth from emil"
                                                 " between SA and NSA UE are not the same")
    DEDICATED_CORESET_FREQUENCY_DOMAIN_RESOURCES_ON_RRC_UNMATCH = ("Scell,The dedicated coreset frequency domain"
                                                                   " resources on rrc unmatched")
    CORESET0_FREQUENCY_DOMAIN_ON_CELL_SETUP_UNMATCH = "Scell,The coreset0 frequency domain on cell setup unmatched"
    DEDICATED_CORESET_FREQUENCY_DOMAIN_ON_CELL_SETUP_UNMATCH = ("Scell,The dedicated coreset frequency domain"
                                                                " on cell setup unmatched")
    CORESET0_FREQUENCY_DOMAIN_RB_SHIFT_ON_CELL_SETUP_UNMATCH = ("Scell,The coreset0 frequency domain rb shift"
                                                                " on cell setup unmatched")
    DEDICATED_CORESET_FREQUENCY_DOMAIN_RB_SHIFT_ON_CELL_SETUP_UNMATCH = ("Scell,The dedicated coreset frequency domain"
                                                                         " rb shift on cell setup unmatched")


class CheckPdcchCoresetAndInitialBwpScell(Checker):

    def __init__(self, log_path, scf_file, emil_file, pcap_file, *args, **kwargs):
        super().__init__(log_path, *args, **kwargs)
        self.scf_file = scf_file
        self.emil_file = emil_file
        self.pcap_file = pcap_file
        self.scf_config = None
        self.bwp_config_from_scf = None
        self.location_and_bw_from_emil = None
        self.location_and_bw_from_emil_sa = None
        self.location_and_bw_from_emil_nsa = None
        self.coreset_dedicated_frequency_domain_from_emil = None
        self.coreset_dedicated_frequency_domain_from_emil_sa = None
        self.coreset_dedicated_frequency_domain_from_emil_nsa = None
        self.cell_setup_from_pacp = None
        self.init_info()

    def init_info(self):
        self.init_scf_config()
        self.init_cell_setup_from_pacp()
        self.init_rb_size_and_start_from_scf()
        self.init_location_and_bw_info_from_emil()
        self.init_coreset_dedicated_frequency_domain_from_emil()

    def verify_location_and_bw(self):
        self.verify_dl_location_and_bw()

    def verify_dl_location_and_bw(self):
        location_and_bw = self.encode_location_and_bw(self.bwp_config_from_scf['dl_rb_size'],
                                                      self.bwp_config_from_scf['dl_rb_start'])
        self.assert_equal(
            'dl initial location and bandwidth', location_and_bw,
            self.location_and_bw_from_emil['locationAndBandwidth_dl'], FailInfoScell.LOCATION_AND_BW_UNMATCH)

    def verify_ul_location_and_bw(self):
        location_and_bw = self.encode_location_and_bw(self.bwp_config_from_scf['ul_rb_size'],
                                                      self.bwp_config_from_scf['ul_rb_start'])
        self.assert_equal(
            'ul initial location and bandwidth', location_and_bw,
            self.location_and_bw_from_emil['locationAndBandwidth_ul'], FailInfoScell.LOCATION_AND_BW_UNMATCH)

    @staticmethod
    def encode_location_and_bw(rb_size, rb_start):
        bwp_size = Const.BWP_SIZE
        if (rb_size - 1) <= int(bwp_size / 2):
            riv = bwp_size * (rb_size - 1) + rb_start
        else:
            riv = bwp_size * (bwp_size - rb_size + 1) + (bwp_size - 1 - rb_start)
        return riv

    def init_rb_size_and_start_from_scf(self):
        self.bwp_config_from_scf = {}
        self.get_dl_rb_size_and_start()
        self.get_ul_rb_size_and_start()

    def get_dl_rb_size_and_start(self):
        self.bwp_config_from_scf['dl_rb_size'] = self.convert_rb_size(
            self.scf_config['cRbSizeDl'],
            self.scf_config['type0CoresetConfigurationIndex'],
            self.scf_config['cellTechnology'])
        self.bwp_config_from_scf['dl_rb_start'] = self.convert_rb_start(
            self.scf_config['cRbStartDl'],
            self.scf_config['type0CoresetConfigurationIndex'],
            self.get_ssb_prb_offset(), self.scf_config['cellTechnology'])

    def get_ul_rb_size_and_start(self):
        self.bwp_config_from_scf['ul_rb_size'] = self.convert_rb_size(
            self.scf_config['cRbSizeUl'],
            self.scf_config['type0CoresetConfigurationIndex'],
            self.scf_config['cellTechnology'])
        self.bwp_config_from_scf['ul_rb_start'] = self.convert_rb_start(
            self.scf_config['cRbStartUl'],
            self.scf_config['type0CoresetConfigurationIndex'],
            self.get_ssb_prb_offset(),
            self.scf_config['cellTechnology'])

    def get_ssb_prb_offset(self):
        ssb_prb_offset = self.cell_setup_from_pacp['ssBlockPrbOffset']
        return ssb_prb_offset

    def convert_rb_size(self, rb_size_str, coreset0_index, cell_tpye):
        if rb_size_str == 'allRb':
            self.case_invalid(InvalidInfoScell.ALL_RB_IS_INVALID)
        elif rb_size_str == 'coreset0':
            coreset0_rb_size = self.get_coreset0_rb_size(coreset0_index, cell_tpye)
            return coreset0_rb_size
        elif rb_size_str == 'sameAsDl':
            if 'dl_rb_size' in self.bwp_config_from_scf or {}:
                return self.bwp_config_from_scf['dl_rb_size']
            else:
                self.case_invalid(InvalidInfoScell.DL_RB_SIZE_NOT_FOUND)
        else:
            m = re.match(r"n(\d+)$", rb_size_str)
            if m:
                return int(m.group(1))
            else:
                self.case_invalid(InvalidInfoScell.RB_SIZE_CHECK_NOT_IMPLEMENTED.format(rb_size_str=rb_size_str))

    def convert_rb_start(self, rb_start_str, coreset0_index, ssb_prb_offset, cell_tpye):
        if rb_start_str == 'sameAsDl':
            if 'dl_rb_start' in self.bwp_config_from_scf or {}:
                return self.bwp_config_from_scf['dl_rb_start']
            else:
                self.case_invalid(InvalidInfoScell.DL_RB_START_NOT_FOUND)
        elif rb_start_str == 'coreset0':
            coreset0_rb_start = self.get_coreset0_rb_start(coreset0_index, ssb_prb_offset, cell_tpye)
            return coreset0_rb_start
        else:
            m = re.match(r"crb(\d+)$", rb_start_str)
            if m:
                return int(m.group(1))
            else:
                self.case_invalid(InvalidInfoScell.RB_START_CHECK_NOT_IMPLEMENTED.format(rb_size_str=rb_start_str))

    def init_cell_setup_from_pacp(self):
        pcap_parser = InfoParser(filename=self.pcap_file)
        item_list = self.make_init_cell_setup_info_items()
        cell_setup_info = pcap_parser.get_info(
            item_list=item_list, filter_pattern=r'itf_l2_ps_cell_cellsetupreq',
            filter_expression='physCellId == %d' % self.scf_config['physCellId'])
        self.validate_cell_setup_info(cell_setup_info)
        self.cell_setup_from_pacp = cell_setup_info[0]

    @staticmethod
    def make_init_cell_setup_info_items():
        return ["ssBlockPrbOffset:",
                "commonControlResourceSet_item_0->coresetFreqDomain: as coreset0FreqDomain",
                "commonControlResourceSet_item_1->coresetFreqDomain: as dedicatedcoresetFreqDomain",
                "commonControlResourceSet_item_0->coresetFreqDomainRbShift: as coreset0FreqDomainRbShift",
                "commonControlResourceSet_item_1->coresetFreqDomainRbShift: as dedicatedcoresetFreqDomainRbShift",
                "physCellId:"]

    def validate_cell_setup_info(self, cell_setup_info):
        self.logger.debug(cell_setup_info)
        if not cell_setup_info or not cell_setup_info[0]:
            self.case_invalid(InvalidInfoScell.NO_CELL_SETUP_INFO)

    def init_scf_config(self):
        scf_parser = InfoParser(filename=self.scf_file)
        scf_info = scf_parser.get_info(
            item_list=["MRBTS-1/NRBTS-1/NRCELL-2->cellBwpList->bwpDN:[]", "actSpecificBwpSize:",
                       "MRBTS-1/NRBTS-1/NRCELL-2->type0CoresetConfigurationIndex:",
                       "MRBTS-1/NRBTS-1/NRCELL-2->cellTechnology:",
                       "MRBTS-1/NRBTS-1/NRCELL-2->physCellId:",
                       "MRBTS-1/NRBTS-1/NRCELL-2->cellDepType:"])
        self.validate_feature_switch(scf_info)
        scf_initial_bwp_config = self.get_scf_initial_bwp_config(scf_info, scf_parser)
        self.validate_scf_config(scf_initial_bwp_config)
        self.scf_config = scf_initial_bwp_config[0]
        scf_dedicated_bwp_config, dedicated_bwp_profile = self.get_scf_dedicated_bwp_config(scf_info, scf_parser)
        self.scf_config['type0CoresetConfigurationIndex'] = scf_info[0]['type0CoresetConfigurationIndex']
        self.scf_config['cellTechnology'] = scf_info[0]['cellTechnology']
        self.scf_config['physCellId'] = scf_info[0]['physCellId']
        self.scf_config['cellDepType'] = scf_info[0]['cellDepType']
        self.scf_config['dedicatedcRbSizeDl'] = scf_dedicated_bwp_config[0]['cRbSizeDl']
        self.scf_config['dedicatedcRbStartDl'] = scf_dedicated_bwp_config[0]['cRbStartDl']
        scf_parser = InfoParser(filename=self.scf_file)
        scf_info = scf_parser.get_info(
            item_list=[dedicated_bwp_profile+"/PDCCH-1/PDCCH_CONFIG_DEDICATED-1->coresetDedicated->cRbStart:",
                       dedicated_bwp_profile+"/PDCCH-1/PDCCH_CONFIG_DEDICATED-1->coresetDedicated->size:"])
        self.scf_config['coresetDedicatedcRbStart'] = scf_info[0]['cRbStart']
        self.scf_config['coresetDedicatedcsize'] = scf_info[0]['size']
        self.logger.debug(self.scf_config)

    def validate_feature_switch(self, scf_info):
        self.logger.debug(scf_info)
        if not scf_info:
            self.case_invalid(InvalidInfoScell.NO_SCF_CONFIG)
        if scf_info[0]['actSpecificBwpSize'] != 'true':
            self.case_invalid(InvalidInfoScell.FEATURE_FLAG_IS_WRONG)

    @staticmethod
    def get_coreset0_rb_size(coreset0_index, cell_tpye):
        if cell_tpye == 'TDD':
            rb_size = Const.CORESET0_SET_TDD_MAP[coreset0_index]['Num of RB']
        else:
            rb_size = Const.CORESET0_SET_FDD_MAP[coreset0_index]['Num of RB']
        return rb_size

    @staticmethod
    def get_coreset0_rb_start(coreset0_index, ssb_prb_offset, cell_tpye):
        if cell_tpye == 'TDD':
            rb_start = ssb_prb_offset - Const.CORESET0_SET_TDD_MAP[coreset0_index]['Offset']
        else:
            rb_start = ssb_prb_offset - Const.CORESET0_SET_FDD_MAP[coreset0_index]['Offset']
        return rb_start

    @staticmethod
    def get_scf_initial_bwp_config(scf_info, scf_parser):
        for node in scf_info[0]['bwpDN']:
            item_to_check = ("bwpType:", "cRbSizeDl:", "cRbStartDl:", "cRbSizeUl:", "cRbStartUl:")
            item_list = [node + '->' + item for item in item_to_check]
            scf_config = scf_parser.get_info(item_list=item_list)
            if scf_config[0]['bwpType'] == 'initial':
                return scf_config

    @staticmethod
    def get_scf_dedicated_bwp_config(scf_info, scf_parser):
        for node in scf_info[0]['bwpDN']:
            item_to_check = ("bwpType:", "cRbSizeDl:", "cRbStartDl:")
            item_list = [node + '->' + item for item in item_to_check]
            scf_config = scf_parser.get_info(item_list=item_list)
            if scf_config[0]['bwpType'] == 'dedicated':
                return scf_config, node

    def validate_scf_config(self, scf_config):
        if not scf_config:
            self.case_invalid(InvalidInfoScell.NO_SCF_CONFIG)
        if scf_config[0]['bwpType'] != 'initial':
            self.case_invalid(InvalidInfoScell.SCF_CONFIG_NO_INITIAL_BWP)

    def init_location_and_bw_info_from_emil(self):
        msg_parser = InfoParser(filename=self.emil_file)
        item_list = self.make_location_and_bw_info_items()
        filter_expression = 'locationAndBandwidth_dl is not None and physCellId == %d' % self.scf_config['physCellId']
        location_and_bw_info_sa = msg_parser.get_info(
            item_list=item_list, filter_pattern=r'rrcReconfiguration',
            filter_expression=filter_expression, silent=True)
        if location_and_bw_info_sa:
            self.validate_location_and_bw_info(location_and_bw_info_sa)
            self.location_and_bw_from_emil_sa = location_and_bw_info_sa[0]
        location_and_bw_info_nsa = msg_parser.get_info(
            item_list=item_list, filter_pattern=r'SgNBAdditionRequestAcknowledge|SgNBModificationRequired',
            filter_expression=filter_expression, silent=True)
        if location_and_bw_info_nsa:
            self.validate_location_and_bw_info(location_and_bw_info_nsa)
            self.location_and_bw_from_emil_nsa = location_and_bw_info_nsa[0]
        if not self.location_and_bw_from_emil_sa and not self.location_and_bw_from_emil_nsa:
            self.case_invalid(InvalidInfoScell.NO_UE)
        elif self.location_and_bw_from_emil_sa and not self.location_and_bw_from_emil_nsa:
            self.location_and_bw_from_emil = self.location_and_bw_from_emil_sa
        elif not self.location_and_bw_from_emil_sa and self.location_and_bw_from_emil_nsa:
            self.location_and_bw_from_emil = self.location_and_bw_from_emil_nsa
        else:
            if (self.location_and_bw_from_emil_sa['locationAndBandwidth_dl'] !=
                    self.location_and_bw_from_emil_nsa['locationAndBandwidth_dl']):
                self.case_fail(FailInfoScell.LOCATION_AND_BW_FROM_EMIL_DIFFERENT_ON_UE)
            self.location_and_bw_from_emil = self.location_and_bw_from_emil_sa

    @staticmethod
    def make_location_and_bw_info_items():
        return ["sCellToAddModList->initialDownlinkBWP->locationAndBandwidth as locationAndBandwidth_dl",
                "sCellToAddModList->physCellId"]

    def validate_location_and_bw_info(self, location_and_bw_info):
        self.logger.debug(location_and_bw_info)
        for item in location_and_bw_info:
            if item['locationAndBandwidth_dl'] != location_and_bw_info[0]['locationAndBandwidth_dl']:
                self.case_fail(FailInfoScell.LOCATION_AND_BW_DL_DIFFERENT)

    def init_coreset_dedicated_frequency_domain_from_emil(self):
        msg_parser = InfoParser(filename=self.emil_file)
        massage_filter = 'UEContextModificationResponse'
        msg_info = msg_parser.get_info(
            item_list=["sCellToAddModList->frequencyDomainResources", "sCellToAddModList->physCellId"],
            filter_pattern=massage_filter,
            filter_expression='physCellId == %d' % self.scf_config['physCellId'], silent=True)
        if msg_info:
            self.validate_coreset_dedicated_frequency_domain_info(msg_info)
            frequency_domain_resources = msg_info[0]["frequencyDomainResources"]
            self.coreset_dedicated_frequency_domain_from_emil_sa = re.sub("[^01]", '', frequency_domain_resources)
            self.logger.debug(frequency_domain_resources)
        massage_filter = 'SgNBAdditionRequestAcknowledge|SgNBModificationRequired'
        msg_info = msg_parser.get_info(
            item_list=["sCellToAddModList->frequencyDomainResources", "sCellToAddModList->physCellId"],
            filter_pattern=massage_filter,
            filter_expression='physCellId == %d' % self.scf_config['physCellId'], silent=True)
        if msg_info:
            self.validate_coreset_dedicated_frequency_domain_info(msg_info)
            frequency_domain_resources = msg_info[0]["frequencyDomainResources"]
            self.coreset_dedicated_frequency_domain_from_emil_nsa = re.sub("[^01]", '', frequency_domain_resources)
            self.logger.debug(frequency_domain_resources)

    def validate_coreset_dedicated_frequency_domain_info(self, coreset_dedicated_frequency_domain_info):
        self.logger.debug(coreset_dedicated_frequency_domain_info)
        for item in coreset_dedicated_frequency_domain_info:
            if (item['frequencyDomainResources'] !=
                    coreset_dedicated_frequency_domain_info[0]['frequencyDomainResources']):
                self.case_fail(FailInfoScell.CORESET_DEDICATED_FREQUENCY_DOMAIN_INFO_DIFFERENT)

    def verify_coreset_dedicated_frequency_domain_on_rrc(self):
        if self.scf_config['cellDepType'] == 'SA':
            if not self.coreset_dedicated_frequency_domain_from_emil_sa:
                self.case_invalid(InvalidInfoScell.NO_UE)
            self.coreset_dedicated_frequency_domain_from_emil = self.coreset_dedicated_frequency_domain_from_emil_sa
        elif self.scf_config['cellDepType'] == 'NSA':
            if not self.coreset_dedicated_frequency_domain_from_emil_nsa:
                self.case_invalid(InvalidInfoScell.NO_UE)
            self.coreset_dedicated_frequency_domain_from_emil = self.coreset_dedicated_frequency_domain_from_emil_nsa
        elif self.scf_config['cellDepType'] == 'SA+NSA':
            if (not self.coreset_dedicated_frequency_domain_from_emil_sa and
                    not self.coreset_dedicated_frequency_domain_from_emil_nsa):
                self.case_invalid(InvalidInfoScell.NO_UE)
            elif (self.coreset_dedicated_frequency_domain_from_emil_sa and
                  not self.coreset_dedicated_frequency_domain_from_emil_nsa):
                self.coreset_dedicated_frequency_domain_from_emil = self.coreset_dedicated_frequency_domain_from_emil_sa
            elif (not self.coreset_dedicated_frequency_domain_from_emil_sa and
                  self.coreset_dedicated_frequency_domain_from_emil_nsa):
                self.coreset_dedicated_frequency_domain_from_emil = \
                    self.coreset_dedicated_frequency_domain_from_emil_nsa
            else:
                if (self.coreset_dedicated_frequency_domain_from_emil_sa !=
                        self.coreset_dedicated_frequency_domain_from_emil_nsa):
                    self.case_fail(FailInfoScell.CORESET_DEDICATED_FREQUENCY_DOMAIN_DIFFERENT_ON_UE)
                self.coreset_dedicated_frequency_domain_from_emil = self.coreset_dedicated_frequency_domain_from_emil_sa
        else:
            self.case_invalid(InvalidInfoScell.CELL_DEP_TYPE_INVALID)
        self.logger.debug(self.coreset_dedicated_frequency_domain_from_emil)
        coreset_freq_size = int(self.scf_config['coresetDedicatedcsize']/6)
        bwp_crb_startdl = self.convert_rb_start(
            self.scf_config['dedicatedcRbStartDl'],
            self.scf_config['type0CoresetConfigurationIndex'],
            self.get_ssb_prb_offset(),
            self.scf_config['cellTechnology'])
        decimal_value_on_emil = int(self.coreset_dedicated_frequency_domain_from_emil, 2)
        decimal_value_on_rrc = (2 ** coreset_freq_size-1)*(
            2**(45-(coreset_freq_size+int((self.scf_config['coresetDedicatedcRbStart']-bwp_crb_startdl)/6))))
        self.assert_equal(
            'dedicated coreset frequency domain resources on rrc message', decimal_value_on_emil,
            decimal_value_on_rrc, FailInfoScell.DEDICATED_CORESET_FREQUENCY_DOMAIN_RESOURCES_ON_RRC_UNMATCH)

    def verify_coreset0_frequency_domain_on_cell_setup(self):
        coreset0_rb_start = self.get_coreset0_rb_start(
            self.scf_config['type0CoresetConfigurationIndex'],
            self.get_ssb_prb_offset(), self.scf_config['cellTechnology'])
        most_bit_index = 64-1-int(coreset0_rb_start/6)
        least_bit_index = 64-int((coreset0_rb_start+self.bwp_config_from_scf['dl_rb_size'])/6)
        decimal_value_on_calc = 0
        for num in range(least_bit_index, most_bit_index+1):
            decimal_value_on_calc = decimal_value_on_calc+2**num
        self.assert_equal('coreset0 frequency domain on cell setup', self.cell_setup_from_pacp['coreset0FreqDomain'],
                          decimal_value_on_calc, FailInfoScell.CORESET0_FREQUENCY_DOMAIN_ON_CELL_SETUP_UNMATCH)
        coreset_0_freq_domain_rb_shift = coreset0_rb_start % 6
        self.assert_equal(
            'coreset0 frequency domain rb shift on cell setup',
            self.cell_setup_from_pacp['coreset0FreqDomainRbShift'],
            coreset_0_freq_domain_rb_shift, FailInfoScell.CORESET0_FREQUENCY_DOMAIN_RB_SHIFT_ON_CELL_SETUP_UNMATCH)

    def verify_coreset_dedicated_frequency_domain_on_cell_setup(self):
        if (self.scf_config['cellDepType'] == 'SA') or (self.scf_config['cellDepType'] == 'SA+NSA') or (
                self.scf_config['cellDepType'] == 'NSA'):
            coreset_freq_size = int(self.scf_config['coresetDedicatedcsize']/6)
            decimal_value_on_calc = (2 ** coreset_freq_size-1)*(
                2**(64-(coreset_freq_size+int(self.scf_config['coresetDedicatedcRbStart']/6))))
            self.assert_equal(
                'dedicated coreset frequency domain on cell setup',
                self.cell_setup_from_pacp['dedicatedcoresetFreqDomain'],
                decimal_value_on_calc, FailInfoScell.DEDICATED_CORESET_FREQUENCY_DOMAIN_ON_CELL_SETUP_UNMATCH)
        else:
            self.case_invalid(InvalidInfoScell.CELL_DEP_TYPE_INVALID)
        coreset_dedicated_freq_domain_rb_shift = self.scf_config['coresetDedicatedcRbStart'] % 6
        self.assert_equal(
            'dedicated coreset frequency domain rb shift on cell setup',
            self.cell_setup_from_pacp['dedicatedcoresetFreqDomainRbShift'],
            coreset_dedicated_freq_domain_rb_shift,
            FailInfoScell.DEDICATED_CORESET_FREQUENCY_DOMAIN_RB_SHIFT_ON_CELL_SETUP_UNMATCH)

    def verify(self):
        self.verify_location_and_bw()
        self.verify_coreset_dedicated_frequency_domain_on_rrc()
        self.verify_coreset0_frequency_domain_on_cell_setup()
        self.verify_coreset_dedicated_frequency_domain_on_cell_setup()
        self.case_pass()


def verify_pdcch_coreset_and_initial_bwp_scell(log_path, scf_file, emil_file, pcap_file, log_level=None):
    checker = CheckPdcchCoresetAndInitialBwpScell(log_path, scf_file, emil_file, pcap_file, log_level=log_level)
    checker.verify()
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
