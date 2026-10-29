# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
:contact: I_ASL3_HZH_TA_FRAMEWORK_GMS@internal.nsn.com
"""
from common_lib import common_lib
# from config import configuration
from cm import cm
# from pm.pm import pm
from fm.fm import fm
from startup.startup import startup
# from features import features
from check_log import check_log
# from log_analysis import log_analysis


class AP_lib(common_lib, cm, fm, check_log, startup):

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        common_lib.__init__(self)
#        pm.__init__(self)
        cm.__init__(self)
        fm.__init__(self)
#        features.__init__(self)
        check_log.__init__(self)
#        log_analysis.__init__(self)
        startup.__init__(self)
#        configuration.__init__(self)


if __name__ == "__main__":
    obj = AP_lib()
    help(obj)
