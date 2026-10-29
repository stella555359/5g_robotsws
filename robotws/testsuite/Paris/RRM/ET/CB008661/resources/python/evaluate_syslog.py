import operator
import os
import re
import sys
from collections import OrderedDict
from datetime import datetime


def read_exclusion_file(exclusion_file_name, exclusion_list):
    with open(exclusion_file_name, "r") as exclusion_file:
        file_content = exclusion_file.readlines()
        exclusion_file.close()
        for line in file_content:
            if not line.startswith("#"):
                if line.startswith("include"):
                    current_path = os.path.dirname(exclusion_file_name)
                    included_file_name = line.split("include")[1].strip()
                    read_exclusion_file(current_path + "/" + included_file_name, exclusion_list)
                else:
                    exclusion_pattern = line.split(";", 1)[1].strip()
                    if exclusion_pattern not in exclusion_list:
                        exclusion_list[exclusion_pattern] = 0


def is_pattern_excluded(line, exclusion_list):
    pattern_excluded = False
    for pattern in exclusion_list:
        if pattern in line:
            pattern_excluded = True
            exclusion_list[pattern] += 1
            break
    return pattern_excluded


def get_timestamps(line, min_input, max_input):
    min_result = min_input
    max_result = max_input
    if '<' in line and '>' in line:
        time_string = line.split('<')[1].split('>')[0]
        try:
            datetime_object = datetime.strptime(time_string, "%Y-%m-%dT%H:%M:%S.%fZ")
            datetime_seconds = datetime_object.timestamp()
            min_result = min(datetime_seconds, min_input)
            max_result = max(datetime_seconds, max_result)
        except ValueError:
            pass
    return min_result, max_result


def update_trace_distribution(trace_distribution, line):
    clean_line1 = re.sub("0[xX][0-9a-fA-F]+", "hex*", line[42:])
    clean_line2 = re.sub("[0-9]+", "*", clean_line1)
    if clean_line2 not in trace_distribution:
        trace_distribution[clean_line2] = 0
    trace_distribution[clean_line2] += 1


def analyse_syslog(syslog_file_name, exclusion_list, max_syslog_rate):
    error_list = []
    trace_distribution = {}
    number_of_lines = 0
    syslog_file = open(syslog_file_name, "r", encoding="iso-8859-1")
    min_timestamp, max_timestamp = 1000000000000000000000, 0
    line = syslog_file.readline().strip()
    while line:
        number_of_lines += 1
        min_timestamp, max_timestamp = get_timestamps(line, min_timestamp, max_timestamp)
        update_trace_distribution(trace_distribution, line)
        if ("ERR" in line) or ("WRN" in line):
            if not is_pattern_excluded(line, exclusion_list):
                error_list.append(line)
                if len(error_list) >= 10:
                    print("exclusion_list", exclusion_list)
                    break
        try:
            line = syslog_file.readline().strip()
        except UnicodeDecodeError:
            line = "UnicodeDecodeError"
            print("****************************************************************** UnicodeDecodeError")
    syslog_file.close()
    syslog_duration = max_timestamp - min_timestamp
    syslog_rate = int(number_of_lines / syslog_duration)
    print(f"syslog_rate {syslog_rate} traces/sec, syslog_duration {syslog_duration} sec")
    if syslog_rate > max_syslog_rate:
        error_list.append(f"Too high syslog_rate {syslog_rate} traces/sec")
    write_statistics(syslog_file_name, exclusion_list, error_list, syslog_rate, max_syslog_rate, trace_distribution)
    return error_list


def write_statistics(syslog_file_name, exclusion_list, error_list, syslog_rate, max_syslog_rate, trace_distribution):
    timestamp = datetime.now().strftime("%Y%m%d_%Hh%M")
    statistics_file_name = syslog_file_name.replace(".log", f"_{timestamp}_Stats.log")
    print(f"Writing statistic file {statistics_file_name}")
    with open(statistics_file_name, "w") as statistics_file:
        statistics_file.write("Number of occurrences per exclusion pattern:\n")
        for pattern in exclusion_list:
            if exclusion_list[pattern] != 0:
                statistics_file.write(f"{exclusion_list[pattern]}; {pattern}\n")
        statistics_file.write("End\n")
        statistics_file.write("Error list:\n")
        for error in error_list:
            statistics_file.write(f"{error}\n")
        statistics_file.write("End\n")
        statistics_file.write(f"syslog_rate: {syslog_rate} traces/sec\n")
        if syslog_rate > max_syslog_rate:
            statistics_file.write("Trace distribution:\n")
            for trace, occurrence in sorted(trace_distribution.items(), key=operator.itemgetter(1), reverse=True):
                statistics_file.write(f"{occurrence}: {trace}\n")
            statistics_file.write("End\n")
        statistics_file.close()


def evaluate_syslog(syslog_file_name, exclusion_file_name, max_syslog_rate):
    exclusion_list = {}
    read_exclusion_file(exclusion_file_name, exclusion_list)
    error_list = analyse_syslog(syslog_file_name, exclusion_list, int(max_syslog_rate))
    return error_list


if __name__ == '__main__':
    evaluate_syslog(sys.argv[1], sys.argv[2], sys.argv[3])
