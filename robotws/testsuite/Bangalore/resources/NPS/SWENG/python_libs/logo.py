# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Krzysztof Michalek
:contact: krzysztof.michalek@nokia.com
:maintainer: None
:contact: None
"""
from __future__ import print_function
import os
from robot.libraries.BuiltIn import BuiltIn


def _call_keyword(keyword):
    return BuiltIn().run_keyword(keyword)


def _log_to_console(text):
    BuiltIn().log_to_console(text, no_newline=False)


def leave_5g_ta_logo():
    """Prints 5G TA logo"""
    directory = os.path.dirname(__file__)
    try:
        with open('{}/logo.txt'.format(directory), 'r') as logo:
            lines = logo.read().splitlines()
            for line in lines:
                # print("{}".format(line))
                _log_to_console("{}".format(line))
    except IOError:
        pass
