import time
import os
import json
import socket
import threading
import sys
import struct
from ...Cockpit_Debug import debugWrite
from ...Cockpit_Config import ConfigClass
from .L1L2TracesGetter import Class_L1L2TracesGetter


# import cProfile, pstats, io


class Class_L1L2StateVariableBuilder:
    def __init__(
            self,
            tlInfo,
            swModule,
            itf,
            destFolder,
            tcpDestIp,
            tcpDestPort,
            tsharkDissector,
            Filter):
        """
            Init Function of module
            Note:   To be used, stateVariableBuilderConfig["L1L2"][swModule]["stateVariableList"] of ConfigClass must
                    be set
            param:  tlInfo:          Information on the Test Line from Cockpit_Config
            param:  swModule:        Module where the traces must be downloaded (e.g. "asik")
            param:  itf:             Interface (backhaul or fronthaul)
            param:  destFolder:      Folder where traces must be stored
            param:  tcpDestIp:       IP to the State Vector Manager
            param:  tcpDestPort:     TCP Port to the State Vector Manager
            param:  tsharkDissector: TShark dissector path
                                     (e.g. "C:\tools\\wireshark\\experimental_fixed_master_R3_luashark\\luashark.lua" )
            param:  Filter:          TShark filter on messages (e.g. "((!(uldata_syncind)) && !(dldata_slottypereq))" )
            return: No return
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
        self._tsharkDissector = tsharkDissector
        self._tcpDestIp = tcpDestIp
        self._tcpDestPort = tcpDestPort
        self._Filter = Filter

        self._outSock = socket.socket(
            socket.AF_INET, socket.SOCK_STREAM)  # TCP

        self._outSock.connect((self._tcpDestIp, self._tcpDestPort))

        self._eventStop = False
        self._lastTransferredFile = None

        try:
            self._stateVariableList = ConfigClass.stateVariableBuilderConfig[
                "L1L2"][swModule]["stateVariableList"]
        except KeyError:
            self._stateVariableList = {}

        self._TracesGetter = Class_L1L2TracesGetter(
            self._tlInfo,
            self._swModule,
            self._sourceItf,
            self._destFolder,
            self._stateVariableList,
            self._tsharkDissector,
            Filter)
        threading.Thread(target=self.F_mainLoop).start()

    # ##----------------------------------------------------------------------------------------------------------###

    def F_mainLoop(self):
        """
            Mainloop of module - must be executed in a separate thread. Get the traces, parse it and send it to SVM
            return: No return
        """
        debugWrite("TsharkStateVariableBuilder.F_mainLoop started")

        # Start Collecting traces
        self._TracesGetter.F_startCollection()

        # Make the storage folder if it does not exist
        try:
            os.makedirs(self._destFolder)
        except OSError:
            pass

        currentFileName = self._TracesGetter.F_getLastFile("JSON")
        self._lastTransferredFile = currentFileName
        while (not self._eventStop) or (currentFileName is not None):
            if currentFileName:
                self._F_SendToStateVector(currentFileName)
            time.sleep(1)
            currentFileName = self._TracesGetter.F_getLastFile("JSON")
            if self._eventStop:
                self._lastTransferredFile = currentFileName

    # ##----------------------------------------------------------------------------------------------------------###

    def F_stop(self):
        """
            Collect the last traces and stop the mainloop and the trace collection
            return: No return
        """
        self._TracesGetter.F_stopCollection()
        self._eventStop = True
        while self._lastTransferredFile is not None:
            debugWrite(
                "Waiting end of transfer for file %s" %
                self._lastTransferredFile)
            time.sleep(1)
        self._F_forceFlush()
        self._outSock.close()

    # ##----------------------------------------------------------------------------------------------------------###

    def _F_FileToJsonData(self, Filename):
        """
            Convert a Json File to Json Data
            param:  Filename: Path to the Json file
            return: A List containing the Json Data. None if there is no Json message in the file
        """
        Data = None
        LinePrev = False
        with open(Filename) as JsonFileDesc:
            for line in JsonFileDesc:
                # Skip Header. Header end when two lines begin with '--' char
                if line.startswith('--'):
                    if LinePrev:
                        # When header has ended, convert json file to Json
                        # Python Data
                        Data = json.load(JsonFileDesc)
                    else:
                        LinePrev = True
                else:
                    LinePrev = False
        return Data

    # ##----------------------------------------------------------------------------------------------------------###

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
        traceDict["frame.traceType"] = "tshark.L1L2"
        traceDict["frame.trigger"] = trigger
        self._nbOfFieldsInHeader = 4

    # ##----------------------------------------------------------------------------------------------------------###

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

    # ##----------------------------------------------------------------------------------------------------------###

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

    # ##----------------------------------------------------------------------------------------------------------###

    def _F_flushTrace(self, traceItem):
        """
            Send the trace to the SVM with a TCP JSON message
            param:  traceItem: trace dict to send
            return: No return
        """
        if (traceItem is not None):
            if len(traceItem) > self._nbOfFieldsInHeader:
                # print(traceItem)
                # time.sleep(0.1)
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

    def _F_forceFlush(self):
        packetToSend = struct.pack(
            '>I', self._packetSize) + b"".join(self._packetToSend)
        # debugWrite(packetToSend)
        self._packetToSend = []
        self._outSock.send(packetToSend)

    # ##---------------------------------------------------------------------------------------------------------###

    def _F_SendToStateVector(self, Filename):
        """
            Parse and send the JSON file message content to the SVM
            param:  Filename: Path to the JSON File
            return: No return
        """
        traceDict = None
        copyMessage = False
        itemValue = '{'
        timeEpoch = 0

        itemName = 'event.L1L2.Message'
        with open(Filename, "r") as JSONFile:
            for line in JSONFile:
                if not copyMessage:
                    if line.startswith('    "_source": {'):
                        itemValue += line.rstrip().replace(' ', '')
                        copyMessage = True
                else:
                    itemValue += line.rstrip()
                    if 'frame.time_epoch' in line:
                        timeEpoch = line.rstrip().split(':')[1][2:-2]
                    if line.startswith('    }'):
                        traceDict = self._F_getTraceDict(timeEpoch, "message")
                        self._F_storeItem(traceDict, itemName, itemValue + '}')
                        self._F_flushTrace(traceDict)
                        traceDict = None
                        copyMessage = False
                        itemValue = '{'
                        timeEpoch = 0
