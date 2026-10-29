# -*- coding: utf-8 -*-
"""
2022/08/23 first version by sheng.1.ye@nokia-sbell.com
           this is the checker to verify pusch rb allocation
2022/09/14 support specified cell id, by Ye Sheng
"""

import math
import unittest
from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser
from testsuite.Beijing.ET.common.resources.lib.info_api import InfoAPI
from testsuite.Beijing.ET.common.resources.lib.checker import Checker


class InvalidInfo:
    UL_FD_SCHED_DATA_NOT_FOUND = 'Message type==ulFdSchedData not found in tti_ul file'
    ACT_SPECIFIC_BWP_SIZE_IS_OFF = 'The parameter actSpecificBwpSize in scf is not "true"'
    CHECKER_IS_IMPLEMENTED_ONLY_FOR_TDD = "Checker is only implemented for TDD"
    PRACH_RANGE_EXCEED_DEDICATED_PRB_RANGE = "Calculated PRACH range exceed dedicated PRB range"
    LONG_PUCCH_START_PUSCH_PRB_DEDICATED_NOT_FOUND = "longPucchStartPuschPrb not found for cell: {cell}"
    CELL_NOT_FOUND_IN_SCF = "Cell {cell} not found in scf"


class FailInfo:
    UNEXPECTED_START_PRB = ("StartPrb: {start_prb} != {expected_start_prb}(expected)\n"
                            "file:{filename}\nrecord:{record_id}")
    UNEXPECTED_NUM_OF_PRB = ("NumOfPrb: {num_of_prb} != {expected_num_of_prb}(expected)\n"
                             "file: {filename}\nrecord: {record_id}")
    PRB_RANGE_EXCEED = ("prb_range: {prb_range} exceed {expected_prb_range}(expected)\n"
                        "file:{filename}\nrecord:{record_id}")


class WarnInfo:
    PRB_VALUE_IS_NOT_INT = ("StartPrb:{start_prb} or NumOfPrb:{num_of_prb} in TTIL log is not integer\n"
                            "file:{filename}\nrecord:{record_id}")


class Const:
    PRACH_GUARD_PRB_NUM = 2
    MSG1_FDM = 1
    EVEN_SFN = 0
    ODD_SFN = 1

    RACH_TONES_RACH_SCS = {
        "cell_technology == 'TDD'": {
            "nrarfcn <= 800000": {
                "prach_config_index<= 39": {'rach_tones': 839, 'rach_scs': 1.25},
                "prach_config_index<= 66": {'rach_tones': 839, 'rach_scs': 5},
                "True": {'rach_tones': 139, 'rach_scs': 30},
            },
            "nrarfcn >= 2016667": {'rach_tones': 139, 'rach_scs': 120}
        },
        "cell_technology=='FDD'": {'rach_tones': 839, 'rach_scs': 1.25},
    }

    PRACH_SLOT = {
        "cell_technology == 'TDD'": {
            "nrarfcn <= 800000": {
                "prach_config_index==93": {'prach_slot': [(ODD_SFN, 9), (ODD_SFN, 19)]}
            }
        }
    }

    UL_SLOT = {
        "cell_technology == 'TDD'": {
            "nrarfcn <= 800000": {
                "(frame_structure_type, guard_period_length, ul_dl_data_slot_ratio) == ('semiStatic', 2, '1/4')":
                    {'ul_slot': [(EVEN_SFN, 4), (EVEN_SFN, 9), (EVEN_SFN, 14), (EVEN_SFN, 19),
                                 (ODD_SFN, 4), (ODD_SFN, 14)]}
            }
        }
    }


class CheckPuschRbAllcation(Checker):

    def __init__(self, log_path, scf_file, egate_file, pcap_file, tti_ul_file, pucch_rb_number, cell=1,
                 *args, **kwargs):
        super().__init__(log_path, *args, **kwargs)
        self.cell = cell
        self.cell_info = {}
        self.info_api = None
        self.pucch_rb_number = pucch_rb_number
        self.scf_file = scf_file
        self.egate_file = egate_file
        self.tti_ul_file = tti_ul_file
        self.pcap_file = pcap_file
        self.scf_config = None
        self.dedicated_bwp_config_from_scf = None
        self.initial_bwp_config_from_scf = None
        self.info_api = None
        self.init_info()

    def init_info(self):
        self.info_api = InfoAPI(log_files=(self.scf_file, self.pcap_file))
        self.init_cell_info_from_scf()
        self.update_pucch_rb_number()
        self.dedicated_bwp_config_from_scf = self.info_api.scf_get_rb_start_and_size(bwp_type='dedicated',
                                                                                     cell=self.cell)
        self.initial_bwp_config_from_scf = self.info_api.scf_get_rb_start_and_size(bwp_type='initial', cell=self.cell)
        self.logger.debug(self.initial_bwp_config_from_scf)

    def update_pucch_rb_number(self):
        if self.pucch_rb_number is None:
            pcap_parser = InfoParser(filename=self.pcap_file)
            item_list = ["cellBwpList->longPucchStartPuschPrb_item_0:[]", "cellBwpList->bwpType:[]", "physCellId:"]
            r = pcap_parser.get_info(item_list, filter_pattern='itf_l2_ps_cell_cellsetupreq',
                                     filter_expression='physCellId == %d' % self.scf_config['physCellId'])
            if not r or 'dedicated' not in r[0]['bwpType']:
                self.case_invalid(InvalidInfo.LONG_PUCCH_START_PUSCH_PRB_DEDICATED_NOT_FOUND.
                                  format(self.scf_config['physCellId']))
            self.pucch_rb_number = 2 * r[0]['longPucchStartPuschPrb_item_0'][r[0]['bwpType'].index('dedicated')]

    def init_cell_info_from_scf(self):
        cell_items = ["actSpecificBwpSize:", "msg1FrequencyStart:", "frameStructureType:", "guardPeriodLength:",
                      "ulDlDataSlotRatio:", "cellTechnology:", "prachConfigurationIndex:", "nrarfcn:"]
        grp_items = ["scs:"]
        self.cell_info = self.info_api.scf_get_nr_cell_info(cell_items=cell_items, grp_items=grp_items)
        if self.cell not in self.cell_info:
            self.case_invalid(InvalidInfo.CELL_NOT_FOUND_IN_SCF, cell=self.cell)
        self.validate_feature_switch(self.cell_info[self.cell])
        self.scf_config = self.cell_info[self.cell]
        self.scf_config['guardPeriodLength'] = int(self.scf_config['guardPeriodLength'].rstrip("Symbols"))
        self.scf_config['scs'] = int(self.scf_config['scs'].rstrip("KHz"))
        self.logger.debug("final scf_config: %s" % self.scf_config)

    def validate_feature_switch(self, scf_info):
        if scf_info['cellTechnology'] != 'TDD':
            self.case_invalid(InvalidInfo.CHECKER_IS_IMPLEMENTED_ONLY_FOR_TDD)
        if scf_info['actSpecificBwpSize'] != 'true':
            self.case_invalid(InvalidInfo.ACT_SPECIFIC_BWP_SIZE_IS_OFF)

    def verify_pusch_allocation(self):
        pusch_allocation_info = [
            self.get_pusch_allocation_info_ul_data(),
            self.get_pusch_allocation_info_prach()
        ]
        self.logger.debug("pusch_allocation_info: %s" % pusch_allocation_info)
        self.verify_pusch_allocation_with_tti_data(pusch_allocation_info)

    def verify_pusch_allocation_with_tti_data(self, pusch_allocation_info):
        parser = InfoParser(filename=self.tti_ul_file)
        result = parser.get_info(
            item_list=['type', 'sfn', 'slot', 'rnti', 'numOfPrb', 'startPrb', 'physCellId'],
            filter_expression="type=='ulFdSchedData' and physCellId == %d" % self.scf_config['physCellId'])
        if not result:
            self.case_invalid(InvalidInfo.UL_FD_SCHED_DATA_NOT_FOUND)
        self.counters['ulFdSchedData'] = len(result)
        self.verify_prb_start_and_size(result, pusch_allocation_info, self.tti_ul_file)

    def verify_prb_start_and_size(self, result, pusch_allocation_info, filename):
        for item in result:
            for info in pusch_allocation_info:
                slots, expected_prb_range_list, slot_type = info['slot_info'], info['prb_info_list'], info['slot_type']
                if (item['sfn'] % 2, item['slot']) in slots and 10 < item['rnti'] < 65535:
                    self.verify_prb_for_tti_item(expected_prb_range_list, filename, item, slot_type)

    def verify_prb_for_tti_item_exact(self, expected_start_prb, expected_num_of_prb, filename, item, slot_type):
        fail_info = FailInfo.UNEXPECTED_START_PRB.format(
            expected_start_prb=expected_start_prb, start_prb=float(item['startPrb']),
            filename=filename, record_id=item['item_id'])
        self.assert_equal('Start Prb for %s' % slot_type, expected_start_prb, float(item['startPrb']), fail_info)
        fail_info = FailInfo.UNEXPECTED_NUM_OF_PRB.format(
            expected_num_of_prb=expected_num_of_prb, num_of_prb=float(item['numOfPrb']),
            filename=filename, record_id=item['item_id'])
        self.assert_equal('Num Of Prb for %s' % slot_type, expected_num_of_prb, float(item['numOfPrb']), fail_info)

    def verify_prb_for_tti_item(self, expected_prb_range_list, filename, item, slot_type):
        expected_prb_range_list = [(start, start + num) for start, num in expected_prb_range_list]

        prb_range = float(item['startPrb']), float(item['startPrb']) + float(item['numOfPrb'])
        fail_info = FailInfo.PRB_RANGE_EXCEED.format(
            expected_prb_range=expected_prb_range_list, prb_range=prb_range,
            filename=filename, record_id=item['item_id'])
        self.assert_true('Prb Range Check for %s' % slot_type,
                         self.prb_range_in_prb_range_list(prb_range, expected_prb_range_list),
                         fail_info)

    def prb_range_in_prb_range_list(self, prb_range, prb_range_list):
        return any(start_prb <= prb_range[0] and prb_range[1] <= end_prb for start_prb, end_prb in prb_range_list)

    def get_pusch_allocation_info_ul_data(self):
        ul_slots = self.get_ul_slot()
        start_prb, num_of_prb = self.get_dedicated_prb_range()
        return {'slot_info': ul_slots, 'prb_info_list': ((start_prb, num_of_prb),), 'slot_type': 'ul_data'}

    def get_ul_slot(self):
        cell_technology = self.scf_config['cellTechnology']
        nrarfcn = self.scf_config['nrarfcn']
        frame_structure_type = self.scf_config['frameStructureType']
        guard_period_length = self.scf_config['guardPeriodLength']
        ul_dl_data_slot_ratio = self.scf_config['ulDlDataSlotRatio']
        values = self.get_mapping_value(Const.UL_SLOT, locals())
        return values['ul_slot']

    def get_dedicated_prb_range(self):
        pusch_start_prb_for_ul = self.dedicated_bwp_config_from_scf['ul_rb_start']
        pusch_num_of_prb_for_ul = self.dedicated_bwp_config_from_scf['ul_rb_size']
        start_prb, num_of_prb = self.adjust_prb_for_pucch(pusch_start_prb_for_ul, pusch_num_of_prb_for_ul)
        return start_prb, num_of_prb

    def adjust_prb_for_pucch(self, start_prb, num_of_prb):
        half_pucch_rb_number = (self.pucch_rb_number + 1) // 2
        return start_prb + half_pucch_rb_number, num_of_prb - 2 * half_pucch_rb_number

    def get_pusch_allocation_info_prach(self):
        prach_slots = self.get_prach_slot()
        prb_range_list = self.get_pusch_prb_range()
        return {'slot_info': prach_slots, 'prb_info_list': prb_range_list, 'slot_type': 'prach'}

    def get_prach_slot(self):
        cell_technology = self.scf_config['cellTechnology']
        nrarfcn = self.scf_config['nrarfcn']
        prach_config_index = self.scf_config['prachConfigurationIndex']
        values = self.get_mapping_value(Const.PRACH_SLOT, locals())
        return values['prach_slot']

    def get_pusch_prb_range_for_single_ue(self):
        start_prb, num_of_prb = self.get_dedicated_prb_range()
        prach_start, prach_end = self.get_prach_prb_range()
        prb_num1 = prach_start - start_prb
        prb_num2 = (start_prb + num_of_prb) - prach_end
        if prb_num1 < 0 or prb_num2 < 0:
            self.case_invalid(InvalidInfo.PRACH_RANGE_EXCEED_DEDICATED_PRB_RANGE)
        elif prb_num1 >= prb_num2:
            return start_prb, prb_num1
        else:
            return prach_end, prb_num2

    def get_pusch_prb_range(self):
        start_prb, num_of_prb = self.get_dedicated_prb_range()
        prach_start, prach_end = self.get_prach_prb_range()
        prb_num1 = prach_start - start_prb
        prb_num2 = (start_prb + num_of_prb) - prach_end
        if prb_num1 < 0 or prb_num2 < 0:
            self.case_invalid(InvalidInfo.PRACH_RANGE_EXCEED_DEDICATED_PRB_RANGE)
        return (start_prb, prb_num1), (prach_end, prb_num2)

    def get_prach_prb_range(self):
        initial_start_prb = self.initial_bwp_config_from_scf['ul_rb_start']
        prach_offset = self.scf_config['msg1FrequencyStart']
        prach_prb_num = self.get_rach_prb_num()
        prach_prb_start = initial_start_prb + prach_offset
        prach_prb_end = prach_prb_start + prach_prb_num
        return prach_prb_start - Const.PRACH_GUARD_PRB_NUM, prach_prb_end + Const.PRACH_GUARD_PRB_NUM

    def get_rach_prb_num(self):
        rach_tones, rach_scs = self.get_rach_tones_and_scs()
        nr_cell_grp_scs = self.scf_config['scs']
        rach_prb_num = math.ceil(rach_tones * rach_scs / (12 * nr_cell_grp_scs) * Const.MSG1_FDM)
        return rach_prb_num

    def get_rach_tones_and_scs(self):
        cell_technology = self.scf_config['cellTechnology']
        nrarfcn = self.scf_config['nrarfcn']
        prach_config_index = self.scf_config['prachConfigurationIndex']
        values = self.get_mapping_value(Const.RACH_TONES_RACH_SCS, locals())
        return values['rach_tones'], values['rach_scs']

    def verify(self):
        self.verify_pusch_allocation()
        self.case_pass()


def verify_pusch_rb_allocation(log_path, scf_file, egate_file, pcap_file, tti_ul_file, pucch_prb_number=None,
                               cell=1, log_level=None):
    checker = CheckPuschRbAllcation(log_path, scf_file, egate_file, pcap_file, tti_ul_file, pucch_prb_number, cell=cell,
                                    log_level=log_level)
    checker.verify()
    checker.create_robot_file()
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
