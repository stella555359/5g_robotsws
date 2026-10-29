# -*- coding: utf-8 -*-
"""
2022/08/19 first version by @author: sheng.1.ye@nokia.com
    The TestCheckPuschRbAllcation class is unittest class for CheckPuschRbAllcation.
"""
import logging
import unittest
import os
from testsuite.Beijing.ET.common.resources.lib.CB008917.check_pusch_rb_allocation import verify_pusch_rb_allocation
from testsuite.Beijing.ET.common.resources.lib.exception_et import CaseFail


class TestCheckPuschRbAllcation(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01(self):
        folder = os.path.join(self.base, 'logs/CB008917-A-b_TC023/')
        scf_file = os.path.join(folder, 'SCF_running.xml')
        egate_file = os.path.join(folder, 'egate_console.log.001')
        tti_ul_file = os.path.join(folder, 'format_output_ul.csv')
        pcap_file = os.path.join(folder, 'cellsetup.txt')
        self.assertTrue(verify_pusch_rb_allocation(log_path=self.run_log_path,
                                                   scf_file=scf_file, pcap_file=pcap_file, egate_file=egate_file,
                                                   tti_ul_file=tti_ul_file,
                                                   pucch_prb_number=16,
                                                   log_level=logging.DEBUG))

    def test02(self):
        folder = os.path.join(self.base, 'logs/msg1FrequencyStart10/')
        scf_file = os.path.join(folder, 'Configuration_scf_MRBTS-1_5_3_UTE5GFT04015_20220802-1105.xml')
        egate_file = os.path.join(folder, 'egate_console.log.002')
        tti_ul_file = os.path.join(folder, 'format_output_ul.csv')
        pcap_file = os.path.join(folder, 'cellsetup.txt')
        self.assertTrue(verify_pusch_rb_allocation(log_path=self.run_log_path,
                                                   scf_file=scf_file, pcap_file=pcap_file, egate_file=egate_file,
                                                   tti_ul_file=tti_ul_file,
                                                   pucch_prb_number=16,
                                                   log_level=logging.DEBUG))

    def test03(self):
        folder = os.path.join(self.base, 'logs/msg1FrequencyStart10_auto_pucch_prb_num/')
        scf_file = os.path.join(folder, 'Configuration_scf_MRBTS-1_5_3_UTE5GFT04015_20220802-1105.xml')
        egate_file = os.path.join(folder, 'egate_console.log.002')
        tti_ul_file = os.path.join(folder, 'format_output_ul.csv')
        pcap_file = os.path.join(folder, 'CPlane_E1F1.pcap_3.6.txt')
        self.assertTrue(verify_pusch_rb_allocation(log_path=self.run_log_path,
                                                   scf_file=scf_file, pcap_file=pcap_file, egate_file=egate_file,
                                                   tti_ul_file=tti_ul_file,
                                                   log_level=logging.DEBUG))


if __name__ == '__main__':
    unittest.main()
