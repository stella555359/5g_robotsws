# -*- coding: utf-8 -*-
"""
:author: Bartosz Bugaj
:contact: bartosz.bugaj@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""

from robot.api import logger

from ..validators import (
    validate_object_type, validate_string, validate_authenticator
)

from .config import VALID_SOURCE_PREFIXES, VALID_DESTINATION_PREFIXES, SMUGGLERS


class BaseSmugglerValidator(object):
    """ Validator class for initial source and destination paths validation """

    INVALID_DESTINATION_MSG = "Invalid destination path. If source is type '{}' destination path " \
                              "should start with '{}'."
    INVALID_PATH_BASE = "Invalid path: {location}. Valid path should start with one of the following: {valid_prefixes}"

    def validate_source_path(self, source):
        """ Base validation of the source path. Checks if path starts with valid string specified in interface class.
            Returns source type prefix and raw source path without prefix.

        :param str source: source path with path type prefix
        :return: path type prefix and raw source path without prefix
        :rtype: tuple
        """

        if source.startswith(VALID_SOURCE_PREFIXES['local']):
            return 'local', source
        else:
            prefix, path = self._get_path_and_prefix_for_location(source)
            self._validate_path_and_prefix(prefix, path, VALID_SOURCE_PREFIXES, source)
            return prefix, path

    def validate_destination_path(self, destination):
        """
        Base validation of the destination path. Checks if path starts with valid string specified in interface class.
        Returns destination type prefix and raw destination path without prefix.

        :param str destination: destination path with path type prefix
        :return: path type prefix and raw destination path without prefix
        :rtype: tuple
        """
        if destination.startswith(VALID_DESTINATION_PREFIXES['local']):
            return 'local', destination
        else:
            prefix, path = self._get_path_and_prefix_for_location(destination)
            self._validate_path_and_prefix(prefix, path, VALID_DESTINATION_PREFIXES, destination)
            return prefix, path

    def validate_kwargs(self, smuggler_type, kwargs):
        """
        Prints warning if any kwargs were given. Used for validating smuggler which doesn't require additional
        parameters.
        :param str smuggler_type: name of smuggler
        :param kwargs: additional parameters
        """
        if kwargs:
            warn_msg = "Parameters {kwargs} are not required for selected smuggler type '{smuggler_type}'. " \
                       "Smuggler type is selected based on given source and destination paths. Check if given paths " \
                       "are correct.".format(kwargs=kwargs, smuggler_type=smuggler_type)
            logger.warn(warn_msg)

    def _get_path_and_prefix_for_location(self, location):
        """ Gets smuggler type prefix and raw location path without prefix.

        :param str location: location path with prefix
        :return: smuggler type prefix, raw path without prefix
        :rtype: tuple
        """
        prefix, separator, path = location.partition('://')
        path = path.lstrip('/')
        print('prefix, path', prefix, path)
        if prefix in ['fsm', 'iphy']:
            path = prefix + '/' + path
        return prefix, path

    def _validate_path_and_prefix(self, prefix, path, valid_prefixes, location):
        """ Validates location path against valid prefixes.

        :param str prefix: smuggler type prefix
        :param str path: path without prefix
        :param dict valid_prefixes: valid prefixes for given location
        :param str location: path with prefix
        """
        location_prefixes = ', '.join(valid_prefixes.values())
        invalid_path_msg = self.INVALID_PATH_BASE.format(location=location, valid_prefixes=location_prefixes)
        if prefix not in valid_prefixes.keys() or not path:
            raise Exception(invalid_path_msg)

    def _validate_source_target_direction(self, destination, source_type, smuggler_type):
        """ Validates if direction of copying obeys specified rules."""

        if source_type == 'local':
            if not destination.startswith(VALID_DESTINATION_PREFIXES[smuggler_type]):
                raise Exception(
                    self.INVALID_DESTINATION_MSG.format(source_type, VALID_DESTINATION_PREFIXES[smuggler_type])
                )
        elif source_type == smuggler_type:
            if not destination.startswith(VALID_DESTINATION_PREFIXES['local']):
                raise Exception(
                    self.INVALID_DESTINATION_MSG.format(source_type, VALID_DESTINATION_PREFIXES['local'])
                )
        else:
            raise Exception(
                self.INVALID_DESTINATION_MSG.format(source_type, VALID_DESTINATION_PREFIXES['local']) +
                "' or '" + VALID_DESTINATION_PREFIXES[smuggler_type] + "'"
            )

    def _check_mandatory_parameters(self, smuggler_type, kwargs, params):
        """
        Checks if mandatory parameters were passed in kwargs
        :param dict kwargs: additional parameters passed to keyword
        :param list params: list of mandatory additional parameters
        """
        missing_params = []
        for param in params:
            if param not in kwargs:
                missing_params.append(param)
        if missing_params:
            raise Exception(
                'Missing mandatory parameters `{}` for smuggler `{}`!'.format(missing_params, smuggler_type))

    def _validate_authenticator(self, smuggler_type, kwargs):
        self._check_mandatory_parameters(smuggler_type, kwargs, ['authenticator'])
        validate_object_type(kwargs['authenticator'], dict)
        validate_authenticator(kwargs['authenticator'])

    def _validate_token(self, smuggler_type, kwargs):
        self._check_mandatory_parameters(smuggler_type, kwargs, ['token'])
        validate_string(kwargs['token'])
        if not kwargs['token']:
            raise Exception("Missing parameter: 'token'.")


class LocalSmugglerValidator(BaseSmugglerValidator):
    """ Validator class for local smuggler """

    def validate_destination_path(self, destination, source_type=None):
        """ Checks if given destination path is a local path """
        if not destination.startswith(VALID_DESTINATION_PREFIXES['local']):
            raise Exception(self.INVALID_DESTINATION_MSG.format(source_type, VALID_DESTINATION_PREFIXES['local']))


class GitSmugglerValidator(BaseSmugglerValidator):
    """ Validator class for git smuggler """

    def validate_destination_path(self, destination, source_type=None):
        """ Checks if given destination path is a local path """
        if not destination.startswith(VALID_DESTINATION_PREFIXES['local']):
            raise Exception(self.INVALID_DESTINATION_MSG.format(source_type, VALID_DESTINATION_PREFIXES['local']))

    def validate_kwargs(self, smuggler_type, kwargs):
        """ Validates additional parameters """
        self._validate_token(smuggler_type, kwargs)


class SvnSmugglerValidator(BaseSmugglerValidator):
    """ Validator class for svn smuggler """

    def validate_destination_path(self, destination, source_type=None):
        """ Checks if given destination path is a local path """
        if not destination.startswith(VALID_DESTINATION_PREFIXES['local']):
            raise Exception(self.INVALID_DESTINATION_MSG.format(source_type, VALID_DESTINATION_PREFIXES['local']))

    def validate_kwargs(self, smuggler_type, kwargs):
        """ Validates additional parameters """
        self._validate_authenticator(smuggler_type, kwargs)


class WebSmugglerValidator(BaseSmugglerValidator):
    """ Validator class for web smuggler """

    def validate_destination_path(self, destination, source_type=None):
        """ Checks if given destination path is a local path """
        if not destination.startswith(VALID_DESTINATION_PREFIXES['local']):
            raise Exception(self.INVALID_DESTINATION_MSG.format(source_type, VALID_DESTINATION_PREFIXES['local']))


class ScpSmugglerValidator(BaseSmugglerValidator):
    """ Validator class for scp smuggler """

    def validate_destination_path(self, destination, source_type=None):
        """ Validates destination path """
        self._validate_source_target_direction(destination, source_type, 'scp')

    def validate_kwargs(self, smuggler_type, kwargs):
        """ Validates additional parameters """
        self._validate_authenticator(smuggler_type, kwargs)


class FsmSmugglerValidator(BaseSmugglerValidator):
    """ Validator class for fsm smuggler """

    def validate_destination_path(self, destination, source_type=None):
        """ Validates destination path"""
        self._validate_source_target_direction(destination, source_type, 'fsm')


class IphySmugglerValidator(BaseSmugglerValidator):
    """ Validator class for iphy smuggler """

    def validate_destination_path(self, destination, source_type=None):
        """ Validates destination path """
        self._validate_source_target_direction(destination, source_type, 'iphy')


class FspSmugglerValidator(BaseSmugglerValidator):
    """ Validator class for fsp smuggler """

    def validate_destination_path(self, destination, source_type=None):
        """ Validates destination path """
        self._validate_source_target_direction(destination, source_type, 'fsp')


class BbmodSmugglerValidator(BaseSmugglerValidator):
    """ Validator class for bbmod smuggler """

    def validate_destination_path(self, destination, source_type=None):
        """ Validates destination path"""
        self._validate_source_target_direction(destination, source_type, 'bbmod')


class SmugglerValidator(object):
    """ Smuggler's validator factory class """

    def __new__(cls, smuggler_name):
        """ Factory-like creation of proper validator class for given smuggler type
        :param str smuggler_name: name of smuggler
        :return: specific instance of smuggler validator class
        :rtype: LocalSmugglerValidator|GitSmugglerValidator|SvnSmugglerValidator|WebSmugglerValidator|
        FsmSmugglerValidator|IphySmugglerValidator|FspSmugglerValidator|BbmodSmugglerValidator
        """
        logger.debug('Smuggler name: {}'.format(smuggler_name))
        validator = globals()[SMUGGLERS.get(smuggler_name).get('validator')]()
        logger.debug('Resolved smuggler handler: {}'.format(type(validator)))
        return validator
