from taf.analyzer.ims2 import Ims2ChangesetLogEntry, Ims2LogReader

from datetime import datetime
from dateutil import parser
from dateutil.parser import ParserError
import copy

import logging

logging.basicConfig(level=logging.INFO)


def _return_alarm_updates_in_interval(file_path, begin=None, end=None):
    """
    Helper function that returns a list of alarm updates for a specified object within a specified time interval.

    :param file_path: The path to the IMS2 trace file.
    :param begin: The start time of the interval in UTC format. If not provided, it defaults to None.
    :param end: The end time of the interval in UTC format. If not provided, it defaults to None.
    :return: A list of dictionaries, each representing an alarm update within the interval.
    """

    return _return_alarm_updates_in_interval_with_clear(file_path=file_path, obj_dist_name="ALARM-",
                                                        begin=begin, end=end)


def _return_alarm_updates_in_interval_with_clear(file_path, obj_dist_name, begin=None, end=None):
    """
    Helper function that returns a list of alarm updates for a specified object within a specified time interval.

    :param file_path: The path to the IMS2 trace file.
    :param obj_dist_name: The distributed name of the object to be checked.
    :param begin: The start time of the interval. If not provided, it defaults to None.
    :param end: The end time of the interval. If not provided, it defaults to None.
    :return: A list of dictionaries, each representing an alarm update within the interval.
    """
    object_list = []
    frame_counter = 0
    for log_entry in Ims2LogReader.from_file(file_path=file_path):
        if isinstance(log_entry, Ims2ChangesetLogEntry):
            for dist_name, value in log_entry.updates.items():
                if (obj_dist_name in dist_name and
                        (begin is None or _get_timestamp_in_datetime_format(begin).timestamp()
                         < log_entry.timestamp.timestamp())
                        and (end is None or log_entry.timestamp.timestamp()
                             < _get_timestamp_in_datetime_format(end).timestamp())):
                    value['log_entry_timestamp'] = log_entry.timestamp.timestamp()
                    value['log_entry_dist_name'] = dist_name
                    value['cleared'] = _return_alarm_removes_in_interval(file_path, dist_name,
                                                                         log_entry.timestamp.timestamp(), end)
                    logging.debug(f"Matched dist_name: {dist_name}")
                    logging.debug(f"IMS frame number - date: [{frame_counter}] - "
                                  f"[{datetime.utcfromtimestamp(log_entry.timestamp.timestamp())}]")
                    logging.debug(f"Alarm content: {value}")
                    logging.debug(f"Cleared: {value['cleared']}")
                    object_list.append(value)
        frame_counter += 1
    return object_list


def _return_alarm_removes_in_interval(file_path, obj_dist_name, begin=None, end=None):
    """
    Helper function that returns a list of alarm removes for a specified object within a specified time interval.

    :param file_path: The path to the IMS2 trace file.
    :param obj_dist_name: The distributed name of the object to be checked.
    :param begin: The start time of the interval. If not provided, it defaults to None.
    :param end: The end time of the interval. If not provided, it defaults to None.
    :return: A list of dictionaries, each representing an alarm update within the interval.
    """
    for log_entry in Ims2LogReader.from_file(file_path=file_path):
        if isinstance(log_entry, Ims2ChangesetLogEntry):
            if obj_dist_name in log_entry.removals and (
                    begin is None or _get_timestamp_in_datetime_format(begin).timestamp()
                    < log_entry.timestamp.timestamp()) \
                    and (end is None or log_entry.timestamp.timestamp()
                         < _get_timestamp_in_datetime_format(end).timestamp()):
                return True
    return False


def _return_object_updates_in_interval(file_path, obj_dist_name, begin=None, end=None, obj_exact_match=False):
    """
    Helper function that returns a list of object updates for a specified object within a specified time interval.

    :param file_path: The path to the IMS2 trace file.
    :param obj_dist_name: The distributed name of the object to be checked.
    :param begin: The start time of the interval in UTC format. If not provided, it defaults to None.
    :param end: The end time of the interval in UTC format. If not provided, it defaults to None.
    :return: A list of dictionaries, each representing an object update within the interval.
    """
    object_list = []
    frame_counter = 0
    for log_entry in Ims2LogReader.from_file(file_path=file_path):
        if isinstance(log_entry, Ims2ChangesetLogEntry):
            for dist_name, value in log_entry.updates.items():
                if (_get_obj_dist_name_match(obj_dist_name, dist_name, obj_exact_match)
                        and (begin is None or _get_timestamp_in_datetime_format(begin).timestamp()
                             < log_entry.timestamp.timestamp())
                        and (end is None or log_entry.timestamp.timestamp()
                             < _get_timestamp_in_datetime_format(end).timestamp())):
                    value['log_entry_timestamp'] = log_entry.timestamp.timestamp()
                    value['log_entry_dist_name'] = dist_name
                    logging.debug(f"Matched dist_name: {dist_name}")
                    logging.debug(f"IMS frame number - date: [{frame_counter}] - "
                                  f"[{datetime.utcfromtimestamp(log_entry.timestamp.timestamp())}]")
                    logging.debug(f"Distname value: {value['log_entry_dist_name']}")
                    object_list.append(value)
        frame_counter += 1
    return object_list


def _get_obj_dist_name_match(obj_dist_name, dist_name, obj_exact_match=False):
    if obj_exact_match and obj_dist_name == dist_name:
        return True
    if (not obj_exact_match) and (obj_dist_name in dist_name):
        return True
    return False


def _check_parameter_change(object_updates, parameter_name):
    """
    Helper function to check if the status of an object has changed.

    :param object_updates: A list of dictionaries, each representing an object update.
    :param parameter_name: The status attribute that will be checked for change.
    :return: A boolean value indicating whether the status of the object has changed.
    """
    parameter_set = set()
    for value in object_updates:
        if parameter_name in value:
            parameter_set.add(value[parameter_name])
            if len(parameter_set) > 1:
                logging.info(f"Timestamp: {value.get('log_entry_timestamp', None)}")
                break
    return len(parameter_set) > 1


def _create_alarm_dict(alarm, rfs_format=True):
    """
    Helper function to create a dictionary representation of an alarm.

    :param alarm: A dictionary representing an alarm.
    :param rfs_format: A boolean value whether the alarm is in RFS format. If not provided, it defaults to True.
    :return: A dictionary with specific keys from the alarm dictionary.
    """

    affected_resources_dn = [resource['reportingResourceDN'] for resource in alarm.get('affectedResources', [])]
    logging.info(f"alarm: {str(alarm)}")
    sn_attribute = next((resource['attributeValue'] for resource in alarm.get('alarmAttribute', [])
                         if resource['attributeName'] == 'serial_no'), None)

    if rfs_format:
        alarm = {
            "alarmId": str(alarm["alarmNumber"]),
            "faultId": str(alarm["faultId"]),
            "alarmName": alarm["alarmName"],
            "object_id": alarm["alarmingResourceDN"],
            "observationTime": alarm["observationTime"],
            "alarm_dist_name": alarm["log_entry_dist_name"],
            "visibleForEM": alarm["visibleForEM"],
            "visibleForNetAct": alarm["visibleForNetAct"],
            "visibleForOnap": alarm["visibleForOnap"],
            "cleared": alarm.get("cleared", None),
            "affected_resources_dn": affected_resources_dn,
            "sn_attribute": sn_attribute,
            "supplAlarmInfo": alarm["alarmText"]["alarmAdditionalInfo"].get("supplAlarmInfo", None)
        }
    else:
        alarm = {
            "alarmNumber": alarm["alarmNumber"],
            "faultId": alarm["faultId"],
            "alarmName": alarm["alarmName"],
            "object_id": alarm["alarmingResourceDN"],
            "observationTime": alarm["observationTime"],
            "visibleForEM": alarm["visibleForEM"],
            "visibleForNetAct": alarm["visibleForNetAct"],
            "visibleForOnap": alarm["visibleForOnap"],
            "cleared": alarm.get("cleared", None),
            "affected_resources_dn": affected_resources_dn,
            "sn_attribute": sn_attribute,
            "supplAlarmInfo": alarm["alarmText"]["alarmAdditionalInfo"].get("supplAlarmInfo", None)
        }
    return alarm


def _intersect_alarms_dicts_keys(list1, list2, keys):
    """
    Helper function to find the intersection of two lists of dictionaries based on specific keys.

    :param list1: The first list of dictionaries.
    :param list2: The second list of dictionaries.
    :param keys: The keys to be considered for intersection.
    :return: A list of dictionaries from the first list that also exist in the second list based on the specified keys.
    """
    dict1 = {tuple(d[k] for k in keys if k in d): d for d in list1}
    dict2 = {tuple(d[k] for k in keys if k in d): d for d in list2}

    intersection_keys = set(dict1.keys()) & set(dict2.keys())

    result = [dict1[key] for key in intersection_keys]

    return result


def _get_timestamp_in_datetime_format(timestamp):
    if not isinstance(timestamp, datetime):
        timestamp = str(timestamp)
        if ':' not in timestamp:
            parsed_timestamp = datetime.fromtimestamp(float(timestamp))
        else:
            try:
                timestamp_with_z_postfix = "{}Z".format(timestamp)
                parsed_timestamp = parser.parse(timestamp_with_z_postfix)
            except ParserError:
                parsed_timestamp = parser.parse(timestamp)
    else:
        parsed_timestamp = timestamp

    return parsed_timestamp


def _translate_alarms(alarms):
    alarms = copy.deepcopy(alarms)
    translated_alarms = []
    for alarm in alarms:
        if 'alarmId' in alarm.keys():
            alarm['alarmNumber'] = alarm.pop('alarmId')
        alarm['alarmNumber'] = int(alarm['alarmNumber'])
        alarm['faultId'] = int(alarm['faultId'])
        translated_alarms.append(alarm)
    return translated_alarms


def get_object_updates_in_interval(file_path, obj_dist_name, begin=None, end=None, obj_exact_match=False):
    """
    Function that returns a list of object updates for a specified object within a specified time interval.

    :param file_path: The path to the IMS2 trace file.
    :param obj_dist_name: The distributed name of the object to be checked.
    :param begin: The start time of the interval. If not provided, it defaults to None.
    :param end: The end time of the interval. If not provided, it defaults to None.
    :param obj_exact_match: To check for exact match of obj_dist_name or part. If not provided, it defaults to False.
    :return: A list of dictionaries, each representing an object update within the interval.
    """

    return _return_object_updates_in_interval(
        file_path=file_path,
        obj_dist_name=obj_dist_name,
        begin=begin, end=end,
        obj_exact_match=obj_exact_match)


def get_object_status_changes(file_path, obj_dist_name, parameter_name, begin=None, end=None, obj_exact_match=False):
    """
    This function checks if the status of a specified object has changed within a specified time interval and returns
    a list of dictionaries containing all changes of the parameter_name and the timestamp of occurrence.

    :param file_path: The path to the IMS2 trace file.
    :param obj_dist_name: The distributed name of the object to be checked.
    :param parameter_name: The attribute that will be checked for change.
    :param begin: The start time of the interval. If not provided, it defaults to None.
    :param end: The end time of the interval. If not provided, it defaults to None.
    :param obj_exact_match: To check for exact match of obj_dist_name or part. If not provided, it defaults to False.
    :return: A list of dictionaries containing all changes of the parameter_name and the timestamp of occurrence.
    """
    object_updates = _return_object_updates_in_interval(file_path, obj_dist_name, begin, end,
                                                        obj_exact_match=obj_exact_match)
    changes = []
    previous_value = None
    for value in object_updates:
        if parameter_name in value and (previous_value is None or value[parameter_name] != previous_value):
            changes.append({
                "timestamp": value.get('log_entry_timestamp', None),
                "value": value[parameter_name],
                "value_initial": previous_value
            })
            previous_value = value[parameter_name]
    return changes


def check_object_status_change(file_path, obj_dist_name, parameter_name, begin=None, end=None, obj_exact_match=False):
    """
    This function checks if the status of a specified object has changed within a specified time interval.

    :param file_path: The path to the IMS2 trace file.
    :param obj_dist_name: The distributed name of the object to be checked.
    :param parameter_name: The attribute that will be checked for change.
    :param begin: The start time of the interval. If not provided, it defaults to None.
    :param end: The end time of the interval. If not provided, it defaults to None.
    :param obj_exact_match: To check for exact match of obj_dist_name or part. If not provided, it defaults to False.
    :return: A boolean value indicating whether the status of the specified object has changed within time interval.
    """
    object_updates = _return_object_updates_in_interval(file_path, obj_dist_name, begin, end,
                                                        obj_exact_match=obj_exact_match)
    return _check_parameter_change(object_updates, parameter_name)


def check_object_status_change_to_desired_value(file_path, obj_dist_name, parameter_name, parameter_value, begin=None,
                                                end=None, obj_exact_match=False):
    """
    This function checks if the status of a specified object has changed to a specified value within
    a specified time interval.

    :param file_path: The path to the IMS2 trace file.
    :param obj_dist_name: The distributed name of the object to be checked.
    :param parameter_name: The attribute that will be checked for change.
    :param parameter_value: The desired value to be checked against the found attribute change.
    :param begin: The start time of the interval. If not provided, it defaults to None.
    :param end: The end time of the interval. If not provided, it defaults to None.
    :param obj_exact_match: To check for exact match of obj_dist_name or part. If not provided, it defaults to False.
    :return: A boolean value indicating whether the status of the specified object has changed to the desired value
    within the specified time interval.
    """
    object_updates = _return_object_updates_in_interval(file_path, obj_dist_name, begin, end,
                                                        obj_exact_match=obj_exact_match)
    for value in object_updates:
        if parameter_name in value and value[parameter_name] == parameter_value:
            return True
    return False


def check_object_status_change_provided_value(file_path, obj_dist_name, parameter_name, status_change, begin=None,
                                              end=None, obj_exact_match=False):
    """
    This function checks if the status of a specified object has changed to a specified value within
    a specified interval.

    :param file_path: The path to the IMS2 trace file.
    :param obj_dist_name: The distributed name of the object to be checked.
    :param parameter_name: The attribute that will be checked for change.
    :param status_change: The value to be checked against the found status change.
    :param begin: The start time of the interval. If not provided, it defaults to None.
    :param end: The end time of the interval. If not provided, it defaults to None.
    :param obj_exact_match: To check for exact match of obj_dist_name or part. If not provided, it defaults to False.
    :return: A boolean value indicating whether the status of the specified object has changed to the specified value
     within the specified time interval.
    """
    object_updates = _return_object_updates_in_interval(file_path, obj_dist_name, begin, end,
                                                        obj_exact_match=obj_exact_match)
    status_changed = _check_parameter_change(object_updates, parameter_name)
    return status_changed and any(value[parameter_name] != status_change for value in object_updates if
                                  parameter_name in value)


def get_alarms_in_interval(file_path, begin=None, end=None, rfs_format=True):
    """
    This function checks for alarms that occurred within a specified time interval.

    :param file_path: The path to the IMS2 trace file.
    :param begin: The start time of the interval in UTC format. If not provided, it defaults to None.
    :param end: The end time of the interval in UTC format. If not provided, it defaults to None.
    :param rfs_format: A boolean value whether the alarm is in RFS format. If not provided, it defaults to True.
    :return: A list of alarm dictionaries that occurred within the specified time interval.
    """
    interval_object_updates = _return_alarm_updates_in_interval(file_path=file_path, begin=begin, end=end)
    return [_create_alarm_dict(alarm, rfs_format=rfs_format) for alarm in interval_object_updates]


def get_alarms_not_cleared_in_interval(file_path, begin=None, end=None):
    """
    This function checks for alarms that occurred within a specified time interval and were not cleared.

    :param file_path: The path to the IMS2 trace file.
    :param begin: The start time of the interval. If not provided, it defaults to None.
    :param end: The end time of the interval. If not provided, it defaults to None.
    :return: A list of alarm dictionaries that occurred within the specified time interval and were not cleared.
    """
    interval_object_updates = _return_alarm_updates_in_interval_with_clear(file_path, "ALARM-", begin, end)
    logging.info(f"interval_object_updates: {str(interval_object_updates)}")
    uncleared_alarms = [alarm for alarm in interval_object_updates if not alarm.get('cleared', False)]
    logging.info(f"uncleared_alarms: {str(uncleared_alarms)}")
    return [_create_alarm_dict(alarm) for alarm in uncleared_alarms]


def get_expected_alarms(file_path, alarms, begin=None, end=None, rfs_format=True):
    """
    This function checks for alarms that occurred within a specified time interval and were not cleared.

    :param file_path: The path to the IMS2 trace file.
    :param alarms: List of alarms to search in IMS file
    :param begin: The start time of the interval in UTC format. If not provided, it defaults to None.
    :param end: The end time of the interval in UTC format. If not provided, it defaults to None.
    :param rfs_format: A boolean value whether the alarm is in RFS format. If not provided, it defaults to True.
    :return: A list of alarm dictionaries if all expected alarms were found in IMS or None if alarms were not found
    """

    found_alarms = []
    not_found_alarms = []

    logging.info(f"Search for expected alarms in ims: {alarms}")
    if not rfs_format:
        alarms = _translate_alarms(alarms)
    logging.info(f"Translated expected alarms format: {alarms}")
    all_detected_alarms = get_alarms_in_interval(file_path=file_path, begin=begin, end=end, rfs_format=rfs_format)
    logging.info(f"All detected alarms from ims: {all_detected_alarms}")
    for alarm in alarms:
        alarm_set = False
        for detected_alarm in all_detected_alarms:
            result = _intersect_alarms_dicts_keys([alarm], [detected_alarm], alarm.keys())
            if result:
                found_alarms.append(detected_alarm)
                alarm_set = True
        if not alarm_set:
            not_found_alarms.append(alarm)
    return found_alarms, not_found_alarms


def verify_expected_alarms(file_path, alarms, begin=None, end=None, rfs_format=True):
    """
    This function checks that expected alarms occurred within a specified time interval.
    Keyword fails if expected alarms were not fond.

    :param file_path: The path to the IMS2 trace file.
    :param alarms: List of alarms to search in IMS file
    :param begin: The start time of the interval in UTC format. If not provided, it defaults to None.
    :param end: The end time of the interval in UTC format. If not provided, it defaults to None.
    :param rfs_format: A boolean value whether the alarm is in RFS format. If not provided, it defaults to True.
    :return: A list of fund expected alarm dictionaries if all expected alarms were found in IMS
    """
    found_alarms, not_found_alarms = get_expected_alarms(file_path=file_path, alarms=alarms,
                                                         begin=begin, end=end, rfs_format=rfs_format)
    logging.info(f"Found expected alarms in ims: {found_alarms}")
    logging.info(f"Not found expected alarms in ims: {not_found_alarms}")
    if not_found_alarms:
        raise AssertionError(f"Alarms {not_found_alarms} were not found passed timeframe")
    return found_alarms
