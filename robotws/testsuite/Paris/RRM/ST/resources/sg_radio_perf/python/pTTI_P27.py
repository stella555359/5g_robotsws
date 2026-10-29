# -*- coding: utf-8 -*-

import re
import os
import sys
from datetime import datetime
import argparse
from math import log10


def dBm2W(dBm):
    return 10 ** ((dBm - 30) / 10.)


def W2dBm(W):
    res = 0
    try:
        res = 30+(10.*log10(W))
    except ValueError as e:
        if W != 0:
            print('Error : W2dBm ==> W={:8.3f}'.format(W))
    return res


SFN_MAX = 1024
TS_MAX = 20.
TIME_PERIOD = 10.

SupportedEventsTTIdl = ['dlFdSchedData', 'dlLaDeltaCqi', 'dlLaAverageCqi']
SupportedEventsTTIul = ['ulFdSchedData', 'ulLaAverageSinr',
                        'ulLaDeltaSinr', 'ulPuschReceiveRespPsData']
SupportedEventsTTI = SupportedEventsTTIdl + SupportedEventsTTIul
Supported5GRel = ['5G19B', '5G20A']

DicoOffsetFiledsDLUL = {
    'dlFdSchedData': {
        'rnti': -1, 'sfn': -1, 'slot': -1, 'rrmDlUsedMcs': -1, 'tbSize': -1, 'txNumber': -1, 'dlHarqProcessIndex': -1,
        'numOfLayers': -1, 'numOfPrb': -1, 'rrmCorrAvgCqi': -1
    },
    'dlLaAverageCqi': {'rnti': -1, 'sfn': -1, 'slot': -1, 'rrmAvgCqi': -1, 'rrmInstCqi': -1},
    'dlLaDeltaCqi': {'rnti': -1, 'sfn': -1, 'slot': -1, 'isDeltaCqiCalculated': -1, 'harqFb': -1},
    'ulFdSchedData': {
        'rnti': -1, 'sfn': -1, 'slot': -1, 'rrmUlUsedMcs': -1, 'tbSize': -1, 'txNumber': -1, 'ulHarqProcessIndex': -1,
        'numOfLayers': -1, 'numOfPrb': -1
    },
    'ulLaAverageSinr': {'rnti': -1, 'sfn': -1, 'slot': -1, 'rrmAvgSinrUl': -1, 'rrmInstSinr': -1},
    'ulLaDeltaSinr': {'rnti': -1, 'sfn': -1, 'slot': -1, 'rrmDeltaSinr': -1, 'isDeltaSinrCalculated': -1, 'crcFb': -1},
    'ulPuschReceiveRespPsData': {'rnti': -1, 'sfn': -1, 'slot': -1, 'rssi': -1}}


class ResultTracesTTIdlul():
    def __init__(self):
        self.fileName = ""
        self.ave_initTargBlergNB_DL = 0.0
        self.ave_initBlergNB_DL = 0.0
        self.ave_Bler_DL = 0.0
        self.traceDuration_DL = 0
        self.tputVolL1Harq_DL = 0.0
        self.tputVolL1AppHarq_DL = 0.0
        self.tputL1Harq_DL = 0.0
        self.tputL1AppHarq_DL = 0.0
        self.ave_numOfPrb_DL = 0.0
        self.ave_rrmCorrAvgCqi_DL = 0.0
        self.ave_rrmInstCqi_DL = 0.0
        self.ave_rrmInstSinr = 0.0
        self.ave_rrmAvgSinrUl = 0.0
        self.ave_rssi = 0.0
        self.ave_mcsUsed_UL = 0.0
        self.ave_initTargBlergNB_UL = 0.0
        self.ave_initBlergNB_UL = 0.0
        self.ave_Bler_UL = 0.0
        self.ave_rrmDeltaSinr = 0.0
        self.ave_correctedSinr = 0.0
        self.ave_numOfPrb_UL = 0.0
        self.ave_allLayers_UL = 0.0
        self.ave_byLayer_UL = 5*[0.0]
        self.traceDuration_UL = 0
        self.tputL1Harq_UL = 0.0
        self.tputL1AppHarq_UL = 0.0
        self.tputVolL1Harq_UL = 0.0
        self.tputVolL1AppHarq_UL = 0.0
        self.DL = {}
        self.creerObjetDicoDL = {
            'dlFdSchedData':  DlFdSchedData,
            'dlLaAverageCqi':  DlLaAverageCqi,
            'dlLaDeltaCqi':    DlLaDeltaCqi
        }
        self.RNTIused_DL = []
        self.UL = {}
        self.creerObjetDicoUL = {
            'ulFdSchedData':   UlFdSchedData,
            'ulLaAverageSinr': UlLaAverageSinr,
            'ulLaDeltaSinr':   UlLaDeltaSinr,
            'ulPuschReceiveRespPsData': UlPuschReceiveRespPsData
        }
        self.RNTIused_UL = []

    def initialise(self, fileName):
        self.initResult(fileName)
        self.DL = {}
        self.RNTIused_DL = []
        self.UL = {}
        self.RNTIused_UL = []

    def initResult(self, fileName):
        self.fileName = fileName
        self.ave_initTargBlergNB_DL = 0.0
        self.ave_initBlergNB_DL = 0.0
        self.ave_Bler_DL = 0.0
        self.traceDuration_DL = 0
        self.tputVolL1Harq_DL = 0.0
        self.tputVolL1AppHarq_DL = 0.0
        self.tputL1Harq_DL = 0.0
        self.tputL1AppHarq_DL = 0.0
        self.ave_numOfPrb_DL = 0.0
        self.ave_rrmCorrAvgCqi_DL = 0.0
        self.ave_rrmInstSinr = 0.0
        self.ave_rrmAvgSinrUl = 0.0
        self.ave_rssi = 0.0
        self.ave_mcsUsed_UL = 0.0
        self.ave_initTargBlergNB_UL = 0.0
        self.ave_initBlergNB_UL = 0.0
        self.ave_Bler_UL = 0.0
        self.ave_rrmDeltaSinr = 0.0
        self.ave_correctedSinr = 0.0
        self.ave_numOfPrb_UL = 0.0
        self.ave_allLayers_UL = 0.0
        self.ave_byLayer_UL = 5*[0.0]
        self.traceDuration_UL = 0
        self.tputL1Harq_UL = 0.0
        self.tputL1AppHarq_UL = 0.0
        self.tputVolL1Harq_UL = 0.0
        self.tputVolL1AppHarq_UL = 0.0

    def formatRecapDL(self, RNTI):
        tmpStrDL = ''
        tmpStrDL += ';' + str('%0.3f' %
                              self.ave_initTargBlergNB_DL).replace('.', ',')
        tmpStrDL += ';' + str('%0.3f' %
                              self.ave_initBlergNB_DL).replace('.', ',')
        tmpStrDL += ';' + str('%0.3f' % self.ave_Bler_DL).replace('.', ',')
        tmpStrDL += ';' + str('%0.3f' %
                              self.tputL1AppHarq_DL).replace('.', ',')
        tmpStrDL += ';' + str('%0.3f' % self.tputL1Harq_DL).replace('.', ',')
        tmpStrDL += ';' + str('%0.3f' % self.ave_numOfPrb_DL).replace('.', ',')
        tmpStrDL += ';' + str('%0.3f' %
                              self.ave_rrmCorrAvgCqi_DL).replace('.', ',')
        tmpStrDL += ';' + str(RNTI)

        return (tmpStrDL)

    def formatRecapUL(self, RNTI):
        tmpStrUL = ''
        tmpStrUL += ';' + str('%0.3f' % self.ave_rrmInstSinr).replace('.', ',')
        tmpAve_correctedSinr = W2dBm(self.ave_correctedSinr)
        tmpStrUL += ';' + str('%0.3f' % tmpAve_correctedSinr).replace('.', ',')
        tmpStrUL += ';' + str('%0.3f' % self.ave_rssi).replace('.', ',')
        tmpStrUL += ';' + str('%0.3f' % self.ave_mcsUsed_UL).replace('.', ',')
        tmpStrUL += ';' + str('%0.3f' %
                              self.ave_initTargBlergNB_UL).replace('.', ',')
        tmpStrUL += ';' + str('%0.3f' %
                              self.ave_initBlergNB_UL).replace('.', ',')
        tmpStrUL += ';' + str('%0.3f' % self.ave_Bler_UL).replace('.', ',')
        tmpStrUL += ';' + str(self.ave_allLayers_UL).replace('.', ',')
        for i in range(1, 5):
            tmpStrUL += ';' + str('%0.3f' %
                                  self.ave_byLayer_UL[i]).replace('.', ',')
        tmpStrUL += ';' + str('%0.3f' %
                              self.tputL1AppHarq_UL).replace('.', ',')
        tmpStrUL += ';' + str('%0.3f' % self.tputL1Harq_UL).replace('.', ',')
        tmpStrUL += ';' + str('%0.3f' % self.ave_numOfPrb_UL).replace('.', ',')
        tmpStrUL += ';' + str(RNTI)

        return (tmpStrUL)


class TraceTTIdlul(object):
    numberOfEvents = 0

    def initialise():
        TraceTTIdlul.numberOfEvents = 0

    def __init__(self, event='', fileNameTrace=''):
        TraceTTIdlul.numberOfEvents += 1
        self.event = event
        self.fileNameTrace = fileNameTrace
        self.numberTracesEvent = 0

    def parseLine(self):
        self.updateTraceNumberEvent()

    def ave(self, sumVal):
        return average(sumVal, self.numberTracesEvent)

    def calculer(self):
        pass

    def updateTraceNumberEvent(self):
        self.numberTracesEvent += 1


class DlFdSchedData(TraceTTIdlul):
    def __init__(self, *args, **kwargs):
        TraceTTIdlul.__init__(self, *args, **kwargs)
        self.SFNFirst = -1
        self.SFNLast = -1
        self.SFNPrev = -1
        self.NbSFN1024 = 0
        self.SLOTFirst = -1
        self.SLOTLast = -1
        self.traceDurationEvent = 0
        self.txNumber = 6*[0]
        self.harqProcessIndexVolL1 = 16*[0]
        self.harqProcessIndexVolL1App = 16*[0]
        self.harqProcessIndexLastTbs = 16*[0]
        self.numOfPrb = 0
        self.rrmCorrAvgCqi = 0.0

    def parseLine(self, nbParam2, eventParamL):
        TraceTTIdlul.parseLine(self)

        tmpSfn = int(getParamValue(
            'sfn', 'dlFdSchedData', nbParam2, eventParamL))
        self.SFNPrev = self.SFNLast
        self.SFNLast = tmpSfn
        if (self.SFNFirst == -1):
            self.SFNFirst = self.SFNLast
            self.SFNPrev = self.SFNLast
        elif (self.SFNLast < self.SFNPrev):
            self.NbSFN1024 += 1

        tmpSlot = int(getParamValue(
            'slot', 'dlFdSchedData', nbParam2, eventParamL))
        self.SLOTLast = tmpSlot
        if (self.SLOTFirst == -1):
            self.SLOTFirst = self.SLOTLast

        tmpTbSize = int(getParamValue(
            'tbSize', 'dlFdSchedData', nbParam2, eventParamL))

        tmpTxNumber = int(getParamValue(
            'txNumber', 'dlFdSchedData', nbParam2, eventParamL))
        self.txNumber[tmpTxNumber] += 1

        tmpHrqIndex = int(getParamValue('dlHarqProcessIndex',
                          'dlFdSchedData', nbParam2, eventParamL))
        if (tmpTxNumber == 1):
            self.harqProcessIndexVolL1[tmpHrqIndex] += tmpTbSize
            self.harqProcessIndexVolL1App[tmpHrqIndex] += tmpTbSize
            self.harqProcessIndexLastTbs[tmpHrqIndex] = tmpTbSize
        else:
            self.harqProcessIndexVolL1[tmpHrqIndex] += self.harqProcessIndexLastTbs[tmpHrqIndex]

        tmpNumOfPrb = int(getParamValue(
            'numOfPrb', 'dlFdSchedData', nbParam2, eventParamL))
        self.numOfPrb += tmpNumOfPrb

        tmpRrmCorrAvgCqi = float(getParamValue(
            'rrmCorrAvgCqi', 'dlFdSchedData', nbParam2, eventParamL))
        self.rrmCorrAvgCqi += tmpRrmCorrAvgCqi

    def calculer(self):
        TraceTTIdlul.calculer(self)

        if self.txNumber[1]:
            resultDLUL.ave_initBlergNB_DL = average(
                (self.txNumber[2]*100), self.txNumber[1])
        else:
            resultDLUL.ave_initBlergNB_DL = 100.
            print('Initial UL  Bler(gNB side) can\'t by calculated TX1 = 0')

        resultDLUL.ave_numOfPrb_DL = self.ave(self.numOfPrb)

        traceDurationSFN = ((SFN_MAX * self.NbSFN1024) -
                            self.SFNFirst + self.SFNLast) * TIME_PERIOD
        traceDurationTS = int(
            ((self.SLOTLast - self.SLOTFirst) * TIME_PERIOD) / TS_MAX)
        self.traceDurationEvent = int(traceDurationSFN + traceDurationTS)
        resultDLUL.traceDuration_DL = self.traceDurationEvent

        for i in range(0, 16):
            resultDLUL.tputVolL1Harq_DL += self.harqProcessIndexVolL1[i]
            resultDLUL.tputVolL1AppHarq_DL += self.harqProcessIndexVolL1App[i]
        resultDLUL.tputL1AppHarq_DL = average(
            resultDLUL.tputVolL1AppHarq_DL, (resultDLUL.traceDuration_DL*1000.))
        resultDLUL.tputL1Harq_DL = average(
            resultDLUL.tputVolL1Harq_DL, (resultDLUL.traceDuration_DL*1000.))

        resultDLUL.ave_rrmCorrAvgCqi_DL = self.ave(self.rrmCorrAvgCqi)


class DlLaAverageCqi(TraceTTIdlul):
    def __init__(self, *args, **kwargs):
        TraceTTIdlul.__init__(self, *args, **kwargs)
        self.rrmInstCqi = 0.0

    def parseLine(self, nbParam2, eventParamL):
        TraceTTIdlul.parseLine(self)
        tmpSfn = int(getParamValue(
            'sfn', 'dlLaAverageCqi', nbParam2, eventParamL))
        tmpSlot = int(getParamValue(
            'slot', 'dlLaAverageCqi', nbParam2, eventParamL))
        tmpRrmInstCqi = float(getParamValue(
            'rrmInstCqi', 'dlLaAverageCqi', nbParam2, eventParamL))
        self.rrmInstCqi += tmpRrmInstCqi

    def calculer(self):
        TraceTTIdlul.calculer(self)
        resultDLUL.ave_rrmInstCqi_DL = self.ave(self.rrmInstCqi)


class DlLaDeltaCqi(TraceTTIdlul):
    def __init__(self, *args, **kwargs):
        TraceTTIdlul.__init__(self, *args, **kwargs)
        self.rrmDeltaCqi = 0.0
        self.isDeltaCqiCalculated = 0
        self.harqFbACK = 2*[0]
        self.harqFbNACK = 2*[0]
        self.harqFbDTX = 2*[0]
        self.harqFbMISC = 2*[0]

    def parseLine(self, nbParam2, eventParamL):
        TraceTTIdlul.parseLine(self)
        tmpSfn = int(getParamValue(
            'sfn', 'dlLaDeltaCqi', nbParam2, eventParamL))

        tmpSlot = int(getParamValue(
            'slot', 'dlLaDeltaCqi', nbParam2, eventParamL))

        tmpIsDeltaCqiCalculated = int(getParamValue(
            'isDeltaCqiCalculated', 'dlLaDeltaCqi', nbParam2, eventParamL))
        self.isDeltaCqiCalculated += tmpIsDeltaCqiCalculated

        tmpHarqFb = getParamValue(
            'harqFb', 'dlLaDeltaCqi', nbParam2, eventParamL)
        if (tmpIsDeltaCqiCalculated == 0 or tmpIsDeltaCqiCalculated == 1):
            if (tmpHarqFb == "ACK"):
                self.harqFbACK[tmpIsDeltaCqiCalculated] += 1
            elif (tmpHarqFb == "NACK"):
                self.harqFbNACK[tmpIsDeltaCqiCalculated] += 1
            elif (tmpHarqFb == "DTX"):
                self.harqFbDTX[tmpIsDeltaCqiCalculated] += 1
            else:
                self.harqFbMISC[tmpIsDeltaCqiCalculated] += 1
                print("Val NON TRAITEE ===> dlLaDeltaCqi/harqFb",
                      dlLaDeltaCqi/harqFb, "<====")

    def calculer(self):
        TraceTTIdlul.calculer(self)
        harqFbACKtmp = 0
        harqFbNACKtmp = 0
        for i in range(0, 2):
            harqFbNACKtmp = harqFbNACKtmp + self.harqFbNACK[i]
            harqFbACKtmp = harqFbACKtmp + self.harqFbACK[i]
        resultDLUL.ave_initTargBlergNB_DL = average(
            (harqFbNACKtmp*100), (harqFbACKtmp + harqFbNACKtmp))
        dtxNackTmp = 0
        dtxNackAckTmp = 0
        for i in range(0, 2):
            dtxNackAckTmp = dtxNackAckTmp + \
                self.harqFbDTX[i] + self.harqFbNACK[i] + self.harqFbACK[i]
            dtxNackTmp = dtxNackTmp + self.harqFbDTX[i] + self.harqFbNACK[i]
        resultDLUL.ave_Bler_DL = average((dtxNackTmp*100), (dtxNackAckTmp))


class UlFdSchedData(TraceTTIdlul):
    def __init__(self, *args, **kwargs):
        TraceTTIdlul.__init__(self, *args, **kwargs)
        self.SFNFirst = -1
        self.SFNLast = -1
        self.SFNPrev = -1
        self.NbSFN1024 = 0
        self.SLOTFirst = -1
        self.SLOTLast = -1
        self.traceDurationEvent = 0
        self.rrmUlUsedMcs = 0
        self.txNumber = 6*[0]
        self.harqProcessIndexVolL1 = 16*[0]
        self.harqProcessIndexVolL1App = 16*[0]
        self.harqProcessIndexLastTbs = 16*[0]
        self.numOfLayers = 5*[0]
        self.numOfPrb = 0

    def parseLine(self, nbParam2, eventParamL):
        TraceTTIdlul.parseLine(self)

        tmpSfn = int(getParamValue(
            'sfn', 'ulFdSchedData', nbParam2, eventParamL))
        self.SFNPrev = self.SFNLast
        self.SFNLast = tmpSfn
        if (self.SFNFirst == -1):
            self.SFNFirst = self.SFNLast
            self.SFNPrev = self.SFNLast
        elif (self.SFNLast < self.SFNPrev):
            self.NbSFN1024 += 1

        tmpSlot = int(getParamValue(
            'slot', 'ulFdSchedData', nbParam2, eventParamL))
        self.SLOTLast = tmpSlot
        if (self.SLOTFirst == -1):
            self.SLOTFirst = self.SLOTLast

        tmpRrmUlUsedMcs = int(getParamValue(
            'rrmUlUsedMcs', 'ulFdSchedData', nbParam2, eventParamL))
        self.rrmUlUsedMcs += tmpRrmUlUsedMcs

        tmpTbSize = int(getParamValue(
            'tbSize', 'ulFdSchedData', nbParam2, eventParamL))

        tmpTxNumber = int(getParamValue(
            'txNumber', 'ulFdSchedData', nbParam2, eventParamL))
        self.txNumber[tmpTxNumber] += 1

        tmpHrqIndex = int(getParamValue('ulHarqProcessIndex',
                          'ulFdSchedData', nbParam2, eventParamL))
        if (tmpTxNumber == 1):
            self.harqProcessIndexVolL1[tmpHrqIndex] += tmpTbSize
            self.harqProcessIndexVolL1App[tmpHrqIndex] += tmpTbSize
            self.harqProcessIndexLastTbs[tmpHrqIndex] = tmpTbSize
        else:
            self.harqProcessIndexVolL1[tmpHrqIndex] += self.harqProcessIndexLastTbs[tmpHrqIndex]

        tmpNumOfLayers = int(getParamValue(
            'numOfLayers', 'ulFdSchedData', nbParam2, eventParamL).replace('RANK', ''))
        if (tmpNumOfLayers > 0 and tmpNumOfLayers < 5):
            self.numOfLayers[tmpNumOfLayers] += 1
        else:
            print('Error Number of Layers({}) out of range'.format(tmpNumOfLayers))

        tmpNumOfPrb = int(getParamValue(
            'numOfPrb', 'ulFdSchedData', nbParam2, eventParamL))
        self.numOfPrb += tmpNumOfPrb

    def calculer(self):
        TraceTTIdlul.calculer(self)
        resultDLUL.ave_mcsUsed_UL = self.ave(self.rrmUlUsedMcs)

        if self.txNumber[1]:
            resultDLUL.ave_initBlergNB_UL = average(
                (self.txNumber[2]*100), self.txNumber[1])
        else:
            resultDLUL.ave_initBlergNB_UL = 100.
            print('Initial UL  Bler(gNB side) can\'t by calculated TX1 = 0')

        allLayers = 0
        for i in range(1, 5):
            allLayers += (self.numOfLayers[i] * i)
        resultDLUL.ave_allLayers_UL = average(
            allLayers, self.numberTracesEvent)
        for i in range(1, 5):
            resultDLUL.ave_byLayer_UL[i] = self.ave(self.numOfLayers[i]*100)
        resultDLUL.ave_numOfPrb_UL = self.ave(self.numOfPrb)
        traceDurationSFN = ((SFN_MAX * self.NbSFN1024) -
                            self.SFNFirst + self.SFNLast) * TIME_PERIOD
        traceDurationTS = int(
            ((self.SLOTLast - self.SLOTFirst) * TIME_PERIOD) / TS_MAX)
        self.traceDurationEvent = int(traceDurationSFN + traceDurationTS)
        resultDLUL.traceDuration_UL = self.traceDurationEvent
        for i in range(0, 16):
            resultDLUL.tputVolL1Harq_UL += self.harqProcessIndexVolL1[i]
            resultDLUL.tputVolL1AppHarq_UL += self.harqProcessIndexVolL1App[i]
        resultDLUL.tputL1AppHarq_UL = average(
            resultDLUL.tputVolL1AppHarq_UL, (resultDLUL.traceDuration_UL*1000))
        resultDLUL.tputL1Harq_UL = average(
            resultDLUL.tputVolL1Harq_UL, (resultDLUL.traceDuration_UL*1000))


class UlLaAverageSinr(TraceTTIdlul):
    def __init__(self, *args, **kwargs):
        TraceTTIdlul.__init__(self, *args, **kwargs)
        self.rrmAvgSinrUl = 0.0
        self.rrmInstSinr = 0.0

    def parseLine(self, nbParam2, eventParamL):
        TraceTTIdlul.parseLine(self)

        tmpSfn = int(getParamValue(
            'sfn', 'ulLaAverageSinr', nbParam2, eventParamL))

        tmpSlot = int(getParamValue(
            'slot', 'ulLaAverageSinr', nbParam2, eventParamL))

        tmpRrmAvgSinrUl = float(getParamValue(
            'rrmAvgSinrUl', 'ulLaAverageSinr', nbParam2, eventParamL))
        self.rrmAvgSinrUl += dBm2W(tmpRrmAvgSinrUl)

        tmpRrmInstSinr = float(getParamValue(
            'rrmInstSinr', 'ulLaAverageSinr', nbParam2, eventParamL))
        self.rrmInstSinr += dBm2W(tmpRrmInstSinr)

    def calculer(self):
        TraceTTIdlul.calculer(self)
        resultDLUL.ave_rrmInstSinr = W2dBm(self.ave(self.rrmInstSinr))

        resultDLUL.ave_rrmAvgSinrUl = W2dBm(self.ave(self.rrmAvgSinrUl))
        resultDLUL.ave_correctedSinr += self.ave(self.rrmAvgSinrUl)


class UlLaDeltaSinr(TraceTTIdlul):
    def __init__(self, *args, **kwargs):
        TraceTTIdlul.__init__(self, *args, **kwargs)
        self.rrmDeltaSinr = 0.0
        self.isDeltaSinrCalculated = 0
        self.crcFbOK = 2*[0]
        self.crcFbNOK = 2*[0]
        self.crcFbDTX = 2*[0]
        self.crcFbMISC = 2*[0]

    def parseLine(self, nbParam2, eventParamL):
        TraceTTIdlul.parseLine(self)

        tmpSfn = int(getParamValue(
            'sfn', 'ulLaDeltaSinr', nbParam2, eventParamL))

        tmpSlot = int(getParamValue(
            'slot', 'ulLaDeltaSinr', nbParam2, eventParamL))

        tmpRrmDeltaSinr = float(getParamValue(
            'rrmDeltaSinr', 'ulLaDeltaSinr', nbParam2, eventParamL))
        self.rrmDeltaSinr += dBm2W(tmpRrmDeltaSinr)

        tmpIsDeltaSinrCalculated = int(getParamValue(
            'isDeltaSinrCalculated', 'ulLaDeltaSinr', nbParam2, eventParamL))
        self.isDeltaSinrCalculated += tmpIsDeltaSinrCalculated

        tmpCrcFb = getParamValue(
            'crcFb', 'ulLaDeltaSinr', nbParam2, eventParamL)
        if (tmpIsDeltaSinrCalculated == 0 or tmpIsDeltaSinrCalculated == 1):
            if (tmpCrcFb == "OK"):
                self.crcFbOK[tmpIsDeltaSinrCalculated] += 1
            elif (tmpCrcFb == "NOK"):
                self.crcFbNOK[tmpIsDeltaSinrCalculated] += 1
            elif (tmpCrcFb == "DTX"):
                self.crcFbDTX[tmpIsDeltaSinrCalculated] += 1
            else:
                self.crcFbMISC[tmpIsDeltaSinrCalculated] += 1
                print("Val NON TRAITEE ===> ulLaDeltaSinr/crcFb",
                      ulLaDeltaSinr/ulCrcFb, "<====")

    def calculer(self):
        TraceTTIdlul.calculer(self)
        resultDLUL.ave_rrmDeltaSinr = W2dBm(self.ave(self.rrmDeltaSinr))
        resultDLUL.ave_initTargBlergNB_UL = average(
            (self.crcFbNOK[1]*100), (self.crcFbOK[1]+self.crcFbNOK[1]))
        crcFbOKtmp = 0
        crcFbNOKtmp = 0
        for i in range(0, 2):
            crcFbNOKtmp = crcFbNOKtmp + self.crcFbNOK[i]
            crcFbOKtmp = crcFbOKtmp + self.crcFbOK[i]
        resultDLUL.ave_Bler_UL = average(
            (crcFbNOKtmp*100), (crcFbOKtmp + crcFbNOKtmp))


class UlPuschReceiveRespPsData(TraceTTIdlul):
    def __init__(self, *args, **kwargs):
        TraceTTIdlul.__init__(self, *args, **kwargs)
        self.rssi = 0.0

    def parseLine(self, nbParam2, eventParamL):
        TraceTTIdlul.parseLine(self)
        tmpSfn = int(getParamValue(
            'sfn', 'ulPuschReceiveRespPsData', nbParam2, eventParamL))
        tmpSlot = int(getParamValue(
            'slot', 'ulPuschReceiveRespPsData', nbParam2, eventParamL))
        tmpRssi = float(getParamValue(
            'rssi', 'ulPuschReceiveRespPsData', nbParam2, eventParamL))
        self.rssi += dBm2W(tmpRssi)

    def calculer(self):
        TraceTTIdlul.calculer(self)
        resultDLUL.ave_rssi = W2dBm(self.ave(self.rssi))


def eventParamList(eventParam):
    eventParamL = eventParam.replace('\n', '')
    eventParamL = eventParamL.replace(' ', '')
    eventParamL = re.split(',', eventParamL)
    nbParam = len(eventParamL)
    nbParam2 = nbParam // 2

    return nbParam2, eventParamL


def offsetParam(param, nbParam2, eventParam):
    try:
        indexP = eventParam.index(param)
        return (indexP+nbParam2)
    except ValueError as e:
        print('Param NON TROUVE {} ===> {}'.format(param, eventParam))
        sys.exit(1)
        return (-1)


def getOffsetParam(event, cle):
    return (DicoOffsetFiledsDLUL[event][cle])


def getParamValue(param, event, nbParam2, eventParamL):
    indexP = getOffsetParam(event, param)
    if (indexP == -1):
        updateDicoOffsetFiledsDLUL(event, nbParam2, eventParamL)
        indexP = getOffsetParam(event, param)

    try:
        tmpParamValue = eventParamL[indexP]
    except ValueError as e:
        print("IndexP      ", indexP)
        print("param       ", param)
        print("event       ", event)
        print("nbParam2    ", nbParam2)
        print("eventParamL ", eventParamL)
        sys.exit(1)

    return tmpParamValue


def updateDicoOffsetFiledsDLUL(event, nbParam2, eventParamL):
    for cle in DicoOffsetFiledsDLUL[event].keys():
        DicoOffsetFiledsDLUL[event][cle] = offsetParam(
            cle, nbParam2, eventParamL)


def average(sumVal, nbVal):
    ave = 0.0
    try:
        ave = float(sumVal) / float(nbVal)
    except ZeroDivisionError as e:
        if (sumVal != 0):
            print('Division({}) by zero({})'.format(sumVal, nbVal))
            # sys.exit(1)
    return ave


resultDLUL = ResultTracesTTIdlul()


def parserTTI(fileName):
    fileNameT, fileExtensionT = os.path.splitext(fileName)
    inputFileCSV = open(fileName, 'r')
    resultDLUL.initialise(fileName)
    for curLine in inputFileCSV:
        curLine = curLine.replace('ERROR:', 'ERROR')
        splitLine = re.split(':', curLine)
        event = ""
        if (len(splitLine) == 2):
            event = splitLine[0]
            if (event in SupportedEventsTTI):
                nbParam2, eventParamL = eventParamList(splitLine[1])
                curRNTI = getParamValue('rnti', event, nbParam2, eventParamL)
                cleObj = curRNTI + '_' + event
                if (event in SupportedEventsTTIdl):
                    if (cleObj not in resultDLUL.DL):
                        traceT = resultDLUL.creerObjetDicoDL[event](
                            event, fileName)
                        resultDLUL.DL[cleObj] = traceT
                        if (curRNTI not in resultDLUL.RNTIused_DL):
                            resultDLUL.RNTIused_DL.append(curRNTI)
                    else:
                        traceT = resultDLUL.DL[cleObj]
                elif (event in SupportedEventsTTIul):
                    if (cleObj not in resultDLUL.UL):
                        traceT = resultDLUL.creerObjetDicoUL[event](
                            event, fileName)
                        resultDLUL.UL[cleObj] = traceT
                        if (curRNTI not in resultDLUL.RNTIused_UL):
                            resultDLUL.RNTIused_UL.append(curRNTI)
                    else:
                        traceT = resultDLUL.UL[cleObj]
                else:
                    print('Event not supported = ', event)
                    break
                traceT.parseLine(nbParam2, eventParamL)
    inputFileCSV.close()

    tmpStrDLall = ''
    tmpStrDL = ''
    for rnti in resultDLUL.RNTIused_DL:
        resultDLUL.initResult(fileName)
        for event in SupportedEventsTTIdl:
            cleObj = rnti + '_' + event
            if cleObj in resultDLUL.DL:
                resultDLUL.DL[cleObj].calculer()
        tmpStrDL = resultDLUL.formatRecapDL(rnti)
        if tmpStrDLall == '':
            tmpStrDLall = tmpStrDL
        else:
            tmpStrDLall = tmpStrDLall + '|' + tmpStrDL

    tmpStrULall = ''
    tmpStrUL = ''
    for rnti in resultDLUL.RNTIused_UL:
        resultDLUL.initResult(fileName)
        for event in SupportedEventsTTIul:
            cleObj = rnti + '_' + event
            if cleObj in resultDLUL.UL:
                resultDLUL.UL[cleObj].calculer()
        tmpStrUL = resultDLUL.formatRecapUL(rnti)
        if tmpStrULall == '':
            tmpStrULall = tmpStrUL
        else:
            tmpStrULall = tmpStrULall + '|' + tmpStrUL
    return (tmpStrDLall, tmpStrULall)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('fileName', type=str,
                        help='fileName : file to be parsed')
    args = parser.parse_args()
    fileName = args.fileName
    parserTTI(fileName)
