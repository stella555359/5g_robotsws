# -*- coding: UTF-8 -*-
"""
Authors:
michal.kusiak@nokia.com
marcin.sokolowski@nokia.com
przemyslaw.romanczyk@nokia.com
michal.popiel@nokia.com
krystian.gordziejewski@nokia.com
"""

import re
import logging


def get_enb_alarm_ids(enb_alarms):
    enb_alarm_ids = []

    for alarm in enb_alarms:
        try:
            if int(alarm.faultId) != 61524 or int(alarm.faultId) != 61510 or int(alarm.faultId) != 61649:
                enb_alarm_ids.append(int(alarm.faultId))
        except Exception:
            if (int(alarm.alarmInformation.alarmText.alarmAdditionalInfo.additionalFaultID) != 61524 or
                    int(alarm.alarmInformation.alarmText.alarmAdditionalInfo.additionalFaultID) != 61510
                    or int(alarm.alarmInformation.alarmText.alarmAdditionalInfo.additionalFaultID) != 61649):
                enb_alarm_ids.append(alarm.alarmInformation.alarmText.alarmAdditionalInfo.additionalFaultID)

    enb_alarm_ids.sort()
    return enb_alarm_ids


def get_nsp_alarm_ids(nsp_alarms):
    nsp_alarms_ids = []
    prog = re.compile(r'(?<=additionalFaultI[dD][:=])\d*')
    for alarm in nsp_alarms:
        tmp = re.search(prog, str(alarm))
        if tmp:
            nsp_alarms_ids.append(str(tmp.group()))
        else:
            nsp_alarms_ids.append(alarm["alarmName"])
    return nsp_alarms_ids


def get_netact_alarm_ids(netact_alarms):
    netact_alarms_ids = []
    prog = re.compile(r'(?<=additionalFaultI[dD][:=])\d*')

    if isinstance(netact_alarms, list):
        for item in netact_alarms:
            tmp = re.search(prog, str(item))
            if tmp:
                netact_alarms_ids.append(int(tmp.group()))
    else:
        for key, value in netact_alarms.items():
            for element in value:
                tmp = re.search(prog, str(element))
                if tmp:
                    netact_alarms_ids.append(int(tmp.group()))
    return netact_alarms_ids


def get_netact_number_alarms(netact_alarms):
    netact_alarms_ids = []
    prog = re.compile(r'(?<=specificProblem\'[:=]\s)\d*')

    if isinstance(netact_alarms, list):
        for item in netact_alarms:
            tmp = re.search(prog, str(item))
            if tmp:
                netact_alarms_ids.append(int(tmp.group()))
    else:
        for key in netact_alarms.keys():
            netact_alarms_ids.append(int(key))
    return netact_alarms_ids


def compare_alarms_from_enb_and_netact(enb_alarms, netact_alarms):
    """
    Return true if all eNB alarm IDs are present on NetAct.
    Otherwise return False.
    modified by michal.popiel@nokia.com
    """
    enb_alarm_ids = get_enb_alarm_ids(enb_alarms)
    netact_alarms_ids = get_netact_alarm_ids(netact_alarms)

    # print 'enb', enb_alarm_ids
    # print 'netact', netact_alarms_ids
    for alarm_id in enb_alarm_ids:
        if (str(alarm_id) == str(4293) or str(alarm_id) == str(61524) or
                str(alarm_id) == str(61510) or str(alarm_id) == str(61649)):
            continue
        if alarm_id not in netact_alarms_ids:
            logging.error(alarm_id, ' missing from NetAct alarms!')
            return False, alarm_id
    return True, None


def remove_allowed_alarms(available, allowed):
    not_allowed_alarms = []
    if allowed:
        for alarm in available:
            match = False
            for regex in allowed:
                match = re.search(regex, alarm)
                if match:
                    status = True
                    break
            if not match:
                not_allowed_alarms.append(alarm)
    else:
        not_allowed_alarms = list(available)
    return not_allowed_alarms


def check_mandatory_alarms(available, mandatory):
    if not isinstance(mandatory, list):
        mandatory = [mandatory]
    unexpected_alarms = []
    if mandatory:
        for regex in mandatory:
            match = False
            for alarm in available:
                match = re.search(regex, alarm)
                if match:
                    status = True
                    break
            if not match:
                unexpected_alarms.append(regex)
    if not unexpected_alarms:
        return True
    else:
        raise AssertionError("Lack of mandatory alarms: %s" % unexpected_alarms)


def remove_expected_alarms(available, expected):
    if not isinstance(expected, list):
        expected = [expected]
    unexpected_alarms = []
    if expected:
        for alarm in available:
            match = False
            for regex in expected:
                match = re.search(regex, alarm)
                if match:
                    status = True
                    break
            if not match:
                unexpected_alarms.append(alarm)
    else:
        unexpected_alarms = list(available)
    return unexpected_alarms
