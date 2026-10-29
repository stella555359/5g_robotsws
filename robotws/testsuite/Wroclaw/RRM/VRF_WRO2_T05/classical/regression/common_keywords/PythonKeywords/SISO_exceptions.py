# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Kacper Falkiewicz
:contact: kacper.falkiewicz@nokia.com
:maintainer: None
:contact: None
"""


class FileDoesNotExist(Exception):
    """
    Raised when file doesn't exist.
    """
    pass


class OutOfRange(Exception):
    """
    Raised when the value is out of range.
    """
    pass


class ParameterHasDifferentValue(Exception):
    """
    Raised when radio params in WebUI have different
    values than in BIM.
    """
    pass


class ParameterIsNotNumeric(Exception):
    """
    Raised when parameter is not numeric.
    """
    pass


class ParameterDoesNotExist(Exception):
    """
    Raised when parameter does not exists.
    """
    pass


class TimeoutError(Exception):
    """
    Classical TimeoutError with broad applications
    """
    pass


class TypeLineDoseNotExist(Exception):
    """
    Raised when type_line doesn't exist in method
    """
    pass


class SwStreamDoseNotExist(Exception):
    """
    Raised when sw_stream doesn't exist in method
    """


class NoCenterFreqForGivenNRARFCN(Exception):
    """
    Raised when there is no center frequency
    for given NRARFCN in Nrarfcn_Fcenter_IF.csv.
    """
    pass


class PowerDiffBelowThreshold(Exception):
    """
    Raised when power difference threshold
    measured by measure_power_diff in sign_analyzer.py
    is not exceeded by actual measure.
    """
    pass


class DeviceError(Exception):
    """
    Raised when user choose device that is not available in get adets status method.
    """
    pass


class DeviceNotReadyError(Exception):
    """
    Raised when AdetS status on one of the xeon's of device is not ready.
    """
    pass


class DifferentHWCount(Exception):
    """
    Raised when count of detected HW from REST API and from int file is different
    """
    pass


class UnknownRadioType(Exception):
    """
    Raised when unsupported radio type is used.
    """
    pass


class InappropriateStatuses(Exception):
    """
    Raised when cell specific info for locked/unlocked cell does not contain proper statuses.
    """


class WrongActivationStatus(Exception):
    """
    Raised when not all cpri link activation statuses on capacity units are correct.
    """


class FaultIsNotPresent(Exception):
    """
    Raised when fault is not present in active alarms on BTS.
    """


class ProgrammableAttenuatorError(Exception):
    """
    Raised when programmable attenuator occurs error.
    """


class SnapshotContentError(Exception):
    """
    Raised when snapshot content is wrong or contains wrong directories.
    """


class NoLmpInterfaceDetected(Exception):
    """
    Raised when there is no lmp interface detected.
    """


class NotEnoughSpace(Exception):
    """
    Raised when there is not enough space on disk.
    """


class WrongSoapUpdateStatus(Exception):
    """
    Raised when soap update status of parameter will differ from 'ok'.
    """
