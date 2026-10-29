# -*- coding: utf-8 -*-
"""
2023/05/18 first version by @author: sheng.1.ye@nokia.com
    The TestVerifyZab class is unittest class for VerifyZab.
"""
import logging
import unittest
import os
from testsuite.Beijing.ET.common.resources.lib.CB010513.check_zab import verify_zab


class TestVerifyZab(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01(self):
        folder = os.path.join(self.base, './logs/log2_tc10/')
        cp_bip_file = os.path.join(folder, 'CPlane_E1F1.pcap.txt')
        scf_file = os.path.join(folder, 'SCF_running.xml')
        swconfig_file = os.path.join(folder, 'swconfig_gnb.txt')
        ttidl_file = os.path.join(folder, 'format_output_dl.csv')
        self.assertTrue(verify_zab(log_path=self.run_log_path,
                                   scf_file=scf_file,
                                   cp_bip_file=cp_bip_file,
                                   swconfig_file=swconfig_file,
                                   ttidl_file=ttidl_file,
                                   scf_cells=(1, 3),
                                   log_level=logging.DEBUG))

    def test02(self):
        folder = os.path.join(self.base, './logs/log3_tc14/')
        cp_bip_file = os.path.join(folder, 'CPlane_E1F1.pcap.txt')
        scf_file = os.path.join(folder, 'SCF_running.xml')
        swconfig_file = os.path.join(folder, 'swconfig_gnb.txt')
        ttidl_file = os.path.join(folder, 'format_output_dl.csv')
        self.assertTrue(verify_zab(log_path=self.run_log_path,
                                   scf_file=scf_file,
                                   cp_bip_file=cp_bip_file,
                                   swconfig_file=swconfig_file,
                                   ttidl_file=ttidl_file,
                                   scf_cells=(1, 2, 3),
                                   log_level=logging.DEBUG))


if __name__ == '__main__':
    unittest.main()
