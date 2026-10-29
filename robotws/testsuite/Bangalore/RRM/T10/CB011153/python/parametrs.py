# from collections import namedtuple
import csv
import csv
import time
all_events = {}
xxxx = ''


def get_total_cmp(pm_report, expected_value):
    value = 0
    counter = 0
    for record in pm_report:
        for time in record.keys():
            for counter in record[time].keys():
                for moc in record[time][counter].keys():
                    value += int(record[time][counter][moc])
    if expected_value == value:
        return 'PASS'
    elif expected_value == -1:
        if value < 1:
            return 'Fail'
        else:
            return 'PASS'
    else:
        print(
            "counter-->",
            counter,
            "expected value-->",
            expected_value,
            "Actual Value",
            value)
        return 'FAIL'
