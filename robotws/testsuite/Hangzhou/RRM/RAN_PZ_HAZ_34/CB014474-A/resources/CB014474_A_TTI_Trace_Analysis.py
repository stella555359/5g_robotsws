# -*- coding: utf-8 -*

"""
Author:         Chen Helen
Contact Mail:   Helen.1.chen@nokia.com
Description:    Event trace log analysis
                Column index may changes in different program, so when calling this file,
                you will need to set value for program.
"""
import csv


def find_two_initTx_ues_paired_with_rat0(
    csv_file, filter_name1, filter_name2, filter_name3,
    filter_name4, filter_name5, filter_name6
):
    filtered_results = []
    with open(csv_file) as f:
        reader = csv.DictReader(f=f)
        for row in reader:
            if (row.get(filter_name1) == 'MUPAIR' and
                    row.get(filter_name2) != '0' and
                    row.get(filter_name3) == '1'):
                filtered_results.append(row)
    final_filtered_results = []
    for i in range(len(filtered_results)):
        for j in range(i + 1, len(filtered_results)):
            row1 = filtered_results[i]
            row2 = filtered_results[j]
            if (row1.get(filter_name4) == row2.get(filter_name4) and
                    row1.get(filter_name5) == row2.get(filter_name5) and
                    row1.get(filter_name6) != row2.get(filter_name6)):
                final_filtered_results.append((row1.get(filter_name4), row1.get(filter_name5)))
    if len(final_filtered_results) > 2:
        return True
    else:
        return False


def find_two_reTx_ues_paired_with_rat0(
    csv_file, filter_name1, filter_name2, filter_name3,
    filter_name4, filter_name5, filter_name6
):
    filtered_results = []
    with open(csv_file) as f:
        reader = csv.DictReader(f=f)
        for row in reader:
            if row.get(filter_name1) == 'MUPAIR' and row.get(filter_name2) != '0':
                filtered_results.append(row)
    final_filtered_results = []
    for i in range(len(filtered_results)):
        for j in range(i + 1, len(filtered_results)):
            row1 = filtered_results[i]
            row2 = filtered_results[j]
            if (row1.get(filter_name4) == row2.get(filter_name4) and
                    row1.get(filter_name5) == row2.get(filter_name5) and
                    row1.get(filter_name6) != row2.get(filter_name6) and
                    (row1.get(filter_name3) != '1' or row2.get(filter_name3) != '1')):
                final_filtered_results.append((row1.get(filter_name4), row1.get(filter_name5)))
    if len(final_filtered_results) > 2:
        return True
    else:
        return False


def find_BWP13_initTx_ue_with_rat0(csv_file, filter_name1, filter_name2, filter_name3, filter_name4):
    group1 = []
    group3 = []
    with open(csv_file) as f:
        reader = csv.DictReader(f=f)
        for row in reader:
            if (row.get(filter_name1) == '1' and
                    row.get(filter_name2) != '0' and
                    row.get(filter_name3) == '1'):
                group1.append(row)
            elif (row.get(filter_name1) == '3' and
                    row.get(filter_name2) != '0' and
                    row.get(filter_name3) == '1'):
                group3.append(row)
    for row1 in group1:
        for row3 in group3:
            if row1.get(filter_name4) != row3.get(filter_name4):
                return True
    return False


def find_BWP13_reTx_ue_with_rat0(csv_file, filter_name1, filter_name2, filter_name3, filter_name4):
    group1 = []
    group3 = []
    with open(csv_file) as f:
        reader = csv.DictReader(f=f)
        for row in reader:
            if (row.get(filter_name1) == '1' and
                    row.get(filter_name2) != '0' and
                    row.get(filter_name3) != '1'):
                group1.append(row)
            elif (row.get(filter_name1) == '3' and
                    row.get(filter_name2) != '0' and
                    row.get(filter_name3) != '1'):
                group3.append(row)
    for row1 in group1:
        for row3 in group3:
            if row1.get(filter_name4) != row3.get(filter_name4):
                return True
    return False
