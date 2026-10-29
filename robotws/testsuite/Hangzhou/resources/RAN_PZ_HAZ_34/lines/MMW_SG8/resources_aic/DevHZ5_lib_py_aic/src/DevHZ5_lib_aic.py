# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
from .common_lib_aic import common_lib_aic
from .config import configuration
from .cm_aic_cluster import cm_aic_cluster
from .pm_aic.pm_aic import pm_aic
from .fm_aic.fm_aic import fm_aic
from .startup_aic.startup_aic import startup_aic
from .features import features
from .tools_aic import tools
from .tools_aic import aic_tools
from .log_analysis_aic import log_analysis_aic
from .call_aic import call_aic


class DevHZ5_lib_aic(
        common_lib_aic,
        configuration,
        pm_aic,
        cm_aic_cluster,
        fm_aic,
        features,
        tools,
        aic_tools,
        log_analysis_aic,
        startup_aic,
        call_aic):

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        common_lib_aic.__init__(self)
        pm_aic.__init__(self)
        cm_aic_cluster.__init__(self)
        fm_aic.__init__(self)
        features.__init__(self)
        # tools reduplicate with aic_tools
        tools.__init__(self)
        aic_tools.__init__(self)
        log_analysis_aic.__init__(self)
        startup_aic.__init__(self)
        configuration.__init__(self)
        call_aic.__init__(self)


if __name__ == "__main__":
    obj = DevHZ5_lib_aic()
    help(obj)
