# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""


class InvalidTypeError(Exception):
    """
    Invalid type error
    """
    def __init__(self, variable, expected_type, actual_type, anonymize=False):
        if anonymize is False:
            message = 'Object `{}` is `{}`. Expected `{}` !'.format(variable, actual_type, expected_type)
        else:
            message = 'Object is `{}`. Expected `{}` !'.format(actual_type, expected_type)
        super(InvalidTypeError, self).__init__(message)


class ValueMismatchError(Exception):
    """
    Value mismatch error
    """
    def __init__(self, value, expected_value, anonymize=False):
        if anonymize is False:
            message = 'Expected value was `{}`. Got `{}` !'.format(expected_value, value)
        else:
            message = 'Got different value than `{}`!'.format(expected_value)
        super(ValueMismatchError, self).__init__(message)


class ItemNotInIterableError(Exception):
    """
    Item not in iterable error
    """
    def __init__(self, item, anonymize=False):
        if anonymize is False:
            message = 'Item `{}` was expected in iterable but was not found!'.format(item)
        else:
            message = 'Item was not found in iterable!'
        super(ItemNotInIterableError, self).__init__(message)


class PatternMismatchError(Exception):
    """
    Pattern mismatch error
    """
    def __init__(self, string, pattern, anonymize=False):
        if anonymize is False:
            message = 'String `{}` doesn\'t match pattern {}'.format(string, pattern)
        else:
            message = 'String doesn\'t match pattern {}'.format(pattern)
        super(PatternMismatchError, self).__init__(message)


class InvalidIPAddressError(Exception):
    """
    Invalid IP address error
    """
    def __init__(self, address):
        message = 'Address `{}` is not a valid IPv4/IPv6 address!'.format(address)
        super(InvalidIPAddressError, self).__init__(message)


class InvalidHostnameError(Exception):
    """
    Invalid hostname error
    """
    def __init__(self, hostname):
        message = 'Hostname `{}` is not a valid hostname!'.format(hostname)
        super(InvalidHostnameError, self).__init__(message)


class InvalidHostAddressError(Exception):
    """
    Invalid host address error
    """
    def __init__(self, address):
        message = 'Address `{}` is not a valid IPv4/IPv6 address or hostname!'.format(address)
        super(InvalidHostAddressError, self).__init__(message)


class InvalidAuthenticatorFieldError(Exception):
    """
    Invalid authenticator field error
    """
    def __init__(self, authenticator_keys):
        message = "Given authenticator contains invalid fields: `{}`".format(authenticator_keys)
        super(InvalidAuthenticatorFieldError, self).__init__(message)


class TimeoutError(Exception):
    """
    Timeout error
    """
    def __init__(self, timeout):
        message = 'Timeout ({}s) has been reached! Operation didn\'t finish in time'.format(timeout)
        super(TimeoutError, self).__init__(message)
