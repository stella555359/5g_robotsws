# -*- coding: utf-8 -*-
"""
2022/07/21 first version by @author: song.guo@nokia-sbell.com
    The TestCheckPdcchCoresetAndInitialBwp class is unittest class for verify pdcch coreset and initial bwp.
2022/07/22 second version by @author: song.guo@nokia-sbell.com
    add NSA part
2022/08/19 third version by @author: song.guo@nokia-sbell.com
    add blanking prb part
"""
import logging
import unittest
import os
from testsuite.Beijing.ET.common.resources.lib.CB008917.check_pdcch_coreset_and_initial_bwp import (
    verify_pdcch_coreset_and_initial_bwp)
from testsuite.Beijing.ET.common.resources.lib.exception_et import CaseFail


class TestCheckPdcchCoresetAndInitialBwp(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01(self):
        scf_file = os.path.join(self.base,
                                'logs/log_20220721/8917-ASIL-ABIO-AP-FDD_SANSAbandN1_10M_50PRBSCF.xml')
        egate_file = os.path.join(self.base, 'logs/log_20220721/egate_console.log')
        emil_file = os.path.join(self.base, 'logs/log_20220721/mon.0-new.emil.5gm.txt')
        pcap_file = os.path.join(self.base, 'logs/log_20220721/cellsetup.txt')
        self.assertTrue(verify_pdcch_coreset_and_initial_bwp(
            log_path=self.run_log_path,
            scf_file=scf_file,
            egate_file=egate_file,
            emil_file=emil_file,
            pcap_file=pcap_file,
            log_level=logging.DEBUG))

    def test02(self):
        scf_file = os.path.join(
            self.base,
            'logs/log_20220722/Configuration_scf_8917-ASIL-ABIO-AP-FDD_10M50PRB_NSA__20220721-0825.xml')
        egate_file = os.path.join(self.base, 'logs/log_20220722/egate_console.log')
        emil_file = os.path.join(self.base, 'logs/log_20220722/mon.0-nsa.emil.5gm.txt')
        pcap_file = os.path.join(self.base, 'logs/log_20220722/FDD10M50PRB_NSA_CELLSETUP.txt')
        self.assertTrue(verify_pdcch_coreset_and_initial_bwp(
            log_path=self.run_log_path,
            scf_file=scf_file,
            egate_file=egate_file,
            emil_file=emil_file,
            pcap_file=pcap_file,
            log_level=logging.DEBUG))

    def test03(self):
        scf_file = os.path.join(
            self.base,
            'logs/log_20220819/Configuration_scf_tc058_ET-ASIk-ABIL-AP-FDD_PRBblanking_11_11_basicCA.xml')
        egate_file = os.path.join(self.base, 'logs/log_20220819/egate_console-tc58.log')
        emil_file = os.path.join(self.base, 'logs/log_20220819/mon.0-new.emil.5gm.txt')
        pcap_file = os.path.join(self.base, 'logs/log_20220819/TC58BIP_Cellsetup.txt')
        self.assertTrue(verify_pdcch_coreset_and_initial_bwp(
            log_path=self.run_log_path,
            scf_file=scf_file,
            egate_file=egate_file,
            emil_file=emil_file,
            pcap_file=pcap_file,
            log_level=logging.DEBUG))

    def test04(self):
        scf_file = os.path.join(self.base,
                                'logs/log_20220825/Configuration_scf8917_tc31_tdd40M100prb.xml')
        egate_file = os.path.join(self.base, 'logs/log_20220825/egate_console.log')
        emil_file = os.path.join(self.base, 'logs/log_20220825/mon.0.emil.5gm.txt')
        pcap_file = os.path.join(self.base, 'logs/log_20220825/TDD100PRBBIPcellsetup.txt')
        self.assertTrue(verify_pdcch_coreset_and_initial_bwp(
            log_path=self.run_log_path,
            scf_file=scf_file,
            egate_file=egate_file,
            emil_file=emil_file,
            pcap_file=pcap_file,
            log_level=logging.DEBUG))


if __name__ == '__main__':
    unittest.main()
