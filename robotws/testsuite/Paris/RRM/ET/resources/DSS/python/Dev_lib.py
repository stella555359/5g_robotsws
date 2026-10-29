# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
"""
from testsuite.Paris.RRM.ET.resources.DSS.python.common_lib import common_lib
from testsuite.Paris.RRM.ET.resources.DSS.python.startup import startup


class Dev_lib(common_lib, startup):

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        common_lib.__init__(self)
        startup.__init__(self)


if __name__ == "__main__":
    obj = Dev_lib()
    help(obj)
