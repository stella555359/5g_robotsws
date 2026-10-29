# -*- coding: utf-8 -*-
"""
:<Change Log>
:2017-10-27  Xie yunyi   initial creatation
:2018-03-30  Lin licai   create new kw: get_alarm_time_per_fault_id
:2019-03-04  Lin licai   update and add UT for python3
:
:author: Xie Yunyi
:contact: yunyi.xie@nokia-sbell.com

"""

import re
import time
import datetime
import logging
from SSHLibrary import SSHLibrary

LTE_SIMPLIFIED_DICT = {'alarmInformation': {'alarmNumber': None, 'alarmText': {'alarmDetail': None}, 'faultId': None}}


def bts_ping_ok(bts_host, timeout, host_ip='127.0.0.1', ssh_username='ute', ssh_password='ute'):
    """
    This keyword is to check the destination BTS IP pings OK
    :param String bts_host: hostname or IP address
    :param String timeout: timeout for the ping
    """
    ssh_local = SSHLibrary()
    ssh_local.open_connection(host_ip)
    ssh_local.login(ssh_username, ssh_password)
    start_time = datetime.datetime.now()
    try:
        while (timeout):
            now_time = datetime.datetime.now()
            ret = ssh_local.execute_command("ping -c 4 {}".format(bts_host), return_stdout=False, return_rc=True)
            if ret == 0:
                print("Ping to host %s is successful now!" % bts_host)
                return "pass"
            elif int((now_time - start_time).seconds) > int(timeout):
                raise Exception("BTS host ping fail!")

            else:
                time.sleep(1)
    except Exception as e:
        raise e
    finally:
        ssh_local.close_connection()


def bts_ping_nok(bts_host, timeout, host_ip='127.0.0.1', ssh_username='ute', ssh_password='ute'):
    """
    This keyword is to wait until the destination BTS IP pings not OK
    :param String bts_host: hostname or IP address
    :param String timeout: timeout for the ping
    """
    ssh_local = SSHLibrary()
    ssh_local.open_connection(host_ip)
    ssh_local.login(ssh_username, ssh_password)
    try:
        start_time = datetime.datetime.now()
        while (timeout):
            now_time = datetime.datetime.now()
            ret = ssh_local.execute_command("ping -c 4 {}".format(bts_host), return_stdout=False, return_rc=True)
            if ret == 1:
                print("Ping to host %s is not reachable now!" % bts_host)
                return "pass"
            elif int((now_time - start_time).seconds) > int(timeout):
                raise Exception("BTS host ping is still OK!")
            else:
                time.sleep(1)
    except Exception as e:
        raise e
    finally:
        ssh_local.close_connection()


def bts_reboot(bts_host='192.168.255.129', username='toor4nsn', password='oZPS0POrRieRtu'):
    """
    Reboot the given BTS by cmd reboot
    :param bts_host: host ip of the destination BTS
    :param username: username to ssh to the host ip
    :param password: password to ssh to the host ip
    :return:
    """
    ssh_local = SSHLibrary()
    ssh_local.open_connection(bts_host)
    ssh_local.login(username, password)
    try:
        ssh_local.execute_command('reboot')
        print("Reboot BTS %s" % bts_host)
    except Exception as e:
        print("Reboot error!")
        raise e
    finally:
        ssh_local.close_connection()


def _check_alarm_exist_or_not(all_alarms, check_info):
    """
    Used to check if given info is exist in the alarm list
    :param all_alarms: The return value of get_active_alarms in ute_admin, it's a list
    :param check_info: fault info to check the alarm, it should be a list
    :return: True if alarm exist, False if not
    """
    faultId = None
    severity = None
    distName = None
    number = None
    time = None
    details = None
    eventType = None
    notifier = None

    check_para = {}

    for ai in check_info:
        para_list = ai.split("=")
        check_para[para_list[0]] = para_list[1]

    if "time" in check_para:
        check_para["btsObservationTime"] = check_para["time"]
        del check_para["time"]

    alarm_exist = False
    for each_alarm in all_alarms:
        check_flag = True
        for apara in check_para:
            if str(each_alarm[apara]).strip() != str(check_para[apara]).strip():
                check_flag = False
                break

        if check_flag:
            alarm_exist = True
            break

    return alarm_exist


def check_alarm_exist(all_alarms, check_info):
    """
    check the specified alarm exist
    | Input Paramaters | Man. | Description |
    | all_alarms       | Yes  | The return value of get_active_alarms in ute_admin, it's a list |
    | check_info  | Yes  | info to check the alarm, it should be a list |

    Example
    | check alarm exist | ${all_alarms} | ["faultId=6203", "severity=Major"] |
    """

    if not _check_alarm_exist_or_not(all_alarms, check_info):
        raise Exception("Alarm Not Exist! Check alarm exist failed.")

    return True


def check_alarm_not_exist(all_alarms, check_info):
    """
    check the specified alarm not exist
    | Input Paramaters | Man. | Description |
    | all_alarms       | Yes  | The return value of get_active_alarms in ute_admin, it's a list |
    | check_info  | Yes  | info to check the alarm, it should be a list |

    Example
    | check alarm not exist | ${all_alarms} | ["faultId=6203", "severity=Major"] |
    """

    if len(all_alarms) == 0:
        return True

    ret = _check_alarm_exist_or_not(all_alarms, check_info)

    if ret:
        raise Exception("Alarm Exist. Check alarm not exist failed.")

    return True


def get_alarm_time_per_fault_id(all_alarms, fault_id):
    """
    get alarm time per fault id
    | Input Paramaters | Man. | Description |
    | all_alarms       | Yes  | The return value of get_active_alarms in ute_admin |
    | fault_id      | Yes  | The fault id for the alarm which you want to get time from |

    | Return Value | The value of time |
    """
    for each_alarm in all_alarms:
        cur_id = each_alarm['faultId']
        if int(cur_id) == int(fault_id):
            return each_alarm['btsObservationTime']

    return None


if __name__ == "__main__":
    alarm_list = [{'btsObservationTime': '2019010502',
                   'faultId': 49,
                   'faultName': 'Cell blocked'}]
    alarmEST = ["faultId=49"]
    alarmNotEST = ["faultId=99"]
    bts_ping_ok("192.168.255.129", 10)
    print("1.KW bts_ping_ok(\"192.168.255.129\", 10) verify result: pass.")
    bts_reboot("192.168.255.129")
    print("2.KW bts_reboot(\"192.168.255.129\") verify result: pass.")
    bts_ping_nok("192.168.255.129", 10)
    print("3.KW  bts_ping_nok(\"192.168.255.129\", 10) verify result: pass.")
    msg = check_alarm_not_exist(alarm_list, alarmNotEST)
    print("4.KW check_alarm_not_exist(alarm_list,alarmNotEST) verify result: %s." % msg)
    msg = check_alarm_exist(alarm_list, alarmEST)
    print("5.KW check_alarm_exist(alarm_list,alarmEST) verify result: %s." % msg)
    almtime = get_alarm_time_per_fault_id(alarm_list, "49")
    print("6.KW get_alarm_time_per_fault_id(alarm_list,\"49\") verify result: %s." % almtime)
    pass


def _matching_dicts(pattern_dict, source_dict):
    for key, value in pattern_dict.items():
        if isinstance(value, dict):
            _match = _matching_dicts(value, source_dict.get(key, {}))
        elif isinstance(value, list):
            _match = value == source_dict.get(key, [])
        else:
            _match = bool(re.search(str(value), str(source_dict.get(key, ''))))
        logging.debug('Key to check: {}, result: {} ({} vs {})'.format(key, _match, str(value),
                                                                       str(source_dict.get(key, ''))))
        if not _match:
            return False
    return True


def _filter_alarms(alarms_list, filter_patterns, simplified_dictionary=None, use_pattern_once=True):
    matched_alarms = []
    left_patterns = filter_patterns[:]
    left_alarms = alarms_list[:]
    for alarm in alarms_list:
        pretty_alarm = _make_pretty_alarm(alarm, simplified_dictionary) if simplified_dictionary else alarm
        logging.debug('Alarm under test: {}'.format(pretty_alarm))
        for pattern in left_patterns:
            logging.debug('Pattern to match: {}'.format(pattern))
            if _matching_dicts(pattern, alarm):
                logging.debug('Alarm matched pattern')
                matched_alarms.append(alarm)
                left_alarms.remove(alarm)
                if use_pattern_once:
                    left_patterns.remove(pattern)
                break
        else:
            logging.debug('Alarm doesnt match any pattern from: {}'.format(left_patterns))
    return matched_alarms, left_alarms, left_patterns


def _make_pretty_alarm(source_dict, recogn_dict=None):
    new_dict = {}
    for key, value in recogn_dict.items():
        if isinstance(value, dict):
            new_dict[key] = _make_pretty_alarm(source_dict.get(key, {}), value)
        else:
            new_dict[key] = str(source_dict.get(key, ''))
    return new_dict


def get_filtered_alarms(current_alarms, expected_patterns=list(), ignored_patterns=list(), critical_patterns=list(),
                        simplified_dictionary=LTE_SIMPLIFIED_DICT):
    """
        Filter given alarm lists using given patterns

        **Input Parameters**

        +-----------------------+-------+------------------------------------------------------------------------+
        | Parameter Name        | Man.  | Description                                                            |
        +=======================+=======+========================================================================+
        | current_alarms        | No    | list of alarms in dict format                                          |
        +-----------------------+-------+------------------------------------------------------------------------+
        | expected_patterns     | No    | list of expected alarms patterns,                                      |
        |                       |       | it should contain one pattern for each expected alarm                  |
        +-----------------------+-------+------------------------------------------------------------------------+
        | ignored_patterns      | No    | list of ignored alarms patterns, one pattern will be used multiply     |
        +-----------------------+-------+------------------------------------------------------------------------+
        | critical_patterns     | No    | list of critical alarms patterns, one pattern will be used multiply    |
        +-----------------------+-------+------------------------------------------------------------------------+
        | simplified_dictionary | No    | if set, define which keys of alarms should be printed in the report    |
        +-----------------------+-------+------------------------------------------------------------------------+

        **RETURN VALUE**

        - found_expected_alarms (list), missing_alarms_patterns (list),
        critical_alarms (list), ignored_alarms (list), warnings (list)

        """  # noqa
    found_expected_alarms, found_other_alarms, not_found_expected_patterns = _filter_alarms(
        current_alarms,
        expected_patterns,
        simplified_dictionary=simplified_dictionary
    )

    found_ignored_alarms, found_other_alarms, not_found_ignored_patterns = _filter_alarms(
        found_other_alarms,
        ignored_patterns,
        simplified_dictionary=simplified_dictionary,
        use_pattern_once=False
    )
    found_critical_alarms, found_not_classified_alarms, not_found_critical_patterns = _filter_alarms(
        found_other_alarms,
        critical_patterns,
        simplified_dictionary=simplified_dictionary,
        use_pattern_once=False
    )
    return (found_expected_alarms, not_found_expected_patterns,
            found_critical_alarms, found_ignored_alarms, found_not_classified_alarms)


def print_alarms(found_expected_alarms=list(), missing_alarms_patterns=list(), critical_alarms=list(),
                 ignored_alarms=list(), warnings=list(), simplified_dictionary=LTE_SIMPLIFIED_DICT):
    """
        It print given alarms lists to TC report with proper severities

        **Input Parameters**

        +---------------------------+-------+--------------------------------------------------------------------------+
        | Input Parameters          | Man.  | Description                                                              |
        +===========================+=======+==========================================================================+
        | found_expected_alarms     | No    | list of alarms in dict format, log severity: INFO                        |
        +---------------------------+-------+--------------------------------------------------------------------------+
        | missing_alarms_patterns   | No    | list of alarms in dict format, log severity: ERR                         |
        +---------------------------+-------+--------------------------------------------------------------------------+
        | critical_alarms           | No    | list of alarms in dict format, log severity: ERR                         |
        +---------------------------+-------+--------------------------------------------------------------------------+
        | ignored_alarms            | No    | list of alarms in dict format, log severity: INFO                        |
        +---------------------------+-------+--------------------------------------------------------------------------+
        | warnings                  | No    | list of alarms in dict format, log severity: WARN                        |
        +---------------------------+-------+--------------------------------------------------------------------------+
        | simplified_dictionary     | No    | if set, define which keys of alarm dict should be printed in the report  |
        +---------------------------+-------+--------------------------------------------------------------------------+

        **RETURN VALUE**

        - None

        """
    if ignored_alarms:
        ignored_alarms = [_make_pretty_alarm(alarm, simplified_dictionary)
                          for alarm in ignored_alarms if simplified_dictionary] or ignored_alarms

        logging.info("Ignored alarms detected: {}".format(ignored_alarms))

    if found_expected_alarms:
        found_expected_alarms = [_make_pretty_alarm(alarm, simplified_dictionary)
                                 for alarm in found_expected_alarms
                                 if simplified_dictionary] or found_expected_alarms

        logging.info('Expected alarms detected: {}'.format(found_expected_alarms))

    if warnings:
        warnings = [_make_pretty_alarm(alarm, simplified_dictionary)
                    for alarm in warnings
                    if simplified_dictionary] or warnings
        logging.warning("Unexpected non critical alarms detected: {}".format(warnings))

    if missing_alarms_patterns:
        missing_alarms_patterns = [_make_pretty_alarm(alarm, simplified_dictionary)
                                   for alarm in missing_alarms_patterns
                                   if simplified_dictionary] or missing_alarms_patterns

        logging.error('Missing alarms: {}'.format(missing_alarms_patterns))

    if critical_alarms:
        critical_alarms = [_make_pretty_alarm(alarm, simplified_dictionary)
                           for alarm in critical_alarms
                           if simplified_dictionary] or critical_alarms
        logging.error('Critical alarms detected: {}'.format(critical_alarms))
