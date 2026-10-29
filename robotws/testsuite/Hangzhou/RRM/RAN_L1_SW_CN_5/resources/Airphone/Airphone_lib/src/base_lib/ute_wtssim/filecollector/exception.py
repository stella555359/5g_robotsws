# -*- coding: utf-8 -*-

from ute_core.exception import CoreException


class FileCollectorException(CoreException):
    """Exception raised if it was not possible to collect files."""


class GetTestlineInfoException(CoreException):
    """Exception raised during get_testline_info.sh execution."""
