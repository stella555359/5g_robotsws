# description:  State Variable builders for all wireshark traces
#
# history:
#               22/03/2019 - RJO: creation

import time
import os
import json
import socket
import threading
import subprocess
import shlex
import sys
import traceback
import struct
from ...Cockpit_Debug import debugWrite
from ...Cockpit_Config import ConfigClass
from ...utilities.SshConnection import SshConnection


class TsharkStateVariableBuilder:
    def __init__(
            self,
            tlInfo,
            swModule,
            itf,
            destFolder,
            tcpDestIp,
            tcpDestPort,
            tsharkMode,
            fieldList,
            tsharkDissector,
            filter):
        """
        Initialise a new SVB for wireshark traces (pcap files)
        :param tlInfo: Informations about TL addresses
        :param swModule: Module (fct-0a, aspa-1c, etc...) where the wireshark traces must be taken from
        :param itf: Interface where the tcpdump must be done (e.g. etha01)
        :param destFolder: Folder where the traces will be stored
        :param tcpDestIp: Ip to the Pc that execute the State Vector Manager
        :param tcpDestPort: TCP port to communicate with the State Vector Manager
        :param tsharkMode: "Analyze" or "collect"
        :param fieldList: Obsolete TODO: Delete it
        :param tsharkDissector: path to the lua dissector to decode te wireshark trace
        :param filter: Filter to be used in wireshark
        """
        self._tlInfo = tlInfo
        self._swModule = swModule
        self._sourceIp = tlInfo[swModule]["hostname"]
        self._sourceUser = tlInfo[swModule]["username"]
        self._sourcePassword = tlInfo[swModule]["password"]
        if itf is None:
            self._sourceItf = tlInfo[swModule]["itf"]
        else:
            self._sourceItf = itf
        self._sourceFolder = tlInfo[swModule]["tcpDumpPath"] + \
            "/" + self._sourceItf + "/"
        self._destFolder = destFolder
        self._tsharkMode = tsharkMode
        self._tsharkDissector = tsharkDissector
        self._tcpDestIp = tcpDestIp
        self._tcpDestPort = tcpDestPort
        self._outSock = socket.socket(
            socket.AF_INET, socket.SOCK_STREAM)  # TCP
        self._outSock.connect((self._tcpDestIp, self._tcpDestPort))
        self._lastValue = {}
        self._eventStop = False
        self._transferredFile = []
        self._lastTransferredFile = None
        self._traceCollection = {}
        self._localfileslist = []
        self._AnalysisBegan = False
        self._filter = filter

        if self._swModule in ("asik", "fct-0a", "fct-0b", "fct-4b"):
            self._sudoTemplate = ""
        else:
            self._sudoTemplate = "echo %s | sudo -S -k " % (
                self._sourcePassword)

        if "linux" in sys.platform:
            self._tsharkExe = "tshark"
        else:
            self._tsharkExe = '"C:/Program Files/Wireshark/tshark.exe"'

        try:
            self._counterList = ConfigClass.stateVariableBuilderConfig[
                "Tshark"][swModule]["counterList"]
            # self._decodeList = ConfigClass.stateVariableBuilderConfig["Tshark"][swModule]["decodeList"]
        except KeyError:
            self._counterList = ()
            # self._decodeList = ()
            # debugWrite("no counterList found in ", ConfigClass.stateVariableBuilderConfig["Tshark"])

        try:
            self._stateVariableList = ConfigClass.stateVariableBuilderConfig[
                "Tshark"][swModule]["stateVariableList"]
        except KeyError:
            self._stateVariableList = {}

        self._packetToSend = []
        self._packetSize = 0

        self._counters = {}
        for counterName in self._counterList:
            self._counters[counterName] = {}
            self._counters[counterName]["value"] = 0

        # self._decodes = {}
        self._sshConnection = SshConnection()
        self._sshConnection.connect(self._tlInfo, self._swModule)
        self._startTsharkTraceCollection()
        threading.Thread(target=self._mainLoop).start()

    def _startTsharkTraceCollection(self):
        """
        Start the collection of tshark traces on the distant swModule
        :return: None
        """
        debugWrite("_startTsharkTraceCollection enter")

        comOut = self._sshConnection.executeAndWaitEnd(
            '%s pkill -f "tcpdump -i %s"' %
            (self._sudoTemplate, self._sourceItf))
        # debugWrite(comOut)
        if self._sudoTemplate == "":
            comOut = self._sshConnection.executeAndWaitEnd(
                '%s sh -c "mkdir -p %s;'
                ' chmod 777 %s;'
                ' rm %s/tcpdump*.pcap*;'
                ' ls -ltr %s;'
                ' echo tcpdump -i %s proto 0x84 -G 20 -C 100 -B 9000 -w %s/tcpdump-%%Y-%%m-%%d_%%Hh%%Mm%%S.pcap'
                ' -W 50 > tcpdump.sh ;'
                ' chmod 777 tcpdump.sh;'
                ' nohup ./tcpdump.sh"' %
                (self._sudoTemplate,
                 self._sourceFolder,
                 self._sourceFolder,
                 self._sourceFolder,
                 self._sourceFolder,
                 self._sourceItf,
                 self._sourceFolder))
        else:
            comOut = self._sshConnection.executeAndWaitEnd(
                '%s -- sh -c "mkdir -p %s;'
                ' chmod 777 %s;'
                ' rm %s/tcpdump*.pcap*;'
                ' ls -ltr %s;'
                ' echo tcpdump -i %s proto 0x84 -G 20 -C 100 -B 9000 -w %s/tcpdump-%%Y-%%m-%%d_%%Hh%%Mm%%S.pcap'
                ' -W 50 > tcpdump.sh ;'
                ' chmod 777 tcpdump.sh;'
                ' nohup ./tcpdump.sh"' %
                (self._sudoTemplate,
                 self._sourceFolder,
                 self._sourceFolder,
                 self._sourceFolder,
                 self._sourceFolder,
                 self._sourceItf,
                 self._sourceFolder))

        # debugWrite(comOut)

        debugWrite("_startTsharkTraceCollection return")

    def stop(self):
        """
        Download and analyse the remaining pcap files, then stop the collection and stop the SVB
        :return: None
        """
        debugWrite("_stopTshark enter")
        self._eventStop = True

        comOut = self._sshConnection.executeAndWaitEnd(
            '%s pkill -f "tcpdump -i %s"' %
            (self._sudoTemplate, self._sourceItf))
        debugWrite(comOut)

        while (self._lastTransferredFile is not None):
            debugWrite(
                "Waiting end of transfer for file %s" %
                (self._lastTransferredFile))
            time.sleep(1)
        self._forceFlush()
        self._outSock.close()
        self._sshConnection.close()
        debugWrite("_stopTshark return")

    def _reconnect(self):
        """
        Reconnect and relaunch the trace collection -- to be used in case of loss of connection with the swModule
        :return: None
        """
        debugWrite("_reconnect enter")
        while not self._eventStop:
            try:
                self._sshConnection = SshConnection()
                self._sshConnection.connect(self._tlInfo, self._swModule)
                break
            except Exception:
                pass
        if not self._eventStop:
            self._startTsharkTraceCollection()
        debugWrite("_reconnect return")

    def getCounters(self):
        """
        return the list of counters tracked
        :return: list of counters
        """
        debugWrite("Tshark Counters: ", self._counters)
        return (self._counters)

    def waitCounter(self, counterName, counterWaitedValue, timeOut):
        """
        Wait for a specific counter to happen a number of time
        :param counterName: Name of the counter
        :param counterWaitedValue: Number of time the value must appear
        :param timeOut: Timeout before raising an exception
        :return: Value of the counter
        """
        debugWrite("Waiting %s >= %d" % (counterName, counterWaitedValue))
        nbSeconds = 0
        currentCounterValue = 0
        while nbSeconds < timeOut:
            if counterName in self._counters:
                currentCounterValue = self._counters[counterName]["value"]
                # debugWrite("%s = %d"%(counterName, currentCounterValue))
                if currentCounterValue >= counterWaitedValue:
                    debugWrite("%s = %d" % (counterName, currentCounterValue))
                    break
            time.sleep(1)
            nbSeconds += 1
        if currentCounterValue < counterWaitedValue:
            debugWrite("Couters: ", self._counters)
            raise Exception(
                "Timeout while waiting for '%s' >= %d" %
                (counterName, counterWaitedValue))
        return (self._counters[counterName])

    def _checkPresenceAndUpdateCounter(
            self,
            fileName,
            frameNumber,
            colInfo,
            counterName):
        """
        Check if a counter is present in a file and update the counter
        :param fileName: CSV filename
        :param frameNumber:
        :param colInfo: list of columns
        :param counterName: Name of the counter
        :return: True if no Error, False otherwise
        """
        returnResult = False
        if counterName in colInfo:
            self._counters[counterName]["fileName"] = fileName
            self._counters[counterName]["frameNumber"] = frameNumber
            self._counters[counterName]["value"] += 1
            returnResult = True
            debugWrite("Increment Counter: " + counterName)
        return (returnResult)

    def getDecodedFrame(self, frameInfo):
        """

        :param frameInfo:
        :return:
        """
        debugWrite("frameInfo: ", frameInfo)
        frameNumber = frameInfo["frameNumber"]
        fileName = frameInfo["fileName"]
        cmdLine = self._tsharkExe +  \
            ' -T pdml -Y frame.number==' + frameNumber + ' -r ' + fileName
        debugWrite(cmdLine)
        decodeFilename = fileName + "_" + frameNumber + ".xml"
        decodeFileDesc = open(decodeFilename, "w")
        returnCode = subprocess.call(
            shlex.split(cmdLine), stdout=decodeFileDesc)
        decodeFileDesc.close()

        decodedFrame = {}
        decodedFrame["decodedFileName"] = decodeFilename

        fileIn = open(decodeFilename, "r")
        lineIn = fileIn.readline()
        while lineIn:
            fieldNameIndex = lineIn.find('field name="')
            showIndex = lineIn.find(' show="')
            if (fieldNameIndex >= 0) and (showIndex >= 0):
                fieldNameStr = lineIn[fieldNameIndex:].split('"')[1]
                showStr = lineIn[showIndex:].split('"')[1]
                decodedFrame[fieldNameStr] = showStr
            lineIn = fileIn.readline()

        fileIn.close()
        debugWrite("decodedFrame", decodedFrame)
        return (decodedFrame)

    def _getLastFileToDecode(self):
        """
        Download the next pcap file to analyse
        :return: Name of downloaded file, or None, if no file downloaded
        """
        returnResult = None

        # Get the directory and file listing
        debugWrite("getting file list")
        try:
            dirListFull = self._sshConnection.fileList(self._sourceFolder)
        except Exception:
            self._reconnect()
            return None
        debugWrite("file list:", dirListFull)
        dirListFull.sort()
        if self._eventStop:
            dirList = dirListFull[:]
        else:
            dirList = dirListFull[:-1]

        # debugWrite("file list:", dirListFull)
        # debugWrite("file list:", dirList)

        if len(dirList) > 0:
            for fileName in dirList:
                sourceFile = self._sourceFolder + "/" + fileName
                if sourceFile not in self._transferredFile:
                    returnResult = self._destFolder + "/" + fileName
                    try:
                        os.remove(returnResult)
                    except OSError:
                        pass
                    self._lastTransferredFile = returnResult
                    debugWrite("getting", sourceFile)
                    try:
                        self._sshConnection.downloadFile(
                            sourceFile, returnResult)
                    except Exception:
                        self._reconnect()
                        return None
                    debugWrite("end of transfer", sourceFile)
                    try:
                        self._sshConnection.executeAndWaitEnd(
                            '%s rm %s' % (self._sudoTemplate, sourceFile))
                    except Exception:
                        self._reconnect()
                        return None
                    self._transferredFile.append(sourceFile)
                    break

        self._lastTransferredFile = returnResult

        return (returnResult)

    def _flushTrace(self, traceItem):
        """
        save the trace to be send to the SVM and send all the traces if the packet to send is big enough
        :param traceItem: trace Item to send
        :return: None
        """
        if (traceItem is not None):
            if len(traceItem) > self._nbOfFieldsInHeader:
                jsonMsg = json.dumps(traceItem)
                jsonMsg = struct.pack(
                    '>I', len(jsonMsg)) + jsonMsg.encode('utf-8')
                self._packetToSend.append(jsonMsg)
                self._packetSize += len(jsonMsg)
                if self._packetSize > 10000000:
                    packetToSend = struct.pack(
                        '>I', self._packetSize) + b"".join(self._packetToSend)
                    self._packetToSend = []
                    self._packetSize = 0
                    self._outSock.send(packetToSend)
                # debugWrite(jsonMsg)

    def _forceFlush(self):
        """
        Send all the messages to the SVM, whatever the size
        :return: None
        """
        packetToSend = struct.pack(
            '>I', self._packetSize) + b"".join(self._packetToSend)
        # debugWrite(packetToSend)
        self._packetToSend = []
        self._outSock.send(packetToSend)

    def _storeItem(self, traceDict, itemName, itemValue):
        """
        Store an item in a new trace dictionary
        :param traceDict: trace dictionary
        :param itemName: name of the item to store
        :param itemValue: value of the item to store
        :return: None
        """
        if (traceDict is not None) and (itemValue is not None):
            try:
                traceDict[itemName] = int(itemValue, 0)
            except ValueError:
                try:
                    traceDict[itemName] = float(itemValue)
                except ValueError:
                    if itemValue != "":
                        traceDict[itemName] = itemValue

    def _fillTraceDictHeader(self, traceDict, timestamp, timeEpoch, trigger):
        """
        Fill the header (time and trace type) of a message in a dictionary
        :param traceDict: dictionary that will contain the message
        :param timestamp: time stamp as a string
        :param timeEpoch: time since Epoch as a float
        :param trigger: trigger to the new message (e.g. message)
        :return: None
        """
        traceDict["frame.timestamp"] = timestamp
        traceDict["frame.time_epoch"] = timeEpoch
        traceDict["frame.traceType"] = "tshark." + \
            self._swModule + "." + self._sourceItf
        traceDict["frame.trigger"] = trigger
        self._nbOfFieldsInHeader = 4

    def _getTraceDict(self, timeEpoch, trigger):
        """
        Get a new dictionary that can contain a message that dates from secondsEpoch
        :param secondsEpoch: time since Epoch
        :param trigger: trigger to the new message (e.g. message)
        :return: dictionary
        """
        (secondsEpochStr, fractionSecondStr) = timeEpoch.split('.')
        secondsEpoch = int(secondsEpochStr)
        # debugWrite("currentMicroSecondsEpoch", currentMicroSecondsEpoch)
        # debugWrite("timeEpoch", timeEpoch)
        localTime = time.strftime(
            "%Y/%m/%d %H:%M:%S",
            time.localtime(secondsEpoch))
        timestamp = localTime + "." + fractionSecondStr
        traceDict = {}
        self._fillTraceDictHeader(traceDict, timestamp, timeEpoch, trigger)
        return (traceDict)

    def _sendToStateVector(self, currentFileName):
        """
        Read and parse the Pcap File and send the different items to the SVM
        :param currentFileName: Name of the Pcap File
        :return: None
        """
        jsonFilename = os.path.splitext(currentFileName)[0] + ".json"
        if self._filter:
            cmdLine = self._tsharkExe +  \
                ' -Y "' + self._filter + '" -T json -r "' + currentFileName + '"'
        else:
            cmdLine = self._tsharkExe +  \
                 + '-T json -r "' + currentFileName + '"'

        debugWrite(cmdLine)

        jsonFileDesc = open(jsonFilename, "w")
        returnCode = subprocess.call(shlex.split(cmdLine), stdout=jsonFileDesc)
        debugWrite("Finished", cmdLine)
        jsonFileDesc.close()

        if os.path.isfile(jsonFilename):
            debugWrite("analysing Tshark results" + jsonFilename)
            traceDict = None
            copyMessage = False
            itemValue = '{'
            timeEpoch = 0

            itemName = 'event.Tshark.Message'
            with open(jsonFilename, "r") as JSONFile:
                for line in JSONFile:
                    if not copyMessage:
                        if line.startswith('    "_source": {'):
                            itemValue += line.rstrip().replace(' ', '')
                            copyMessage = True
                    else:
                        itemValue += line.rstrip().replace(' ', '')
                        if 'frame.time_epoch' in line:
                            timeEpoch = line.rstrip().split(':')[1][2:-2]
                        if line.startswith('    }'):
                            traceDict = self._getTraceDict(
                                timeEpoch, "message")
                            self._storeItem(
                                traceDict, itemName, itemValue + '}')
                            self._flushTrace(traceDict)
                            traceDict = None
                            copyMessage = False
                            itemValue = '{'
                            timeEpoch = 0

    def _storeTsharkCsvColumnName(self, firstLine):
        """
        Read the first line of the CSV file and store the value of the columns
        :param firstLine: line containing the list of column names
        :return: None
        """
        self._columnNameToColId = {}
        columnName = firstLine.split(';')
        for colId in range(len(columnName)):
            self._columnNameToColId[columnName[colId]] = colId

    def _openAndStoreHeader(self, fileName):
        """
        Ope the CSV file and store the informations of the header
        :param fileName: name of the CSV file
        :return: File descriptor
        """
        debugWrite("enter")
        fileIn = open(fileName, "r")
        lineIn = fileIn.readline().strip('\n')
        while lineIn:
            if lineIn.startswith(
                    "frame.number;frame.time;frame.time_epoch;_ws.col.Info"):
                self._storeTsharkCsvColumnName(lineIn)
                break
            lineIn = fileIn.readline().strip('\n')
        debugWrite("exit")
        return (fileIn)

    def _getSplittedLine(self, fileIn):
        """
        Take a line with multiple ';' (like a csv line) and return a list with all the elements between the ';'
        :param fileIn: File descriptor whith the next line to read
        :return: list of string
        """
        result = None
        lineIn = fileIn.readline()
        if lineIn:
            result = lineIn.strip('\n').split(';')
        return (result)

    def _getItem(self, itemName, splittedLineIn):
        """
        Get an item from the CSV file
        :param itemName: Name of the item to get
        :param splittedLineIn: List from the _getSplittedLine function return
        :return: Value contained inside the CSV cell
        """
        result = splittedLineIn[self._columnNameToColId[itemName]]
        if result == "":
            result = None
        return (result)

    def _mainLoop(self):
        """
        Mainloop of the wireshark SVB. Get and analyse the pcap file from the swModule. Send the items to the VM and
        collect the defined counters
        :return: None
        """
        debugWrite("TsharkStateVariableBuilder._mainLoop started")
        try:
            debugWrite("counterList:", self._counterList)
            try:
                os.makedirs(self._destFolder)
            except OSError:
                pass
            debugFile = open(self._destFolder + "/debug.log", "a")

            # pr = cProfile.Profile()
            # pr.enable()
            currentFileName = self._getLastFileToDecode()

            while (not self._eventStop) or (currentFileName is not None):
                if (currentFileName is not None):
                    debugFile.write(
                        time.strftime("%H:%M:%S - ") +
                        currentFileName +
                        " downloaded")

                if (currentFileName is not None) and (
                        self._tsharkMode != "Collect"):
                    csvFilename = currentFileName + ".csv"
                    cmdLine = self._tsharkExe + \
                        ' -T fields -E header=y -E separator=;  -r ' + currentFileName
                    for requestedField in (
                        "frame.number",
                        "frame.time",
                        "frame.time_epoch",
                            "_ws.col.Info"):
                        cmdLine += " -e " + requestedField

                    debugWrite(cmdLine)
                    csvFileDesc = open(csvFilename, "w")
                    returnCode = subprocess.call(
                        shlex.split(cmdLine), stdout=csvFileDesc)
                    debugWrite("Finished", cmdLine)
                    csvFileDesc.close()

                    if os.path.isfile(csvFilename):
                        debugWrite("analysing Tshark results" + csvFilename)
                        fileIn = self._openAndStoreHeader(csvFilename)
                        splittedLineIn = self._getSplittedLine(fileIn)
                        while (splittedLineIn is not None):
                            # debugWrite("splittedLineIn", splittedLineIn)
                            frameNumber = self._getItem(
                                "frame.number", splittedLineIn)
                            colInfo = self._getItem(
                                "_ws.col.Info", splittedLineIn)
                            if colInfo is not None:
                                for counterName in self._counterList:
                                    if self._checkPresenceAndUpdateCounter(
                                            currentFileName, frameNumber, colInfo, counterName):
                                        debugWrite(
                                            "Counter detected", counterName)
                                        # if counterName in self._decodeList:
                                        #    self._storeDecoding(counterName, splittedLineIn, currentFileName)
                            splittedLineIn = self._getSplittedLine(fileIn)
                            # debugWrite(traceDict)
                        fileIn.close()
                        debugWrite(
                            "End of analysis Tshark results for" + csvFilename)

                    self._sendToStateVector(currentFileName)

                time.sleep(1)
                currentFileName = self._getLastFileToDecode()
            # pr.disable()
            # s = io.StringIO()
            # sortby = 'cumulative'
            # ps = pstats.Stats(pr, stream=s).sort_stats(sortby)
            # ps.print_stats()
            # debugWrite(s.getvalue())
            debugFile.close()
        except Exception:
            debugWrite("Exception: " + traceback.format_exc(limit=5))
        debugWrite("TsharkStateVariableBuilder._mainLoop stopped")
