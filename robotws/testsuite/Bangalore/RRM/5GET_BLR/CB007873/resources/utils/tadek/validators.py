# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
import re
import sys

from ipaddress import ip_interface

from .errors import InvalidTypeError, ValueMismatchError, PatternMismatchError, ItemNotInIterableError, \
    InvalidAuthenticatorFieldError, InvalidHostnameError, InvalidIPAddressError, InvalidHostAddressError

if sys.version_info[0] >= 3:
    from builtins import str as unicode


def validate_object_type(object_, expected_type, anonymize_exception=False):
    """ Checks if object's type matches expected type
    :param object object_: Object that will be checked
    :param object|tuple(object)|list(object) expected_type: expected type of object. \
                                                            Can be single value or tuple|list
    :param bool anonymize_exception: If set to true then exception won't show given object_ value
    """
    if not isinstance(object_, expected_type):
        raise InvalidTypeError(object_, expected_type, type(object_), anonymize_exception)


def validate_object_value(object_, expected_value, anonymize_exception=False):
    """ Checks if object's value matches expected one
    :param object object_: Object that will be checked
    :param expected_value: expected value of object
    :param bool anonymize_exception: If set to true then exception won't show given object_ value
    """
    if object_ != expected_value:
        raise ValueMismatchError(object_, expected_value, anonymize_exception)


def validate_object_in_iterable(object_, iterable, anonymize_exception=False):
    """ Checks if object is in iterable. Can be used to check substrings as well
    :param object object_: Object that will be checked
    :param iterable: Iterable in which object is expected
    :param bool anonymize_exception: If set to true then exception won't show given object_ value
    """
    if object_ not in iterable:
        raise ItemNotInIterableError(object_, anonymize_exception)


def validate_string_matches_pattern(string, pattern, anonymize_exception=False):
    """ Checks if tested string matches given pattern
    :param str string: tested string
    :param str|re.Pattern pattern: regex pattern
    :param bool anonymize_exception: If set to true then exception won't show given string value
    """
    if not re.match(pattern, string):
        str_pattern = pattern if isinstance(pattern, str) else pattern.pattern
        raise PatternMismatchError(string, str_pattern, anonymize_exception)


def validate_iterable_not_empty(iterable):
    """ Checks if there are any elements in iterable

    :param iterable:
    """
    if not iterable:
        raise Exception('Given iterable is empty!')


def validate_every_item_in_iterable(condition, iterable):
    """ Checks if every item in iterable fulfills condition, if any of items doesn't then exception is raised
    :param condition: function checking item from iterable
    :param iterable: Iterable containing items under test
    """
    if not all(condition(item) for item in iterable):
        raise Exception('There is at least one item in iterable that doesn\'t match given condition!')


def validate_string(object_, anonymize_exception=False):
    """ Checks if given object_ is string.
    :param str|None object_: tested object
    :param bool anonymize_exception: If set to true then exception won't show given string value
    """
    validate_object_type(object_, (str, unicode), anonymize_exception)


def validate_login(login):
    """ Checks if login has acceptable characters
    :param str|unicode login:
    """
    login_pattern = re.compile('^[a-zA-Z0-9_-]+$')
    validate_string(login)
    validate_string_matches_pattern(login, login_pattern)


def validate_password(password):
    """ Checks if password has acceptable characters
    :param str|unicode password:
    """
    password_pattern = re.compile(r'^[A-Za-z0-9 !\"#$%&\'()*+,-./:;<=>?@[\]^_`{|}~]+$')
    validate_string(password, True)
    validate_string_matches_pattern(password, password_pattern, True)


def validate_authenticator(authenticator):
    """ Checks if given authenticator contains only valid fields and if those field are strings.
    :param dict authenticator: dictionary with parameters used to connect to remote host. \
        Keys are: \
        'key' - path to rsa key, \
        'user' - user on remote host, \
        'password' - password used to establish connection.
    """
    authenticator_keys = set(authenticator.keys())
    valid_keys = {'key', 'user', 'password'}
    if authenticator_keys - valid_keys:
        raise InvalidAuthenticatorFieldError(authenticator_keys)
    else:
        if 'key' in authenticator_keys:
            validate_string(authenticator.get('key'))
        if 'user' in authenticator_keys:
            validate_login(authenticator.get('user'))
        if 'password' in authenticator_keys:
            validate_password(authenticator.get('password'))


def validate_host_address(address):
    """ Checks if given address is valid IPv4/IPv6 or hostname
    :param str address: tested address
    """
    try:
        validate_ip_address(address)
    except InvalidIPAddressError:
        try:
            validate_hostname(address)
        except InvalidHostnameError:
            raise InvalidHostAddressError(address)


def validate_ip_address(address):
    """ Checks if given address is valid IPv4 or IPv6 address
    :param str address: IPv4 or IPV6 address
    """
    try:
        ip_interface(unicode(address))
    except ValueError:
        raise InvalidIPAddressError(address)


def validate_hostname(hostname):
    """ Checks if given hostname is valid
    :param str hostname:
    """
    hostname_pattern = re.compile(r'^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*'
                                  r'([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$')
    try:
        validate_string(hostname)
        validate_string_matches_pattern(hostname, hostname_pattern)
    except PatternMismatchError:
        raise InvalidHostnameError(hostname)
    except InvalidTypeError:
        raise InvalidHostnameError(hostname)
