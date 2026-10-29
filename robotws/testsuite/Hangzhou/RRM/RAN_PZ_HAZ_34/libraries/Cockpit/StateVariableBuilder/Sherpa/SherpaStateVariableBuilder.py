import time
import os
import json
import socket
import threading
import pysftp
import subprocess
import shlex
import paramiko
import re
import sys
import traceback
import struct

from operator import itemgetter
from ...utilities.SortedCollection import SortedCollection


class TimeoutException(Exception):
    pass


class SherpaStateVariableBuilder:
    def __init__(
            self,
            tlInfo,
            sherpaFolder,
            tcpDestIp,
            tcpDestPort,
            sherpaMode="Collect"):
        self._sourceIp = tlInfo["l1l2monitor"]["hostname"]
        self._sourceUser = tlInfo["l1l2monitor"]["username"]
        self._sourcePassword = tlInfo["l1l2monitor"]["password"]
        self._sourceFolder = tlInfo["l1l2monitor"]["tcpDumpPath"]
        self._sourceItf = tlInfo["l1l2monitor"]["itf"]
        self._sherpaFolder = sherpaFolder
        self._sherpaMode = sherpaMode
        self._tcpDestIp = tcpDestIp
        self._tcpDestPort = tcpDestPort
        self._outSock = socket.socket(
            socket.AF_INET, socket.SOCK_STREAM)  # TCP
        self._outSock.connect((self._tcpDestIp, self._tcpDestPort))
        self._lastValue = {}
        self._eventStop = False
        self._cnopts = pysftp.CnOpts()
        self._cnopts.hostkeys = None
        self._transferredFile = []
        self._lastTransferredFile = None
        self._traceCollection = {}
        self._counters = {}
        self._startSherpaTraceCollection()
        threading.Thread(target=self._mainLoop).start()

    def _startSherpaTraceCollection(self):
        print("_startSherpaTraceCollection enter")
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(
            self._sourceIp,
            username=self._sourceUser,
            password=self._sourcePassword)

        transport = ssh.get_transport()
        channel = transport.open_session()
        channel.get_pty()
        channel.setblocking(1)

        channel.exec_command(
            'sudo -k -- sh -c "killall tcpdump; mkdir -p %s; rm %s/L1L2.pcap*; ls -ltr %s;'
            ' tcpdump -i %s -C 100 -B 9000 -w %s/L1L2.pcap -W 50"' %
            (self._sourceFolder,
             self._sourceFolder,
             self._sourceFolder,
             self._sourceItf,
             self._sourceFolder))
        # print("command executed")
        nbTriesLeft = 10
        while nbTriesLeft > 0:
            # print("recv_ready()==False")
            stdout = channel.recv(4096)
            print("channel.recv 1:", stdout.decode("UTF-8"))
            if re.search('[Pp]assword', stdout.decode("UTF-8")):
                channel.send(self._sourcePassword + '\n')
                nbTriesLeft = 0
                # print("password sent")
            time.sleep(1)
            nbTriesLeft -= 1

        # print("recv_ready()==True")
        while channel.recv_ready():
            stdout = channel.recv(20000)
            print("channel.recv 2:", stdout.decode("UTF-8"))

        channel.close()

        print("_startSherpaTraceCollection return")

        ssh.close()

    def stop(self):
        print("_stopSherpa enter")
        self._eventStop = True
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(
            self._sourceIp,
            username=self._sourceUser,
            password=self._sourcePassword)

        transport = ssh.get_transport()
        channel = transport.open_session()
        channel.get_pty()
        channel.setblocking(1)

        channel.exec_command('sudo -k killall tcpdump')
        # print("command executed")
        nbTriesLeft = 10
        while nbTriesLeft > 0:
            # print("recv_ready()==False")
            stdout = channel.recv(4096)
            print("channel.recv 1:", stdout.decode("UTF-8"))
            if re.search('[Pp]assword', stdout.decode("UTF-8")):
                channel.send(self._sourcePassword + '\n')
                nbTriesLeft = 0
                # print("password sent")
            time.sleep(1)
            nbTriesLeft -= 1

        # print("recv_ready()==True")
        while channel.recv_ready():
            stdout = channel.recv(20000)
            print("channel.recv 2:", stdout.decode("UTF-8"))

        channel.close()

        ssh.close()
        while (self._lastTransferredFile is not None):
            print("Waiting end of transfer for file %s\n" %
                  (self._lastTransferredFile[-11:]))
            time.sleep(1)

        self._outSock.close()

        print("_stopSherpa return")

    def getCounters(self):
        print("Sherpa Counters: ", self._counters)
        return (self._counters)

    def waitCounter(self, counterName, counterValue, timeOut):
        nbSeconds = 0
        while nbSeconds < timeOut:
            if counterName in self._counters:
                if self._counters[counterName] >= counterValue:
                    break
            time.sleep(1)
            nbSeconds += 1
        if nbSeconds >= timeOut:
            print("Sherpa Couters: ", self._counters)
            raise TimeoutException()
        return (self._counters[counterName])

    def _getLastFileToDecode(self):

        returnResult = None
        sftpConn = pysftp.Connection(
            host=self._sourceIp,
            username=self._sourceUser,
            password=self._sourcePassword,
            cnopts=self._cnopts)

        # Get the directory and file listing
        dirList = sftpConn.listdir(self._sourceFolder)

        if len(dirList) > 1:
            for fileName in dirList[0:-1]:
                sourceFile = self._sourceFolder + "/" + fileName
                if sourceFile not in self._transferredFile:
                    returnResult = self._sherpaFolder + "/" + fileName
                    try:
                        os.remove(returnResult)
                    except OSError:
                        pass
                    self._lastTransferredFile = returnResult
                    # print("getting", sourceFile)
                    sftpConn.get(sourceFile, returnResult)
                    # print("end of transfer", sourceFile)
                    self._transferredFile.append(sourceFile)
                    break

        # Closes the connection
        sftpConn.close()
        self._lastTransferredFile = returnResult

        return (returnResult)

    def _flushTrace(self, traceItem, minNumber=0):
        if len(traceItem) >= minNumber:
            jsonMsg = json.dumps(traceItem)
            jsonMsg = struct.pack('>I', len(jsonMsg)) + jsonMsg.encode('utf-8')
            self._outSock.send(jsonMsg)
            # print(jsonMsg)

    def _splitTextAndStore(self, traceDict, itemName, theText):
        noBlankItemName = itemName.replace(' ', '_')
        if noBlankItemName not in self._counters:
            self._counters[noBlankItemName] = 0
        self._counters[noBlankItemName] += 1

        for subItemString in theText.split(','):
            subItemName = subItemString.split('=')[0]
            if subItemName in ("TA", "sinLayer0", "sinLayer1", "tbSize"):
                subItemValue = subItemString.split('=')[-1]
                self._storeItem(
                    traceDict,
                    noBlankItemName +
                    "." +
                    subItemName,
                    subItemValue)
                if subItemName == "TA":
                    print(traceDict)

    def _storeItem(self, traceDict, itemName, itemValue):
        if itemValue is not None:
            try:
                traceDict[itemName] = int(itemValue, 0)
            except ValueError:
                try:
                    traceDict[itemName] = float(itemValue)
                except ValueError:
                    if itemValue != "":
                        traceDict[itemName] = itemValue

    def _fillTraceDictHeader(
            self,
            traceDict,
            timestamp,
            timeEpoch,
            trigger,
            crnti,
            currentTti):
        traceDict["frame.timestamp"] = timestamp
        traceDict["frame.time_epoch"] = timeEpoch
        traceDict["frame.traceType"] = "sherpa"
        traceDict["frame.trigger"] = trigger
        traceDict["event.sherpa.crnti"] = crnti
        traceDict["event.sherpa.fn"] = currentTti["sfn"] % 1024
        traceDict["event.sherpa.subFn"] = currentTti["subFn"]

    def _ttiToSfnAndSubFn(self, tti):
        result = {}
        (sfnStr, subFnStr) = tti.split('.')
        result["sfn"] = int(sfnStr)
        result["subFn"] = int(subFnStr)
        return (result)

    def _getTraceDict(
            self,
            startMicroSecondsEpoch,
            startTti,
            currentTti,
            crnti,
            trigger):
        crnti = int(crnti, 0)
        startTtiMicroSeconds = (
            10000 * startTti["sfn"]) + (200 * startTti["subFn"])
        currentTtiMicroSeconds = (
            10000 * currentTti["sfn"]) + (200 * currentTti["subFn"])
        currentMicroSecondsEpoch = startMicroSecondsEpoch + \
            (currentTtiMicroSeconds - startTtiMicroSeconds)
        secondsEpoch = int(currentMicroSecondsEpoch / 1000000)
        fractionSecond = str(currentMicroSecondsEpoch)[-6:]
        timeEpoch = str(secondsEpoch) + "." + fractionSecond
        # print("currentMicroSecondsEpoch", currentMicroSecondsEpoch)
        # print("timeEpoch", timeEpoch)
        localTime = time.strftime(
            "%Y/%m/%d %H:%M:%S",
            time.localtime(secondsEpoch))
        timestamp = localTime + "." + fractionSecond
        if crnti not in self._traceCollection:
            self._traceCollection[crnti] = SortedCollection(
                key=itemgetter("frame.timestamp"))

        try:
            traceDict = self._traceCollection[crnti].find(timestamp)
        except ValueError:
            traceDict = {}
            self._fillTraceDictHeader(
                traceDict,
                timestamp,
                timeEpoch,
                trigger,
                crnti,
                currentTti)
            self._traceCollection[crnti].insert_right(traceDict)

        return (traceDict)

    def _storeSherpaCsvColumnName(self, firstLine):
        self._columnNameToColId = {}
        columnName = firstLine.split(';')
        for colId in range(len(columnName)):
            self._columnNameToColId[columnName[colId]] = colId

    def _openAndStoreHeader(self, fileName):
        fileIn = open(fileName, "r")
        firstLine = fileIn.readline()
        self._storeSherpaCsvColumnName(firstLine)
        return (fileIn)

    def _getSplittedLine(self, fileIn):
        result = None
        lineIn = fileIn.readline()
        if lineIn:
            result = lineIn.split(';')
        return (result)

    def _getItem(self, itemName, splittedLineIn):
        result = splittedLineIn[self._columnNameToColId[itemName]]
        if result == "":
            result = None
        return (result)

    def _mainLoop(self):
        print("SherpaStateVariableBuilder._mainLoop started")
        try:
            os.makedirs(self._sherpaFolder)
            debugFile = open(self._sherpaFolder + "/debug.log", "a")
            if "linux" in sys.platform:
                sherpaExe = "/opt/Nokia/Sherpa_5G/runSherpa"
            else:
                sherpaExe = '"C:/Program Files/Nokia/Sherpa_5G/sherpa.exe"'

            # pr = cProfile.Profile()
            # pr.enable()
            currentFileName = None

            while (not self._eventStop) or (currentFileName is not None):
                try:
                    os.remove(self._sherpaFolder + "/Summary.csv")
                except OSError:
                    pass

                currentFileName = self._getLastFileToDecode()

                if (currentFileName is not None):
                    debugFile.write(
                        time.strftime("%H:%M:%S - ") +
                        currentFileName +
                        " downloaded\n")

                if (currentFileName is not None) and (
                        self._sherpaMode != "Collect"):
                    cmdLine = sherpaExe + ' -o ' + self._sherpaFolder + \
                        ' -M -d 3600 ' + currentFileName
                    print(shlex.split(cmdLine))
                    returnCode = subprocess.call(shlex.split(cmdLine))

                    while (
                        not self._eventStop) and (
                        not os.path.isfile(
                            self._sherpaFolder +
                            "/Summary.csv")):
                        time.sleep(1)
                        print("waiting " + self._sherpaFolder + "/Summary.csv")

                    if os.path.isfile(self._sherpaFolder + "/Summary.csv"):
                        print("analysing Sherpa results")
                        fileIn = self._openAndStoreHeader(
                            self._sherpaFolder + "/Summary.csv")
                        splittedLineIn = self._getSplittedLine(fileIn)
                        fileIn.close()

                        (timeSecond, fractionSecond) = self._getItem(
                            "start time", splittedLineIn).split('.')
                        timeStruct = time.strptime(
                            timeSecond, "%Y/%m/%d %H:%M:%S")
                        # print("timeStruct", timeStruct)
                        secondsEpoch = round(time.mktime(timeStruct))
                        # print("secondsEpoch" , secondsEpoch)
                        timeEpoch = str(secondsEpoch) + "." + fractionSecond
                        startMicroSecondsEpoch = round(
                            float(timeEpoch) * 1000000)
                        # print("startMicroSecondsEpoch" , startMicroSecondsEpoch)
                        startTti = self._ttiToSfnAndSubFn(
                            self._getItem("start tti", splittedLineIn))

                        fileIn = self._openAndStoreHeader(
                            self._sherpaFolder + "/dlStat.csv")
                        splittedLineIn = self._getSplittedLine(fileIn)
                        while (
                                splittedLineIn is not None) and (
                                not self._eventStop):
                            currentTti = self._ttiToSfnAndSubFn(
                                self._getItem("SHERPA TTI", splittedLineIn))
                            crnti = self._getItem("RNTI", splittedLineIn)
                            traceDict = self._getTraceDict(
                                startMicroSecondsEpoch, startTti, currentTti, crnti, "1sTimer")
                            self._storeItem(
                                traceDict, "event.sherpa.dlStat.throughput", self._getItem(
                                    "TP(kb/s)", splittedLineIn))
                            self._storeItem(
                                traceDict, "event.sherpa.dlStat.minMcs", self._getItem(
                                    "MIN MCS", splittedLineIn))
                            self._storeItem(
                                traceDict, "event.sherpa.dlStat.maxMcs", self._getItem(
                                    "MAX MCS", splittedLineIn))
                            self._storeItem(
                                traceDict, "event.sherpa.dlStat.meanMcs", self._getItem(
                                    "MEAN MCS", splittedLineIn))
                            self._storeItem(
                                traceDict, "event.sherpa.dlStat.nbGrant", self._getItem(
                                    "NB GRANT", splittedLineIn))
                            splittedLineIn = self._getSplittedLine(fileIn)
                            # print(traceDict)
                        fileIn.close()

                        fileIn = self._openAndStoreHeader(
                            self._sherpaFolder + "/ulStat.csv")
                        splittedLineIn = self._getSplittedLine(fileIn)
                        while (
                                splittedLineIn is not None) and (
                                not self._eventStop):
                            currentTti = self._ttiToSfnAndSubFn(
                                self._getItem("SHERPA TTI", splittedLineIn))
                            crnti = self._getItem("RNTI", splittedLineIn)
                            traceDict = self._getTraceDict(
                                startMicroSecondsEpoch, startTti, currentTti, crnti, "1sTimer")
                            self._storeItem(
                                traceDict, "event.sherpa.ulStat.throughput", self._getItem(
                                    "TP(kb/s)", splittedLineIn))
                            self._storeItem(
                                traceDict, "event.sherpa.ulStat.minMcs", self._getItem(
                                    "MIN MCS", splittedLineIn))
                            self._storeItem(
                                traceDict, "event.sherpa.ulStat.maxMcs", self._getItem(
                                    "MAX MCS", splittedLineIn))
                            self._storeItem(
                                traceDict, "event.sherpa.ulStat.meanMcs", self._getItem(
                                    "MEAN MCS", splittedLineIn))
                            self._storeItem(
                                traceDict, "event.sherpa.ulStat.nbGrant", self._getItem(
                                    "NB GRANT", splittedLineIn))
                            self._storeItem(
                                traceDict, "event.sherpa.ulStat.bler", self._getItem(
                                    "BLER", splittedLineIn))
                            splittedLineIn = self._getSplittedLine(fileIn)
                            # print(traceDict)
                        fileIn.close()

                        # print(self._traceCollection)
                        # print(self._traceCollection.keys())

                        for crntiTrace in self._traceCollection:
                            # print(crntiTrace)
                            for traceDict in self._traceCollection[crntiTrace]:
                                self._flushTrace(traceDict, minNumber=8)

                        self._traceCollection = {}
                        os.remove(self._sherpaFolder + "/Summary.csv")

                    cmdLine = sherpaExe + ' -o ' + self._sherpaFolder + ' -d 3600 ' + currentFileName
                    print(shlex.split(cmdLine))
                    returnCode = subprocess.call(shlex.split(cmdLine))

                    while (
                        not self._eventStop) and (
                        not os.path.isfile(
                            self._sherpaFolder +
                            "/Summary.csv")):
                        time.sleep(1)
                        print("waiting " + self._sherpaFolder + "/Summary.csv")

                    if os.path.isfile(self._sherpaFolder + "/Summary.csv"):
                        print("analysing Sherpa results")

                        fileIn = self._openAndStoreHeader(
                            self._sherpaFolder + "/l1l2Trace.csv")
                        splittedLineIn = self._getSplittedLine(fileIn)
                        while (
                                splittedLineIn is not None) and (
                                not self._eventStop):
                            crnti = self._getItem("RNTI", splittedLineIn)
                            if crnti is not None:
                                currentTti = self._ttiToSfnAndSubFn(
                                    self._getItem("SHERPA TTI", splittedLineIn))
                                traceDict = self._getTraceDict(
                                    startMicroSecondsEpoch, startTti, currentTti, crnti, "message")
                                msgName = self._getItem(
                                    "MSG ID", splittedLineIn)
                                self._splitTextAndStore(
                                    traceDict,
                                    "event.sherpa.l1l2Trace." +
                                    msgName,
                                    self._getItem(
                                        "TEXT",
                                        splittedLineIn))
                            splittedLineIn = self._getSplittedLine(fileIn)

                        for crntiTrace in self._traceCollection:
                            # print(crntiTrace)
                            for traceDict in self._traceCollection[crntiTrace]:
                                self._flushTrace(traceDict, minNumber=8)

                        fileIn.close()
                        self._traceCollection = {}
                        os.remove(self._sherpaFolder + "/Summary.csv")

                time.sleep(1)
            # pr.disable()
            # s = io.StringIO()
            # sortby = 'cumulative'
            # ps = pstats.Stats(pr, stream=s).sort_stats(sortby)
            # ps.print_stats()
            # print(s.getvalue())
            debugFile.close()
        except Exception:
            print("Exception: " + traceback.format_exc(limit=5))

        print("SherpaStateVariableBuilder._mainLoop stopped")
