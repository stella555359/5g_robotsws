# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
from .pa import pa
from .mdrb import mdrb


class call(pa, mdrb):
    def __init__(self):
        pa.__init__(self)
        mdrb.__init__(self)
