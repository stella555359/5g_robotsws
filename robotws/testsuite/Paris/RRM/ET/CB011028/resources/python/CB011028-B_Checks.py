# Python script used for 11028 Checks
# Script author : adrien.hervat@nokia.com
# Script contact: adrien.hervat@nokia.com
# Creation Date               : 13/11/2023
# Modification:
#       27/11/2023      |     File name modification
#       13/12/2023      |     Check Rim Rs with Blanking addition
#       20/12/2023      |     Check Prb Pooling for DL and UL optimization
#       11/01/2024      |     CheckPrbPoolingDL_8940 method addition
#       07-01-2025     adrien.hervat@nokia.com     Fix slot rimrs


import csv
import os
import json
import getopt
import sys
import math
from enum import Enum

# TAF Libraries:
from taf.analyzer.ttitrace_eventdecoder import TtitraceReader as TtitraceReaderEvtDec


# Check Rim Rs configuration with Blanking Cell by cell
def CheckRimRsbyCellWithBlanking(csvPathName, RimRsPrbCell, SubCellId, BlankingLow, BlankingHigh):
    """
    """

    numofrimrsCell = 0

    numofwrongslot = 0

    numofcollisionslot = 0
    secondarysubbcellid = 0

    csirstable = []
    rimrstable = []

    BlankingLowFail = 0
    BlankingHighFail = 0
    lastPrbnonBlanking = 0
    lastPrbFound = 0

    with open(csvPathName) as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            if row['_ws.col.Info'] == "DlData_RimRsSendReq":
                rimrstable.append(row)
            if row['_ws.col.Info'] == "DlData_CsiRsSendReq":
                csirstable.append(row)

    for rim in rimrstable:
        if rim['3gpp.subcellid'] == str(SubCellId):
            # check number of Rim Rs per cell
            if rim['DlData_RimRsSendReq_t.numOfPrb'] == RimRsPrbCell and rim['3gpp.subcellid']:
                numofrimrsCell += 1

            # check number of slot that should not be used for Rim Rs
            if rim['3gpp.slot'] != "3" and rim['3gpp.slot'] != "6" and rim['3gpp.subcellid']:
                numofwrongslot += 1

            # check BlankingLow and BlankingHigh
            lastPrbnonBlanking = 273 - int(BlankingHigh) - 1

            if rim['DlData_RimRsSendReq_t.startPrb'] < BlankingLow and rim['3gpp.subcellid']:
                BlankingLowFail += 1

            lastPrbFound = int(rim['DlData_RimRsSendReq_t.startPrb']) + int(rim['DlData_RimRsSendReq_t.numOfPrb']) - 1
            if lastPrbFound > lastPrbnonBlanking:
                BlankingHighFail += 1

            # check number of collision of RimRs and  CsiRs messages on same slot for same subcell
            secondarysubbcellid = SubCellId + 4

            for csi in csirstable:
                if csi['3gpp.subcellid'] == str(SubCellId) or csi['3gpp.subcellid'] == str(secondarysubbcellid):
                    if rim['3gpp.sfn'] == csi['3gpp.sfn'] and rim['3gpp.slot'] == csi['3gpp.slot']:
                        numofcollisionslot += 1

    results = {"rimrsCell": numofrimrsCell,
               "wrongslot": numofwrongslot,
               "LowFail": BlankingLowFail,
               "HighFail": BlankingHighFail,
               "collisionslot": numofcollisionslot}

    return results


# Check Rim Rs configuration for all cells
def CheckRimRs(csvPathName, RimRsPrbCell1, RimRsPrbCell2, RimRsPrbCell3, RimRsPrbCell4):
    """
    """

    numofrimrsCell1 = 0
    numofrimrsCell2 = 0
    numofrimrsCell3 = 0
    numofrimrsCell4 = 0

    numofwrongslot = 0

    numofcollisionslot = 0
    primarysubbcellid = 0

    csirstable = []
    rimrstable = []

    with open(csvPathName) as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            if row['_ws.col.info'] == "DlData_RimRsSendReq":
                rimrstable.append(row)
            if row['_ws.col.info'] == "DlData_CsiRsSendReqL1sw":
                csirstable.append(row)

    for rim in rimrstable:
        # check number of Rim Rs per cell
        if (rim['DlData_RimRsSendReq_t.numOfPrb'] == RimRsPrbCell1 and rim['3gpp.subcellid']) == "0":
            numofrimrsCell1 += 1
        if (rim['DlData_RimRsSendReq_t.numOfPrb'] == RimRsPrbCell2 and rim['3gpp.subcellid']) == "1":
            numofrimrsCell2 += 1
        if (rim['DlData_RimRsSendReq_t.numOfPrb'] == RimRsPrbCell3 and rim['3gpp.subcellid']) == "2":
            numofrimrsCell3 += 1
        if (rim['DlData_RimRsSendReq_t.numOfPrb'] == RimRsPrbCell4 and rim['3gpp.subcellid']) == "3":
            numofrimrsCell4 += 1
        # check number of slot that should not be used for Rim Rs
        if rim['3gpp.slot'] != "3" and rim['3gpp.slot'] != "12":
            numofwrongslot += 1

        primarysubbcellid = int(rim['3gpp.subcellid']) + 4

        for csi in csirstable:
            # check number of collision of RimRs and  CsiRs messages on same slot for same subcell
            if rim['3gpp.sfn'] == csi['3gpp.sfn'] and rim['3gpp.slot'] == csi['3gpp.slot'] and \
                   (rim['3gpp.subcellid'] == csi['3gpp.subcellid'] or primarysubbcellid == int(csi['3gpp.subcellid'])):
                numofcollisionslot += 1

    results = {"rimrsCell1": numofrimrsCell1,
               "rimrsCell2": numofrimrsCell2,
               "rimrsCell3": numofrimrsCell3,
               "rimrsCell4": numofrimrsCell4,
               "wrongslot": numofwrongslot,
               "collisionslot": numofcollisionslot}

    return results


# Check Rim Rs configuration for all cells on ASOH board
def CheckRimRsForAsoh(csvPathName, RimRsPrbCell1, RimRsPrbCell2, RimRsPrbCell3, RimRsPrbCell4):
    """
    """

    numofrimrsCell1 = 0
    numofrimrsCell2 = 0
    numofrimrsCell3 = 0
    numofrimrsCell4 = 0

    numofwrongslot = 0

    numofcollisionslot = 0
    primarysubbcellid = 0

    csirstable = []
    rimrstable = []

    with open(csvPathName) as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            if row['_ws.col.Info'] == "DlData_RimRsSendReq":
                rimrstable.append(row)
            if row['_ws.col.Info'] == "DlData_CsiRsSendReqL1sw":
                csirstable.append(row)

    for rim in rimrstable:
        # check number of Rim Rs per cell
        if (rim['DlData_RimRsSendReq_t.numOfPrb'] == RimRsPrbCell1 and rim['3gpp.subcellid']) == "0":
            numofrimrsCell1 += 1
        if (rim['DlData_RimRsSendReq_t.numOfPrb'] == RimRsPrbCell2 and rim['3gpp.subcellid']) == "2":
            numofrimrsCell2 += 1
        if (rim['DlData_RimRsSendReq_t.numOfPrb'] == RimRsPrbCell3 and rim['3gpp.subcellid']) == "4":
            numofrimrsCell3 += 1
        if (rim['DlData_RimRsSendReq_t.numOfPrb'] == RimRsPrbCell4 and rim['3gpp.subcellid']) == "6":
            numofrimrsCell4 += 1
        # check number of slot that should not be used for Rim Rs
        if rim['3gpp.slot'] != "3" and rim['3gpp.slot'] != "6":
            numofwrongslot += 1

        primarysubbcellid = int(rim['3gpp.subcellid']) + 4

        for csi in csirstable:
            # check number of collision of RimRs and  CsiRs messages on same slot for same subcell
            if rim['3gpp.sfn'] == csi['3gpp.sfn'] and rim['3gpp.slot'] == csi['3gpp.slot'] and \
                   (rim['3gpp.subcellid'] == csi['3gpp.subcellid'] or primarysubbcellid == int(csi['3gpp.subcellid'])):
                numofcollisionslot += 1

    results = {"rimrsCell1": numofrimrsCell1,
               "rimrsCell2": numofrimrsCell2,
               "rimrsCell3": numofrimrsCell3,
               "rimrsCell4": numofrimrsCell4,
               "wrongslot": numofwrongslot,
               "collisionslot": numofcollisionslot}

    return results


# Check Prb Pooling DL for all cells and L1 Subpool
def CheckPrbPoolingDL(jsonPathName, ListofCell, L1Pool, ListofL1Subpool):
    """
    """

    numDlReport = [0, 0, 0, 0]
    numZabCell = [0, 0, 0, 0]
    minPrbDlStatus = [0, 0, 0, 0]
    CellPrbDlStatus = [0, 0, 0, 0]
    BbrmUsableCellPrbForDlStatus = [0, 0, 0, 0]
    StreamPrbNonGbrDlStatus = [0, 0, 0, 0]
    StreamPrbGbrDlStatus = [0, 0, 0, 0]

    numDlInterL1Event = 0

    L1PoolIdDlStatus = 0
    L1PoolMaxStreamPrbDlStatus = 0
    L1SubpoolPrbDlStatus = [0, 0]

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == "dlAllocatedPooledResourcesData":
                sfn = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                cellId = event.data["eventHeader"]["physCellId"]
                hasZabPrivilege = event.data["hasZabPrivilege"]
                allocStreamPrbMinDl = event.data["allocStreamPrbMinDl"]
                numAllocCellPrbDl = event.data["numAllocCellPrbDl"]
                bbrmUsableCellPrbForDlGbrLoadReport = event.data["bbrmUsableCellPrbForDlGbrLoadReport"]
                allocStreamPrbNonGbrDl = event.data["allocStreamPrbNonGbrDl"]
                allocStreamPrbGbrDl = event.data["allocStreamPrbGbrDl"]

                for j in range(len(ListofCell)):
                    if cellId == int(ListofCell[j].CellId):
                        if hasZabPrivilege == 1:
                            numZabCell[j] += 1
                        if allocStreamPrbMinDl < int(ListofCell[j].minPrbDl):
                            minPrbDlStatus[j] += 1
                        if numAllocCellPrbDl < int(ListofCell[j].minCellPrbDl) or \
                           numAllocCellPrbDl > int(ListofCell[j].maxCellPrbDl):
                            CellPrbDlStatus[j] += 1
                        if bbrmUsableCellPrbForDlGbrLoadReport != int(ListofCell[j].bbrmUsableCellPrbForDl):
                            BbrmUsableCellPrbForDlStatus[j] += 1
                        if allocStreamPrbNonGbrDl < int(ListofCell[j].StreamPrbNonGbrDl):
                            StreamPrbNonGbrDlStatus[j] += 1
                        if allocStreamPrbGbrDl < int(ListofCell[j].StreamPrbGbrDl):
                            StreamPrbGbrDlStatus[j] += 1
                        numDlReport[j] += 1

            if event.type == "dlInterL1SubpoolReconfData":
                sfn = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                l1PoolId = event.data["l1PoolId"]
                poolMaxNumStreamPrb = event.data["poolMaxNumStreamPrb"]

                if l1PoolId != int(L1Pool.L1PoolIdtoCheck):
                    L1PoolIdDlStatus += 1
                if poolMaxNumStreamPrb != int(L1Pool.L1PoolMaxStreamPrbDl):
                    L1PoolMaxStreamPrbDlStatus += 1

                for j in range(len(event.data["l1SubPools"])):
                    for k in range(len(ListofL1Subpool)):
                        if event.data["l1SubPools"][j]["subPoolId"] == int(ListofL1Subpool[k].L1SpId):
                            if event.data["l1SubPools"][j]["currentStreamPrbCapacityPerSp"] < \
                                    int(ListofL1Subpool[k].minStreamL1SpDl) or \
                                    event.data["l1SubPools"][j]["currentStreamPrbCapacityPerSp"] > \
                                    int(ListofL1Subpool[k].maxStreamL1SpDl):
                                L1SubpoolPrbDlStatus[k] += 1
                numDlInterL1Event += 1

    results = {"DlReport": numDlReport,
               "ZabCell": numZabCell,
               "MinPrbDl": minPrbDlStatus,
               "CellPrbDl": CellPrbDlStatus,
               "BbrmUsablePrbDl": BbrmUsableCellPrbForDlStatus,
               "StreamPrbNonGbrDl": StreamPrbNonGbrDlStatus,
               "StreamPrbGbrDl": StreamPrbGbrDlStatus,
               "L1PoolIdDl": L1PoolIdDlStatus,
               "L1PoolMaxDl": L1PoolMaxStreamPrbDlStatus,
               "L1SubpoolPrbDl": L1SubpoolPrbDlStatus,
               "DlInterL1Event": numDlInterL1Event
               }

    return results


# Check Prb Pooling DL for all cells and L1 Subpool
def CheckPrbPoolingDL_8940(jsonPathName, ListofCell, L1Pool, ListofL1Subpool):
    """
    """

    numDlReport = [0, 0, 0, 0]
    numZabCell = [0, 0, 0, 0]
    minPrbDlStatus = [0, 0, 0, 0]
    CellPrbDlStatus = [0, 0, 0, 0]
    StreamPrbNonGbrDlStatus = [0, 0, 0, 0]
    StreamPrbGbrDlStatus = [0, 0, 0, 0]

    numDlInterL1Event = 0

    L1PoolIdDlStatus = 0
    L1PoolMaxStreamPrbDlStatus = 0
    L1SubpoolPrbDlStatus = [0, 0]

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == "dlAllocatedPooledResourcesData":
                sfn = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                cellId = event.data["eventHeader"]["physCellId"]
                hasZabPrivilege = event.data["hasZabPrivilege"]
                allocStreamPrbMinDl = event.data["allocStreamPrbMinDl"]
                numAllocCellPrbDl = event.data["numAllocCellPrbDl"]
                allocStreamPrbNonGbrDl = event.data["allocStreamPrbNonGbrDl"]
                allocStreamPrbGbrDl = event.data["allocStreamPrbGbrDl"]

                for j in range(len(ListofCell)):
                    if cellId == int(ListofCell[j].CellId):
                        if hasZabPrivilege == 1:
                            numZabCell[j] += 1
                        if allocStreamPrbMinDl < int(ListofCell[j].minPrbDl):
                            minPrbDlStatus[j] += 1
                        if numAllocCellPrbDl < int(ListofCell[j].minCellPrbDl) or \
                           numAllocCellPrbDl > int(ListofCell[j].maxCellPrbDl):
                            CellPrbDlStatus[j] += 1
                        if allocStreamPrbNonGbrDl < int(ListofCell[j].StreamPrbNonGbrDl):
                            StreamPrbNonGbrDlStatus[j] += 1
                        if allocStreamPrbGbrDl < int(ListofCell[j].StreamPrbGbrDl):
                            StreamPrbGbrDlStatus[j] += 1
                        numDlReport[j] += 1

            if event.type == "dlInterL1SubpoolReconfData":
                sfn = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                l1PoolId = event.data["l1PoolId"]
                poolMaxNumStreamPrb = event.data["poolMaxNumStreamPrb"]

                if l1PoolId != int(L1Pool.L1PoolIdtoCheck):
                    L1PoolIdDlStatus += 1
                if poolMaxNumStreamPrb != int(L1Pool.L1PoolMaxStreamPrbDl):
                    L1PoolMaxStreamPrbDlStatus += 1

                for j in range(len(event.data["l1SubPools"])):
                    for k in range(len(ListofL1Subpool)):
                        if event.data["l1SubPools"][j]["subPoolId"] == int(ListofL1Subpool[k].L1SpId):
                            if event.data["l1SubPools"][j]["currentStreamPrbCapacityPerSp"] < \
                                    int(ListofL1Subpool[k].minStreamL1SpDl) or \
                                    event.data["l1SubPools"][j]["currentStreamPrbCapacityPerSp"] > \
                                    int(ListofL1Subpool[k].maxStreamL1SpDl):
                                L1SubpoolPrbDlStatus[k] += 1
                numDlInterL1Event += 1

    results = {"DlReport": numDlReport,
               "ZabCell": numZabCell,
               "MinPrbDl": minPrbDlStatus,
               "CellPrbDl": CellPrbDlStatus,
               "StreamPrbNonGbrDl": StreamPrbNonGbrDlStatus,
               "StreamPrbGbrDl": StreamPrbGbrDlStatus,
               "L1PoolIdDl": L1PoolIdDlStatus,
               "L1PoolMaxDl": L1PoolMaxStreamPrbDlStatus,
               "L1SubpoolPrbDl": L1SubpoolPrbDlStatus,
               "DlInterL1Event": numDlInterL1Event
               }

    return results


# Check Prb Pooling UL for all cells and L1 Subpool
def CheckPrbPoolingUL(jsonPathName, ListofCell, L1Pool, ListofL1Subpool):
    """
    """

    numUlReport = [0, 0, 0, 0]

    CellPrbUlStatus = [0, 0, 0, 0]
    BbrmUsableCellPrbForUlStatus = [0, 0, 0, 0]
    StreamPrbNonGbrUlStatus = [0, 0, 0, 0]
    StreamPrbGbrUlStatus = [0, 0, 0, 0]

    numUlInterL1Event = 0

    L1PoolIdUlStatus = 0
    L1PoolMaxStreamPrbUlStatus = 0
    L1SubpoolPrbUlStatus = [0, 0]

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == "ulAllocatedPooledResourcesData":
                sfn = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                cellId = event.data["eventHeader"]["physCellId"]
                numAllocCellPrbUl = event.data["numAllocCellPrbUl"]
                bbrmUsableCellPrbForUlGbrLoadReport = event.data["bbrmUsableCellPrbForUlGbrLoadReport"]
                allocStreamPrbNonGbrUl = event.data["allocStreamPrbNonGbrUl"]
                allocStreamPrbGbrUl = event.data["allocStreamPrbGbrUl"]

                for j in range(len(ListofCell)):
                    if cellId == int(ListofCell[j].CellId):
                        if numAllocCellPrbUl < int(ListofCell[j].minCellPrbUl) or \
                           numAllocCellPrbUl > int(ListofCell[j].maxCellPrbUl):
                            CellPrbUlStatus[j] += 1
                        if bbrmUsableCellPrbForUlGbrLoadReport != int(ListofCell[j].bbrmUsableCellPrbForUl):
                            BbrmUsableCellPrbForUlStatus[j] += 1
                        if allocStreamPrbNonGbrUl < int(ListofCell[j].StreamPrbNonGbrUl):
                            StreamPrbNonGbrUlStatus[j] += 1
                        if allocStreamPrbGbrUl < int(ListofCell[j].StreamPrbGbrUl):
                            StreamPrbGbrUlStatus[j] += 1
                        numUlReport[j] += 1

            if event.type == "ulInterL1SubpoolReconfData":
                sfn = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                l1PoolId = event.data["l1PoolId"]
                poolMaxNumStreamPrb = event.data["poolMaxNumStreamPrb"]

                if l1PoolId != int(L1Pool.L1PoolIdtoCheck):
                    L1PoolIdUlStatus += 1
                if poolMaxNumStreamPrb != int(L1Pool.L1PoolMaxStreamPrbUl):
                    L1PoolMaxStreamPrbUlStatus += 1

                for j in range(len(event.data["l1SubPools"])):
                    for k in range(len(ListofL1Subpool)):
                        if event.data["l1SubPools"][j]["subPoolId"] == int(ListofL1Subpool[k].L1SpId):
                            if event.data["l1SubPools"][j]["currentStreamPrbCapacityPerSp"] < \
                                    int(ListofL1Subpool[k].minStreamL1SpUl) or \
                                    event.data["l1SubPools"][j]["currentStreamPrbCapacityPerSp"] > \
                                    int(ListofL1Subpool[k].maxStreamL1SpUl):
                                L1SubpoolPrbUlStatus[k] += 1
                numUlInterL1Event += 1

    results = {"UlReport": numUlReport,
               "CellPrbUl": CellPrbUlStatus,
               "BbrmUsablePrbUl": BbrmUsableCellPrbForUlStatus,
               "StreamPrbNonGbrUl": StreamPrbNonGbrUlStatus,
               "StreamPrbGbrUl": StreamPrbGbrUlStatus,
               "L1PoolIdUl": L1PoolIdUlStatus,
               "L1PoolMaxUl": L1PoolMaxStreamPrbUlStatus,
               "L1SubpoolPrbUl": L1SubpoolPrbUlStatus,
               "UlInterL1Event": numUlInterL1Event,
               }

    return results
