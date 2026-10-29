# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
"""
# from common_lib import common_lib
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.common_lib import common_lib
# from config import configuration
# from cm import cm
from testsuite.Paris.RRM.ET.CB009836.resources.python.cm import cm

# from pm.pm import pm
# from fm.fm import fm
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.startup import startup
# from features import features
# from tools import tools
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.log_analysis import log_analysis


class Dev_lib(log_analysis, common_lib, cm, startup):

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        log_analysis.__init__(self)
        common_lib.__init__(self)
        cm.__init__(self)
        startup.__init__(self)


if __name__ == "__main__":
    obj = Dev_lib()
    help(obj)
    # PARAMS_IN_VENDOR = ['actTddCsirsAllocOptimization=true']
    # modified_vendor_file= obj.change_vendor_parameters(PARAMS_IN_VENDOR)
