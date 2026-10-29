# -*- coding: utf-8 -*-
"""
2023/04/19 first version by @author: hang.du@nokia-sbell.com
    The TestCheckSharedSrResource class is unittest class for CheckSharedSrResource.
"""
import logging
import unittest
import os
from testsuite.Beijing.ET.common.resources.lib.CB010318.check_shared_sr_resource import verify_shared_sr_resource
from testsuite.Beijing.ET.common.resources.lib.exception_et import CaseFail


class TestCheckSharedSrResource(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01(self):
        folder = os.path.join(self.base, 'logs/CB010318-A4-1/')
        scf_file = os.path.join(folder, 'SCF_running.xml')
        egate_file = os.path.join(folder, 'egate_console.log.001')
        pcap_file = os.path.join(folder, 'CPlane_E1F1.txt')
        self.assertTrue(verify_shared_sr_resource(log_path=self.run_log_path,
                                                  scf_file=scf_file, pcap_file=pcap_file, egate_file=egate_file,
                                                  log_level=logging.DEBUG))


if __name__ == '__main__':
    unittest.main()
