import os
import json
import getopt
import sys
import math
from enum import Enum
from pathlib import Path

# TAF Libraries:
from taf.analyzer.ttitrace_eventdecoder import TtitraceReader as TtitraceReaderEvtDec


def Check_Slot_Processing_Duration_Budget(jsonPathName, expectedBudget):
    """
    This function checks in tti json file, in event ulLoadControlData :
    the value of slotProcessingDurationBudget could be 750 ms in the
    BI slot (loadType value is "LOADTYPEMIXED")
    """
    sfn = 0
    failure = 1
    nbExtendedBudget = 0

    print("Check slotProcessingDurationBudget in ulLoadControlData in %s , the nb of expected timing %s"
          % (jsonPathName, expectedBudget))

    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        failure = 1
        return failure

    with open(jsonPathName, 'rb') as file_obj:
        print("TTI handling for event: ulLoadControlData ...")
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == "ulLoadControlData":
                print("one event ulLoadControlData...")
                sfn = event.data["eventHeader"]["sfn"]
                physCellId = event.data["eventHeader"]["physCellId"]
                timePattern_value = event.data["measurementInfo"]["slotProcessingDurationBudget"]
                loadType_value = event.data["measurementInfo"]["loadType"]
                print("cellId = %s , timing = %s, loadType = %s" % (physCellId, timePattern_value, loadType_value))
                if loadType_value == "LOADTYPEMIXED" and timePattern_value == int(expectedBudget):
                    nbExtendedBudget += 1
    print("nb of occurence of timing pattern 750ms %s" % nbExtendedBudget)
    if nbExtendedBudget > 0:
        print("At least once : slot processing duration budget is: %s" % expectedBudget)
        failure = 0
    return failure


def Check_Multiple_K2_Values(jsonPathName):
    """
    This function checks in tti json file, in event ulFdSchedData, the colomn K2 values
    could be 4,3,2. The number of occurences of K2=4, 3, 2 should be > 0 respectively
    """
    failure = 1
    nbK2is2 = 0
    nbK2is3 = 0
    nbK2is4 = 0

    print("Check K2 values in ulFdSchedData in file : %s" % jsonPathName)
    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        failure = 1
        return failure

    with open(jsonPathName, 'rb') as file_obj:
        print("TTI handling for event ulFdSchedData ...")
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == "ulFdSchedData":
                print("one event ulFdSchedData...")
                sfn = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                physCellId = event.data["eventHeader"]["physCellId"]
                k2_value = event.data["K2"]
                print("sfn=%s, slot=%s, cell=%s, K2=%s" % (sfn, slot, physCellId, k2_value))
                if k2_value == 2:
                    nbK2is2 += 1
                if k2_value == 3:
                    nbK2is3 += 1
                if k2_value == 4:
                    nbK2is4 += 1
    if nbK2is2 == 0:
        print("no occurence of k2=2")
    if nbK2is3 == 0:
        print("no occurence of k2=3")
    if nbK2is4 == 0:
        print("no occurence of k2=4")

    if nbK2is2*nbK2is3*nbK2is4 > 0:
        print("nbK2is2*nbK2is3*nbK2is4 = %s * %s * %s = %s" % (nbK2is2, nbK2is3, nbK2is4, nbK2is2*nbK2is3*nbK2is4))
        failure = 0

    return failure
