# Script author : adrien.hervat@nokia.com
# Script contact: adrien.hervat@nokia.com
# Creation Date               : 13/11/2023
# Modification:
#       20/02/2024      |     File creation
#       13/06/2024      |     First Push
#       07-01-2025     adrien.hervat@nokia.com     Fix algo check csirs trs


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
def CheckCsiRsSlotSymbolPos(csvPathName, ListofCell, TrsSlotsList, TrsSymbolsList):
    """
    """

    csirstable = []

    numofcsirs = [0, 0, 0, 0]
    totalcsirs = 0
    numoftrsitem = [0, 0, 0, 0]
    numofcrsitem = [0, 0, 0, 0]
    numofitem = [0, 0, 0, 0]

    startsymbol = []
    trsinfo = []

    trsslotissue = [0, 0, 0, 0]
    trssymbolissue = [0, 0, 0, 0]
    crsslotissue = [0, 0, 0, 0]
    crssymbolissue = [0, 0, 0, 0]

    with open(csvPathName) as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            if row['_ws.col.info'] == "DlData_CsiRsSendReqL1sw":
                csirstable.append(row)

    for csi in csirstable:
        for i in range(len(ListofCell)):
            count = ListofCell[i].SubCellId.count(csi['3gpp.subcellid'])
            if count > 0:
                numofcsirs[i] += 1

                symbol = csi['DlData_CsiRsResourceL1sw_t.startSymbol']
                startsymbol = symbol.split(',')
                trs = csi['DlData_CsiRsResourceL1sw_t.trsInfo']
                trsinfo = trs.split(',')

                for j in range(len(trsinfo)):
                    if trsinfo[j] == '1':
                        numoftrsitem[i] += 1
                        count = TrsSlotsList.count(csi['3gpp.slot'])
                        if count == 0:
                            trsslotissue[i] += 1
                        count = TrsSymbolsList.count(startsymbol[j])
                        if count == 0:
                            trssymbolissue[i] += 1
                    if trsinfo[j] == '0':
                        numofcrsitem[i] += 1
                        if ListofCell[i].CsiSlots != (csi['3gpp.slot']):
                            crsslotissue[i] += 1
                        count = ListofCell[i].CsiSymbols.count(startsymbol[j])
                        if count == 0:
                            crssymbolissue[i] += 1
                    numofitem[i] += 1
        totalcsirs += 1

    results = {"csipercell": numofcsirs,
               "total": totalcsirs,
               "trsitem": numoftrsitem,
               "trsslot": trsslotissue,
               "trssymbol": trssymbolissue,
               "crsitem": numofcrsitem,
               "crsslot": crsslotissue,
               "crssymbol": crssymbolissue,
               "itempercell": numofitem}

    return results


# Check Rim Rs configuration with Blanking Cell by cell
def CheckCsiRsSlotSymbolPos25R1(csvPathName, ListofCell, TrsSlotsList, TrsSymbolsList):
    """
    """

    csirstable = []

    numofcsirs = [0, 0, 0, 0]
    totalcsirs = 0
    numoftrsitem = [0, 0, 0, 0]
    numofcrsitem = [0, 0, 0, 0]
    numofitem = [0, 0, 0, 0]

    startsymbol = []
    trsinfo = []

    trsslotissue = [0, 0, 0, 0]
    trssymbolissue = [0, 0, 0, 0]
    crsslotissue = [0, 0, 0, 0]
    crssymbolissue = [0, 0, 0, 0]

    with open(csvPathName) as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            if row['_ws.col.info'] == "DlData_CsiRsSendReq":
                csirstable.append(row)

    for csi in csirstable:
        for i in range(len(ListofCell)):
            count = ListofCell[i].SubCellId.count(csi['3gpp.subcellid'])
            if count > 0:
                numofcsirs[i] += 1

                symbol = csi['DlData_CsiRsResource_t.startSymbol']
                startsymbol = symbol.split(',')
                trs = csi['DlData_CsiRsResource_t.trsInfo']
                trsinfo = trs.split(',')

                for j in range(len(trsinfo)):
                    if trsinfo[j] == '1':
                        numoftrsitem[i] += 1
                        count = TrsSlotsList.count(csi['3gpp.slot'])
                        if count == 0:
                            trsslotissue[i] += 1
                        count = TrsSymbolsList.count(startsymbol[j])
                        if count == 0:
                            trssymbolissue[i] += 1
                    if trsinfo[j] == '0':
                        numofcrsitem[i] += 1
                        count = ListofCell[i].CsiSlots.count(csi['3gpp.slot'])
                        if count == 0:
                            crsslotissue[i] += 1
                        count = ListofCell[i].CsiSymbols.count(startsymbol[j])
                        if count == 0:
                            crssymbolissue[i] += 1
                    numofitem[i] += 1
        totalcsirs += 1

    results = {"csipercell": numofcsirs,
               "total": totalcsirs,
               "trsitem": numoftrsitem,
               "trsslot": trsslotissue,
               "trssymbol": trssymbolissue,
               "crsitem": numofcrsitem,
               "crsslot": crsslotissue,
               "crssymbol": crssymbolissue,
               "itempercell": numofitem}

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

    msgDlAlloc = 0
    msgDlInter = 0

    numDlInterL1Event = 0

    L1PoolIdDlStatus = 0
    L1PoolMaxStreamPrbDlStatus = 0
    L1SubpoolPrbDlStatus = [0, 0]

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == "dlAllocatedPooledResourcesData":
                msgDlAlloc += 1
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
                msgDlInter += 1
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
               "DlInterL1Event": numDlInterL1Event,
               "msgdlAl": msgDlAlloc,
               "msgdlIn": msgDlInter
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

    msgUlAlloc = 0
    msgUlInter = 0

    numUlInterL1Event = 0

    L1PoolIdUlStatus = 0
    L1PoolMaxStreamPrbUlStatus = 0
    L1SubpoolPrbUlStatus = [0, 0]

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == "ulAllocatedPooledResourcesData":
                msgUlAlloc += 1
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
                msgUlInter += 1
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
               "msgulAl": msgUlAlloc,
               "msgulIn": msgUlInter
               }

    return results
