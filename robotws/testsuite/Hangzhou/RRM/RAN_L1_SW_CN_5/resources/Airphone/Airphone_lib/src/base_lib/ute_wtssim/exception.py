# -*- coding: utf-8 -*-

from ute_core.exception import CoreException


class WtsSimException(CoreException):
    """A base exception class for the ute_wtssim library."""


class LuaConfigGenError(CoreException):
    """Exception is raised if lua config generator error."""


class PortIsReserved(WtsSimException):
    def __init__(self, who, port):
        msg = "{} port ({}) is reserved by a different process. Cannot continue.".format(who, port)
        super(PortIsReserved, self).__init__(msg)


class ProcessNotFound(WtsSimException):
    def __init__(self, who, port, *warn):
        msg = "No {} process running in port {}. {}".format(who, port, warn)
        super(ProcessNotFound, self).__init__(msg)


class ProcessCannotStart(WtsSimException):
    def __init__(self, msg, out=None, err=None):
        out = '' if out is None else '+++ Output +++\n{}\n\n'.format(out)
        err = '' if err is None else '+++ Error +++\n{}\n\n'.format(err)
        msg = '{}{}{}'.format(msg, out, err)
        super(ProcessCannotStart, self).__init__(msg)


class NoRegexpMatch(WtsSimException):
    """Exception raised when some operation cannot match regexp."""


class InvalidSSHClient(WtsSimException):
    """Exception raised when an SSH client object doesn't have required methods."""


class InvalidTelnetClient(WtsSimException):
    """Exception raised when a telnet client object doesn't have required methods."""


class CannotAddNotificationClient(WtsSimException):
    """Exception raised when notifier has client information for specified alias."""


class MultipleScfcAreFound(LuaConfigGenError):
    """Exception is raised if more than one scfc file is found on eNB."""


class DirectoryError(LuaConfigGenError):
    """Exception is raised if destination directory does not exist."""


class SSHCommandError(LuaConfigGenError):
    """Exception is raised if rc of shell command on eNB is not zero."""


class ConfigParameterError(LuaConfigGenError):
    """Exception is raised if passed config parameter is not valid."""


class IphyConfigValidationError(CoreException):
    """Exception raised when iphy config validation is not successful."""
