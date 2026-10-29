# -*- coding: utf-8 -*-
"""
2022/10/10 first version by @author: sheng.1.ye@nokia.com
    The TestCheckPhysCellId class is unittest class for CheckPhysCellId.
"""
import logging
import unittest
import os
from testsuite.Beijing.ET.common.resources.lib.CB_EXAMPLE.check_physcellid import verify_physcellid


class TestCheckPhysCellId(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01_physcellid_is_50_pass(self):
        folder = os.path.join(self.base, 'logs/log_example1_physcellid_50/')
        pcap_file = os.path.join(folder, 'cellsetup.txt')
        self.assertTrue(verify_physcellid(log_path=self.run_log_path,
                                          pcap_file=pcap_file,
                                          log_level=logging.DEBUG))

    def test02_physcellid_is_51_fail(self):
        folder = os.path.join(self.base, 'logs/log_example2_physcellid_51/')
        pcap_file = os.path.join(folder, 'cellsetup.txt')
        try:
            verify_physcellid(log_path=self.run_log_path,
                              pcap_file=pcap_file,
                              log_level=logging.DEBUG)
        except Exception as e:
            self.assertTrue('physCellId unmatch' in str(e))
        else:
            self.fail("Exception is expected")


if __name__ == '__main__':
    unittest.main()
