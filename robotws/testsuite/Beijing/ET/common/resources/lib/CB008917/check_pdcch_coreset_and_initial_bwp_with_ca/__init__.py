# -*- coding: utf-8 -*-
"""
2022/09/19 first version by song.guo@nokia-sbell.com
    this is the checker to verify pdcch coreset and initial bwp with CA
2022/09/20 second version by song.guo@nokia-sbell.com
    add distinguish cellDepType
"""

import unittest
from testsuite.Beijing.ET.common.resources.lib.CB008917.check_pdcch_coreset_and_initial_bwp_with_ca.checkpcell import (
    verify_pdcch_coreset_and_initial_bwp_pcell)
from testsuite.Beijing.ET.common.resources.lib.CB008917.check_pdcch_coreset_and_initial_bwp_with_ca.checkscell import (
    verify_pdcch_coreset_and_initial_bwp_scell)


def verify_pdcch_coreset_and_initial_bwp_with_ca(log_path, scf_file, emil_file, pcap_file, log_level=None):
    verify_pdcch_coreset_and_initial_bwp_pcell(log_path=log_path, scf_file=scf_file, emil_file=emil_file,
                                               pcap_file=pcap_file, log_level=log_level)
    verify_pdcch_coreset_and_initial_bwp_scell(log_path=log_path, scf_file=scf_file, emil_file=emil_file,
                                               pcap_file=pcap_file, log_level=log_level)
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)
