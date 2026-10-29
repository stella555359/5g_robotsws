# -*- coding: utf-8 -*-
"""
2022/08/09 first version by @author: sheng.1.ye@nokia.com
    The TestCheckCsiRsRbStartAndNr class is unittest class for CheckCsiRsRbStartAndNr.
2022/08/30 make revision1 and add two unit test
2022/08/30 rename from TestCheckCsiRsStartingRbAndNrOfRbs to TestCheckCsiRsRbStartAndNr, by Ye Sheng
"""


import logging
import unittest
import os
from testsuite.Beijing.ET.common.resources.lib.CB008917.check_csi_rs_rb_start_and_nr import (
    verify_csirs_rb_start_and_nr)


class TestCheckCsiRsRbStartAndNr(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01(self):
        folder = os.path.join(self.base, 'logs/40M/')
        scf_file = os.path.join(folder, 'MRBTS-1_5_3_UTE5GFT04016_20220731-2204_chbw40_beamforming.xml')
        pcap_file = os.path.join(folder, 'cellsetup.txt')
        egate_file = os.path.join(folder, 'egate_console.log.002')
        self.assertTrue(verify_csirs_rb_start_and_nr(
            log_path=self.run_log_path,
            scf_file=scf_file, pcap_file=pcap_file, egate_file=egate_file, revision=0, log_level=logging.DEBUG))

    def test02(self):
        folder = os.path.join(self.base, 'logs/FDD_45PRB_start0_rballocation52/')
        scf_file = os.path.join(folder, 'MRBTS-1_ET-ASIL-ABIO-AP-FDD_SANSAbandN1_45PRB_config1.xml')
        pcap_file = os.path.join(folder, 'cellsetup.txt')
        egate_file = os.path.join(folder, 'egate_console.log.003')
        self.assertTrue(verify_csirs_rb_start_and_nr(
            log_path=self.run_log_path,
            scf_file=scf_file, pcap_file=pcap_file, egate_file=egate_file, revision=0, log_level=logging.DEBUG))

    def test03(self):
        folder = os.path.join(self.base, 'logs/FDD_45PRB_start0_rballocationBWP/')
        scf_file = os.path.join(folder, 'MRBTS-1_ET-ASIL-ABIO-AP-FDD_SANSAbandN1_45PRB_config1.xml')
        pcap_file = os.path.join(folder, 'cellsetup.txt')
        egate_file = os.path.join(folder, 'egate_console.log.004')
        self.assertTrue(verify_csirs_rb_start_and_nr(
            log_path=self.run_log_path,
            scf_file=scf_file, pcap_file=pcap_file, egate_file=egate_file, revision=0, log_level=logging.DEBUG))

    def test04(self):
        folder = os.path.join(self.base, 'logs/FDD_50PRB_start0_rballocationBWP/')
        scf_file = os.path.join(folder, 'MRBTS-1_ET-ASIL-ABIO-AP-FDD_SANSAbandN1_50PRB_config1.xml')
        pcap_file = os.path.join(folder, 'cellsetup.txt')
        egate_file = os.path.join(folder, 'egate_console.log.005')
        self.assertTrue(verify_csirs_rb_start_and_nr(
            log_path=self.run_log_path,
            scf_file=scf_file, pcap_file=pcap_file, egate_file=egate_file, revision=0, log_level=logging.DEBUG))

    def test05(self):
        folder = os.path.join(self.base, 'logs/FDD_70PRB_start0_rballocation52/')
        scf_file = os.path.join(folder, 'MRBTS-1_ET-ASIL-ABIO-AP-FDD_SANSAbandN1_70PRB_config1.xml')
        pcap_file = os.path.join(folder, 'cellsetup.txt')
        egate_file = os.path.join(folder, 'egate_console.log.001')
        self.assertTrue(verify_csirs_rb_start_and_nr(
            log_path=self.run_log_path,
            scf_file=scf_file, pcap_file=pcap_file, egate_file=egate_file, revision=0, log_level=logging.DEBUG))

    def test06(self):
        folder = os.path.join(self.base, 'logs/FDD_70PRB_start0_rballocationBWP/')
        scf_file = os.path.join(folder, 'MRBTS-1_ET-ASIL-ABIO-AP-FDD_SANSAbandN1_70PRB_config1.xml')
        pcap_file = os.path.join(folder, 'cellsetup.txt')
        egate_file = os.path.join(folder, 'egate_console.log.003')
        self.assertTrue(verify_csirs_rb_start_and_nr(
            log_path=self.run_log_path,
            scf_file=scf_file, pcap_file=pcap_file, egate_file=egate_file, revision=0, log_level=logging.DEBUG))

    def test07(self):
        folder = os.path.join(self.base, 'logs/FDD_70PRB_start28_rballocation52/')
        scf_file = os.path.join(folder, 'MRBTS-1_ET-ASIL-ABIO-AP-FDD_SANSAbandN1_70PRB_config1.xml')
        pcap_file = os.path.join(folder, 'cellsetup.txt')
        egate_file = os.path.join(folder, 'egate_console.log.002')
        self.assertTrue(verify_csirs_rb_start_and_nr(
            log_path=self.run_log_path,
            scf_file=scf_file, pcap_file=pcap_file, egate_file=egate_file, revision=0, log_level=logging.DEBUG))

    def test08(self):
        folder = os.path.join(self.base, 'logs/TDD_revision1/')
        scf_file = os.path.join(folder, 'MRBTS-1_5_3_UTE5GFT04016_20220801-1706_chbw40_NonBeamforming.xml')
        pcap_file = os.path.join(folder, 'cellsetup.txt')
        egate_file = os.path.join(folder, 'egate_console.log.004')
        self.assertTrue(verify_csirs_rb_start_and_nr(
            log_path=self.run_log_path,
            scf_file=scf_file, pcap_file=pcap_file, egate_file=egate_file, log_level=logging.DEBUG))

    def test09(self):
        folder = os.path.join(self.base, 'logs/FDD_revision1/')
        scf_file = os.path.join(folder, 'MRBTS-1_ET-ASIL-ABIO-AP-FDD_SANSAbandN1_45PRB_config1.xml')
        pcap_file = os.path.join(folder, 'cellsetup.txt')
        egate_file = os.path.join(folder, 'egate_console.log.002')
        self.assertTrue(verify_csirs_rb_start_and_nr(
            log_path=self.run_log_path,
            scf_file=scf_file, pcap_file=pcap_file, egate_file=egate_file, log_level=logging.DEBUG))


if __name__ == '__main__':
    unittest.main()
