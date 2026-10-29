# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: yin.zhang
:contact: yin.zhang@nokia.com
"""
# import sys, os
# sys.path.append(os.path.dirname(__file__))
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_CM_lib.common_lib import common_lib
from testsuite.Krakow.resources.NJ_Resources.Resources.python.DevNJ_CM_lib.cm.cm import cm


class DevNJ_CM_lib(common_lib, cm):

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        common_lib.__init__(self)
        cm.__init__(self)

    def __del__(self):
        common_lib.__del__(self)
        cm.__del__(self)
