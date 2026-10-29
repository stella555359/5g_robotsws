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


class FailInfo:
    VALID_SHARED_SR_NOT_FOUND = 'shared sr resource not found in egate file'


class CheckSharedSrResource(Checker):

    def __init__(self, log_path, scf_file, egate_file, pcap_file, cell=1, *args, **kwargs):
        super().__init__(log_path, *args, **kwargs)
        self.cell = cell
        self.cell_info = {}
        self.info_api = None
        self.scf_file = scf_file
        self.egate_file = egate_file
        self.pcap_file = pcap_file
        self.scf_config = None
        self.info_api = None
        self.cell_setup_from_pacp = None
        self.init_info()

    def init_info(self):
        return

    def verify_shared_sr(self):
        self.verify_shared_sr_with_egate()

    def verify_shared_sr_with_egate(self):
        item_list = ["criticalExtensions",
                     "pucch-ResourceId[2]",
                     "startingPRB[2]",
                     "rrc-TransactionIdentifier",
                     "rrc-TransactionIdentifier as rrcID"]

        filter_exp = "criticalExtensions == 'rrcReconfiguration :'and rrcID == 2 and startingPRB == 0"

        info_parser = InfoParser(filename=self.egate_file)
        result = info_parser.get_info(item_list=item_list, filter_expression=filter_exp)
        if not result:
            self.case_fail(FailInfo.VALID_SHARED_SR_NOT_FOUND)
            return False

    def verify(self):
        self.verify_shared_sr()
        self.case_pass()


def verify_shared_sr_resource(log_path, scf_file, egate_file, pcap_file, cell=1, log_level=None):
    checker = CheckSharedSrResource(log_path, scf_file, egate_file, pcap_file, cell=cell, log_level=log_level)
    checker.verify()
    checker.create_robot_file()
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
