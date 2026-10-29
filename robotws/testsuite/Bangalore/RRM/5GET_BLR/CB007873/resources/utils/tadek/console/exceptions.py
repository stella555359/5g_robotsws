# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""


class InvalidConsoleTypeError(Exception):
    """ Exception class for invalid console type """

    def __init__(self, console):
        message = "Given console `{}` is not a valid value!"
        super(InvalidConsoleTypeError, self).__init__(message.format(console))
