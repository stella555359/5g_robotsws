"""
:copyright: Nokia Networks
:author: Damian Muszynski
:contact: damian.muszynski@nokia.com
:maintainer: I_EXT_5G_IV_WRO_OAM3_GMS

This module contains robot framework utility keywords.
"""


from robot.libraries.BuiltIn import BuiltIn, ExecutionFailed


def wait_until_keyword_fails(retry, retry_interval, name, *args):
    BuiltIn().wait_until_keyword_succeeds(retry, retry_interval, keyword_fails.__name__, name, *args)


def keyword_fails(name, *args):
    try:
        BuiltIn().run_keyword(name, *args)
    except ExecutionFailed:
        return True
    else:
        raise AssertionError("Keyword '{}' did not fail".format(name))
