# -*- coding: utf-8 -*-
"""
2022/08/30 first version by sheng.1.ye@nokia-sbell.com
           this is the checker to verify correctness of csi rs startprb and nrofrb for blanking prb
2022/09/15 support specified cell id, by Ye Sheng
"""

import unittest
from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser
from testsuite.Beijing.ET.common.resources.lib.info_api import InfoAPI
from testsuite.Beijing.ET.common.resources.lib.checker import Checker


class InvalidInfo:
    ACT_SPECIFIC_BWP_SIZE_IS_ON = 'The parameter actSpecificBwpSize in scf is "true"'
    ACT_PRB_BLANKING_IS_OFF = 'The parameter actPRBBlanking in scf is not "true"'

    CHECKER_NOT_IMPLEMENTED = "Checker Not implemented for '{info_str}'"
    FAIL_TO_LOOKUP_RBS_BY_SCS_BW = "Fail to lookup RBs by scs={scs}, bw={bw}, cell_technology={cell_technology}"
    NO_CSI_RS_RB_INFO_FOUND_IN_EGATE = "No CSI RS startingRB and nrofRBs info in egate file {egate_file}"
    CELL_NOT_FOUND_IN_SCF = "Cell {cell} not found in scf"


class FailInfo:
    UNEXPECTED_CSIRS_STARTING_RB = "startingRB in type {csi_type} does not match expected value"
    UNEXPECTED_CSIRS_NR_OF_RBS = "nrofRBs in type {csi_type} does not match expected value"


class Const:
    SCS_BW_TO_CHANNEL_RBS_TDD = {
        30: {5: 11, 10: 24, 15: 38, 20: 51, 25: 65, 30: 78, 40: 106,
             50: 133, 60: 162, 70: 189, 80: 217, 90: 245, 100: 273}
    }
    SCS_BW_TO_CHANNEL_RBS_FDD = {
        15: {5: 25, 10: 52, 15: 79, 20: 106, 25: 133, 30: 160, 40: 216}
    }


class CheckCsiRsRbStartAndNrForBlanking(Checker):

    def __init__(self, log_path, scf_file, egate_file, cell=1, *args, **kwargs):
        super().__init__(log_path, *args, **kwargs)
        self.cell = cell
        self.cell_info = {}
        self.info_api = None
        self.scf_file = scf_file
        self.egate_file = egate_file
        self.scf_config = None
        self.carrier_bw_nrbs = None
        self.starting_rb_and_nr_of_rbs = None
        self.rb_info_from_egate = None
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
        self.carrier_bw_nrbs = self.get_rbs_by_scs_and_bw()
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
        self.init_rb_info_for_csi_report()
        self.init_rb_info_for_trs()
        self.logger.debug("starting_rb_and_nr_of_rbs: %s" % self.starting_rb_and_nr_of_rbs)

    def init_rb_info_for_csi_report(self):
        starting_rb = self.get_starting_prb_for_csi_report()
        nr_of_rbs = self.get_nr_of_prb_for_csi_report()
        self.starting_rb_and_nr_of_rbs['csi_report'] = starting_rb, nr_of_rbs, self.func_name()
        self.starting_rb_and_nr_of_rbs['csi_im'] = starting_rb, nr_of_rbs, self.func_name()

    def get_starting_prb_for_csi_report(self):
        if self.scf_config['actCsirsMultiplexing'] == 'true':
            self.case_invalid(InvalidInfo.CHECKER_NOT_IMPLEMENTED, info_str='actCsirsMultiplexing=True')
        offset_prb_dl = self.scf_config['nbrOfBlankedPRBsLowEdgeDL']
        starting_rb = self.ceil_4(offset_prb_dl)
        return starting_rb

    def get_nr_of_prb_for_csi_report(self):
        if self.scf_config['lteNrDssMode'] not in ('none', None):
            self.case_invalid(InvalidInfo.CHECKER_NOT_IMPLEMENTED, info_str='lteNrDssMode!=none')
        reduced_nbr_of_prbs_dl_high_edge = self.scf_config['nbrOfBlankedPRBsHighEdgeDL']
        reduced_nbr_of_prbs_dl_low_edge = self.scf_config['nbrOfBlankedPRBsLowEdgeDL']
        if reduced_nbr_of_prbs_dl_high_edge == 0:
            if self.scf_config['actCsirsMultiplexing'] == 'true':
                self.case_invalid(InvalidInfo.CHECKER_NOT_IMPLEMENTED, info_str='actCsirsMultiplexing=True')
            if reduced_nbr_of_prbs_dl_low_edge == 0:
                self.case_invalid(InvalidInfo.CHECKER_NOT_IMPLEMENTED, info_str='nbrOfBlankedPRBsLowEdgeDL=0')
            nr_of_rb = self.ceil_4(self.carrier_bw_nrbs - self.ceil_4(reduced_nbr_of_prbs_dl_low_edge))
        else:
            nr_of_rb = self.floor_4(self.carrier_bw_nrbs - self.ceil_4(reduced_nbr_of_prbs_dl_low_edge) -
                                    reduced_nbr_of_prbs_dl_high_edge)
        return nr_of_rb

    def init_rb_info_for_trs(self):
        rb_allocation = self.scf_config['rbAllocation']
        if self.carrier_bw_nrbs <= 52 or rb_allocation == 'BWP':
            starting_rb = 0
            nr_of_rbs = self.ceil_4(self.carrier_bw_nrbs)
            self.starting_rb_and_nr_of_rbs['trs'] = starting_rb, nr_of_rbs, self.func_name()
        else:
            self.case_invalid(InvalidInfo.CHECKER_NOT_IMPLEMENTED, info_str='carrierBwNrbs>52 and rbAllocation!=BWP')

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
        cell_items = ["actSpecificBwpSize:", "actPRBBlanking:", "nbrOfBlankedPRBsLowEdgeDL:",
                      "nbrOfBlankedPRBsHighEdgeDL:", "lteNrDssMode:", "slowPrbPoolingTddFr1DlAllowed:",
                      "csirsBmMgmtSubband:", "slowPrbPoolingTddFr1DlAllowed:",
                      "actCsirsMultiplexing:", "csirsForTracking->rbAllocation:",
                      "cellTechnology:", "chBw:", "#/NRCELL_FDD-1->chBwDl:"]
        grp_items = ["scs:"]
        self.cell_info = self.info_api.scf_get_nr_cell_info(cell_items=cell_items, grp_items=grp_items)
        if self.cell not in self.cell_info:
            self.case_invalid(InvalidInfo.CELL_NOT_FOUND_IN_SCF, cell=self.cell)
        self.validate_feature_switch(self.cell_info[self.cell])
        self.scf_config = self.cell_info[self.cell]
        self.logger.debug("final scf_config: %s" % self.scf_config)

    def validate_feature_switch(self, scf_info):
        if scf_info['actSpecificBwpSize'] == 'true':
            self.case_invalid(InvalidInfo.ACT_SPECIFIC_BWP_SIZE_IS_ON)
        if scf_info['actPRBBlanking'] != 'true':
            self.case_invalid(InvalidInfo.ACT_PRB_BLANKING_IS_OFF)

    def verify(self):
        self.verify_starting_rb_and_nr_of_rbs()
        self.case_pass()


def verify_csirs_rb_start_and_nr_for_blanking(log_path, scf_file, egate_file, cell=1, log_level=None):
    checker = CheckCsiRsRbStartAndNrForBlanking(log_path, scf_file, egate_file, cell=cell, log_level=log_level)
    checker.verify()
    checker.create_robot_file()
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
