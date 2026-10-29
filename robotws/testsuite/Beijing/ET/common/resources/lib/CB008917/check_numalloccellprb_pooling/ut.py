# -*- coding: utf-8 -*-
"""
2022/09/02 first version by @author: song.guo@nokia-sbell.com
    The TestCheckNumAllocCellPrbWithPoolingPrbBlanking class is unittest class for verify the NumAllocCellPrb value
    on Prb Blanking feature with Pooling.
2022/09/08 second version by @author: song.guo@nokia-sbell.com
    Change name TestCheckNumAllocCellPrbWithPoolingPrbBlanking class to TestCheckNumAllocCellPrbWithPooling
2022/09/09 third version by @author: song.guo@nokia-sbell.com
    add pooling + dedicated bwp part
"""
import logging
import unittest
import os
from testsuite.Beijing.ET.common.resources.lib.CB008917.check_numalloccellprb_pooling import (
    verify_numalloccellprb_pooling)
from testsuite.Beijing.ET.common.resources.lib.exception_et import CaseFail


class TestCheckNumAllocCellPrbWithPooling(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01(self):
        scf_file = os.path.join(
            self.base,
            'logs/log_20220901/Configuration_scf_MRBTS-1_ET-ASIL-ABIO-AP-FDD_PRBblanking_15_11_pooling.xml')
        pcap_file = os.path.join(self.base, 'logs/log_20220901/cellsetup.txt')
        tti_dl_file = os.path.join(self.base, 'logs/log_20220901/2730_TTI.bin.19.dl__all.csv')
        tti_ul_file = os.path.join(self.base, 'logs/log_20220901/2730_TTI.bin.19.ul__all.csv')
        self.assertTrue(verify_numalloccellprb_pooling(log_path=self.run_log_path,
                        scf_file=scf_file, pcap_file=pcap_file, tti_dl_file=tti_dl_file, tti_ul_file=tti_ul_file,
                        log_level=logging.DEBUG))

    def test02(self):
        scf_file = os.path.join(
            self.base,
            'logs/log_20220907/' +
            'Configuration_scf_MRBTS-1_ET-ASIL-ABIO-AP-FDD_20220908-1421_10M_45PRB_dedicateBWP_pooling.xml')
        pcap_file = os.path.join(self.base, 'logs/log_20220907/10M_45PRB.txt')
        tti_dl_file = os.path.join(self.base, 'logs/log_20220907/2730_TTI.bin.10.dl__all.csv')
        tti_ul_file = os.path.join(self.base, 'logs/log_20220907/2730_TTI.bin.10.ul__all.csv')
        self.assertTrue(verify_numalloccellprb_pooling(
            log_path=self.run_log_path,
            scf_file=scf_file, pcap_file=pcap_file, tti_dl_file=tti_dl_file, tti_ul_file=tti_ul_file,
            log_level=logging.DEBUG))

    def test03(self):
        scf_file = os.path.join(
            self.base,
            'logs/log_20220908/' +
            'Configuration_scf_MRBTS-1_ET-ASIL-ABIO-AP-FDD_20220908-1134_70PRB_dedicateBWP_pooling.xml')
        pcap_file = os.path.join(self.base, 'logs/log_20220908/15M_70PRB.txt')
        tti_dl_file = os.path.join(self.base, 'logs/log_20220908/2730_TTI.bin.13.dl__all.csv')
        tti_ul_file = os.path.join(self.base, 'logs/log_20220908/2730_TTI.bin.13.ul__all.csv')
        self.assertTrue(verify_numalloccellprb_pooling(
            log_path=self.run_log_path,
            scf_file=scf_file, pcap_file=pcap_file, tti_dl_file=tti_dl_file, tti_ul_file=tti_ul_file,
            log_level=logging.DEBUG))


if __name__ == '__main__':
    unittest.main()
