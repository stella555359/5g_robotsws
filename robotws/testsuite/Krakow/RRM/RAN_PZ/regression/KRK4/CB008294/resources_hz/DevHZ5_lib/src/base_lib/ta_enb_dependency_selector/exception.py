# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Al-john Vizcarra
:contact: al-john.vizcarra@nokia.com
:maintainer: Michael Liclican, Al-john Vizcarra
:contact: michael.liclican@nokia.com, al-john.vizcarra@nokia.com
"""

from ute_core.exception import CoreException


class EnbDependencySelectorException(CoreException):
    """Main Enb Dependency Selector Library Exception"""


class MissingNsetapVersion(EnbDependencySelectorException):
    """Exception is raised when NSETAP version is not included in Manifest.ini of enb load."""


class FileDoesNotExist(EnbDependencySelectorException):
    """Exception is raised when file to be downloaded does not exist."""
