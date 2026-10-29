# -*- coding: utf-8 -*-
"""
2022/08/09 first version by @author: andy.sun@nokia.com
"""


import logging
import unittest
import os
from testsuite.Beijing.ET.common.resources.lib.CB010513.check_tdra import (verify_tdra)


class TestCheckTDRA(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01(self):
        folder = os.path.join(self.base, 'logs/log1_2023_0412/')
        scf_file = os.path.join(folder, 'SCF_running.xml')
        pcap_file = os.path.join(folder, 'CPlane_E1F1.pcap.txt')
        emil_file = os.path.join(folder, 'mon.0.emil.5gm.txt')
        swconfig_file = os.path.join(folder, 'swconfig_gnb.txt')
        tti_dl_file = os.path.join(folder, 'format_output_dl.csv')
        self.assertTrue(verify_tdra(
            log_path=self.run_log_path,
            scf_file=scf_file, pcap_file=pcap_file, emil_file=emil_file,
            tti_dl_file=tti_dl_file, swconfig_file=swconfig_file, log_level=logging.DEBUG))
        # print("===================================================================")


if __name__ == '__main__':
    unittest.main()
