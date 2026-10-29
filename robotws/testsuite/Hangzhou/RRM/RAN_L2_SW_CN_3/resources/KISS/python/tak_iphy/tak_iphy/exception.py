# -*- coding: utf-8 -*-
"""
:created on: 15-04-2017

:copyright: Nokia
:author: Leo Wang
:contact: leo.y.wang@nokia.com
:maintainer: Yonna Yao
:contact: yonna.yao@nokia-sbell.com
"""

from ute_core.exception import CoreException


class KissIphyException(CoreException):
    """Exception for example is raised for delete method."""


class IphyGetPhyCellIdError(KissIphyException):
    """Exception for pci get fail"""


class KissIphyDLAntennaDumpException(CoreException):
    """Exception for example is raised for iphy dul antenna dump method."""


class KissIphyGetDLCoreIdException(CoreException):
    """Exception for example is raised for iphy get core id method."""


class KissIphyTriggerDLAntennaDumpWithNullIphyId(CoreException):
    """Exception for example is raised for trigger_dl_antenna_snapshot_dump method with null iphy id"""


class KissIphyDownloadAntennaDumpDataWithNullIphyId(CoreException):
    """Exception for example is raised for download_dl_antenna_dump_data method with null iphy id"""


class KissIphySibMessageNotReceived(CoreException):
    """Exception is raised for sib1_and_sib2_should_be_received"""
    pass
