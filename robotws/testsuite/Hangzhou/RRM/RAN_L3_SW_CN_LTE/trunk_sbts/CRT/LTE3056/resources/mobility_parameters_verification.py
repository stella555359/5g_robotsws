from .MobilityParameters import MobilityParameters, _convert_binary_string_to_int
from ta_messaging import message_flows as flow
from datetime import datetime
from pytz import timezone as target_timezone
import time

SECONDS_FROM_1900_TO_1970 = 2208988800


def convert_twos_bitstring6_to_int(bit_str, twos_conversion_to_int):
    if bit_str is not None:
        bit_str = str(bit_str)
        if twos_conversion_to_int:
            if bit_str[0] == '1':
                bit_str = list(bit_str)
                helper = _convert_binary_string_to_int(''.join(bit_str[1:]))
                helper = 0 - 64 + helper
                return helper
        return _convert_binary_string_to_int(bit_str)
    return None


def verify_if_mobility_parameters_field_is_set_to(flow_alias,
                                                  message_alias,
                                                  ie_name,
                                                  expected_ie_value,
                                                  twos_conversion_to_int=False):
    message = flow.get_flow(flow_alias).get_message(message_alias)
    mobility_parameters_hex = message.get_value_by_unique_key("mobilityParameters")
    mobility_parameters = MobilityParameters(mobility_parameters_hex[2:])
    message_ie_value = convert_twos_bitstring6_to_int(mobility_parameters.get_ie_value(ie_name, False),
                                                      twos_conversion_to_int)
    mobility_parameters.print_mobility_parameters_struct()
    assert str(expected_ie_value) == str(message_ie_value), \
        "%s value is not equal to expected, msg:%s != exp:%s" % (ie_name, message_ie_value, expected_ie_value)


def get_daylt_expected_value(timezone):
    current_date = datetime.now()
    dst = str(target_timezone(timezone).dst(current_date, is_dst=None))
    hours = int(dst[0:1])
    return hours


def get_daylt_expected_value_binary(timezone):
    current_date = datetime.now()
    dst = str(target_timezone(timezone).dst(current_date, is_dst=None))
    hours = int(dst[0:1])
    return '0b0%s' % hours


def get_daylt_expected_value_15min_resolution(timezone):
    current_date = datetime.now()
    dst = str(target_timezone(timezone).dst(current_date, is_dst=None))
    hours = int(dst[0:1])
    return 4 * hours


def verify_ltmoff_value_in_message(flow_alias,
                                   message_alias,
                                   timezone):
    message = flow.get_flow(flow_alias).get_message(message_alias)
    ltmoff_from_message = message.get_value_by_unique_key("localTimeOffset-r11")
    ltmoff_expected = get_correct_value_of_localtimeoffset_including_dst_for_timezone_in_15_min_resoultion(timezone)
    assert ltmoff_from_message == ltmoff_expected, \
        "Expected localTimeOffset-r11 is %s, but value in message is different %s" % (ltmoff_expected,
                                                                                      ltmoff_from_message)


def get_correct_value_of_localtimeoffset_including_dst_for_timezone_in_15_min_resoultion(timezone):
    return get_correct_value_of_localtimeoffset_including_dst_for_timezone_in_hours(timezone) * 4


def get_correct_value_of_localtimeoffset_including_dst_for_timezone_in_30_min_resoultion(timezone):
    return get_correct_value_of_localtimeoffset_including_dst_for_timezone_in_hours(timezone) * 2


def get_correct_value_of_localtimeoffset_including_dst_for_timezone_in_hours(timezone):
    timezone = target_timezone(timezone)
    current_date = datetime.now(timezone)
    utc_offset = current_date.utcoffset().total_seconds()
    print("timezone={}, current_date={}, utc_offset={}".format(timezone, current_date, utc_offset))
    return int(utc_offset / 3600)


def get_time_from_linux():
    epoch_time = int(time.time())
    calculated_timestamp = SECONDS_FROM_1900_TO_1970 + epoch_time
    print("Current UTC time from linux:")
    print(calculate_time_from_timestamp(epoch_time))
    return calculated_timestamp


def verify_if_utc_timestamp_is_correct(sib_timestamp, linux_timestamp, offset):
    print("Current UTC time from msg timestamp:")
    print(calculate_time_from_timestamp(int(sib_timestamp / 100) - SECONDS_FROM_1900_TO_1970))
    assert (linux_timestamp - int(offset)) < int(sib_timestamp / 100) < (linux_timestamp + int(offset)), \
        "%s is not in range <%s,%s>" % (int(sib_timestamp / 100), (linux_timestamp - int(offset)),
                                        (linux_timestamp + int(offset)))


def calculate_time_from_timestamp(utc_timestamp):
    return datetime.fromtimestamp(utc_timestamp)


def get_timeInfoUtc_value_from_message(flow_alias, message_alias):
    message = flow.get_flow(flow_alias).get_message(message_alias)
    return message.get_value_by_unique_key('timeInfoUTC-r11')


def verify_periodicity_and_repetition(flow_alias, message_alias, periodicity, repetition):
    periodicity = float(periodicity[:-2])
    repetition = int(repetition)
    print(periodicity)
    print(repetition)
    utc_times_list = []
    occurrence_times_list = []

    for index in range(1, 11):
        utc_time = get_timeInfoUtc_value_from_message(flow_alias, message_alias + str(index))
        utc_times_list.append(utc_time)
        occurence_time = get_occurence_time_of_message(flow_alias, message_alias + str(index))
        occurrence_times_list.append(occurence_time)

    print("Verify Periodicity and Repetition based on UTC time from message")
    check_if_list_contains_times_with_specific_periodicity_and_repetition(utc_times_list, periodicity / 10,
                                                                          repetition, 1)
    print("Verify Periodicity and Repetition based on occurence time of message")
    check_if_list_contains_times_with_specific_periodicity_and_repetition(occurrence_times_list, periodicity / 1000,
                                                                          repetition, 0.01)


def get_occurence_time_of_message(flow_alias, message_alias):
    message = flow.get_flow(flow_alias).get_message(message_alias)
    return float(message.occurrence_time)


def check_if_list_contains_times_with_specific_periodicity_and_repetition(times_list, periodicity, repetition,
                                                                          tolerance_periodicity):
    periods_list = get_periods_list(times_list)
    calculated_period = get_mean_period_from_periods_list(periods_list)
    print("calculated period : %s" % calculated_period)
    calculated_repetition = get_repetition_from_periods_list(periods_list)
    print("calculated repetition : %s" % calculated_repetition)

    assert (periodicity - tolerance_periodicity) < calculated_period < (periodicity + tolerance_periodicity), \
        "Calculated periodicity:%s doesnt match %s with tolerance %s" % (calculated_period, periodicity,
                                                                         tolerance_periodicity)
    assert calculated_repetition == repetition, \
        "Calculated repetition:%s doesnt match expected:%s" % (calculated_repetition, repetition)
    return True


def get_periods_list(times_list):
    last_time = 0.00
    periods_list = []
    for each_time in times_list:
        if last_time != 0:
            assert each_time >= last_time, "provided times are wrong!"
            periods_list.append(each_time - last_time)
        last_time = each_time
    print("Periods list %s" % periods_list)
    return periods_list


def get_mean_period_from_periods_list(periods_list):
    new_periods_list = clean_period_list_from_periods_less_than_preset_lvl(periods_list)
    sum_of_periods = 0
    if new_periods_list:
        for each_period in new_periods_list:
            sum_of_periods += each_period
        mean_period = sum_of_periods / len(new_periods_list)
        return mean_period
    else:
        return 0


def get_repetition_from_periods_list(periods_list, tolerance=0.02):
    if periods_list == []:
        return 0
    repetition_counter = 1
    repetitions_list = []
    for period_index, each_period in enumerate(periods_list):
        is_it_last_period = period_index == (len(periods_list) - 1)
        if each_period <= tolerance:
            repetition_counter += 1
            if is_it_last_period:
                repetitions_list.append(repetition_counter)
        else:
            repetitions_list.append(repetition_counter)
            repetition_counter = 1
    return max(repetitions_list)


def clean_period_list_from_periods_less_than_preset_lvl(periods, lvl=0.1):
    new_periods_list = []
    for period_index, each_period in enumerate(periods):
        if each_period > lvl:
            new_periods_list.append(periods[period_index])
    return new_periods_list
