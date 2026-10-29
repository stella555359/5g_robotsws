# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Kacper Falkiewicz
:contact: kacper.falkiewicz@nokia.com
:maintainer: I_5G_SISO_CRT@internal.nsn.com
:contact: I_5G_SISO_CRT@internal.nsn.com
"""
from robot.libraries.BuiltIn import BuiltIn


def raise_when_output_is_empty(func):
    """
    Decorator which add to func additional assertion.

    :param func: Function
    :return: Output of function
    :raise ValueError: Raise when length of output func equals 0
    """
    def wrapper(*args, **kwargs):
        output = func(*args, **kwargs)
        if len(output) == 0:
            raise ValueError("Output is empty.\n Output: {}".format(output))
        return output
    return wrapper


def get_details_to_login_from_init(service):
    """
    Get details to login from given service.
    :param service: str e.g. 'http' or 'ssh'
    :return: tuple of str (address, username, password) e.g. ('192.168.255.129', 'toor4nsn', 'oZPS0POrRieRtu')
    :raises AttributeError when there is no service requested by user
    """
    if service == 'http':
        details_to_login = BuiltIn().get_variable_value("${tl.gnbs[0].cu.oam_http_connection_details}")
    elif service == 'ssh':
        details_to_login = BuiltIn().get_variable_value("${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection}")
    else:
        raise AttributeError("There is no service: {}. Only supported: 'oam' and 'ssh'".format(service))
    return details_to_login.addr, details_to_login.username, details_to_login.password
