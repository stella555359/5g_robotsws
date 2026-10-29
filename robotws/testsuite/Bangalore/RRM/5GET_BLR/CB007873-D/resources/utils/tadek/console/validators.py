# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
import re

from robot.api import logger
from ..validators import (
    validate_string_matches_pattern, validate_string, validate_authenticator, validate_host_address
)

from .config import CONSOLES
from .exceptions import InvalidConsoleTypeError


class BaseConsoleValidator(object):
    """ Validator class for consoles that require no further validation """

    def __init__(self, console_name):
        """
        :param str console_name: name of console
        """
        self._console_name = console_name

    def validate(self, kwargs):
        """ Validation method """
        pass

    def _check_mandatory_parameters(self, kwargs, params):
        """ Checks if mandatory parameters were passed in kwargs
        :param dict kwargs: additional parameters passed to keyword
        :param list params: list of mandatory additional parameters
        """
        missing_params = []
        for param in params:
            if param not in kwargs:
                missing_params.append(param)
        if missing_params:
            raise Exception(
                'Missing mandatory parameters `{}` for console `{}`!'.format(missing_params, self._console_name)
            )

    def _convert_to_integer(self, kwargs, key, default_value):
        """ Converts given parameter from kwargs to integer. If conversion is impossible then exception is raised
        :param dict kwargs: additional parameters passed to keyword
        :param str key: name of additional parameter
        :param int default_value: default value
        """
        try:
            kwargs[key] = int(kwargs.get(key, default_value))
        except TypeError:
            raise TypeError(
                'Given parameter `{}` with value `{}` cannot be converted to int!'.format(key, kwargs.get(key))
            )


class SshConsoleValidator(BaseConsoleValidator):
    """ Validator class for Ssh console """

    def validate(self, kwargs):
        """ Checks if host's address has correct format, port is integer (if specified) and authenticator has proper
        format (if specified)"""
        self._check_mandatory_parameters(kwargs, ['address'])
        validate_host_address(kwargs.get('address'))
        self._convert_to_integer(kwargs, 'port', 22)
        if kwargs.get('authenticator') is not None:
            validate_authenticator(kwargs.get('authenticator'))


class TelnetConsoleValidator(BaseConsoleValidator):
    """ Validator class for Telnet console """

    def validate(self, kwargs):
        """ Checks if host's address has correct format, prompt is a string and if port is integer (if specified) """
        self._check_mandatory_parameters(kwargs, ['address', 'prompt'])
        validate_host_address(kwargs.get('address'))
        validate_string(kwargs.get('prompt'))
        self._convert_to_integer(kwargs, 'port', 23)


class BbmodConsoleValidator(BaseConsoleValidator):
    """ Validator class for Bbmod console """

    def validate(self, kwargs):
        """ Checks if given Bbmod console has proper name """
        bbmod_console_pattern = re.compile('^bbmod-[1-3]$')
        validate_string_matches_pattern(self._console_name, bbmod_console_pattern)


class FspConsoleValidator(BaseConsoleValidator):
    """ Validator class for Fsp(j) console """

    def validate(self, kwargs):
        """ Checks if given FSP(j) console has proper name """
        fsp_console_pattern = re.compile(r'^fsp[j]?[\-][1-7][a-d]$|^fsp[j]?[\-][1-3]$')
        validate_string_matches_pattern(self._console_name, fsp_console_pattern)


class ConsoleValidator(object):
    """ Console's validator factory class """

    def __new__(cls, console_name):
        """ Factory-like creation of proper validator class for given console type
        :param str console_name: name of console
        :return: specific instance of console validator class
        :rtype: SshConsoleValidator|TelnetConsoleValidator|BbmodConsoleValidator|FspConsoleValidator|SkipValidation
        :raises: InvalidConsoleTypeError
        """
        validate_string(console_name)
        console_name = console_name.lower()
        console_name_key = console_name.split('-')[0]
        logger.debug('Console name key: {}'.format(console_name_key))
        if console_name_key in CONSOLES.keys():
            validator = cls._instantiate_validator_class(CONSOLES.get(console_name_key).get('validator'), console_name)
            logger.debug('Resolved validator class: {}'.format(type(validator)))
            return validator
        else:
            raise InvalidConsoleTypeError(console_name)

    @staticmethod
    def _instantiate_validator_class(validator, console_name):
        """ Creates instance of validator class
        :param str validator: name of validator class
        :param str console_name: name of console
        :return: instance of validator class
        :rtype: SshConsoleValidator|TelnetConsoleValidator|BbmodConsoleValidator|FspConsoleValidator|SkipValidation
        """
        validator_instance = globals().get(validator)(console_name)
        return validator_instance
