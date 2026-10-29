# -*- coding: utf-8 -*-
"""
2022/05/25 tdra checker by @author: andy.sun@nokia-sbell.com
"""

import unittest
from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser
from testsuite.Beijing.ET.common.resources.lib.info_api import InfoAPI
from testsuite.Beijing.ET.common.resources.lib.checker import Checker
from enum import Enum


class InvalidInfo:
    CELL_NOT_FOUND = "Cell: {cell} info not found in {log_type}"
    ACT_BB_POOL_EXTENSITION_TDD_FR1_IS_NOT_SET = "Rd Parameter actBbPoolExtensionTddFr1 is not set"
    DL_FD_SCHED_DATA_NOT_FOUND = 'Message type==dlFdSchedData of cell: {cell} not found in tti_dl file'


class FailInfo:
    TDRA_NOT_CONSISTANT = "{type} TDRA Not consistant with {msg} of cell:{cell_id}"
    EXPECTED_SLIVS_NOT_USED = "Expected SLIVs: {slivs} of cell:{cell_id} Not used, tti_slivs: {tti_slivs}"


class FeatureFlag(Enum):
    FEATURE_CB8534_ENABLE = 0
    FEATURE_CB7601_ENABLE = 1
    FEATURE_FT2200_With_CB8247 = 2
    FEATURE_UE_SPECIFIC_CSIRS = 3


class CheckTDRA(Checker):

    def __init__(self, log_path, scf_file, pcap_file, emil_file, tti_dl_file, swconfig_file,
                 scf_cells, *args, **kwargs):
        super().__init__(log_path, *args, **kwargs)
        self.scf_cells = scf_cells
        self.cell = None
        self.info_api = None
        self.scf_file = scf_file
        self.pcap_file = pcap_file
        self.emil_file = emil_file
        self.tti_dl_file = tti_dl_file
        self.swconfig_file = swconfig_file
        self.rd_parameters = {}
        self.cell_info = {}
        self.cell_config = {}
        self.common_tdra_pcap = {}
        self.dedicated_tdra_pcap = {}
        self.common_tdra_rrc = {}
        self.dedicated_tdra_rrc = {}
        self.tti_SLIVs = {}
        self.symbol_nums = {}
        self.no_trs_special = {}
        self.csirs_start_symbols = {}
        self.coreset_id = None
        self.coreset_duration = None
        self.symbol_bitmap = 0
        self.SLIVs = set()
        self.reTx_SLIVs = set()
        self.special_SLIVs = set()
        self.feature_flag = None
        self.init_info()

    def init_info(self):
        self.init_info_api()
        self.init_rd_parameters()
        self.init_cell_info_from_scf()
        self.init_cell_config_from_pcap()

    def init_info_api(self):
        self.info_api = InfoAPI(log_files=(self.scf_file, self.swconfig_file))

    def init_rd_parameters(self):
        self.rd_parameters['actBbPoolExtensionTddFr1'] = self.info_api.swconfig_get_rd_parameter('0x58070a')

    def init_cell_info_from_scf(self):
        cell_items = ["actCellCsirsTddOnSsbBf:", "actCellCsiRsImTddNonBf:", "actCsirsMultiplexing:",
                      "maxCsirsNumber:", "cellCsiRsImLocationMode:", "actPdschAtSsbSlots:", "dlMimoMode:",
                      "actPdschRmCsirsForTracking:", "frameStructureType:", "guardPeriodLength:"]
        grp_items = ["numberOfTransmittedSsBlocks:", "ssBurstSetPeriod:", "scs:"]
        self.cell_info = self.info_api.scf_get_nr_cell_info(cell_items=cell_items, grp_items=grp_items)
        for cell in self.scf_cells:
            if cell not in self.cell_info:
                self.case_invalid(InvalidInfo.CELL_NOT_FOUND, cell=cell, log_type='scf')
        self.logger.debug("Info from scf, cell_info: %s" % self.cell_info)

    def init_cell_config_from_pcap(self):
        pcap_parser = InfoParser(filename=self.pcap_file)
        for cell in self.scf_cells:
            phys_cell_id = self.cell_info[cell]["physCellId"]
            pcap_info = pcap_parser.get_info(
                item_list=["nrCellIdentity:", "physCellId:", "csirsPoolingGroupId:", "cellCsiRsPeriodicity_item_0:",
                           "coresetId:[]", "coresetDuration:[]", "associatedCoresetId:[]", "searchSpaceType:[]",
                           "monitoringSymbolsWithinSlot:[]", "gpStartSymbol:[]", "patternLength:[]",
                           "numPdschPrbInTrsSlots:[]", "dmrsTypeAPosition:"],
                filter_pattern='itf_l2_ps_cell_cellsetupreq',
                filter_expression='physCellId == %d' % phys_cell_id)
            if not pcap_info[0]:
                self.case_invalid(InvalidInfo.CELL_NOT_FOUND, cell=cell, log_type='pcap')
            self.cell_config[cell] = pcap_info[0]
        self.logger.debug("Init from pcap, cell_config: %s" % self.cell_config)

    def get_common_tdra_from_pcap_cell_setup_resp(self):
        pcap_parser = InfoParser(filename=self.pcap_file)
        for cell in self.scf_cells:
            nr_cell_identity = self.cell_config[cell]["nrCellIdentity"]
            pcap_info = pcap_parser.get_info(
                item_list=["nrCellIdentity:", "pdschTimeDomainAllocation->startSymbolAndLength:[]"],
                filter_pattern='itf_l2_ps_cell_cellsetupresp',
                filter_expression='nrCellIdentity == %d' % nr_cell_identity)
            if not pcap_info[0]:
                self.case_invalid(InvalidInfo.CELL_NOT_FOUND, cell=cell, log_type='pcap cellSetupResp')
            self.common_tdra_pcap[cell] = pcap_info[0]["startSymbolAndLength"]
        self.logger.debug("common tdra from cellSetupResp: %s" % self.common_tdra_pcap)

    def get_dedicated_tdra_from_pcap_user_setup_resp(self):
        pcap_parser = InfoParser(filename=self.pcap_file)
        for cell in self.scf_cells:
            nr_cell_identity = self.cell_config[cell]["nrCellIdentity"]
            pcap_info = pcap_parser.get_info(
                item_list=["nrCellIdentity:", "pdschTimeDomainAllocationList->startSymbolAndLength:[]"],
                filter_pattern='itf_l2_ps_user_usersetupresp',
                filter_expression='nrCellIdentity == %d' % nr_cell_identity)
            if not pcap_info[0]:
                self.case_invalid(InvalidInfo.CELL_NOT_FOUND, cell=cell, log_type='pcap userSetupResp')
            self.dedicated_tdra_pcap[cell] = pcap_info[0]["startSymbolAndLength"]
        self.logger.debug("dedicated tdra from userSetupResp: %s" % self.dedicated_tdra_pcap)

    def get_common_tdra_from_emil_rrc_setup(self):
        egate_parser = InfoParser(filename=self.emil_file)
        item_list = ["pdsch-ConfigCommon->setup->startSymbolAndLength[]", "scramblingID0"]
        for cell in self.scf_cells:
            phys_cell_id = self.cell_info[cell]['physCellId']
            tdra_list = egate_parser.get_info(filter_pattern=r'rrcSetup\b',
                                              filter_expression='scramblingID0 == %d' % phys_cell_id,
                                              item_list=item_list)
            if not tdra_list[0]:
                self.case_invalid(InvalidInfo.CELL_NOT_FOUND, cell=cell, log_type='emil rrcSetup pdsch-ConfigCommon')
            self.common_tdra_rrc[cell] = tdra_list[0]["startSymbolAndLength"]
        self.logger.debug("common_tdra_rrc: %s" % self.common_tdra_rrc)

    def get_dedicated_tdra_from_emil_rrc_setup(self):
        egate_parser = InfoParser(filename=self.emil_file)
        item_list = ["pdsch-Config->setup->startSymbolAndLength[]", "scramblingID0"]
        for cell in self.scf_cells:
            phys_cell_id = self.cell_info[cell]['physCellId']
            tdra_list = egate_parser.get_info(filter_pattern=r'rrcSetup\b',
                                              filter_expression='scramblingID0 == %d' % phys_cell_id,
                                              item_list=item_list)
            if not tdra_list[0]:
                self.case_invalid(InvalidInfo.CELL_NOT_FOUND, cell=cell, log_type='emil rrcSetup pdsch-Config')
            self.dedicated_tdra_rrc[cell] = tdra_list[0]["startSymbolAndLength"]
        self.logger.debug("dedicated_tdra_rrc: %s" % self.dedicated_tdra_rrc)

    def get_used_slivs_from_tti(self):
        for cell in self.scf_cells:
            parser = InfoParser(filename=self.tti_dl_file)
            result = parser.get_info(item_list=['SLIV', 'physCellId'],
                                     filter_expression="type=='dlFdSchedData' "
                                     "and physCellId==%d" % self.cell_info[cell]['physCellId'])
            if not result:
                self.case_invalid(InvalidInfo.DL_FD_SCHED_DATA_NOT_FOUND, cell=cell)
            self.tti_SLIVs[cell] = set()
            for item in result:
                self.tti_SLIVs[cell].update({int(float(item['SLIV']))})
        self.logger.debug("tti_SLIVs: %s" % self.tti_SLIVs)

    def get_feature_flag(self):
        if self.cell_info[self.cell]["actCellCsirsTddOnSsbBf"] == "true":
            self.logger.debug("TDRA Calculation: CB8534 Config")
            self.feature_flag = FeatureFlag.FEATURE_CB8534_ENABLE
        elif self.cell_info[self.cell]["actCellCsiRsImTddNonBf"] == "true":
            self.logger.debug("TDRA Calculation: CB7601 Config")
            self.feature_flag = FeatureFlag.FEATURE_CB7601_ENABLE
        elif (self.cell_info[self.cell]["dlMimoMode"] == "8x4 Closed Loop Spatial Multiplexing" and
              self.cell_info[self.cell]["actCsirsMultiplexing"] == "true"):
            max_csirs_number = self.cell_info[self.cell]["maxCsirsNumber"]
            self.logger.debug("TDRA Calculation: FT2200 and CB8247 Config, maxCsiRsNum: %d" % max_csirs_number)
            self.feature_flag = FeatureFlag.FEATURE_FT2200_With_CB8247
        else:
            self.logger.debug("TDRA Calculation: UE Specific")
            self.feature_flag = FeatureFlag.FEATURE_UE_SPECIFIC_CSIRS

    def get_gp_start_symbols(self):
        gp_start_symbols = [self.cell_config[self.cell]["gpStartSymbol"][0]]
        pattern_length = self.cell_config[self.cell]["patternLength"]
        gp_start_symbol_1 = self.cell_config[self.cell]["gpStartSymbol"][1]
        gp_start_symbols.append(gp_start_symbol_1 if pattern_length[1] > 0 else 0)
        return gp_start_symbols

    def get_init_symbols(self, is_with_gp):
        init_symbols = {14}
        gp_start_symbols = self.get_gp_start_symbols()
        for gp_start_symbol in gp_start_symbols:
            if is_with_gp and gp_start_symbol >= 9:
                init_symbols.update({gp_start_symbol})
        return init_symbols

    def get_special_slivs(self):
        self.special_SLIVs.update({self.calculate_sliv(1, 10)})
        self.special_SLIVs.update({self.calculate_sliv(2, 9)})

    def update_symbol_nums_and_csirs_start_symbols_cb8534(self, csirs_pooling_group_id):
        if self.cell_info[self.cell]["numberOfTransmittedSsBlocks"] == "2 beams":
            if csirs_pooling_group_id == 0 or csirs_pooling_group_id == 1:
                self.csirs_start_symbols[self.cell].update({11})
            else:
                self.no_trs_special[self.cell] = True
            self.get_special_slivs()
        elif self.cell_info[self.cell]["numberOfTransmittedSsBlocks"] == "4 beams":
            if csirs_pooling_group_id == 0 or csirs_pooling_group_id == 1:
                self.csirs_start_symbols[self.cell].update({10})
            else:
                self.symbol_nums[self.cell].update({0, 2})
        else:
            self.no_trs_special[self.cell] = True

    def update_csirs_start_symbols_cb7601(self, csirs_pooling_group_id):
        if csirs_pooling_group_id == 0 or csirs_pooling_group_id == 1:
            self.csirs_start_symbols[self.cell].update({11})
        else:
            self.no_trs_special[self.cell] = True
        self.get_special_slivs()

    def update_csirs_start_symbols_ft2200_with_cb8247(self, csirs_pooling_group_id):
        if self.cell_info[self.cell]["maxCsirsNumber"] > 1:
            self.symbol_nums[self.cell].update({0, 2})
            self.csirs_start_symbols[self.cell].update({10})
        else:
            if csirs_pooling_group_id == 2:
                self.symbol_nums[self.cell].update({0, 2})
            else:
                self.csirs_start_symbols[self.cell].update({10})

    def update_symbol_nums_and_csirs_start_symbols(self):
        csirs_period = int(self.cell_config[self.cell]["cellCsiRsPeriodicity_item_0"][2:])
        csirs_pooling_group_id = self.cell_config[self.cell]["csirsPoolingGroupId"]
        if self.feature_flag == FeatureFlag.FEATURE_CB8534_ENABLE:
            self.update_symbol_nums_and_csirs_start_symbols_cb8534(csirs_pooling_group_id)
        elif self.feature_flag == FeatureFlag.FEATURE_CB7601_ENABLE:
            self.update_csirs_start_symbols_cb7601(csirs_pooling_group_id)
        elif self.feature_flag == FeatureFlag.FEATURE_FT2200_With_CB8247:
            self.update_csirs_start_symbols_ft2200_with_cb8247(csirs_pooling_group_id)
        if csirs_period == 80 and (csirs_pooling_group_id == 0 or csirs_pooling_group_id == 2):
            pass

    def get_csirs_start_symbols(self, is_with_gp, activate_pdsch_at_trs=False):
        self.update_symbol_nums_and_csirs_start_symbols()
        # cell specific csi-rs
        init_symbols = self.get_init_symbols(is_with_gp)
        for init_symbol in init_symbols:
            for symbol_num in self.symbol_nums[self.cell]:
                if init_symbol - symbol_num >= 9:
                    self.csirs_start_symbols[self.cell].update({init_symbol - symbol_num})

        # CB008940 enable - for 1 ueSpecific csi-rs
        self.csirs_start_symbols[self.cell].update({13})
        gp_start_symbols = self.get_gp_start_symbols()
        for gp_start_symbol in gp_start_symbols:
            if is_with_gp and gp_start_symbol >= 9 and (gp_start_symbol - 1 >= 9):
                self.csirs_start_symbols[self.cell].update({gp_start_symbol - 1})

        # TRS and DMRS conflict
        num_pdsch_prb_in_trs_slots = self.cell_config[self.cell]["numPdschPrbInTrsSlots"][0]
        if (is_with_gp and self.cell_info[self.cell]["actPdschRmCsirsForTracking"] == "true" and
           activate_pdsch_at_trs and num_pdsch_prb_in_trs_slots > 0 and
           not self.no_trs_special[self.cell]):  # Dedicate add Trs
            self.csirs_start_symbols[self.cell].update({9})

    @staticmethod
    def get_start_and_length_from_sliv(sliv):
        start = 13 - sliv % 14
        length = 15 - sliv // 14
        if length <= 8 or length + start > 14:
            start = sliv % 14
            length = sliv // 14 + 1
        return start, length

    @staticmethod
    def calculate_sliv(start_symbol, length_in_symbols):
        # return l - 1 <= 7 ? 14 * (l - 1) + s : 14 * (14 - l + 1) + (14 - 1 - s);
        margin_param = 7
        ofdm_symbols_per_slot = 14
        if length_in_symbols - 1 <= margin_param:
            return ofdm_symbols_per_slot * (length_in_symbols - 1) + start_symbol
        else:
            return (ofdm_symbols_per_slot * (ofdm_symbols_per_slot - length_in_symbols + 1) +
                    (ofdm_symbols_per_slot - 1 - start_symbol))

    def get_expected_slivs(self):
        start_symbols = set()
        for i in range(0, int(self.cell_config[self.cell]["dmrsTypeAPosition"][-1:])):
            j = 15 - i
            if self.symbol_bitmap & (1 << j):
                if self.coreset_duration > 0:
                    self.coreset_duration -= 1
                if self.coreset_duration == 0:
                    start_symbols.add(i + 1)
        for start_symbol in start_symbols:
            for csi_start in self.csirs_start_symbols[self.cell]:
                self.SLIVs.update({self.calculate_sliv(start_symbol, csi_start - start_symbol)})

    def get_retx_slivs(self):
        for SLIV in self.SLIVs:
            start, length = self.get_start_and_length_from_sliv(SLIV)
            while (start < int(self.cell_config[self.cell]["dmrsTypeAPosition"][-1:]) and
                   start + length - 1 < 13):
                start += 1
                self.reTx_SLIVs.update({self.calculate_sliv(start, length)})
        self.logger.debug("reTx_SLIVs: %s" % self.reTx_SLIVs)
        self.SLIVs.update(self.reTx_SLIVs)

    def update_symbol_bitmap(self):
        self.symbol_bitmap = 0
        for i in range(0, len(self.cell_config[self.cell]["associatedCoresetId"])):
            if self.cell_config[self.cell]["associatedCoresetId"][i] == self.coreset_id:
                self.symbol_bitmap |= self.cell_config[self.cell]["monitoringSymbolsWithinSlot"][i]

    def get_expected_common_slivs(self, is_with_gp=False, activate_pdsch_at_trs=True):
        self.symbol_nums[self.cell] = set()
        self.symbol_nums[self.cell].update({0})
        self.no_trs_special[self.cell] = False
        self.csirs_start_symbols[self.cell] = set()
        if self.cell_info[self.cell]["cellCsiRsImLocationMode"] == "manual":
            pass
        else:
            self.get_csirs_start_symbols(is_with_gp, activate_pdsch_at_trs)
        self.coreset_id = self.cell_config[self.cell]["coresetId"][0]
        self.coreset_duration = self.cell_config[self.cell]["coresetDuration"][0]
        self.update_symbol_bitmap()
        self.get_expected_slivs()

    def get_expected_dedicated_slivs(self, activate_pdsch_at_trs=True):
        self.csirs_start_symbols[self.cell].clear()
        self.get_expected_common_slivs(True, activate_pdsch_at_trs)
        if self.cell_info[self.cell]["cellCsiRsImLocationMode"] == "manual":
            pass
        else:
            self.get_csirs_start_symbols(True, activate_pdsch_at_trs)
        self.coreset_id = self.cell_config[self.cell]["coresetId"][1]
        self.coreset_duration = self.cell_config[self.cell]["coresetDuration"][1]
        self.update_symbol_bitmap()
        self.get_expected_slivs()
        self.get_retx_slivs()

    def validate_rd_parameters(self):
        if not self.rd_parameters['actBbPoolExtensionTddFr1']:
            self.case_invalid(InvalidInfo.ACT_BB_POOL_EXTENSITION_TDD_FR1_IS_NOT_SET)

    def clear_sliv_and_tdra_sets(self):
        self.SLIVs.clear()
        self.reTx_SLIVs.clear()
        self.special_SLIVs.clear()

    def verify_common_tdra(self):
        self.get_expected_common_slivs()
        csirs_pooling_group_id = self.cell_config[self.cell]["csirsPoolingGroupId"]
        self.assert_equal("common TDRA comparing", self.SLIVs, set(self.common_tdra_pcap[self.cell]),
                          FailInfo.TDRA_NOT_CONSISTANT.format(type='common', msg='cellSetupResp', cell_id=self.cell),
                          classify=('cell:%d csirsPoolingGroupId:%d' % (self.cell, csirs_pooling_group_id),
                          'cellSetupResp', 'SLIVs'))
        self.assert_equal("common TDRA comparing", self.SLIVs, set(self.common_tdra_rrc[self.cell]),
                          FailInfo.TDRA_NOT_CONSISTANT.format(type='common', msg='rrcSetup', cell_id=self.cell),
                          classify=('cell:%d csirsPoolingGroupId:%d' % (self.cell, csirs_pooling_group_id),
                          'rrcSetup common', 'SLIVs'))
        self.clear_sliv_and_tdra_sets()

    def verify_dedicated_tdra(self):
        self.get_expected_dedicated_slivs()
        csirs_pooling_group_id = self.cell_config[self.cell]["csirsPoolingGroupId"]
        self.assert_equal("dedicated TDRA comparing", self.SLIVs, set(self.dedicated_tdra_pcap[self.cell]),
                          FailInfo.TDRA_NOT_CONSISTANT.format(type='dedicated', msg='userSetupResp', cell_id=self.cell),
                          classify=('cell:%d csirsPoolingGroupId:%d' % (self.cell, csirs_pooling_group_id),
                          'userSetupResp', 'SLIVs'))
        self.assert_equal("dedicated TDRA comparing", self.SLIVs, set(self.dedicated_tdra_rrc[self.cell]),
                          FailInfo.TDRA_NOT_CONSISTANT.format(type='dedicated', msg='rrcSetup', cell_id=self.cell),
                          classify=('cell:%d csirsPoolingGroupId:%d' % (self.cell, csirs_pooling_group_id),
                          'rrcSetup dedicated', 'SLIVs'))
        self.verify_expected_slivs_used()
        # self.verify_special_slivs_used()
        self.clear_sliv_and_tdra_sets()

    def verify_expected_slivs_used(self):
        csirs_pooling_group_id = self.cell_config[self.cell]["csirsPoolingGroupId"]
        self.assert_true("expected sliv checking", self.tti_SLIVs[self.cell].issubset(self.SLIVs) or
                         self.tti_SLIVs[self.cell] == self.SLIVs,
                         FailInfo.EXPECTED_SLIVS_NOT_USED.format(
                         slivs=self.SLIVs,
                         cell_id=self.cell,
                         tti_slivs=self.tti_SLIVs[self.cell]),
                         classify=('cell:%d csirsPoolingGroupId:%d' % (self.cell, csirs_pooling_group_id),
                         'tti_trace slivs', 'SLIVs'),
                         classify_value=tuple(sorted(self.tti_SLIVs[self.cell])))

    def verify_special_slivs_used(self):
        csirs_pooling_group_id = self.cell_config[self.cell]["csirsPoolingGroupId"]
        if (self.feature_flag == FeatureFlag.FEATURE_CB7601_ENABLE or
            (self.feature_flag == FeatureFlag.FEATURE_CB8534_ENABLE and
             self.cell_info[self.cell]["numberOfTransmittedSsBlocks"] == "2 beams")):
            self.assert_true("special sliv checking", self.special_SLIVs.issubset(self.tti_SLIVs[self.cell]),
                             FailInfo.EXPECTED_SLIVS_NOT_USED.format(
                             slivs=self.SLIVs,
                             cell_id=self.cell,
                             tti_slivs=self.special_SLIVs),
                             classify=('cell:%d csirsPoolingGroupId:%d' % (self.cell, csirs_pooling_group_id),
                             'special slivs', 'SLIVs'),
                             classify_value=tuple(sorted(self.special_SLIVs)))

    def verify(self):
        self.validate_rd_parameters()
        self.get_common_tdra_from_pcap_cell_setup_resp()
        self.get_dedicated_tdra_from_pcap_user_setup_resp()
        self.get_common_tdra_from_emil_rrc_setup()
        self.get_dedicated_tdra_from_emil_rrc_setup()
        self.get_used_slivs_from_tti()
        for cell in self.scf_cells:
            self.cell = cell
            self.get_feature_flag()
            self.verify_common_tdra()
            self.verify_dedicated_tdra()
        self.case_pass()


def verify_tdra(log_path, scf_file, pcap_file, emil_file, tti_dl_file, swconfig_file,
                scf_cells=(1, 2, 3), log_level=None):
    checker = CheckTDRA(log_path, scf_file, pcap_file, emil_file, tti_dl_file, swconfig_file,
                        scf_cells=scf_cells, log_level=log_level)
    checker.verify()
    checker.create_robot_file()
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
