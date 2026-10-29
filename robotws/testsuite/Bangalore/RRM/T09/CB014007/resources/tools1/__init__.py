# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
from .download_pstool import DownloadPstools
from .capture_emil_log import emil
from .capture_enb_ttitrace import enb_ttitrace
from .wireshark import wireshark
from .a2a_improve import a2a_improve
from .a2a_fail_parse import a2a_fail_parse
from .suiteteardown_report import SuiteTeardownReport
from .modify_ini import modify_ini
from .ta_messaging_extend import ta_messaging_extend
from .modify_yaml import modify_yaml
from .cus_pcap import cus_pcap


class tools(DownloadPstools, emil, enb_ttitrace, wireshark, a2a_improve, a2a_fail_parse, SuiteTeardownReport,
            modify_ini, ta_messaging_extend, modify_yaml, cus_pcap):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        DownloadPstools.__init__(self)
        emil.__init__(self)
        enb_ttitrace.__init__(self)
        wireshark.__init__(self)
        a2a_improve.__init__(self)
        a2a_fail_parse.__init__(self)
        SuiteTeardownReport.__init__(self)
        modify_ini.__init__(self)
        modify_yaml.__init__(self)
        cus_pcap.__init__(self)
        ta_messaging_extend.__init__(self)


if __name__ == "__main__":
    obj = tools()
    help(obj)
