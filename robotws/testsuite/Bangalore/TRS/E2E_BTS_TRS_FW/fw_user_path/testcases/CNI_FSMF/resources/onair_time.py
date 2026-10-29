#!/usr/bin/python
import os
import re
import datetime as dt
import sys

print("Executing code")

with open(
    'background_syslog.txt', encoding='utf8', errors='ignore'
) as f:
    lines = f.readlines()
str1 = 'Starting resetting procedure'
str2 = str()

# str3 = "Got OnAir event for cell"

str3 = 'Validated to OnAirDone'
reset_start_raw = str()
on_air_raw = str()
d = r'(?:2[0-3]|[01]?[0-9]):[0-5]?[0-9]:[0-5]?[0-9]'
for i in range(len(lines)):
    try:
        if str1 in lines[i]:
            str2 = lines[i]
            reset_start_raw = re.findall(r'{0}.*?(?=\d*)'.format(d), str2, re.DOTALL)[0]
    except Exception:
        print('Cannot get start of reset message in log')

    try:
        if str3 in lines[i]:
            str2 = lines[i]
            on_air_raw = re.findall(r'{0}.*?(?=\d*)'.format(d), str2, re.DOTALL)[0]
    except Exception:
        print('Cannot get OnAir message in log')

if (reset_start_raw != '') and (on_air_raw != ''):
    time1 = dt.datetime.strptime(reset_start_raw, '%H:%M:%S')
    time2 = dt.datetime.strptime(on_air_raw, '%H:%M:%S')
    diff = time2 - time1
    sys.stdout.write(str(diff.seconds))
