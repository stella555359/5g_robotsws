import os
import json
import getopt
import sys
import math
from enum import Enum
from pathlib import Path

# TAF Libraries:
from taf.analyzer.ttitrace_eventdecoder import TtitraceReader as TtitraceReaderEvtDec


def allocCellThroughputDl(jsonPathName, DL_min_data_allocation, DL_maxThroughputL1Pool):
    """
    This function returns the value of allocCellThroughputDl for any cell every Five SFN
    """
    print("TTI jsonfile: %s " % jsonPathName)

    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        return 0

    DL_min_data_allocation = int(DL_min_data_allocation)
    DL_maxThroughputL1Pool = int(DL_maxThroughputL1Pool)
    nbMsg = 0
    allocCellThroughputDl = 0
    sfn = 0
    current_sfn_in_progress = 0
    allocCellThroughputDl_sum = 0
    nbre_pass = 0
    failure = 0

    with open(jsonPathName, 'rb') as file_obj:
        print("Nb message avant boucle for: %s" % nbMsg)
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            nbMsg = nbMsg+1
            if event.type == "dlAllocatedPooledResourcesData":
                sfn = event.data["eventHeader"]["sfn"]
                allocCellThroughputDl = event.data["allocCellThroughputDl"]
                allocCellThroughputDl = allocCellThroughputDl * 8
                print("allocCellThroughputDl value in bit/slot per SFN is %s/%s" % (sfn, allocCellThroughputDl))
                if current_sfn_in_progress != sfn:
                    if allocCellThroughputDl_sum > DL_maxThroughputL1Pool:
                        print("allocCellThroughputDl_sum > DL_maxThroughputL1Pool at SFN %s" % sfn)
                        failure = failure+1
                        break  # return result_check
                    allocCellThroughputDl_sum = allocCellThroughputDl
                    current_sfn_in_progress = sfn
                    print("current_sfn_in_progress != sfn, sum is %s" % allocCellThroughputDl_sum)
                else:
                    allocCellThroughputDl_sum = allocCellThroughputDl_sum + allocCellThroughputDl
                    if allocCellThroughputDl_sum > DL_maxThroughputL1Pool:
                        print("allocCellThroughputDl_sum > DL_maxThroughputL1Pool at SFN %s" % sfn)
                        failure = failure+1
                        break  # return result_check
                    print("current_sfn_in_progress = sfn, sum is %s" % allocCellThroughputDl_sum)
                if allocCellThroughputDl < DL_min_data_allocation:
                    print("allocCellThroughputDl < DL_min_data_allocation at SFN %s" % sfn)
                    failure = failure+1
                    break  # return result_check
    if failure != 0:
        return failure


def Check_allocCellThroughput(jsonPathName, eventTTI, columnInEvent, min_data_allocation, maxTputLimit):
    """
    This function checks in tti json file :
    1) in event dlAllocatedPooledResourcesData, for each sfn :
    The value of column allocCellThroughputDl (in bytes/slot)*8 of each cell should be
    >= the predefined min_data_allocation (bits/slot);
    The sum of the values of allocCellThroughputDl at the same sfn should be
    <= the predefined maxTputLimit;
    or
    2) in event ulAllocatedPooledResourcesData, for each sfn :
    The value of column allocCellThroughputUl (in bytes/slot)*8 of each cell should be
    >= the predefined min_data_allocation (bits/slot);
    The sum of the values of allocCellThroughputUl at the same sfn should be
    <= the predefined maxTputLimit;
    If the above condition fails, then the value of variable "failure" increments,
    returns the value of failure
    """
    print("====> Check the value of %s in TTI event %s in TTI jsonfile: %s "
          % (columnInEvent, eventTTI, jsonPathName))

    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        return 0

    min_data_allocation = int(min_data_allocation)
    maxTputLimit = int(maxTputLimit)
    nbMsg = 0
    allocCellThroughput = 0
    sfn = 0
    current_sfn_in_progress = 0
    allocCellThroughput_sum = 0
    nbre_pass = 0
    failure = 0

    with open(jsonPathName, 'rb') as file_obj:
        print("Nb message avant boucle for: %s" % nbMsg)
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            nbMsg = nbMsg+1
            if event.type == eventTTI:
                sfn = event.data["eventHeader"]["sfn"]
                physCellId = event.data["eventHeader"]["physCellId"]
                allocCellThroughput = event.data[columnInEvent]
                allocCellThroughput = allocCellThroughput * 8
                print("value of column %s of cell %s in bit/slot per SFN is %s/%s"
                      % (columnInEvent, physCellId, sfn, allocCellThroughput))
                if current_sfn_in_progress != sfn:
                    if allocCellThroughput_sum > maxTputLimit:
                        print("allocCellThroughput_sum of all cells > max Tput Limit of L1Pool at SFN %s" % sfn)
                        failure = failure+1
                        break  # return result_check
                    allocCellThroughput_sum = allocCellThroughput
                    current_sfn_in_progress = sfn
                    print("current_sfn_in_progress != sfn, sum is %s" % allocCellThroughput)
                else:
                    allocCellThroughput_sum = allocCellThroughput_sum + allocCellThroughput
                    if allocCellThroughput_sum > maxTputLimit:
                        print("allocCellThroughput_sum of all cells > max Tput Limit of L1Pool at SFN %s" % sfn)
                        failure = failure+1
                        break  # return result_check
                    print("current_sfn_in_progress = sfn, sum is %s" % allocCellThroughput_sum)
                if allocCellThroughput < min_data_allocation:
                    print("allocCellThroughput < min garanted data allocation at SFN %s" % sfn)
                    failure = failure+1
                    break  # return result_check
    # if failure != 0:
    return failure


def Check_IWK_8927_RAT_Value(jsonPathName, eventTTI, columnInEvent):
    """
    This function checks in tti json file, in event dlFdSchedData, at each SFN,
    the value of rat0Bitmap :
    - if physCellId=50 : rat0Bitmap value should be 0 since cell 50 is configured
    with RAT1 (dl resource allocation type=1)
    - if physCellId!=50 : rat0Bitmap value should be > 0, since all other cells
    are configured with RAT0 (dl resource allocation type=1) , the value will be a
    bitmap value, non zero;
    If the above condition fails, then the value of variable "failure" increments,
    returns the value of failure
    """
    sfn = 0
    failure = 0
    rat0Bitmap_value = 1
    print("====> Check the value of %s in TTI event %s in TTI jsonfile: %s "
          % (columnInEvent, eventTTI, jsonPathName))

    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        failure = 1
        return failure

    with open(jsonPathName, 'rb') as file_obj:
        print("TTI handling for event: %s Column %s " % (eventTTI, columnInEvent))
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == eventTTI:
                sfn = event.data["eventHeader"]["sfn"]
                physCellId = event.data["eventHeader"]["physCellId"]
                rat0Bitmap_value = event.data[columnInEvent]
                if physCellId == 50 and rat0Bitmap_value != 0:
                    print("cell %s Rat0BitMap Value is : %s, it should be 0, check failed"
                          % (physCellId, rat0Bitmap_value))
                    failure = 1
                    break
                if physCellId != 50 and rat0Bitmap_value == 0:
                    print("cell %s Rat0BitMap Value is : %s, it should not be 0, check failed"
                          % (physCellId, rat0Bitmap_value))
                    failure = 1
                    break
    return failure


def Check_PrbAllocation(jsonPathName, eventTTI, columnInEvent, min_prb_allocation,
                        maxCellPrbL1Pool_Legacy, maxCellPrbL1Pool):
    """
    This function checks :
    """
    sfn = 0
    failure = 0
    current_sfn_in_progress = 1025    # valid sfn in tti 0-1024
    allocCellPrb = 0
    allocCellPrb_sum = 0
    min_prb_allocation = int(min_prb_allocation)
    maxCellPrbL1Pool_Legacy = int(maxCellPrbL1Pool_Legacy)
    maxCellPrbL1Pool = int(maxCellPrbL1Pool)

    print("====> Check the value of %s in TTI event %s in TTI jsonfile: %s "
          % (columnInEvent, eventTTI, jsonPathName))
    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        failure = 1
        return failure
    with open(jsonPathName, 'rb') as file_obj:
        print("TTI handling for event: %s Column %s " % (eventTTI, columnInEvent))
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == eventTTI:
                sfn = event.data["eventHeader"]["sfn"]
                physCellId = event.data["eventHeader"]["physCellId"]
                allocCellPrb = event.data[columnInEvent]
                print("allocated cell PRB %s of cell %s at SFN %s is %s"
                      % (columnInEvent, physCellId, sfn, allocCellPrb))
                if allocCellPrb < min_prb_allocation:
                    print("allocCellPrb of cell %s at sfn %s is %s : failed" % (physCellId, sfn, allocCellPrb))
                    failure = failure+1
                    break
                if current_sfn_in_progress == 1025:
                    print("first record of event %s at SFN %s" % (eventTTI, sfn))
                    current_sfn_in_progress = sfn    # re-initialise current sfn
                if current_sfn_in_progress != 1025 and sfn == current_sfn_in_progress:
                    allocCellPrb_sum = allocCellPrb_sum + allocCellPrb
                    print("sum of allocCellPrb at sfn %s is %s :" % (sfn, allocCellPrb_sum))
                if current_sfn_in_progress != 1025 and sfn != current_sfn_in_progress:
                    # entre in a new sfn, check the sum of the previous sfn's allocCellPrb
                    if allocCellPrb_sum > maxCellPrbL1Pool or allocCellPrb_sum < maxCellPrbL1Pool_Legacy:
                        print("allocCellPrb_sum= %s at SFN %s is out of range between: %s and %s"
                              % (allocCellPrb_sum, sfn, maxCellPrbL1Pool_Legacy, maxCellPrbL1Pool))
                        failure = failure+1
                        break
                    else:
                        allocCellPrb_sum = allocCellPrb    # entre in a new sfn, reinitialise the sum and current sfn
                        current_sfn_in_progress = sfn
                        print("current_sfn_in_progress is sfn %s, new sum is %s" % (sfn, allocCellPrb_sum))
    return failure


def Check_UlCellTpRedFactor(
    jsonPathName,
    eventTTI,
    columnInEvent,
    min_data_allocation,
    maxTputLimit,
    maxThresholdTputAlloc
):
    """
    Added for the CB013199 enhancement feature CB015330
    This function checks in tti json file :
    1) in event ulAllocatedPooledResourcesData:
    At each sfn, check the CB013199 behaviour (legacy feature) :
    - The value of column allocCellThroughputUl (in bytes/slot)*8 of each cell should be
      >= the predefined min_data_allocation (bits/slot);
    - The sum of the values of allocCellThroughputUl at the same sfn should be
      <= the predefined maxTputLimit;
    If one of the above condition fails, then the value of variable "failure" increments,
    returns the value of failure;

    And check also the CB015330 behaviour (new feature):
    If in the same sfn, the sum of the values of allocCellThroughputUl > maxThresholdTputAlloc, then
    expected value of the colomn "ulCellTpRedFactorInSch" of each cell in the sfn should be 0.75,
    otherwise the expected value of the "ulCellTpRedFactorInSch" should be 1;
    """
    print("====> Check the value of %s in TTI event %s in TTI jsonfile: %s "
          % (columnInEvent, eventTTI, jsonPathName))

    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        return 0

    min_data_allocation = int(min_data_allocation)
    maxTputLimit = int(maxTputLimit)
    maxThresholdTputAlloc = int(maxThresholdTputAlloc)
    nbMsg = 0
    allocCellThroughput = 0
    sfn = 0
    current_sfn_in_progress = 0
    allocCellThroughput_sum = 0
    nbre_pass = 0
    failure = 0
    expected_ulCellTpRedFactorInSch_min = 0.75
    expected_ulCellTpRedFactorInSch_max = 1
    ulCellTpRedFactorInSch_value = 0
    nb_Of_Rows_In_Sfn = 0
    ulCellTpRedFactorInSch_sum_of_sfn = 0

    with open(jsonPathName, 'rb') as file_obj:
        print("Nb message avant boucle for: %s" % nbMsg)
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            nbMsg = nbMsg+1
            if event.type == eventTTI:
                sfn = event.data["eventHeader"]["sfn"]
                physCellId = event.data["eventHeader"]["physCellId"]
                allocCellThroughput = event.data[columnInEvent]
                allocCellThroughput = allocCellThroughput * 8
                ulCellTpRedFactorInSch_value = event.data["ulCellTpRedFactorInSch"]
                print("At SFN %s , Cell %s 's AllocTput %s = %s in bits/slot, ulCellTpRedFactorInSch = %s"
                      % (sfn, physCellId, columnInEvent, allocCellThroughput, ulCellTpRedFactorInSch_value))
                if current_sfn_in_progress != sfn:
                    if allocCellThroughput_sum > maxTputLimit:
                        print("allocCellThroughput_sum of all cells > max Tput Limit of L1Pool at SFN %s" % sfn)
                        failure = failure+1
                        break  # return result_check
                    # check of CB015330, expected ulCellTpRedFactorInSch should be 0.75 for each cell in the l1pool
                    if (allocCellThroughput_sum > maxThresholdTputAlloc) and \
                       (ulCellTpRedFactorInSch_sum_of_sfn != expected_ulCellTpRedFactorInSch_min*nb_Of_Rows_In_Sfn):
                        print(
                            "At least 1 unexpected ulCellTpRedFactorInSch value in sfn %s, since "
                            "allocCellThroughput_sum %s > maxThresholdTputAlloc %s"
                            % (current_sfn_in_progress, allocCellThroughput_sum, maxThresholdTputAlloc)
                        )
                        print("expected ulCellTpRedFactorInSch is %s" % expected_ulCellTpRedFactorInSch_min)
                        failure = failure+1
                        break  # return result_check
                    # check of CB015330, expected ulCellTpRedFactorInSch should be 1 for each cell in the l1pool
                    if (allocCellThroughput_sum <= maxThresholdTputAlloc) and \
                       (ulCellTpRedFactorInSch_sum_of_sfn != expected_ulCellTpRedFactorInSch_max*nb_Of_Rows_In_Sfn):
                        print(
                            "At least got one unexpected ulCellTpRedFactorInSch value in sfn %s, since "
                            "allocCellThroughput_sum %s < maxThresholdTputAlloc %s"
                            % (current_sfn_in_progress, allocCellThroughput_sum, maxThresholdTputAlloc)
                        )
                        print("expected ulCellTpRedFactorInSch is %s" % expected_ulCellTpRedFactorInSch_max)
                        failure = failure+1
                        break  # return result_check
                    allocCellThroughput_sum = allocCellThroughput
                    ulCellTpRedFactorInSch_sum_of_sfn = ulCellTpRedFactorInSch_value
                    current_sfn_in_progress = sfn
                    nb_Of_Rows_In_Sfn = 1
                    print("current_sfn_in_progress changed, new sfn = %s , sum is %s, nb of rows in sfn is %s"
                          % (sfn, allocCellThroughput, nb_Of_Rows_In_Sfn))
                else:
                    allocCellThroughput_sum = allocCellThroughput_sum + allocCellThroughput
                    ulCellTpRedFactorInSch_sum_of_sfn += ulCellTpRedFactorInSch_value
                    nb_Of_Rows_In_Sfn += 1
                    if allocCellThroughput_sum > maxTputLimit:
                        print("allocCellThroughput_sum of all cells > max Tput Limit of L1Pool at SFN %s" % sfn)
                        failure = failure+1
                        break  # return result_check
                    # print("current_sfn_in_progress = sfn, alloc tput sum is %s" % allocCellThroughput_sum)
                    print(
                        "current_sfn_in_progress = %s, %s rows in the same sfn, alloc tput sum is %s, "
                        "ul red factor is %s"
                        % (sfn, nb_Of_Rows_In_Sfn, allocCellThroughput_sum, ulCellTpRedFactorInSch_sum_of_sfn)
                    )
                if allocCellThroughput < min_data_allocation:
                    print("allocCellThroughput < min garanted data allocation at SFN %s" % sfn)
                    failure = failure+1
                    break  # return result_check
    # if failure != 0:
    return failure


def Split_Json_Of_2_L1Pools(
    jsonPathName,
    json_file_1,
    json_file_2
):
    """
    To split json file by physCellId
    physCellId=50,52, l1pool x
    physCellId=51,53, l1pool y
    """
    print("====> spliting jsonfile %s into %s and %s : "
          % (jsonPathName, json_file_1, json_file_2))
    nbMsg = 0

    pool_x_items = []
    pool_y_items = []

    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        return 0

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            nbMsg = nbMsg+1
            physCellId = event.data["eventHeader"]["physCellId"]
            print("event %s : physCellId = %s" % (i, physCellId))
            # if i == 1:
            #     print(event.data)
            if physCellId % 2 == 0:
                pool_x_items.append(event.data)
            else:
                pool_y_items.append(event.data)
        print(pool_x_items[0])
        print(pool_y_items[0])

    with open(json_file_1, 'w', encoding="utf-8") as f:
        json.dump(pool_x_items, f, ensure_ascii=False, indent=4)

    if not os.path.exists(json_file_1) or os.path.getsize(json_file_1) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % json_file_1)
        return 0

    with open(json_file_2, 'w', encoding="utf-8") as f:
        json.dump(pool_y_items, f, ensure_ascii=False, indent=4)

    if not os.path.exists(json_file_2) or os.path.getsize(json_file_2) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % json_file_2)
        return 0

    print("in total, number of event parsed : %s" % nbMsg)
    print("split finished... output file %s and %s are created" % (json_file_1, json_file_2))
