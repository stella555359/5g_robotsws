# Script author : adrien.hervat@nokia.com
# Script contact: adrien.hervat@nokia.com
# Modification:
#       08/10/2024      |     File creation
#       16-06-2025     adrien.hervat@nokia.com     First Delivery
#       20-06-2025     adrien.hervat@nokia.com     New V2 algo for PRB Randomization checking
#       20-06-2025     adrien.hervat@nokia.com     New V3 algo for PRB Randomization checking


import csv
import os
import json
import getopt
import sys
import math
from enum import Enum

# TAF Libraries:
from taf.analyzer.ttitrace_eventdecoder import TtitraceReader as TtitraceReaderEvtDec


# Check if DCI UL_0_0_FORCE is used during Transient Phase
def CheckDCI_UL_0_0_FORCE(jsonPathName, ListofCell):
    """
    """

    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        return 0

    wrongUlDCI = [0, 0, 0, 0]    # To store the number of occurences of a not expected DCI appears

    DCI_UL = ['UL_00_FORCE']     # DCI not expected during RRC reconfiguration (Transient Phase)

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == "ulFdSchedData":
                sfn = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                cellId = event.data["eventHeader"]["physCellId"]
                rnti = event.data["eventHeader"]["rnti"]
                dciformat = event.data["dciFormat"]

                for j in range(len(ListofCell)):
                    if cellId == int(ListofCell[j].CellId):
                        if dciformat in DCI_UL:
                            wrongUlDCI[j] += 1
                            print("DCI UL error on cell %s with RNTI %s at %s/%s" % (cellId, rnti, sfn, slot))
    return wrongUlDCI


def create_tab_for_Cell(x):
    lst = []
    for i in range(x):
        lst_2d = []
        lst.append(lst_2d)
    return lst


def init_tab(x):
    tab = []
    for i in range(x):
        tab.append(0)
    return tab


# Check PRB Randomization on PUSCH >> Check that all startPRB are different in each RRC Reconf
def CheckPrbRandomization_V1(csvPathName, ListofCell):
    """
    """

    if not os.path.exists(csvPathName) or os.path.getsize(csvPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % csvPathName)
        return 0

    nbreconfsent = 0
    nbreconfcomplete = 0

    totalNbRrcReconf = init_tab(x=len(ListofCell))   # Number of RRC Reconfiguration per cell
    statusNbRrcReconf = init_tab(x=len(ListofCell))  # Number of randomization issue during RRC reconfiguration
    start = init_tab(x=len(ListofCell))              # Beginning of an RRC reconfiguration (Transient Phase)

    rnti_rrc = create_tab_for_Cell(x=len(ListofCell))          # Reference RNTI from RRC Reconfiguration
    startprbtabcell = create_tab_for_Cell(x=len(ListofCell))   # Store all start prb for each RRC Reconf for each cells

    last_pusch_sfn = 0
    last_pusch_slot = 0

    with open(csvPathName) as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            for i in range(len(ListofCell)):
                if "RRCReconfiguration" in row['_ws.col.info'] and "DlData" in row['_ws.col.info'] and start[i] == 0:
                    count = ListofCell[i].SubCellId.count(row['3gpp.subcellid'])
                    if count > 0:
                        nbreconfsent += 1
                        reconf = []
                        startprbtabcell[i].append(reconf)
                        start[i] = 1
                        rnti = []
                        rnti_rrc[i].append(rnti)
                        rnti_rrc[i][totalNbRrcReconf[i]] = row['3gpp.rnti']
                if row['_ws.col.info'] == "UlData_PuschReceiveReq" and start[i] == 1:
                    count = ListofCell[i].SubCellId.count(row['3gpp.subcellid'])
                    subcellid = row['3gpp.subcellid']
                    startprb = row['UlData_puschReceiveReqGrant_t.startPrb']
                    rnti = row['3gpp.rnti']
                    sfn = row['3gpp.sfn']
                    slot = row['3gpp.slot']
                    start_split = startprb.split(',')
                    rnti_split = rnti.split(',')
                    for j in range(len(start_split)):
                        if count > 0 and rnti_rrc[i][totalNbRrcReconf[i]] == rnti_split[j]:
                            startprbtabcell[i][totalNbRrcReconf[i]].append(start_split[j])
                            total = len(startprbtabcell[i][totalNbRrcReconf[i]])
                            dupli = len(set(startprbtabcell[i][totalNbRrcReconf[i]]))
                            if total != dupli:
                                start[i] = 2
                                last_pusch_sfn = sfn
                                last_pusch_slot = slot
                if "RRCReconfigurationComplete" in row['_ws.col.info'] and "UlData" in row['_ws.col.info'] \
                        and start[i] >= 1:
                    count = ListofCell[i].SubCellId.count(row['3gpp.subcellid'])
                    rnti = row['3gpp.rnti']
                    subcellid = row['3gpp.subcellid']
                    sfn = row['3gpp.sfn']
                    slot = row['3gpp.slot']
                    nbreconfcomplete += 1
                    if count > 0 and rnti_rrc[i][totalNbRrcReconf[i]] == rnti:
                        if start[i] == 2:
                            if str(last_pusch_sfn) < sfn:
                                statusNbRrcReconf[i] += 1
                                print("Issue on SubcellId %s with RNTI %s at %s/%s" % (subcellid, rnti, sfn, slot))
                            elif str(last_pusch_sfn) == sfn:
                                if str(last_pusch_slot) <= slot:
                                    statusNbRrcReconf[i] += 1
                                    print("Issue on SubcellId %s with RNTI %s at %s/%s" % (subcellid, rnti, sfn, slot))
                            if str(last_pusch_sfn) > sfn:
                                startprbtabcell[i][totalNbRrcReconf[i]].pop()
                            elif str(last_pusch_sfn) == sfn:
                                if str(last_pusch_slot) > slot:
                                    startprbtabcell[i][totalNbRrcReconf[i]].pop()
                    totalNbRrcReconf[i] += 1
                    start[i] = 0

    results = {"totalNbRrcReconf": totalNbRrcReconf,
               "statusNbRrcReconf": statusNbRrcReconf,
               "startprbtabCell": startprbtabcell,
               "nbreconfsent": nbreconfsent,
               "nbreconfcomplete": nbreconfcomplete,
               }

    return results


# Check PRB Randomization on PUSCH >> Check that the ratio of different startPRB values is > 30% in each RRC reconf
def CheckPrbRandomization_V2(csvPathName, ListofCell):
    """
    """

    if not os.path.exists(csvPathName) or os.path.getsize(csvPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % csvPathName)
        return 0

    nbreconfsent = 0
    nbreconfcomplete = 0

    totalNbRrcReconf = init_tab(x=len(ListofCell))   # Number of RRC Reconfiguration per cell
    statusNbRrcReconf = init_tab(x=len(ListofCell))  # Number of randomization issue during RRC reconfiguration
    start = init_tab(x=len(ListofCell))              # Beginning of an RRC reconfiguration (Transient Phase)

    rnti_rrc = create_tab_for_Cell(x=len(ListofCell))          # Reference RNTI from RRC Reconfiguration
    startprbtabcell = create_tab_for_Cell(x=len(ListofCell))   # Store all start prb for each RRC Reconf for each cells

    last_pusch_sfn = 0
    last_pusch_slot = 0

    with open(csvPathName) as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            for i in range(len(ListofCell)):
                if "RRCReconfiguration" in row['_ws.col.info'] and "DlData" in row['_ws.col.info'] and start[i] == 0:
                    count = ListofCell[i].SubCellId.count(row['3gpp.subcellid'])
                    if count > 0:
                        nbreconfsent += 1
                        reconf = []
                        startprbtabcell[i].append(reconf)
                        start[i] = 1
                        rnti = []
                        rnti_rrc[i].append(rnti)
                        rnti_rrc[i][totalNbRrcReconf[i]] = row['3gpp.rnti']
                if row['_ws.col.info'] == "UlData_PuschReceiveReq" and start[i] == 1:
                    count = ListofCell[i].SubCellId.count(row['3gpp.subcellid'])
                    subcellid = row['3gpp.subcellid']
                    startprb = row['UlData_puschReceiveReqGrant_t.startPrb']
                    rnti = row['3gpp.rnti']
                    sfn = row['3gpp.sfn']
                    slot = row['3gpp.slot']
                    start_split = startprb.split(',')
                    rnti_split = rnti.split(',')
                    for j in range(len(start_split)):
                        if count > 0 and rnti_rrc[i][totalNbRrcReconf[i]] == rnti_split[j]:
                            startprbtabcell[i][totalNbRrcReconf[i]].append(start_split[j])
                if "RRCReconfigurationComplete" in row['_ws.col.info'] and "UlData" in row['_ws.col.info'] \
                        and start[i] >= 1:
                    count = ListofCell[i].SubCellId.count(row['3gpp.subcellid'])
                    rnti = row['3gpp.rnti']
                    subcellid = row['3gpp.subcellid']
                    sfn = row['3gpp.sfn']
                    slot = row['3gpp.slot']
                    nbreconfcomplete += 1
                    if count > 0 and rnti_rrc[i][totalNbRrcReconf[i]] == rnti:
                        total = len(startprbtabcell[i][totalNbRrcReconf[i]])
                        dupli = len(set(startprbtabcell[i][totalNbRrcReconf[i]]))
                        ratio = (dupli/total)*100
                        if ratio < 30:
                            statusNbRrcReconf[i] += 1
                            print("Issue on SubcellId %s with RNTI %s at %s/%s" % (subcellid, rnti, sfn, slot))
                    totalNbRrcReconf[i] += 1
                    start[i] = 0

    results = {"totalNbRrcReconf": totalNbRrcReconf,
               "statusNbRrcReconf": statusNbRrcReconf,
               "startprbtabCell": startprbtabcell,
               "nbreconfsent": nbreconfsent,
               "nbreconfcomplete": nbreconfcomplete,
               }

    return results


# Check PRB Randomization on PUSCH >> Check that all startPRB in all RRC reconf are different for 1 cell
def CheckPrbRandomization_V3(csvPathName, ListofCell):
    """
    """

    if not os.path.exists(csvPathName) or os.path.getsize(csvPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % csvPathName)
        return 0

    nbreconfsent = 0
    nbreconfcomplete = 0

    totalNbRrcReconf = init_tab(x=len(ListofCell))   # Number of RRC Reconfiguration per cell
    statusNbRrcReconf = init_tab(x=len(ListofCell))  # Number of randomization issue during RRC reconfiguration
    start = init_tab(x=len(ListofCell))              # Beginning of an RRC reconfiguration (Transient Phase)

    rnti_rrc = create_tab_for_Cell(x=len(ListofCell))          # Reference RNTI from RRC Reconfiguration
    startprbtabcell = create_tab_for_Cell(x=len(ListofCell))   # Store all start prb for each RRC Reconf for each cells
    startprbglobal = create_tab_for_Cell(x=len(ListofCell))

    last_pusch_sfn = 0
    last_pusch_slot = 0

    with open(csvPathName) as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            for i in range(len(ListofCell)):
                if "RRCReconfiguration" in row['_ws.col.info'] and "DlData" in row['_ws.col.info'] and start[i] == 0:
                    count = ListofCell[i].SubCellId.count(row['3gpp.subcellid'])
                    if count > 0:
                        nbreconfsent += 1
                        reconf = []
                        startprbtabcell[i].append(reconf)
                        start[i] = 1
                        rnti = []
                        rnti_rrc[i].append(rnti)
                        rnti_rrc[i][totalNbRrcReconf[i]] = row['3gpp.rnti']
                if row['_ws.col.info'] == "UlData_PuschReceiveReq" and start[i] == 1:
                    count = ListofCell[i].SubCellId.count(row['3gpp.subcellid'])
                    subcellid = row['3gpp.subcellid']
                    startprb = row['UlData_puschReceiveReqGrant_t.startPrb']
                    rnti = row['3gpp.rnti']
                    sfn = row['3gpp.sfn']
                    slot = row['3gpp.slot']
                    start_split = startprb.split(',')
                    rnti_split = rnti.split(',')
                    for j in range(len(start_split)):
                        if count > 0 and rnti_rrc[i][totalNbRrcReconf[i]] == rnti_split[j]:
                            startprbtabcell[i][totalNbRrcReconf[i]].append(start_split[j])
                            startprbglobal[i].append(start_split[j])
                if "RRCReconfigurationComplete" in row['_ws.col.info'] and "UlData" in row['_ws.col.info'] \
                        and start[i] >= 1:
                    totalNbRrcReconf[i] += 1
                    start[i] = 0

    for i in range(len(ListofCell)):
        total = len(startprbglobal[i])
        dupli = len(set(startprbglobal[i]))
        diff = total - dupli
        if total > 0:
            ratio = (dupli/total)*100
            if ratio < 75:
                statusNbRrcReconf[i] += diff

    results = {"totalNbRrcReconf": totalNbRrcReconf,
               "statusNbRrcReconf": statusNbRrcReconf,
               "startprbtabCell": startprbtabcell,
               "nbreconfsent": nbreconfsent,
               "startprbglobal": startprbglobal,
               }

    return results
