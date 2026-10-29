# -*- coding: utf-8 -*-
"""
:created on: 2020-01-11

:copyright: Nokia
:author: Yao Yonna
:contact: yonna.yao@nokia-sbell.com
"""

from .counter_control import CounterControl
from .feature_log import FeatureLog


class tak_gnb(CounterControl, FeatureLog):

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        CounterControl.__init__(self)
        FeatureLog.__init__(self)
        pass
