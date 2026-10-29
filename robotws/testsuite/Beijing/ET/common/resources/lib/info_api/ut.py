# -*- coding: utf-8 -*-
"""
2022/08/23 first version by @author: sheng.1.ye@nokia.com
    The TestInfoAPI class is unittest class for InfoAPI.
"""
import logging
import unittest
import os
import sys

try:
    from testsuite.Beijing.ET.common.resources.lib.info_api import InfoAPI
except ModuleNotFoundError:
    sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    from info_api import InfoAPI


class TestInfoAPI(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01_sort_log_files(self):
        folder = os.path.join(self.base, 'logs/msg1FrequencyStart10/')
        scf_file = os.path.join(folder, 'Configuration_scf_MRBTS-1_5_3_UTE5GFT04015_20220802-1105.xml')
        egate_file = os.path.join(folder, 'egate_console.log.002')
        tti_ul_file = os.path.join(folder, 'format_output_ul.csv')
        pcap_file = os.path.join(folder, 'cellsetup.txt')
        info_api = InfoAPI(log_files=(scf_file, egate_file, tti_ul_file, pcap_file))
        self.assertEqual(info_api.log_dict['scf'][0], scf_file)
        self.assertEqual(info_api.log_dict['egate'][0], egate_file)
        self.assertEqual(info_api.log_dict['csv'][0], tti_ul_file)
        self.assertEqual(info_api.log_dict['other'][0], pcap_file)

    def test02_scf_get_rb_start_and_size(self):
        folder = os.path.join(self.base, 'logs/msg1FrequencyStart10/')
        scf_file = os.path.join(folder, 'Configuration_scf_MRBTS-1_5_3_UTE5GFT04015_20220802-1105.xml')
        pcap_file = os.path.join(folder, 'cellsetup.txt')
        info_api = InfoAPI(log_files=(scf_file, pcap_file))

        dedicated_rb_start_and_size = info_api.scf_get_rb_start_and_size('dedicated')
        initial_rb_start_and_size = info_api.scf_get_rb_start_and_size('initial')
        expected_dedicated_rb_info = {'dl_rb_size': 100, 'dl_rb_start': 3, 'ul_rb_size': 100, 'ul_rb_start': 3}
        expected_initial_rb_info = {'dl_rb_size': 48, 'dl_rb_start': 31, 'ul_rb_size': 48, 'ul_rb_start': 31}
        [self.assertEqual(dedicated_rb_start_and_size[k], v) for k, v in expected_dedicated_rb_info.items()]
        [self.assertEqual(initial_rb_start_and_size[k], v) for k, v in expected_initial_rb_info.items()]

    def test03_scf_get_nr_cell_info(self):
        folder = os.path.join(self.base, 'logs/msg1FrequencyStart10/')
        scf_file = os.path.join(folder, 'Configuration_scf_MRBTS-1_5_3_UTE5GFT04015_20220802-1105.xml')
        info_api = InfoAPI(log_files=(scf_file,))
        self.assertEqual({1: {'grp': 0, 'physCellId': 50}, 2: {'grp': 1, 'physCellId': 51}},
                         info_api.scf_get_nr_cell_info())


if __name__ == '__main__':
    unittest.main()
