import os
import json
import getopt
import sys
from enum import Enum

# TAF Libraries:
from taf.analyzer.ttitrace_eventdecoder import TtitraceReader as TtitraceReaderEvtDec


# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

firstSlots_1116_0ms = [4, 14]
firstSlots_1116_3ms = [8, 18]
firstSlots_1070 = [4, 8, 14, 18]


def getUeUlSchedulingSlots(jsonPathName, frameStruct, RNTI=65535):
    """
    Compute the number of first Tx ans re-Tx in first and second UL slots according to the frame structure
    Input parameters:
      jsonPathName: json file of the TTI trace
      frameStruct: string 1116_0ms, 1116_3ms or 1070
      RNTI: UE RNTI to check (default value 65535: all UL scheduling are taken into account)
    Returned following values:
      - nb of 1st Tx using 1st Slot
      - nb of reTx using 1st Slot
      - nb of 1st Tx using 2nd Slot
      - nb of ReTx using 2nd Slot
    Return -1 for all in case of error
    """
    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        return -1, -1, -1, -1

    if frameStruct == "1116_0ms":
        FirstSlots = firstSlots_1116_0ms
    elif frameStruct == "1116_3ms":
        FirstSlots = firstSlots_1116_3ms
    elif frameStruct == "1070":
        FirstSlots = firstSlots_1070
    else:
        print("TTI trace ERROR: wrong frameStruct parameter %s, expected 1116_0ms or 1116_3ms"
              % frameStruct)
        return -1, -1, -1, -1

    RNTI = int(RNTI)

    nbMsg = 0
    ulFdSchedData = 0
    nb1stTx1stSlot = 0
    nb1stTx2ndSlot = 0
    nbReTx1stSlot = 0
    nbReTx2ndSlot = 0

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            nbMsg = nbMsg+1
            RNTIsched = event.data["eventHeader"]["rnti"]
            if event.type == "ulFdSchedData" and (RNTI == 65535 or RNTI == RNTIsched):
                ulFdSchedData = ulFdSchedData+1
                SFN = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                txNumber = event.data["txNumber"]

                # Some fields of ulFdSchedData could be invalid, then continue
                if txNumber == 255:
                    continue

                if slot in FirstSlots:
                    if txNumber == 1:
                        nb1stTx1stSlot = nb1stTx1stSlot+1
                    else:
                        nbReTx1stSlot = nbReTx1stSlot+1
                else:
                    if txNumber == 1:
                        nb1stTx2ndSlot = nb1stTx2ndSlot+1
                    else:
                        nbReTx2ndSlot = nbReTx2ndSlot+1

    return nb1stTx1stSlot, nbReTx1stSlot, nb1stTx2ndSlot, nbReTx2ndSlot


def checkATB_HRUE_B02_004(jsonPathName, smallestMcsATBLowSE=6):
    """
    Check the ATB behaviour according to the TC B02-004
    Input parameters:
      jsonPathName: json file of the TTI trace
      smallestMcsATBLowSE: RD param rdSmallestMcsATBLowSEValue value used (default value 6)
    Returned value:
      - 0 in case of error found, else above 0
    """
    if not os.path.exists(jsonPathName) or os.path.getsize(jsonPathName) <= 24:
        print("TTI trace ERROR: %s doesn't exist or size <= 24" % jsonPathName)
        return 0

    smallestMcsATBLowSE = int(smallestMcsATBLowSE)

    nbMsg = 0
    nbCheckBlerType = 0
    nbCheckSchedul = 0
    nbPrbLowMcs = [4, 8, 14]

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            nbMsg = nbMsg+1
            RNTIsched = event.data["eventHeader"]["rnti"]
            if event.type == "ulLaDeltaSinr":
                targetBlerType = event.data["targetBlerType"]
                if targetBlerType != "HIGHRELIABLE" and targetBlerType != "OFF":
                    SFN = event.data["eventHeader"]["sfn"]
                    slot = event.data["eventHeader"]["slot"]
                    print("TTI ERROR: targetBlerType %s at SFN %s, slot %s (expected HIGHRELIABLE or OFF)"
                          % (targetBlerType, SFN, slot))
                    return 0
                nbCheckBlerType = nbCheckBlerType+1
            elif event.type == "ulFdSchedData":
                # Some fields of ulFdSchedData could be invalid, then continue
                txNumber = event.data["txNumber"]
                if txNumber == 255:
                    continue

                SFN = event.data["eventHeader"]["sfn"]
                slot = event.data["eventHeader"]["slot"]
                mcsTable = event.data["mcsTable"]
                if mcsTable != "QAM64LOWSE":
                    print("TTI ERROR: mcsTable %s at SFN %s, slot %s (expected QAM64LOWSE)"
                          % (targetBlerType, SFN, slot))
                    return 0

                rrmUlProposedMcs = event.data["rrmUlProposedMcs"]
                if txNumber == 1:
                    numOfPrb = event.data["numOfPrb"]
                    if rrmUlProposedMcs < smallestMcsATBLowSE and numOfPrb not in nbPrbLowMcs:
                        print("TTI ERROR: numOfPrb %s at SFN %s, slot %s (expected %s)"
                              % (numOfPrb, SFN, slot, nbPrbLowMcs))
                        return 0
                else:
                    # Jing.T 30/10/25: changement suite à actAdaptiveReTxResMcs s'active par defaut
                    # if rrmUlProposedMcs != 0 and rrmUlProposedMcs != 255:
                    if rrmUlProposedMcs != 0 and rrmUlProposedMcs != 255 and rrmUlProposedMcs < 29:
                        print("TTI ERROR: rrmUlProposedMcs %s at SFN %s, slot %s (expected 0 or 255)"
                              % (rrmUlProposedMcs, SFN, slot))
                        return 0
                nbCheckSchedul = nbCheckSchedul+1

    return nbCheckBlerType * nbCheckSchedul
