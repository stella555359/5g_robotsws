# -*- coding: utf-8 -*-
"""
2022/08/09 first version by sheng.1.ye@nokia-sbell.com
           this is the checker to verify correctness of csi rs startprb and nrofrb
2022/08/30 make revision1 for init_rb_info_for_csi_report, by Ye Sheng
2022/08/30 rename file, rename class from CheckCsiRsStartingRbAndNrOfRbs to CheckCsiRsRbStartAndNr, by Ye Sheng
2022/09/15 support specified cell id, by Ye Sheng
"""

import unittest
from math import ceil
from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser
from testsuite.Beijing.ET.common.resources.lib.info_api import InfoAPI
from testsuite.Beijing.ET.common.resources.lib.checker import Checker


class InvalidInfo:
    NO_SCF_CONFIG = "No config found in scf config"
    ACT_SPECIFIC_BWP_SIZE_IS_OFF = 'The parameter actSpecificBwpSize in scf is not "true"'
    INVALID_CSIRS_BM_MGMT_SUBBAND = "Invalid Value of 'csirsBmMgmtSubband': '{value}'"
    CHECKER_NOT_IMPLEMENTED = "Checker Not implemented for '{info_str}'"
    FAIL_TO_LOOKUP_RBS_BY_SCS_BW = "Fail to lookup RBs by scs={scs}, bw={bw}, cell_technology={cell_technology}"
    NO_CSI_RS_RB_INFO_FOUND_IN_EGATE = "No CSI RS startingRB and nrofRBs info in egate file {egate_file}"
    CELL_NOT_FOUND_IN_SCF = "Cell {cell} not found in scf"


class FailInfo:
    UNEXPECTED_CSIRS_STARTING_RB = "startingRB in type {csi_type} does not match expected value"
    UNEXPECTED_CSIRS_NR_OF_RBS = "nrofRBs in type {csi_type} does not match expected value"


class Const:
    N_OF_PRB_SSB = 20
    SCS_BW_TO_CHANNEL_RBS_TDD = {
        30: {5: 11, 10: 24, 15: 38, 20: 51, 25: 65, 30: 78, 40: 106,
             50: 133, 60: 162, 70: 189, 80: 217, 90: 245, 100: 273}
    }
    SCS_BW_TO_CHANNEL_RBS_FDD = {
        15: {5: 25, 10: 52, 15: 79, 20: 106, 25: 133, 30: 160, 40: 216}
    }


class CheckCsiRsRbStartAndNr(Checker):

    def __init__(self, log_path, scf_file, pcap_file, egate_file, cell=1, revision=1, *args, **kwargs):
        super().__init__(log_path, *args, **kwargs)
        self.cell = cell
        self.cell_info = {}
        self.info_api = None
        self.scf_file = scf_file
        self.pcap_file = pcap_file
        self.egate_file = egate_file
        self.scf_config = None
        self.dedicated_bwp_config_from_scf = None
        self.rb_info_from_pcap = None
        self.starting_rb_and_nr_of_rbs = None
        self.rb_info_from_egate = None
        self.revision = revision
        self.init_info()

    def verify_starting_rb_and_nr_of_rbs(self):
        for csi_rs_type, starting_rb, nr_of_rbs in self.rb_info_from_egate:
            calc_starting_prb, calc_nr_of_rbs, func_name = self.starting_rb_and_nr_of_rbs[csi_rs_type]
            self.assert_equal("%s: expected startingRB(%s) = sent startingRB" % (csi_rs_type, func_name),
                              calc_starting_prb, starting_rb,
                              FailInfo.UNEXPECTED_CSIRS_STARTING_RB.format(csi_type=csi_rs_type))
            self.assert_equal("%s: expected nrofRBs(%s) = sent nrofRBs" % (csi_rs_type, func_name),
                              calc_nr_of_rbs, nr_of_rbs,
                              FailInfo.UNEXPECTED_CSIRS_NR_OF_RBS.format(csi_type=csi_rs_type))

    def init_info(self):
        self.init_cell_info_from_scf()
        self.init_dedicated_bwp_from_scf()
        self.init_rb_param_from_pcap()
        self.calc_starting_rb_and_nr_of_rbs()
        self.get_rb_info_from_egate_rrc()

    def get_rb_info_from_egate_rrc(self):
        self.rb_info_from_egate = []
        egate_parser = InfoParser(filename=self.egate_file)
        self.get_rb_info_from_egate_rrc_setup(egate_parser)
        self.get_rb_info_from_egate_rrc_reconfiguration(egate_parser)
        if not self.rb_info_from_egate:
            self.case_invalid(InvalidInfo.NO_CSI_RS_RB_INFO_FOUND_IN_EGATE, egate_file=self.egate_file)
        self.logger.debug("rb_info_from_egate: %s" % self.rb_info_from_egate)

    def get_rb_info_from_egate_rrc_setup(self, egate_parser):
        base_list = ['(CSI-RS|csi-IM)-ResourceId[] as ResourceId', 'startingRB[]', 'nrofRBs[]']
        for parent in ('nzp-CSI-RS-ResourceToAddModList->', 'csi-IM-ResourceToAddModList->'):
            item_list = [parent + i for i in base_list] + ['scramblingID']
            rb_info_list = egate_parser.get_info(filter_pattern=r'rrcSetup\b',
                                                 filter_expression='scramblingID == %d' % self.scf_config['physCellId'],
                                                 item_list=item_list, silent=True)
            self.save_csi_im_info(rb_info_list) if 'IM' in parent else self.save_csi_info(rb_info_list)

    def get_rb_info_from_egate_rrc_reconfiguration(self, egate_parser):
        base_list = ['(CSI-RS|csi-IM)-ResourceId[] as ResourceId', 'startingRB[]', 'nrofRBs[]']
        for node in ('spCellConfig->', 'sCellToAddModList->'):
            for parent in ('nzp-CSI-RS-ResourceToAddModList->', 'csi-IM-ResourceToAddModList->'):
                item_list = [node + parent + i for i in base_list] + [node + 'physCellId'] + ['scramblingID']
                filter_exp = 'physCellId == {0} or physCellId is None and scramblingID == {0}'.format(
                    self.scf_config['physCellId'])
                rb_info_list = egate_parser.get_info(
                    filter_pattern=r'rrcReconfiguration',
                    filter_expression=filter_exp,  item_list=item_list, silent=True)
                self.save_csi_im_info(rb_info_list) if 'IM' in parent else self.save_csi_info(rb_info_list)

    def save_csi_info(self, rb_info_list):
        for rb_info in rb_info_list:
            if rb_info['startingRB']:
                for res_id, starting_rb, nr_of_rbs in zip(rb_info['ResourceId'], rb_info['startingRB'],
                                                          rb_info['nrofRBs']):
                    self.rb_info_from_egate.append((self.resource_id_to_csi_type(res_id), starting_rb, nr_of_rbs))

    def save_csi_im_info(self, rb_info_list):
        for rb_info in rb_info_list:
            if rb_info['startingRB']:
                for starting_rb, nr_of_rbs in zip(rb_info['startingRB'], rb_info['nrofRBs']):
                    self.rb_info_from_egate.append(('csi_im', starting_rb, nr_of_rbs))

    @staticmethod
    def resource_id_to_csi_type(resource_id):
        r = resource_id
        return 'csi_report' if r == 0 else 'trs' if r <= 33 else 'beam_mgmt'

    def calc_starting_rb_and_nr_of_rbs(self):
        self.starting_rb_and_nr_of_rbs = {}
        self.init_rb_info_for_beam_mgmt()
        self.init_rb_info_for_csi_report()
        self.init_rb_info_for_trs()
        self.logger.debug("starting_rb_and_nr_of_rbs: %s" % self.starting_rb_and_nr_of_rbs)

    def init_rb_info_for_beam_mgmt(self):
        if self.scf_config['csirsBmMgmtSubband'] == 'belowSSPBCHBlock':
            self.init_rb_info_for_beam_mgmt_subband_below()
        elif self.scf_config['csirsBmMgmtSubband'] == 'aboveSSPBCHBlock':
            self.init_rb_info_for_beam_mgmt_subband_above()
        else:
            self.case_invalid(InvalidInfo.INVALID_CSIRS_BM_MGMT_SUBBAND, value=self.scf_config['csirsBmMgmtSubband'])

    def init_rb_info_for_beam_mgmt_subband_below(self):
        if self.scf_config['slowPrbPoolingTddFr1DlAllowed'] == 'true':
            self.case_invalid(InvalidInfo.CHECKER_NOT_IMPLEMENTED, info_str='slowPrbPoolingTddFr1DlAllowed=True')
        else:
            ssb_prb_offset = self.rb_info_from_pcap['ssBlockPrbOffset']
            offset_prb_dl = self.dedicated_bwp_config_from_scf['dl_rb_start']
            starting_rb = self.ceil_4(offset_prb_dl)
            nr_of_rbs = self.floor_4(ssb_prb_offset - self.ceil_4(offset_prb_dl))
            self.starting_rb_and_nr_of_rbs['beam_mgmt'] = starting_rb, nr_of_rbs, self.func_name()

    def init_rb_info_for_beam_mgmt_subband_above(self):
        ssb_prb_offset = self.rb_info_from_pcap['ssBlockPrbOffset']
        ssb_sub_carrier_offset = self.rb_info_from_pcap['ssBlockSubCarrierOffset']
        kssb = self.rb_info_from_pcap['kSSB']
        offset_prb_dl = self.dedicated_bwp_config_from_scf['dl_rb_start']
        nbr_of_prbs_dl = self.dedicated_bwp_config_from_scf['dl_rb_size']
        starting_rb = self.ceil_4(ssb_prb_offset + ceil(kssb/24) + Const.N_OF_PRB_SSB)
        nr_of_rbs = (self.floor_4(nbr_of_prbs_dl + offset_prb_dl) -
                     self.ceil_4(ssb_prb_offset + ceil(ssb_sub_carrier_offset/12) + 20))
        self.starting_rb_and_nr_of_rbs['beam_mgmt'] = starting_rb, nr_of_rbs, self.func_name()

    def init_rb_info_for_csi_report(self):
        if self.scf_config['actCsirsMultiplexing'] == 'true':
            self.case_invalid(InvalidInfo.CHECKER_NOT_IMPLEMENTED, info_str='actCsirsMultiplexing=True')
        else:
            offset_prb_dl = self.dedicated_bwp_config_from_scf['dl_rb_start']
            nbr_of_prbs_dl = self.dedicated_bwp_config_from_scf['dl_rb_size']
            if self.revision == 0:
                starting_rb = self.ceil_4(offset_prb_dl)
                nr_of_rbs = self.floor_4(nbr_of_prbs_dl + offset_prb_dl - self.ceil_4(offset_prb_dl))
            else:  # self.revision == 1:
                starting_rb = self.floor_4(offset_prb_dl)
                nr_of_rbs = self.ceil_4(nbr_of_prbs_dl + offset_prb_dl - self.floor_4(offset_prb_dl))
            self.starting_rb_and_nr_of_rbs['csi_report'] = starting_rb, nr_of_rbs, self.func_name()
            self.starting_rb_and_nr_of_rbs['csi_im'] = starting_rb, nr_of_rbs, self.func_name()

    def init_rb_info_for_trs(self):
        bw_rbs = self.get_rbs_by_scs_and_bw()
        rb_allocation = self.scf_config['rbAllocation']
        if bw_rbs <= 52 or rb_allocation == 'BWP':
            self.init_rb_info_for_trs_rb_allocation_bwp()
        elif rb_allocation == 52:
            self.init_rb_info_for_trs_rb_allocation_52()

    def init_rb_info_for_trs_rb_allocation_bwp(self):
        offset_prb_dl = self.dedicated_bwp_config_from_scf['dl_rb_start']
        nbr_of_prbs_dl = self.dedicated_bwp_config_from_scf['dl_rb_size']
        starting_rb = self.floor_4(offset_prb_dl)
        # nr_of_rbs = min(52, self.ceil_4(nbr_of_prbs_dl + offset_prb_dl - self.floor_4(offset_prb_dl)))
        nr_of_rbs = self.ceil_4(nbr_of_prbs_dl + offset_prb_dl - self.floor_4(offset_prb_dl))
        self.starting_rb_and_nr_of_rbs['trs'] = starting_rb, nr_of_rbs, self.func_name()

    def init_rb_info_for_trs_rb_allocation_52(self):
        offset_prb_dl = self.dedicated_bwp_config_from_scf['dl_rb_start']
        nbr_of_prbs_dl = self.dedicated_bwp_config_from_scf['dl_rb_size']
        tracking_start_rb = self.scf_config['startRB']
        nbr_avl_rbs_for_trs = self.floor_4(offset_prb_dl + nbr_of_prbs_dl -
                                           max(tracking_start_rb, self.ceil_4(offset_prb_dl)))
        if nbr_avl_rbs_for_trs >= 52:
            self.init_rb_info_for_trs_avlrbs_ge_52()
        else:
            self.init_rb_info_for_trs_avlrbs_lt_52()

    def init_rb_info_for_trs_avlrbs_ge_52(self):
        offset_prb_dl = self.dedicated_bwp_config_from_scf['dl_rb_start']
        tracking_start_rb = self.scf_config['startRB']
        starting_rb = max(tracking_start_rb, self.ceil_4(offset_prb_dl))
        nr_of_rbs = 52
        self.starting_rb_and_nr_of_rbs['trs'] = starting_rb, nr_of_rbs, self.func_name()

    def init_rb_info_for_trs_avlrbs_lt_52(self):
        offset_prb_dl = self.dedicated_bwp_config_from_scf['dl_rb_start']
        nbr_of_prbs_dl = self.dedicated_bwp_config_from_scf['dl_rb_size']
        nbr_avl_rbs_for_trs_2 = self.floor_4(nbr_of_prbs_dl + offset_prb_dl - self.ceil_4(offset_prb_dl))
        if nbr_avl_rbs_for_trs_2 < 52:
            self.init_rb_info_for_trs_avlrbs2_lt_52()
        else:
            self.init_rb_info_for_trs_avlrbs2_ge_52()

    def init_rb_info_for_trs_avlrbs2_lt_52(self):
        offset_prb_dl = self.dedicated_bwp_config_from_scf['dl_rb_start']
        nbr_of_prbs_dl = self.dedicated_bwp_config_from_scf['dl_rb_size']
        starting_rb = self.floor_4(offset_prb_dl)
        # nr_of_rbs = min(52, ceil(nbr_of_prbs_dl + offset_prb_dl - starting_rb))
        nr_of_rbs = ceil(nbr_of_prbs_dl + offset_prb_dl - starting_rb)
        self.starting_rb_and_nr_of_rbs['trs'] = starting_rb, nr_of_rbs, self.func_name()

    def init_rb_info_for_trs_avlrbs2_ge_52(self):
        offset_prb_dl = self.dedicated_bwp_config_from_scf['dl_rb_start']
        starting_rb = self.ceil_4(offset_prb_dl)
        nr_of_rbs = 52
        self.starting_rb_and_nr_of_rbs['trs'] = starting_rb, nr_of_rbs, self.func_name()

    def get_rbs_by_scs_and_bw(self):
        cell_technology = self.scf_config['cellTechnology']
        scs = int(self.scf_config['scs'].split('KHz')[0])
        bw = int(self.scf_config['chBwDl' if cell_technology == 'FDD' else 'chBw'].split('MHz')[0])
        scs_bw_to_rbs = Const.SCS_BW_TO_CHANNEL_RBS_FDD if cell_technology == 'FDD' else Const.SCS_BW_TO_CHANNEL_RBS_TDD
        rbs = scs_bw_to_rbs.get(scs, {}).get(bw, None)
        if not rbs:
            self.case_invalid(InvalidInfo.FAIL_TO_LOOKUP_RBS_BY_SCS_BW, scs=scs, bw=bw, cell_technology=cell_technology)
        return rbs

    def init_cell_info_from_scf(self):
        self.info_api = InfoAPI(log_files=(self.scf_file,))
        cell_items = ["actSpecificBwpSize:", "csirsBmMgmtSubband:", "slowPrbPoolingTddFr1DlAllowed:",
                      "actCsirsMultiplexing:", "csirsForTracking->rbAllocation:", "csirsForTracking->startRB:",
                      "cellTechnology:", "chBw:", "#/NRCELL_FDD-1->chBwDl:"]
        grp_items = ["scs:"]
        self.cell_info = self.info_api.scf_get_nr_cell_info(cell_items=cell_items, grp_items=grp_items)
        if self.cell not in self.cell_info:
            self.case_invalid(InvalidInfo.CELL_NOT_FOUND_IN_SCF, cell=self.cell)
        self.validate_feature_switch(self.cell_info[self.cell])
        self.scf_config = self.cell_info[self.cell]
        self.logger.debug("final scf_config: %s" % self.scf_config)

    def init_dedicated_bwp_from_scf(self):
        self.dedicated_bwp_config_from_scf = self.info_api.scf_get_rb_start_and_size(bwp_type='dedicated',
                                                                                     cell=self.cell)
        self.logger.debug("dedicated_bwp_config_from_scf: %s" % self.dedicated_bwp_config_from_scf)

    def validate_feature_switch(self, scf_info):
        if scf_info['actSpecificBwpSize'] != 'true':
            self.case_invalid(InvalidInfo.ACT_SPECIFIC_BWP_SIZE_IS_OFF)

    def init_rb_param_from_pcap(self):
        pcap_parser = InfoParser(filename=self.pcap_file)
        pcap_info = pcap_parser.get_info(
            item_list=['ssBlockPrbOffset:', 'ssBlockSubCarrierOffset:', 'kSSB:', 'physCellId:'],
            filter_pattern='itf_l2_ps_cell_cellsetupreq',
            filter_expression='physCellId == %d' % self.scf_config['physCellId'])
        self.rb_info_from_pcap = pcap_info[0]
        self.logger.debug("rb_info_from_pcap: %s" % self.rb_info_from_pcap)

    def verify(self):
        self.verify_starting_rb_and_nr_of_rbs()
        self.case_pass()


def verify_csirs_rb_start_and_nr(log_path, scf_file, pcap_file, egate_file, cell=1, revision=1, log_level=None):
    checker = CheckCsiRsRbStartAndNr(log_path, scf_file, pcap_file, egate_file, cell=cell, revision=revision,
                                     log_level=log_level)
    checker.verify()
    checker.create_robot_file()
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
