import re
import os
import datetime


def checkPrachRecReqIE(l1l2_file, prachConfig_file, result_file, prachConfigIndex):
    # Index in L1L2 post processing file
    prachRecReqSfn = 1
    prachRecReqSlot = 2
    prachRecReqOcca = 3
    prachRecIndSfn = 4
    prachRecIndSlot = 5
    prachRecIndNoisePwr = 6
    prachRecIndPreambleLength = 7
    prachRecIndPreambleIdx = 8
    prachRecIndPreambleTimeOcc = 9
    prachRecIndInitTA = 10
    prachRecIndPeakMetric = 11

    l1l2_file_obj = open(l1l2_file, 'r')
    prachConfig_file_obj = open(prachConfig_file, 'r')
    result_file_obj = open(result_file, 'a')

    prachSfn = {}
    prachSlot = {}
    prachRecIndTestStatus = 'PASSED'
    prachRecInd = False
    prachSlotUsed = []

    result_file_obj.write("\n\n------------------------------------------")
    result_file_obj.write("\nL1L2 Analysis Prach Received Request\n")

    # Read from prachconfig file, the execpted PRACH sfn slot for each defined prach configuration
    # Result is stored in prachSlot tab
    buffer_in = prachConfig_file_obj.readline()  # Saute la 1ere ligne
    while 1:
        buffer_in = prachConfig_file_obj.readline()
        if buffer_in == "":
            break
        line = buffer_in.split(":")

        prachSlot[line[0]] = []
        for i in range(len(line[2].split(","))):
            prachSlot[line[0]].append(int(line[2].split(",")[i]))
        prachSfn[line[0]] = []
        for i in range(len(line[1].split(","))):
            prachSfn[line[0]].append(int(line[1].split(",")[i]))

    if not (prachConfigIndex in prachSlot):
        result_file_obj.write("\n\tprachConfigurationIndex not in prachConfigurationIndex able\n")
        prachRecIndTestStatus = 'FAILED'
        return prachRecIndTestStatus

    result_file_obj.write("\n\tPrach Expected sfn: " + str(prachSfn[prachConfigIndex][0]) + " MOD " +
                          str(prachSfn[prachConfigIndex][1]) + "\n")
    if len(prachSfn[prachConfigIndex]) == 3:
        result_file_obj.write("\n\tPrach Expected sfn: " + str(prachSfn[prachConfigIndex][0]) + " MOD " +
                              str(prachSfn[prachConfigIndex][2]) + "\n")

    result_file_obj.write("\tPrach Expected slot: " + str(prachSlot[prachConfigIndex]) + "\n")

    while 1:
        buffer_in = l1l2_file_obj.readline()
        if buffer_in == "":
            break
        line = buffer_in.replace("\n", "").split(";")

        if line[0].find("UlData_PrachReceiveReq") != -1:

            prachRecInd = True

            prachSfnCur = int(line[prachRecReqSfn], 16)
            prachSlotCur = int(line[prachRecReqSlot], 16)

            if (len(prachSfn[prachConfigIndex]) == 2 and
                prachSfnCur % prachSfn[prachConfigIndex][0] != prachSfn[prachConfigIndex][1]) or \
                    (len(prachSfn[prachConfigIndex]) == 3 and
                     prachSfnCur % prachSfn[prachConfigIndex][0] != prachSfn[prachConfigIndex][1] and
                     prachSfnCur % prachSfn[prachConfigIndex][0] != prachSfn[prachConfigIndex][2]):
                result_file_obj.write("\n\tSFN Not Expected In prachReveiveReq \n")
                prachRecIndTestStatus = 'FAILED'
            try:
                prachSlot[prachConfigIndex].index(prachSlotCur)
            except ValueError:
                result_file_obj.write("\n\tSlot Not Expected In prach"
                                      "ReveiveReq: " + str(prachSlotCur) + "\n")
                prachRecIndTestStatus = 'FAILED'

            # Add in list prachSlotUsed slot found in prachRecReq
            try:
                prachSlotUsed.index(prachSlotCur)
            except ValueError:
                prachSlotUsed.append(prachSlotCur)

            if prachRecIndTestStatus == 'FAILED':
                return prachRecIndTestStatus

    if prachRecInd:
        for slotKey in prachSlot[prachConfigIndex]:
            try:
                prachSlotUsed.index(slotKey)
            except ValueError:
                result_file_obj.write("\n\tWARNING: Slot defined in prachConfig Table NOT USED: " + str(slotKey))
                prachRecIndTestStatus = 'PASSED'
        if prachRecIndTestStatus == 'PASSED':
            result_file_obj.write("\n\tNo errror in prachReveiveReq\n")
    else:
        result_file_obj.write("\n\tNo prachReveiveReq in traces\n")
        prachRecIndTestStatus = 'FAILED'
    return prachRecIndTestStatus


def checkPrachRecInd(l1l2_file, prachConfig_file, result_file, prachConfigIndex):
    # Index in L1L2 post processing file
    prachRecReqSfn = 1
    prachRecReqSlot = 2
    prachRecReqOcca = 3
    prachRecIndSfn = 4
    prachRecIndSlot = 5
    prachRecIndNoisePwr = 6
    prachRecIndPreambleLength = 7
    prachRecIndPreambleIdx = 8
    prachRecIndPreambleTimeOcc = 9
    prachRecIndInitTA = 10
    prachRecIndPeakMetric = 11

    l1l2_file_obj = open(l1l2_file, 'r')
    prachConfig_file_obj = open(prachConfig_file, 'r')
    result_file_obj = open(result_file, 'a')

    prachSfn = {}
    prachSlot = {}
    prachRecIndTestStatus = 'PASSED'

    result_file_obj.write("\n\n------------------------------------------")
    result_file_obj.write("\nL1L2 Analysis Prach Received Indication\n")

    # Read from prachconfig file, the execpted PRACH sfn slot for each defined prach configuration
    # Result is stored in prachSlot tab
    buffer_in = prachConfig_file_obj.readline()  # Saute la 1ere ligne
    while 1:
        buffer_in = prachConfig_file_obj.readline()
        if buffer_in == "":
            break
        line = buffer_in.split(":")

        prachSlot[line[0]] = []
        for i in range(len(line[2].split(","))):
            prachSlot[line[0]].append(int(line[2].split(",")[i]))
        prachSfn[line[0]] = []
        for i in range(len(line[1].split(","))):
            prachSfn[line[0]].append(int(line[1].split(",")[i]))

    if not (prachConfigIndex in prachSlot):

        result_file_obj.write("\n\tprachConfigurationIndex not in prachConfigurationIndex Table \n")
        prachRecIndTestStatus = 'FAILED'
        return prachRecIndTestStatus

    result_file_obj.write("\n\tPrach Expected sfn: " + str(prachSfn[prachConfigIndex][0]) + " MOD " +
                          str(prachSfn[prachConfigIndex][1]) + "\n")

    if len(prachSfn[prachConfigIndex]) == 3:
        result_file_obj.write("\n\tPrach Expected sfn: " + str(prachSfn[prachConfigIndex][0]) + " MOD " +
                              str(prachSfn[prachConfigIndex][2]) + "\n")

    result_file_obj.write("\tPrach Expected slot: " + str(prachSlot[prachConfigIndex]) + "\n")

    while 1:
        buffer_in = l1l2_file_obj.readline()
        if buffer_in == "":
            break
        line = buffer_in.replace("\n", "").split(";")

        if line[0].find("UlData_PrachReceiveInd") != -1:

            prachSfnCur = int(line[prachRecIndSfn], 16)
            prachSlotCur = int(line[prachRecIndSlot], 16)

            if (len(prachSfn[prachConfigIndex]) == 2 and
                prachSfnCur % prachSfn[prachConfigIndex][0] != prachSfn[prachConfigIndex][1]) or \
                    (len(prachSfn[prachConfigIndex]) == 3 and
                     prachSfnCur % prachSfn[prachConfigIndex][0] != prachSfn[prachConfigIndex][1] and
                     prachSfnCur % prachSfn[prachConfigIndex][0] != prachSfn[prachConfigIndex][2]):
                result_file_obj.write("\n\tSFN Not Expected In prachReveiveInd \n")
                prachRecIndTestStatus = 'FAILED'

            try:
                prachSlot[prachConfigIndex].index(prachSlotCur)
            except ValueError:
                result_file_obj.write("\n\tSlot Not Expected in prachReveiveInd: " + str(prachSlotCur) + "\n")
                prachRecIndTestStatus = 'FAILED'

            if prachRecIndTestStatus == 'FAILED':
                return prachRecIndTestStatus

            noisePwrVal = line[prachRecIndNoisePwr]
            nbPreambles = int(line[prachRecIndPreambleLength], 16)
            preambleIdxVal = line[prachRecIndPreambleIdx].split(',')
            premableTimeOccVal = line[prachRecIndPreambleTimeOcc].split(',')
            initTAVal = line[prachRecIndInitTA].split(',')
            peakMetricVal = line[prachRecIndPeakMetric].split(',')

            result_file_obj.write("\n\tSFN:" + str(prachSfnCur) + ", Slot:" + str(prachSlotCur) +
                                  ", Number of Preambles:" + str(nbPreambles) + ", Noise Power:" + str(noisePwrVal))
            for i in range(nbPreambles):
                result_file_obj.write("\n\t\tPreamble Index:" + str(int(preambleIdxVal[i], 16)) + ", initialTA:" +
                                      str(int(initTAVal[i], 16)) + ",Peak Metric:" + str((peakMetricVal[i])) + "\n")

    return prachRecIndTestStatus


def checkBeamId(l1l2_file, result_file, beamToCheck):
    # Index in L1L2 post processing file
    prachRecReqSfn = 1
    prachRecReqSlot = 2
    prachRecReqOcca = 3
    prachRecIndSfn = 4
    prachRecIndSlot = 5
    prachRecIndNoisePwr = 6
    prachRecIndPreambleLength = 7
    prachRecIndPreambleIdx = 8
    prachRecIndPreambleTimeOcc = 9
    prachRecIndInitTA = 10
    prachRecIndPeakMetric = 11
    pdcchSfn = 12
    pdcchSlot = 13
    pdcchBeamId = 14

    l1l2_file_obj = open(l1l2_file, 'r')
    result_file_obj = open(result_file, 'a')

    prachRecIndStatus = False
    prachRecIndNb = 0
    beamCheckStatus = 'PASSED'

    result_file_obj.write("\n\n------------------------------------------")
    result_file_obj.write("\nL1L2 Analysis Beam Check\n")

    while 1:
        buffer_in = l1l2_file_obj.readline()
        if buffer_in == "":
            break
        line = buffer_in.replace("\n", "").split(";")

        if line[0].find("UlData_PrachReceiveInd") != -1:

            prachRecIndStatus = True
            prachRecIndNb = prachRecIndNb + 1
            prachSfnCur = int(line[prachRecIndSfn], 16)
            prachSlotCur = int(line[prachRecIndSlot], 16)

            noisePwrVal = line[prachRecIndNoisePwr]
            nbPreambles = int(line[prachRecIndPreambleLength], 16)
            preambleIdxVal = line[prachRecIndPreambleIdx].split(',')
            premableTimeOccVal = line[prachRecIndPreambleTimeOcc].split(',')
            initTAVal = line[prachRecIndInitTA].split(',')
            peakMetricVal = line[prachRecIndPeakMetric].split(',')

            result_file_obj.write("\n\tPRACH - SFN:" + str(prachSfnCur) + ", Slot:" + str(prachSlotCur) +
                                  ", Number of Preambles:" + str(nbPreambles) + ", Noise Power:" + str(noisePwrVal))
            for i in range(nbPreambles):
                result_file_obj.write("\n\t\tPreamble Index:" + str(int(preambleIdxVal[i], 16)) + ", initialTA:" +
                                      str(int(initTAVal[i], 16)) + ",Peak Metric:" + str((peakMetricVal[i])) + "\n")

        if line[0].find("DlData_PdcchSendReq") != -1 and prachRecIndStatus:
            pdcchSfnCur = int(line[pdcchSfn], 16)
            pdcchSlotCur = int(line[pdcchSlot], 16)
            beamId = int(line[pdcchBeamId], 16)
            result_file_obj.write("\n\tPDCCH - SFN:" + str(pdcchSfnCur) + ", Slot:" + str(pdcchSlotCur) +
                                  ", BeamId:" + str(beamId))
            if beamToCheck != beamId:
                result_file_obj.write("\n\tBeam check: FAILED\n")
                beamCheckStatus = "FAILED"
            else:
                result_file_obj.write("\n\tBeam check: PASSED\n")
            prachRecIndStatus = False

    if prachRecIndNb > 1:
        result_file_obj.write("\n\tBeam check failed: several prachReceiveInd Msg")
        beamCheckStatus = "FAILED"

    return beamCheckStatus
