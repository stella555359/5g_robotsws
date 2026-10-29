# -*- coding: utf-8 -*-
"""
2022/10/10 first version by sheng.1.ye@nokia-sbell.com
           this is a DEMO checker to verify physcellid is 50
"""

import unittest
from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser
from testsuite.Beijing.ET.common.resources.lib.checker import Checker


class Const:
    PHYSCELLID = 50


class InvalidInfo:
    CELL_SETUP_REQ_NOT_FOUND = "itf_l2_ps_cell_CellSetupReq_t not found"


class FailInfo:
    UNEXPECTED_PHYSCELLID = "physCellId({physCellId}) is not %d!" % Const.PHYSCELLID


class CheckPhysCellId(Checker):

    def __init__(self, log_path, pcap_file, *args, **kwargs):
        super().__init__(log_path, *args, **kwargs)
        self.pcap_file = pcap_file
        self.pcap_info = None
        self.init_info()

    def verify_physcellid(self):
        self.assert_equal('physCellId', Const.PHYSCELLID, self.pcap_info['physCellId'],
                          FailInfo.UNEXPECTED_PHYSCELLID.format(physCellId=self.pcap_info['physCellId']))

    def init_info(self):
        self.init_pcap_info()

    def init_pcap_info(self):
        pcap_parser = InfoParser(filename=self.pcap_file)
        pcap_info = pcap_parser.get_info(item_list=['physCellId:'],
                                         filter_pattern='itf_l2_ps_cell_cellsetupreq', count=1, silent=True)
        if not pcap_info:
            self.case_invalid(InvalidInfo.CELL_SETUP_REQ_NOT_FOUND)
        self.pcap_info = pcap_info[0]
        self.logger.debug("pcap_info: %s" % self.pcap_info)

    def verify(self):
        self.verify_physcellid()
        self.case_pass()


def verify_physcellid(log_path, pcap_file, log_level=None):
    checker = CheckPhysCellId(log_path, pcap_file, log_level=log_level)
    checker.create_robot_file()
    checker.verify()
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
