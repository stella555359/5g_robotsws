# -*- coding: utf-8 -*-
"""
2022/06/01 first version by sheng.1.ye@nokia-sbell.com
           this is the checker to verify Csi Rs Resource Allocation
2022/06/09 update to fit new base class Checker
2022/06/14 refactoring and fix tdLte frame structure check, by Ye Sheng
2022/06/17 skip slot when actPciBasedCsiImRandomization=True and bi=6, by Ye Sheng
2022/06/30 update format of item_list, by Ye Sheng
2022/09/15 support specified cell id, by Ye Sheng
"""

import unittest
from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser
from testsuite.Beijing.ET.common.resources.lib.info_api import InfoAPI
from testsuite.Beijing.ET.common.resources.lib.checker import Checker


class InvalidInfo:
    NO_SCF_CONFIG = "No config found in scf config"
    NO_RRC_RECONFIGURATION = "No RRCReconfiguration found in message log"
    CSI_RS_RESOURCE_INCOMPLETE = "Csi Rs Resource information is not complete in RRCReconfiguration"
    UNSUPPORTED_FRAME_STRUCTURE = "Unsupported Frame Structure: {frame_structure}"
    UNKNOWN_PORT = "Unknown port: {port}, (1, 4 or 8 are expected)"
    UNSUPPORTED_GUARDPERIODLENGTH = "Unsupported guardPeriodLength: {guard_period_length}"
    NO_ROW4_ROW8_CSIRS_CONFIG = "No row4 or row8 config for Csi Rs config"
    CELL_NOT_FOUND_IN_SCF = "Cell {cell} not found in scf"


class FailInfo:
    OFFSET_UNMATCH = "Csi-Rs slot offset in <RRC Reconfiguration> message NOT match expected offset"
    PERIOD_UNMATCH = "Csi-Rs period in <RRC Reconfiguration> message NOT match expected period"
    START_SYMBOL_UNMATCH = "Csi-Rs start symbol in <RRC Reconfiguration> message NOT match expected start symbol"


class Const:
    FRAME_STRUCTURE_TO_BI_UL_SLOTS_MAP = {
        ('semiStatic', '1/4', None): {'BI': [3, 8], 'UL': [4, 9]},
        ('semiStatic', '3/7', None): {'BI': [3, 7], 'UL': [4, 8, 9]},
        ('tdLte', None, '0ms'): {'BI': [3], 'UL': [4, 5]}}
    START_SYMBOL_MAP = {
        'ss_slot_act_pdsch': {1: [13], 2: [13], 4: [12], 6: None},
        'ss_slot': {1: [13], 2: [13], 4: [12], 6: [12, 12, 6, 6]},
        'trs_slot': {1: [13], 2: [13], 4: [12], 6: None},
        'bi_10_slot': {1: [9], 2: [9], 4: [8], 6: [8, 8, 6, 6]},
        'bi_6_slot': {1: [5], 2: [5], 4: [4], 6: [4, 4, 2, 2]},
        'dl_14_slot': {1: [13], 2: [13], 4: [12], 6: [12, 12, 10, 10]}
    }


class CheckCellCsiRsAllocation(Checker):

    def __init__(self, log_path, scf_file, msg_file, cell=1, *args, **kwargs):
        super().__init__(log_path, *args, **kwargs)
        self.cell = cell
        self.cell_info = {}
        self.info_api = None
        self.scf_file = scf_file
        self.msg_file = msg_file
        self.scf_config = {}
        self.csi_rs_info = {}
        self.csi_rs_allocation_info = {}
        self.bi_slots = []
        self.ul_slots = []
        self.trs_slots = []
        self.trs_period = 0
        self.ssb_slots = []
        self.ssb_period = 0
        self.init_info()

    def init_info(self):
        self.init_cell_info_from_scf()
        self.init_csi_rs_info_from_msg()
        self.init_csi_rs_allocation_info()
        self.init_trs_slots_and_period()
        self.init_ssb_slots_and_period()
        self.init_bi_and_ul_slots()

    def init_cell_info_from_scf(self):
        self.info_api = InfoAPI(log_files=(self.scf_file,))
        cell_items, grp_items = self.get_scf_cell_and_grp_items()
        self.cell_info = self.info_api.scf_get_nr_cell_info(cell_items=cell_items, grp_items=grp_items)
        if self.cell not in self.cell_info:
            self.case_invalid(InvalidInfo.CELL_NOT_FOUND_IN_SCF, cell=self.cell)
        self.scf_config = self.cell_info[self.cell]
        self.logger.debug("final scf_config: %s" % self.scf_config)

    def get_scf_cell_and_grp_items(self):
        return ['cellCsiRsImLocationMode:',
                'actPciBasedCsiImRandomization:',
                'physCellId:',
                'actPdschAtSsbSlots:',
                'actPdschRmCsirsForTracking:',
                'frameStructureType:',
                'guardPeriodLength:',
                'ulDlDataSlotRatio:',
                'lteToNrFrameShift:',
                'cellCsiRsLocationList->firstOFDMSymbol:[]',
                'cellCsiRsLocationList->offset:[]'], ['numberOfTransmittedSsBlocks:', 'ssBurstSetPeriod:']

    def init_csi_rs_info_from_msg(self):
        msg_parser = InfoParser(filename=self.msg_file)
        item_list = self.make_csi_rs_info_items(cell_type='pcell')
        csi_rs_info = msg_parser.get_info(item_list=item_list, filter_pattern=r'RRCReconfiguration',
                                          filter_expression='physCellId == %d' % self.scf_config['physCellId'],
                                          count=1)
        self.validate_csi_rs_info(csi_rs_info)
        self.csi_rs_info = csi_rs_info[0]

    def make_csi_rs_info_items(self, cell_type='pcell'):
        node_type = 'spCellConfig->' if cell_type == 'pcell' else 'sCellToAddModList->'
        if self.get_msg_file_type() != 'pcap':
            item_list = ['nzp-CSI-RS-ResourceToAddModList->firstOFDMSymbolInTimeDomain[] as firstOFDMSymbolList',
                         'nzp-CSI-RS-ResourceToAddModList->periodicityAndOffset[] as periodicityAndOffsetList',
                         'nzp-CSI-RS-ResourceToAddModList->nrofPorts[] as nrofPortsList',
                         'physCellId']
        else:
            item_list = ['nzp-CSI-RS-ResourceToAddModList->firstOFDMSymbolInTimeDomain:[] as firstOFDMSymbolList',
                         'nzp-CSI-RS-ResourceToAddModList->periodicityAndOffset->[] as periodicityAndOffsetList',
                         'nzp-CSI-RS-ResourceToAddModList->nrofPorts:[] as nrofPortsList',
                         'physCellId:']
        item_list = [node_type + i for i in item_list]
        return item_list

    def get_msg_file_type(self):
        return 'egate' if 'egate' in self.msg_file else 'pcap'

    def validate_csi_rs_info(self, csi_rs_info):
        self.logger.debug(csi_rs_info)
        if not csi_rs_info or not csi_rs_info[0]:
            self.case_invalid(InvalidInfo.NO_RRC_RECONFIGURATION)
        if not all((csi_rs_info[0]['nrofPortsList'],
                    csi_rs_info[0]['firstOFDMSymbolList'], csi_rs_info[0]['periodicityAndOffsetList'])):
            self.case_invalid(InvalidInfo.CSI_RS_RESOURCE_INCOMPLETE)

    def init_csi_rs_allocation_info(self):
        allocation_info = self.make_csi_rs_allocation_info()
        self.validate_csi_rs_allocation_info(allocation_info)
        self.csi_rs_allocation_info = allocation_info

    def make_csi_rs_allocation_info(self):
        allocation_info = {}
        for port, symbol, offset in zip(self.csi_rs_info['nrofPortsList'],
                                        self.csi_rs_info['firstOFDMSymbolList'],
                                        self.csi_rs_info['periodicityAndOffsetList']):
            self.counters['Port_%s' % port] += 1
            info = allocation_info.setdefault(port, {'symbol': [], 'offset': [], 'period': []})
            info['symbol'].append(symbol)
            info['offset'].append(int(offset.split(':')[1]))
            info['period'].append(int(offset.split(':')[0][5:]))
        return allocation_info

    def validate_csi_rs_allocation_info(self, allocation_info):
        if 'p4' not in allocation_info and 'p8' not in allocation_info:
            self.case_invalid(InvalidInfo.NO_ROW4_ROW8_CSIRS_CONFIG)
        for port in allocation_info:
            if port not in ('p1', 'p4', 'p8'):
                self.case_invalid(InvalidInfo.UNKNOWN_PORT.format(port=port))

    def init_trs_slots_and_period(self):
        if 'p1' in self.csi_rs_allocation_info:
            self.trs_slots = self.csi_rs_allocation_info['p1']['offset']
            self.trs_period = self.csi_rs_allocation_info['p1']['period']

    def init_ssb_slots_and_period(self):
        self.ssb_slots = self.get_ssb_slots()
        self.ssb_period = self.scf_config['ssBurstSetPeriod'] * 2

    def init_bi_and_ul_slots(self):
        slots_map = Const.FRAME_STRUCTURE_TO_BI_UL_SLOTS_MAP
        frame_structure = self.validate_frame_structure()
        self.bi_slots = slots_map[frame_structure]['BI']
        self.ul_slots = slots_map[frame_structure]['UL']

    def validate_frame_structure(self):
        frame_structure = [self.scf_config['frameStructureType'], self.scf_config['ulDlDataSlotRatio'],
                           self.scf_config['lteToNrFrameShift']]
        if frame_structure[0] == 'semiStatic' and frame_structure[1] in ('1/4', '3/7'):
            frame_structure[2] = None
        elif frame_structure[0] == 'tdLte' and frame_structure[2] == '0ms':
            frame_structure[1] = None
        else:
            self.case_invalid(InvalidInfo.UNSUPPORTED_FRAME_STRUCTURE.format(frame_structure=frame_structure))
        return tuple(frame_structure)

    def verify(self):
        self.verify_csirs_allocation()
        self.case_pass()

    def verify_csirs_allocation(self):
        for port, info in self.csi_rs_allocation_info.items():
            if port in ('p4', 'p8'):
                self.verify_csi_rs_allocation(port, info)

    def verify_csi_rs_allocation(self, port, info):
        if self.scf_config['cellCsiRsImLocationMode'] == 'manual':
            self.verify_csirs_allocation_manual(port, info)
        else:
            self.verify_csirs_allocation_automatic(port, info)

    def verify_csirs_allocation_manual(self, port, info):
        self.logger.debug("port: %s, info: %s" % (port, info))
        self.assert_equal('start symbol', self.scf_config['firstOFDMSymbol'], info['symbol'],
                          FailInfo.START_SYMBOL_UNMATCH)
        self.assert_equal('offset', self.scf_config['offset'], info['offset'], FailInfo.OFFSET_UNMATCH)
        self.logger.debug('match(expected=real): slot: %s, start symbols: %s' % (info['offset'], info['symbol']))

    def verify_csirs_allocation_automatic(self, port, info):
        self.logger.debug("port: %s, info: %s" % (port, info))
        csi_im_random = self.scf_config['actPciBasedCsiImRandomization'] == 'true'
        csirs_slot_0 = self.get_csirs_init_slot(csi_im_random)
        period = 40
        for s in range(period):
            slot = (csirs_slot_0 + s) % period
            if self.match_slot(slot, period, info, csi_im_random):
                break

    def get_csirs_init_slot(self, csi_im_random):
        phys_cellid = self.scf_config['physCellId']
        return phys_cellid % 21 if csi_im_random else (phys_cellid % 11 * 7) % 40

    def match_slot(self, slot, period, info, csi_im_random):
        if self.is_ul_slot(slot):
            return False
        elif csi_im_random and (self.is_ssb_slot(slot, period) or self.is_trs_slot(slot, period)):
            return False
        elif self.is_ssb_slot(slot, period):
            return self.verify_ss_slot(slot, period, info)
        elif self.is_trs_slot(slot, period):
            return self.verify_trs_slot(slot, period, info)
        elif self.is_bi_slot(slot):
            return self.verify_bi_slot(slot, period, info, csi_im_random)
        else:
            return self.verify_dl14_slot(slot, period, info)

    def verify_ss_slot(self, slot, period, info):
        if self.scf_config['actPdschAtSsbSlots'] == 'true':
            return self.compare_offset_and_start_symbol(slot, period, info, 'ss_slot_act_pdsch')
        else:
            return self.compare_offset_and_start_symbol(slot, period, info, 'ss_slot')

    def verify_trs_slot(self, slot, period, info):
        return self.compare_offset_and_start_symbol(slot, period, info, 'trs_slot')

    def verify_bi_slot(self, slot, period, info, csi_im_random):
        bi = self.get_bi_type()
        if bi == 10:
            return self.compare_offset_and_start_symbol(slot, period, info, 'bi_10_slot')
        elif bi == 6 and not csi_im_random:
            return self.compare_offset_and_start_symbol(slot, period, info, 'bi_6_slot')
        return None

    def verify_dl14_slot(self, slot, period, info):
        return self.compare_offset_and_start_symbol(slot, period, info, 'dl_14_slot')

    def compare_offset_and_start_symbol(self, slot, period, info, slot_type):
        num_of_ssb = self.get_num_of_ssb()
        expected_symbol = Const.START_SYMBOL_MAP[slot_type].get(num_of_ssb, {})
        if expected_symbol:
            self.assert_equal('offset', slot, info['offset'][0], FailInfo.OFFSET_UNMATCH)
            self.assert_equal('period', period, info['period'][0], FailInfo.PERIOD_UNMATCH)
            self.assert_equal('start symbol', expected_symbol, info['symbol'], FailInfo.START_SYMBOL_UNMATCH)
            self.logger.debug('match(expected=real): slot: %s, start symbols: %s' % (slot, expected_symbol))
            return True
        return False

    def is_ssb_slot(self, slot, period):
        return slot in self.ssb_slots

    def is_trs_slot(self, slot, period):
        return slot in self.trs_slots

    def is_bi_slot(self, slot):
        return slot % 10 in self.bi_slots

    def get_bi_type(self):
        if self.scf_config['guardPeriodLength'] not in ('2Symbols', '4Symbols'):
            self.case_invalid(InvalidInfo.UNSUPPORTED_GUARDPERIODLENGTH.format(
                              guard_period_length=self.scf_config['guardPeriodLength']))
        return {'2Symbols': 10, '4Symbols': 6}[self.scf_config['guardPeriodLength']]

    def is_ul_slot(self, slot):
        return slot % 10 in self.ul_slots

    def get_num_of_ssb(self):
        return int(self.scf_config['numberOfTransmittedSsBlocks'].split(' ')[0])

    def get_ssb_slots(self):
        return {1: [0], 2: [0], 4: [0, 1], 6: [0, 1, 2]}[self.get_num_of_ssb()]


def verify_cell_csirs_allocation(log_path, scf_file, msg_file, cell=1, log_level=None):
    checker = CheckCellCsiRsAllocation(log_path, scf_file, msg_file, cell=cell, log_level=log_level)
    checker.verify()
    checker.create_robot_file()
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
