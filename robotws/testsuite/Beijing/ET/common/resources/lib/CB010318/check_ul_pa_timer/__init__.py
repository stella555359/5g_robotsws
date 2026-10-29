# -*- coding: utf-8 -*-
"""
2022/07/04 first version by sheng.1.ye@nokia-sbell.com
           this is the checker to verify correctness of location and bandwith
2022/07/08 add warning of PRB_VALUE_IS_NOT_INT, by Ye Sheng
"""

import unittest
from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser
from testsuite.Beijing.ET.common.resources.lib.info_api import InfoAPI
from testsuite.Beijing.ET.common.resources.lib.checker import Checker


class InvalidInfo:
    UL_PA_TIMER_DATA_NOT_FOUND = 'Message type==paTimerData not found in tti_ul file'
    CELL_NOT_FOUND_IN_SCF = "Cell {cell} not found in scf"


class FailInfo:
    UL_PA_TIMER_DISABLE = "ul pa timer disable: {counter_start}"


class WarnInfo:
    PRB_VALUE_IS_NOT_INT = ("StartPrb:{start_prb} or NumOfPrb:{num_of_prb} in TTIL log is not integer\n"
                            "file:{filename}\nrecord:{record_id}")


class CheckULPATimer(Checker):

    def __init__(self, log_path, scf_file, msg_file, tti_dl_file, tti_ul_file, cell=1, *args, **kwargs):
        super().__init__(log_path, *args, **kwargs)
        self.cell = cell
        self.cell_info = {}
        self.info_api = None
        self.scf_file = scf_file
        self.msg_file = msg_file
        self.tti_dl_file = tti_dl_file
        self.tti_ul_file = tti_ul_file
        self.scf_config = None
        self.dedicated_bwp_config_from_scf = None
        self.location_and_bw_from_egate = None
        self.init_info()

    def init_info(self):
        self.init_cell_info_from_scf()

    def init_cell_info_from_scf(self):
        self.info_api = InfoAPI(log_files=(self.scf_file,))
        self.cell_info = self.info_api.scf_get_nr_cell_info(cell_items=["actVoipPacketAggr:"])
        if self.cell not in self.cell_info:
            self.case_invalid(InvalidInfo.CELL_NOT_FOUND_IN_SCF, cell=self.cell)
        self.scf_config = self.cell_info[self.cell]
        self.logger.debug("final scf_config: %s" % self.scf_config)

    def verify_ul_pa_timer_start(self):
        parser = InfoParser(filename=self.tti_ul_file)
        expression = "type=='paTimerData' and physCellId == %d" % self.scf_config['physCellId']
        result = parser.get_info(item_list=['type', 'event', 'id', 'physCellId'], filter_expression=expression)
        if not result:
            self.case_invalid(InvalidInfo.UL_PA_TIMER_DATA_NOT_FOUND)
        self.verify_pa_timer_start(result, self.tti_ul_file)

    def verify_pa_timer_start(self, result, filename):
        self.counters['STARTOfEvent'] = 0
        for item in result:
            if item['event'] == "START":
                self.counters['STARTOfEvent'] += 1
        fail_info = FailInfo.UL_PA_TIMER_DISABLE.format(counter_start=self.counters['STARTOfEvent'])
        self.assert_true('ABCD', self.counters['STARTOfEvent'] > 0, fail_info)

    def verify(self):
        self.verify_ul_pa_timer_start()
        self.case_pass()


def verify_ul_pa_timer(log_path, scf_file, msg_file, tti_dl_file, tti_ul_file, cell=1, log_level=None):
    checker = CheckULPATimer(log_path, scf_file, msg_file, tti_dl_file, tti_ul_file,
                             cell=cell, log_level=log_level)
    checker.verify()
    checker.create_robot_file()
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
