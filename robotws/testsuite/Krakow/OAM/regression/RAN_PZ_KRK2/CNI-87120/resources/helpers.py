"""
author: Maciej Russek, maciej.russek@nokia.com
maintainer: Maciej Russek, maciej.russek@nokia.com
description: Python helper methods
"""

from taf.rfrl.bts.devices.exceptions import AlarmIsNotActive


def verify_fan_overspeed_alarm_exist_in_file(filepath, expected_alarm_count,
                                             alarm_string='(4080)	EFaultId_FanOverSpeedAl '):
    alarm_counter = 0
    file = open(filepath, "r")
    filelines = file.readlines()

    for i in range(len(filelines)):
        if alarm_string in filelines[i]:
            alarm_counter += 1

    if alarm_counter != int(expected_alarm_count):
        raise AlarmIsNotActive("There is {} fan alarms in {}".format(alarm_counter, filepath))
