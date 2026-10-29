# -*- coding: utf-8 -*-


from ute_core.exception import CoreException


class EnbDependencySelectorException(CoreException):
    """Main Enb Dependency Selector Library Exception"""


class MissingNsetapVersion(EnbDependencySelectorException):
    """Exception is raised when NSETAP version is not included in Manifest.ini of enb load."""


class FileDoesNotExist(EnbDependencySelectorException):
    """Exception is raised when file to be downloaded does not exist."""
