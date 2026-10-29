import csv
import re
import zipfile
import tarfile
import os
import gzip
from datetime import datetime
import time
import sys

# [Documentation]
# Author: Mateusz Jelen
# Maintainer: Damian Kotula
# Based on syslog saved during snapshot collection, script creates timetable file containing information
# how long it took for snapshot logs to be freezed by BTS/DU/CU.
# Freezing time in timetable is in miliseconds.
# Column D shows time from when the component started to freeze the file until freeze end.
# Column E shows time from start of snapshot until file freeze end.


def time_to_milisec(start_time):
    start_hour = start_time.split(":")[0]
    start_min = start_time.split(":")[1]
    start_sec = start_time.split(":")[2].split(".")[0]
    start_mil = start_time.split(".")[1].split("Z")[0]
    milisec = 3600000 * int(start_hour) + 60000 * int(start_min) + 1000 * int(start_sec) + int(start_mil[0:3])
    return milisec


if len(sys.argv) != 2:
    print("Incorrect file arguments. Please type python /path_to_file/file_name.py /path_to_syslog/syslog_name.log")
else:
    syslog = sys.argv[1]

syslog_content = open(syslog, "r")
syslog_lines = syslog_content.readlines()

start_time = 0
start_time_milisec = 0
for line in syslog_lines:
    if ("startSnapShot" in line or "SNAPSHOT START" in line) and start_time == 0:
        start_time = line.split("<")[1]
        start_time = start_time.split(">")[0]
        start_time = start_time.split("T")[1]
        start_time_milisec = time_to_milisec(start_time)

syslognr = syslog[7:].split(".")[0]
elem_list = []
time_table_file = open("/tmp/time_table.csv", "w")
time_table_file.write("Snapshot start time:" + ";" + start_time + "\n")
time_table_file.write("Element" + ";" + "Freeze start" + ";" + "Freeze end" + ";" + "Time from fr start" + ";" +
                      "Time from snap start" + "\n")

for line in syslog_lines:
    if "Starting to freeze" in line:
        element = line.split(" <")[0]
        element = element.split(" ")[-1]
        fr_st_time = line.split("<")[1]
        fr_st_time = fr_st_time.split(">")[0]
        fr_st_time = fr_st_time.split("T")[1]
        fr_st_time_milisec = time_to_milisec(fr_st_time)
        elem_list.append([element, fr_st_time, fr_st_time_milisec])
for line in syslog_lines:
    fr_st_time2_milisec = 0
    fr_st_time2 = 0
    if "Freeze ended" in line:
        element = line.split(" <")[0]
        element = element.split(" ")[-1]
        for elem in elem_list:
            if element == elem[0]:
                fr_st_time2_milisec = elem[2]
                fr_st_time2 = elem[1]
        fr_en_time = line.split("<")[1]
        fr_en_time = fr_en_time.split(">")[0]
        fr_en_time = fr_en_time.split("T")[1]
        fr_en_time_milisec = time_to_milisec(fr_en_time)
        if fr_st_time2_milisec == 0:
            fr_diff = 0
        else:
            fr_diff = fr_en_time_milisec-fr_st_time2_milisec
        sn_diff = fr_en_time_milisec - start_time_milisec
        time_table_file.write(str(element) + ";" + str(fr_st_time2) + ";" + str(fr_en_time) + ";" + str(fr_diff) +
                              ";" + str(sn_diff) + "\n")

time_table_file.close()
