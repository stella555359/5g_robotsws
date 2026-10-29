# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
from .wireshark import wireshark
from .a2a_improve import a2a_improve
from .auto_cfg import auto_cfg
from .a2a_fail_parse import a2a_fail_parse
from .check_cap import CapPacket


class tools(wireshark, a2a_improve, auto_cfg, a2a_fail_parse, CapPacket):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        wireshark.__init__(self)
        a2a_improve.__init__(self)
        auto_cfg.__init__(self)
        a2a_fail_parse.__init__(self)
        CapPacket.__init__(self)


if __name__ == "__main__":
    obj = tools()
    help(obj)
