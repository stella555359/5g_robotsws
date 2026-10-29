# _*_ coding:utf-8 _*_
# cs2BlockUeList check
import re
import csv
import sys
import os
import ast


def Checkcs2BlockUeList(Ttitrace):
    with open(Ttitrace, 'r') as f1:
        reader = csv.reader(f1)
        first_row = next(reader)
        corrCheckBlockUeListAfterStep1_index = first_row.index('dlMuAwareTdSchInfo.corrCheckBlockUeListAfterStep1')
        cs2BlockUeList_index = first_row.index('dlPreTdBlockUeData.cs2BlockUeList')
        print(corrCheckBlockUeListAfterStep1_index)
        print(cs2BlockUeList_index)
        cs2BlockUeList_check_result = []
        for row in reader:
            corrCheckBlockUeListAfterStep1 = row[corrCheckBlockUeListAfterStep1_index]
            cs2BlockUeList = row[cs2BlockUeList_index]
            corrCheckBlockUe_len = len(corrCheckBlockUeListAfterStep1.split(', '))
            cs2BlockUeList_len = len(cs2BlockUeList.split(', '))
            if (corrCheckBlockUe_len > 1):
                corrCheckBlockUe_list = corrCheckBlockUeListAfterStep1.replace("[", "").replace("]", "")
                corrCheckBlockUe_list = corrCheckBlockUe_list.split(', ')
                print(corrCheckBlockUe_list)
                if (cs2BlockUeList_len > 1):
                    cs2BlockUeList_value = ast.literal_eval(cs2BlockUeList)
                    print(cs2BlockUeList_value)
                    for i in range(len(cs2BlockUeList_value)):
                        rnti = cs2BlockUeList_value[i]['rnti']
                        reason = cs2BlockUeList_value[i]['reason']
                        print(rnti)
                        print(reason)
                        if str(rnti) in corrCheckBlockUe_list:
                            cs2BlockUeList_check_result.append('True')
                        elif (str(reason) != 'CS2_CORRCHECKBLOCK'):
                            continue
                        else:
                            cs2BlockUeList_check_result.append('False')
                else:
                    continue
            else:
                continue
        if 'False' in cs2BlockUeList_check_result:
            print("cs2BlockUeList check result is fail")
            return (False)
        else:
            print('pass')
            return (True)
