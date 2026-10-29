# -*- coding: utf-8 -*-
"""
2022/06/09 first version by @author: sheng.1.ye@nokia.com
    The TestCheckCsiRsAllocation class is unittest class for CheckCsiRsAllocation.
"""
import logging
import unittest
import os
from testsuite.Beijing.ET.common.resources.lib.CB008534.check_cell_csi_rs_allocation import verify_cell_csirs_allocation
from testsuite.Beijing.ET.common.resources.lib.exception_et import CaseFail


class TestCheckCsiRsAllocation(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01_aiphone_1beam_pass(self):
        scf_file = os.path.join(self.base, 'logs/airphone_1beam_pass/SCF_running.xml')
        msg_file = os.path.join(self.base, 'logs/airphone_1beam_pass/x2.txt')
        self.assertTrue(verify_cell_csirs_allocation(log_path=self.run_log_path,
                        scf_file=scf_file, msg_file=msg_file, log_level=logging.DEBUG))

    def test02_keysight_auto_bi10_6beams_fail(self):
        scf_file = os.path.join(self.base, 'logs/keysight_auto_bi10_6beams_fail/Configuration_scf.xml')
        msg_file = os.path.join(self.base, 'logs/keysight_auto_bi10_6beams_fail/x2gnp-2.txt')
        try:
            verify_cell_csirs_allocation(
                log_path=self.run_log_path,
                scf_file=scf_file, msg_file=msg_file, log_level=logging.DEBUG)
        except CaseFail:
            pass
        else:
            self.fail("Case Fail is expected")

    def test03_keysight_auto_bi10_6beams_pass(self):
        scf_file = os.path.join(self.base, 'logs/keysight_auto_bi10_6beams_pass/Configuration_scf.xml')
        msg_file = os.path.join(self.base, 'logs/keysight_auto_bi10_6beams_pass/x2gnp-2.txt')
        self.assertTrue(verify_cell_csirs_allocation(log_path=self.run_log_path,
                        scf_file=scf_file, msg_file=msg_file, log_level=logging.DEBUG))

    def test04_airphone_tdlte_pass(self):
        scf_file = os.path.join(self.base, 'logs/airphone_tdlte/scf.xml')
        msg_file = os.path.join(self.base, 'logs/airphone_tdlte/br0.pcap.txt')
        self.assertTrue(verify_cell_csirs_allocation(log_path=self.run_log_path,
                        scf_file=scf_file, msg_file=msg_file, log_level=logging.DEBUG))


if __name__ == '__main__':
    unittest.main()
