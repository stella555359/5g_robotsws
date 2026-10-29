import socket
from robot.api import logger
from datetime import date
import calendar
import json

weekend_days = ["Friday", "Saturday", "Sunday"]


def get_hostname():
    hostname = socket.gethostname()
    hostname = hostname.replace("-", "_")
    return hostname


def is_weekend():
    current_day = calendar.day_name[date.today().weekday()]
    for day in weekend_days:
        if day == current_day:
            return True
    return False


def check_tl_reservation_state(filename='/opt/ute/reservation.json'):
    try:
        with open(filename) as json_file:
            data = json.load(json_file)
        return data['enb_state']
    except FileNotFoundError:
        return 'sw_uploaded'


CRITICAL_FAULTS = ["10", "16", "1806", "1868", "4341", "4352", "4383"]
DEFAULT_VALUES = {
    "TEST_ITERATION": 30,
    "TEST_ITERATION2": 5,
    "TEST_ITERATION3": 1,
    "UPGRADE_ITERATIONS": 5,
    "SITE_RESET_ITERATIONS": 30,
    "RU_RESET_ITERATIONS": 5,
    "BBMOD_RESET_ITERATIONS": 5,
    "LOCK_UNLOCK_ITERATIONS": 5,
    "DELTA_ITERATIONS": 5,
    "custom_alarms": ["4728", "7312", "4681"],
    "critical_faults": CRITICAL_FAULTS,
    "5G_SOURCE_SW": "SBTS23R1_ENB_0000_000777_000006",
    "L3_CALL": False,
    "L3_CALL_CELLS": None,
    "L3_CALL_TPUT_SRC": "control_app",
    "TEST_ITERATION_WEEK": 30
}

VARS_VRF_WRO2_T01 = {
    "7_16_UTE5GCLOUDT151": {
        "custom_alarms": ["4681", "2002", "4038"],
        "TEST_ITERATION": 50,
        "TEST_ITERATION2": 5,
        "L3_CALL": False,
    },
    "7_16_UTE5GCLOUDT152": {
        "custom_alarms": ["4681", "2002", "4038"],
        "TEST_ITERATION": 50,
        "TEST_ITERATION2": 5,
        "L3_CALL": False,
    },
    "7_16_UTE5GCLOUDT161": {
        "critical_faults": ["10", "1806", "1868", "4341", "4352", "4383"],
        "custom_alarms": ["4681", "2002", "4038", "16", "4452"],
        "TEST_ITERATION": 50,
        "TEST_ITERATION2": 5,
        "L3_CALL": False,
    },
    "7_16_UTE5GCLOUDT177": {
        "custom_alarms": ["4681", "2002", "4038"],
        "TEST_ITERATION": 50,
        "TEST_ITERATION2": 5,
        "L3_CALL": False,
    },
    "7_16_UTE5G286CLASS041_2": {
        "custom_alarms": ["4681", "2002", "4038"],
        "TEST_ITERATION": 10,
        "TEST_ITERATION2": 5,
        "L3_CALL": False,
    },
    "7_16_UTE5GCLOUDT201": {
        "custom_alarms": ["4681", "2002", "4038"],
        "TEST_ITERATION": 50,
        "TEST_ITERATION2": 5,
        "L3_CALL": False,
    },
    "7_16_UTE5GSA5_1": {
        "custom_alarms": ["4681", "2002", "4038", "4546"],
        "TEST_ITERATION": 50,
        "TEST_ITERATION2": 10,
        "L3_CALL": False,
    },
}

VARIABLE_default = {}
try:
    VARIABLE_default = DEFAULT_VALUES.copy()
    if is_weekend():
        VARS_VRF_WRO2_T01[get_hostname()]["TEST_ITERATION"] = \
            VARS_VRF_WRO2_T01[get_hostname()].get('TEST_ITERATION_WEEK', VARIABLE_default["TEST_ITERATION_WEEK"])
    VARIABLE_default.update(VARS_VRF_WRO2_T01[get_hostname()])
    logger.debug(VARIABLE_default)
except KeyError:
    logger.info(
        "Hostname {} does not exist in VARS_VRF_WRO2_T01 dictionary!".format(get_hostname()), also_console=True
    )

CUSTOM_SW_CONFIG_FLAGS = {
    '0x10041': ('2', 'UDP_SYSLOG'),
    '0x100B7': ('1', 'enable_OAM_core_dump'),
    '0x10079': ('300000', 'bigger_core_dump'),
    '0x3F001E': ('1', 'coredump_during_shutdown')
}
