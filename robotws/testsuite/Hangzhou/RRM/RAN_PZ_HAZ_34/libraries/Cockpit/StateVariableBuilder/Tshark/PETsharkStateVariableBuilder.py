import time
import os
import json
import socket
import threading
import struct
from ...Cockpit_Debug import debugWrite
from ...Cockpit_Config import ConfigClass
from .PETsharkTracesGetter import Class_PETsharkTracesGetter
import xml.etree.ElementTree as ET
import re


# import cProfile, pstats, io


class Class_PETsharkStateVariableBuilder:
    def __init__(self, tlInfo, swModule, destFolder, tcpDestIp, tcpDestPort):
        """
            Init Function of module
            Note:   To be used, stateVariableBuilderConfig["PETshark"][swModule]["stateVariableList"] of
                    ConfigClass must be set
            param:  tlInfo:          Information on the Test Line from Cockpit_Config
            param:  swModule:        Module where the traces must be downloaded (e.g. "airmosaic")
            param:  destFolder:      Folder where traces must be stored
            param:  tcpDestIp:       IP to the State Vector Manager
            param:  tcpDestPort:     TCP Port to the State Vector Manager
            return: No return
        """
        self._tlInfo = tlInfo
        self._swModule = swModule
        self._sourceIp = tlInfo[swModule]["hostname"]
        self._sourceUser = tlInfo[swModule]["username"]
        self._sourcePassword = tlInfo[swModule]["password"]
        self._sourceFolder = tlInfo[swModule]["tcpDumpPath"]
        self._destFolder = destFolder
        self._tcpDestIp = tcpDestIp
        self._tcpDestPort = tcpDestPort

        self._outSock = socket.socket(
            socket.AF_INET, socket.SOCK_STREAM)  # TCP

        self._outSock.connect((self._tcpDestIp, self._tcpDestPort))

        self._eventStop = False
        self._lastTransferredFile = None

        try:
            self._stateVariableList = ConfigClass.stateVariableBuilderConfig[
                "PETshark"][swModule]["stateVariableList"]
        except KeyError:
            self._stateVariableList = {}

        self._TracesGetter = Class_PETsharkTracesGetter(
            self._tlInfo, self._swModule, self._destFolder)
        threading.Thread(target=self.F_mainLoop).start()

    # ##-----------------------------------------------------------------------------------------------------------###

    def F_mainLoop(self):
        """
            Mainloop of module - must be executed in a separate thread. Get the traces, parse it and send it to SVM
            return: No return
        """
        debugWrite("PETsharkStateVariableBuilder.F_mainLoop started")

        # Start Collecting traces
        self._TracesGetter.F_startCollection()

        # Make the storage folder if it does not exist
        try:
            os.makedirs(self._destFolder)
        except OSError:
            pass

        currentFileName = self._TracesGetter.F_getLastFile()
        while (not self._eventStop) or (currentFileName is not None):
            if currentFileName:
                self._F_SendToStateVector(currentFileName)
                os.remove(currentFileName)
            currentFileName = self._TracesGetter.F_getLastFile()
            self._lastTransferredFile = currentFileName

    # ##-----------------------------------------------------------------------------------------------------------###

    def F_stop(self):
        """
            Collect the last traces and stop the mainloop and the trace collection
            return: No return
        """
        self._TracesGetter.F_stopCollection()
        self._eventStop = True
        while (self._lastTransferredFile is not None):
            debugWrite(
                "Waiting end of transfer for file %s" %
                (self._lastTransferredFile))
            time.sleep(1)
        self._outSock.close()

    # ##-----------------------------------------------------------------------------------------------------------###

    def _F_fillTraceDictHeader(self, traceDict, timestamp, timeEpoch, trigger):
        """
            Fill the header of the trace dict with general informations
            param:  traceDict: current trace dict
            param:  timestamp: string containing the timestamp of the message
            param:  timeEpoch: float containing the time of the message since Epoch
            param:  trigger:   trigger explaining why the trace has been sent to SVM
            return: No return
        """
        traceDict["frame.timestamp"] = timestamp
        traceDict["frame.time_epoch"] = timeEpoch
        traceDict["frame.traceType"] = "tshark.PE"
        traceDict["frame.trigger"] = trigger
        self._nbOfFieldsInHeader = 4

    # ##-----------------------------------------------------------------------------------------------------------###

    def _F_getTraceDict(self, timeEpoch, trigger):
        """
            Give a new Trace dict from the time of the message and the trigger of the message
            param:  timeEpoch: float containing the time of the message since Epoch
            param:  trigger:   trigger explaining why the trace has been sent to SVM
            return: No return
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
        self._F_fillTraceDictHeader(traceDict, timestamp, timeEpoch, trigger)
        return (traceDict)

    # ##-----------------------------------------------------------------------------------------------------------###

    def _F_storeItem(self, traceDict, itemName, itemValue):
        """
            Store a new item in a trace dict
            param:  traceDict: trace dict where the item will be stored
            param:  itemName:  Name of the item to store
            param:  itemValue: Value of the item to store
            return: No return
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

    # ##-----------------------------------------------------------------------------------------------------------###

    def _F_flushTrace(self, traceItem):
        """
            Send the trace to the SVM with a TCP JSON message
            param:  traceItem: trace dict to send
            return: No return
        """
        if (traceItem is not None):
            if len(traceItem) > self._nbOfFieldsInHeader:
                jsonMsg = json.dumps(traceItem)
                jsonMsg = struct.pack(
                    '>I', len(jsonMsg)) + jsonMsg.encode('utf-8')
                self._outSock.send(jsonMsg)
                # print(jsonMsg)
                # debugWrite(jsonMsg)

    # ##-----------------------------------------------------------------------------------------------------------###

    def _F_SendToStateVector(self, Filename):
        """
            Send the PDML file message content to the SVM
            param:  Filename: Path to the PDML File
            return: No return
        """
        traceDict = None
        time_epoch = '0.0'
        itemValue = ''
        line = ''
        with open(Filename, "r") as file:
            while not line.startswith(r'</pdml>'):
                line = file.readline()
                if line.startswith(r'<packet>'):
                    # itemValue = itemValue + line.rstrip()
                    line = file.readline()
                    while not line.startswith(r'</packet>'):
                        # itemValue = itemValue + line.rstrip()
                        itemValue = itemValue + line
                        if 'frame.time_epoch' in line:
                            time_epoch = line.split('show="')[1][:-4]
                        line = file.readline()
                    traceDict = self._F_getTraceDict(time_epoch, "message")
                    itemValue = '<packet>' +\
                                self.filterXML(itemValue, self._stateVariableList).replace('\n', '') + '</packet>'
                    self._F_storeItem(
                        traceDict, "event.PETshark.Message", itemValue)
                    # Send the trace dict to the SVM
                    self._F_flushTrace(traceDict)
                    traceDict = None
                    itemValue = ''

    # ##----------------------------------------------------------------------------------------------------------###

    def filterXML(self, string, variableList):
        """
            Filter a message in XML format
            string:       string of the Message
            variableList: Part of the message that will not be deleted
            return: filtered message
        """
        endString = ""
        subString = ""
        toDelete = False
        for m in re.finditer(r'([^\n]*)(\n)', string):
            line = m.group(1)
            if '</' in line:
                if toDelete:
                    lastLine = subString[:-1].rfind('\n')
                    if lastLine == -1:
                        toDelete = False
                        subString = ''
                    else:
                        subString = subString[:subString[:-1].rfind('\n') + 1]
                else:
                    endString += line + '\n'
            elif line[-2] is not '/' and not self.getName(line) in variableList:
                toDelete = True
                subString += self.filterLine(line) + '\n'
            elif self.getName(line) in variableList:
                if toDelete:
                    endString += subString
                    endString += self.filterLine(line) + '\n'
                    toDelete = False
                    subString = ""
                else:
                    endString += self.filterLine(line) + '\n'
        return endString

    # ##-----------------------------------------------------------------------------------------------------------###

    def getName(self, line):
        """
            get the name of an xml field
            line:   xml field
            return: name of the xml field
        """
        firstChar = line.find('"') + 1
        endChar = line[firstChar:].find('"') + firstChar
        return line[firstChar:endChar]

    # ##----------------------------------------------------------------------------------------------------------###

    def filterLine(self, line):
        """
            Remove unused parts of an xml field (hide; size; pos; unmaskedvalue)
            line:   xml field
            return: name of the xml field
        """
        currentChar = 0
        markup = ''
        while line[currentChar] is ' ':
            currentChar += 1
        currentChar += 1
        while line[currentChar] is not ' ':
            markup += line[currentChar]
            currentChar += 1

        if markup == "proto":
            attribToDelete = {"hide", "pos"}
        else:
            attribToDelete = {"hide", "size", "pos", "unmaskedvalue"}

        currentChar = line[currentChar:].find('" ') + 2 + currentChar
        while currentChar is not -1:
            endCharAttrib = line[currentChar:].find('=') + currentChar
            if line[currentChar:endCharAttrib] in attribToDelete:
                nextChar = line[currentChar:].find('" ')
                if nextChar is not -1:
                    endCharAttrib = nextChar + 2 + currentChar
                    line = line[0:currentChar] + line[endCharAttrib:]
                else:
                    line = line[0:currentChar - 1] + \
                        line[(line[endCharAttrib + 2:].find('"') + endCharAttrib + 3):]
                    currentChar = -1
            else:
                currentChar = endCharAttrib
                nextChar = line[currentChar:].find('" ')
                if nextChar is not -1:
                    currentChar = nextChar + 2 + currentChar
                else:
                    currentChar = -1
        return line
