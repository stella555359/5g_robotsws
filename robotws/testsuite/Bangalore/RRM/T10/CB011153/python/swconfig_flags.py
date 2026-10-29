# !/usr/bin/python2.7
# -*- coding: utf-8 -*-

"""Trace Flag set
:copyright: NSB
:author:    Gao Jianzhong
:contact:   jianzhong.gao@nokia-sbell.com
"""


MAC_PS_TRACE_DEBUG = ["0x10041 = 5 #ERadCcs_AaSysLogOutputMode - UDP logging enabled",
                      "0x10040 = 1 #ERadCcs_AaSysLogOutputLevel - Severity changed from DEBUG to INFO",
                      "0x1003F = 1 #ERadCcs_AaSysLogInputLevel - Severity changed from DEBUG to INFO",
                      "0x130020 = 1 #UEC TUecRadDebugLogEnabledGlobal",
                      "0x130021 = 1 #UEC TUecRadDebugLogEnabledUec",
                      "0x1A0020 = 1 #TRSW_DBG_ETHSEC_DISABLED = TRUE"]
