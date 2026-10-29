import re
from datetime import datetime


def Select_power_information_smod(str1):
    result = 0
    sfppower = 0
    hostpower = 0
    list1 = []
    list1 = str1.split('\n')
    line = list1[1]
    matchobj = re.search(r'"SfpPowerLevel":"(.*)""HostPowerLevel":"(.*)""', line)
    sfppower = int(matchobj.group(1))
    hostpower = int(matchobj.group(2))
    if sfppower <= hostpower:
        result = 1
    return result


def Select_power_information_smod_22r4(str1):
    result = 0
    sfppower = 0
    hostpower = 0
    list1 = []
    list1 = str1.split('\n')
    line = list1[1]
    matchobj = re.search(r'"SfpPowerLevel":"(.*)""HostPowerLevel":"(.*)"}', line)
    sfppower = int(matchobj.group(1))
    hostpower = int(matchobj.group(2))
    if sfppower <= hostpower:
        result = 1
    return result


def get_dump_file_result(dump_file):
    with open(dump_file, 'r') as f:
        cont = True
        part = ''
        while cont:
            cont = f.readline()
            if cont != '':
                if cont[0] == '4':
                    part = cont
                    break
    return part[4:6]


def Check_value_threshold(value1, value2, lowthreshold, highthreshold):
    check_thr = 0
    a = isinstance(value1, list)
    if a:
        value1 = float(value1[0])
        value2 = float(value2[0])
    else:
        value1 = float(value1)
        value2 = float(value2)
    lowthreshold = float(lowthreshold)
    highthreshold = float(highthreshold)
    if lowthreshold <= value1 <= highthreshold:
        if lowthreshold <= value2 <= highthreshold:
            check_thr = 1
    return check_thr


def Check_timestamp_rflog(detect_time, ready_time):
    check_time = 0
    matchobj1 = re.search(r'<(.*)\.', detect_time).group(1).replace('T', ' ')
    matchobj1 = datetime.strptime(matchobj1, '%Y-%m-%d %H:%M:%S')
    matchobj2 = re.search(r'<(.*)\.', ready_time).group(1).replace('T', ' ')
    matchobj2 = datetime.strptime(matchobj2, '%Y-%m-%d %H:%M:%S')
    time = (matchobj2 - matchobj1).seconds
    if time <= 91:
        check_time = 1
    return check_time


def Check_file_format(str1):
    format = 0
    if str1[-1] == 'z':
        format = 1
    return format
