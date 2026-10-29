# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
from .cm_aic import cm_aic
from .cm_iphy import cm_iphy    # cm_iphy keep due to AiC using same AP with Classical
from .cm_iphy_aic import cm_iphy_aic


class cm_aic_cluster(cm_aic, cm_iphy, cm_iphy_aic):
    def __init__(self):
        cm_aic.__init__(self)
        cm_iphy.__init__(self)
        cm_iphy_aic.__init__(self)


if __name__ == "__main__":
    cm_obj = cm_aic_cluster()
    help(cm_obj)
