import sys
import os
import json


def get_total_cmp(pm_report, expected_value, cell_id=None):
    value = 0
    counter = 0
    sd_level = {}
    for record in pm_report:
        for time in record.keys():
            for counter in record[time].keys():
                for moc in record[time][counter].keys():
                    if cell_id is not None and cell_id in moc:
                        value += int(float(record[time][counter][moc]))
                        if moc in sd_level.keys():
                            sd_level[moc] = sd_level[moc] + int(int(float(record[time][counter][moc])))
                        else:
                            sd_level[moc] = 0
    print(sd_level)
    if expected_value == value:
        return 'PASS'+"'#'"+str(sd_level)
    elif expected_value == -1:
        if value < 1:
            return 'Fail'"'#'"+str(sd_level)
        else:
            return 'PASS'+"'#'"+str(sd_level)
    else:
        print(
            "counter-->",
            counter,
            "expected value-->",
            expected_value,
            "Actual Value",
            value)
        return 'FAIL'+"'#'"+str(sd_level)


def compare_eq(l1, l2):
    for i in range(len(l1)):
        l1[i] = int(l1[i], 16)
    if isinstance(l2, list):
        for i in range(len(l2)):
            l2[i] = int(str(l2[i]))
        for i in l1:
            if i not in l2:
                return 'Fail'
    else:
        print(l2, l1)
        if int(l2) not in l1:
            return 'Fail'
    return 'Pass'


def update_slice_value(val):
    return eval(val)
