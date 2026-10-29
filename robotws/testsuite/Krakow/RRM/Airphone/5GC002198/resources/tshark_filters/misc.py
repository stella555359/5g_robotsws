# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: DevWro1
:maintainer: 5GSWEngWro
:contact: I_TA5G_SUPPORT <I_TA5G_SUPPORT@internal.nsn.com>
"""


DEFAULT_S1_MME_SCTP = "sctp"
SCTP_INIT = "sctp.chunk_type == init"
SCTP_INIT_CREDIT = "sctp.init_credit"
SCTP_INIT_CREDIT_ACKNOWLEDGE = "sctp.initack_credit"
DEFAULT_UU_LESS_1000 = "less 1000"
S1_X2_INTERFACE = "eth3"
UU_INTERFACE = "eth4"
DEFAULT_ENB_LMP = "dst port not 51000"
DEFAULT_LOOPBACK = "(sctp || udp) && less 1000"
