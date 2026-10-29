import re
from datetime import datetime


def Select_power_information_smod(str1):
    result = 0
    sfppower = 0
    hostpower = 0
    list1 = []
    list1 = str1.split('\n')
    line = list1[1]
    matchobj = re.search(r'"SfpPowerLevel":"(.*)""HostPowerLevel":"(.*)"', line)
    sfppower = int(matchobj.group(1))
    hostpower = int(matchobj.group(2)[0])
    if sfppower <= hostpower:
        result = 1
    return result


def Check_dump_file_powerlevel(dump_txt, power):
    list1 = dump_txt.split('\n')
    str1 = list1[-2][4:6]
    a = bin(int(str1, 16))[2:]
    num = str.zfill(a, 8)
    check_num = 0
    if power == 'PL1' or power == 'PL2':
        if num[-6] == '0':
            check_num = 1
    if power == 'PL3':
        if num[-6] == '1':
            check_num = 1
    return check_num


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
    if time <= 90:
        check_time = 1
    return check_time


def Check_BBMOD_type(BBMOD_txt):
    hostname = ''
    list1 = BBMOD_txt.split('\n')
    Type = re.search(r'value=(.*)\r', list1[1]).group(1)
    if Type == "'ASIL'":
        hostname = 'asp-1b'
    if Type == "'ASIB'":
        hostname = 'fsp-1b'
    return hostname
