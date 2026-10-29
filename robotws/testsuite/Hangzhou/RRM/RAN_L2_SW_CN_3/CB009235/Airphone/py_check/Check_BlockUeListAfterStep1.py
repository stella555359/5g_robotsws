# usr/bin/python
# _*_ coding:utf-8 _*_
# Check BlockUeListAfterStep1
import re
import csv
import sys
import os


def CheckBlockUeListAfterStep1(Ttitrace):
    with open(Ttitrace, 'r') as f1:
        reader = csv.reader(f1)
        first_row = next(reader)
        blocklist_index = first_row.index('dlMuAwareTdSchInfo.corrCheckBlockUeListAfterStep1')
        corrCheckBlockUeList = []
        corrCheckBlockUeList_Fail = []
        corrCheckBlockUeList_check_result = []
        for row in reader:
            corrCheckBlockUe = row[blocklist_index]
            blockUelist_len = len(corrCheckBlockUe.split(','))
            # print(corrCheckBlockUe)
            if (blockUelist_len > 0) and (blockUelist_len <= 3):
                if (corrCheckBlockUe != ''):
                    corrCheckBlockUeList.append(corrCheckBlockUe)
                    corrCheckBlockUeList_check_result.append('True')
                else:
                    continue
            elif (blockUelist_len > 3):
                corrCheckBlockUeList_Fail.append(corrCheckBlockUe)
                corrCheckBlockUeList_check_result.append('False')
            else:
                continue
        print(corrCheckBlockUeList)
        print(corrCheckBlockUeList_Fail)
        if 'False' in corrCheckBlockUeList_check_result:
            print('check blocklist more than 3UE')
            return False
        else:
            return True
