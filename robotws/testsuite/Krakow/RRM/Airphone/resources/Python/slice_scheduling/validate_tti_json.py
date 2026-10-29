# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Adrianna Pienkowska
:contact: adrianna.pienkowska@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
from testsuite.Krakow.RRM.Airphone.resources.Python.file_management import load_json_file
from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import logger_console
from validate_functions import check_msg_with_values_in_frame


class JSONValidationError(Exception):
    pass


def check_percent_messages_has_given_value(json_file, keys, expected_values, percent=80):
    """
    Examines the TTI Trace JSON file to verify the presence of expected values in events and ensure that a specific
    percentage of these values are accurate.
    :param json_file: type file path, path to TTI Trace JSON file.
    :param keys: type list, keys to traverse TTI Trace dictionary, first element is a name of the event, consecutive
    should be iterable with the path to the value inside event dictionary e.g.
    ['csiSrReportData', ('eventHeader', 'sfn'), ('reportType',)] allows to traverse this event:
    {
    "csiSrReportData": {
        "body": {
            "eventHeader": {
                "sfn":605
            },
            "reportType":"EXPECTED_VALUE",
        }
    }
    when the value should be a list then python's slice function should be used, e.g. ['ulFdSchedData',
    ('longTermCfoMetricOfBeam', slice(1,8,2)] traversing event:
    {
    "ulFdSchedData": {
        "body": {
            "rrmBufferedDataUlLcg_bytes": [1,2,3,4,5,6,7,8,9]
    }}}
    returns [2, 4, 6, 8]
    :param expected_values: type list, list of expected values for given keys, e.g. for above example list
    [605, ["NO_VALUE", "VALUE"]] would try to match values hidden under csiSrReportData->eventHeader->sfn (True) and
    csiSrReportData->reportType (in this case False). Each element of the list matches consecutive iterable from
    keys. How the values are evaluated depends on the type of the element in the list. For numbers and strings,
    the found value is directly compared. For lists, it checks if the value is among its elements, unless the key for
    this particular is a slice, then it expects the list in the expected_values to be equal to the list returned from
    the transversion of the event. For tuples, it verifies if the value falls within the range specified by the first
    and second elements of the tuple. For boolean values, it checks if the value exists. Finally, for callable
    objects, it invokes the function provided as an argument on the given value.
    :param percent: type int, percentage, what proportion of events have correct values.
    :param check_end_values: type tuple,
    :return: None
    """
    json_content = load_json_file(json_file)
    tti_events, errors = __compare_values_in_events_to_expected(json_content, keys[0], keys[1:], expected_values)

    for nr in range(len(errors)):
        received = int((1 - len(errors[nr])/tti_events)*100)
        message_keys = [str(i) for i in keys[nr + 1]]
        event = keys[0] + '->' + '->'.join(message_keys)
        if received < int(percent):
            msg = f'In file {json_file} to many events with wrong value, expected {percent}% but received {received}%'
            msg += f' for message: {event} first error: {str(errors[nr][0])}'
            raise JSONValidationError(msg)
        logger_console(f'Frames with wrong messages {100-received}% for message: {event}')


def check_one_message_has_given_value(json_file, keys, expected_values):
    """
    Examines the TTI Trace JSON file to verify that all events have expected values for messages given in keys.
    :param json_file: type file path, path to TTI Trace JSON file.
    :param keys: type list, keys to traverse TTI Trace dictionary, first element is a name of the event, consecutive
    should be iterable with the path to the value inside event dictionary e.g.
    ['csiSrReportData', ('eventHeader', 'sfn'), ('reportType',)] allows to traverse this event:
    {
    "csiSrReportData": {
        "body": {
            "eventHeader": {
                "sfn":605
            },
            "reportType":"EXPECTED_VALUE",
        }
    }
    when the value should be a list then python's slice function should be used, e.g. ['ulFdSchedData',
    ('longTermCfoMetricOfBeam', slice(1,8,2)] traversing event:
    {
    "ulFdSchedData": {
        "body": {
            "rrmBufferedDataUlLcg_bytes": [1,2,3,4,5,6,7,8,9]
    }}}
    returns [2, 4, 6, 8]
    :param expected_values: type list, list of expected values for given keys, e.g. for above example list
    [605, ["NO_VALUE", "VALUE"]] would try to match values hidden under csiSrReportData->eventHeader->sfn (True) and
    csiSrReportData->reportType (in this case False). Each element of the list matches consecutive iterable from
    keys. How the values are evaluated depends on the type of the element in the list. For numbers and strings,
    the found value is directly compared. For lists, it checks if the value is among its elements, unless the key for
    this particular is a slice, then it expects the list in the expected_values to be equal to the list returned from
    the transversion of the event. For tuples, it verifies if the value falls within the range specified by the first
    and second elements of the tuple. For boolean values, it checks if the value exists. Finally, for callable
    objects, it invokes the function provided as an argument on the given value.
    :return: None
    """
    json_content = load_json_file(json_file)
    tti_events, errors = __compare_values_in_events_to_expected(json_content, keys[0], keys[1:], expected_values)
    for nr in range(len(errors)):
        received = tti_events - len(errors[nr])
        event = keys[0] + '->' + '->'.join(keys[nr + 1])
        if received == 0:
            msg = f'In file {json_file} to no event with correct value, for message: {event} first error:'
            msg += f'{str(errors[nr][0])}'
            raise JSONValidationError(msg)
        logger_console(f'One frame with correct value for event {event} has been found!')


def check_percent_messages_has_given_value_in_consecutive_events(json_file, first_keys, first_expected_values,
                                                                 second_keys, second_expected_values, percent=80,
                                                                 all_next_events=True, check_next_event=True):
    """

    :param json_file: type file path, path to TTI Trace JSON file.
    :param first_keys: type list, keys to traverse TTI Trace dictionary for first expected event, first element is
    a name of the event, consecutive
    should be iterable with the path to the value inside event dictionary e.g.
    ['csiSrReportData', ('eventHeader', 'sfn'), ('reportType',)] allows to traverse this event:
    {
    "csiSrReportData": {
        "body": {
            "eventHeader": {
                "sfn":605
            },
            "reportType":"EXPECTED_VALUE",
        }
    }
    when the value should be a list then python's slice function should be used, e.g. ['ulFdSchedData',
    ('longTermCfoMetricOfBeam', slice(1,8,2)] traversing event:
    {
    "ulFdSchedData": {
        "body": {
            "rrmBufferedDataUlLcg_bytes": [1,2,3,4,5,6,7,8,9]
    }}}
    returns [2, 4, 6, 8]
    :param first_expected_values: type list, list of expected values for first event keys, e.g. for above example list
    [605, ["NO_VALUE", "VALUE"]] would try to match values hidden under csiSrReportData->eventHeader->sfn (True) and
    csiSrReportData->reportType (in this case False). Each element of the list matches consecutive iterable from
    keys. How the values are evaluated depends on the type of the element in the list. For numbers and strings,
    the found value is directly compared. For lists, it checks if the value is among its elements. For tuples,
    it verifies if the value falls within the range specified by the first and second elements of the tuple. For
    boolean values, it checks if the value exists. Finally, for callable objects, it invokes the function provided as
    an argument on the given value.
    :param second_keys:  type list, keys to traverse TTI Trace dictionary for second expected event.
    :param second_expected_values:  type list, list of expected values for second event keys
    :param percent: type int, percentage, what proportion of events have correct values.
    :param all_next_events: boolean, if True expects for all valid first event a consecutive second event,
    default value is True
    :param check_next_event: boolean, if True expects for second event appear right after the first event without any
    event in between, default value is True
    :return: None
    """

    json_content = load_json_file(json_file)
    first = (first_keys, first_expected_values)
    second = (second_keys, second_expected_values)
    tti_events, errors = __compare_values_in_events_to_expected_in_consecutive_events(json_content, first, second,
                                                                                      all_next_events, check_next_event)

    msg = 'Checking consecutive messages: first: '
    just_len = len(msg)
    for nr in range(len(first[0])-1):
        first_event = first[0][0] + '->' + '->'.join(first[0][nr + 1])
        msg = f'{msg}{"" if nr == 0 else " "*just_len}{first_event}\n'
    logger_console(msg[:-1])

    for nr in range(len(errors)):
        received = int((1 - len(errors[nr])/tti_events)*100)
        second_event = second[0][0] + '->' + '->'.join(second[0][nr + 1])
        if received < int(percent):
            msg = f'In file {json_file} to many events with wrong value, expected {percent}% but received {received}%'
            msg += f' for message: {second_event} first error: {str(errors[nr][0])}'
            raise JSONValidationError(msg)
        msg = f'Frames with wrong messages {100-received}% for consecutive message: '
        msg += f'{second_event}'
        logger_console(msg)


def __compare_values_in_events_to_expected_in_consecutive_events(json_dict, first, second, all_next_events,
                                                                 check_next_event):
    tti_even_list = json_dict['events']
    tti_wanted_first_events = 0
    tti_wanted_second_events = 0
    first_errors = [list() for _ in range(len(first[1]))]
    second_errors = [list() for _ in range(len(second[1]))]
    first_event = first[0][0]
    second_event = second[0][0]
    check_second = False
    for item in tti_even_list:
        if check_second:
            if check_next_event:
                tti_wanted_second_events += 1
                __compare_values_when_check_next_event_is_true(item, second, second_errors)
                check_second = False
                continue
            if second_event in item:
                tti_wanted_second_events += 1
                tuple_keys = second[0][1:]
                __compare_values_in_tuple_keys_to_expected(item[second_event]['body'], tuple_keys, second[1],
                                                           second_errors)
                check_second = False
                continue
        elif first_event in item:
            tuple_keys = first[0][1:]
            error = __compare_values_in_tuple_keys_to_expected(item[first_event]['body'], tuple_keys, first[1],
                                                               first_errors)
            if error is None:
                check_second = True
                tti_wanted_first_events += 1
    if tti_wanted_first_events == 0:
        raise JSONValidationError(f'No event {first_event}')
    if all_next_events and tti_wanted_first_events != tti_wanted_second_events:
        raise JSONValidationError(f'Number of {first_event} isn\'t equal to the number of {second_event}')
    return tti_wanted_second_events, second_errors


def __compare_values_when_check_next_event_is_true(item, second, second_errors):
    second_event = second[0][0]
    tuple_keys = second[0][1:]
    try:
        __compare_values_in_tuple_keys_to_expected(item[second_event]['body'], tuple_keys, second[1],
                                                   second_errors)
    except KeyError:
        msg = (f'Next event isn\'t {second_event}. If you don\'t want the events being one just after '
               f'another change check_next_event to False.')
        error = JSONValidationError(msg)
        for nr in range(len(tuple_keys)):
            second_errors[nr].append(error)


def __compare_values_in_events_to_expected(json_dict, event, tuple_keys, expected_values):
    tti_even_list = json_dict['events']
    tti_wanted_events = 0
    errors = [list() for _ in range(len(tuple_keys))]
    for item in tti_even_list:
        if event in item:
            tti_wanted_events += 1
            __compare_values_in_tuple_keys_to_expected(item[event]['body'], tuple_keys, expected_values, errors)
    if tti_wanted_events:
        return tti_wanted_events, errors
    else:
        raise JSONValidationError(f'No event {event}')


def __compare_values_in_tuple_keys_to_expected(tti_event, tuple_keys, expected_values, errors):
    for nr, key_tuple in enumerate(tuple_keys):
        temp = tti_event
        for key in key_tuple:
            temp = temp[key]
        error = check_msg_with_values_in_frame(temp, expected_values[nr])
        if error:
            errors[nr].append(error)
            return error
