"""
ANR (Automatic Neighbor Relations) utilities module.

This module provides functionality for analyzing ANR operations, neighbor removal,
and related syslog verification for 5GC features.
"""

import re
from datetime import datetime
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils import file_reader
from testsuite.Wroclaw.RRM.resources.log.log import blog


def get_removal_fire_times(syslog_path: str, removal_auto: bool | None = None) -> list[str]:
    """
    Retrieves the times when rdNeighRemovalEvaluationTime timer fired from syslog.

    :param syslog_path: The path to the syslog file.
    :type syslog_path: str
    :param removal_auto: If True, looks for auto removal enabled pattern.
                        If False, looks for auto removal disabled pattern.
                        If None, looks for basic timer fire pattern. Defaults to None.
    :type removal_auto: bool | None
    :return: A list of timestamps when the timer fired (format: "HH:MM:SS").
    :rtype: list[str]
    """
    fires = []

    if removal_auto is True:
        pattern = (
            "Timer rdNeighRemovalEvaluationTime fired, "
            "creating AutomaticNeighbourRelationRemovalProcedure."
        )
    elif removal_auto is False:
        pattern = ("Timer rdNeighRemovalEvaluationTime fired. ActAutoNrNbRemoval was disabled in last cycle, "
                   "AutomaticNeighbourRelationRemovalProcedure skipped.")
    else:
        pattern = "Timer rdNeighRemovalEvaluationTime fired, creating AutomaticNeighbourRelationRemovalProcedure."

    for line in file_reader(syslog_path):
        if pattern in line:
            fires.append(line.split(' ')[1].split('.')[0])

    return fires


def count_fires(syslog_path: str, auto_removal: bool | None = None) -> int:
    """
    Counts the number of times rdNeighRemovalEvaluationTime timer fired.

    :param syslog_path: The path to the syslog file.
    :type syslog_path: str
    :param auto_removal: If True/False, looks for corresponding auto removal pattern.
                        If None, looks for basic timer fire pattern. Defaults to None.
    :type auto_removal: bool | None
    :return: The count of timer fires.
    :rtype: int
    """
    return len(get_removal_fire_times(syslog_path, auto_removal))


def check_time_difference(syslog_path: str, auto_removal: bool | None = None) -> bool:
    """
    Verifies that rdNeighRemovalEvaluationTime timer fires are 300 seconds (5 minutes) apart.

    :param syslog_path: The path to the syslog file.
    :type syslog_path: str
    :param auto_removal: If True/False, looks for corresponding auto removal pattern.
                        If None, looks for basic timer fire pattern. Defaults to None.
    :type auto_removal: bool | None
    :return: True if time differences are correct, False if no fires found.
    :rtype: bool
    :raises AssertionError: If time difference between fires is not 300 seconds.
    """
    fires = get_removal_fire_times(syslog_path, auto_removal)

    if len(fires) == 0:
        return False

    prev = datetime.strptime(fires[0], "%H:%M:%S")
    for fire in fires[1:]:
        fire_time = datetime.strptime(fire, "%H:%M:%S")
        assert (fire_time - prev).seconds == 300, \
            f"Expected 300 seconds between timer fires, got {(fire_time - prev).seconds}"
        prev = fire_time

    return True


def confirm_srb3(syslog_path: str, require_srb3: bool = True) -> bool:
    """
    Confirms SRB3 activation or deactivation in syslog.

    :param syslog_path: The path to the syslog file.
    :type syslog_path: str
    :param require_srb3: If True, verifies SRB3 is activated.
                        If False, verifies SRB3 is not activated. Defaults to True.
    :type require_srb3: bool
    :return: True if the expected SRB3 status is found.
    :rtype: bool
    :raises ValueError: If the expected message is not found in syslog.
    """
    if require_srb3:
        srb3_pattern = re.compile(
            r'.*?SgnbAdditionProcedure.cpp:\d+'
            r'.*?SRB3 is activated'
            r'.*?for UE: ueIdCu:\d+', re.IGNORECASE)
    else:
        srb3_pattern = re.compile(
            r'.*?SgnbAdditionProcedure.cpp:\d+'
            r'.*?SRB3 is not activated'
            r'.*?', re.IGNORECASE)

    for line in file_reader(syslog_path):
        if srb3_pattern.match(line):
            return True

    raise ValueError(f'No SRB3 {"activation" if require_srb3 else "deactivation"} message found in syslog')


def confirm_inter_gnb_ho(syslog_path: str) -> bool:
    """
    Confirms inter-gNB handover succeeded by checking for required syslog patterns.

    :param syslog_path: The path to the syslog file.
    :type syslog_path: str
    :return: True if handover succeeded.
    :rtype: bool
    :raises ValueError: If handover procedure failed (missing required messages).
    """
    ho_pattern = re.compile(
        r'.*?CellNeighbourStatusUpdateIndProcedure.cpp:\d+ .*?inter-gNb.*?'
        r'.*?hoSucceeded.*?', re.IGNORECASE)
    gnb_confirm_pattern = re.compile(
        r'.*?Handler.hpp:\d+ Received response of type messages::x2ap::SgNBChangeConfirm', re.IGNORECASE)
    gnb_change_pattern = re.compile(
        r'.*?SgNbChangeEventHandler.cpp:\d+'
        r'.*?PCMD - Change sgNbChangeResult setting from : '
        r'SgNbChangeResult:success to : SgNbChangeResult:success',
        re.IGNORECASE)

    ho_ok, sgnb_confirm, sgnb_change = False, False, False

    for line in file_reader(syslog_path):
        if not ho_ok and ho_pattern.match(line):
            blog(f"HO succeeded pattern: {ho_pattern.match(line).group(0)}")
            ho_ok = True
        if not sgnb_confirm and gnb_confirm_pattern.match(line):
            blog(f"gNb confirm pattern: {gnb_confirm_pattern.match(line).group(0)}")
            sgnb_confirm = True
        if not sgnb_change and gnb_change_pattern.match(line):
            blog(f"gNB change pattern: {gnb_change_pattern.match(line).group(0)}")
            sgnb_change = True

        if all([ho_ok, sgnb_confirm, sgnb_change]):
            return True

    raise ValueError(
        f'Handover procedure failed: ho_ok={ho_ok}, '
        f'sgnb_confirm={sgnb_confirm}, sgnb_change={sgnb_change}'
    )


def confirm_nrrel_removed(syslog_path: str) -> bool:
    """
    Confirms NRREL removal in syslog.

    :param syslog_path: The path to the syslog file.
    :type syslog_path: str
    :return: True if NRREL removal message is found.
    :rtype: bool
    :raises ValueError: If no NRREL removal message is found in syslog.
    """
    nrrel_removal_pattern = re.compile(
        r'.*?AutomaticNeighbourRelationRemovalProcedure.cpp:\d+'
        r'.*?AutomaticNeighbourRelationRemovalProcedure:'
        r'.*?Removing 2 NrRels and 0 NrAdjNrCells', re.IGNORECASE)

    for line in file_reader(syslog_path):
        if nrrel_removal_pattern.match(line):
            return True

    raise ValueError('No NRREL removal message found in syslog')


def confirm_nradjnrcell_removed(syslog_path: str) -> bool:
    """
    Confirms NRADJNRCELL removal in syslog.

    :param syslog_path: The path to the syslog file.
    :type syslog_path: str
    :return: True if NRADJNRCELL removal message is found.
    :rtype: bool
    :raises ValueError: If no NRADJNRCELL removal message is found in syslog.
    """
    nradjnrcell_removal_pattern = re.compile(
        r'.*?AutomaticNeighbourRelationRemovalProcedure.cpp:\d+'
        r'.*?AutomaticNeighbourRelationRemovalProcedure:'
        r'.*?Removing 0 NrRels and 2 NrAdjNrCells', re.IGNORECASE)

    for line in file_reader(syslog_path):
        if nradjnrcell_removal_pattern.match(line):
            return True

    raise ValueError('No NRADJNRCELL removal message found in syslog')
