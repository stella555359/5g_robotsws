# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
from common_lib import common_lib
from config import configuration
from cm.cm import cm
from pm.pm import pm
from fm.fm import fm
from features import features
from tools1 import tools
from log_analysis import log_analysis
from sas.sas import sas
from base_lib.ta_xml import ta_xml
from base_lib.ute_fsmaccess import ute_fsmaccess


class DevHZ5_lib(common_lib, configuration, pm, cm, fm, features, tools, log_analysis, sas, ta_xml, ute_fsmaccess):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        common_lib.__init__(self)
        pm.__init__(self)
        cm.__init__(self)
        fm.__init__(self)
        features.__init__(self)
        tools.__init__(self)
        log_analysis.__init__(self)
        sas.__init__(self)
        configuration.__init__(self)
        ta_xml.__init__(self)
        ute_fsmaccess.__init__(self)


if __name__ == "__main__":
    obj = DevHZ5_lib()
    help(obj)
