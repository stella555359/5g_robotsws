# -*- coding: utf-8 -*-
"""
2023/03/27 first version by @author: sheng.1.ye@nokia.com
    The TestVerifyTrsAllocation class is unittest class for VerifyTrsAllocation.
2023/05/19 add ut to support verify only some of cells, by Ye Sheng
"""
import logging
import unittest
import os
from testsuite.Beijing.ET.common.resources.lib.CB010513.check_trs_allocation import verify_trs_allocation


class TestVerifyTrsAllocation(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01(self):
        folder = os.path.join(self.base, '../check_csirs_allocation/logs/log1_2023_0327/')
        cp_bip_file = os.path.join(folder, 'CPlane_E1F1.pcap.txt')
        bip_file = os.path.join(folder, 'L2L1_Bip_ABIO5_ABIO5.pcap.txt')
        scf_file = os.path.join(folder, 'SCF_running.xml')
        emil_file = os.path.join(folder, 'mon.0.emil.5gm.txt')
        swconfig_file = os.path.join(folder, 'swconfig_gnb.txt')
        self.assertTrue(verify_trs_allocation(log_path=self.run_log_path,
                                              scf_file=scf_file,
                                              cp_bip_file=cp_bip_file,
                                              bip_file=bip_file,
                                              emil_file=emil_file,
                                              swconfig_file=swconfig_file,
                                              log_level=logging.DEBUG))

    def test02(self):
        folder = os.path.join(self.base, '../check_csirs_allocation/logs/log2_tc10/')
        cp_bip_file = os.path.join(folder, 'CPlane_E1F1.pcap.txt')
        bip_file = os.path.join(folder, 'L2L1_Bip_ABIO5_ABIO5.pcap.txt')
        scf_file = os.path.join(folder, 'SCF_running.xml')
        emil_file = os.path.join(folder, 'mon.0.emil.5gm.txt')
        swconfig_file = os.path.join(folder, 'swconfig_gnb.txt')
        self.assertTrue(verify_trs_allocation(log_path=self.run_log_path,
                                              scf_file=scf_file,
                                              cp_bip_file=cp_bip_file,
                                              bip_file=bip_file,
                                              emil_file=emil_file,
                                              swconfig_file=swconfig_file,
                                              scf_cells=(1, 3, 4),
                                              log_level=logging.DEBUG))

    def test03_not_all_cells(self):
        folder = os.path.join(self.base, '../check_csirs_allocation/logs/log2_tc10/')
        cp_bip_file = os.path.join(folder, 'CPlane_E1F1.pcap.txt')
        bip_file = os.path.join(folder, 'L2L1_Bip_ABIO5_ABIO5.pcap.txt')
        scf_file = os.path.join(folder, 'SCF_running.xml')
        emil_file = os.path.join(folder, 'mon.0.emil.5gm.txt')
        swconfig_file = os.path.join(folder, 'swconfig_gnb.txt')
        self.assertTrue(verify_trs_allocation(log_path=self.run_log_path,
                                              scf_file=scf_file,
                                              cp_bip_file=cp_bip_file,
                                              bip_file=bip_file,
                                              emil_file=emil_file,
                                              swconfig_file=swconfig_file,
                                              scf_cells=(1, 3),
                                              log_level=logging.DEBUG))


if __name__ == '__main__':
    unittest.main()
