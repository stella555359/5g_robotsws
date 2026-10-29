import time
import os
import glob
import scanf
import json
import socket
import threading
import calendar
import traceback
import struct


class EmilStateVariableBuilder:
    def __init__(self, emilFolder, tcpDestIp, tcpDestPort):
        self._emilFolder = emilFolder
        self._tcpDestIp = tcpDestIp
        self._tcpDestPort = tcpDestPort
        self._outSock = socket.socket(
            socket.AF_INET, socket.SOCK_STREAM)  # TCP
        self._outSock.connect((self._tcpDestIp, self._tcpDestPort))
        self._lastValue = {}
        self._eventStop = False
        threading.Thread(target=self._mainLoop).start()

    def stop(self):
        self._eventStop = True
        self._outSock.close()

    def _getLastFileToDecode(self):
        fileList = sorted(
            glob.glob(
                self._emilFolder +
                "/Fields2UserAllMessages*.txt"))
        return (fileList[-1])

    def _flushTrace(self, traceItem, minNumber=0):
        if len(traceItem) > minNumber:
            jsonMsg = json.dumps(traceItem, indent=2)
            jsonMsg = struct.pack('>I', len(jsonMsg)) + jsonMsg.encode('utf-8')
            self._outSock.send(jsonMsg)
            # print(jsonMsg)

    def _storeAndCheckChange(self, itemName, itemValue, instanceKey):
        result = False
        if instanceKey not in self._lastValue:
            self._lastValue[instanceKey] = {}

        if itemName not in self._lastValue[instanceKey]:
            self._lastValue[instanceKey][itemName] = None

        if self._lastValue[instanceKey][itemName] != itemValue:
            self._lastValue[instanceKey][itemName] = itemValue
            result = True

        return (result)

    def _mainLoop(self):
        try:
            while not self._eventStop:
                try:
                    currentFileName = self._getLastFileToDecode()
                    file = open(currentFileName, 'r')
                except IOError:
                    print("Cannot open file")
                    time.sleep(1)
                    continue

                currentPos = 0
                traceItem = {}

                while not self._eventStop:
                    currentPos = file.tell()
                    line = file.readline()
                    if line:
                        if not line.endswith("\n"):
                            line = None

                    if not line:
                        if currentFileName != self._getLastFileToDecode():
                            file.close()
                            break
                        time.sleep(1)
                        file.seek(currentPos)
                    else:
                        # print(line, "EOL\n")
                        if line.startswith("TraceId:"):
                            self._flushTrace(traceItem, minNumber=5)
                            traceItem = {}
                            traceItem["frame.traceType"] = "emil"
                            traceItem["frame.trigger"] = "message"
                            # TraceId: 3 - Time: 2018/02/06 15:53:39.085704
                            # UTC+0
                            (traceItem["event.emil.traceId"], traceDate, traceTime, traceOffset) = scanf.scanf(
                                "TraceId: %d - Time: %s %s %s", line)
                            # print("\ntraceDate, traceTime, traceOffset", traceDate, traceTime, traceOffset)
                            (timeSecond, fractionSecond) = traceTime.split('.')
                            # print("timeSecond, fractionSecond", timeSecond, fractionSecond)
                            emilTimeSecond = traceDate + " " + timeSecond + " " + traceOffset
                            # print("emilTimeSecond", emilTimeSecond)
                            timeStruct = time.strptime(
                                emilTimeSecond, "%Y/%m/%d %H:%M:%S %Z%z")
                            # print("timeStruct", timeStruct)
                            secondsEpoch = calendar.timegm(timeStruct)
                            # print("secondsEpoch", secondsEpoch)
                            localTime = time.strftime(
                                "%Y/%m/%d %H:%M:%S", time.localtime(secondsEpoch))
                            # print("localTime", localTime)
                            # traceItem["emilTimestamp"] = traceDate + " " + traceTime + " " + traceOffset
                            traceItem["frame.timestamp"] = localTime + \
                                "." + fractionSecond
                            traceItem["frame.time_epoch"] = str(
                                secondsEpoch) + "." + fractionSecond
                            # print(traceItem)

                        if line.startswith("CRNTI:"):
                            (crnti,) = scanf.scanf("CRNTI: %d", line)
                            if self._storeAndCheckChange(
                                    "crnti", crnti, traceItem["event.emil.traceId"]):
                                traceItem["event.emil.crnti"] = crnti

                        if line.startswith("FsUeId:"):
                            (fsUeId,) = scanf.scanf("FsUeId: %d", line)
                            if self._storeAndCheckChange(
                                    "fsUeId", fsUeId, traceItem["event.emil.traceId"]):
                                traceItem["event.emil.fsUeId"] = fsUeId

                        if line.strip().startswith("message c1"):
                            (traceItem["event.emil.rrcMessageId"],) = scanf.scanf(
                                "message c1 : %s", line.strip())

                        if line.strip().startswith("establishmentCause "):
                            (traceItem["event.emil.establishmentCause"],) = scanf.scanf(
                                "establishmentCause %s", line.strip().replace(",", ""))

                        if line.strip().startswith("Decoded NAS message:"):
                            traceItem["event.emil.nasMessageId"] = line.strip().split(
                                ':')[-1]
        except Exception:
            print("Exception: " + traceback.format_exc(limit=5))
        print("EmilStateVariableBuilder mainLoop stopped")


if __name__ == '__main__':
    emilStateVariableBuilder = EmilStateVariableBuilder(
        "//135.120.146.217/d$/TRACES/Emil/", "127.0.0.1", 5001)
