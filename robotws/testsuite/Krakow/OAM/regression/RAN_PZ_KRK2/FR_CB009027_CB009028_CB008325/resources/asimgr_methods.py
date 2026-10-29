# -*- coding: utf-8 -*-
"""
Author: Grzegorz Kaczor
"""

from moler.util.moler_test import MolerTest
from taf.ul.sc.asimgr import AsiMgr


class AsirHandler(object):

    def __init__(self):
        pass

    @staticmethod
    @MolerTest.raise_background_exceptions()
    def get_asi_hw_data_based_on_commissioning():
        asimgr = AsiMgr(autoconnect=True)
        hubs = asimgr.get_asi_hw_data_based_on_commissioning()
        return hubs
