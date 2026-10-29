# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""

from .mdrb_aic import mdrb_aic
from .pa_aic import pa_aic


class call_aic(mdrb_aic, pa_aic):
    def __init__(self):
        mdrb_aic.__init__(self)
        pa_aic.__init__(self)
