# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
from .cm_bts import cm_bts
from .cm_iphy import cm_iphy


class cm(cm_bts, cm_iphy):
    def __init__(self):
        cm_bts.__init__(self)
        cm_iphy.__init__(self)


if __name__ == "__main__":
    cm_obj = cm()
    help(cm)
