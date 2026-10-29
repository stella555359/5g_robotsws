"""
:copyright: Nokia Solutions and Networks
:authors:
    Michal Gorski <michal.gorski@nokia.com>
:maintainers:
    Michal Gorski <michal.gorski@nokia.com>
"""

import re

DEFAULT_INTERVAL = 1.0
DEFAULT_INTERVAL_MARGIN = 0.5

TPUT_UNIT_MULTIPLIER = {
    'bits/sec': 1,
    'kbits/sec': 10 ** 3,
    'Mbits/sec': 10 ** 6,
    'Gbits/sec': 10 ** 9
}

"""
VOL_UNIT_MULTIPLIER:
    dictionary which maps volume units to conversion ratios into bits used in iperf;
    defined according to iperf2 documentation: https://iperf.fr/iperf-doc.php, units not consistent with SI system
"""
VOL_UNIT_MULTIPLIER = {
    'Bytes': 8,
    'KBytes': 8 * 2 ** 10,
    'MBytes': 8 * 2 ** 20,
    'GBytes': 8 * 2 ** 30
}


def is_iperf_client_log(iperf_log):
    """
    Checks if provided iperf logfile was crated by iperf client
    :param iperf_log: path to an iperf log file
    :return: True if iperf_log is an iperf client log, False if it is not
    """
    with open(iperf_log, 'r') as file:
        content = file.readlines()
    return "Client connecting" in content[1]


def get_all_data_lines(iperf_log):
    """
    Gets all data lines from iperf log, i.e. all lines containing 'bits/sec' phrase
    :param iperf_log: path to an iperf log file
    :return: list of lines (strings) containing throughput data
    """
    with open(iperf_log, 'r') as file:
        content = file.readlines()
    return [line for line in content if 'bits/sec' in line]


def get_specific_data_lines(iperf_log, condition):
    """
    Gets from iperf_log data lines for which provided condition is met
    :param iperf_log: path to an iperf log file
    :param condition: a function which takes data line as an argument and returns True for desired lines
    :return: list of data lines (strings) which fulfill the condition
    """
    return [line for line in get_all_data_lines(iperf_log) if condition(line)]


def get_fields_from_data_line(line):
    """
    Parses data line into separate data fields
    :param line: data line from iperf log, e.g.:
        '[  3]  2.0- 3.0 sec  15635200 Bytes  125081600 bits/sec   0.099 ms    0/11168 (0%)'
    :return: list of fields containing data values and units, e.g.:
        ['3', '2.0', '3.0', 'sec', '15635200', 'Bytes', '125081600', 'bits/sec', '0.099', 'ms', '0/11168']
    """
    return re.findall(r"\w*\.*/*\w+", line)


def get_duration_from_data_line(line):
    """
    Gets duration for which data in provided data line was reported
    :param line: data line from iperf log
    :return: duration in seconds
    """
    start_time, end_time = list(map(lambda x: float(x), get_fields_from_data_line(line)[1:3]))
    return end_time - start_time


def get_throughput_from_data_line(line, output_unit='bits/sec'):
    """
    Gets throughput from data line and converts it into provided output_unit, into bits/sec by default
    :param line: data line from iperf log
    :param output_unit: throughput unit defined in TPUT_UNIT_MULTIPLIER dictionary
    :return: throughput in provided unit, in bits/sec if output_unit is not provided
    """
    value, unit = get_fields_from_data_line(line)[6:8]
    return float(value) * TPUT_UNIT_MULTIPLIER[unit] / TPUT_UNIT_MULTIPLIER[output_unit]


def get_volume_from_data_line(line):
    """
    Gets volume from data line and converts it into bits using VOL_UNIT_MULTIPLIER dictionary
    :param line: data line from iperf log
    :return: volume in bits
    """
    value, unit = get_fields_from_data_line(line)[4:6]
    return float(value) * VOL_UNIT_MULTIPLIER[unit]


def get_periodic_data_lines(iperf_log, interval=DEFAULT_INTERVAL, margin=DEFAULT_INTERVAL_MARGIN):
    """
    Gets all data lines with data reported periodically by iperf (not summary lines);
    data is considered periodically reported when its duration equal to provided interval within provided margin
    :param iperf_log: path to an iperf log file
    :param interval: interval that will allow to differentiate between periodic and summary lines,
        preferably the interval which was provided in iperf call with -i option
    :param margin: margin for comparing data duration to provided interval,
        used to prevent discarding lines due to small fluctuations in data duration
    :return: list of lines (strings) with periodically reported data
    """
    return get_specific_data_lines(iperf_log, lambda line: abs(get_duration_from_data_line(line) - interval) <= margin)


def get_summary_lines(iperf_log, interval=DEFAULT_INTERVAL, margin=DEFAULT_INTERVAL_MARGIN):
    """
    Gets summary lines reported by iperf, i.e. lines logged at the end of iperf session and containing total time,
    total volume and average throughput; data line is considered a summary line when extracted duration differs from
    provided interval within provided margin
    Notice: iperf client logs contain also server summary lines which can be distinguished by containing e.g. "ms"
    phrase; such lines are filtered out in case of iperf client logs in this function
    :param iperf_log: path to an iperf log file
    :param interval: interval that will allow to differentiate between periodic and summary lines,
        preferably the interval which was provided in iperf call with -i option
    :param margin: margin for comparing extracted duration to provided interval
    :return: list of lines (strings) with periodically reported data
    """
    summary_lines = get_specific_data_lines(iperf_log,
                                            lambda line: abs(get_duration_from_data_line(line) - interval) > margin)
    if is_iperf_client_log(iperf_log):
        return [line for line in summary_lines if "ms" not in line]
    else:
        return summary_lines


def get_max_kbps(iperf_log):
    """
    Gets maximum throughput that was logged in provided iperf log
    :param iperf_log: path to an iperf log file
    :return: integer value of maximum throughput in kbits/sec
    """
    throughputs = []
    for line in get_periodic_data_lines(iperf_log):
        throughputs.append(get_throughput_from_data_line(line, 'kbits/sec'))
    return int(max(throughputs))


def get_total_time(iperf_log):
    """
    Gets total time for all iperf sessions that were logged in provided iperf log
    :param iperf_log: path to an iperf log file
    :return: integer value of total time in milliseconds
    """
    total_time = sum(map(get_duration_from_data_line, get_summary_lines(iperf_log)))
    return int(total_time * 1000)


def get_total_volume_in_kbits(iperf_log):
    """
    Gets total volume for all iperf sessions that were logged in provided iperf log
    :param iperf_log: path to an iperf log file
    :return: integer value of total volume in kbits
    """
    total_volume = sum(map(lambda line: get_volume_from_data_line(line), get_summary_lines(iperf_log)))
    return int(total_volume / 1000)


def get_expected_values(iperf_log):
    """
    Gets total time, total volume and maximum throughput for provided iperf log wrapped as a dictionary
    :param iperf_log: path to an iperf log file
    :return: dictionary containing integer values of total time (ms), total volume (kbit) and maximum throughput (kbps)
    """
    return {
        "total_time": get_total_time(iperf_log),
        "total_volume": get_total_volume_in_kbits(iperf_log),
        "max_throughput": get_max_kbps(iperf_log)
    }
