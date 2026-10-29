# -*- coding: utf-8 -*-
"""
2022/07/04 first version by @author: sheng.1.ye@nokia.com
    The TestCheckLocationAndBandwidth class is unittest class for CheckLocationAndBandwidth.
2022/07/08 add test02 with float value in csv, by Ye Sheng
"""
import logging
import unittest
import os
from testsuite.Beijing.ET.common.resources.lib.CB008917.check_location_and_bandwidth import (
    verify_location_and_bandwidth)
from testsuite.Beijing.ET.common.resources.lib.exception_et import CaseFail


class TestCheckLocationAndBandwidth(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01(self):
        folder = os.path.join(self.base, 'logs/log_20220704/')
        scf_file = os.path.join(folder, 'Configuration_scf_MRBTS-1_ET-ASIL-ABIO-AP-FDD_bandN145PRB.xml')
        msg_file = os.path.join(folder, 'egate_console.log')
        tti_dl_file = os.path.join(folder, '2730_TTI.bin.19.dl__all.csv')
        tti_ul_file = os.path.join(folder, '2730_TTI.bin.6.ul__all.csv')
        self.assertTrue(verify_location_and_bandwidth(log_path=self.run_log_path,
                        scf_file=scf_file, msg_file=msg_file,
                        tti_dl_file=tti_dl_file, tti_ul_file=tti_ul_file, log_level=logging.DEBUG))

    def test02(self):
        folder = os.path.join(self.base, 'logs/CB008917-B-a_TC049_20220707160823071')
        scf_file = os.path.join(folder, 'SCF_running.xml')
        msg_file = os.path.join(folder, 'egate_console.log')
        tti_dl_file = os.path.join(folder, 'format_output_dl.csv')
        tti_ul_file = os.path.join(folder, 'format_output_ul.csv')
        self.assertTrue(verify_location_and_bandwidth(log_path=self.run_log_path,
                        scf_file=scf_file, msg_file=msg_file,
                        tti_dl_file=tti_dl_file, tti_ul_file=tti_ul_file, log_level=logging.DEBUG))


if __name__ == '__main__':
    unittest.main()
