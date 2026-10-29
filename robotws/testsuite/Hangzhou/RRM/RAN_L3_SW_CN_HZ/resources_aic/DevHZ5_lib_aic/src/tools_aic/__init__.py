# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
from .wireshark import wireshark
from .a2a_improve import a2a_improve
from .auto_cfg_aic import auto_cfg_aic
from .a2a_fail_parse import a2a_fail_parse
from .traffic import traffic
from .suiteteardown_report_aic import SuiteTeardownReportAic
from .tti_trace_aic import tti_trace_aic
from .ap_bip_aic import ap_bip_aic
from .ap_ttitrace_aic import ap_ttitrace_aic
from .dcap_aic import dcap_aic


class tools(wireshark,
            a2a_improve,
            a2a_fail_parse,
            traffic,
            SuiteTeardownReportAic,
            tti_trace_aic,
            ap_bip_aic,
            ap_ttitrace_aic,
            dcap_aic):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        wireshark.__init__(self)
        a2a_improve.__init__(self)
        a2a_fail_parse.__init__(self)
        traffic.__init__(self)
        SuiteTeardownReportAic.__init__(self)
        tti_trace_aic.__init__(self)
        ap_bip_aic.__init__(self)
        ap_ttitrace_aic.__init__(self)
        dcap_aic.__init__(self)


class aic_tools(auto_cfg_aic):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        auto_cfg_aic.__init__(self)


if __name__ == "__main__":
    obj = tools()
    help(obj)
