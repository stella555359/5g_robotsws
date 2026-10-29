# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
from .emil import capture_emil
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.SG3.AP.src.tools.wireshark import wireshark
from .a2a_improve import a2a_improve
from .auto_cfg import auto_cfg
from .a2a_fail_parse import a2a_fail_parse
from .traffic import traffic
from .suiteteardown_report import SuiteTeardownReport
from .gnb_bip import gnb_bip
from .ap_bip import ap_bip
from .check_cap import CapPacket
from .gnb_l2stream import gnb_l2stream
from .ap_ttitrace import ap_ttitrace
from .trs_traffic import trs_traffic


class tools(capture_emil, wireshark, a2a_improve, auto_cfg, a2a_fail_parse, traffic,
            SuiteTeardownReport, gnb_bip, ap_bip, CapPacket, gnb_l2stream, ap_ttitrace, trs_traffic):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        capture_emil.__init__(self)
        wireshark.__init__(self)
        a2a_improve.__init__(self)
        auto_cfg.__init__(self)
        a2a_fail_parse.__init__(self)
        traffic.__init__(self)
        SuiteTeardownReport.__init__(self)
        gnb_bip.__init__(self)
        ap_bip.__init__(self)
        CapPacket.__init__(self)
        gnb_l2stream.__init__(self)
        ap_ttitrace.__init__(self)
        trs_traffic.__init__(self)


if __name__ == "__main__":
    obj = tools()
    help(obj)
