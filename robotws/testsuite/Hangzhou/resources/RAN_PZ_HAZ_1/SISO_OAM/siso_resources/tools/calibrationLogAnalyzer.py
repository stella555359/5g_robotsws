__author__ = "j6feng"

import gzip
import os
import random
import re
import shutil
import sys
import tarfile
import zipfile
from math import pi
from optparse import OptionParser

from bokeh.colors import RGB
from bokeh.layouts import column
from bokeh.layouts import layout
from bokeh.models import (
    CustomJS,
    ColumnDataSource,
    HoverTool,
    Legend,
    LegendItem,
    DatetimeTickFormatter,
    FixedTicker,
)
from bokeh.models.widgets import Select, Button
from bokeh.plotting import figure, output_file, save

from caliRegConditions import *


class UnZipFile:
    def __init__(self):
        self.logList = []
        self.temp7zList = []
        self.num7z = 0

    def run(self, zipFilename, logPath):
        fileSuffix = os.path.splitext(zipFilename)[-1].lower()
        if fileSuffix in [".zip"]:
            self.zipFile(zipFilename, logPath)
        elif fileSuffix in [".tgz"]:
            self.tgzFile(zipFilename, logPath)
        elif fileSuffix in [".gz"]:
            self.gzFile(zipFilename, logPath)
        elif fileSuffix in [".7z"]:
            self.zFile(zipFilename, logPath)
        else:
            print("not support unzip except for *.zip, *.tgz, *.gz, *.7z")

    def tgzFile(self, zipFilename, logPath):
        print(("Begin to unzip tgz files: %s" % (zipFilename)))
        tar = tarfile.open(zipFilename)
        for filename in tar.getnames():
            print(filename)
            tar.extract(filename, logPath)
            self.treeUnZipFiles(filename, logPath)

    def zipFile(self, zipFilename, logPath):
        print(("Begin to unzip zip files: %s" % (zipFilename)))
        btszipfile = zipfile.ZipFile(zipFilename, "r")
        for filename in btszipfile.namelist():
            print(filename)
            btszipfile.extract(filename, logPath)
            self.treeUnZipFiles(filename, logPath)

    def gzFile(self, zipFilename, logPath):
        print(("Begin to unzip gz files: %s" % (zipFilename)))
        filename = os.path.basename(zipFilename)
        filename = os.path.join(logPath, filename.replace(".gz", ""))
        gFile = gzip.GzipFile(zipFilename)
        open(filename, "w+").write(gFile.read())
        gFile.close()
        self.logList.append(filename)

    def zFile(self, zipFilename, logPath):
        if self.num7z:
            print("Do not support the recursion unzip the files")
            return
        self.num7z += 1
        print(("Begin to unzip 7z files: %s" % (zipFilename)))
        tempDir = os.path.join(logPath, "tempDir")
        os.mkdir(tempDir)
        try:
            cmd = "7za e %s -aoa -o%s" % (zipFilename, tempDir)
            print(("cmd is %s" % (cmd)))
            os.system(cmd)
            for filename in os.listdir(tempDir):
                if os.path.isdir(filename):
                    os.rmdir(filename)
                    continue
                print(("%s move to %s" % (filename, logPath)))
                shutil.move(os.path.join(tempDir, filename), logPath)
                self.treeUnZipFiles(filename, logPath)
        except Exception as e:
            raise e
        os.rmdir(tempDir)

    def treeUnZipFiles(self, filename, logPath):
        fileSuffix = os.path.splitext(filename)[-1].lower()
        logfile = os.path.join(logPath, filename)
        if fileSuffix in [".zip", ".tgz", ".gz", ".7z"]:
            self.run(logfile, logPath)
            os.remove(logfile)
        elif fileSuffix in [".log"]:
            self.logList.append(logfile)


class CalibrationLog:
    def __init__(self, bandwidthInfo, zipFilename, resultPath, checkType):
        self.resultPath = resultPath
        self.checkCaliResult = CheckCaliResult(bandwidthInfo, checkType)
        self.execUnZip = UnZipFile()
        self.logList = []

        if os.path.splitext(zipFilename)[-1].lower() == ".log":
            self.logList.append(zipFilename)
        else:
            self.execUnZip.run(zipFilename, os.path.dirname(zipFilename))
            self.logList = self.execUnZip.logList

        print(("calibration log is: ", self.logList))

    def findAndAnalyzer(self):
        print(self.logList)
        for logfile in self.logList:
            self.tempRegDict = None
            self.rxdataflag = True
            self.txdataflag = True
            self.txfinalflag = True
            self.rxAmpdataflag = True
            self.checkCaliResult.maxPort = 0
            fileHead = os.path.splitext(os.path.basename(logfile))[0]
            print(fileHead)
            rxFile = os.path.join(self.resultPath, fileHead + "_rxdata.csv")
            rxAmpFile = os.path.join(self.resultPath, fileHead + "_rxAmpdata.csv")
            txFile = os.path.join(self.resultPath, fileHead + "_txdata.csv")
            finalitxFile = os.path.join(self.resultPath, fileHead + "_finalitxdata.csv")
            resultCsv = os.path.join(self.resultPath, fileHead + "_result.csv")
            outputFile = os.path.join(self.resultPath, fileHead + "_result.html")
            output_file(outputFile)
            rxdata = open(rxFile, "wb")
            rxAmpdata = open(rxAmpFile, "wb")
            txdata = open(txFile, "wb")
            finalitxdata = open(finalitxFile, "wb")

            self.RXregDict = RXregDict
            self.TXregDict = TXregDict
            self.finaliTXregDict = finaliTXregDict
            self.RXAmpDict = RXAmpDict

            self.analyzer(logfile, rxdata, txdata, finalitxdata, rxAmpdata)
            print(rxdata)
            rxdata.close()
            rxAmpdata.close()
            txdata.close()
            finalitxdata.close()
            # try:
            self.checkCaliResult.outputResultDict = {}
            self.checkCaliResult.checkCalibration(txFile, "TX")
            self.checkCaliResult.checkCalibration(finalitxFile, "FTX")
            self.checkCaliResult.checkCalibration(rxFile, "RX")
            self.checkCaliResult.checkCalibration(rxAmpFile, "RXAmp")
            self.outputResult(logfile, resultCsv)
            drawChart(self.checkCaliResult.chartValDict)
            # except Exception, e:
            #     print "Failed to check %s:%s" %(logfile,str(e))

    def outputResult(self, logfile, resultCsv):
        filename = os.path.basename(logfile)
        print(("==================%s==================" % (filename)))
        resultData = open(resultCsv, "wb")
        portList = [
            str(port).rjust(4) for port in range(self.checkCaliResult.maxPort + 1)
        ]
        msg1 = "%s%s%s" % ("LnCellID".rjust(10), "Type".rjust(5), "".join(portList))
        print(msg1)
        resultData.write((",".join(msg1.split()) + "\n").encode())

        for key, val in list(self.checkCaliResult.outputResultDict.items()):
            cliaType, lnCellId = key.split("_")
            portIdList = val[0]
            retList = val[1]
            msg2 = "%s%s" % (lnCellId.rjust(10), cliaType.rjust(5))
            for port in range(self.checkCaliResult.maxPort + 1):
                if len(portIdList) == 0:
                    break
                if port not in portIdList:
                    msg2 = "%s%s" % (msg2, "-".rjust(4))
                    continue
                ret = retList.pop(0)
                msg2 = "%s%s" % (msg2, ret.rjust(4))
                portIdList.pop(0)
                self.changeChartValDict(cliaType, lnCellId, port, ret)
            print(msg2)
            resultData.write((",".join(msg2.split()) + "\n").encode())
        resultData.close()

    def changeChartValDict(self, cliaType, lnCellId, port, ret):
        if ret == "Ok":
            newPort = "%s" % (port)
        else:
            newPort = "%s*" % (port)
        self.checkCaliResult.chartValDict[cliaType][lnCellId][
            newPort
        ] = self.checkCaliResult.chartValDict[cliaType][lnCellId].pop(port)

    def analyzer(self, file, rxdata, txdata, finalitxdata, rxAmpdata):
        with open(file) as h:
            lines = h.readlines()
            for line in lines:
                self.isMatch = "no"
                if (
                    "ULPHY/CALIB" not in line
                    and "PrintRxCalibrationInfo" not in line
                    and "PrintTxCalibrationCoeffInfo" not in line
                ):
                    continue
                line = line.replace("<br>", "")
                if self.isMatch == "no" and "RC:SFN:" in line:
                    self.run(self.RXregDict, line, rxdata)
                    self.RXregDict = self.tempRegDict
                    if self.isMatch == "no":
                        self.run(self.RXAmpDict, line, rxAmpdata)
                        self.RXAmpDict = self.tempRegDict

                if self.isMatch == "no" and "TC:SFN:" in line:
                    self.run(self.TXregDict, line, txdata)
                    self.TXregDict = self.tempRegDict
                    if self.isMatch == "no":
                        self.run(self.finaliTXregDict, line, finalitxdata)
                        self.finaliTXregDict = self.tempRegDict

    def run(self, regDict, line, data):
        for regVal, [func, fileHead] in list(regDict.items()):
            matchgroup = re.match(r"{regVal}".format(regVal=regVal), line)
            if matchgroup:
                self.runFunc(eval(func), matchgroup, data, fileHead)
                self.isMatch = "yes"
                self.tempRegDict = {regVal: [func, fileHead]}
                return
        self.tempRegDict = regDict

    def runFunc(self, func, matchgroup, data, fileHead):
        func(matchgroup, data, fileHead)

    def RXreg(self, matchgroup, rxdata, fileHead):
        tempDataList = []
        if self.rxdataflag:
            rxdata.write(headDict[fileHead].encode())
            self.rxdataflag = False
        self.writeContent(matchgroup, rxdata)

    def RXAmpreg(self, matchgroup, rxAmpdata, fileHead):
        tempDataList = []
        if self.rxAmpdataflag:
            rxAmpdata.write(headDict[fileHead].encode())
            self.rxAmpdataflag = False
        self.writeContent(matchgroup, rxAmpdata)

    def TXreg(self, matchgroup, txdata, fileHead):
        if self.txdataflag:
            txdata.write(headDict[fileHead].encode())
            self.txdataflag = False
        self.writeContent(matchgroup, txdata)

    def FinaliTXreg(self, matchgroup, finalitxdata, fileHead):
        if self.txfinalflag:
            finalitxdata.write((headDict[fileHead]).encode())
            self.txfinalflag = False
        self.writeContent(matchgroup, finalitxdata)

    def writeContent(self, matchgroup, fileData):
        tempDataList = []
        for x in range(1, matchgroup.lastindex + 1):
            tempDataList.append(matchgroup.group(x))
        fileData.write((",".join(tempDataList) + "\n").encode())


def getPlotValByPortId(portIdList, portIdDict, chartType):
    xs = []
    ys = []
    for portId in portIdList:
        valList = portIdDict[portId][chartType]
        ys.append(valList)
        xs.append(portIdDict[portId]["Time"])
    return [xs, ys]


def getTempDictAndMaxLen(valDict, tempDir, key, chartType):
    ys = valDict[chartType]
    xs = pd.to_datetime(valDict["Time"])
    tempDir[key] = [xs, ys]


def rewriteTempDict(tempDir, txDict, rxDict, txrx):
    if txrx.lower() == "tx":
        txDict.update(tempDir)
    elif txrx.lower() == "rx":
        rxDict.update(tempDir)


def getTicker(timeList):
    start = timeList[0]
    start = start.split(":")[0] + ":" + start.split(":")[1] + ":" + "00"
    start = int(round(pd.to_datetime(start).timestamp() * 1000)) - 60000
    end = (
        int(round(pd.to_datetime(timeList[len(timeList) - 1]).timestamp() * 1000))
        + 60000
    )
    time = []
    for i in range(start, end, 5000):
        time.append(i)
    return time


def drawChart(chartValDict):
    txrxOptionList = list(chartValDict.keys())
    rxtxSelect = Select(
        title="Rx/Tx",
        value=txrxOptionList[0],
        id="rxtx",
        options=txrxOptionList,
        width=250,
    )
    lnCellSelect = Select(title="LnCellID", id="lnCellId", width=250)

    rxtxOptionValue = rxtxSelect.value
    lnCellIdOptList = list(chartValDict[rxtxOptionValue].keys())
    lnCellSelect.value = lnCellIdOptList[0]
    lnCellSelect.options = lnCellIdOptList
    lnCellIdOptionValue = lnCellSelect.value

    portIdList = list(chartValDict[rxtxOptionValue][lnCellIdOptionValue].keys())
    portIdList.sort(key=lambda x: float(x.strip("*")))
    portIdDict = chartValDict[rxtxOptionValue][lnCellIdOptionValue]
    strPortIdList = [str(i) for i in portIdList]

    def createPlot(title, dataType):
        tools_to_show = "box_zoom,pan,save,reset,wheel_zoom"  # tap,

        # plot = figure(title=title,width=1500, height=500,tools=[tools_to_show])
        hover = HoverTool(
            tooltips=[("port:", "@name"), ("value:", "$y")], show_arrow=True
        )
        plot = figure(
            title=title,
            width=1500,
            height=500,
            tools=[hover, tools_to_show],
            x_axis_type="datetime",
        )
        plot.xaxis.formatter = DatetimeTickFormatter(
            microseconds=["%H:%M:%S"],
            milliseconds=["%H:%M:%S"],
            seconds=["%H:%M:%S"],
            minsec=["%H:%M:%S"],
            minutes=["%H:%M:%S"],
            hourmin=["%H:%M:%S"],
            hours=["%H:%M:%S"],
            days=["%H:%M:%S"],
            months=["%H:%M:%S"],
            years=["%H:%M:%S"],
        )
        plot.xaxis.major_label_orientation = pi / 4
        time = getTicker(portIdDict[portIdList[0]]["Time"])

        plot.xaxis.ticker = FixedTicker(ticks=time)

        colorList = []
        for i in range(len(portIdList)):
            colorList.append(
                RGB(
                    random.randint(0, 255),
                    random.randint(0, 255),
                    random.randint(0, 255),
                )
            )

        XS, YS = getPlotValByPortId(portIdList, portIdDict, dataType)

        legendItem1 = []
        legendItem2 = []
        for i, (x, y, color, label) in enumerate(zip(XS, YS, colorList, strPortIdList)):
            source = ColumnDataSource(
                data=dict(x=pd.to_datetime(x), y=y, name=[label] * len(x))
            )
            chart = plot.line("x", "y", source=source, color=color, name="name")
            # chart = plot.line(x, y, color=color)
            # plot.add_tools(HoverTool(renderers=[chart], tooltips=[('port', label),("value:", "$y")]))

            if len(strPortIdList) < 33:
                legendItem1.append(LegendItem(label=label, renderers=[chart]))
            else:
                if i < 32:
                    legendItem1.append(LegendItem(label=label, renderers=[chart]))
                else:
                    legendItem2.append(LegendItem(label=label, renderers=[chart]))
        if len(strPortIdList) < 33:
            for i in range(len(strPortIdList), 31):
                chart = plot.line([], [])
                legendItem1.append(LegendItem(label="", renderers=[]))
            for i in range(32, 64):
                chart = plot.line([], [])
                legendItem2.append(LegendItem(label="", renderers=[]))
        else:
            for i in range(len(strPortIdList), 64):
                chart = plot.line([], [])
                legendItem2.append(LegendItem(label="", renderers=[]))
        legend1 = Legend(items=legendItem1, location=(30, 20), orientation="horizontal")
        legend2 = Legend(items=legendItem2, location=(30, 10), orientation="horizontal")
        plot.add_layout(legend1, "below")
        plot.add_layout(legend2, "below")
        plot.legend.click_policy = "hide"
        plot.legend.glyph_width = 10
        return plot

    epnoPlot = createPlot("Ep/No", "EpNo")
    TOPlot = createPlot("TO", "TO")
    smtTOPlot = createPlot("smtTO", "smtTO")
    phasePlot = createPlot("PhasePlot", "Phase")
    smtPhasePlot = createPlot("smtPhase", "smtPhase")
    ampRatioPlot = createPlot("AmpRatio", "AmpRatio")
    ampPlot = createPlot("Amp", "Amp")
    peakPlot = createPlot("Peak", "peak")
    absoluteAmpPlot = createPlot("absolute Amp", "absoluteAmp")

    selectAllButton = Button(label="select all", button_type="primary")
    clearAllButton = Button(label="clear all", button_type="primary")

    chartAndTXRXDict = {}
    portIdDict = {}

    epnoTxDict = {}
    epnoRxDict = {}
    toTxDict = {}
    toRxDict = {}
    smtTOTxDict = {}
    smtTORxDict = {}
    phaseTxDict = {}
    phaseRxDict = {}
    smtPhaseTxDict = {}
    smtPhaseRxDict = {}
    ampRatioTxDict = {}
    ampRatioRxDict = {}
    ampTxDict = {}
    ampRxDict = {}
    peakTxDict = {}
    peakRxDict = {}
    absoluteAmpRxDict = {}
    absoluteAmpTxDict = {}

    for txrx, lnCellDict in list(chartValDict.items()):
        chartAndTXRXDict[txrx] = list(chartValDict[txrx].keys())
        epnoTempDict = {}
        toTempDict = {}
        smtTOTempDict = {}
        phaseTempDict = {}
        smtPhaseTempDict = {}
        ampRatioTempDict = {}
        ampTempDict = {}
        peakTempDict = {}
        absoluteAmpTempDict = {}

        for lncellId in lnCellDict:
            key = "%s_%s" % (txrx, lncellId)
            portIdList = list(lnCellDict[lncellId].keys())
            portIdList.sort(key=lambda x: float(x.strip("*")))
            val = [str(i) for i in portIdList]
            portIdDict[key] = val
            for portId in portIdList:
                key = "%s_%s_%s" % (txrx, lncellId, portId)
                valDict = lnCellDict[lncellId][portId]
                getTempDictAndMaxLen(valDict, epnoTempDict, key, "EpNo")
                getTempDictAndMaxLen(valDict, toTempDict, key, "TO")
                getTempDictAndMaxLen(valDict, smtTOTempDict, key, "smtTO")
                getTempDictAndMaxLen(valDict, phaseTempDict, key, "Phase")
                getTempDictAndMaxLen(valDict, smtPhaseTempDict, key, "smtPhase")
                getTempDictAndMaxLen(valDict, ampRatioTempDict, key, "AmpRatio")
                getTempDictAndMaxLen(valDict, ampTempDict, key, "Amp")
                getTempDictAndMaxLen(valDict, peakTempDict, key, "peak")
                getTempDictAndMaxLen(valDict, absoluteAmpTempDict, key, "absoluteAmp")

        rewriteTempDict(epnoTempDict, epnoTxDict, epnoRxDict, txrx)
        rewriteTempDict(toTempDict, toTxDict, toRxDict, txrx)
        rewriteTempDict(smtTOTempDict, smtTOTxDict, smtTORxDict, txrx)
        rewriteTempDict(phaseTempDict, phaseTxDict, phaseRxDict, txrx)
        rewriteTempDict(smtPhaseTempDict, smtPhaseTxDict, smtPhaseRxDict, txrx)
        rewriteTempDict(ampRatioTempDict, ampRatioTxDict, ampRatioRxDict, txrx)
        rewriteTempDict(ampTempDict, ampTxDict, ampRxDict, txrx)
        rewriteTempDict(peakTempDict, peakTxDict, peakRxDict, txrx)
        rewriteTempDict(absoluteAmpTempDict, absoluteAmpTxDict, absoluteAmpRxDict, txrx)

    lnCellDS = ColumnDataSource(data=chartAndTXRXDict)
    portIdDS = ColumnDataSource(data=portIdDict)

    epnoTxDS = ColumnDataSource(data=epnoTxDict)
    epnoRxDS = ColumnDataSource(data=epnoRxDict)

    toTxDS = ColumnDataSource(data=toTxDict)
    toRxDS = ColumnDataSource(data=toRxDict)

    smtTOTxDS = ColumnDataSource(data=smtTOTxDict)
    smtTORxDS = ColumnDataSource(data=smtTORxDict)

    phaseTxDS = ColumnDataSource(data=phaseTxDict)
    phaseRxDS = ColumnDataSource(data=phaseRxDict)

    smtPhaseTxDS = ColumnDataSource(data=smtPhaseTxDict)
    smtPhaseRxDS = ColumnDataSource(data=smtPhaseRxDict)

    ampRatioTxDS = ColumnDataSource(data=ampRatioTxDict)
    ampRatioRxDS = ColumnDataSource(data=ampRatioRxDict)

    ampTxDS = ColumnDataSource(data=ampTxDict)
    ampRxDS = ColumnDataSource(data=ampRxDict)

    peakTxDS = ColumnDataSource(data=peakTxDict)
    peakRxDS = ColumnDataSource(data=peakRxDict)

    absoluteAmpTxDS = ColumnDataSource(data=absoluteAmpTxDict)
    absoluteAmpRxDS = ColumnDataSource(data=absoluteAmpRxDict)

    def commonCallback(
        rxtxSource=rxtxSelect,
        lnCellSource=lnCellSelect,
        lnCellSourceVal=lnCellDS,
        portIdSourceVal=portIdDS,
        epnoPlotSource=epnoPlot,
        epnoTxSourceVal=epnoTxDS,
        epnoRxSourceVal=epnoRxDS,
        toPlotSource=TOPlot,
        toTxSourceVal=toTxDS,
        toRxSourceVal=toRxDS,
        smtToPlotSource=smtTOPlot,
        smtToTxSourceVal=smtTOTxDS,
        smtToRxSourceVal=smtTORxDS,
        phasePlotSource=phasePlot,
        phaseTxSourceVal=phaseTxDS,
        phaseRxSourceVal=phaseRxDS,
        smtPhasePlotSource=smtPhasePlot,
        smtPhaseTxSourceVal=smtPhaseTxDS,
        smtPhaseRxSourceVal=smtPhaseRxDS,
        ampRatioPlotSource=ampRatioPlot,
        ampRatioTxSourceVal=ampRatioTxDS,
        ampRatioRxSourceVal=ampRatioRxDS,
        ampPlotSource=ampPlot,
        ampTxSourceVal=ampTxDS,
        ampRxSourceVal=ampRxDS,
        peakPlotSource=peakPlot,
        peakTxSourceVal=peakTxDS,
        peakRxSourceVal=peakRxDS,
        absoluteAmpPlotSource=absoluteAmpPlot,
        absoluteAmpTxSourceVal=absoluteAmpTxDS,
        absoluteAmpRxSourceVal=absoluteAmpRxDS,
    ):
        val = cb_obj.value
        if val in ("TX", "RX"):
            txrx = val
            lnCellData = lnCellSourceVal.data
            lnCellDataList = lnCellData[txrx]
            lnCellSource.options = lnCellDataList
            lnCellSource.change.emit()
            lnCell = lnCellSource.value
        else:
            txrx = rxtxSource.value
            lnCell = val

        # portId
        portIdData = portIdSourceVal.data
        key = "%s_%s" % (txrx, lnCell)
        if val in ("TX", "RX"):
            if not portIdData[key]:
                lnCell = lnCellDataList[0]
                key = "%s_%s" % (txrx, lnCell)
        portIdData = portIdData[key]

        def changePlot(plotSource, valTxSource, valRxSource, txrx, lnCell, portIdData):

            line_rend = [
                rend
                for rend in plotSource.renderers
                if rend.__proto__.type == "GlyphRenderer"
            ]
            legend_rend = [
                rend for rend in plotSource.renderers if rend.__proto__.type == "Legend"
            ]

            for line in range(0, len(line_rend)):
                line_rend[line].attributes.data_source.data["x"] = ""
                line_rend[line].attributes.data_source.data["y"] = ""
                line_rend[line].attributes.data_source.change.emit()

            for legend in range(0, len(legend_rend)):
                for item in range(0, len(legend_rend[legend].items)):
                    legend_rend[legend].items[item].attributes.label["value"] = ""
                    legend_rend[legend].items[item].attributes.renderers = []

            if txrx.lower() == "tx":
                data = valTxSource.data
            elif txrx.lower() == "rx":
                data = valRxSource.data
            i = 0
            for portId in portIdData:
                key = "%s_%s_%s" % (txrx, lnCell, portId)
                xs = data[key][0]
                ys = data[key][1]
                line_rend[i].attributes.data_source.data["x"] = xs
                line_rend[i].attributes.data_source.data["y"] = ys
                line_rend[i].attributes.data_source.data["name"] = [portId] * len(ys)

                line_rend[i].attributes.data_source.change.emit()
                if len(portIdData) < 33:
                    legend_rend[0].items[i].attributes.label["value"] = portId
                    legend_rend[0].items[i].attributes.renderers = [line_rend[i]]
                else:
                    if i < 32:
                        legend_rend[0].items[i].attributes.label["value"] = portId
                        legend_rend[0].items[i].attributes.renderers = [line_rend[i]]
                    else:
                        legend_rend[1].items[i - 32].attributes.label["value"] = portId
                        legend_rend[1].items[i - 32].attributes.renderers = [
                            line_rend[i]
                        ]
                i = i + 1

        # EpNoChart
        changePlot(
            epnoPlotSource, epnoTxSourceVal, epnoRxSourceVal, txrx, lnCell, portIdData
        )
        # # TO
        changePlot(toPlotSource, toTxSourceVal, toRxSourceVal, txrx, lnCell, portIdData)
        # # smtTO
        changePlot(
            smtToPlotSource,
            smtToTxSourceVal,
            smtToRxSourceVal,
            txrx,
            lnCell,
            portIdData,
        )
        # # phase
        changePlot(
            phasePlotSource,
            phaseTxSourceVal,
            phaseRxSourceVal,
            txrx,
            lnCell,
            portIdData,
        )
        # # smtPhase
        changePlot(
            smtPhasePlotSource,
            smtPhaseTxSourceVal,
            smtPhaseRxSourceVal,
            txrx,
            lnCell,
            portIdData,
        )
        # # ampRatio
        changePlot(
            ampRatioPlotSource,
            ampRatioTxSourceVal,
            ampRatioRxSourceVal,
            txrx,
            lnCell,
            portIdData,
        )
        # amp
        changePlot(
            ampPlotSource, ampTxSourceVal, ampRxSourceVal, txrx, lnCell, portIdData
        )
        # peak
        changePlot(
            peakPlotSource, peakTxSourceVal, peakRxSourceVal, txrx, lnCell, portIdData
        )
        # absoluteAmp
        changePlot(
            absoluteAmpPlotSource,
            absoluteAmpTxSourceVal,
            absoluteAmpRxSourceVal,
            txrx,
            lnCell,
            portIdData,
        )

    def selectAllCallback(
        epnoPlotSource=epnoPlot,
        toPlotSource=TOPlot,
        smtToPlotSource=smtTOPlot,
        phasePlotSource=phasePlot,
        smtPhasePlotSource=smtPhasePlot,
        ampRatioPlotSource=ampRatioPlot,
        ampPlotSource=ampPlot,
        peakPlotSource=peakPlot,
        absoluteAmpPlotSource=absoluteAmpPlot,
    ):
        def selectAll(plotSource):
            legend_rend = [
                rend for rend in plotSource.renderers if rend.__proto__.type == "Legend"
            ]
            for legend in range(0, len(legend_rend)):
                for item in range(0, len(legend_rend[legend].items)):
                    if legend_rend[legend].items[item].renderers[0]:
                        legend_rend[legend].items[item].renderers[0].visible = True

        selectAll(epnoPlotSource)
        selectAll(toPlotSource)
        selectAll(smtToPlotSource)
        selectAll(phasePlotSource)
        selectAll(smtPhasePlotSource)
        selectAll(ampRatioPlotSource)
        selectAll(ampPlotSource)
        selectAll(peakPlotSource)
        selectAll(absoluteAmpPlotSource)

    def clearAllCallback(
        epnoPlotSource=epnoPlot,
        toPlotSource=TOPlot,
        smtToPlotSource=smtTOPlot,
        phasePlotSource=phasePlot,
        smtPhasePlotSource=smtPhasePlot,
        ampRatioPlotSource=ampRatioPlot,
        ampPlotSource=ampPlot,
        peakPlotSource=peakPlot,
        absoluteAmpPlotSource=absoluteAmpPlot,
    ):
        def clearAll(plotSource):
            legend_rend = [
                rend for rend in plotSource.renderers if rend.__proto__.type == "Legend"
            ]
            for legend in range(0, len(legend_rend)):
                for item in range(0, len(legend_rend[legend].items)):
                    if legend_rend[legend].items[item].renderers[0]:
                        legend_rend[legend].items[item].renderers[0].visible = False

        clearAll(epnoPlotSource)
        clearAll(toPlotSource)
        clearAll(smtToPlotSource)
        clearAll(phasePlotSource)
        clearAll(smtPhasePlotSource)
        clearAll(ampRatioPlotSource)
        clearAll(ampPlotSource)
        clearAll(peakPlotSource)
        clearAll(absoluteAmpPlotSource)

    rxtxSelect.js_on_change("value", CustomJS.from_py_func(commonCallback))
    lnCellSelect.js_on_change("value", CustomJS.from_py_func(commonCallback))
    selectAllButton.js_on_click(CustomJS.from_py_func(selectAllCallback))
    clearAllButton.js_on_click(CustomJS.from_py_func(clearAllCallback))

    c = column(
        epnoPlot,
        TOPlot,
        smtTOPlot,
        phasePlot,
        smtPhasePlot,
        ampRatioPlot,
        ampPlot,
        peakPlot,
        absoluteAmpPlot,
    )
    log_a = layout([[rxtxSelect, lnCellSelect], [selectAllButton, clearAllButton], c])
    save(log_a)
    # show(log_a)


def get_user_paras():
    opt = OptionParser()
    opt.add_option(
        "--bw",
        type="string",
        action="store",
        dest="bandwidth",
        help="bandwidth, 10M:0.009,15M:0.00135,20M:0.0018",
    )
    opt.add_option(
        "--path",
        type="string",
        action="store",
        dest="path",
        help="The path to which the results are saved",
    )
    opt.add_option("--log", type="string", action="store", dest="logDir", help="syslog")
    opt.add_option(
        "--type",
        type="string",
        action="store",
        dest="type",
        help="support 8pipe(default), mmimo",
    )  # 8pipe default, mmimo
    (options, args) = opt.parse_args()
    bandwidthInfo = options.bandwidth
    resultPath = options.path
    zipFilename = options.logDir
    checkType = options.type
    if bandwidthInfo is None:
        bandwidthInfo = "20M"
    if checkType is None:
        checkType = "8pipe"
    if zipFilename is None:
        print("Parameter error")
        sys.exit(1)
    if resultPath is None:
        resultPath = os.path.dirname(zipFilename)
        if resultPath == "":
            resultPath = os.path.dirname(os.path.realpath(sys.argv[0]))
    return [bandwidthInfo, resultPath, zipFilename, checkType]


def get_syslog_result_without_unexpected_port(result, unexpected_port):
    a = result.split('\n')
    port_list = []
    rx_result_list = []
    for i in a:
        if 'LnCellID' in i:
            port_list = i.split(' ')
            while u'' in port_list:
                port_list.remove(u'')
        if 'RX' in i and 'Ok' in i:
            rx_result = i.split(' ')
            while u'' in rx_result:
                rx_result.remove(u'')
            rx_result_list.append(rx_result)
    print(port_list)
    print(rx_result_list)
    for i in unexpected_port:
        if str(i) in port_list:
            get_index = port_list.index(str(i))
            print(get_index)
            for j in range(len(rx_result_list)):
                rx_result_list[j].pop(get_index)
            port_list.pop(get_index)
    return rx_result_list


if __name__ == "__main__":
    bandwidthInfo, resultPath, zipFilename, checkType = get_user_paras()
    # zipFilename = "C:\\works\\A_TDLTE\CITA\\CIRelated\\SYSLOG_282.LOG"
    # resultPath = "C:\\works\\A_TDLTE\CITA\\CIRelated\\result"
    # bandwidthInfo = "20M"
    # checkType = "mmimo"
    checkType = checkType.lower()
    calibrationLog = CalibrationLog(bandwidthInfo, zipFilename, resultPath, checkType)
    calibrationLog.findAndAnalyzer()
