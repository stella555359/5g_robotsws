# -*- coding: utf-8 -*-
"""
2022/06/09 first version by @author: sheng.1.ye@nokia.com
    The TestCheckCb8593AdaptiveSr class is unittest class for CheckCb8593AdaptiveSr.
2022/08/24 add unit test test03, by Ye Sheng
"""

import logging
import unittest
import os
from testsuite.Beijing.ET.common.resources.lib.CB008593.check_cb8593_adaptive_sr import verify_cb8593_adaptive_sr


class TestCheckCb8593AdaptiveSr(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01(self):
        x2ap_txt_log_file = os.path.join(self.base, 'logs/test01/br0.pcap.txt')
        self.assertTrue(verify_cb8593_adaptive_sr(self.run_log_path, x2ap_txt_log_file, log_level=logging.DEBUG))

    def test02(self):
        x2ap_txt_log_file = os.path.join(self.base, 'logs/keysight_acknowledge_delayed/br0.pcap.txt')
        self.assertTrue(verify_cb8593_adaptive_sr(self.run_log_path, x2ap_txt_log_file, log_level=logging.DEBUG))

    def test03(self):
        x2ap_txt_log_file = os.path.join(self.base, 'logs/CB008593-A_1-5_TC01_20220824/br0.pcap.txt')
        self.assertTrue(verify_cb8593_adaptive_sr(self.run_log_path, x2ap_txt_log_file, log_level=logging.DEBUG))


if __name__ == '__main__':
    unittest.main()
