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

VARIABLES = {
    "7_16_UTE5GHASTROTL03": {
        "custom_alarms": ["8000"],
        "L3_CALL": False,
    },
    "7_16_UTE5GHASTROTL04": {
        "UPGRADE_ITERATIONS": 1,
        "SITE_RESET_ITERATIONS": 1,
        "RU_RESET_ITERATIONS": 1,
        "BBMOD_RESET_ITERATIONS": 1,
        "LOCK_UNLOCK_ITERATIONS": 1,
        "custom_alarms": ["4681", "61030"],
        "L3_CALL": False,
    },
    "7_16_UTE5GHASTROTL23": {
        "RU_RESET_ITERATIONS": 3,
        "BBMOD_RESET_ITERATIONS": 3,
        "LOCK_UNLOCK_ITERATIONS": 3,
        "DELTA_ITERATIONS": 3,
        "custom_alarms": ["4681", "7107", "7311", "7306", "7307", "8000"],
        "L3_CALL": False,
    },
    "7_16_UTE5GHASTROTL25": {
        "TEST_ITERATION": 5,
        "custom_alarms": ["4681", "7107", "7311", "7306", "7307"],
        "L3_CALL": False,
    },
    "7_16_UTE5GHASTROTL26": {
        "TEST_ITERATION": 1,
        "custom_alarms": ["4681", "62003", "8000"],
    },
    "7_16_UTE5GHASTROTL70": {
        "TEST_ITERATION_WEEK": 60,
        "custom_alarms": ["4681", "4728", "7312"],
        "L3_CALL": True,
    },
    "7_16_UTE5GHASTROTL71": {
        "TEST_ITERATION_WEEK": 60,
        "custom_alarms": ["4681", "4728", "7312", "7313", "2922", "2923", "7115", "62002", "62003"],
        "L3_CALL": False,
    },
    "7_16_UTE5GHASTROTL73": {
        "TEST_ITERATION": 1,
        "TEST_ITERATION2": 1,
        "L3_CALL": True,
        "custom_alarms": ["4728", "7312", "4681", "4764"],
        "TEST_ITERATION_WEEK": 60
    },
    "7_16_UTE5GHASTROTL74": {
        "TEST_ITERATION": 10,
        "custom_alarms": ["4681", "7107", "7311", "7306", "7307"],
        "5G_SOURCE_SW": "SBTS00_ENB_9999_230628_000010",
        "L3_CALL": False,
    },
    "7_16_UTE5GHASTROTL75": {
        "TEST_ITERATION": 15,
        "custom_alarms": ["62003", "4681"],
    },
    "7_16_UTE5GHASTROTL76": {
        "TEST_ITERATION": 15,
        "custom_alarms": ["62003", "4681"],
    },
    "7_16_UTE5GHASTROTL77": {
        "TEST_ITERATION": 10,
        "custom_alarms": ["4681", "7107", "7311", "7306", "7307"],
        "5G_SOURCE_SW": "SBTS00_ENB_9999_230628_000010",
        "L3_CALL": False,
    },
    "7_16_UTE5GHASTROCSTMO26": {
        "TEST_ITERATION_WEEK": 60,
        "custom_alarms": ["4681", "4290", "4291", "4728", "1838", "62003", "8000"],
    },
    "7_16_UTE5GHASTROCSTMO27": {
        "custom_alarms": ["4681", "4290", "4291", "4728", "6327", "62001", "6203", "7307", "7107", "6278", "7115",
                          "4546", "62003", "1898", "8000", "4655", "4741", "7100", "61649", "7311", "7319", "2002",
                          "6331"],
    },
    "7_16_UTE5GHASTROCSTMO28": {
        "custom_alarms": ["4681", "4290", "4291", "4728", "6327", "62001", "6203", "7307", "7107", "6278", "7115"],
    },
    "7_16_UTE5GHASTROCSTMO58": {
        "custom_alarms": ["4681", "4290", "4291", "4728", "6327", "62001", "6203", "7307", "7107", "6278", "7115",
                          "4546", "62003", "1898", "8000", "4655", "4741", "7100", "61649", "7311", "7319", "2002",
                          "4203"],
    },
    "7_16_UTE5GHASTROCSTMO83": {
        "custom_alarms": ["4546", "4728", "7107", "62003", "1898", "4681", "8000", "4655", "4741", "7100", "61649",
                          "7311", "7319", "7307", "2002", "7300", "7319", "7311", "2421", "4681", "61649", "7114",
                          "7114", "6117", "4546"]
    },
    "7_16_UTE5GHASTROCSTMO312": {
        "custom_alarms": ['4546', '4728', '7107', '62003', '1898', '4681', '8000', '4655', '4741', '7100', '61649',
                          '7311', '7319', '7307', '2002', '2934'],
    },
    "7_16_UTE5GHASTROMUTANT3": {
        "UPGRADE_ITERATIONS": 2,
        "SITE_RESET_ITERATIONS": 10,
        "BBMOD_RESET_ITERATIONS": 20
    },
    "7_16_UTE5GHASTROMUTANT4": {
        "SITE_RESET_ITERATIONS": 50,
        "RU_RESET_ITERATIONS": 5,
        "BBMOD_RESET_ITERATIONS": 5,
        "LOCK_UNLOCK_ITERATIONS": 5,
        "DELTA_ITERATIONS": 3,
        "custom_alarms": ["4681", "7107", "7311", "7306", "7307", "8000"],
        "L3_CALL": False,
    }
}

VARIABLE = {}
try:
    VARIABLE = DEFAULT_VALUES.copy()
    if is_weekend():
        VARIABLES[get_hostname()]["TEST_ITERATION"] = \
            VARIABLES[get_hostname()].get('TEST_ITERATION_WEEK', VARIABLE["TEST_ITERATION_WEEK"])
    VARIABLE.update(VARIABLES[get_hostname()])
    logger.debug(VARIABLE)
except KeyError:
    logger.info(
        "Hostname {} does not exist in VARIABLES dictionary!".format(get_hostname()), also_console=True
    )

CUSTOM_SW_CONFIG_FLAGS = {
    '0x10041': ('2', 'UDP_SYSLOG'),
    '0x100B7': ('1', 'enable_OAM_core_dump'),
    '0x10079': ('300000', 'bigger_core_dump'),
    '0x3F001E': ('1', 'coredump_during_shutdown')
}
