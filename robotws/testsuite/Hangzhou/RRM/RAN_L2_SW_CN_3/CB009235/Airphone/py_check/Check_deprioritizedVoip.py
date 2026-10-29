# _*_ coding:utf-8 _*_
# cs2BlockUeList check
import re
import csv
import sys
import os
import ast


def Check_deprioritizedVoip(Ttitrace):
    with open(Ttitrace, 'r') as f1:
        reader = csv.reader(f1)
        first_row = next(reader)
        resReqClassPrio_index = first_row.index('dlTdSchedSubcellData.resReqClassPrio')
        muStatus_index = first_row.index('dlFdSchedData.muStatus')
        numOf5qi1Prb_index = first_row.index('dlFdSchedData.numOf5qi1Prb')
        print(resReqClassPrio_index)
        print(muStatus_index)
        print(numOf5qi1Prb_index)
        deprioritizedVoip_check_result = []
        for row in reader:
            resReqClassPrio = row[resReqClassPrio_index]
            muStatus = row[muStatus_index]
            numOf5qi1Prb = row[numOf5qi1Prb_index]
            print(resReqClassPrio)
            print(muStatus)
            # print(numOf5qi1Prb)
            if (resReqClassPrio == '25.0') and (muStatus == 'NOMUELIGIBLE_NOTNONGBR'):
                if (numOf5qi1Prb != '0.0') and (numOf5qi1Prb != ''):
                    deprioritizedVoip_check_result.append(resReqClassPrio)
                    print(numOf5qi1Prb)
                else:
                    continue
            else:
                continue
        print(deprioritizedVoip_check_result)
        if '25.0' in deprioritizedVoip_check_result:
            return (True)
        else:
            return (False)
