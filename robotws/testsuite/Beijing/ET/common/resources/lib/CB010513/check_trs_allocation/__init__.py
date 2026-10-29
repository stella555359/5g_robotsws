# -*- coding: utf-8 -*-
"""
2023/03/27 first version by sheng.1.ye@nokia-sbell.com
           this is checker to verify TRS allocation for CB10513E
2023/05/08 fix subcell mapping to cell, use pooling_group_id for slotOffset check, add stats check, by Ye Sheng
2023/05/19 improve to support verify only some of cells, by Ye Sheng
"""

import unittest
from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser
from testsuite.Beijing.ET.common.resources.lib.info_api import InfoAPI
from testsuite.Beijing.ET.common.resources.lib.checker import Checker
from collections import namedtuple
import json


class Const:

    TrsInfo = namedtuple('TrsInfo', ('resourceSetId', 'slotOffset', 'symbol', 'freqDomainAllocation'))
    CSIRS_TRACKING_RESOURCE_INFO_FOR_SSB = {
        0: [TrsInfo(3, 'i', 4, 1), TrsInfo(3, 'i', 8, 1), TrsInfo(3, 'i+1', 4, 1), TrsInfo(3, 'i+1', 8, 1)],
        1: [TrsInfo(4, 'i', 4, 4), TrsInfo(4, 'i', 8, 4), TrsInfo(4, 'i+1', 4, 4), TrsInfo(4, 'i+1', 8, 4)],
        2: [TrsInfo(5, 'i', 5, 2), TrsInfo(5, 'i', 9, 2), TrsInfo(5, 'i+1', 5, 2), TrsInfo(5, 'i+1', 9, 2)],
        3: [TrsInfo(6, 'i', 5, 8), TrsInfo(6, 'i', 9, 8), TrsInfo(6, 'i+1', 5, 8), TrsInfo(6, 'i+1', 9, 8)],
        4: [TrsInfo(7, 'j', 4, 1), TrsInfo(7, 'j', 8, 1), TrsInfo(7, 'j+1', 4, 1), TrsInfo(7, 'j+1', 8, 1)],
        5: [TrsInfo(8, 'j', 4, 4), TrsInfo(8, 'j', 8, 4), TrsInfo(8, 'j+1', 4, 4), TrsInfo(8, 'j+1', 8, 4)]
    }


class InvalidInfo:
    CELL_NOT_FOUND_IN_SCF = "Cell {cell} not found in scf"
    CELL_GROUP_SETUP_REQ_NOT_FOUND = "itf_l2_ps_cell_cellgroupsetupreq not found"
    CSI_RS_SEND_REQ_NOT_FOUND = "dldata_csirssendreq not found"
    RRC_SETUP_REQ_NOT_FOUND = "rrcSetupRequest not found"
    RRC_SETUP_REQ_CSI_RS_RESOURCE_SET_NOT_FOUND = "CSI-RS Resource Set not found in rrcSetupRequest"
    RRC_SETUP_REQ_CSI_RS_RESOURCE_NOT_FOUND = "CSI-RS Resource not found in rrcSetupRequest"
    RRC_SETUP_REQ_CELL_ID_NOT_FOUND = "Cell {cell} in rrcSetupRequest not found in cellsetupreq"
    RRC_SETUP_REQ_NO_CELL_INFO = "Cell {cell} in scf not found in rrcSetupRequest"
    CELL_SETUP_REQ_NOT_FOUND = "itf_l2_ps_cell_cellsetupreq not found in C-BIP file"
    ACT_BB_POOL_EXTENSITION_TDD_FR1_IS_NOT_SET = "Rd Parameter actBbPoolExtensionTddFr1 is not set"


class FailInfo:
    TRACKING_RESOURCE_NUMBER_NOT_EQUAL_TO_SSB = "Number of Tracking Resource != ssb number(cellgrp={grp})"
    TRACKING_RESOURCE_SLOT_OFFSET_UNMATCH = ("Slot Offset in Tracking Resource of {msg} unmatch"
                                             "(cellgrp={grp}, poolinggrp={grp})")
    TRACKING_RESOURCE_SYMBOL_UNMATCH = "Symbol in Tracking Resource of {msg} unmatch(cellgrp={grp})"
    TRACKING_RESOURCE_FREQ_DOMAIN_UNMATCH = ("Freq Domain Allocation in Tracking Resource of {msg} "
                                             "unmatch(cellgrp={grp})")
    TRACKING_RESOURCE_NR_OF_PORTS_UNMATCH = "nrofPorts in Tracking Resource of {msg} unmatch(cellgrp={grp})"
    UNEXPECTED_CSIRS_TRS_SLOT_AND_SYMBOL = "Slot={slot}, Symbol={symbol} is not expected for TRS for cell={cell}"
    RRC_SETUP_REQ_CSI_RS_RESOURCE_SET_ID_INVALID = "ResourceSetId: {resource_set_id} in RRC setup req is invalid"

    UNEXPECTED_SUB_CELL_ID_IN_CSIRS_SEND_REQ = "unexpected sub_cell_id{sub_cell} in CsiRsSendReq"


class PassInfo:
    EXPECTED_CSIRS_TRS_SLOT_AND_SYMBOL = "[CsiRsSendReq] Get Expected TRS for cell={cell}: Slot={slot}, Symbol={symbol}"


class CheckTrsAllocation(Checker):

    def __init__(self, log_path, scf_file, cp_bip_file, bip_file, emil_file, swconfig_file, scf_cells,
                 *args, **kwargs):
        super().__init__(log_path, *args, **kwargs)
        self.scf_cells = scf_cells
        self.scf_file = scf_file
        self.cp_bip_file = cp_bip_file
        self.bip_file = bip_file
        self.emil_file = emil_file
        self.swconfig_file = swconfig_file
        self.info_api = None
        self.cell_info = None
        self.cp_bip_info = None
        self.cell_group_setup_info = None
        self.csi_rs_send_req_info = None
        self.rrc_setup_req_info = None
        self.rd_parameters = None

        self.init_info()

    def init_info(self):
        self.init_info_api()
        self.init_rd_parameters()
        self.init_cell_info_from_scf()
        self.init_cell_group_setup_info()
        self.init_csi_rs_send_req_info()
        self.init_rrc_setup_req_info()

    def init_info_api(self):
        self.info_api = InfoAPI(log_files=(self.scf_file, self.swconfig_file))

    def init_rd_parameters(self):
        self.rd_parameters = {}
        self.rd_parameters['actBbPoolExtensionTddFr1'] = self.info_api.swconfig_get_rd_parameter('0x58070a')
        self.rd_parameters['bellCanadaFrameType'] = self.info_api.swconfig_get_rd_parameter('0x58012b')

    def init_cell_info_from_scf(self):
        self.cell_info = self.info_api.scf_get_nr_cell_info(
            cell_items=['csiReportPeriodicity:',
                        'csirsTrackingPeriod:',
                        'csirsNumberWithinReportPeriod_Set1:',
                        '=int(csirsTrackingPeriod[:-2]) as csirsTrackingPeriod',
                        '=int(int(csiReportPeriodicity[5:])/(1<<(csirsNumberWithinReportPeriod_Set1-1))) '
                        'as csiRsPeriodicity'],
            grp_items=["numberOfTransmittedSsBlocks:"])
        for cell in self.scf_cells:
            if cell not in self.cell_info:
                self.case_invalid(InvalidInfo.CELL_NOT_FOUND_IN_SCF, cell=cell)
            self.cell_info[cell].update(self.info_api.scf_get_tdd_frame_structure_type(cell=cell))
        self.logger.debug("self.cell_info: %s" % json.dumps(self.cell_info, indent=4))

    def init_cell_group_setup_info(self):
        cp_bip_parser = InfoParser(filename=self.cp_bip_file)
        resource_info_prefix = r'csirsTrackingResourceSet_item_(\d+)->csirsTrackingResource_item_(\d+)'
        cp_bip_info = cp_bip_parser.get_info(item_list=['nrCellGrpId:',
                                                        resource_info_prefix + '->csirsTrackingSlotOffset:',
                                                        resource_info_prefix + '->csirsTrackingSymbol()',
                                                        resource_info_prefix + '->csirsTrackingFreqDomainAllocation:'],
                                             filter_pattern='itf_l2_ps_cell_cellgroupsetupreq')
        if not cp_bip_info:
            self.case_invalid(InvalidInfo.CELL_GROUP_SETUP_REQ_NOT_FOUND)
        self.cell_group_setup_info = {}
        for item in cp_bip_info:
            self.cell_group_setup_info[item['nrCellGrpId']] = item.get('group', {})
        self.logger.debug("cell_group_setup_info: %s" % json.dumps(self.cell_group_setup_info, indent=4))
        self.init_cell_id_info(cp_bip_parser)

    def init_cell_id_info(self, cp_bip_parser):
        cell_id_info = cp_bip_parser.get_info(item_list=['nrCellGrpId:', 'nrCellIdentity:', 'csirsPoolingGroupId:',
                                                         'dlSubcellId:[]'],
                                              filter_pattern='itf_l2_ps_cell_cellsetupreq')
        if cell_id_info:
            for item in cell_id_info:
                cell_group = item['nrCellGrpId']
                cell_id = item['nrCellIdentity']
                for info in self.cell_info.values():
                    if info['grp'] == cell_group:
                        info['cell_id'] = cell_id
                        info['csirsPoolingGroupId'] = item['csirsPoolingGroupId']
                        info['dlSubcellId'] = item['dlSubcellId']
        else:
            self.case_invalid(InvalidInfo.CELL_SETUP_REQ_NOT_FOUND)
        self.logger.debug("cell_id_info: %s" % json.dumps(cell_id_info, indent=4))

    def init_csi_rs_send_req_info(self):
        bip_parser = InfoParser(filename=self.bip_file)
        bip_info = bip_parser.get_info(
            item_list=["sfn:", "slot:", "subcellId:", "startSymbol:[]", "density:[]", "trsInfo:[]", "csiRsConfig:[]"],
            filter_pattern='dldata_csirssendreq', count=200, silent=True)
        if not bip_info:
            self.case_invalid(InvalidInfo.CSI_RS_SEND_REQ_NOT_FOUND)
        self.csi_rs_send_req_info = bip_info
        self.logger.debug("csi_rs_send_req_info: %s" % json.dumps(self.csi_rs_send_req_info[:10], indent=4))

    def init_rrc_setup_req_info(self):
        self.rrc_setup_req_info = {}
        emil_parser = InfoParser(filename=self.emil_file)
        rrc_setup_cell_info = emil_parser.get_info(item_list=["nRCellIdentity()"], filter_pattern='rrcSetupRequest')
        if not rrc_setup_cell_info:
            self.case_invalid(InvalidInfo.RRC_SETUP_REQ_NOT_FOUND)
        for item in rrc_setup_cell_info:
            nr_cell_id = item['nRCellIdentity']
            match_cell = [cell for cell in self.cell_info if self.cell_info[cell]['cell_id'] == nr_cell_id]
            if match_cell:
                cell = match_cell[0]
                info = self.rrc_setup_req_info.setdefault(cell, {'csi_rs_resource_set': {}, 'csi_rs_resource': {}})
                info['csi_rs_resource_set'] = self.rrc_setup_get_csi_rs_resource_set_info(item['item_id'], emil_parser)
                info['csi_rs_resource'] = self.rrc_setup_get_csi_rs_resource_info(item['item_id'], emil_parser)
            else:
                print(self.cell_info)
                self.case_invalid(InvalidInfo.RRC_SETUP_REQ_CELL_ID_NOT_FOUND, cell=nr_cell_id)
        self.logger.debug("rrc_setup_req: csi_rs_resource_and_set: %s" % json.dumps(self.rrc_setup_req_info, indent=4))

    def rrc_setup_get_csi_rs_resource_set_info(self, item_id, emil_parser):
        resource_set_prefix = r"nzp-CSI-RS-ResourceSetToAddModList->#(\d+)"
        resource_set_info = emil_parser.get_info(item_list=[resource_set_prefix + "->nzp-CSI-ResourceSetId",
                                                            resource_set_prefix + "->nzp-CSI-RS-Resources->[]",
                                                            resource_set_prefix + "->trs-Info"],
                                                 item_id_list=[item_id])
        if not resource_set_info:
            self.case_invalid(InvalidInfo.RRC_SETUP_REQ_CSI_RS_RESOURCE_SET_NOT_FOUND)
        group = resource_set_info[0].get('group', {})
        return {v['nzp-CSI-ResourceSetId']: v for v in group.values()}

    def rrc_setup_get_csi_rs_resource_info(self, item_id, emil_parser):
        resource_prefix = r"nzp-CSI-RS-ResourceToAddModList->#(\d+)"
        resource_info = emil_parser.get_info(item_list=[resource_prefix + "->nzp-CSI-RS-ResourceId",
                                                        resource_prefix + "->frequencyDomainAllocation-> find '[01]+'",
                                                        resource_prefix + "->nrofPorts",
                                                        resource_prefix + "->firstOFDMSymbolInTimeDomain",
                                                        resource_prefix + r"->periodicityAndOffset find \d+ as period",
                                                        resource_prefix + r"->periodicityAndOffset: as offset"],
                                             item_id_list=[item_id])
        if not resource_info:
            self.case_invalid(InvalidInfo.RRC_SETUP_REQ_CSI_RS_RESOURCE_NOT_FOUND)
        group = resource_info[0].get('group', {})
        return {v['nzp-CSI-RS-ResourceId']: v for v in group.values()}

    def validate_rd_parameters(self):
        if not self.rd_parameters['actBbPoolExtensionTddFr1']:
            self.case_invalid(InvalidInfo.ACT_BB_POOL_EXTENSITION_TDD_FR1_IS_NOT_SET)

    def verify_cell_group_setup(self):
        for cell in self.scf_cells:
            ssb = int(self.cell_info[cell]['numberOfTransmittedSsBlocks'].split(' ')[0])
            grp = self.cell_info[cell]['grp']
            pooling_group = self.cell_info[cell]['csirsPoolingGroupId']
            received_tracking_resource = self.cell_group_setup_info[grp]
            self.assert_equal("[cellGroupSetup] number of tracking_resource",
                              ssb, len(received_tracking_resource),
                              FailInfo.TRACKING_RESOURCE_NUMBER_NOT_EQUAL_TO_SSB.format(grp=grp),
                              classify=('cell%d' % cell, 'cellGroupSetup', 'tracking_resource_num'))
            for ssb_index in range(ssb):
                expected_resource = Const.CSIRS_TRACKING_RESOURCE_INFO_FOR_SSB[ssb_index]
                i, j = self.cell_info[cell]['I'], self.cell_info[cell]['J']
                for n, received_resource in received_tracking_resource[ssb_index].items():
                    expected = expected_resource[n]
                    self.assert_equal("[cellGroupSetup] slotOffset",
                                      eval(expected.slotOffset) + 40 * pooling_group,
                                      received_resource["csirsTrackingSlotOffset"],
                                      FailInfo.TRACKING_RESOURCE_SLOT_OFFSET_UNMATCH.format(
                                          grp=grp, pooling_group=pooling_group, msg='cellGroupSetup'),
                                      classify=('cell%d' % cell, 'cellGroupSetup', 'slotOffset'))
                    self.assert_equal("[cellGroupSetup] symbol",
                                      expected.symbol,
                                      received_resource["csirsTrackingSymbol"],
                                      FailInfo.TRACKING_RESOURCE_SYMBOL_UNMATCH.format(grp=grp, msg='cellGroupSetup'),
                                      classify=('cell%d' % cell, 'cellGroupSetup', 'symbol'))
                    self.assert_equal("[cellGroupSetup] freqDomainAllocation",
                                      expected.freqDomainAllocation,
                                      received_resource["csirsTrackingFreqDomainAllocation"],
                                      FailInfo.TRACKING_RESOURCE_FREQ_DOMAIN_UNMATCH.format(
                                          grp=grp, msg='cellGroupSetup'),
                                      classify=('cell%d' % cell, 'cellGroupSetup', 'freqDomainAllocation'))

    def verify_csi_rs_send_req(self):
        for item in self.csi_rs_send_req_info:
            # cell = item['subcellId'] // 2 + 1
            sub_cell = item['subcellId']
            for cell_id, info in self.cell_info.items():
                if sub_cell in info['dlSubcellId']:
                    cell = cell_id
                    break
            else:
                self.case_fail(FailInfo.UNEXPECTED_SUB_CELL_ID_IN_CSIRS_SEND_REQ, sub_cell=sub_cell)
                return
            if cell in self.scf_cells:
                tracking_slots = self.cell_info[cell]['csirsTrackingPeriod'] * 2
                current_slot = ((item['sfn'] * 20) + item['slot']) % tracking_slots
                trs_info_list = item['trsInfo']
                start_symbol_list = item['startSymbol']
                for n, start_symbol in enumerate(start_symbol_list):
                    if trs_info_list[n] == 'ENABLED':
                        self.validate_csirs_trs_slot_and_symbol(current_slot, start_symbol, cell)

    def validate_csirs_trs_slot_and_symbol(self, slot, symbol, cell):
        grp = self.cell_info[cell]['grp']
        cell_group_trs_info = self.cell_group_setup_info[grp]
        for resource in cell_group_trs_info.values():
            for expected in resource.values():
                if expected['csirsTrackingSlotOffset'] == slot and expected['csirsTrackingSymbol'] == symbol:
                    self.assert_true(PassInfo.EXPECTED_CSIRS_TRS_SLOT_AND_SYMBOL
                                     .format(slot=slot, symbol=symbol, cell=cell), True,
                                     classify=['cell%d' % cell, 'csiRsSendReq', 'Slot and Symbol'],
                                     classify_value=(slot, symbol))
                    return True
        self.case_fail(FailInfo.UNEXPECTED_CSIRS_TRS_SLOT_AND_SYMBOL, slot=slot, symbol=symbol, cell=cell)
        return False

    def verify_rrc_setup_req(self):
        for cell in self.scf_cells:
            if cell not in self.rrc_setup_req_info:
                self.case_invalid(InvalidInfo.RRC_SETUP_REQ_NO_CELL_INFO, cell=cell)
            grp = self.cell_info[cell]['grp']
            csi_rs_resource = self.rrc_setup_req_info[cell]['csi_rs_resource']
            csi_rs_resource_set = self.rrc_setup_req_info[cell]['csi_rs_resource_set']
            self.validate_csi_rs_resource_info(grp, csi_rs_resource, csi_rs_resource_set)

    def validate_csi_rs_resource_info(self, grp, csi_rs_resource, csi_rs_resource_set):
        for resource_set_id, resource_set_info in csi_rs_resource_set.items():
            if resource_set_info.get("trs-Info", False) == "true":
                ssb_index = [i for i, item in Const.CSIRS_TRACKING_RESOURCE_INFO_FOR_SSB.items()
                             if item[0].resourceSetId == resource_set_id]
                if not ssb_index:
                    self.case_fail(FailInfo.RRC_SETUP_REQ_CSI_RS_RESOURCE_SET_ID_INVALID,
                                   resource_set_id=resource_set_id)
                for n, resource_id in enumerate(resource_set_info['nzp-CSI-RS-Resources']):
                    self.validate_rrc_setup_req_time_and_slot_info(csi_rs_resource[resource_id], ssb_index[0], grp, n)

    def validate_rrc_setup_req_time_and_slot_info(self, resource_info, ssb_index, grp, index_in_ssb):
        freq_domain_allocation = int(resource_info['frequencyDomainAllocation'].split("'")[1], 2)
        nr_of_ports = resource_info['nrofPorts']
        symbol = resource_info['firstOFDMSymbolInTimeDomain']
        cell_group_trs_info = self.cell_group_setup_info[grp][ssb_index][index_in_ssb]
        expected_freq_domain_allocation = cell_group_trs_info['csirsTrackingFreqDomainAllocation']
        expected_nr_of_ports = "p1"
        expected_symbol = cell_group_trs_info['csirsTrackingSymbol']
        self.assert_equal("[rrcSetupRequest] frequencyDomainAllocation",
                          expected_freq_domain_allocation, freq_domain_allocation,
                          FailInfo.TRACKING_RESOURCE_FREQ_DOMAIN_UNMATCH.format(grp=grp, msg='rrcSetupRequest'),
                          classify=('cellGroup%d' % grp, 'rrcSetupRequest', 'frequencyDomainAllocation'))
        self.assert_equal("[rrcSetupRequest] symbol",
                          expected_symbol, symbol,
                          FailInfo.TRACKING_RESOURCE_SYMBOL_UNMATCH.format(grp=grp, msg='rrcSetupRequest'),
                          classify=('cellGroup%d' % grp, 'rrcSetupRequest', 'symbol')
                          )
        self.assert_equal("[rrcSetupRequest] nrofPorts",
                          expected_nr_of_ports, nr_of_ports,
                          FailInfo.TRACKING_RESOURCE_NR_OF_PORTS_UNMATCH.format(grp=grp, msg='rrcSetupRequest'),
                          classify=('cellGroup%d' % grp, 'rrcSetupRequest', 'nr_of_ports')
                          )

    def get_stats_parameters(self):
        stats_param = []
        for cell in self.scf_cells:
            for item in ['cellGroupSetup', 'csiRsSendReq']:
                stats_param.append(['cell%d' % cell, item])
            info = self.cell_info[cell]
            cell_group = info['grp']
            for item in ['rrcSetupRequest']:
                stats_param.append(['cellGroup%d' % cell_group, item])
        return stats_param

    def verify(self):
        self.validate_rd_parameters()
        self.verify_cell_group_setup()
        self.verify_csi_rs_send_req()
        self.verify_rrc_setup_req()
        stats_param = self.get_stats_parameters()
        self.case_pass(stats_param=stats_param)


def verify_trs_allocation(log_path, scf_file, cp_bip_file, bip_file, emil_file, swconfig_file, scf_cells=(1, 2, 3),
                          log_level=None):
    checker = CheckTrsAllocation(log_path, scf_file, cp_bip_file, bip_file, emil_file, swconfig_file,
                                 scf_cells=scf_cells, log_level=log_level)
    checker.create_robot_file()
    checker.verify()
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
