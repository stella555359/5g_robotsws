"""
:copyright: Nokia Networks
:author: Aleksander Kleczek, Dawid Krawczuk, Maciej Pikula
:contact:
:maintainer: None
:contact: None
"""
from __future__ import absolute_import
from builtins import object
from testsuite.Hangzhou.RRM.RAN_L3_SW_CN_LTE.trunk_sbts.CRT.LTE2275.LTE2275_resource.\
    common.robot_managment import *

from robot.api.deco import keyword


class egate_process_managment(object):

    def __init__(self):
        pass

    @keyword('Start WTS services and reach active state with lua: ${lua_cfg}')
    def start_wts_reach_active(self, lua_cfg):
        setup_teardown_lib = robot_get_library_instance('libraries.ta_setups_and_teardowns')
        setup_teardown_lib.ta_egate_instance.reach_onair(lua_cfg=lua_cfg)
