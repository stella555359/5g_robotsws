import os
import re
from time import time

from robot.api import logger
from taf.sbts.oam.coam.admin import admin as cadmin
from taf.rfrl.utilities import tl_config
from taf.rfrl.bts.devices.du.pm_counters import GenericPmCounter
from testsuite.Krakow.resources.alarm import Alarm
from testsuite.Krakow.OAM.regression.RAN_PZ_KRK4.CB012784.resources.variables import *


class WrongActiveAlarms(Exception):
    pass


def verify_alarms(expected_alarms, expected_not_visible_alarms, tc=None):
    mplane_address = tl_config.get_oam_ip_address(bts_id=0, du_id=0, bts_type='GNB')
    api = cadmin()
    admin = api.connect_to(bts_host=mplane_address)
    if tc:
        counters = admin.get_pm_counters(counter_ids="M40015C1,M40015C5,M40015C6")
        expected_alarms, expected_not_visible_alarms = (
            set_expected_alarms_by_counter(expected_alarms, expected_not_visible_alarms, counters, tc))
    current_alarms = admin.get_active_alarms()
    logger.info(f"Active alarms: {current_alarms}")
    ok_alarms = []
    wrong_alarms = []

    for alarm in expected_alarms:
        for current_alarm in current_alarms:
            if 'hwPath' in alarm.keys() and alarm['faultId'] == current_alarm['faultId'] and \
                    alarm['faultName'] == current_alarm['faultName'] and alarm['hwPath'] in current_alarm['hwPath']:
                ok_alarms.append(alarm)
            elif 'notifier' in alarm.keys() and alarm['faultId'] == current_alarm['faultId'] and \
                    alarm['faultName'] == current_alarm['faultName'] and alarm['notifier'] == current_alarm['notifier']:
                ok_alarms.append(alarm)
    for alarm in expected_not_visible_alarms:
        for current_alarm in current_alarms:
            if 'hwPath' in alarm.keys() and alarm['faultId'] == current_alarm['faultId'] and \
                    alarm['faultName'] == current_alarm['faultName'] and alarm['hwPath'] in current_alarm['hwPath']:
                wrong_alarms.append(alarm)
            elif 'notifier' in alarm.keys() and alarm['faultId'] == current_alarm['faultId'] and \
                    alarm['faultName'] == current_alarm['faultName'] and alarm['notifier'] == current_alarm['notifier']:
                wrong_alarms.append(alarm)

    missing_alarms = [item for item in expected_alarms if item not in ok_alarms]
    if missing_alarms or wrong_alarms:
        raise WrongActiveAlarms(f"Expected alarms which are not active: {missing_alarms}. Expected alarms "
                                f"that are active and should not be: {wrong_alarms}.")
    logger.console("Alarms validation passed")


def set_expected_alarms_by_counter(expected_alarms, expected_not_visible_alarms, counters, tc):
    if tc not in ["TC1_1", "TC1_2"]:
        raise Exception("Test case unknown, tc should be TC1_1 or TC1_2")
    counters = counters["BTS"][f"MRBTS-{global_bts_id}"]["EQM-1"]["APEQM-1"]["CABINET-1"]["BBMOD-1"]
    for sfp in counters:
        if tc == "TC1_1":
            time_with_values = counters[sfp]["LANE-1"]["SBTS_SFP_BBMOD_LANE"]["M40015C1"]
            last_timestamp = sorted(list(map(int, time_with_values)))[-1]
            if time_with_values[str(last_timestamp)] > -1.33:
                expected_alarms.append(alarms_sfp_1[sfp])
            else:
                expected_not_visible_alarms.append(alarms_sfp_1[sfp])
        elif tc == "TC1_2":
            lane_counters = counters[sfp]["LANE-1"]["SBTS_SFP_BBMOD_LANE"]
            m40015c1_last_timestamp = sorted(list(map(int, lane_counters["M40015C1"])))[-1]
            m40015c5_last_timestamp = sorted(list(map(int, lane_counters["M40015C5"])))[-1]
            m40015c6_last_timestamp = sorted(list(map(int, lane_counters["M40015C6"])))[-1]
            if lane_counters["M40015C1"][str(m40015c1_last_timestamp)] < -0.005:
                expected_alarms.append(alarms_sfp_2["M40015C1"][sfp])
            else:
                expected_not_visible_alarms.append(alarms_sfp_2["M40015C1"][sfp])
            if lane_counters["M40015C5"][str(m40015c5_last_timestamp)] >= -0.86:
                expected_alarms.append(alarms_sfp_2["M40015C5"][sfp])
            else:
                expected_not_visible_alarms.append(alarms_sfp_2["M40015C5"][sfp])
            if 10 * lane_counters["M40015C6"][str(m40015c6_last_timestamp)] + 10 < 91:
                expected_alarms.append(alarms_sfp_2["M40015C6"][sfp])
            else:
                expected_not_visible_alarms.append(alarms_sfp_2["M40015C6"][sfp])
    logger.console(f"expected_alarms: {expected_alarms},\nexpected_not_visible_alarms:{expected_not_visible_alarms}")
    return expected_alarms, expected_not_visible_alarms
