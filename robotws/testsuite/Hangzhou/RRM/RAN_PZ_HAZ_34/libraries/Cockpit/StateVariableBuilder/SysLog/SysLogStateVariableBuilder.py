# description:  State Variable builders for all text syslogs
#
# history:
#               22/03/2019 - RJO: creation

import time
import os
import json
import socket
import threading
import select
import traceback
import struct
import re

from datetime import datetime
import pytz
from ...Cockpit_Debug import debugWrite
from ...Cockpit_Config import ConfigClass
from ...utilities.SshConnection import SshConnection
from ...utilities.Constants import Constants


# import cProfile, pstats, io


class SysLogStateVariableBuilder:
    def __init__(
        self,
        tlInfo,
        swModule,
        shortCommand,
        minimumTimeForAnalysis,
        destFolder,
        tcpDestIp,
        tcpDestPort,
    ):
        """
        Initialize and start in a thread a new syslog SVB
        :param tlInfo: Information about the test line that will be used
        :param swModule: Module on which the log must be gathered (e.g. 'fct0-a', 'aspa-1c')
        :param shortCommand: log to collect
        :param minimumTimeForAnalysis: time from which the data will be analyzed
        :param destFolder: folder where the collected traces will be stored
        :param tcpDestIp: ip address of the computer that execute the State Vector Manager
        :param tcpDestPort: tcp port of the server of communications between SVBs and SVM
        """
        self._swModule = swModule
        self._shortCommand = shortCommand
        self._command = shortCommand
        self._tlInfo = tlInfo
        if "Classical" in tlInfo["type"]:
            self._isClassical = True
            self._commandType = shortCommand
            if "fct-0a" in swModule:
                self._commandType = "asik"
                if "startup_DEFAULT" in shortCommand:
                    self._command = "tail -n+0 -f /tmp/startup_DEFAULT.log; xzcat /tmp/startup_DEFAULT.log.xz"
                if "startup_NODEOAM" in shortCommand:
                    self._command = "tail -n+0 -f /tmp/startup_NODEOAM.log; zcat /tmp/startup_NODEOAM.log.[0-9].gz"
                if "startup_OAMAGENT" in shortCommand:
                    self._command = "tail -n+0 -f /tmp/startup_OAMAGENT.log; zcat /tmp/startup_OAMAGENT.log.[0-9].gz"
                if "cpcl_startup_DEFAULT" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /tmp/node_0xe002/tmp/startup_DEFAULT.log;"
                        " xzcat /tmp/node_0xe002/tmp/startup_DEFAULT.log.xz")
                if "cpif_startup_DEFAULT" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /tmp/node_0xe004/tmp/startup_DEFAULT.log;"
                        " xzcat /tmp/node_0xe004/tmp/startup_DEFAULT.log.xz")
                if "cpnb_startup_DEFAULT" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /tmp/node_0xe003/tmp/startup_DEFAULT.log;"
                        " xzcat /tmp/node_0xe003/tmp/startup_DEFAULT.log.xz")
                if "journalctl" in shortCommand:
                    self._command = "journalctl --utc -o short-iso-precise -n 10000 -f"
                if "oam_startup_DEFAULT" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /tmp/node_0xe000/tmp/startup_DEFAULT.log;"
                        " xzcat /tmp/node_0xe000/tmp/startup_DEFAULT.log.xz")
                if "oam_startup_RACOAM" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /ram/node_0xe000/opt/nokia/SS"
                        "_MzOam/cloud-racoam/logs/startup_RACOAM.log"
                    )
                if "oam_startup_SITEOAM" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /ram/node_0xe000/opt/nokia/SS"
                        "_MzOam/cloud-siteoam/siteoam/logs/startup_SITEOAM.log"
                    )
                if "upue_EmQueue" in shortCommand:
                    self._command = "tail -n+0 -f /tmp/node_0xe00a/tmp/EmQueue.log"
                if "upue_startup" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /tmp/node_0xe00a/tmp/FCTL-E00A_startup.log;"
                        " zcat /tmp/node_0xe00a/tmp/FCTL-E00A_startup.zip")
                if "cpcl_startup" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /tmp/node_0xe002/tmp/startup_cp_cl.log;"
                        " xzcat /tmp/node_0xe002/tmp/startup_cp_cl.log.xz"
                    )
                if "cpif_startup" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /tmp/node_0xe004/tmp/startup_cp_if.log;"
                        " xzcat /tmp/node_0xe004/tmp/startup_cp_if.log.xz"
                    )
                if "cpnb_startup" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /tmp/node_0xe003/tmp/startup_cp_nb.log;"
                        " xzcat /tmp/node_0xe003/tmp/startup_cp_nb.log.xz"
                    )

            if "fct-0b" in swModule:
                self._commandType = "asik"
                if "cpue_startup" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /tmp/node_0xe007/tmp/startup_cp_ue.log;"
                        " xzcat /tmp/node_0xe007/tmp/startup_cp_ue.log.xz"
                    )
                if "cprt_startup" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /tmp/node_0xe005/tmp/startup_cp_rt.log;"
                        " xzcat /tmp/node_0xe005/tmp/startup_cp_rt.log.xz"
                    )
                if "cprt_startup_DEFAULT" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /tmp/node_0xe005/tmp/startup_DEFAULT.log;"
                        " xzcat /tmp/node_0xe005/tmp/startup_DEFAULT.log.xz")
                if "cpue_startup_DEFAULT" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /tmp/node_0xe007/tmp/startup_DEFAULT.log;"
                        " xzcat /tmp/node_0xe007/tmp/startup_DEFAULT.log.xz")
                if "startup_DEFAULT" in shortCommand:
                    self._command = "tail -n+0 -f /tmp/startup_DEFAULT.log; xzcat /tmp/startup_DEFAULT.log.xz"
                if "journalctl" in shortCommand:
                    self._command = "journalctl --utc -o short-iso-precise -n 10000 -f"

            if "fct-4b" in swModule:
                self._commandType = "asik"
                if "cpue_startup" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /tmp/node_0xe007/tmp/startup_cp_ue.log;"
                        " xzcat /tmp/node_0xe007/tmp/startup_cp_ue.log.xz"
                    )
                if "cprt_startup" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /tmp/node_0xe005/tmp/startup_cp_rt.log;"
                        " xzcat /tmp/node_0xe005/tmp/startup_cp_rt.log.xz"
                    )
                if "cprt_startup_DEFAULT" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /tmp/node_0xe005/tmp/startup_DEFAULT.log;"
                        " xzcat /tmp/node_0xe005/tmp/startup_DEFAULT.log.xz")
                if "cpue_startup_DEFAULT" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /tmp/node_0xe007/tmp/startup_DEFAULT.log;"
                        " xzcat /tmp/node_0xe007/tmp/startup_DEFAULT.log.xz")
                if "startup_DEFAULT" in shortCommand:
                    self._command = "tail -n+0 -f /tmp/startup_DEFAULT.log; xzcat /tmp/startup_DEFAULT.log.xz"
                if "journalctl" in shortCommand:
                    self._command = "journalctl --utc -o short-iso-precise -n 10000 -f"

            if "asp-1a" in swModule:
                self._commandType = "abil"
                if "startup_DEFAULT" in shortCommand:
                    self._command = "tail -n+0 -f /tmp/startup_DEFAULT.log; xzcat /tmp/startup_DEFAULT.log.xz"
                if "journalctl" in shortCommand:
                    self._command = "journalctl --utc -o short-iso -n 10000 -f"

            if "asp-1b" in swModule:
                self._commandType = "abil"
                if "startup_DEFAULT" in shortCommand:
                    self._command = "tail -n+0 -f /tmp/startup_DEFAULT.log; xzcat /tmp/startup_DEFAULT.log.xz"
                if "journalctl" in shortCommand:
                    self._command = "journalctl --utc -o short-iso -n 10000 -f"

            if "aspa-1c" in swModule:
                self._commandType = "abil"
                if "journalctl" in shortCommand:
                    self._command = "journalctl --utc -o short-iso -n 10000 -f"

            try:
                self._counterList = ConfigClass.stateVariableBuilderConfig[
                    "SysLog"][self._commandType]["counterList"]
            except KeyError:
                self._counterList = ()
                debugWrite(
                    "no counterList found in ",
                    ConfigClass.stateVariableBuilderConfig["SysLog"],
                )

        else:
            self._isClassical = False
            if "ethtool" in shortCommand:
                self._command = (
                    "while sleep 1; do ethtool -S ethc0 | grep -i good; done;"
                )
            if "FSP_startup" in shortCommand:
                self._command = (
                    "tail -n+0 -f /tmp/node_0x*/tmp/FSP-*_startup.log;"
                    " xzcat /tmp/node_0x*/tmp/FSP-*_startup.log.xz"
                )
            if "startup_" in shortCommand:
                if "startup_DEFAULT" in shortCommand:
                    self._command = "tail -n+0 -f /tmp/startup_DEFAULT.log; xzcat /tmp/startup_DEFAULT.log.xz"
                if "oam-0" in swModule and "startup_RACOAM" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /opt/nokia/SS_MzOam/cloud-racoam/logs/startup_RACOAM.log;"
                        " zcat /opt/nokia/SS_MzOam/cloud-racoam/logs/startup_RACOAM.log.[0-9].gz")
                if "oam-0" in swModule and "startup_SITEOAM" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /opt/nokia/SS_MzOam/cloud-siteoam/siteoam/logs/startup_SITEOAM.log;"
                        " zcat /opt/nokia/SS_MzOam/cloud-siteoam/siteoam/logs/startup_SITEOAM.[0-9].log.gz")
                if "oam-0" in swModule and "startup_OAMAGENT" in shortCommand:
                    self._command = (
                        "tail -n+0 -f /opt/nokia/SS_MzOam/oamagentjs/logs/startup_OAMAGENT.log;"
                        " zcat /opt/nokia/SS_MzOam/oamagentjs/logs/startup_OAMAGENT.log.[0-9].gz")
                if "rap01" in swModule and "startup_NODEOAM" in shortCommand:
                    self._command = "tail -n+0 -f /tmp/startup_NODEOAM.log; zcat /tmp/startup_NODEOAM.log.[0-9].gz"
                if "asik" in swModule and "startup_NODEOAM" in shortCommand:
                    self._command = "tail -n+0 -f /tmp/startup_NODEOAM.log; zcat /tmp/startup_NODEOAM.log.[0-9].gz"
                if "rap01" in swModule and "startup_OAMAGENT" in shortCommand:
                    self._command = "tail -n+0 -f /tmp/startup_OAMAGENT.log; zcat /tmp/startup_OAMAGENT.log.[0-9].gz"
            if "journalctl" in shortCommand:
                if "abil" in swModule:
                    self._command = "journalctl --utc -o short-iso -n 10000 -f"
                else:
                    self._command = (
                        "sudo journalctl --utc -o short-iso-precise -n 10000 -f"
                    )
            if "L3_SYSLOG" in shortCommand:
                self._command = "tail --retry -n+0 -f /opt/AirPhone/L3/SYSLOG.log"
            try:
                self._counterList = ConfigClass.stateVariableBuilderConfig[
                    "SysLog"][swModule]["counterList"]
            except KeyError:
                self._counterList = ()
                debugWrite(
                    "no counterList found in ",
                    ConfigClass.stateVariableBuilderConfig["SysLog"],
                )
        if "trcinfo" in shortCommand:
            self._command = (
                "command=export PATH=$PATH:/lsu/nodebin:/lsu/bin:/lsu/app:/sbin:/usr/sbin:/usr/bin:/bin:"
                "/usr/sbin:/sbin:/usr/local/bin:/opt/bin:/opt/sbin:/home/user/bin;"
                " trcinfo -p0-2 > /home/user/logFile.log & tail -f -n+0 /home/user/logFile.log")
        self._tlInfo = tlInfo
        self._destFolder = destFolder
        self._minimumTimeForAnalysis = minimumTimeForAnalysis
        self._lastTimeStamp = Constants.MAX_TIME_SECONDS
        self._currYearString = str(datetime.today().year) + "-"
        self._epoch = datetime.utcfromtimestamp(0).replace(tzinfo=pytz.utc)

        try:
            self._counterList = ConfigClass.stateVariableBuilderConfig[
                "SysLog"][swModule]["counterList"]
        except KeyError:
            self._counterList = ()
            debugWrite(
                "no counterList found in ",
                ConfigClass.stateVariableBuilderConfig["SysLog"],
            )

        try:
            os.makedirs(destFolder)
        except OSError:
            pass

        self._tcpDestIp = tcpDestIp
        self._tcpDestPort = tcpDestPort
        self._outSock = socket.socket(
            socket.AF_INET, socket.SOCK_STREAM)  # TCP
        self._outSock.connect((self._tcpDestIp, self._tcpDestPort))
        self._lastValue = {}
        self._eventStop = False
        self._traceCollection = {}
        self._counters = {}
        self._packetToSend = []
        self._packetSize = 0
        debugWrite("launching _mainLoop")
        threading.Thread(target=self._mainLoop).start()

    def stop(self):
        """
        Stop the state variable builder and send the remaining collected logs to the SVM
        :return: None
        """
        self._eventStop = True
        time.sleep(1)
        self._forceFlush()
        time.sleep(1)
        self._outSock.close()

    def getCounters(self):
        """
        return the counters list, for a counter mode use
        :return: counters list
        """
        debugWrite("SysLog Counters: ", self._counters)
        return self._counters

    def waitCounter(self, counterName, counterWaitedValue, timeOut):
        """
        Wait for a counter to appear
        :param counterName: Name of the counter
        :param counterWaitedValue: Number of times the counter must appear to stop waiting
        :param timeOut: time out before an exception is raised
        :return:
        """
        debugWrite("Waiting %s >= %d" % (counterName, counterWaitedValue))
        nbSeconds = 0
        currentCounterValue = 0
        while nbSeconds < timeOut:
            if counterName in self._counters:
                currentCounterValue = self._counters[counterName]
                # debugWrite("%s = %d"%(counterName, currentCounterValue))
                if currentCounterValue >= counterWaitedValue:
                    debugWrite("%s = %d" % (counterName, currentCounterValue))
                    break
            time.sleep(1)
            nbSeconds += 1
        if currentCounterValue < counterWaitedValue:
            debugWrite("Couters: ", self._counters)
            raise Exception(
                "Timeout while waiting for '%s' >= %d"
                % (counterName, counterWaitedValue)
            )
        return currentCounterValue

    def _flushTrace(self, traceItem):
        """
        save the trace to be send to the SVM and send all the traces if the packet to send is big enough
        :param traceItem: trace Item to send
        :return: None
        """
        if traceItem is not None:
            if len(traceItem) > self._nbOfFieldsInHeader:
                jsonMsg = json.dumps(traceItem)
                jsonMsg = struct.pack(
                    ">I", len(jsonMsg)) + jsonMsg.encode("utf-8")
                self._packetToSend.append(jsonMsg)
                self._packetSize += len(jsonMsg)
                if self._packetSize > 100000:
                    packetToSend = struct.pack(
                        ">I", self._packetSize) + b"".join(self._packetToSend)
                    self._packetToSend = []
                    self._packetSize = 0
                    self._outSock.send(packetToSend)
                # debugWrite(jsonMsg)

    def _forceFlush(self):
        """
        Send all the messages to the SVM, whatever the size
        :return: None
        """
        packetToSend = struct.pack(">I", self._packetSize) + b"".join(
            self._packetToSend
        )
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
        if itemValue is not None:
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
        traceDict["frame.traceType"] = "sysLog"
        traceDict["frame.trigger"] = trigger
        self._nbOfFieldsInHeader = 4

    def _getTraceDict(self, secondsEpoch, trigger):
        """
        Get a new dictionary that can contain a message that dates from secondsEpoch
        :param secondsEpoch: time since Epoch
        :param trigger: trigger to the new message (e.g. message)
        :return: dictionary
        """
        localTime = time.strftime(
            "%Y/%m/%d %H:%M:%S",
            time.localtime(secondsEpoch))
        if isinstance(secondsEpoch, int):
            timeEpoch = str(secondsEpoch) + ".0"
        else:
            timeEpoch = str(secondsEpoch)
        (secondsEpochStr, fractionSecondStr) = timeEpoch.split(".")
        timestamp = localTime + "." + fractionSecondStr
        traceDict = {}
        self._fillTraceDictHeader(traceDict, timestamp, timeEpoch, trigger)

        return traceDict

    def _sendToStateVector(self, itemvalue, secondsEpoch):
        """
        Send a new value to the State Vector Manager
        :param itemvalue: value to send (string )
        :param secondsEpoch: time since Epoch
        :return: None
        """
        tracedict = self._getTraceDict(secondsEpoch, "message")
        if self._isClassical is True:
            itemtype = "event.syslog." + self._swModule + "." + self._shortCommand
        else:
            itemtype = "event.syslog." + self._swModule
        self._storeItem(tracedict, itemtype, itemvalue.replace("\n", ""))
        self._flushTrace(tracedict)

    def _analyseLine(self, line):
        """
        Analyse a line from a syslog, parse it and send it to the SVM
        :param line: line to analyse
        :return: None
        """
        timeIndex = line.find(self._currYearString)

        if timeIndex >= 0:
            # Try to scan something like 2018-06-27T08:41:33.137
            if len(line) > timeIndex + 23:
                traceTime = line[timeIndex: timeIndex + 23]
                try:
                    utcDatetime = datetime.strptime(
                        traceTime, "%Y-%m-%dT%H:%M:%S.%f"
                    ).replace(tzinfo=pytz.utc)
                    secondsEpoch = (utcDatetime - self._epoch).total_seconds()
                    self._lastTimeStamp = secondsEpoch
                    if self._swModule in [
                        "cpcl-0",
                        "cpif-0",
                        "cpnb-0",
                        "cpue-0",
                        "oam-0",
                        "upue-0",
                    ]:
                        itemvalue = re.sub(
                            r"\S+ \S+ (?P<value>(.)+)", "\\g<value>", line
                        )
                    else:
                        itemvalue = re.sub(
                            r"\S+ \S+ (?P<value>(.)+)", "\\g<value>", line[timeIndex:]
                        )[4:].rstrip()
                    # The following code check if the line is part of a json
                    # message inside the syslog file
                    if self._JsonProbability is 0:
                        if itemvalue.endswith("{"):
                            if len(itemvalue) is 1:
                                self._itemvalue += itemvalue
                            else:
                                self._sendToStateVector(
                                    self._itemvalue, int(self._lastTimeStamp)
                                )
                                self._itemvalue = ""
                                self._itemvalue = itemvalue
                            self._JsonProbability = 1
                        else:
                            self._sendToStateVector(
                                self._itemvalue, int(self._lastTimeStamp)
                            )
                            self._itemvalue = ""
                            self._itemvalue = itemvalue
                    elif self._JsonProbability is 1:
                        if re.findall(r"\"(.)*\": ", line):
                            self._JsonProbability = 2
                            self._itemvalue += itemvalue
                        else:
                            self._sendToStateVector(
                                self._itemvalue, int(self._lastTimeStamp)
                            )
                            self._itemvalue = ""
                            self._itemvalue = itemvalue
                    elif self._JsonProbability is 2:
                        if len(itemvalue) > 4:
                            if itemvalue[0] is not " " and itemvalue[1] is not " ":
                                self._sendToStateVector(
                                    self._itemvalue, int(self._lastTimeStamp)
                                )
                        self._itemvalue += itemvalue
                        if itemvalue.startswith("}"):
                            self._JsonProbability = 0

                except Exception as e:
                    print(e)
                    pass

        else:
            # Should not be used because the collected trace should have the
            # right date format
            try:
                traceTime = line[:15]
                # Try to scan something like Sep 05 14:04:37
                # utcDatetime = datetime.strptime(traceTime, "%b %d
                # %H:%M:%S").replace(tzinfo=timezone.utc,
                currentYear = int(self._currYearString[:-1])
                utcDatetime = datetime.strptime(
                    traceTime, "%b %d %H:%M:%S").replace(
                    tzinfo=pytz.utc, year=currentYear)
                secondsEpoch = (utcDatetime - self._epoch).total_seconds()
                if self._itemvalue:
                    self._sendToStateVector(
                        self._itemvalue.replace("\r", "").replace("\n", ""),
                        int(self._lastTimeStamp),
                    )
                self._lastTimeStamp = secondsEpoch
                self._itemvalue = re.sub(
                    r"\S+ \S+ \S+ \S+ (?P<value>(.)+)", "\\g<value>", line
                )
            except Exception:
                try:
                    self._itemvalue += line
                except Exception:
                    pass

        if self._lastTimeStamp > self._minimumTimeForAnalysis:
            for counterName in self._counterList:
                if counterName in line:
                    if counterName not in self._counters:
                        self._counters[counterName] = 0
                    self._counters[counterName] += 1

    def _mainLoop(self):
        """
        Main function of a syslog SVB. Get the syslog, analyse it and send the result to the SVM
        :return: None
        """
        debugWrite("enter")
        self._itemvalue = ""
        self._JsonProbability = 0
        try:
            # Connect to the swModule
            debugFile = open(
                self._destFolder
                + "/_debug"
                + self._swModule
                + "_"
                + self._shortCommand
                + ".log",
                "a",
            )
            debugFile.write(
                time.strftime("%H:%M:%S - ")
                + "SysLogStateVariableBuilder._mainLoop started for "
                + self._swModule
                + "\n"
            )
            while not self._eventStop:
                try:
                    sshConnection = SshConnection()
                    sshConnection.connect(self._tlInfo, self._swModule)
                    debugFile.write(
                        time.strftime("%H:%M:%S - ")
                        + "Connected to "
                        + self._tlInfo[self._swModule]["hostname"]
                        + "\n"
                    )
                    break

                except Exception:
                    debugWrite(
                        "Exception in SysLogStateVariableBuilder\n"
                        + traceback.format_exc()
                        + "\nEnd of Exception"
                    )
                    debugFile.write(
                        time.strftime("%H:%M:%S - ")
                        + "Exception in SysLogStateVariableBuilder\n"
                        + traceback.format_exc()
                        + "\nEnd of Exception\n"
                    )

                    time.sleep(1)

            try:
                BUF_SIZE = 10240
                LeftOver = ""
                transport = sshConnection.get_transport()
                transport.set_keepalive(1)
                channel = transport.open_session()
                # channel.settimeout(1)
                cmd = "hostname; pwd;" + self._command
                channel.get_pty()
                channel.exec_command(cmd)
                outFile = open(
                    self._destFolder
                    + "/"
                    + self._swModule
                    + "_"
                    + self._shortCommand
                    + ".log",
                    "a",
                )
                debugFile.write(
                    time.strftime("%H:%M:%S - ") +
                    "Starting loop" +
                    "\n")
                while not self._eventStop:
                    # If connection to the swModule is lost
                    if not transport.is_active():
                        debugFile.write(
                            time.strftime("%H:%M:%S - ")
                            + "Lost connection - try reconnecting"
                            + "\n"
                        )
                        # Reconnect
                        while not self._eventStop:
                            try:
                                sshConnection = SshConnection()
                                sshConnection.connect(
                                    self._tlInfo, self._swModule)
                                debugFile.write(
                                    time.strftime("%H:%M:%S - ")
                                    + "Connected to "
                                    + self._tlInfo[self._swModule]["hostname"]
                                    + "\n"
                                )
                                break
                            except Exception:
                                pass
                        time.sleep(10)
                        transport = sshConnection.get_transport()
                        transport.set_keepalive(1)
                        channel = transport.open_session()
                        cmd = "hostname; pwd;" + self._command
                        channel.get_pty()
                        channel.exec_command(cmd)
                    # debugWrite(time.strftime("%H:%M:%S - ") + "transport is active for " +
                    #  self._swModule + "_" + self._shortCommand)
                    rl, wl, xl = select.select([channel], [], [], 1.0)
                    if len(rl) > 0:
                        buf = channel.recv(BUF_SIZE)
                        if len(buf) > 0:
                            lines_to_process = LeftOver + \
                                buf.decode(errors="ignore")
                            EOL = lines_to_process.rfind("\n")
                            if EOL != len(lines_to_process) - 1:
                                LeftOver = lines_to_process[EOL + 1:]
                                lines_to_process = lines_to_process[: EOL + 1]
                            else:
                                LeftOver = ""
                            for line in lines_to_process.splitlines():
                                try:
                                    outFile.write(line + "\n")
                                except IOError:
                                    debugWrite(
                                        "Exception in SysLogStateVariableBuilder\n" +
                                        traceback.format_exc() +
                                        "\nEnd of Exception")
                                    debugFile.write(
                                        time.strftime("%H:%M:%S - ") +
                                        "Exception in SysLogStateVariableBuilder\n" +
                                        traceback.format_exc() +
                                        "\nEnd of Exception\n")
                                self._analyseLine(line)
                                try:
                                    debugFile.write(
                                        time.strftime("%H:%M:%S - ")
                                        + "line analyzed: "
                                        + line
                                        + "\n"
                                    )
                                except Exception:
                                    debugFile.write(
                                        time.strftime("%H:%M:%S - ")
                                        + "line contains illegal char\n"
                                    )
                        else:
                            debugFile.write(
                                time.strftime("%H:%M:%S - ") + "sleep 1s - 1\n"
                            )
                            time.sleep(1)
                    else:
                        debugFile.write(
                            time.strftime("%H:%M:%S - ") + "sleep 1s - 2\n")
                        time.sleep(1)
                debugFile.write(
                    time.strftime("%H:%M:%S - ") + "Closing connection" + "\n"
                )
                try:
                    channel.close()
                except Exception:
                    debugWrite(
                        "channel.close() Exception in SysLogStateVariableBuilder\n"
                    )
                    debugFile.write(
                        time.strftime("%H:%M:%S - ") +
                        "channel.close() Exception in SysLogStateVariableBuilder\n")
                transport.close()
                sshConnection.close()
                outFile.close()
            except Exception:
                debugWrite(
                    "Exception in SysLogStateVariableBuilder\n"
                    + traceback.format_exc()
                    + "\nEnd of Exception"
                )
                debugFile.write(
                    time.strftime("%H:%M:%S - ")
                    + "Exception in SysLogStateVariableBuilder\n"
                    + traceback.format_exc()
                    + "\nEnd of Exception\n"
                )

            debugFile.write(
                time.strftime("%H:%M:%S - ")
                + "SysLogStateVariableBuilder._mainLoop stopped"
                + "\n"
            )
            debugFile.close()
        except Exception:
            debugWrite("Exception: " + traceback.format_exc(limit=5))
        debugWrite("exit")
