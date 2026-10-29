# Python script used for 8662 AA_13 checks
# Script author : yann.ah.herve@nokia.com
# Script contact: yann.ah.herve@nokia.com
# Creation Date               : 2-August-2022
# Last Modified Date          : 25-September-2022
# Last Modified by            : tomasz.1.godlewski@nokia.com
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
#       06-February-2025    |    CloudRan TCs copied from NPS to WRO_2_4 (regression takeover), whole resources replaced

import math

from taf.analyzer.ttitrace_eventdecoder import TtitraceReader as TtitraceReaderEvtDec


def checkAdaptiveFDDUL(jsonPathName):
    # In UL FDD, as SRS is not handle because of AP UE capabilities, all slots
    # Are of SLIV 27, thus (14-1)*12 = 156 REs per PRBs.
    # 8 PRBs are reserved for PRACH every odd SFN on SFN.1 slots
    UlTddREsPerPrb = 156
    # PRB busy by PRACH
    NbRACHPrbs = 14
    # PRBBusy by PUCCH (may be retrieved from CPRT logs at cellseup if CPRT debug log are enabled)
    PRBBusyPucch = 8

    ReservedMcs = [29, 30, 31]
    targetPct = 95
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
            sfn = ulFdSchedEvents["eventHeader"]["sfn"]
            slot = ulFdSchedEvents["eventHeader"]["slot"]
            rrmUlUsedMcs = ulFdSchedEvents["rrmUlUsedMcs"]
            numOfPrb = ulFdSchedEvents["numOfPrb"]
            sliv = ulFdSchedEvents["SLIV"]
            redundancyVersion = ulFdSchedEvents["redundancyVersion"]
            PRBCandRetx = ulFdSchedEvents["PRBCandRetx"]

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
