from taf.sbts.oam.coam.admin import admin
from datetime import datetime, timezone, timedelta
from time import sleep
from robot.libraries.BuiltIn import BuiltIn

connection = None


def get_connection():
    """Returns caom_admin connection object
    """
    global connection
    if connection is None:
        coam_admin = admin()
        connection = coam_admin.connect_to()
    return connection


def get_rmod_power():
    """Retrieves real-time measurements and returns power of RMOD_1.

    :return: RMOD_1 power.
    :rtype: float
    """
    rt_meas_list = get_connection().get_measurements()
    power_value = None
    for entry in rt_meas_list:
        if 'ENERGY_EFFICIENCY/RMOD/RMOD_R-1' in entry:
            power_value = float(entry['ENERGY_EFFICIENCY/RMOD/RMOD_R-1']['power'])
            break
    return power_value


def update_lbpsPeriodList_with_current_time():
    """Sets lbpsDayOfWeek, lbpsStartTimeHour, lbpsStartTimeMinute to current time,
       lbpsDuration to 120 minutes and lbpsSuspended to notSuspended
    """
    now = datetime.now(timezone.utc)
    five_minutes_ago = now - timedelta(minutes=5)
    day_of_week = five_minutes_ago.strftime("%A")
    hour = five_minutes_ago.hour
    minute = five_minutes_ago.minute
    get_connection().perform_parameter_recommissioning(
        dist_name="MRBTS-{}/NRBTS-{}/NRPGRP-1".format(get_mrbts(), get_nrbts()),
        parameter="lbpsPeriodList",
        value=[{"lbpsDayOfWeek": day_of_week[:3], "lbpsStartTimeHour": hour, "lbpsStartTimeMinute": minute,
                'lbpsDuration': 120, 'lbpsSuspended': 'notSuspended'}],
        operation="update")


def update_actNrLBRTXPowerSaving(value):
    """Sets actNrLBRTXPowerSaving to chosen value
    """
    get_connection().perform_parameter_recommissioning(
        dist_name="MRBTS-{}/NRBTS-{}".format(get_mrbts(), get_nrbts()),
        parameter="actNrLBRTXPowerSaving",
        value=value,
        operation="update")


def validate_cell_energy_saving(expected_status):
    """Retrieves cells info and validates if Cell_1 energySavingState is as expected
    """
    cell_info = get_connection().get_cells_info()
    energy_saving_state = next(
        (entry['energySavingState'] for entry in cell_info
         if 'NRCELL_R-1' in entry['id']['internal']),
        'not found'
    )
    assert energy_saving_state == expected_status, \
        f"energySavingState is {energy_saving_state}, but should be {expected_status}"


def wait_for_energySavingState_update():
    """Wait 5 minutes for energySavingState to update
    """
    sleep(300)


def get_nrbts():
    """
    Used to retrieve NRBTS id from testline configuration
    :return: type: int
    """
    return BuiltIn().get_variable_value("${tl.gnbs[0].global_bts_id}")


def get_mrbts():
    """
    Used to retrieve MRBTS id from testline configuration
    :return: type: int
    """
    return BuiltIn().get_variable_value("${tl.gnbs[0].instance_id}")
