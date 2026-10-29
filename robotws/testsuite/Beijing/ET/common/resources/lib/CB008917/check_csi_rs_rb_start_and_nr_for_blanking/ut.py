# -*- coding: utf-8 -*-
"""
2022/08/30 first version by @author: sheng.1.ye@nokia.com
    The TestCheckCsiRsRbStartAndNrForBlanking class is unittest class for CheckCsiRsRbStartAndNrForBlanking.
"""
import logging
import unittest
import os
from testsuite.Beijing.ET.common.resources.lib.CB008917.check_csi_rs_rb_start_and_nr_for_blanking import (
    verify_csirs_rb_start_and_nr_for_blanking)


class TestCheckCsiRsRbStartAndNrForBlanking(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01(self):
        folder = os.path.join(self.base, 'logs/low11_high11/')
        scf_file = os.path.join(folder, 'MRBTS-1_ET-ASIL-ABIO-AP-FDD_20220817-1025.xml')
        egate_file = os.path.join(folder, 'egate_console.log.002')
        self.assertTrue(verify_csirs_rb_start_and_nr_for_blanking(
            log_path=self.run_log_path,
            scf_file=scf_file, egate_file=egate_file, log_level=logging.DEBUG))

    def test02(self):
        folder = os.path.join(self.base, 'logs/muting_52_start0_low0_high5/')
        scf_file = os.path.join(folder, 'MRBTS-1_ET-ASIL-ABIO-AP-FDD_20220817-1035_PRBblanking_5_0.xml')
        egate_file = os.path.join(folder, 'egate_console.log.001')
        self.assertTrue(verify_csirs_rb_start_and_nr_for_blanking(
            log_path=self.run_log_path,
            scf_file=scf_file, egate_file=egate_file, log_level=logging.DEBUG))

    def test03(self):
        folder = os.path.join(self.base, 'logs/muting_bpw_low11_high0/')
        scf_file = os.path.join(folder, 'MRBTS-1_ET-ASIL-ABIO-AP-FDD_20220812-1132_dynamic_blank11_0.xml')
        egate_file = os.path.join(folder, 'egate_console.log.001')
        self.assertTrue(verify_csirs_rb_start_and_nr_for_blanking(
            log_path=self.run_log_path,
            scf_file=scf_file, egate_file=egate_file, log_level=logging.DEBUG))


if __name__ == '__main__':
    unittest.main()
