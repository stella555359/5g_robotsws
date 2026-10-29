# -*- coding: utf-8 -*-
"""
2022/07/04 first version by @author: sheng.1.ye@nokia.com
    The TestCheckLocationAndBandwidth class is unittest class for CheckLocationAndBandwidth.
2022/07/08 add test02 with float value in csv, by Ye Sheng
"""
import logging
import unittest
import os
from testsuite.Beijing.ET.common.resources.lib.CB010318.check_ul_pa_timer import (
    verify_ul_pa_timer)
from testsuite.Beijing.ET.common.resources.lib.exception_et import CaseFail


class TestCheckLocationAndBandwidth(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01(self):
        folder = os.path.join(self.base, 'logs/')
        scf_file = os.path.join(folder, 'Configuration_scf_MRBTS-1_O-RAN_TL-BM69_BF_20230406-0653.xml')
        msg_file = os.path.join(folder, 'egate_console.log')
        tti_dl_file = os.path.join(folder, 'format_output_dl.csv')
        tti_ul_file = os.path.join(folder, 'format_output_ul.csv')
        self.assertTrue(verify_ul_pa_timer(log_path=self.run_log_path,
                        scf_file=scf_file, msg_file=msg_file,
                        tti_dl_file=tti_dl_file, tti_ul_file=tti_ul_file, log_level=logging.DEBUG))


if __name__ == '__main__':
    unittest.main()
