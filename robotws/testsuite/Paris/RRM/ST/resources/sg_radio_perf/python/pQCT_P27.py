# -*- coding: utf-8 -*-

import argparse
import os
import re
import sys
from datetime import datetime
from math import log10

from ctesPerf import *

MIN_ = 3   # Header composé par au moins '_'

SupportedTracesQCT = ['0xB883', '0xB884', '0xB887', '0xB8A7', '0xB97F', '0xB992']
DicoOffsetFiledsQCT = {
    '0xB883': {'tbSize': 24, 'rnti': 34},
    '0xB884': {'channelType': 10, 'PUCCH_PUSCH': 11, 'dlPathLoss': 12},
    '0xB887': {
        'tbSize': 17, 'MCS': 19, 'numOfPrb': 20, 'numOfLayers': 26, 'crcFb': 29, 'txNumber': 35
    },
    '0xB8A7': {'CQI': 21},
    '0xB97F': {'RSRP': 6, 'RSRQ': 7},
    '0xB992': {'SNR': 3}
}


def getOffsetParam(traceQCT, param):
    return (DicoOffsetFiledsQCT[traceQCT][param])


def analyseTraceLineQCT(curLine):

    traceQCTName = ''
    typeTraceLine = 'none'

    re_StartTraceQCT = re.compile(r'[1980]{1}\s*[Jan]{1}')
    startTraceQCT = re_StartTraceQCT.search(curLine)
    if startTraceQCT:
        re_startTraceNR5G = re.compile(
            r's*\[[A-F0-9]{2}\]\s*0xB[A-F0-9]{3}\s*NR5G\s*')
        startTraceNR5G = re_startTraceNR5G.search(curLine)
        if startTraceNR5G:
            re_traceNR5G_0xByyy = re.compile(r'0xB\w{3}')
            traceNR5G_0xByyy = re_traceNR5G_0xByyy.search(
                startTraceNR5G.group(0))
            if traceNR5G_0xByyy:
                traceQCTName = traceNR5G_0xByyy.group(0)
                if traceQCTName in SupportedTracesQCT:
                    typeTraceLine = 'traceLineQCTsup'
                else:
                    typeTraceLine = 'traceLineQCTnonSup'
        else:
            typeTraceLine = 'traceLineQCTnonSup'
    elif len(curLine.strip()) == 0:
        typeTraceLine = 'nullLineQCT'
    else:
        nb_ = curLine.strip().count('-')
        if (nb_ > MIN_ and nb_ == len(curLine.strip())):
            typeTraceLine = 'headerLineQCT'
        else:
            typeTraceLine = 'dataLineQCT'

    return (typeTraceLine, traceQCTName)


class Automate():
    def __init__(self):
        self.state = 'none'
        self.traceQCTName = ''
        self.curObjectTraceQCT = None
        self.dicoTracesQCT = {}
        self.fileName = ''

    def initialise(self, fileName):
        self.state = 'none'
        self.traceQCTName = ''
        self.curObjectTraceQCT = None
        self.dicoTracesQCT = {}
        self.fileName = fileName

    def setState(self, newState):
        self.state = newState

    def getAction(self, event):
        return (self.dicoAudomate[self.state][event])

    def parserLine(self, curLine):
        typeTraceLine, traceQCTName = analyseTraceLineQCT(curLine)
        action = self.getAction(typeTraceLine)
        action(self, traceQCTName, curLine)

    def action_m1(self, traceName, curLine):
        self.state = 'none'

    def action_00(self, traceName, curLine):
        pass

    def action_01(self, traceName, curLine):
        self.setState('none')

    def action_02(self, traceName, curLine):
        pass

    def action_03(self, traceName, curLine):
        self.setState('traceLineQCTsup')

        if traceName not in self.dicoTracesQCT:
            fileNameT, fileExtensionT = os.path.splitext(self.fileName)
            self.curObjectTraceQCT = CreerDicoTracesQCT[traceName](
                traceName, fileNameT, curLine)
            self.dicoTracesQCT[traceName] = self.curObjectTraceQCT
        else:
            self.curObjectTraceQCT = self.dicoTracesQCT[traceName]
            self.curObjectTraceQCT.updateLastTrace(curLine)

    def action_04(self, traceName, curLine):
        self.setState('headerLineQCT')

    def action_05(self, traceName, curLine):
        self.setState('dataLineQCT')
        if (not self.curObjectTraceQCT.headerTrace):
            self.curObjectTraceQCT.logTraceQCT(self.curObjectTraceQCT.prevLine)
            self.curObjectTraceQCT.headerTrace = True

    def action_06(self, traceName, curLine):
        self.curObjectTraceQCT.updatePrevLine(curLine)

    def action_07(self, traceName, curLine):
        self.curObjectTraceQCT.logTraceQCT(curLine)
        self.curObjectTraceQCT.setCurLine(curLine)
        self.curObjectTraceQCT.calculsLine()

    dicoAudomate = {
        'none': {
            'none': action_m1, 'traceLineQCTsup': action_03, 'traceLineQCTnonSup': action_00,
            'headerLineQCT': action_00, 'dataLineQCT': action_00, 'nullLineQCT': action_00},
        'traceLineQCTsup': {
            'none': action_m1, 'traceLineQCTsup': action_03, 'traceLineQCTnonSup': action_01,
            'headerLineQCT': action_04, 'dataLineQCT': action_00, 'nullLineQCT': action_00},
        'headerLineQCT': {
            'none': action_m1, 'traceLineQCTsup': action_03, 'traceLineQCTnonSup': action_01,
            'headerLineQCT': action_05, 'dataLineQCT': action_06, 'nullLineQCT': action_00},
        'dataLineQCT': {
            'none': action_m1, 'traceLineQCTsup': action_03, 'traceLineQCTnonSup': action_01,
            'headerLineQCT': action_02, 'dataLineQCT': action_07, 'nullLineQCT': action_01},
        'nullLineQCT': {
            'none': action_m1, 'traceLineQCTsup': action_00, 'traceLineQCTnonSup': action_00,
            'headerLineQCT': action_00, 'dataLineQCT': action_00, 'nullLineQCT': action_00},
        'traceLineQCTnonSup': {
            'none': action_m1, 'traceLineQCTsup': action_m1, 'traceLineQCTnonSup': action_m1,
            'headerLineQCT': action_m1, 'dataLineQCT': action_m1, 'nullLineQCT': action_m1}
    }


def str2Float(strVal):
    if len(strVal) > 0 and strVal != 'NA':
        flagRes = True
        tmpVal = float(strVal)
    else:
        flagRes = False
        tmpVal = 0.0
    return flagRes, tmpVal


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


def str2Int(strVal):
    if len(strVal) > 0 and (strVal.isdigit()):
        resFlag = True
        tmpVal = int(strVal)
    else:
        resFlag = False
        tmpVal = -1

    return resFlag, tmpVal


class SumNbval():
    def __init__(self, sum=0.0, nb=0):
        self.sum = sum
        self.nb = nb

    def add(self, val):
        self.sum += val
        self.nb += 1

    def average(self):
        if self.nb > 0:
            avg = float(self.sum)/float(self.nb)
        else:
            avg = 0.0
        return avg

    def add_str2Float(self, strVal):
        resFlag, val = str2Float(strVal)
        if resFlag:
            self.add(val)

    def add_str2Float_dBm2W(self, strVal):
        resFlag, val = str2Float(strVal)
        if resFlag:
            self.add(dBm2W(val))

    def average_W2dBm(self):
        if self.nb > 0:
            avg = W2dBm(float(self.sum)/float(self.nb))
        else:
            avg = 0.0
        return avg


def formatRecapVal():
    tmpStrDL = ''
    tmpStrUL = ''
    for tmpRnti in resultDLUL.RNTIlist:
        tmpStrDL += tmpRnti + ' '
        tmpStrUL += tmpRnti + ' '

    tmpStrDL += ';' + str('%0.3f' % resultDLUL.DlRSRP_avg).replace('.', ',')
    tmpStrUL += ';' + str('%0.3f' % resultDLUL.DlRSRP_avg).replace('.', ',')

    tmpStrDL += ';' + str('%0.3f' %
                          resultDLUL.DlPathLoss_avg).replace('.', ',')
    tmpStrUL += ';' + str('%0.3f' %
                          resultDLUL.DlPathLoss_avg).replace('.', ',')

    # tmpStrDL += ';'
    # tmpStrUL += ';'
    tmpStrDL += ';' + str('%0.3f' % (cLA_CTE_DL_PL -
                          resultDLUL.DlRSRP_avg)).replace('.', ',')
    tmpStrUL += ';' + str('%0.3f' % (cLA_CTE_DL_PL -
                          resultDLUL.DlRSRP_avg)).replace('.', ',')

    tmpStrDL += ';' + str('%0.3f' % resultDLUL.DlRSRQ_avg).replace('.', ',')
    tmpStrUL += ';' + str('%0.3f' % resultDLUL.DlRSRQ_avg).replace('.', ',')

    tmpStrDL += ';' + str('%0.3f' %
                          resultDLUL.UE_PUCCH_TxPwr_avg).replace('.', ',')

    tmpStrDL += ';' + str('%0.3f' % resultDLUL.CQI_avg).replace('.', ',')
    tmpStrUL += ';' + str('%0.3f' % resultDLUL.CQI_avg).replace('.', ',')

    tmpStrUL += ';' + str('%0.3f' %
                          resultDLUL.UE_PUCCH_TxPwr_avg).replace('.', ',')
    tmpStrUL += ';' + str('%0.3f' %
                          resultDLUL.UE_PUSCH_TxPwr_avg).replace('.', ',')
    tmpStrUL += ';' + str('%0.3f' % resultDLUL.L1ULTput_Mbps).replace('.', ',')

    tmpStrDL += ';' + str('%0.3f' % resultDLUL.DlSNR_avg).replace('.', ',')
    tmpStrDL += ';' + str('%0.3f' % resultDLUL.dlMCS_avg).replace('.', ',')
    tmpStrDL += ';' + str('%0.3f' %
                          resultDLUL.initialDlBlerUE).replace('.', ',')
    tmpStrDL += ';' + str('%0.3f' % resultDLUL.DlBlerUE_avg).replace('.', ',')
    tmpStrDL += ';' + str(resultDLUL.numLayers_avg).replace('.', ',')
    layersAll = 0
    for i in range(1, 5):
        layersAll += resultDLUL.Layers_pc[i]
    for i in range(1, 5):
        if (layersAll != 0):
            tmpStrDL += ';' + \
                str('%0.3f' % (
                    (resultDLUL.Layers_pc[i] * 100.) / layersAll)).replace('.', ',')
        else:
            tmpStrDL += ';' + ''

    tmpStrDL += ';' + str('%0.3f' %
                          resultDLUL.AppDLTput_Mbps).replace('.', ',')
    tmpStrDL += ';' + str('%0.3f' % resultDLUL.L1DLTput_Mbps).replace('.', ',')
    tmpStrDL += ';' + str(resultDLUL.dlPRB_avg).replace('.', ',')

    return tmpStrDL, tmpStrUL


class ResultTraceQCT ():
    def __init__(self):
        self.RNTIlist = []
        self.dlMCS_avg = 0.0
        self.numLayers_avg = 0.0
        self.Layers_pc = 5*[0]
        self.dlPRB_avg = 0.0
        self.initialDlBlerUE = 0.0
        self.DlBlerUE_avg = 0.0
        self.L1DLTput_Mbps = 0.0
        self.AppDLTput_Mbps = 0.0
        self.L1ULTput_Mbps = 0.0
        self.CQI_avg = 0.0
        self.DlPathLoss_avg = 0.0
        self.UE_PUCCH_TxPwr_avg = 0.0
        self.UE_PUSCH_TxPwr_avg = 0.0
        self.DlRSRP_avg = 0.0
        self.DlRSRQ_avg = 0.0
        self.DlSNR_avg = 0.0

    def initResult(self):
        self.RNTIlist = []
        self.dlMCS_avg = 0.0
        self.numLayers_avg = 0.0
        self.Layers_pc = 5*[0]
        self.dlPRB_avg = 0.0
        self.initialDlBlerUE = 0.0
        self.DlBlerUE_avg = 0.0
        self.L1DLTput_Mbps = 0.0
        self.AppDLTput_Mbps = 0.0
        self.L1ULTput_Mbps = 0.0
        self.CQI_avg = 0.0
        self.DlPathLoss_avg = 0.0
        self.UE_PUCCH_TxPwr_avg = 0.0
        self.UE_PUSCH_TxPwr_avg = 0.0
        self.DlRSRP_avg = 0.0
        self.DlRSRQ_avg = 0.0
        self.DlSNR_avg = 0.0


class TraceQCT (object):
    numberOfQCTTraces = 0

    def __init__(self, traceName='', fileNameTrace='', firstTrace=''):
        TraceQCT.numberOfQCTTraces += 1
        self.traceName = traceName
        self.traceState = ''
        self.traceDuration = 0
        self.numberOfTraces = 0
        self.firstTrace = firstTrace
        self.lastTrace = firstTrace
        self.headerTrace = False
        self.curLine = ''
        self.prevLine = ''
        self.curLineSplit = ''
        if cLA_QCT_LOG_CSV:
            self.fileNameTrace = fileNameTrace + '_' + traceName + '.csv'
            self.outputFile = open(self.fileNameTrace, 'w')
            self.outputFile.close()
            self.outputFile = open(self.fileNameTrace, 'a')

    def logTraceQCT(self, line):
        line = line.replace('|', ';').replace('.', ',')
        if cLA_QCT_LOG_CSV:
            self.outputFile.write(line)

    def updatePrevLine(self, prevLine):
        self.prevLine = prevLine

    def updateLastTrace(self, lastTrace):
        self.numberOfTraces += 1
        self.lastTrace = lastTrace

    def setCurLine(self, curLine):
        self.curLine = curLine
        self.curLineSplit = curLine.split('|')

    def calTraceDuration(self):
        timeFistTrace = datetime.strptime(
            (self.firstTrace.split('[')[0]).strip(), '%Y %b  %d  %H:%M:%S.%f')
        timeLastTrace = datetime.strptime(
            (self.lastTrace.split('[')[0]).strip(), '%Y %b  %d  %H:%M:%S.%f')
        deltaTime = timeLastTrace - timeFistTrace
        self.traceDuration = int(
            (deltaTime.seconds*1000)+(deltaTime.microseconds/1000))

    def getParamValue(self, param):
        indexP = getOffsetParam(self.traceName, param)

        if (indexP == -1):
            print('Error >>>  parametre non traitée traceName={} param={}'.format(
                param, self.traceName))
            print("Error --------------------------------->traceQCT     ",
                  self.traceName)
            print("Error --------------------------------->param        ", param)
            print("Error --------------------------------->IndexP       ", indexP)
            print("Error --------------------------------->curLineSplit ",
                  self.curLineSplit)
            print("Error --------------------------------->curLine      ", self.curLine)

        tmpParamValue = ''
        try:
            tmpParamValue = (self.curLineSplit[indexP-1]).strip()
        except ValueError as e:
            print("except --------------------------------->traceQCT     ",
                  self.traceName)
            print("except --------------------------------->param        ", param)
            print("except --------------------------------->IndexP       ", indexP)
            print("except --------------------------------->curLineSplit ",
                  self.curLineSplit)
            print("except --------------------------------->curLine      ", self.curLine)

        return tmpParamValue

    def calculsLine(self):
        pass

    def calculer(self):
        self.calTraceDuration()


class Trace_0xB883(TraceQCT):
    def __init__(self, *args, **kwargs):
        TraceQCT.__init__(self, *args, **kwargs)
        self.L1ULTputVol = 0.0
        self.RNTI = []

    def calculsLine(self):
        TraceQCT.calculsLine(self)
        resFlag, tmpTbSize = str2Int(self.getParamValue('tbSize'))

        if resFlag:
            self.L1ULTputVol += tmpTbSize
            # print ('-----Debug ------------> '.format(self.L1ULTputVol))
        curRNTI = self.getParamValue('rnti')
        if ((curRNTI != '') and (curRNTI not in self.RNTI)):
            self.RNTI.append(curRNTI)

    def calculer(self):
        TraceQCT.calculer(self)
        try:
            resultDLUL.L1ULTput_Mbps = float(
                self.L1ULTputVol * 8) / float(self.traceDuration * 1000)

        except ValueError as e:
            print('-------------------------------------------------------------------> traceDuration(ms) : {0}'
                  .format(self.traceDuration))
        resultDLUL.RNTIlist = self.RNTI


class Trace_0xB884(TraceQCT):
    def __init__(self, *args, **kwargs):
        TraceQCT.__init__(self, *args, **kwargs)
        self.DlPathLoss = SumNbval()
        self.UE_PUCCH_TxPwr = SumNbval()
        self.UE_PUSCH_TxPwr = SumNbval()

    def calculsLine(self):
        TraceQCT.calculsLine(self)
        self.DlPathLoss.add_str2Float_dBm2W(self.getParamValue('dlPathLoss'))
        tmpChannelType = self.getParamValue('channelType')
        if tmpChannelType == 'PUCCH':
            self.UE_PUCCH_TxPwr.add_str2Float_dBm2W(
                self.getParamValue('PUCCH_PUSCH'))
        elif tmpChannelType == 'PUSCH':
            self.UE_PUSCH_TxPwr.add_str2Float_dBm2W(
                self.getParamValue('PUCCH_PUSCH'))

    def calculer(self):
        TraceQCT.calculer(self)
        resultDLUL.DlPathLoss_avg = self.DlPathLoss.average_W2dBm()
        resultDLUL.UE_PUCCH_TxPwr_avg = self.UE_PUCCH_TxPwr.average_W2dBm()
        resultDLUL.UE_PUSCH_TxPwr_avg = self.UE_PUSCH_TxPwr.average_W2dBm()


class Trace_0xB887(TraceQCT):
    def __init__(self, *args, **kwargs):
        TraceQCT.__init__(self, *args, **kwargs)
        self.dlMCS = SumNbval()
        self.numLayers = SumNbval()
        self.Layers = 5*[0]
        self.dlPRB = SumNbval()
        self.NbCRC_status_PASS = 0
        self.NbCRCstatusFAIL = 0
        self.NbCRCstatusFAILReTx0 = 0
        self.NbCRC_status_MISC = 0
        self.reTx = 6*[0]
        self.L1DLTputVol = 0.0
        self.AppDLTputVol = 0.0

    def calculsLine(self):
        TraceQCT.calculsLine(self)
        self.dlMCS.add_str2Float(self.getParamValue('MCS'))
        resFlag, tmpNumLayer = str2Int(self.getParamValue('numOfLayers'))
        if resFlag:
            if 0 < tmpNumLayer < 5:
                self.Layers[tmpNumLayer] += 1
                self.numLayers.add(tmpNumLayer)
            else:
                print('Error Number of Layer ({}) out of range'.format(tmpNumLayer))

        self.dlPRB.add_str2Float(self.getParamValue('numOfPrb'))

        resFlag, tmpIntReTx = str2Int(self.getParamValue('txNumber'))
        if resFlag:
            if 0 <= tmpIntReTx < 6:
                self.reTx[tmpIntReTx] += 1
            else:
                print('Error TxNumber ({}) out of range'.format(tmpIntReTx))

        tmpStrCRC = self.getParamValue('crcFb')
        if len(tmpStrCRC) > 0:
            if tmpStrCRC == 'PASS':
                self.NbCRC_status_PASS += 1
            elif tmpStrCRC == 'FAIL':
                self.NbCRCstatusFAIL += 1
                if tmpIntReTx == 0:
                    self.NbCRCstatusFAILReTx0 += 1
            else:
                self.NbCRC_status_MISC += 1

        resFlag, tmpTbSize = str2Int(self.getParamValue('tbSize'))
        if resFlag:
            self.L1DLTputVol += tmpTbSize
            if tmpStrCRC == 'PASS':
                self.AppDLTputVol += tmpTbSize

    def calculer(self):
        TraceQCT.calculer(self)
        resultDLUL.dlMCS_avg = self.dlMCS.average()
        resultDLUL.dlPRB_avg = self.dlPRB.average()
        resultDLUL.numLayers_avg = self.numLayers.average()
        resultDLUL.Layers_pc = self.Layers
        try:
            resultDLUL.L1DLTput_Mbps = float(
                self.L1DLTputVol * 8) / float(self.traceDuration * 1000)
            resultDLUL.AppDLTput_Mbps = float(
                self.AppDLTputVol * 8) / float(self.traceDuration * 1000)
        except ValueError as e:
            print('-------------------------------------------------------------------> traceDuration(ms) : {0}'
                  .format(self.traceDuration))

        if self.reTx[0] > 0:
            resultDLUL.initialDlBlerUE = float(
                100 * self.NbCRCstatusFAILReTx0) / float(self.reTx[0])
        retxAll = 0
        for i in range(0, 6):
            retxAll += self.reTx[i]
        if retxAll > 0:
            resultDLUL.DlBlerUE_avg = float(
                100 * self.NbCRCstatusFAIL) / float(retxAll)


class Trace_0xB8A7(TraceQCT):
    def __init__(self, *args, **kwargs):
        TraceQCT.__init__(self, *args, **kwargs)
        self.CQI = SumNbval()

    def calculsLine(self):
        TraceQCT.calculsLine(self)
        self.CQI.add_str2Float(self.getParamValue('CQI'))

    def calculer(self):
        TraceQCT.calculer(self)
        resultDLUL.CQI_avg = self.CQI.average()


class Trace_0xB97F(TraceQCT):
    def __init__(self, *args, **kwargs):
        TraceQCT.__init__(self, *args, **kwargs)
        self.DlRSRP = SumNbval()
        self.DlRSRQ = SumNbval()

    def calculsLine(self):
        TraceQCT.calculsLine(self)
        self.DlRSRP.add_str2Float_dBm2W(self.getParamValue('RSRP'))
        self.DlRSRQ.add_str2Float_dBm2W(self.getParamValue('RSRQ'))

    def calculer(self):
        TraceQCT.calculer(self)
        resultDLUL.DlRSRP_avg = self.DlRSRP.average_W2dBm()
        resultDLUL.DlRSRQ_avg = self.DlRSRQ.average_W2dBm()


class Trace_0xB992(TraceQCT):
    def __init__(self, *args, **kwargs):
        TraceQCT.__init__(self, *args, **kwargs)
        self.dlSNR = SumNbval()

    def calculsLine(self):
        TraceQCT.calculsLine(self)
        self.dlSNR.add_str2Float_dBm2W(self.getParamValue('SNR'))
        print("CHECK:", self.getParamValue('SNR'))

    def calculer(self):
        TraceQCT.calculer(self)
        resultDLUL.DlSNR_avg = self.dlSNR.average_W2dBm()
        print("CHECK_AVG:", resultDLUL.DlSNR_avg)


CreerDicoTracesQCT = {
    '0xB883': Trace_0xB883,
    '0xB884': Trace_0xB884,
    '0xB887': Trace_0xB887,
    '0xB8A7': Trace_0xB8A7,
    '0xB97F': Trace_0xB97F,
    '0xB992': Trace_0xB992
}


resultDLUL = ResultTraceQCT()


def parserQCT(fileName):

    AUTO = Automate()
    resultDLUL.initResult()

    fileNameT, fileExtensionT = os.path.splitext(fileName)

    AUTO.initialise(fileName)
    # inputFileTXT = open(fileName, 'br', encoding="latin-1", errors='ignore')
    inputFileTXT = open(fileName, 'r', encoding="latin-1", errors='ignore')
    for curLine in inputFileTXT:
        AUTO.parserLine(curLine)
    inputFileTXT.close()

    for traceQCT in AUTO.dicoTracesQCT.keys():
        AUTO.dicoTracesQCT[traceQCT].calculer()
    tmpStrDL, tmpStrUL = formatRecapVal()

    print("\n\nRESULT :")
    print('   tmpStrDL \n\t{}'.format(tmpStrDL))
    print('   tmpStrUL \n\t{}'.format(tmpStrUL))

    return (tmpStrDL, tmpStrUL)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('fileName', type=str,
                        help='fileName : file to be parsed')
    args = parser.parse_args()
    fileName = args.fileName
    parserQCT(fileName)
