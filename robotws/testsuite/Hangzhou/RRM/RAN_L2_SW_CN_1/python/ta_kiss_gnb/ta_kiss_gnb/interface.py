# -*- coding: utf-8 -*-
"""
:created on: 2020-01-11

:copyright: Nokia
:author: Yao Yonna
:contact: yonna.yao@nokia-sbell.com
"""

from .counter_control import CounterControl


class ta_kiss_gnb(CounterControl):

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        CounterControl.__init__(self)
        pass
