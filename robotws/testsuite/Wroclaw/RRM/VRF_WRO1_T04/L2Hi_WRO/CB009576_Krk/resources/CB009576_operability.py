"""
:copyright: Nokia Networks
:author: Damian Piasecki
:maintainer: Damian Piasecki
:contact: damian.piasecki@nokia.com
:team: MN_RAN_RD_VRF_KRK_11
"""

from time import sleep, time


from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import (
    logger_info,
    logger_console_info
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb import (
    handle_admin, wait_for_requested_bts_state
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.webem_alarms import get_warnings


@handle_admin
def perform_site_reset(**kwargs):
    """
    The function to perform site reset procedure
    """

    kwargs["connection"].reset(reset_coverage='Site', wait_for_reconnection=True)
    logger_console_info("Site reset procedure was correctly performed")


@handle_admin
def get_number_of_cells(**kwargs):
    """
    The function to get the number of cells configured on gNB

    :return: (int) Number of cells configured on gNB
    """
    cell_info = kwargs["connection"].get_cells_info("nr")
    number_of_cells = len(cell_info)
    logger_info(f"Number of cells configured on gNB {number_of_cells}")
    return number_of_cells


@handle_admin
def get_cell_operational_state(cell, **kwargs):
    """
    The function to get cell operational state

    :param cell: (int) Cell number for which operational state should be checked
    :return: (str) Cell operational state
    """
    cell_info = kwargs["connection"].get_cells_info("nr")
    cell_state = cell_info[cell]["status"]["operationalState"]
    logger_info(f"Current cell operational state is {cell_state}")
    return cell_state


@handle_admin
def get_cell_barring_status(cell, **kwargs):
    """
    The function to get cell barring status

    :param cell: (int) Cell number for which barring status should be checked
    :return: (str) Cell barring status
    """
    cell_info = kwargs["connection"].get_cells_info("nr")
    barring_status = cell_info[cell]["status"]["barringStatus"]
    logger_info(f"Current cell barring status is {barring_status}")
    return barring_status


def check_barring_status_for_all_cells():
    """
    The function to check if the barring status for all cells is "unbarred"
    """
    number_of_cell = get_number_of_cells()
    statuses = []
    for cell in range(number_of_cell):
        current_status = get_cell_barring_status(cell)
        statuses.append(current_status)
    if all(current_status == "unbarred" for current_status in statuses):
        logger_console_info(f"All cells have the appropriate barring status: unbarred")
    else:
        raise Exception(f"Not all cells have the appropriate barring status: {statuses}")


@handle_admin
def bts_block(**kwargs):
    """
    The function to perform BTS block procedure
    """
    logger_console_info("Starting BTS block procedure")
    kwargs["connection"].block()


@handle_admin
def bts_unblock(**kwargs):
    """
    The function to perform BTS unblock procedure
    """
    logger_console_info("Starting BTS unblock procedure")
    kwargs["connection"].unblock(wait_for_reconnection=False)


@handle_admin
def cell_block(cell_dist_name="MRBTS-1/NRBTS-1/NRCELL-1", **kwargs):
    """
    The function to perform cell block procedure

    :param cell_dist_name: (str) Cell object path
    """
    logger_console_info("Starting cell block procedure")
    kwargs["connection"].block_cell(dist_name=cell_dist_name)


@handle_admin
def cell_unblock(cell_dist_name="MRBTS-1/NRBTS-1/NRCELL-1", **kwargs):
    """
    The function to perform cell unblock procedure

    :param cell_dist_name: (str) Cell object path
    """
    logger_console_info("Starting cell unblock procedure")
    kwargs["connection"].unblock_cell(dist_name=cell_dist_name)


def check_current_alarm_on_bts(wait_time, alarm):
    current_time = time() + (wait_time * 60)
    while time() < current_time:
        num_of_alarms, alarms_set = get_warnings()
        logger_console_info(num_of_alarms)
        logger_console_info(alarms_set)
        alarms = [int(x) for x in alarms_set]

        if alarm in alarms:
            return
        sleep(15)
    raise ValueError(f"Waiting too long: {wait_time} minutes")


def verify_if_gnb_returned_to_onair_state():
    """
    The function to verify if gNB returned to OnAir state
    """
    wait_for_requested_bts_state(bts_state="onair")
    logger_console_info(f"gNB returned to OnAir state")
