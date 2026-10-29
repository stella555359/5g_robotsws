# Python script used for 8662 AA_13 checks
# Script author : yann.ah.herve@nokia.com
# Script contact: yann.ah.herve@nokia.com
# Creation Date               : 2-August-2022
# Last Modified Date          : 25-September-2022
# Last Modified by            : yann.ah.herve@nokia.com
# Modification:
#       10-August-2022      |     Add more debug data
#       10-August-2022      |     Fix bad condition for skipping RV=3
#       9-September-2022    |     Add function for -AD UL checks
#       25-September-2022   |     Add function for -AC UL checks
#       30-September-2022   |     Add case for numCdmGroupNoData=2 (RANK2)
#       05-October-2022     |     Add check about RV3 when rdAdaptiveReTxNackCount == "2"
#       22-Febuary-2023     |     Modifications to take into account ABIP case for checkAdaptiveFDDUL
#       22-Febuary-2023     |     NbRACHPrbsAbio = 8 and NbRACHPrbsAbip = 7
#       22-Febuary-2023     |     PRBBusyAbio = 14 and PRBBusyAbip = 12
#       12-OCtober-2023     |     Remove UL checks related ot Loner (ABIL is outdated now)
#                           |     By looking at ABIP configuration, I now don't see any difference
#                           |     between ABIP and ABIO about PUCCH/PRACH PRBs.
#                           |     So, I have removed the ABIO/ABIP dependency. However I have kept the input
#                           |     board parameter in case of.
#       03-September-2024   |     Update condition to have MCSinitTx because of L2PS updates related
#                           |     to PR779609.
#                           |     Update also TddREsPerFrame to take into account TRS in slots 20,21
#                           |     related to PRB pooling activation by default.
#                           |     Update also SIB/MIB table

import os
import json
import getopt
import sys
import math
from enum import Enum

# TAF Libraries:
from taf.analyzer.ttitrace_eventdecoder import TtitraceReader as TtitraceReaderEvtDec


def checkAdaptiveTDDDL(jsonPathName, rdAdaptiveReTxNackCount):
    """

    """

#
# REs available per slot over a 160 ms (320 slots) period in case BBPooling is enabled
#
# 144 = (13 symbols - 1 symbol for 2 DMRS) x 12 sub-carrier
# 132 = (13 symbols - 1 symbol for 2 DMRS - 1 symbol density 1 for TRS-CA) x 12 sub-carrier
# 126 = (13 symbols - 1 symbol for 2 DMRS - 0.5 symbol density 3 for CSI-RS) x 12 sub-carrier
# 96 = (9 symbols - 1 symbol for 2 DMRS) x 12 sub-carrier
#
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!! IMPORTANT REMARK !!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# TRS and CSI-CA allocation depends on the times attach was done. CSI-CA or TRS slot may change
# over time during attach attempts...
# So, this table is only working just after gNB reset and for first attach
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    TddREsPerFrameWithBBPool = \
        ([[132, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0],
         [138, 138, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0],
         [144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0],
         [144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0],
         [144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0],
         [144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0],
         [144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0],
         [144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0],
         [144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0],
         [138, 138, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0],
         [144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0],
         [144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0],
         [144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0],
         [144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0],
         [144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0],
         [144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0, 144, 144, 144, 96, 0]])

# Number of PRB already booked by SIB or MIB depending on SFN and slot
# 32 PRBs for SSB, 64 PRB for SIBx
    TddPRBSIBMIB = \
        ([[32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]])

    ReservedMcs = [29, 30, 31]
    TddREsPerFrame = TddREsPerFrameWithBBPool
    Qm = 6
    targetPct = 100
    MinPct = 50
    MaxPRB = 273
    RBGSize = 16
    REDelta = 500
    dlHarqProcessTable = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
    PRBMargin = 3
    numOfChecksWithMoreResources = 0
    numOfChecksWithLessResources = 0
    numOfChecksWithSameResources = 0
    numOfReservedMcs = 0
    numOfUnexpectedPRBRBG = 0
    numOfUnexpectedPRBCand = 0
    numOfUnexpectedMCS = 0

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == "dlFdSchedData":
                dlHarqProcessIndex = event.data["dlHarqProcessIndex"]
                # Filter broadcast RNTI
                if event.data["eventHeader"]["rnti"] != 65535:
                    dlHarqProcessTable[dlHarqProcessIndex].append(event.data)

    # TTI trace is processed by HARQ
    for harqProcessId in range(0, 16):
        ndi = 0
        print('Processing HARQ process ID: %s' % harqProcessId)
        for dlFdSchedEvents in dlHarqProcessTable[harqProcessId]:
            # sfn = dlFdSchedEvents["eventHeader"]["onAirTime"]["sfn"]
            sfn = dlFdSchedEvents["eventHeader"]["sfn"]
            # slot = dlFdSchedEvents["eventHeader"]["onAirTime"]["slot"]
            slot = dlFdSchedEvents["eventHeader"]["slot"]
            rrmDlUsedMcs = dlFdSchedEvents["rrmDlUsedMcs"]
            numOfPrb = dlFdSchedEvents["numOfPrb"]
            startPrb = dlFdSchedEvents["startPrb"]
            dlHarqProcessIndex = dlFdSchedEvents["dlHarqProcessIndex"]
            sliv = dlFdSchedEvents["SLIV"]
            redundancyVersion = dlFdSchedEvents["redundancyVersion"]
            tbSize = dlFdSchedEvents["tbSize"]
            PRBCandRetx = dlFdSchedEvents["PRBCandRetx"]
            PRBMinRetx = dlFdSchedEvents["PRBMinRetx"]
            PRBMaxCodeRateRetx = dlFdSchedEvents["PRBMaxCodeRateRetx"]
            adaptRetxStatus = dlFdSchedEvents["adaptRetxStatus"]
            effectiveCodingRate = float(dlFdSchedEvents["effectiveCodeRate"])
            # In case numCdmGroupNoData=2, there is no PDSCH data multiplexed
            # with DMRS. So, 12 (2*6) REs more are missing in this case.
            if dlFdSchedEvents["numCdmGroupNoData"] == 2:
                UnusedREWith2L = 12
            else:
                UnusedREWith2L = 0

            # In case of an initial transmission, we save number of RE and number of PRB
            if redundancyVersion == 0:
                ndi = 1
                McsIni = rrmDlUsedMcs
                # The use of SLIV 53 is related to OSI and book one dedicated PDDCH symbol.
                # So, PDSCH only starts from symbol 2.
                # I don't exactly know when it's used, so add special cases for it:
                if sliv == 53:
                    REIni = 11*12 - UnusedREWith2L
                else:
                    REIni = TddREsPerFrame[sfn % 16][slot] - UnusedREWith2L
                PRBIni = numOfPrb
                effectiveCodingRateIni = effectiveCodingRate
                print("New DL data (RV=0): SFN/slot: %s.%s, RE in slot: %s, MCS: %s, \
num of PRBs: %s, Coding rate: %s" %
                      (sfn, slot, REIni, McsIni, PRBIni, effectiveCodingRate))
            else:
                # Check adaptive retransmission only in case RV=2 or RV=1 and RV=3 only in case
                # HARQ DTX feedback hardening is not delivered (needToCheckRV3 == True)
                if ndi == 1:
                    if (redundancyVersion == 3 and rdAdaptiveReTxNackCount == "0x20"):
                        if (numOfPrb != PRBIni):
                            numOfUnexpectedPRBRBG += 1
                            print("==> To be checked: wrong value for numberOfPrb: %s expected: %s" %
                                  (numOfPrb, PRBIni))
                        if (rrmDlUsedMcs != McsIni):
                            numOfUnexpectedMCS += 1
                            print("==> To be checked: wrong value for MCS: %s expected: %s" %
                                  (rrmDlUsedMcs, McsIni))

                        print("DL retrans with deactivated adaptive retrans: SFN/slot: %s.%s, RV: %s, \
numOfPrb: %s, numOfPrb in TTI: %s, Coding rate: %s" %
                              (sfn, slot, redundancyVersion, rrmDlUsedMcs, numOfPrb, effectiveCodingRateIni))
                    else:
                        if sliv == 53:
                            RERetransPerPRB = 11*12 - UnusedREWith2L
                        elif sliv == 67:
                            RERetransPerPRB = 10*12 - UnusedREWith2L
                        else:
                            RERetransPerPRB = TddREsPerFrame[sfn % 16][slot] - UnusedREWith2L
                        if REIni < RERetransPerPRB:
                            numOfChecksWithMoreResources += 1
                        elif REIni > RERetransPerPRB:
                            numOfChecksWithLessResources += 1
                        else:
                            numOfChecksWithSameResources += 1
                        ExpectedPRBCand = math.ceil((PRBIni*REIni*targetPct)/(RERetransPerPRB*100))
                        # Check number of PRB allocated with a 3 PRB margin
                        if (ExpectedPRBCand > PRBCandRetx + PRBMargin) or (ExpectedPRBCand < PRBCandRetx - PRBMargin):
                            print("==> To be checked: wrong value for PRBCand: %s expected: %s" %
                                  (PRBCandRetx, ExpectedPRBCand))
                            numOfUnexpectedPRBCand += 1

                        # In case the number of needed PRB + number of PRB busy by SSB or SIBx
                        #  exceed the max number of PRB, number of PRB is limited ro maxPRB
                        PRBBusy = TddPRBSIBMIB[sfn % 16][slot]
                        if ExpectedPRBCand + PRBBusy > MaxPRB:
                            ExpectedPRBCand = MaxPRB - PRBBusy

                        # PRB alignment to RBG
                        # PRB alignment to RBG depends on RBG size but also is last RBG is used or not.
                        # It's too complicated to forecast expected values, so I only check
                        # if number of RBG is one of the 4 expected values
                        ExpectedPRBCandRBG_1 = 16*(int(ExpectedPRBCand / RBGSize) + 1)
                        ExpectedPRBCandRBG_2 = 16*int(ExpectedPRBCand / RBGSize)
                        ExpectedPRBCandRBG_3 = 16*int(ExpectedPRBCand / RBGSize) + MaxPRB % RBGSize
                        ExpectedPRBCandRBG_4 = 16*(int(ExpectedPRBCand / RBGSize) + 1) + MaxPRB % RBGSize

                        print("DL retrans: SFN/slot: %s.%s, RV: %s, MCS: %s, REs in slot: %s, PRB busy in slot: %s, \
Expected PRBCand: %s, Expected PRBCandRBG: %s or %s or %s or %s , PRBCand in TTI: %s, \
numOfPrb in TTI: %s, Coding rate: %s" %
                              (sfn, slot, redundancyVersion, rrmDlUsedMcs, RERetransPerPRB, PRBBusy,
                               ExpectedPRBCand,
                               ExpectedPRBCandRBG_1, ExpectedPRBCandRBG_2,
                               ExpectedPRBCandRBG_3, ExpectedPRBCandRBG_4,
                               PRBCandRetx, numOfPrb, effectiveCodingRate))

                        if ((ExpectedPRBCandRBG_1 != numOfPrb) and (ExpectedPRBCandRBG_2 != numOfPrb) and
                                (ExpectedPRBCandRBG_3 != numOfPrb) and (ExpectedPRBCandRBG_4 != numOfPrb)):
                            print("==> To be checked: wrong value for PRBCandRBG")
                            numOfUnexpectedPRBRBG += 1

                        #
                        # Because of changes related to PR779609, initial MCS is used only in case
                        # TBSinit == TBSreTx AND PRBinit == PRBreTx AND CRinit == CRreTx
                        # It's too difficult to check if TBS is the same, so only num of REs between
                        # initial trans and reTx is checked. So, the check may generate a ~1 or 2 % error cases.
                        # If something gets wrong the error ratio will increase and an error will be detected.
                        #
                        # I have added a constraint about the difference of RE between initial and retransmission.
                        # If the RE difference is below REDelta, I don't check the MCS as TBS MAY be the same
                        # because the RE difference is too small...
                        if (((RERetransPerPRB*numOfPrb == REIni*PRBIni) and
                                (numOfPrb == PRBIni) and
                                (effectiveCodingRate == effectiveCodingRateIni) and
                                (rrmDlUsedMcs != McsIni)) or
                                (abs(RERetransPerPRB*numOfPrb - REIni*PRBIni) > REDelta and
                                    (rrmDlUsedMcs not in ReservedMcs))):
                            print("==> To be checked: wrong MCS for retrans")
                            print("RERetransPerPRB: %s, numOfPrb: %s, REIni: %s, PRBIni: %s, \
effectiveCodingRate: %s, effectiveCodingRateIni: %s, \
rrmDlUsedMcs: %s, McsIni: %s" %
                                  (RERetransPerPRB, numOfPrb, REIni, PRBIni, effectiveCodingRate,
                                   effectiveCodingRateIni, rrmDlUsedMcs, McsIni))
                            numOfUnexpectedMCS += 1

                    if (rrmDlUsedMcs in ReservedMcs):
                        numOfReservedMcs += 1

                    if redundancyVersion == 1:
                        ndi = 0

    totalChecks = numOfChecksWithLessResources + numOfChecksWithMoreResources + numOfChecksWithSameResources
    totalErrors = numOfUnexpectedMCS + numOfUnexpectedPRBRBG + numOfUnexpectedPRBCand
    print("Num of check performed with less number of REs as initial transmission: " +
          str(numOfChecksWithLessResources))
    print("Num of check performed with more number of REs as initial transmission: " +
          str(numOfChecksWithMoreResources))
    print("Num of check performed with same number of REs as initial transmission: " +
          str(numOfChecksWithSameResources))
    print("Total number of checks: " + str(totalChecks))
    print("Number of reserved MCS: " + str(numOfReservedMcs))
    print("Number of unexpected MCS: " + str(numOfUnexpectedMCS))
    print("Number of unexpected PRBs: " + str(numOfUnexpectedPRBCand))
    print("Number of unexpected RBGs: " + str(numOfUnexpectedPRBRBG))
    print("Total number of unexpected values: " + str(totalErrors))
    AdaptiveReTxErrorRatio = ((100*totalErrors) / totalChecks)
    print("Error ratio: ==> " + str(AdaptiveReTxErrorRatio) + " % <<=")
    if (numOfChecksWithLessResources == 0 or numOfChecksWithMoreResources == 0 or numOfChecksWithSameResources == 0):
        # Return an error in case some cases are missing.
        AdaptiveReTxErrorRatio = 100

    checksSumUp = {"reservedMcsDetected": numOfReservedMcs,
                   "unexpectedMcsDetected": numOfUnexpectedMCS,
                   "unexpectedPRBDetected": numOfUnexpectedPRBCand,
                   "unexpectedRBGDetected": numOfUnexpectedPRBRBG,
                   "moreResourceChecks": numOfChecksWithMoreResources,
                   "lessResourceChecks": numOfChecksWithLessResources,
                   "sameResourceChecks": numOfChecksWithSameResources,
                   "ErrorRatio": AdaptiveReTxErrorRatio}

    return checksSumUp


def checkAdaptiveFDDUL(jsonPathName, gNBmodemtype):
    """

    """

    # In UL FDD, as SRS is not handle because of AP UE capabilities, all slots
    # Are of SLIV 27, thus (14-1)*12 = 156 REs per PRBs.
    # 8 PRBs are reserved for PRACH every odd SFN on SFN.1 slots
    UlTddREsPerPrb = 156
    # PRB busy by PRACH
    NbRACHPrbs = 14
    # PRBBusy by PUCCH (may be retrieved from CPRT logs at cellseup if CPRT debug log are enabled)
    PRBBusyPucch = 8

    ReservedMcs = [29, 30, 31]
    Qm = 6
    targetPct = 95
    MinPct = 50
    MaxPRB = 106
    ulHarqProcessTable = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
    numOfUlChecks = 0
    numOfUlChecks_in_PRACH_slot = 0
    numOfReservedMcs = 0
    numOfUnexpectedPRBCand = 0
    numOfUnexpectedMCS = 0

    with open(jsonPathName, 'rb') as file_obj:
        for i, event in enumerate(TtitraceReaderEvtDec(file_obj=file_obj)):
            if event.type == "ulFdSchedData":
                ulHarqProcessIndex = event.data["ulHarqProcessIndex"]
                # Filter broadcast RNTI
                if event.data["eventHeader"]["rnti"] != 65535:
                    ulHarqProcessTable[ulHarqProcessIndex].append(event.data)

    # TTI trace is processed by HARQ
    for harqProcessId in range(0, 16):
        ndi = 0
        print('Processing HARQ process ID: %s' % harqProcessId)
        for ulFdSchedEvents in ulHarqProcessTable[harqProcessId]:
            # sfn = ulFdSchedEvents["eventHeader"]["onAirTime"]["sfn"]
            sfn = ulFdSchedEvents["eventHeader"]["sfn"]
            # slot = ulFdSchedEvents["eventHeader"]["onAirTime"]["slot"]
            slot = ulFdSchedEvents["eventHeader"]["slot"]
            rrmUlUsedMcs = ulFdSchedEvents["rrmUlUsedMcs"]
            numOfPrb = ulFdSchedEvents["numOfPrb"]
            startPrb = ulFdSchedEvents["startPrb"]
            ulHarqProcessIndex = ulFdSchedEvents["ulHarqProcessIndex"]
            sliv = ulFdSchedEvents["SLIV"]
            redundancyVersion = ulFdSchedEvents["redundancyVersion"]
            tbSize = ulFdSchedEvents["tbSize"]
            PRBCandRetx = ulFdSchedEvents["PRBCandRetx"]
            PRBMinRetx = ulFdSchedEvents["PRBMinRetx"]
            PRBMaxCodeRateRetx = ulFdSchedEvents["PRBMaxCodeRateRetx"]
            adaptRetxStatus = ulFdSchedEvents["adaptRetxStatus"]

            # In case of an initial transmission, we save number of RE and number of PRB
            if redundancyVersion == 0:
                ndi = 1
                McsIni = rrmUlUsedMcs
                PRBIni = numOfPrb
                print("New UL data (RV=0): SFN/slot: %s.%s, RE in slot: %s, MCS: %s, num of PRBs: %s, SLIV: %s" %
                      (sfn, slot, UlTddREsPerPrb, McsIni, PRBIni, sliv))
            else:
                # Check adaptive retransmission only in case RV=2 or RV=1 and RV=3
                if ndi == 1:
                    numOfUlChecks += 1

                    # In case it's a PRACH slot, PRBs are allocated for PRACH
                    # Otherwise, PRBs are also busy because of PUCCH (same for all slots)
                    PRBBusy = PRBBusyPucch
                    if sfn % 2 == 1 and slot == 1:
                        PRBBusy += NbRACHPrbs
                        numOfUlChecks_in_PRACH_slot += 1
                        print("PRACH slot, PRBBusy is %s " % (PRBBusy))

                    # Same number of REs inside initial and retransmission slots.
                    ExpectedPRBCand = math.ceil((PRBIni*targetPct)/100)
                    # In case the number of needed PRB + number of PRB busy by PRACH
                    #  exceed the max number of PRB, number of PRB is limited to maxPRB
                    if ExpectedPRBCand + PRBBusy > MaxPRB:
                        ExpectedPRBCand = MaxPRB - PRBBusy

                    # Check number of PRB allocated
                    if (ExpectedPRBCand != numOfPrb):
                        print("==> To be checked: wrong value for numOfPrb: %s expected: %s" %
                              (numOfPrb, ExpectedPRBCand))
                        numOfUnexpectedPRBCand += 1

                    print("UL retrans: SFN/slot: %s.%s, RV: %s, MCS: %s, REs in slot: %s, PRB busy in slot: %s, \
Expected PRB: %s, PRBCand in TTI: %s, numOfPrb in TTI: %s, SLIV: %s" %
                          (sfn, slot, redundancyVersion, rrmUlUsedMcs, UlTddREsPerPrb, PRBBusy,
                           ExpectedPRBCand, PRBCandRetx, numOfPrb, sliv))

                    #
                    # Check that reserved MCS is used in case of different number of PRB or RE
                    # and initial MCS is used in case of same number of REs in retransmission slot.
                    #
                    if (((numOfPrb == PRBIni) and (rrmUlUsedMcs != McsIni)) or
                            ((numOfPrb != PRBIni) and (rrmUlUsedMcs not in ReservedMcs))):
                        print("==> To be checked: wrong MCS for retrans")
                        numOfUnexpectedMCS += 1

                    if (rrmUlUsedMcs in ReservedMcs):
                        numOfReservedMcs += 1

                    if redundancyVersion == 1:
                        ndi = 0

    totalChecks = numOfUlChecks
    totalErrors = numOfUnexpectedMCS + numOfUnexpectedPRBCand
    print("Total number of checks: " + str(totalChecks))
    print("Number of check in PRACH slots: " + str(numOfUlChecks_in_PRACH_slot))
    print("Number of reserved MCS: " + str(numOfReservedMcs))
    print("Number of unexpected MCS: " + str(numOfUnexpectedMCS))
    print("Number of unexpected PRBs: " + str(numOfUnexpectedPRBCand))
    print("Total number of unexpected values: " + str(totalErrors))
    AdaptiveReTxErrorRatio = ((100*totalErrors) / totalChecks)
    print("Error ratio: ==> " + str(AdaptiveReTxErrorRatio) + " % <<=")
    if (numOfUlChecks == 0):
        # Return an error in case some cases are missing.
        AdaptiveReTxErrorRatio = 100

    checksSumUp = {"reservedMcsDetected": numOfReservedMcs,
                   "unexpectedMcsDetected": numOfUnexpectedMCS,
                   "unexpectedPRBDetected": numOfUnexpectedPRBCand,
                   "ErrorRatio": AdaptiveReTxErrorRatio}

    return checksSumUp
