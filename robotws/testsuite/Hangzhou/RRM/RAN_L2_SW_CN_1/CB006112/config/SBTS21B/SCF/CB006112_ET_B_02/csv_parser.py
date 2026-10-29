#!/usr/bin/env python3
import csv
import logging
logging.basicConfig(level=logging.INFO)


def get_priority_and_sfnInterval_form_csv(csv_file="./csv/test001.csv"):
    with open(csv_file) as fh:
        data = csv.reader(fh)
        rows = [row for row in data]
    prioriy_list = []
    sfn_list = []
    for i in rows:
        for j in i:
            if j == 'ulTdSchedSubcellData: sfn':
                prioriy_list.append(i[45])
                sfn_list.append(i[37])
    sfn_interval_lt = []
    for i in range(len(sfn_list) - 1):
        a = int(sfn_list[i+1]) - int(sfn_list[i])
        sfn_interval_lt.append(a)
    return prioriy_list, sfn_interval_lt
