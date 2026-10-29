#!/usr/bin/python
import re
import datetime as dt
import sys

# Remove or comment out this print � it pollutes output for Robot parsing
# print("Executing code")

with open('background_syslog.txt', encoding='utf8', errors='ignore') as f:
    lines = f.readlines()

str1 = 'Starting resetting procedure'
str3 = 'Validated to OnAirDone'

reset_start_raw = ''
on_air_raw = ''

# Time pattern for HH:MM:SS (strict)
time_pattern = r'(?:2[0-3]|[01][0-9]):[0-5][0-9]:[0-5][0-9]'

for line in lines:
    try:
        if str1 in line:
            # Extract time HH:MM:SS from the line
            match = re.search(time_pattern, line)
            if match:
                reset_start_raw = match.group()
    except Exception as e:
        # Log error if needed
        pass

    try:
        if str3 in line:
            match = re.search(time_pattern, line)
            if match:
                on_air_raw = match.group()
    except Exception as e:
        pass

if reset_start_raw and on_air_raw:
    time1 = dt.datetime.strptime(reset_start_raw, '%H:%M:%S')
    time2 = dt.datetime.strptime(on_air_raw, '%H:%M:%S')
    diff = time2 - time1
    # Output the seconds difference only
    sys.stdout.write(str(diff.seconds))
else:
    # If no times found, output 0 or suitable error value
    sys.stdout.write('0')
