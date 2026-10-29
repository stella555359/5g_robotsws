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
    NO_SCF_CONFIG = "No config found in scf config"
    NO_DL_CCCH_MESSAGE = "No DL-CCCH-MESSAGE in egate file"
    DL_FD_SCHED_DATA_NOT_FOUND = 'Message type==dlFdSchedData not found in tti_dl file'
    UL_FD_SCHED_DATA_NOT_FOUND = 'Message type==ulFdSchedData not found in tti_ul file'
    ACT_SPECIFIC_BWP_SIZE_IS_OFF = 'The parameter actSpecificBwpSize in scf is not "true"'
    CELL_NOT_FOUND_IN_SCF = "Cell {cell} not found in scf"


class FailInfo:
    LOCATION_AND_BW_UNMATCH = "Calculated Location and Bandwidth from SCF does not match that from eGate"
    START_PRB_OVERFLOW = "StartPrb: {start_prb} < RB_Start: {rb_start}\nfile:{filename}\nrecord:{record_id}"
    NUM_OF_PRB_OVERFLOW = ("StartPrb + NumOfPrb: {end_prb} > RB_Start + RB_Size: {rb_end}\n"
                           "file: {filename}\nrecord: {record_id}")


class WarnInfo:
    PRB_VALUE_IS_NOT_INT = ("StartPrb:{start_prb} or NumOfPrb:{num_of_prb} in TTIL log is not integer\n"
                            "file:{filename}\nrecord:{record_id}")


class Const:
    BWP_SIZE = 275


class CheckLocationAndBandwidth(Checker):

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
        self.init_dedicated_bwp_from_scf()
        self.init_location_and_bw_info_from_msg()

    def verify_location_and_bw(self):
        self.verify_dl_location_and_bw()
        self.verify_ul_location_and_bw()

    def verify_dl_location_and_bw(self):
        location_and_bw = self.encode_location_and_bw(self.dedicated_bwp_config_from_scf['dl_rb_size'],
                                                      self.dedicated_bwp_config_from_scf['dl_rb_start'])
        self.assert_equal('dl location and bandwidth', location_and_bw,
                          self.location_and_bw_from_egate['locationAndBandwidth_dl'], FailInfo.LOCATION_AND_BW_UNMATCH)

    def verify_ul_location_and_bw(self):
        location_and_bw = self.encode_location_and_bw(self.dedicated_bwp_config_from_scf['ul_rb_size'],
                                                      self.dedicated_bwp_config_from_scf['ul_rb_start'])
        self.assert_equal('ul location and bandwidth', location_and_bw,
                          self.location_and_bw_from_egate['locationAndBandwidth_ul'], FailInfo.LOCATION_AND_BW_UNMATCH)

    @staticmethod
    def encode_location_and_bw(rb_size, rb_start):
        bwp_size = Const.BWP_SIZE
        if (rb_size - 1) <= (bwp_size / 2):
            riv = bwp_size * (rb_size - 1) + rb_start
        else:
            riv = bwp_size * (bwp_size - rb_size + 1) + (bwp_size - 1 - rb_start)
        return riv

    def init_dedicated_bwp_from_scf(self):
        self.dedicated_bwp_config_from_scf = self.info_api.scf_get_rb_start_and_size(bwp_type='dedicated')
        self.logger.debug("dedicated_bwp_config_from_scf: %s" % self.dedicated_bwp_config_from_scf)

    def init_cell_info_from_scf(self):
        self.info_api = InfoAPI(log_files=(self.scf_file,))
        self.cell_info = self.info_api.scf_get_nr_cell_info(cell_items=["actSpecificBwpSize:"])
        if self.cell not in self.cell_info:
            self.case_invalid(InvalidInfo.CELL_NOT_FOUND_IN_SCF, cell=self.cell)
        self.validate_feature_switch(self.cell_info[self.cell])
        self.scf_config = self.cell_info[self.cell]
        self.logger.debug("final scf_config: %s" % self.scf_config)

    def validate_feature_switch(self, scf_info):
        if scf_info['actSpecificBwpSize'] != 'true':
            self.case_invalid(InvalidInfo.ACT_SPECIFIC_BWP_SIZE_IS_OFF)

    def init_location_and_bw_info_from_msg(self):
        msg_parser = InfoParser(filename=self.msg_file)
        item_list = self.make_location_and_bw_info_items()
        location_and_bw_info = msg_parser.get_info(
            item_list=item_list, filter_pattern=r'DL-CCCH-Message',
            filter_expression='scramblingID == %d' % self.scf_config['physCellId'], count=1)
        self.validate_location_and_bw_info(location_and_bw_info)
        self.location_and_bw_from_egate = location_and_bw_info[0]

    @staticmethod
    def make_location_and_bw_info_items():
        return ["uplinkBWP-ToAddModList->locationAndBandwidth as locationAndBandwidth_ul",
                "downlinkBWP-ToAddModList->locationAndBandwidth as locationAndBandwidth_dl",
                "scramblingID"]

    def validate_location_and_bw_info(self, location_and_bw_info):
        self.logger.debug(location_and_bw_info)
        if not location_and_bw_info or not location_and_bw_info[0]:
            self.case_invalid(InvalidInfo.NO_DL_CCCH_MESSAGE)

    def verify_prb_range(self):
        self.verify_prb_range_dl()
        self.verify_prb_range_ul()

    def verify_prb_range_dl(self):
        parser = InfoParser(filename=self.tti_dl_file)
        result = parser.get_info(
            item_list=['type', 'numOfPrb', 'startPrb', 'physCellId'],
            filter_expression="type=='dlFdSchedData' and physCellId == %d" % self.scf_config['physCellId'])
        if not result:
            self.case_invalid(InvalidInfo.DL_FD_SCHED_DATA_NOT_FOUND)
        self.counters['dlFdSchedData'] = len(result)
        self.verify_prb_start_and_size(
            self.dedicated_bwp_config_from_scf['dl_rb_start'], self.dedicated_bwp_config_from_scf['dl_rb_size'],
            result, self.tti_dl_file)

    def verify_prb_range_ul(self):
        parser = InfoParser(filename=self.tti_ul_file)
        result = parser.get_info(
            item_list=['type', 'numOfPrb', 'startPrb', 'physCellId'],
            filter_expression="type=='ulFdSchedData' and physCellId == %d" % self.scf_config['physCellId'])
        if not result:
            self.case_invalid(InvalidInfo.UL_FD_SCHED_DATA_NOT_FOUND)
        self.counters['ulFdSchedData'] = len(result)
        self.verify_prb_start_and_size(
            self.dedicated_bwp_config_from_scf['ul_rb_start'], self.dedicated_bwp_config_from_scf['ul_rb_size'],
            result, self.tti_ul_file)

    def verify_prb_start_and_size(self, rb_start, rb_size, result, filename):
        for item in result:
            # print("startPrb:(%s), rb_start:(%s)" % (repr(item['startPrb']), repr(rb_start)))
            if type(item['startPrb']) is str:
                self.case_warning(WarnInfo.PRB_VALUE_IS_NOT_INT, num_of_prb=item['numOfPrb'],
                                  start_prb=item['startPrb'], filename=filename, record_id=item['item_id'])
            fail_info = FailInfo.START_PRB_OVERFLOW.format(rb_start=rb_start, start_prb=float(item['startPrb']),
                                                           filename=filename, record_id=item['item_id'])
            self.assert_true('startPrb >= rb_start', float(item['startPrb']) >= rb_start, fail_info)
            fail_info = FailInfo.NUM_OF_PRB_OVERFLOW.format(rb_end=rb_start+rb_size,
                                                            end_prb=float(item['startPrb'])+float(item['numOfPrb']),
                                                            filename=filename, record_id=item['item_id'])
            self.assert_true('numOfPrb + startPrb <= rb_start + rb_size',
                             float(item['numOfPrb']) + float(item['startPrb']) <= rb_start + rb_size, fail_info)

    def verify(self):
        self.verify_location_and_bw()
        self.verify_prb_range()
        self.case_pass()


def verify_location_and_bandwidth(log_path, scf_file, msg_file, tti_dl_file, tti_ul_file, cell=1, log_level=None):
    checker = CheckLocationAndBandwidth(log_path, scf_file, msg_file, tti_dl_file, tti_ul_file,
                                        cell=cell, log_level=log_level)
    checker.verify()
    checker.create_robot_file()
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
