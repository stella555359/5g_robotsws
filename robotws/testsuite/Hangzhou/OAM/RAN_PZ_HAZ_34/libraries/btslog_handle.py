from dateutil import parser, rrule
import re


def get_specific_str_timestamp(file_input, filter_str):
    time_str_list = []
    with open(file_input, encoding='ISO-8859-1') as fp:
        output = fp.readlines()
        for line in output:
            if line.count(filter_str) > 0:
                time_str = re.findall(
                    r"\d{4}-\d{1,2}-\d{1,2}\S+\d{1,2}:\d{1,2}:\d{1,2}\S+Z", line
                )
                time_str_list.append(time_str[0])
    if time_str_list:
        print(time_str_list)
        return time_str_list
    else:
        raise Exception("filter_str: %s not found!" % filter_str)


def calc_time_interval(time_stamp1, time_stamp2):
    time1 = parser.parse(time_stamp1)
    time2 = parser.parse(time_stamp2)
    time_interval = rrule.rrule(rrule.SECONDLY, dtstart=time1, until=time2)
    print(time_interval.count())
    return time_interval.count()
