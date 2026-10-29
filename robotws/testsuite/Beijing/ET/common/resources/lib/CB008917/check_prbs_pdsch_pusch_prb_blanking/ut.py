# -*- coding: utf-8 -*-
"""
2022/08/30 first version by @author: song.guo@nokia-sbell.com
    The TestCheckPrbsPdschPuschPrbBlanking class is unittest class for verify the prbs of pdsch and pusch
    on prb blanking feature.

"""
import logging
import unittest
import os
from testsuite.Beijing.ET.common.resources.lib.CB008917.check_prbs_pdsch_pusch_prb_blanking import (
    verify_prbs_pdsch_pusch_prb_blanking)
from testsuite.Beijing.ET.common.resources.lib.exception_et import CaseFail


class TestCheckPrbsPdschPuschPrbBlanking(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01(self):
        scf_file = os.path.join(self.base,
                                'logs/log_20220830/Configuration_scf_MRBTS-1_ET-ASIL-ABIO-AP-FDD_PRBblanking_0_21.xml')
        pcap_file = os.path.join(self.base, 'logs/log_20220830/cellsetup.txt')
        tti_dl_file = os.path.join(self.base, 'logs/log_20220830/2730_TTI.bin.19.dl__all.csv')
        tti_ul_file = os.path.join(self.base, 'logs/log_20220830/2730_TTI.bin.11.ul__all.csv')
        self.assertTrue(
            verify_prbs_pdsch_pusch_prb_blanking(
                log_path=self.run_log_path,  scf_file=scf_file, pcap_file=pcap_file, tti_dl_file=tti_dl_file,
                tti_ul_file=tti_ul_file, log_level=logging.DEBUG))


if __name__ == '__main__':
    unittest.main()
