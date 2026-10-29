from builtins import hex
from builtins import str
from builtins import range
from builtins import object
import base64
import socket
import struct
import sys
import time
import traceback
import urllib.request
import urllib.error


class CDspCrash(object):
    def __init__(self, targetIpAddress, targetPort, debug):
        self.__targetIpAddress = targetIpAddress
        self.__targetPort = targetPort
        self.__debugEnable = debug
        self.__socket = None
        self.__connectionEstablished = False
        self.__LENGTH_OF_MSG_HEADER = 16

    def openConnection(self, socket1=socket):
        """
        :param socket1:
        :return:
        """
        print("Open connection to", self.__targetIpAddress, ":", self.__targetPort)
        try:
            self.__socket = socket1.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.__socket.settimeout(10.0)
            self.__socket.connect((self.__targetIpAddress, self.__targetPort))
            self.__socket.settimeout(2.0)
            print("Connection established")
            self.__connectionEstablished = True
        except socket.error as inst:
            traceback.print_exc()
            print("ERROR: Connection failed (" + str(inst) + ").")
            print("Is R&D port service enabled? Try with argument --enableRnDPort")
        return self.__connectionEstablished

    def closeConnection(self):
        print("Closing connection")
        closeConnectionSuccessful = True
        self.__connectionEstablished = False
        try:
            self.__socket.close()
        except socket.error as inst:
            traceback.print_exc()
            print("Failure in closing socket. " + str(inst))
            closeConnectionSuccessful = False
        return closeConnectionSuccessful

    def generateExceptionToDsp(self, dspType1, board, cpu):
        if not self.__connectionEstablished:
            print("Connection to BTS is not established")
            return False
        if dspType1 == "faraday":
            return self.__raiseExceptionToFaraday(board, cpu)
        elif dspType1 == "nyquist":
            return self.__raiseExceptionToNyquist(board, cpu)
        elif dspType1 == "kepler":
            return self.__raiseExceptionToKepler(board, cpu)
        else:
            print("ERROR: Unknown dspType received:" + dspType1)
            return False

    def generateSilentCrashToDsp(self, dspType1, board, cpu, silentCrashType):
        if not self.__connectionEstablished:
            print("Connection to BTS is not established")
            return False
        successStatus = True
        print(
            "Generating silentCrash GPIO:"
            + str(silentCrashType)
            + " to board:"
            + board
            + " "
            + dspType1
            + ":"
            + cpu
        )
        disableEdcAddress = "0x01846008"
        disableEdcData = ["0x00000008"]
        disableMemProtectionAddress = "0x0184A200"
        disableMemProtectionData = ["0x0000FF3F"]
        gpioAddress = "0x00800080"
        if (
            silentCrashType == 0 or silentCrashType == 2,
            silentCrashType == 4,
            silentCrashType == 6,
        ):
            gpioData = ["0x0000A120"]
        else:
            gpioData = ["0x036803E2", "0x031908F2", "0x0D1803A2", "0x0003A120"]
        cacheL1DWbAllAddress = "0x01845044"
        cacheL1DWbAllData = ["0x00000001"]
        cacheL1PInvAllAddress = "0x01845028"
        cacheL1PInvAllData = ["0x00000001"]
        if dspType1 == "nyquist":
            dspCpuList = [1, 3, 2, 4]
        elif dspType1 == "kepler":
            dspCpuList = [1, 3, 2, 4, 5, 6, 7, 8]
        else:
            dspCpuList = [1, 3, 2]
        for x in dspCpuList:
            if (
                silentCrashType == 0
                or silentCrashType == 2
                or silentCrashType == 4
                or silentCrashType == 6
            ) or x == int(cpu[3:4]):
                success = []
                if (
                    silentCrashType == 0
                    or silentCrashType == 1
                    or silentCrashType == 2
                    or silentCrashType == 4
                    or silentCrashType == 6
                ):
                    print(
                        "+Configuring PDSP7 as Accumulator working in reclamation mode"
                        " (for queue 0x0338 [824dec])"
                    )
                    Pdsp7_cmdBuffAddr_off4 = "0x02A38004"
                    recQ = ["0x00000338"]
                    success.append(
                        self.__writeToDspWithBrowserDspMemoryReq(
                            Pdsp7_cmdBuffAddr_off4, recQ, board, cpu[0:3] + str(x)
                        )
                    )
                    Pdsp7_cmdBuffAddr = "0x02A38000"
                    recCmd = ["0x00008300"]
                    success.append(
                        self.__writeToDspWithBrowserDspMemoryReq(
                            Pdsp7_cmdBuffAddr, recCmd, board, cpu[0:3] + str(x)
                        )
                    )
                    print(
                        "+Now pausing QMSS TX queue 0x0338 [824dec]"
                        ", to prevent accumulator-pktDma race condition on that queue."
                    )
                    infraPktDma_Chann24_Addr = "0x02A08700"
                    pauseChannelValue = ["0xA0000000"]
                    success.append(
                        self.__writeToDspWithBrowserDspMemoryReq(
                            infraPktDma_Chann24_Addr,
                            pauseChannelValue,
                            board,
                            cpu[0:3] + str(x),
                        )
                    )
                    print(
                        "Updating SRIO GC registers with new queue (ID 0x0338 [824dec])"
                    )
                    gcBaseAddress = "0x02900EE0"
                    gcQueuesData = ["0x03380338", "0x03380338", "0x03380338"]
                    success.append(
                        self.__writeToDspWithBrowserDspMemoryReq(
                            gcBaseAddress, gcQueuesData, board, cpu[0:3] + str(x)
                        )
                    )
                    print("\nDisabling EDC from " + cpu[0:3] + str(x))
                    success.append(
                        self.__writeToDspWithBrowserDspMemoryReq(
                            disableEdcAddress, disableEdcData, board, cpu[0:3] + str(x)
                        )
                    )
                    print("Disabling memory protection from " + cpu[0:3] + str(x))
                    success.append(
                        self.__writeToDspWithBrowserDspMemoryReq(
                            disableMemProtectionAddress,
                            disableMemProtectionData,
                            board,
                            cpu[0:3] + str(x),
                        )
                    )
                    print(
                        "Patching fsync interrupt vector with GPIO:"
                        + str(silentCrashType)
                        + " from "
                        + cpu[0:3]
                        + str(x)
                    )
                    success.append(
                        self.__writeToDspWithBrowserDspMemoryReq(
                            gpioAddress, gpioData, board, cpu[0:3] + str(x)
                        )
                    )
                if silentCrashType == 0 or silentCrashType == 1:
                    print("Flushing L1D and L1P caches from " + cpu[0:3] + str(x))
                    success.append(
                        self.__writeToDspWithBrowserDspMemoryReq(
                            cacheL1DWbAllAddress,
                            cacheL1DWbAllData,
                            board,
                            cpu[0:3] + str(x),
                        )
                    )
                    success.append(
                        self.__writeToDspWithBrowserDspMemoryReq(
                            cacheL1PInvAllAddress,
                            cacheL1PInvAllData,
                            board,
                            cpu[0:3] + str(x),
                        )
                    )
                if silentCrashType == 2 or silentCrashType == 3:
                    print("Disable DSP RXU from " + cpu[0:3] + str(x))
                    success.append(
                        self.__writeToDspWithBrowserDspMemoryReq(
                            "0x0290004C", ["0x00000000"], board, cpu[0:3] + str(x)
                        )
                    )
                if silentCrashType == 4 or silentCrashType == 5:
                    print("Disable DSP TXU from " + cpu[0:3] + str(x))
                    success.append(
                        self.__writeToDspWithBrowserDspMemoryReq(
                            "0x02900044", ["0x00000000"], board, cpu[0:3] + str(x)
                        )
                    )
                if (silentCrashType == 6 or silentCrashType == 7) and x == int(
                    cpu[3:4]
                ):
                    print("Pause DSP RX channels from " + cpu[0:3] + str(x))
                    # TEARDOWN HACK: Send messages several times
                    # as they are not set properly for the first time.
                    for _ in range(0, 5):
                        success.append(
                            self.__writeToDspWithBrowserDspMemoryReq(
                                "0x02901800", ["0x40000000"], board, cpu[0:3] + str(x)
                            )
                        )
                        success.append(
                            self.__writeToDspWithBrowserDspMemoryReq(
                                "0x02901820", ["0x40000000"], board, cpu[0:3] + str(x)
                            )
                        )
                        success.append(
                            self.__writeToDspWithBrowserDspMemoryReq(
                                "0x02901840", ["0x40000000"], board, cpu[0:3] + str(x)
                            )
                        )
                        success.append(
                            self.__writeToDspWithBrowserDspMemoryReq(
                                "0x02901860", ["0x40000000"], board, cpu[0:3] + str(x)
                            )
                        )
                        success.append(
                            self.__writeToDspWithBrowserDspMemoryReq(
                                "0x02901880", ["0x40000000"], board, cpu[0:3] + str(x)
                            )
                        )
                        success.append(
                            self.__writeToDspWithBrowserDspMemoryReq(
                                "0x029018A0", ["0x40000000"], board, cpu[0:3] + str(x)
                            )
                        )
                        success.append(
                            self.__writeToDspWithBrowserDspMemoryReq(
                                "0x029018C0", ["0x40000000"], board, cpu[0:3] + str(x)
                            )
                        )
                        success.append(
                            self.__writeToDspWithBrowserDspMemoryReq(
                                "0x029018E0", ["0x40000000"], board, cpu[0:3] + str(x)
                            )
                        )
                        success.append(
                            self.__writeToDspWithBrowserDspMemoryReq(
                                "0x02901900", ["0x40000000"], board, cpu[0:3] + str(x)
                            )
                        )
                        success.append(
                            self.__writeToDspWithBrowserDspMemoryReq(
                                "0x02901920", ["0x40000000"], board, cpu[0:3] + str(x)
                            )
                        )
                        success.append(
                            self.__writeToDspWithBrowserDspMemoryReq(
                                "0x02901940", ["0x40000000"], board, cpu[0:3] + str(x)
                            )
                        )
                        success.append(
                            self.__writeToDspWithBrowserDspMemoryReq(
                                "0x02901960", ["0x40000000"], board, cpu[0:3] + str(x)
                            )
                        )
                        success.append(
                            self.__writeToDspWithBrowserDspMemoryReq(
                                "0x02901980", ["0x40000000"], board, cpu[0:3] + str(x)
                            )
                        )
                        success.append(
                            self.__writeToDspWithBrowserDspMemoryReq(
                                "0x029019A0", ["0x40000000"], board, cpu[0:3] + str(x)
                            )
                        )
                        success.append(
                            self.__writeToDspWithBrowserDspMemoryReq(
                                "0x029019C0", ["0x40000000"], board, cpu[0:3] + str(x)
                            )
                        )
                        success.append(
                            self.__writeToDspWithBrowserDspMemoryReq(
                                "0x029019E0", ["0x40000000"], board, cpu[0:3] + str(x)
                            )
                        )
                        time.sleep(0.1)
                    print(
                        "In case 'faultId = 2074', 'SrioRetryStoppedAl' is not visible."
                        " Fault visible only in syslog. Try again since setting params"
                        " might have not worked for the first time."
                    )
                if not all(success):
                    print(
                        "ERROR: In generating silent crash with CPU:"
                        + cpu[0:3]
                        + str(x)
                    )
                    successStatus = False
        if successStatus:
            print("\nSilent crash generated succesfully.")
        else:
            print("\nERROR: occured during silent crash generation")
        return successStatus

    def sendFaultIndicationMessageToBts(
        self, board, cpu, faultId, faultMsg, faultState
    ):
        if not self.__connectionEstablished:
            print("Connection to BTS is not established")
            return False
        if faultMsg == "0x3400":
            try:
                (
                    FAULT_INDICATION_MSG,
                    faultIndicationMsg,
                ) = self.__generateFaultIndicationMessage0x3400(
                    board, cpu, faultId, faultState
                )
                print(
                    "Sending FAULT_INDICATION_MSG 0x3400 with faultId:"
                    + str(faultId)
                    + " from board:"
                    + board
                    + ", cpu:"
                    + cpu
                )
                packedMessage = self.__createMessage(
                    FAULT_INDICATION_MSG, faultIndicationMsg
                )
                self.__socket.send(packedMessage)
                return True
            except socket.error as inst:
                traceback.print_exc()
                print(
                    "Failure when sending FAULT_INDICATION_MSG 0x3400 to BTS. "
                    + str(inst)
                )
                return False
        elif faultMsg == "0x2414":
            try:
                (
                    LOM_FAULT_IND_MSG,
                    lomFaultIndMsg,
                ) = self.__generateLomFaultIndMessage0x2414(
                    board, cpu, faultId, faultState
                )
                print(
                    "Sending LOM_FAULT_IND_MSG 0x2414 with faultId:"
                    + str(faultId)
                    + " from board:"
                    + board
                    + ", cpu:"
                    + cpu
                )
                packedMessage = self.__createMessage(LOM_FAULT_IND_MSG, lomFaultIndMsg)
                self.__socket.send(packedMessage)
                return True
            except socket.error as inst:
                traceback.print_exc()
                print(
                    "Failure when sending LOM_FAULT_IND_MSG 0x2414 to BTS. " + str(inst)
                )
                return False
        elif faultMsg == "0x8008":
            try:
                FAULT_IND_MSG, faultIndMsg = self.__generateFaultIndMessage0x8008(
                    board, cpu, faultId, faultState
                )
                print(
                    "Sending FAULT_IND_MSG 0x8008 with faultId:"
                    + str(faultId)
                    + " from board:"
                    + board
                    + ", cpu:"
                    + cpu
                )
                packedMessage = self.__createMessage(FAULT_IND_MSG, faultIndMsg)
                self.__socket.send(packedMessage)
                return True
            except socket.error as inst:
                traceback.print_exc()
                print("Failure when sending FAULT_IND_MSG 0x8008 to BTS. " + str(inst))
                return False
        elif faultMsg.lower() == "0x2b84":
            try:
                API_ALARM_MSG, apiAlarmMsg = self.__generateApiAlarmMessage0x2b84(
                    board, cpu, faultId
                )
                print(
                    "Sending API_ALARM_MSG 0x2b84 with faultId:"
                    + str(faultId)
                    + " from board:"
                    + board
                    + ", cpu:"
                    + cpu
                )
                packedMessage = self.__createMessage(API_ALARM_MSG, apiAlarmMsg)
                self.__socket.send(packedMessage)
                return True
            except socket.error as inst:
                traceback.print_exc()
                print("Failure when sending API_ALARM_MSG 0x2b84 to BTS. " + str(inst))
                return False
        elif faultMsg.lower() == "0x802a":
            try:
                FAULT_REQ_MSG, faultReqMsg = self.__generateFaultReqMessage0x802a(
                    board, cpu, faultId, faultState
                )
                print(
                    "Sending FAULT_REQ_MSG 0x802a with faultId:"
                    + str(faultId)
                    + " from board:"
                    + board
                    + ", cpu:"
                    + cpu
                )
                packedMessage = self.__createMessage(FAULT_REQ_MSG, faultReqMsg)
                self.__socket.send(packedMessage)
                return True
            except socket.error as inst:
                traceback.print_exc()
                print("Failure when sending FAULT_REQ_MSG 0x802a to BTS. " + str(inst))
                return False

    def registerNewMemdumpArea(self, board, cpu, dumpStartAddress, dumpLenght):
        if not self.__connectionEstablished:
            print("Connection to BTS is not established")
            return False
        try:
            (
                MEMORY_DUMP_REGISTER_IND_MSG,
                memoryDumpRegisterInd,
            ) = self.__generateMemoryDumpRegisterIndMessage(
                board, cpu, dumpStartAddress, dumpLenght
            )
            print(
                "Sending MEMORY_DUMP_REGISTER_IND_MSG 0x8107 to register memory address:"
                + dumpStartAddress
                + " lenght:"
                + dumpLenght
                + " to board:"
                + board
                + " cpu:"
                + cpu
            )
            packedMessage = self.__createMessage(
                MEMORY_DUMP_REGISTER_IND_MSG, memoryDumpRegisterInd
            )
            self.__socket.send(packedMessage)
            return True
        except socket.error as inst:
            traceback.print_exc()
            print(
                "Failure when sending MEMORY_DUMP_REGISTER_IND_MSG 0x8107 to BTS. "
                + str(inst)
            )
            return False

    def generateDspReset(self, dspType1, board, cpu, dspResetType):
        if not self.__connectionEstablished:
            print("Connection to BTS is not established")
            return False
        successStatus = False
        try:
            API_RESET_MSG, apiResetReq = self.__generateApiResetReqMessage(
                dspType1, board, cpu, dspResetType
            )
            print(
                "Generating dspReset type:"
                + str(dspResetType)
                + " to board:"
                + board
                + " "
                + dspType1
                + ":"
                + cpu
            )
            packedMessage = self.__createMessage(API_RESET_MSG, apiResetReq)
            self.__socket.send(packedMessage)
            print("API_RESET_REQ 0x2B81 sent. Waiting for reply.")
        except socket.error as inst:
            traceback.print_exc()
            print(
                "ERROR: Failure when sending first API_RESET_REQ 0x2B81 to BTS. "
                + str(inst)
            )
            successStatus = False
        if self.__isExpectedReplyMessageOK("0x2b82"):
            print("API_RESET_RESP 0x2B82, received with OK status")
        else:
            print("ERROR: API_RESET_RESP 0x2B82, not received or NOK status")
            successStatus = False
        try:
            apiResetReq["resetState"] = "0x00000000"  # 0=Reset RELEASE
            print("Releasing from reset board:" + board + " " + dspType1 + ":" + cpu)
            packedMessage = self.__createMessage(API_RESET_MSG, apiResetReq)
            self.__socket.send(packedMessage)
            print("API_RESET_REQ 0x2B81 sent. Waiting for reply.")
        except socket.error as inst:
            traceback.print_exc()
            print(
                "ERROR: Failure when sending secnd API_RESET_REQ 0x2B81 to BTS. "
                + str(inst)
            )
            successStatus = False
        if self.__isExpectedReplyMessageOK("0x2b82"):
            print("API_RESET_RESP 0x2B82, received with OK status")
        else:
            print("ERROR: API_RESET_RESP 0x2B82, not received or NOK status")
            successStatus = False
        return successStatus

    def sendApiResetMsg(self, dspType1, board, cpu, apiReset):
        if not self.__connectionEstablished:
            print("Connection to BTS is not established")
            return False
        successStatus = False
        try:
            API_RESET_MSG, apiResetReq = self.__generateApiResetReqMessage2(
                dspType1, board, cpu, apiReset
            )
            print(
                "Generating apiReset state:"
                + str(apiReset[0])
                + ", extra:"
                + str(apiReset[1])
                + " to board:"
                + board
                + " "
                + ":"
                + cpu
            )
            packedMessage = self.__createMessage(API_RESET_MSG, apiResetReq)
            self.__socket.send(packedMessage)
            print("API_RESET_REQ 0x2B81 sent. Waiting for reply.")
        except socket.error as inst:
            traceback.print_exc()
            print(
                "ERROR: Failure when sending first API_RESET_REQ 0x2B81 to BTS. "
                + str(inst)
            )
            successStatus = False
        if self.__isExpectedReplyMessageOK("0x2b82"):
            print("API_RESET_RESP 0x2B82, received with OK status")
        else:
            print("ERROR: API_RESET_RESP 0x2B82, not received or NOK status")
            successStatus = False
        return successStatus

    def writeDataToDsp(self, board, cpu, memoryAddress, dataToWrite):
        print(
            "Writing data:"
            + dataToWrite
            + " to address:"
            + memoryAddress
            + " to board:"
            + board
            + " cpu:"
            + cpu
        )
        dataToWriteList = []
        dataToWriteList.append(dataToWrite)
        successStatus = self.__writeToDspWithBrowserDspMemoryReq(
            memoryAddress, dataToWriteList, board, cpu
        )
        if successStatus:
            print("Data written to DSP succesfully")
        else:
            print("ERROR: occured when writing data to DSP")
        return successStatus

    def enableRnDPort(self, targetIpAddress):
        enableOK = False
        print("Enabling R&D Port from " + targetIpAddress)
        address = "https://" + targetIpAddress + "/protected/enableRndPorts.cgi"
        auth_encoded = base64.b64encode(b"Nemuadmin:nemuuser")
        req = urllib.request.Request(address)
        req.add_header("Authorization", "Basic %s" % auth_encoded)
        try:
            response = urllib.request.urlopen(req)
            lines = response.readlines()
            for line in lines:
                if line.find("R&D Ports Service Enabled Successfully") != -1:
                    enableOK = True
            if enableOK:
                print("R&D Port Enabled Successfully")
            else:
                print("R&D Port Enabling Failed")
        except urllib.error.HTTPError:
            print("R&D Port Enabling Failed except")
        return enableOK

    def __createMessage(self, messageDefinition, messageContent):
        packedMessage = bytes()
        for x in messageDefinition:
            if len(messageContent.get(x)) == 6:
                packedMessage += struct.pack(
                    "H", socket.htons(int(eval(messageContent.get(x))))
                )
            elif len(messageContent.get(x)) == 4:
                packedMessage += struct.pack("B", int(eval(messageContent.get(x))))
            else:
                packedMessage += struct.pack(
                    "I", socket.htonl(int(eval(messageContent.get(x))))
                )
        return packedMessage

    def __returnSenderTaskFromTargetPort(self, targetPort):
        if targetPort == 15001:
            return "0308"
        elif targetPort == 15002:
            return "04CF"
        elif targetPort == 15003:
            return "0315"
        elif targetPort == 15004:
            return "031D"
        elif targetPort == 15005:
            return "031C"
        print("ERROR, could not parse senderTask from targetPort:" + str(targetPort))
        return False

    def __receiveToBuffer(self):
        try:
            receiveBuffer = self.__socket.recv(5120)
            self.__debugPrint(
                "DEBUG(__receiveToBuffer):receiveBuffer:"
                + self.__decodeToHex(receiveBuffer)
            )
            return receiveBuffer
        except socket.timeout:
            print(" __receiveToBuffer: socket.timeout No data received")
        except Exception as errorCode:
            if errorCode[0] == 10035:
                print(
                    " __receiveToBuffer: socket.error [errno: 10035] No data received"
                )
                time.sleep(1)
            else:
                print(
                    " __receiveToBuffer: unexpected socket.error, ErrorCode:", errorCode
                )
        return bytes()

    def __decodeToHex(self, receivedMessage):
        hexString = "0x"
        for x in range(0, len(receivedMessage)):
            hexString += "%0.2x" % struct.unpack("B", receivedMessage[x:x+1])
        return hexString

    def __decodeMessageHeaderFromBuffer(self, msgHeaderBuffer):
        fmt = "IIIHH"
        unpacked = struct.unpack(fmt, msgHeaderBuffer)
        decodedMsgId = "0x%0.8x" % (socket.ntohl(unpacked[0]))
        decodedMsgLength = "0x%0.4x" % (socket.ntohs(unpacked[3]))
        self.__debugPrint(
            "DEBUG(__decodeMessageHeaderFromBuffer):decodedMsgId:"
            + decodedMsgId
            + ",decodedMsgLenght:"
            + decodedMsgLength
        )
        return decodedMsgId, decodedMsgLength

    def __waitForReplyMessage(self, expectedMsgId):
        receiveBuffer = bytes()
        for _ in range(0, 10):
            receiveBuffer += self.__receiveToBuffer()
            if len(receiveBuffer) > self.__LENGTH_OF_MSG_HEADER:
                decodedMsgId, decodedMsgLength = self.__decodeMessageHeaderFromBuffer(
                    receiveBuffer[0:self.__LENGTH_OF_MSG_HEADER]
                )
                if len(receiveBuffer) >= eval(decodedMsgLength):
                    if eval(decodedMsgId) == eval(expectedMsgId):
                        return receiveBuffer[: eval(decodedMsgLength)]
                    else:
                        print(
                            "Received message:"
                            + decodedMsgId
                            + " , expecting message: "
                            + expectedMsgId
                        )
                        receiveBuffer = receiveBuffer[eval(decodedMsgLength):]
                else:
                    self.__debugPrint(
                        "DEBUG(__waitForReplyMessage): Length of receiveBuffer less than decodedMsgLenght"
                    )
            else:
                self.__debugPrint(
                    "DEBUG(__waitForReplyMessage): Length of receiveBuffer less than LENGTH_OF_MSG_HEADER"
                )
        # else:
        print("WARNING: Expected reply message " + expectedMsgId + " not received")
        return False

    def __isReply0x2c5aOK(self, replyMessage):
        fmt = "IIIHHIIIIII"
        successCode = ""
        try:
            unpacked = struct.unpack(fmt, replyMessage)
            successCode = "0x%0.8x" % (socket.ntohl(unpacked[6]))
        except struct.error:
            print("Error in handling received reply!")
            return False
        if successCode == "0x00000000":
            return True
        else:
            return False

    def __isReply0x2c45OK(self, replyMessage):
        fmt = "IIIHHIIIIIIIIIIII"
        responseStatus = ""
        try:
            unpacked = struct.unpack(fmt, replyMessage)
            responseStatus = "0x%0.8x" % (socket.ntohl(unpacked[6]))
        except struct.error:
            print("Error in handling received reply!")
            return False
        if responseStatus == "0x00000000":
            return True
        else:
            return False

    def __isReply0x2b82OK(self, replyMessage):
        fmt = "IIIHHIIIII"
        successCode = ""
        try:
            unpacked = struct.unpack(fmt, replyMessage)
            successCode = "0x%0.8x" % (socket.ntohl(unpacked[5]))
        except struct.error:
            print("Error in handling received reply!")
            return False
        if successCode == "0x00000000":
            return True
        else:
            return False

    def __isReply0x0f8aOK(self, replyMessage):
        fmt = "IIIHHI"
        successCode = ""
        try:
            unpacked = struct.unpack(fmt, replyMessage)
            successCode = "0x%0.8x" % (socket.ntohl(unpacked[5]))
        except struct.error:
            print("Error in handling received reply!")
            return False
        if successCode == "0x00000000":
            return True
        else:
            return False

    def __isReply0x12c1OK(self, replyMessage):
        # https://docs.python.org/2/library/struct.html#format-characters
        fmt = "IIIHHIIII"  # 4+4+4+2+2+4+4+4+4 = 32
        successCode = ""
        try:
            unpacked = struct.unpack(fmt, replyMessage)
            successCode = "0x%0.8x" % (socket.ntohl(unpacked[6]))
        except struct.error:
            print("Error in handling received reply!")
            return False
        if successCode == "0x00000000":
            return True
        else:
            return False

    def __isExpectedReplyMessageOK(self, expectedMsgId):
        replyMessage = self.__waitForReplyMessage(expectedMsgId)
        if replyMessage:
            if expectedMsgId.lower() == "0x2c5a":
                return self.__isReply0x2c5aOK(replyMessage)
            elif expectedMsgId.lower() == "0x2c45":
                return self.__isReply0x2c45OK(replyMessage)
            elif expectedMsgId.lower() == "0x2b82":
                return self.__isReply0x2b82OK(replyMessage)
            elif expectedMsgId.lower() == "0x0f8a":
                return self.__isReply0x0f8aOK(replyMessage)
            elif expectedMsgId.lower() == "0x12c1":
                return self.__isReply0x12c1OK(replyMessage)
            print("No handling for", expectedMsgId.lower())
            return False

    def __raiseExceptionToFaraday(self, board, cpu):
        successStatus = True
        try:
            (
                API_SET_L2_MEM_CONFIG_REQ_MSG,
                apiSetL2MemConfigReqMsg,
            ) = self.__generateApiSetL2MemConfigReqMessage(board, cpu)
            print("Generating exception to FSMr2 FSP:" + board + " faraday:" + cpu)
            packedMessage = self.__createMessage(
                API_SET_L2_MEM_CONFIG_REQ_MSG, apiSetL2MemConfigReqMsg
            )
            self.__socket.send(packedMessage)
            print("API_SET_L2_MEM_CONFIG_REQ_MSG 0x2C59 sent. Waiting for reply.")
        except socket.error as inst:
            traceback.print_exc()
            print(
                "Failure when sending first API_SET_L2_MEM_CONFIG_REQ_MSG 0x2C59 to BTS. "
                + str(inst)
            )
            successStatus = False
        if self.__isExpectedReplyMessageOK("0x2c5a"):
            print("API_SET_L2_MEM_CONFIG_RESP_MSG 0x2C5A, received with OK status")
        else:
            print(
                "ERROR: API_SET_L2_MEM_CONFIG_RESP_MSG 0x2C5A, not received or NOK status"
            )
            successStatus = False
        try:
            print(
                "Reverting back to symmetric mode, FSMr2 FSP:"
                + board
                + " faraday:"
                + cpu
            )
            apiSetL2MemConfigReqMsg["l2ConfigItem1"] = "0x00000000"
            packedMessage = self.__createMessage(
                API_SET_L2_MEM_CONFIG_REQ_MSG, apiSetL2MemConfigReqMsg
            )
            self.__socket.send(packedMessage)
            print("API_SET_L2_MEM_CONFIG_REQ_MSG 0x2C59 sent. Waiting for reply.")
        except socket.error as inst:
            traceback.print_exc()
            print(
                "Failure when sending second API_SET_L2_MEM_CONFIG_REQ_MSG 0x2C59 to BTS. "
                + str(inst)
            )
            successStatus = False
        if self.__isExpectedReplyMessageOK("0x2c5a"):
            print("API_SET_L2_MEM_CONFIG_RESP_MSG 0x2C5A, received with OK status")
            print("Exception generated successfully")
        else:
            print(
                "ERROR: API_SET_L2_MEM_CONFIG_RESP_MSG 0x2C5A, not received or NOK status"
            )
            successStatus = False
        return successStatus

    def __raiseExceptionToNyquist(self, board, cpu):
        successStatus = True
        try:
            (
                API_SET_IO_PIN_STATE_REQ,
                apiSetIoPinStateReqMsg,
            ) = self.__generateApiSetIoPinStateReqMessage(board, cpu)
            print("Generating exception to FSMr3 FSP:" + board + " nyquist:" + cpu)
            packedMessage = self.__createMessage(
                API_SET_IO_PIN_STATE_REQ, apiSetIoPinStateReqMsg
            )
            self.__socket.send(packedMessage)
            print("API_SET_IO_PIN_STATE_REQ 0x2C44 sent. Waiting for reply.")
        except socket.error as inst:
            traceback.print_exc()
            print(
                "Failure when sending API_SET_IO_PIN_STATE_REQ 0x2C44 to BTS. "
                + str(inst)
            )
            successStatus = False
        if self.__isExpectedReplyMessageOK("0x2c45"):
            print("API_SET_IO_PIN_STATE_RESP 0x2C45, received with OK status")
            print("Exception generated successfully")
        else:
            print("ERROR: API_SET_IO_PIN_STATE_RESP 0x2C45, not received or NOK status")
            successStatus = False
        return successStatus

    def __raiseExceptionToKepler(self, board, cpu):
        successStatus = True
        try:
            API_DSP_CRASH_REQ_MSG, dspCrashReqMsg = self.__generateApiDspCrashReqMessage(
                board, cpu
            )
            print("Generating exception to FSMr4 FSP:" + board + " kepler:" + cpu)
            packedMessage = self.__createMessage(API_DSP_CRASH_REQ_MSG, dspCrashReqMsg)
            self.__socket.send(packedMessage)
            print("API_DSP_CRASH_REQ_MSG 0x12c0 sent. Waiting for reply.")
        except socket.error as inst:
            traceback.print_exc()
            print(
                "Failure when sending API_DSP_CRASH_REQ_MSG 0x12c0 to BTS. " + str(inst)
            )
            successStatus = False
        if self.__isExpectedReplyMessageOK("0x12c1"):
            print("API_DSP_CRASH_RESP_MSG 0x12c1, received with OK status")
            print("Exception generated successfully")
        else:
            print("ERROR: API_DSP_CRASH_RESP_MSG 0x12c1, not received or NOK status")
            successStatus = False
        return successStatus

    def __writeToDspWithBrowserDspMemoryReq(
        self, sourceAddress, sourceData, board, cpu
    ):
        try:
            (
                BROWSER_DSP_MEMORY_REQ,
                browserDspMemoryReq,
            ) = self.__generateBrowserDspMemoryReqMessage(
                sourceAddress, sourceData, board, cpu
            )
            packedMessage = self.__createMessage(
                BROWSER_DSP_MEMORY_REQ, browserDspMemoryReq
            )
            self.__socket.send(packedMessage)
            return True
        except socket.error as inst:
            traceback.print_exc()
            print(
                "Failure when sending BROWSER_DSP_MEMORY_REQ 0x1BEB to BTS. "
                + str(inst)
            )
            return False

    def __debugPrint(self, debugString):
        if self.__debugEnable:
            print(debugString)
        return True

    def __generateApiResetReqMessage(self, dspType1, board, cpu, dspResetType):
        senderTask = self.__returnSenderTaskFromTargetPort(self.__targetPort)
        API_RESET_MSG = [
            "headerMsgId",
            "headerReceiver",
            "headerSender",
            "headerLenght",
            "headerFlags",
            "targetBoard",
            "targetCpu",
            "resetState",
            "resetExtra",
        ]
        apiResetReq = {}
        apiResetReq["headerMsgId"] = "0x00002B81"
        if dspType1 == "nyquist":
            apiResetReq["headerReceiver"] = "0x101104A7"
        else:
            apiResetReq["headerReceiver"] = "0x" + board[2:4] + "0D04A7"
        apiResetReq["headerSender"] = "0x1011" + senderTask
        apiResetReq["headerLenght"] = "0x0020"
        apiResetReq["headerFlags"] = "0x0000"
        apiResetReq["targetBoard"] = "0x000000" + board[2:4]
        apiResetReq["targetCpu"] = "0x000000" + cpu[2:3] + "0"
        apiResetReq["resetState"] = "0x00000001"  # 1=Reset SET
        apiResetReq["resetExtra"] = "0x0000000" + str(dspResetType)
        return API_RESET_MSG, apiResetReq

    def __generateApiResetReqMessage2(self, dspType1, board, cpu, apiReset):
        senderTask = self.__returnSenderTaskFromTargetPort(self.__targetPort)
        API_RESET_MSG = [
            "headerMsgId",
            "headerReceiver",
            "headerSender",
            "headerLenght",
            "headerFlags",
            "targetBoard",
            "targetCpu",
            "resetState",
            "resetExtra",
        ]
        apiResetReq = {}
        apiResetReq["headerMsgId"] = "0x00002B81"
        if dspType1 == "nyquist":
            apiResetReq["headerReceiver"] = "0x101104A7"
        else:
            apiResetReq["headerReceiver"] = "0x" + board[2:4] + "0D04A7"
        apiResetReq["headerSender"] = "0x1011" + senderTask
        apiResetReq["headerLenght"] = "0x0020"
        apiResetReq["headerFlags"] = "0x0000"
        apiResetReq["targetBoard"] = "0x000000" + board[2:4]
        apiResetReq["targetCpu"] = "0x000000" + cpu[2:4]
        apiResetReq["resetState"] = "0x0000000" + str(apiReset[0])
        apiResetReq["resetExtra"] = "0x0000000" + str(apiReset[1])
        return API_RESET_MSG, apiResetReq

    def __generateApiSetL2MemConfigReqMessage(self, board, cpu):
        senderTask = self.__returnSenderTaskFromTargetPort(self.__targetPort)
        API_SET_L2_MEM_CONFIG_REQ_MSG = [
            "headerMsgId",
            "headerReceiver",
            "headerSender",
            "headerLenght",
            "headerFlags",
            "transactionId",
            "numberOfItems",
            "chipItem1",
            "l2ConfigItem1",
            "resultItem1",
        ]
        apiSetL2MemConfigReqMsg = {}
        apiSetL2MemConfigReqMsg["headerMsgId"] = "0x00002C59"
        apiSetL2MemConfigReqMsg["headerReceiver"] = "0x" + board[2:4] + "0D04B5"
        apiSetL2MemConfigReqMsg["headerSender"] = "0x1011" + senderTask
        apiSetL2MemConfigReqMsg["headerLenght"] = "0x0024"
        apiSetL2MemConfigReqMsg["headerFlags"] = "0x0000"
        apiSetL2MemConfigReqMsg["transactionId"] = "0x00000000"
        apiSetL2MemConfigReqMsg["numberOfItems"] = "0x00000001"
        apiSetL2MemConfigReqMsg["chipItem1"] = "0x000000" + cpu[2:3] + "0"
        apiSetL2MemConfigReqMsg["l2ConfigItem1"] = "0x00000001"
        apiSetL2MemConfigReqMsg["resultItem1"] = "0x00000000"
        return API_SET_L2_MEM_CONFIG_REQ_MSG, apiSetL2MemConfigReqMsg

    def __generateApiSetIoPinStateReqMessage(self, board, cpu):
        senderTask = self.__returnSenderTaskFromTargetPort(self.__targetPort)
        API_SET_IO_PIN_STATE_REQ = [
            "headerMsgId",
            "headerReceiver",
            "headerSender",
            "headerLenght",
            "headerFlags",
            "transactionId",
            "ioPin",
            "state",
        ]
        apiSetIoPinStateReqMsg = {}
        apiSetIoPinStateReqMsg["headerMsgId"] = "0x00002C44"
        apiSetIoPinStateReqMsg["headerReceiver"] = board[0:3] + "01104B5"
        apiSetIoPinStateReqMsg["headerSender"] = board[0:3] + "011" + senderTask
        apiSetIoPinStateReqMsg["headerLenght"] = "0x001C"
        apiSetIoPinStateReqMsg["headerFlags"] = "0x0000"
        apiSetIoPinStateReqMsg["transactionId"] = "0x00000000"
        if board[3:4] == "2":
            apiSetIoPinStateReqMsg["ioPin"] = (
                "0x000000" + str(hex(32 + int(cpu[2:3]) - 3))[2:4]
            )
        elif board[3:4] == "3":
            apiSetIoPinStateReqMsg["ioPin"] = (
                "0x000000" + str(hex(39 + int(cpu[2:3]) - 3))[2:4]
            )
        elif board[3:4] == "4":
            apiSetIoPinStateReqMsg["ioPin"] = (
                "0x000000" + str(hex(46 + int(cpu[2:3]) - 3))[2:4]
            )
        apiSetIoPinStateReqMsg["state"] = "0x00000003"
        return API_SET_IO_PIN_STATE_REQ, apiSetIoPinStateReqMsg

    def __generateApiDspCrashReqMessage(self, board, cpu):
        senderTask = self.__returnSenderTaskFromTargetPort(self.__targetPort)
        API_DSP_CRASH_REQ_MSG = [
            "headerMsgId",
            "headerReceiver",
            "headerSender",
            "headerLenght",
            "headerFlags",
            "transactionId",
            "nodeId",
        ]
        receiverTask = "04B9"
        apiDspCrashReqMsg = {}
        apiDspCrashReqMsg["headerMsgId"] = "0x000012C0"
        apiDspCrashReqMsg["headerReceiver"] = board[0:4] + cpu[2:3] + "D" + receiverTask
        apiDspCrashReqMsg["headerSender"] = board[0:3] + "011" + senderTask
        apiDspCrashReqMsg["headerLenght"] = "0x0018"
        apiDspCrashReqMsg["headerFlags"] = "0x0000"
        apiDspCrashReqMsg["transactionId"] = "0x00000000"
        apiDspCrashReqMsg["nodeId"] = "0x00000000"
        return API_DSP_CRASH_REQ_MSG, apiDspCrashReqMsg

    def __generateBrowserDspMemoryReqMessage(
        self, sourceAddress, sourceData, board, cpu
    ):
        _ = self.__returnSenderTaskFromTargetPort(self.__targetPort)
        BROWSER_DSP_MEMORY_REQ = [
            "headerMsgId",
            "headerReceiver",
            "headerSender",
            "headerLenght",
            "headerFlags",
            "writeData",
            "dataCount",
            "dspDataAddress",
            "dspData",
        ]
        browserDspMemoryReq = {}
        browserDspMemoryReq["headerMsgId"] = "0x00001BEB"
        browserDspMemoryReq["headerReceiver"] = board + cpu[2:4] + "023B"
        browserDspMemoryReq["headerSender"] = "0x10110308"
        browserDspMemoryReq["headerLenght"] = "0x0020"
        browserDspMemoryReq["headerFlags"] = "0x0000"
        browserDspMemoryReq["writeData"] = "0x00000001"
        browserDspMemoryReq["dataCount"] = "0x00000004"
        browserDspMemoryReq["dspDataAddress"] = sourceAddress
        browserDspMemoryReq["dspData"] = sourceData[0]
        if len(sourceData) > 1:
            for y in range((len(sourceData) - 1)):
                BROWSER_DSP_MEMORY_REQ.append("extraDspData" + str(y + 1))
                browserDspMemoryReq["extraDspData" + str(y + 1)] = sourceData[y + 1]
                browserDspMemoryReq["dataCount"] = "0x%.8x" % int(
                    eval(browserDspMemoryReq.get("dataCount")) + 4
                )
                browserDspMemoryReq["headerLenght"] = "0x%.4x" % int(
                    eval(browserDspMemoryReq.get("headerLenght")) + 4
                )
        return BROWSER_DSP_MEMORY_REQ, browserDspMemoryReq

    def __generateFaultIndicationMessage0x3400(self, board, cpu, faultId, faultState):
        senderTask = self.__returnSenderTaskFromTargetPort(self.__targetPort)
        FAULT_INDICATION_MSG = [
            "headerMsgId",
            "headerReceiver",
            "headerSender",
            "headerLenght",
            "headerFlags",
            "faultId",
            "faultSeverity",
            "faultState",
            "time",
            "faultSource",
            "faultLocation",
            "faultInfo0",
            "faultInfo1",
            "faultInfo2",
            "faultInfo3",
            "faultInfo4",
            "faultInfo5",
            "faultInfo6",
            "faultInfo7",
            "faultInfo8",
            "faultInfo9",
            "faultInfo10",
            "faultInfo11",
        ]
        faultIndicationMsg = {}
        faultIndicationMsg["headerMsgId"] = "0x00003400"
        faultIndicationMsg["headerReceiver"] = "0x10110009"
        faultIndicationMsg["headerSender"] = "0x1011" + senderTask
        faultIndicationMsg["headerLenght"] = "0x0058"
        faultIndicationMsg["headerFlags"] = "0x0000"
        faultIndicationMsg["faultId"] = "0x%.8x" % faultId
        faultIndicationMsg["faultSeverity"] = "0x00000001"
        faultIndicationMsg["faultState"] = "0x%.8x" % faultState
        faultIndicationMsg["time"] = "0x00000000"
        faultIndicationMsg["faultSource"] = "0x" + board[2:4] + cpu[2:4] + "04C1"
        faultIndicationMsg["faultLocation"] = "0x" + board[2:4] + cpu[2:4] + "04C1"
        faultIndicationMsg["faultInfo0"] = "0x00000000"
        faultIndicationMsg["faultInfo1"] = "0x00000000"
        faultIndicationMsg["faultInfo2"] = "0x00000000"
        faultIndicationMsg["faultInfo3"] = "0x00000000"
        faultIndicationMsg["faultInfo4"] = "0x00000000"
        faultIndicationMsg["faultInfo5"] = "0x00000000"
        faultIndicationMsg["faultInfo6"] = "0x00000000"
        faultIndicationMsg["faultInfo7"] = "0x00000000"
        faultIndicationMsg["faultInfo8"] = "0x00000000"
        faultIndicationMsg["faultInfo9"] = "0x00000000"
        faultIndicationMsg["faultInfo10"] = "0x00000000"
        faultIndicationMsg["faultInfo11"] = "0x00000000"
        return FAULT_INDICATION_MSG, faultIndicationMsg

    def __generateLomFaultIndMessage0x2414(self, board, cpu, faultId, faultState):
        senderTask = self.__returnSenderTaskFromTargetPort(self.__targetPort)
        LOM_FAULT_IND_MSG = [
            "headerMsgId",
            "headerReceiver",
            "headerSender",
            "headerLenght",
            "headerFlags",
            "faultId",
            "faultState",
            "faultSeverity",
            "faultLocationType",
            "faultLocation",
            "extraFaultInfo0",
            "extraFaultInfo1",
            "extraFaultInfo2",
            "extraFaultInfo3",
            "extraFaultInfo4",
            "extraFaultInfo5",
            "extraFaultInfo6",
            "extraFaultInfo7",
            "extraFaultInfo8",
            "extraFaultInfo9",
            "extraFaultInfo10",
            "extraFaultInfo11",
        ]
        lomFaultIndMsg = {}
        lomFaultIndMsg["headerMsgId"] = "0x00002414"
        lomFaultIndMsg["headerReceiver"] = "0x10110009"
        lomFaultIndMsg["headerSender"] = "0x1011" + senderTask
        lomFaultIndMsg["headerLenght"] = "0x0054"
        lomFaultIndMsg["headerFlags"] = "0x0000"
        lomFaultIndMsg["faultId"] = "0x%.8x" % faultId
        lomFaultIndMsg["faultState"] = "0x%.8x" % faultState
        lomFaultIndMsg["faultSeverity"] = "0x00000001"
        lomFaultIndMsg["faultLocationType"] = "0x00000001"
        lomFaultIndMsg["faultLocation"] = "0x" + board[2:4] + cpu[2:4] + "04C1"
        lomFaultIndMsg["extraFaultInfo0"] = "0x00000000"
        lomFaultIndMsg["extraFaultInfo1"] = "0x00000000"
        lomFaultIndMsg["extraFaultInfo2"] = "0x00000000"
        lomFaultIndMsg["extraFaultInfo3"] = "0x00000000"
        lomFaultIndMsg["extraFaultInfo4"] = "0x00000000"
        lomFaultIndMsg["extraFaultInfo5"] = "0x00000000"
        lomFaultIndMsg["extraFaultInfo6"] = "0x00000000"
        lomFaultIndMsg["extraFaultInfo7"] = "0x00000000"
        lomFaultIndMsg["extraFaultInfo8"] = "0x00000000"
        lomFaultIndMsg["extraFaultInfo9"] = "0x00000000"
        lomFaultIndMsg["extraFaultInfo10"] = "0x00000000"
        lomFaultIndMsg["extraFaultInfo11"] = "0x00000000"
        return LOM_FAULT_IND_MSG, lomFaultIndMsg

    def __generateFaultIndMessage0x8008(self, board, cpu, faultId, faultState):
        senderTask = self.__returnSenderTaskFromTargetPort(self.__targetPort)
        FAULT_IND_MSG = [
            "headerMsgId",
            "headerReceiver",
            "headerSender",
            "headerLenght",
            "headerFlags",
            "faultId",
            "faultState",
            "faultSource",
            "faultInfo0",
            "faultInfo1",
            "faultInfo2",
            "faultInfo3",
            "faultInfo4",
            "faultInfo5",
            "faultInfo6",
            "faultInfo7",
            "faultInfo8",
            "faultInfo9",
            "faultInfo10",
            "faultInfo11",
        ]
        faultIndMsg = {}
        faultIndMsg["headerMsgId"] = "0x00008008"
        faultIndMsg["headerReceiver"] = "0x10110009"
        faultIndMsg["headerSender"] = "0x1011" + senderTask
        faultIndMsg["headerLenght"] = "0x004c"
        faultIndMsg["headerFlags"] = "0x0000"
        faultIndMsg["faultId"] = "0x%.8x" % faultId
        faultIndMsg["faultState"] = "0x%.8x" % faultState
        faultIndMsg["faultSource"] = "0x" + board[2:4] + cpu[2:4] + "04C1"
        faultIndMsg["faultInfo0"] = "0x00000000"
        faultIndMsg["faultInfo1"] = "0x00000000"
        faultIndMsg["faultInfo2"] = "0x00000000"
        faultIndMsg["faultInfo3"] = "0x00000000"
        faultIndMsg["faultInfo4"] = "0x00000000"
        faultIndMsg["faultInfo5"] = "0x00000000"
        faultIndMsg["faultInfo6"] = "0x00000000"
        faultIndMsg["faultInfo7"] = "0x00000000"
        faultIndMsg["faultInfo8"] = "0x00000000"
        faultIndMsg["faultInfo9"] = "0x00000000"
        faultIndMsg["faultInfo10"] = "0x00000000"
        faultIndMsg["faultInfo11"] = "0x00000000"
        return FAULT_IND_MSG, faultIndMsg

    def __generateApiAlarmMessage0x2b84(self, board, cpu, faultId):
        senderTask = self.__returnSenderTaskFromTargetPort(self.__targetPort)
        API_ALARM_MSG = [
            "headerMsgId",
            "headerReceiver",
            "headerSender",
            "headerLenght",
            "headerFlags",
            "faultId",
            "faultUnit",
            "faultDataLenBytes",
            "faultData0",
            "faultData1",
        ]
        apiAlarmMsg = {}
        apiAlarmMsg["headerMsgId"] = "0x00002b84"
        apiAlarmMsg["headerReceiver"] = "0x10110009"
        apiAlarmMsg["headerSender"] = "0x1011" + senderTask
        apiAlarmMsg["headerLenght"] = "0x0024"
        apiAlarmMsg["headerFlags"] = "0x0000"
        apiAlarmMsg["faultId"] = "0x%.8x" % faultId
        apiAlarmMsg["faultUnit"] = "0x" + board[2:4] + cpu[2:4] + "04C1"
        apiAlarmMsg["faultDataLenBytes"] = "0x00000008"
        apiAlarmMsg["faultData0"] = "0x00000000"
        apiAlarmMsg["faultData1"] = "0x00000000"
        return API_ALARM_MSG, apiAlarmMsg

    def __generateFaultReqMessage0x802a(self, board, cpu, faultId, faultState):
        senderTask = self.__returnSenderTaskFromTargetPort(self.__targetPort)
        FAULT_REQ_MSG = [
            "headerMsgId",
            "headerReceiver",
            "headerSender",
            "headerLenght",
            "headerFlags",
            "faultId",
            "faultUnit",
            "faultSubUnit",
            "faultCpid",
            "faultState",
            "faultSeverity",
            "objectType",
            "detectingUnit",
            "detectingSubUnit",
            "faultInfo0",
            "faultInfo1",
            "faultInfo2",
            "faultInfo3",
            "faultInfo4",
            "faultInfo5",
            "faultInfo6",
            "faultInfo7",
            "faultInfo8",
            "faultInfo9",
            "faultInfo10",
            "faultInfo11",
        ]
        faultReqMsg = {}
        faultReqMsg["headerMsgId"] = "0x0000802a"
        faultReqMsg[
            "headerReceiver"
        ] = "0x10110046"  # MOAM task 0x0009, SysAdapter 0x0046
        faultReqMsg["headerSender"] = "0x1011" + senderTask
        faultReqMsg["headerLenght"] = "0x0064"
        faultReqMsg["headerFlags"] = "0x0000"
        faultReqMsg["faultId"] = "0x%.8x" % faultId
        faultReqMsg["faultUnit"] = "0x%.8x" % eval(board)
        faultReqMsg["faultSubUnit"] = "0x%.8x" % eval(cpu)
        faultReqMsg["faultCpid"] = "0x00000000"
        faultReqMsg["faultState"] = "0x%.8x" % faultState
        faultReqMsg["faultSeverity"] = "0x00000001"
        faultReqMsg["objectType"] = "0x00000000"
        faultReqMsg["detectingUnit"] = "0x%.8x" % eval(board)
        faultReqMsg["detectingSubUnit"] = "0x%.8x" % eval(cpu)
        faultReqMsg["faultInfo0"] = "0x00000000"
        faultReqMsg["faultInfo1"] = "0x00000000"
        faultReqMsg["faultInfo2"] = "0x00000000"
        faultReqMsg["faultInfo3"] = "0x00000000"
        faultReqMsg["faultInfo4"] = "0x00000000"
        faultReqMsg["faultInfo5"] = "0x00000000"
        faultReqMsg["faultInfo6"] = "0x00000000"
        faultReqMsg["faultInfo7"] = "0x00000000"
        faultReqMsg["faultInfo8"] = "0x00000000"
        faultReqMsg["faultInfo9"] = "0x00000000"
        faultReqMsg["faultInfo10"] = "0x00000000"
        faultReqMsg["faultInfo11"] = "0x00000000"
        return FAULT_REQ_MSG, faultReqMsg

    def __generateMemoryDumpRegisterIndMessage(
        self, board, cpu, dumpStartAddress, dumpLenght
    ):
        MEMORY_DUMP_REGISTER_IND_MSG = [
            "headerMsgId",
            "headerReceiver",
            "headerSender",
            "headerLenght",
            "headerFlags",
            "transactionId",
            "board",
            "cpu",
            "startAddress",
            "length",
        ]
        memoryDumpRegisterInd = {}
        memoryDumpRegisterInd["headerMsgId"] = "0x00008107"
        memoryDumpRegisterInd["headerReceiver"] = "0x10110001"
        memoryDumpRegisterInd["headerSender"] = "0x12320240"
        memoryDumpRegisterInd["headerLenght"] = "0x0024"
        memoryDumpRegisterInd["headerFlags"] = "0x0000"
        memoryDumpRegisterInd["transactionId"] = "0x00000000"
        memoryDumpRegisterInd["board"] = "0x000000" + board[2:]
        memoryDumpRegisterInd["cpu"] = "0x000000" + cpu[2:]
        memoryDumpRegisterInd["startAddress"] = dumpStartAddress
        memoryDumpRegisterInd["length"] = dumpLenght
        return MEMORY_DUMP_REGISTER_IND_MSG, memoryDumpRegisterInd


def validateArgsOK(args1):
    argsOK = True
    if len(args1.board) != 4:
        argsOK = False
        print("ERROR: Invalid size of argument board. eg. Use syntax -b 0x12")
    if (
        args1.cpuFSMr2
        and len(args1.cpuFSMr2) != 4
        or args1.cpuFSMr3
        and len(args1.cpuFSMr3) != 4
    ):
        argsOK = False
        print("ERROR: Invalid size of argument cpu. eg. Use syntax -c 0x33 or -n 0x44")
    if args1.registerDumpArea:
        if len(args1.registerDumpArea[0]) != 10 or len(args1.registerDumpArea[1]) != 10:
            print(
                "ERROR: Invalid size of argument registerDumpArea."
                "\n eg. Use syntax -d 0x12345678 0x00001234"
            )
            argsOK = False
        if args1.cpuFSMr2:
            print(
                "ERROR: Registering memdump area is supported only in FSMr3."
                "\n In FSMr2 edit memorydumps.ini file in ROM"
            )
            argsOK = False
    if args1.writeDspData:
        if len(args1.writeDspData[0]) != 10 or len(args1.writeDspData[1]) != 10:
            print(
                "ERROR: Invalid size of argument writeDspData."
                "\n eg. Use syntax -w 0x12345678 0x00005678"
            )
            argsOK = False
    if not argsOK:
        print("Give argument -h for help")
    return argsOK


def determineDspTypeFromArgs(cpuFSMr2, cpuFSMr3, cpuFSMr4):
    if cpuFSMr2:
        return "faraday", cpuFSMr2
    elif cpuFSMr3:
        return "nyquist", cpuFSMr3
    else:
        return "kepler", cpuFSMr4


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-i",
        "--ipAddress",
        help="Target IP Address (default: 192.168.255.129)",
        default="192.168.255.129",
    )
    parser.add_argument(
        "-p",
        "--port",
        help="Target Port (default: 15003)",
        type=int,
        default=15003,
        choices=list(range(15001, 15006)),
    )
    parser.add_argument("-b", "--board", help="BoardId (Eg. 0x12)", required=True)
    groupHw = parser.add_mutually_exclusive_group(required=True)
    groupHw.add_argument("-c", "--cpuFSMr2", help="FSMr2 cpuId (Eg. 0x42)")
    groupHw.add_argument("-n", "--cpuFSMr3", help="FSMr3 cpuId (Eg. 0x42)")
    groupHw.add_argument("-k", "--cpuFSMr4", help="FSMr4 cpuId (Eg. 0x3d)")
    groupAction = parser.add_mutually_exclusive_group(required=True)
    groupAction.add_argument(
        "-e", "--exception", help="Generate exception to DSP", action="store_true"
    )
    groupAction.add_argument(
        "-s",
        "--silentCrashType",
        help=(
            "Generate silent crash to DSP."
            " 0=GPIO disabled, 1=GPIO enabled,"
            " 2=Disable DSP RXU GPIO disable, 3=Disable DSP RXU GPIO Enable,"
            " 4=Disable DSP TXU GPIO disable, 5=Disable DSP TXU GPIO Enable,"
            " 6=Pause DSP Rx GPIO disable, 7=Pause DSP Rx GPIO Enable"
        ),
        type=int,
        choices=list(range(0, 8)),
    )
    groupAction.add_argument(
        "-r",
        "--resetType",
        help="Generate DSP reset (API_RESET_REQ/RESP), 1=Warm, 2=Crash",
        type=int,
        choices=list(range(0, 3)),
    )
    groupAction.add_argument(
        "--apiReset",
        help="Send API_RESET_REQ with given state and extra (eg. --apiReset 1 1) to given -b board and -c/-n cpu",
        nargs=2,
        type=int,
        choices=list(range(0, 3)),
    )
    groupAction.add_argument(
        "-f",
        "--fault0x3400",
        help="Send FAULT_INDICATION_MSG 0x3400 with given faultId, (not supported anymore with new OAM)",
        type=int,
    )
    groupAction.add_argument(
        "-a",
        "--fault0x2b84",
        help="Send API_ALARM_MSG 0x2b84 with given faultId",
        type=int,
    )
    groupAction.add_argument(
        "-u",
        "--fault0x8008",
        help="Send FAULT_IND_MSG 0x8008 with given faultId",
        type=int,
    )
    groupAction.add_argument(
        "-l",
        "--fault0x2414",
        help="Send LOM_FAULT_IND_MSG 0x2414 with given faultId",
        type=int,
    )
    groupAction.add_argument(
        "-t",
        "--fault0x802a",
        help="Send FAULT_REQ_MSG 0x802a with given faultId",
        type=int,
    )
    groupAction.add_argument(
        "-d",
        "--registerDumpArea",
        help=(
            "FSMr3 only, register new memdump area."
            " StartAddress and lenght as argument, -d [startAddress] [lenght]. eg. -d 0x10800000 0x00001000"
        ),
        nargs=2,
    )
    groupAction.add_argument(
        "-w",
        "--writeDspData",
        help=(
            "WARNING this is experimental way to write data to DSP using BROWSER_DSP_MEMORY_REQ msg."
            "Address and data given as argument, -w [address] [data]. eg. -w 0x10800000 0x12345678"
        ),
        nargs=2,
    )
    parser.add_argument(
        "--state",
        help="Set FaultState, 0=Cancel, 1=Start, 2=Event. (default: 1)",
        type=int,
        choices=list(range(0, 3)),
        default=1,
    )
    parser.add_argument("--enableRnDPort", help="Enables RnD port", action="store_true")
    parser.add_argument(
        "--enableRnDPortAddress",
        help="Address which is used for enabling Rnd port. (default: 192.168.255.129)",
        default="192.168.255.129",
    )
    parser.add_argument(
        "--debug", help="Enables additional debug printing", action="store_true"
    )
    args = parser.parse_args()

    if not validateArgsOK(args):
        sys.exit(-1)
    dspType, targetCpu = determineDspTypeFromArgs(
        args.cpuFSMr2, args.cpuFSMr3, args.cpuFSMr4
    )
    dspCrash = CDspCrash(args.ipAddress, args.port, args.debug)
    if args.enableRnDPort:
        dspCrash.enableRnDPort(args.enableRnDPortAddress)
    if dspCrash.openConnection():
        if args.exception:
            dspCrash.generateExceptionToDsp(dspType, args.board, targetCpu)
        elif args.silentCrashType is not None:
            dspCrash.generateSilentCrashToDsp(
                dspType, args.board, targetCpu, args.silentCrashType
            )
        elif args.resetType is not None:
            dspCrash.generateDspReset(dspType, args.board, targetCpu, args.resetType)
        elif args.apiReset is not None:
            dspCrash.sendApiResetMsg(dspType, args.board, targetCpu, args.apiReset)
        elif args.fault0x3400 is not None:
            dspCrash.sendFaultIndicationMessageToBts(
                args.board, targetCpu, args.fault0x3400, "0x3400", args.state
            )
        elif args.fault0x2414 is not None:
            dspCrash.sendFaultIndicationMessageToBts(
                args.board, targetCpu, args.fault0x2414, "0x2414", args.state
            )
        elif args.fault0x8008 is not None:
            dspCrash.sendFaultIndicationMessageToBts(
                args.board, targetCpu, args.fault0x8008, "0x8008", args.state
            )
        elif args.fault0x2b84 is not None:
            dspCrash.sendFaultIndicationMessageToBts(
                args.board, targetCpu, args.fault0x2b84, "0x2b84", args.state
            )
        elif args.fault0x802a is not None:
            dspCrash.sendFaultIndicationMessageToBts(
                args.board, targetCpu, args.fault0x802a, "0x802a", args.state
            )
        elif args.registerDumpArea is not None:
            dspCrash.registerNewMemdumpArea(
                args.board,
                targetCpu,
                args.registerDumpArea[0],
                args.registerDumpArea[1],
            )
        elif args.writeDspData:
            dspCrash.writeDataToDsp(
                args.board, targetCpu, args.writeDspData[0], args.writeDspData[1]
            )
        dspCrash.closeConnection()
    sys.exit()
