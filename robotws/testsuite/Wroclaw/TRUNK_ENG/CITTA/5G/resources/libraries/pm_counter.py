import datetime
import time


def get_current_pm_counter_time(round_direction='up'):
    """ Gets PM COUNTER time, which is current UNIX time rounded to full minutes.

    :param round_direction: Indicates how the UNIX time should be rounded, it can be round up, or round down.
    :return: UNIX time rounded to full minutes
    :rtype: int
    """

    if round_direction == 'up':
        return int(time.mktime(datetime.datetime.now().timetuple()) // 60) * 60 + 60
    elif round_direction == 'down':
        return int(time.mktime(datetime.datetime.now().timetuple()) // 60) * 60
    else:
        raise TypeError('Wrong `round_direction` value ({}). It can be only: `up` or `down`.'.format(round_direction))


def list_of_unix_minutes_between_dates(start, stop):
    """ Creates list of UNIX time rounded to full minutes

    :param start: start time of UNIX time rounded to full minutes
    :param stop: stop time of UNIX time rounded to full minutes
    :return: list of UNIX time rounded to full minutes between start and stop inclusive
    :rtype: list
    """

    return [minute for minute in range(int(start), int(stop)+1, 60)]


def get_sum_of_pm_counter_value_based_on_time(data, path, counter_time):
    """ Calculates sum of PM counter values for given minute(s)

    :param data: PM counter (Performance Measurement) values. Output from get_counters_info.
        keyword (ute_admin).
    :param path: Path to PM counter e.g.: BTS/BTS/NRBTS-1/NF1UB/M55323C01009
    :param counter_time: UNIX time rounded to full minutes for which PM counter should be calculated.
    :return: Sum of PM counter values for given minute(s)
    :rtype: int
    """

    for key in path.split('/'):
        data = data[key]
    if not isinstance(counter_time, list):
        counter_time = [counter_time]
    return sum([data[str(time_stamp)] for time_stamp in counter_time if str(time_stamp) in data.keys()])


def get_avg_pm_counter_value(data, path, number_of_measurements):
    """ Calculate average of PM counter's measurements.

    :param dict data: PM counter (Performance Measurement) values. Output from get_counters_info.
        keyword (ute_admin).
    :param str path: Path to PM counter e.g.: BTS/BTS/NRBTS-1/NF1UB/M55323C01009
    :param int number_of_measurements: Number of measurement for which average counter value will be calculated.
    :return: Average of PM counter's measurements.
    :rtype int
    """
    for key in path.split('/'):
        data = data.get(key)
    sorted_measurements = sorted(data.items(), reverse=True)
    extracted_measurements = sorted_measurements[:number_of_measurements]
    values = list(map(lambda i: i[1], extracted_measurements))
    return int(sum(values) / len(values))


def get_sum_pm_counter_value(data, path, number_of_measurements):
    """ Calculate the sum of PM counter's measurements.

    :param dict data: PM counter (Performance Measurement) values. Output from get_counters_info.
        keyword (ute_admin).
    :param str path: Path to PM counter e.g.: BTS/CELLS/NRCELL-1/MCC-311_MNC-489/NRANS/SUCC_INTRA_DU_HO_SA_PLMN
    :param int number_of_measurements: Number of measurement for which average counter value will be calculated.
    :return: Sum of PM counter's measurements.
    :rtype int
    """
    for key in path.split('/'):
        data = data.get(key)

    sorted_measurements = sorted(data.items(), reverse=True)
    extracted_measurements = sorted_measurements[:number_of_measurements]
    values = list(map(lambda i: i[1], extracted_measurements))
    return int(sum(values))
