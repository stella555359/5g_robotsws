from __future__ import absolute_import
from __future__ import print_function
import pandas as pd
import math
import numpy as np

headDict = {
    "RXHead1": "FSP,Time,antennaIndex,TimeOffet,Phase,antAmpRatio,final,smtTO,smtPhase\n",
    "RXHead2": "FSP,Time,hyperframe,frame,subframe,antIdx,TimeOffet,Phase,antAmpRatio,final,"
               "smtTO,smtPhase\n",
    "RXHead3": "FSP,Time,hyperframe,frame,subframe,lncellId,port,TimeOff,Phase,tmpRatio,"
               "AmpRatio,smtTO,smtPhase,Ep/No,peak\n",
    "RCHead1": "FSP,Ant,Ep/No\n",
    "TXHead1": "FSP,Time,caliSetIdx,AntIdx,TimeOff,Phase,AmpRatio,smtTO,smtPhase,Ep/No,peak\n",
    "TXHead2": "FSP,Time,hyperframe,frame,subframe,cellIdx,caliSetIdx,AntIdx,TimeOff,Phase,"
               "AmpRatio,smtTO,smtPhase,Ep/No,peak\n",
    "TXHead3": "FSP,Time,hyperframe,frame,subframe,lncellId,port,TimeOff,Phase,tmpRatio,"
               "amp,smtTO,smtPhase,Ep/No,peak\n",
    "FTXHead1": "FSP,Time,frame,slot,symbol,cellIndex,caliSetIdx,antIdx,finalAmpRatio,finalAmpRatioQ15,"
                "Ep/No\n",
    "FTXHead2": "FSP,Time,hyperframe,frame,subframe,cellIndex,caliSetIdx,antIdx,finalAmpRatio,"
                "finalAmpRatioQ15,Ep/No,minAnt\n",
    "FTXHead3": "FSP,Time,hyperframe,frame,subframe,lncellId,port,AmpRatio,minPort\n",
    "RCHead1": "FSP,Ant, Ep/No\n",
    "RXAmpHead": "FSP,Time,hyperframe,frame,subframe,lncellId,port,scaling,amp\n",
}

RXregDict = {
    r".*FSP-(\d+).*<(.*)>.*antennaIndex=(\d+),TimeOffet=([-]?\d+),antPhaseOff=([-]?\d.*),"
    r"antAmpRatio=([-]?.*),final=([-]?.*),smtTO=([-]?\d.*),smtPhase=([-+]?[0-9]*\.?[0-9]+),g_.*": [
        "self.RXreg",
        "RXHead1",
    ],
    r".*FSP-(\d+).*<(.*)>.*RC:SFN:(\d+).(\d+).(\d+).*andIdx=(\d+),TO=([-]?\d+),PhaseOff=([-]?\d.*),"
    r"AmpRatio=([-]?.*),final=([-]?.*),smtTO=([-]?\d.*),smtPhase=([-]?\d.*).*": [
        "self.RXreg",
        "RXHead2",
    ],
    r".*FSP-(\d+).*<(.*)>.*RC:SFN:(\d+).(\d+).(\d+).*lncellId=(\d+),port=(\d+),TO=([-]?\d+),"
    r"Phase=([-]?\d.*),tmpRatio=([-]?.*),AmpRatio=([-]?.*),smtTO=([-]?\d.*),smtPhase=([-]?\d.*),"
    r"Ep/No=([-]?\d.*),peak=([-]?\d+).": [
        "self.RXreg",
        "RXHead3",
    ],
    r".*ASP-.*?-Disp_(\d+).*<(.*)>.*RC:SFN:(\d+).(\d+).(\d+).*lncellId=(\d+),port=(\d+),TO=([-]?\d+),"
    r"Phase=([-]?\d.*),tmpRatio=([-]?.*),AmpRatio=([-]?.*),smtTO=([-]?\d.*),smtPhase=([-]?\d.*),"
    r"Ep/No=([-]?\d.*),peak=([-]?\d+).": [
        "self.RXreg",
        "RXHead3",
    ]
}
TXregDict = {
    r".*FSP-(\d+).*<(.*)>.*TC:SFN.*caliSetIdx (\d+),AntIdx\((\d+)\):TimeOff=([-]?\d.*),"
    r"antPhaseOff=([-]?\d.*),AmpRatio=([-]?\d.*),smtTO=([-]?\d+),smtPhase=([-]?\d.*),"
    r"Ep/No\(dB\)\(peak\)=([-]?\d.*)\(([-]?\d+)\).*": [
        "self.TXreg",
        "TXHead1",
    ],
    r".*FSP-(\d+).*<(.*)>.*TC:SFN:(\d+).(\d+).(\d+),cellIdx=(\d+),caliSetIdx=(\d+),"
    r"AntIdx=(\d+),TimeOff=([-]?\d.*),antPhaseOff=([-]?\d.*),AmpRatio=([-]?\d.*),smtTO=([-]?\d+),"
    r"smtPhase=([-]?\d.*),Ep/No\(dB\)\(peak\)=([-]?\d.*)\(([-]?\d+)\).*": [
        "self.TXreg",
        "TXHead2",
    ],
    r".*FSP-(\d+).*<(.*)>.*TC:SFN:(\d+).(\d+).(\d+),lncellId=(\d+),port=(\d+),TO=([-]?\d.*),"
    r"Phase=([-]?\d.*),tmpRatio=([-]?\d.*),amp=([-]?\d.*),smtTO=([-]?\d+),smtPhase=([-]?\d.*),"
    r"Ep/No=([-]?\d.*),peak=([-]?\d+).": [
        "self.TXreg",
        "TXHead3",
    ],
    r".*ASP-.*?-Disp_(\d+).*<(.*)>.*TC:SFN:(\d+).(\d+).(\d+),lncellId=(\d+),port=(\d+),"
    r"TO=([-]?\d.*),Phase=([-]?\d.*),tmpRatio=([-]?\d.*),amp=([-]?\d.*),smtTO=([-]?\d+),"
    r"smtPhase=([-]?\d.*),Ep/No=([-]?\d.*),peak=([-]?\d+).": [
        "self.TXreg",
        "TXHead3",
    ]
}
finaliTXregDict = {
    r".*FSP-(\d+).*<(.*)>.*TC:SFN:(\d+),Slot:(\d+),Sym:(\d+),cellIndex=(\d+),caliSetIdx=(\d+),"
    r"AntIdx\((\d+)\):FinalAmpRatio=([-]?.*),finalAmpRatioQ15=(\d+),Ep/No\(dB\)=([-]?\d.*)\(AntIdx.*": [
        "self.FinaliTXreg",
        "FTXHead1",
    ],
    r".*FSP-(\d+).*<(.*)>.*TC:SFN:(\d+).(\d+).(\d+),cellIdx=(\d+),caliSetIdx=(\d+),AntIdx=(\d+),"
    r"FinalAmpRatio=([-]?.*),finalAmpRatioQ15=(\d+),Ep/No\(dB\)=([-]?\d.*)\(minAnt=(\d+),.*": [
        "self.FinaliTXreg",
        "FTXHead2",
    ],
    r".*FSP-(\d+).*<(.*)>.*TC:SFN:(\d+).(\d+).(\d+),lncellId=(\d+),port=(\d+),ampRatio=([-]?.*),"
    r"minPort=(\d+).": [
        "self.FinaliTXreg",
        "FTXHead3",
    ]
    # TC:SFN:30.361.6,lncellId=1,port=0,ampRatio=0.9979,minPort=4.
}

RXAmpDict = {
    r".*FSP-(\d+).*<(.*)>.*RC:SFN:(\d+).(\d+).(\d+),lnCellId=(\d+),port=(\d+),"
    r"scaling=(\d+),amp=([-]?\d*[.]?\d*)": [
        "self.RXAmpreg",
        "RXAmpHead",
    ],
    r".*ASP-.*?-Disp_(\d+).*<(.*)>.*RC:SFN:(\d+).(\d+).(\d+),lnCellId=(\d+),port=(\d+),"
    r"scaling=(\d+),amp=([-]?\d*[.]?\d*)": [
        "self.RXAmpreg",
        "RXAmpHead",
    ],
}

BWDict = {"10M": 0.009, "15M": 0.00135, "20M": 0.0018}

JudgeRules = {
    "8pipe": {
        "RX": {
            "Ep/No": {"10M": 15.5, "15M": 17.5, "20M": 17.5},
            "tmpRatio": [0.707, 1.414],
            "AmpRatio": [0.708, 1],
            "calibrationdegree": 5.0,
        },
        "TX": {
            "Ep/No": {"10M": 15.5, "15M": 17.5, "20M": 17.5},
            "tmpRatio": [0.707, 1.414],
            "AmpRatio": [0.708, 1],
            "calibrationdegree": 5.0,
        },
    },
    "mmimo": {
        "RX": {
            "Ep/No": {"10M": 30, "20M": 35},
            "tmpRatio": [0.707, 1],
            "AmpRatio": [0.707, 1],
            "calibrationdegree": 5.0,
        },
        "TX": {
            "Ep/No": {"10M": 20, "20M": 25},
            "tmpRatio": [0.707, 1.414],
            "AmpRatio": [0.708, 1],
            "calibrationdegree": 5.0,
        },
    },
}


class CheckCaliResult:
    def __init__(self, bandwidthInfo, checkType, isSCT=False):
        self.outputResultDict = {}
        self.isSCT = isSCT
        self.checkBandWidthInfo(bandwidthInfo)
        self.chartValDict = {}
        self.checkType = checkType
        self.changeEpNoMimVal()

    def changeEpNoMimVal(self):
        if self.isSCT and self.checkType == "mmimo":
            JudgeRules[self.checkType]["RX"]["Ep/No"] = {"10M": 17.5, "20M": 17.5}
            JudgeRules[self.checkType]["TX"]["Ep/No"] = {"10M": 17.5, "20M": 17.5}

    def checkBandWidthInfo(self, bandwidthInfo):
        bwKey = BWDict.keys()
        bandwidthInfo = bandwidthInfo.replace(" ", "").strip(";")
        if ":" not in bandwidthInfo:
            self.bandwidthInfo = bandwidthInfo.upper()
            if self.bandwidthInfo not in bwKey:
                raise Exception("Not support bandwidth except %s" % (",".join(bwKey)))
            return
        self.bandwidthInfo = {}
        for lncellidBw in bandwidthInfo.split(";"):
            lncellId, bw = lncellidBw.split(":")
            bw = bw.upper()
            self.bandwidthInfo[lncellId] = bw
            if bw not in bwKey:
                raise Exception("Not support bandwidth except %s" % (",".join(bwKey)))

    def checkCalibration(self, csvFile, calbirationtype):
        try:
            data = pd.read_csv(csvFile)
        except Exception as e:
            print(str(e))
            return
        lncellId = data["lncellId"].drop_duplicates()
        lncellId.index = range(len(lncellId))
        caliType = calbirationtype
        if calbirationtype.lower() == "ftx":
            caliType = "TX"
        elif calbirationtype.lower() == "rxamp":
            caliType = "RX"
        if not self.isSCT and caliType not in self.chartValDict.keys():
            self.chartValDict[caliType] = {}
        for i in range(0, len(lncellId)):
            lnCellIdVal = lncellId[i]
            lnCellIdVal = str(lnCellIdVal)
            if not self.isSCT and lnCellIdVal not in self.chartValDict[caliType].keys():
                self.chartValDict[caliType][lnCellIdVal] = {}
            self.resultDict = {}
            key = "%s_%s" % (caliType, lncellId[i])
            if key not in self.outputResultDict.keys():
                self.outputResultDict[key] = [[], []]

            if calbirationtype.lower() in ["tx", "rx", "ftx"]:
                print(
                    "calbirationType is ",
                    calbirationtype,
                    ", lncellId is",
                    lncellId[i].item(),
                )
            tmpdata = data[(data["lncellId"] == lncellId[i])]
            tmpdata.index = range(len(tmpdata))
            self.getBandwidth(lnCellIdVal)

            if calbirationtype.lower() in ["ftx", "rxamp"]:
                self.checkAllPortFinal(tmpdata, caliType, lnCellIdVal)
            else:
                self.checkAllPort(tmpdata, calbirationtype, lnCellIdVal)
            sorted(
                self.resultDict.items(), reverse=True
            )  # lambda x, y: cmp(x[0], y[0]))
            for port, ret in self.resultDict.items():
                port = int(port)
                if ret != "Ok":
                    print("*FAIL*port:%s is %s" % (port, ret))
                    ret = "NOk"
                if port in self.outputResultDict[key][0] and ret == "NOk":
                    index = self.outputResultDict[key][0].index(port)
                    self.outputResultDict[key][1][index] = ret
                    continue
                if port not in self.outputResultDict[key][0]:
                    self.maxPort = max(int(port), self.maxPort)
                    self.outputResultDict[key][0].append(int(port))
                    self.outputResultDict[key][1].append(ret)

    def getBandwidth(self, lncellId):
        try:
            if isinstance(self.bandwidthInfo, str):
                self.bandwidth = self.bandwidthInfo
            else:
                self.bandwidth = self.bandwidthInfo[lncellId]
            self.bwVal = BWDict[self.bandwidth]
        except Exception as e:
            msg = "lncellId %s have no bandwidth information." % (lncellId)
            raise Exception(msg)

    def checkAllPortFinal(self, data, key, lnCellIdVal):
        Allport = data["port"].drop_duplicates().sort_values()
        Allport.index = range(len(Allport))
        for i in range(0, len(Allport)):
            portIdVal = Allport[i]
            if portIdVal < 0 or portIdVal > 64:
                continue
            tmpPortData = data[(data["port"] == Allport[i])]
            tmpPortData.index = range(len(tmpPortData))
            if key.lower() == "rx":
                if not self.isSCT:
                    self.chartValDict[key][lnCellIdVal][portIdVal][
                        "Amp"
                    ] = self.getList("amp", tmpPortData)
                    self.chartValDict[key][lnCellIdVal][portIdVal][
                        "absoluteAmp"
                    ] = self.getAbsoluteAmp("amp", "scaling", tmpPortData)
                continue
            ret = self.checkFinalratio(tmpPortData, "TX")
            self.resultDict[portIdVal] = ret
            if not self.isSCT:
                self.chartValDict[key][lnCellIdVal][portIdVal][
                    "AmpRatio"
                ] = self.getList("AmpRatio", tmpPortData)

    def checkAllPort(self, data, calbirationtype, lnCellIdVal):
        Allport = data["port"].drop_duplicates().sort_values()
        Allport.index = range(len(Allport))
        for i in range(0, len(Allport)):
            portIdVal = Allport[i]
            if portIdVal < 0 or portIdVal > 64:
                continue
            tmpPortData = data[(data["port"] == Allport[i])]
            tmpPortData.index = range(len(tmpPortData))
            # tmpPortData.loc[((tmpPortData['Phase']>= -180)&(tmpPortData['Phase']<=-175)), 'Phase'] += 360
            tmpdata = [x / 180 * np.pi for x in tmpPortData["Phase"]]
            tmpPortData["Phase"] = [x / np.pi * 180 for x in np.unwrap(tmpdata)]
            ret = self.checkPort(tmpPortData, calbirationtype)
            # portId
            if not self.isSCT and calbirationtype.lower() in ["tx", "rx"]:
                self.chartValDict[calbirationtype][lnCellIdVal][portIdVal] = {}
                self.getChartValByPort(
                    calbirationtype, lnCellIdVal, portIdVal, tmpPortData
                )
            self.resultDict[portIdVal] = ret

    def getChartValByPort(self, calbirationtype, lnCellIdVal, portIdVal, portdata):
        self.chartValDict[calbirationtype][lnCellIdVal][portIdVal][
            "EpNo"
        ] = self.getList("Ep/No", portdata)
        self.chartValDict[calbirationtype][lnCellIdVal][portIdVal]["TO"] = self.getList(
            "TimeOff", portdata
        )
        self.chartValDict[calbirationtype][lnCellIdVal][portIdVal][
            "smtTO"
        ] = self.getList("smtTO", portdata)
        self.chartValDict[calbirationtype][lnCellIdVal][portIdVal][
            "Phase"
        ] = self.getList("Phase", portdata)
        self.chartValDict[calbirationtype][lnCellIdVal][portIdVal][
            "smtPhase"
        ] = self.getList("smtPhase", portdata)
        self.chartValDict[calbirationtype][lnCellIdVal][portIdVal][
            "AmpRatio"
        ] = self.getList("AmpRatio", portdata)
        self.chartValDict[calbirationtype][lnCellIdVal][portIdVal][
            "Amp"
        ] = self.getList("amp", portdata)
        self.chartValDict[calbirationtype][lnCellIdVal][portIdVal][
            "peak"
        ] = self.getList("peak", portdata)
        self.chartValDict[calbirationtype][lnCellIdVal][portIdVal][
            "Time"
        ] = self.getList("Time", portdata)
        self.chartValDict[calbirationtype][lnCellIdVal][portIdVal]["absoluteAmp"] = []

    def getAbsoluteAmp(self, dividendKey, divisorKey, portdata):
        retList = []
        if dividendKey in portdata.keys() and divisorKey in portdata.keys():
            dividenList = portdata[dividendKey].values.tolist()
            divisorList = portdata[divisorKey].values.tolist()
            for index, divisorVal in enumerate(divisorList):
                absoluteAmp = float(dividenList[index]) / float(divisorVal)
                # absoluteAmp = ("%.4f" %absoluteAmp)
                retList.append(absoluteAmp)
        return retList

    def getList(self, key, portdata):
        retList = []
        if key in portdata.keys():
            retList = portdata[key].values.tolist()
            if key != "Time":
                retList = [float(i) for i in retList]
        return retList

    def checkFinalratio(self, portdata, calbirationtype):
        AmpRatioMinVal, AmpRatioMaxVal = JudgeRules[self.checkType][calbirationtype][
            "AmpRatio"
        ]
        if (
            portdata["AmpRatio"].min() < AmpRatioMinVal
            and portdata["AmpRatio"].max() > AmpRatioMaxVal
        ):
            return "NOk:calibration tmp ampRatio not in %s to %s" % (
                AmpRatioMinVal,
                AmpRatioMaxVal,
            )
        else:
            return "Ok"

    def checkPort(self, portdata, calbirationtype):
        # Ep/No
        epnoMinVal = JudgeRules[self.checkType][calbirationtype]["Ep/No"][
            self.bandwidth
        ]
        if self.isSCT:
            portdata = portdata[portdata["Ep/No"] > 0]

        if len(portdata["Ep/No"]) == 0 or portdata["Ep/No"].min() < epnoMinVal:
            return "NOk:calibration epno smaller than %sdb" % (epnoMinVal)
        # tmpRatio
        tmpRatioMinVal, tmpRatioMaxVal = JudgeRules[self.checkType][calbirationtype][
            "tmpRatio"
        ]

        if (
            portdata["tmpRatio"].min() < tmpRatioMinVal
            or portdata["tmpRatio"].max() > tmpRatioMaxVal
        ):
            return "NOk:calibration tmp ampRatio not in %s to %s" % (
                tmpRatioMinVal,
                tmpRatioMaxVal,
            )

        elif calbirationtype == "RX":
            # AmpRatio
            return self.checkFinalratio(portdata, calbirationtype)

        # portdata.loc[((portdata['Phase']>= -180)&(portdata['Phase']<=-175)), 'Phase'] += 360

        if self.checkType == "mmimo":
            calibrationdegree = math.sqrt(
                portdata["TimeOff"].var() * pow(2 * self.bwVal, 2) * 18
                + portdata["Phase"].var()
            )
        elif self.checkType == "8pipe":
            calibrationdegree = math.sqrt(
                portdata["TimeOff"].var() * pow(2 * self.bwVal, 2)
                + portdata["Phase"].var()
            )

        degreeVal = JudgeRules[self.checkType][calbirationtype]["calibrationdegree"]
        if calibrationdegree > 5.0:
            return "NOk:calibration degree bigger than %s" % (degreeVal)
        else:
            return "Ok"
