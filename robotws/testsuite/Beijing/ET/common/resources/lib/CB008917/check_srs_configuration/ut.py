# -*- coding: utf-8 -*-
"""
2022/08/03 first version by @author: song.guo@nokia-sbell.com
    The TestCheckSrsConfiguration class is unittest class for verify srs configuration.
2022/08/19 second version by @author: song.guo@nokia-sbell.com
    add blanking prb part
2022/09/06 third version by @author: song.guo@nokia-sbell.com
    add pooling + blanking prb part
2022/09/08 fourth version by @author: song.guo@nokia-sbell.com
    add pooling + dedicated bwp part
"""
import logging
import unittest
import os
from testsuite.Beijing.ET.common.resources.lib.CB008917.check_srs_configuration import verify_srs_configuration
from testsuite.Beijing.ET.common.resources.lib.exception_et import CaseFail


class TestCheckSrsConfiguration(unittest.TestCase):
    def setUp(self):
        self.base = os.path.dirname(__file__)
        self.run_log_path = os.path.join(self.base, r'../run_logs')

    def test01(self):
        scf_file = os.path.join(
            self.base,
            'logs/log_20220803/Configuration_scf_MRBTS-1_ET-ASIL-ABIO-AP-FDD_SANSAbandN1_45PRB_config.xml')
        emil_file = os.path.join(self.base, 'logs/log_20220803/mon.0.emil.5gm.txt')
        pcap_file = os.path.join(self.base, 'logs/log_20220803/45prbbipcellsetup.txt')
        self.assertTrue(verify_srs_configuration(log_path=self.run_log_path,
                        scf_file=scf_file, emil_file=emil_file, pcap_file=pcap_file,
                        version=1, log_level=logging.DEBUG))

    def test02(self):
        scf_file = os.path.join(
            self.base,
            'logs/log_20220804/Configuration_scf_8917-ASIL-ABIO-AP-FDD_10M50PRB_NSA__20220721-0825.xml')
        emil_file = os.path.join(self.base, 'logs/log_20220804/mon.0-nsa.emil.5gm.txt')
        pcap_file = os.path.join(self.base, 'logs/log_20220804/FDD10M50PRB_NSA_CELLSETUP.txt')
        self.assertTrue(verify_srs_configuration(log_path=self.run_log_path,
                        scf_file=scf_file, emil_file=emil_file, pcap_file=pcap_file,
                        version=1, log_level=logging.DEBUG))

    def test03(self):
        scf_file = os.path.join(self.base,
                                'logs/log_20220802/Configuration_scf_MRBTS-1_5-3-UTE5GFT04016_20220801-1539.xml')
        emil_file = os.path.join(self.base, 'logs/log_20220802/mon.0-70prb.emil.5gm.txt')
        pcap_file = os.path.join(self.base, 'logs/log_20220802/70prb-bipcellsetup.txt')
        self.assertTrue(verify_srs_configuration(log_path=self.run_log_path,
                        scf_file=scf_file, emil_file=emil_file, pcap_file=pcap_file,
                        version=1, log_level=logging.DEBUG))

    def test04(self):
        scf_file = os.path.join(
            self.base,
            'logs/log_20220819/Configuration_scf_tc058_ET-ASIk-ABIL-AP-FDD_PRBblanking_11_11_basicCA.xml')
        emil_file = os.path.join(self.base, 'logs/log_20220819/mon.0-new.emil.5gm.txt')
        pcap_file = os.path.join(self.base, 'logs/log_20220819/TC58BIP_Cellsetup.txt')
        self.assertTrue(verify_srs_configuration(
            log_path=self.run_log_path,
            scf_file=scf_file, emil_file=emil_file, pcap_file=pcap_file, version=1, log_level=logging.DEBUG))

    def test05(self):
        scf_file = os.path.join(self.base,
                                'logs/log_20220825/Configuration_scf8917_tc31_tdd40M100prb.xml')
        emil_file = os.path.join(self.base, 'logs/log_20220825/mon.0.emil.5gm.txt')
        pcap_file = os.path.join(self.base, 'logs/log_20220825/TDD100PRBBIPcellsetup.txt')
        self.assertTrue(verify_srs_configuration(
            log_path=self.run_log_path,
            scf_file=scf_file, emil_file=emil_file, pcap_file=pcap_file, version=1, log_level=logging.DEBUG))

    def test06(self):
        scf_file = os.path.join(
            self.base,
            'logs/log_20220906/Configuration_scf_MRBTS-1_ET-ASIL-ABIO-AP-FDD_PRBblanking_15_11_pooling.xml')
        emil_file = os.path.join(self.base, 'logs/log_20220906/mon.0.emil.5gm.txt')
        pcap_file = os.path.join(self.base, 'logs/log_20220906/cellsetup.txt')
        self.assertTrue(verify_srs_configuration(
            log_path=self.run_log_path,
            scf_file=scf_file, emil_file=emil_file, pcap_file=pcap_file, version=1, log_level=logging.DEBUG))

    def test07(self):
        scf_file = os.path.join(
            self.base,
            'logs/log_20220907/' +
            'Configuration_scf_MRBTS-1_ET-ASIL-ABIO-AP-FDD_20220908-1421_10M_45PRB_dedicateBWP_pooling.xml')
        emil_file = os.path.join(self.base, 'logs/log_20220907/mon.0.emil.5gm.txt')
        pcap_file = os.path.join(self.base, 'logs/log_20220907/10M_45PRB.txt')
        self.assertTrue(verify_srs_configuration(
            log_path=self.run_log_path,
            scf_file=scf_file, emil_file=emil_file, pcap_file=pcap_file, version=1, log_level=logging.DEBUG))

    def test08(self):
        scf_file = os.path.join(
            self.base,
            'logs/log_20220908/' +
            'Configuration_scf_MRBTS-1_ET-ASIL-ABIO-AP-FDD_20220908-1134_70PRB_dedicateBWP_pooling.xml')
        emil_file = os.path.join(self.base, 'logs/log_20220908/mon.0.emil.5gm.txt')
        pcap_file = os.path.join(self.base, 'logs/log_20220908/15M_70PRB.txt')
        self.assertTrue(verify_srs_configuration(
            log_path=self.run_log_path,
            scf_file=scf_file, emil_file=emil_file, pcap_file=pcap_file, version=1, log_level=logging.DEBUG))


if __name__ == '__main__':
    unittest.main()
