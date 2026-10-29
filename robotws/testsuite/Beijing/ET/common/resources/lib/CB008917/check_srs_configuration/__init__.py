# -*- coding: utf-8 -*-
"""
2022/07/29 first version by song.guo@nokia-sbell.com
    this is the checker to verify Srs configuration
2022/08/19 second version by song.guo@nokia-sbell.com
    add blanking prb part
2022/09/06 third version by song.guo@nokia-sbell.com
    add pooling+blanking prb part
2022/09/07 fourth version by song.guo@nokia-sbell.com
    add pooling+dedicated bwp party
2024/05/31 add parameter "version", to keep old behavior for old log in ut, by Ye Sheng
"""

import re
import unittest
from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser
from testsuite.Beijing.ET.common.resources.lib.checker import Checker


class Const:
    SRS_CONFIGURE_FDD_TABLE = [
        {'UL_BW_min': 0, 'UL_BW_max': 24, 'Csrs': 1, 'Bsrs': 0, 'SRS_BW_size': 8,
         'Carrier_BW_PRB': [25, 52, 79, 106, 133, 160, 216]},
        {'UL_BW_min': 24, 'UL_BW_max': 32, 'Csrs': 7, 'Bsrs': 0, 'SRS_BW_size': 24,
         'Carrier_BW_PRB': [52, 79, 106, 133, 160, 216]},
        {'UL_BW_min': 32, 'UL_BW_max': 52, 'Csrs': 9, 'Bsrs': 0, 'SRS_BW_size': 32,
         'Carrier_BW_PRB': [52, 79, 106, 133, 160, 216]},
        {'UL_BW_min': 52, 'UL_BW_max': 76, 'Csrs': 14, 'Bsrs': 0, 'SRS_BW_size': 52,
         'Carrier_BW_PRB': [79, 106, 133, 160, 216]},
        {'UL_BW_min': 76, 'UL_BW_max': 104, 'Csrs': 20, 'Bsrs': 0, 'SRS_BW_size': 76,
         'Carrier_BW_PRB': [106, 133, 160, 216]},
        {'UL_BW_min': 104, 'UL_BW_max': 160, 'Csrs': 25, 'Bsrs': 0, 'SRS_BW_size': 104,
         'Carrier_BW_PRB': [133, 160, 216]},
        {'UL_BW_min': 160, 'UL_BW_max': 216, 'Csrs': 40, 'Bsrs': 0, 'SRS_BW_size': 160,
         'Carrier_BW_PRB': [216]}
    ]
    SRS_CONFIGURE_TDD_TABLE = [
        {'UL_BW_min': 0, 'UL_BW_max': 32, 'Csrs': 1, 'Bsrs': 0, 'SRS_BW_size': 8,
         'Carrier_BW_PRB': [51, 78, 106, 133, 162, 189, 217, 245, 273]},
        {'UL_BW_min': 32, 'UL_BW_max': 48, 'Csrs': 9, 'Bsrs': 0, 'SRS_BW_size': 32,
         'Carrier_BW_PRB': [51, 78, 106, 133, 162, 189, 217, 245, 273]},
        {'UL_BW_min': 48, 'UL_BW_max': 76, 'Csrs': 12, 'Bsrs': 0, 'SRS_BW_size': 48,
         'Carrier_BW_PRB': [51, 78, 106, 133, 162, 189, 217, 245, 273]},
        {'UL_BW_min': 76, 'UL_BW_max': 104, 'Csrs': 20, 'Bsrs': 0, 'SRS_BW_size': 76,
         'Carrier_BW_PRB': [78, 106, 133, 162, 189, 217, 245, 273]},
        {'UL_BW_min': 104, 'UL_BW_max': 132, 'Csrs': 25, 'Bsrs': 0, 'SRS_BW_size': 104,
         'Carrier_BW_PRB': [106, 133, 162, 189, 217, 245, 273]},
        {'UL_BW_min': 132, 'UL_BW_max': 160, 'Csrs': 33, 'Bsrs': 0, 'SRS_BW_size': 132,
         'Carrier_BW_PRB': [133, 162, 189, 217, 245, 273]},
        {'UL_BW_min': 160, 'UL_BW_max': 184, 'Csrs': 40, 'Bsrs': 0, 'SRS_BW_size': 160,
         'Carrier_BW_PRB': [162, 189, 217, 245, 273]},
        {'UL_BW_min': 184, 'UL_BW_max': 216, 'Csrs': 45, 'Bsrs': 0, 'SRS_BW_size': 184,
         'Carrier_BW_PRB': [189, 217, 245, 273]},
        {'UL_BW_min': 216, 'UL_BW_max': 240, 'Csrs': 51, 'Bsrs': 0, 'SRS_BW_size': 216,
         'Carrier_BW_PRB': [217, 245, 273]},
        {'UL_BW_min': 240, 'UL_BW_max': 256, 'Csrs': 53, 'Bsrs': 0, 'SRS_BW_size': 240,
         'Carrier_BW_PRB': [245, 273]},
        {'UL_BW_min': 256, 'UL_BW_max': 272, 'Csrs': 57, 'Bsrs': 0, 'SRS_BW_size': 256,
         'Carrier_BW_PRB': [273]},
        {'UL_BW_min': 272, 'UL_BW_max': 273, 'Csrs': 61, 'Bsrs': 0, 'SRS_BW_size': 272,
         'Carrier_BW_PRB': [273]}
    ]


class InvalidInfo:
    DL_RB_START_NOT_FOUND = "DlRbStart not found but UlRbStart is 'sameAsDl"
    RB_START_CHECK_NOT_IMPLEMENTED = "rb_start check for {rb_start_str} not implemented"
    FEATURE_FLAG_IS_WRONG = ('The combined parameter actSpecificBwpSize or actPRBBlanking or actSlowPrbPooling'
                             ' or cellTechnology in scf is not right')


class FailInfo:
    SRS_CONFIGURE_ON_RRC_DIFFERENT = "The values of SRS configure on different RRC message are not the same"
    SRS_VALUE_ON_RRC_MESSAGE_DIFFERENT_WITH_CONFIGURED = ("The values of srs on rrc message is different"
                                                          "with configured value")
    UL_BANDWIDTH_NOT_IN_APPLICABLE_CARRIER_BANDWIDTH_ON_SRS_CONFIGURE_TABLE = (
        "ul bandwidth is not in applicable carrier bandwidth on selected item in srs configure table")


class CheckSrsConfiguration(Checker):

    def __init__(self, log_path, scf_file, emil_file, pcap_file, version, *args, **kwargs):
        super().__init__(log_path, *args, **kwargs)
        self.scf_file = scf_file
        self.emil_file = emil_file
        self.pcap_file = pcap_file
        self.srs_scf_config = None
        self.srs_config_rrc_from_emil = None
        self.srs_cell_setup_from_pcap = None
        self.bwp_rb_start_from_scf = None
        self.srs_bw_size = None
        self.ul_bandwidth_key = "ulBandwidth" if version < 2 else "ulBandwidth_item_0"
        self.init_info()

    def init_info(self):
        self.init_srs_scf_config()
        self.init_srs_cell_setup_from_pcap()
        self.init_rb_start_from_scf()
        self.init_srs_config_rrc_from_emil()

    def init_rb_start_from_scf(self):
        self.bwp_rb_start_from_scf = {}
        self.get_dl_rb_start()
        self.get_ul_rb_start()

    def get_dl_rb_start(self):
        self.bwp_rb_start_from_scf['dl_rb_start'] = self.convert_rb_start(self.srs_scf_config['cRbStartDl'])

    def get_ul_rb_start(self):
        self.bwp_rb_start_from_scf['ul_rb_start'] = self.convert_rb_start(self.srs_scf_config['cRbStartUl'])

    def convert_rb_start(self, rb_start_str):
        if rb_start_str == 'sameAsDl':
            if 'dl_rb_start' in (self.bwp_rb_start_from_scf or {}):
                return self.bwp_rb_start_from_scf['dl_rb_start']
            else:
                self.case_invalid(InvalidInfo.DL_RB_START_NOT_FOUND)
        else:
            m = re.match(r"crb(\d+)$", rb_start_str)
            if m:
                return int(m.group(1))
            else:
                self.case_invalid(InvalidInfo.RB_START_CHECK_NOT_IMPLEMENTED.format(rb_size_str=rb_start_str))

    def init_srs_cell_setup_from_pcap(self):
        pcap_parser = InfoParser(filename=self.pcap_file)
        item_list = self.make_srs_init_cell_setup_info_items()
        cell_setup_info = pcap_parser.get_info(item_list=item_list, filter_pattern=r'itf_l2_ps_cell_cellsetupreq')
        self.srs_cell_setup_from_pcap = cell_setup_info[0]
        self.logger.debug(self.srs_cell_setup_from_pcap)

    def make_srs_init_cell_setup_info_items(self):
        return ["cellBwpList_item_1->longPucchNumPuschPrb_item_0: as longPucchNumPuschPrb",
                "cellBwpList_item_1->longPucchStartPuschPrb_item_0: as longPucchStartPuschPrb",
                "cellBwpList_item_1->uplinkBwp->bandwidth: as ulDedicatedBwpSize",
                "numMinPrbAllocUl_item_0:",
                self.ul_bandwidth_key + "()"]

    def init_srs_scf_config(self):
        scf_parser = InfoParser(filename=self.scf_file)
        scf_info = scf_parser.get_info(
            item_list=["MRBTS-1/NRBTS-1/NRCELL-1->cellBwpList->bwpDN:[]",
                       "MRBTS-1/NRBTS-1/NRCELL-1->cellTechnology:",
                       "MRBTS-1/NRBTS-1/NRCELL-1->nbrOfBlankedPRBsLowEdgeUL:",
                       "actPRBBlanking:",
                       "actSlowPrbPooling:",
                       "actSpecificBwpSize:"])
        self.srs_scf_config = self.get_scf_dedicated_bwp_config(scf_info, scf_parser)
        self.srs_scf_config['cellTechnology'] = scf_info[0]['cellTechnology']
        self.srs_scf_config['nbrOfBlankedPRBsLowEdgeUL'] = scf_info[0]['nbrOfBlankedPRBsLowEdgeUL']
        self.srs_scf_config['actPRBBlanking'] = scf_info[0]['actPRBBlanking']
        self.srs_scf_config['actSlowPrbPooling'] = scf_info[0]['actSlowPrbPooling']
        self.srs_scf_config['actSpecificBwpSize'] = scf_info[0]['actSpecificBwpSize']
        self.logger.debug(self.srs_scf_config)

    @staticmethod
    def get_scf_dedicated_bwp_config(scf_info, scf_parser):
        for node in scf_info[0]['bwpDN']:
            item_to_check = ("bwpType:", "cRbStartDl:", "cRbStartUl:")
            item_list = [node + '->' + item for item in item_to_check]
            scf_config = scf_parser.get_info(item_list=item_list)
            if scf_config[0]['bwpType'] == 'dedicated':
                return scf_config[0]

    def init_srs_config_rrc_from_emil(self):
        msg_parser = InfoParser(filename=self.emil_file)
        msg_info = msg_parser.get_info(
            item_list=["c-SRS", "b-SRS", "b-hop", "freqDomainPosition", "freqDomainShift"],
            filter_pattern=r'rrcSetup\b|rrcReconfiguration\b|SgNBAdditionRequestAcknowledge|CellGroupConfig')
        for item in msg_info:
            if (item['c-SRS'] is None or item['b-SRS'] is None or item['b-hop'] is None or
                    item['freqDomainPosition'] is None or item['freqDomainShift'] is None):
                msg_info.remove(item)
        self.srs_config_rrc_from_emil = msg_info
        self.logger.debug(self.srs_config_rrc_from_emil)

    def get_srs_bw_size(self):
        if (self.srs_scf_config['actSpecificBwpSize'] == 'true' and
                self.srs_scf_config['actPRBBlanking'] == 'false' and
                self.srs_scf_config['actSlowPrbPooling'] == 'false'):
            self.srs_bw_size = self.srs_cell_setup_from_pcap['longPucchNumPuschPrb']
        elif (self.srs_scf_config['actSpecificBwpSize'] == 'false' and
              self.srs_scf_config['actPRBBlanking'] == 'true' and
              self.srs_scf_config['actSlowPrbPooling'] == 'false'):
            self.srs_bw_size = self.srs_cell_setup_from_pcap['longPucchNumPuschPrb']
        elif (self.srs_scf_config['actSpecificBwpSize'] == 'false' and
              self.srs_scf_config['actPRBBlanking'] == 'true' and
              self.srs_scf_config['actSlowPrbPooling'] == 'true' and
              self.srs_scf_config['cellTechnology'] == 'FDD'):
            self.srs_bw_size = min(self.srs_cell_setup_from_pcap['ulBandwidth'],
                                   (self.srs_cell_setup_from_pcap['numMinPrbAllocUl_item_0'] -
                                    2 * (self.srs_cell_setup_from_pcap['longPucchStartPuschPrb'] -
                                    self.srs_scf_config['nbrOfBlankedPRBsLowEdgeUL'])))
            self.logger.debug(self.srs_bw_size)
        elif (self.srs_scf_config['actSpecificBwpSize'] == 'true' and
              self.srs_scf_config['actPRBBlanking'] == 'false' and
              self.srs_scf_config['actSlowPrbPooling'] == 'true' and
              self.srs_scf_config['cellTechnology'] == 'FDD'):
            self.srs_bw_size = min(self.srs_cell_setup_from_pcap['ulDedicatedBwpSize'],
                                   (self.srs_cell_setup_from_pcap['numMinPrbAllocUl_item_0'] -
                                    2 * self.srs_cell_setup_from_pcap['longPucchStartPuschPrb']))
            self.logger.debug(self.srs_bw_size)
        else:
            self.case_invalid(InvalidInfo.FEATURE_FLAG_IS_WRONG)

    def get_srs_configure_on_table(self):
        self.get_srs_bw_size()
        selected_item = None
        if self.srs_scf_config['cellTechnology'] == 'FDD':
            for item in Const.SRS_CONFIGURE_FDD_TABLE:
                if item['UL_BW_min'] <= self.srs_bw_size < item['UL_BW_max']:
                    selected_item = item
                    break
        else:
            for item in Const.SRS_CONFIGURE_TDD_TABLE:
                if item['UL_BW_min'] <= self.srs_bw_size < item['UL_BW_max']:
                    selected_item = item
                    break
        if self.srs_cell_setup_from_pcap[self.ul_bandwidth_key] not in selected_item['Carrier_BW_PRB']:
            self.case_fail(FailInfo.UL_BANDWIDTH_NOT_IN_APPLICABLE_CARRIER_BANDWIDTH_ON_SRS_CONFIGURE_TABLE)
        self.logger.debug(selected_item)
        return selected_item

    def verify_srs_table_with_rrc(self):
        self.logger.debug(self.srs_config_rrc_from_emil)
        for item in self.srs_config_rrc_from_emil:
            if (item['c-SRS'] != self.srs_config_rrc_from_emil[0]['c-SRS'] or
                    item['b-SRS'] != self.srs_config_rrc_from_emil[0]['b-SRS'] or
                    item['b-hop'] != self.srs_config_rrc_from_emil[0]['b-hop'] or
                    item['freqDomainPosition'] != self.srs_config_rrc_from_emil[0]['freqDomainPosition'] or
                    item['freqDomainShift'] != self.srs_config_rrc_from_emil[0]['freqDomainShift']):
                self.case_fail(FailInfo.SRS_CONFIGURE_ON_RRC_DIFFERENT)
        compare_value = self.get_srs_configure_on_table()
        self.assert_equal(
            'compare c-SRS value on rrc message', compare_value['Csrs'],
            self.srs_config_rrc_from_emil[0]['c-SRS'], FailInfo.SRS_VALUE_ON_RRC_MESSAGE_DIFFERENT_WITH_CONFIGURED)
        self.assert_equal(
            'compare b-SRS value on rrc message', compare_value['Bsrs'],
            self.srs_config_rrc_from_emil[0]['b-SRS'], FailInfo.SRS_VALUE_ON_RRC_MESSAGE_DIFFERENT_WITH_CONFIGURED)
        self.assert_equal(
            'compare b-hop value on rrc message', 0,
            self.srs_config_rrc_from_emil[0]['b-hop'], FailInfo.SRS_VALUE_ON_RRC_MESSAGE_DIFFERENT_WITH_CONFIGURED)
        self.assert_equal(
            'compare freqDomainPosition value on rrc message', 0,
            self.srs_config_rrc_from_emil[0]['freqDomainPosition'],
            FailInfo.SRS_VALUE_ON_RRC_MESSAGE_DIFFERENT_WITH_CONFIGURED)
        self.verify_freq_domain_shift(compare_value)

    def verify_freq_domain_shift(self, item):
        srs_bw_size = item['SRS_BW_size']
        srs_freq_domain_offset = (self.bwp_rb_start_from_scf['ul_rb_start'] +
                                  self.srs_cell_setup_from_pcap['longPucchStartPuschPrb'] +
                                  int((self.srs_cell_setup_from_pcap['longPucchNumPuschPrb']-srs_bw_size)/2))
        self.logger.debug(srs_freq_domain_offset)
        self.assert_equal('compare freqDomainShift value on rrc message', srs_freq_domain_offset,
                          self.srs_config_rrc_from_emil[0]['freqDomainShift'],
                          FailInfo.SRS_VALUE_ON_RRC_MESSAGE_DIFFERENT_WITH_CONFIGURED)

    def verify(self):
        self.verify_srs_table_with_rrc()
        self.case_pass()


def verify_srs_configuration(log_path, scf_file, emil_file, pcap_file, version=2, log_level=None):
    checker = CheckSrsConfiguration(log_path, scf_file, emil_file, pcap_file, version=version, log_level=log_level)
    checker.verify()
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
