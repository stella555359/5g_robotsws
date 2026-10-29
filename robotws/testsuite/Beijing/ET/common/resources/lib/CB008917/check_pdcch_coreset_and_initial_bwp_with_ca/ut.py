# -*- coding: utf-8 -*-
"""
2022/09/19 first version by @author: song.guo@nokia-sbell.com
    The TestCheckPdcchCoresetAndInitialBwpWithCA class is unittest class
        for verify pdcch coreset and initial bwp with CA.
"""
import logging
import unittest
import os
from testsuite.Beijing.ET.common.resources.lib.CB008917.check_pdcch_coreset_and_initial_bwp_with_ca import (
    verify_pdcch_coreset_and_initial_bwp_with_ca)
from testsuite.Beijing.ET.common.resources.lib.exception_et import CaseFail


class TestCheckPdcchCoresetAndInitialBwpWithCA(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01(self):
        scf_file = os.path.join(self.base,
                                'logs/log_20220914/SCF_running.xml')
        emil_file = os.path.join(self.base, 'logs/log_20220914/mon.0.emil.5gm.txt')
        pcap_file = os.path.join(self.base, 'logs/log_20220914/CPlane_E1F1.pcap.txt')
        self.assertTrue(verify_pdcch_coreset_and_initial_bwp_with_ca(
            log_path=self.run_log_path,
            scf_file=scf_file, emil_file=emil_file, pcap_file=pcap_file, log_level=logging.DEBUG))

    def test02(self):
        scf_file = os.path.join(self.base,
                                'logs/log_20220919/SCF_running.xml')
        emil_file = os.path.join(self.base, 'logs/log_20220919/mon.0.emil.5gm.txt')
        pcap_file = os.path.join(self.base, 'logs/log_20220919/CPlane_E1F1.pcap.txt')
        self.assertTrue(verify_pdcch_coreset_and_initial_bwp_with_ca(
            log_path=self.run_log_path,
            scf_file=scf_file, emil_file=emil_file, pcap_file=pcap_file, log_level=logging.DEBUG))

    def test03(self):
        scf_file = os.path.join(self.base,
                                'logs/log_20220921/SCF_running.xml')
        emil_file = os.path.join(self.base, 'logs/log_20220921/mon.0.emil.5gm.txt')
        pcap_file = os.path.join(self.base, 'logs/log_20220921/CPlane_E1F1.pcap.txt')
        self.assertTrue(verify_pdcch_coreset_and_initial_bwp_with_ca(
            log_path=self.run_log_path,
            scf_file=scf_file, emil_file=emil_file, pcap_file=pcap_file, log_level=logging.DEBUG))


if __name__ == '__main__':
    unittest.main()
