import socket
import time
from positionerBase import PositionerBase, HbteException
from hbtePositionerConfig import HbtePositionerConst

readTimes = 3


class HBTEPositioner(PositionerBase):
    def __init__(self, ip, port=5000, version="1_3"):
        self._ip = ip
        self._port = port
        self._clientSocket = None
        self.hbteConst = HbtePositionerConst(self.__querySystemVersion())
        self._axisMaxNums = len(self.queryAxisPosition())

    def __openDevice(self):
        clientSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        clientSocket.settimeout(2)
        time.sleep(0.05)
        clientSocket.connect((self._ip, self._port))
        return clientSocket

    def __sendData(self, data):
        try:
            self._clientSocket = self.__openDevice()
            self._clientSocket.sendall(data.encode("utf8"))
            time.sleep(0.2)
            recvData = self._clientSocket.recv(1024).decode()
            errCount = 0
            while not recvData.endswith("\r\n"):
                recvData += self._clientSocket.recv(1024).decode()
                errCount += 1
                if errCount >= readTimes:
                    raise Exception("read more than the maximum number of times.")
            if "HELP" not in data and "SYSTEM:ERR" in recvData:
                raise HbteException("Sending instruction error, error code: {0}.".format(recvData[13:-2]))
            return recvData[:-2]
        except socket.error as e:
            print("__send data error: {0}".format(e))
            raise HbteException("__send data error: {0}".format(e))
            return None
        finally:
            if self._clientSocket is not None:
                self._clientSocket.close()

    def __querySystemVersion(self):
        recvData = self.__sendData("SYSTEM:VERSION?\r\n")
        version = recvData[recvData.index("SYSTEM:VERSION:") + len("SYSTEM:VERSION:"):]
        major = version.split(".")[0]
        subversion = int(version.split(".")[1])
        if major > "V1" or (major == "V1" and subversion >= 7):
            return "1_3"
        else:
            return "1_2"

    def setAxisPosition(self, axisId=0x01, position=20.05, speed=20.5):
        if (axisId > self._axisMaxNums):
            raise HbteException("The axis ID exceeds the maximum value of the positioner.")
        tmp = "{0}{1},{2},{3}".format(self.hbteConst.SET_POSITION, str(axisId),
                                      "{:.2f}".format(position), "{:.2f}".format(speed))
        tmp = tmp.replace(",", self.hbteConst.SEPARATOR)
        recvData = self.__sendData("{0}\r\n".format(tmp))
        tmpMap = self.__handleRecvData(recvData, self.hbteConst.SET_POSITION)
        for key in tmpMap.keys():
            if tmpMap[key] != "OK":
                raise HbteException("set {0} axis failed.".format(tmpMap[key]))
        return True

    def __handleRecvData(self, recvData="", cmd=""):
        cmd = cmd if cmd.endswith(":") else cmd + ":"
        index = recvData.index(cmd) + len(cmd)
        recvData = recvData[index:]
        tmps = [x.split(self.hbteConst.SEPARATOR) for x in recvData.split(self.hbteConst.DELIMITER)]
        return {int(x[0]): x[1] for x in tmps}

    def resetAxis(self, axisId=0xFF):
        axisList = list()
        if axisId == 0xFF:
            for i in range(self._axisMaxNums):
                axisList.append(str(i + 1))
        else:
            if (axisId > self._nums):
                raise HbteException("The axis ID exceeds the maximum value of the turntable")
            axisList.append(str(axisId))
        recvData = self.__sendData("{0}{1}\r\n".format(self.hbteConst.RESET, self.hbteConst.DELIMITER.join(axisList)))
        axisStates = self.__handleRecvData(recvData, self.hbteConst.RESET)
        for key in axisStates:
            if axisStates[key] != "OK":
                raise HbteException("reset {0} axis failed.".format(axisStates[key]))
        while True:
            axisStates = self.queryAxisState()
            time.sleep(1)
            flag = 1
            for axisId in axisList:
                if int(axisId) in axisStates.keys() and axisStates[int(axisId)] == "1":
                    flag = 0
            if flag == 1:
                break
        return True

    def stopAxis(self, axisId):
        if (axisId > self._axisMaxNums):
            raise HbteException("The axis ID exceeds the maximum value of the positioner.")
        recvData = self.__sendData("{0}{1}\r\n".format(self.hbteConst.STOP, axisId))
        tmps = self.__handleRecvData(recvData, self.hbteConst.STOP)
        if axisId in tmps.keys():
            if tmps[axisId] != "OK":
                raise HbteException("stop {0} axis failed.".format(axisId))
        return True

    def queryAxisState(self):
        recvData = self.__sendData("{0}?\r\n".format(self.hbteConst.QUERY_STATE))
        return self.__handleRecvData(recvData, self.hbteConst.QUERY_STATE)

    def queryAxisPosition(self):
        recvData = self.__sendData("{0}?\r\n".format(self.hbteConst.QUERY_POSITION))
        return self.__handleRecvData(recvData, self.hbteConst.QUERY_POSITION)

    def getHelp(self):
        recvData = self.__sendData("{0}\r\n".format(self.hbteConst.HELP))
        print(recvData)

    def getIDN(self):
        recvData = self.__sendData("{0}?\r\n".format(self.hbteConst.QUERY_IDN))
        return recvData[recvData.index("IDN:") + len("IDN:"):]

    def getVersion(self):
        recvData = self.__sendData("{0}?\r\n".format(self.hbteConst.QUERY_VERSION))
        return recvData[recvData.index(self.hbteConst.QUERY_VERSION + ":") + len(self.hbteConst.QUERY_VERSION):]

    def getIP(self):
        recvData = self.__sendData("{0}?\r\n".format(self.hbteConst.QUERY_IP))
        recvData = recvData[recvData.index(self.hbteConst.QUERY_IP + ":") + len(self.hbteConst.QUERY_IP + ":"):]
        return recvData.split("-")

    def changeIP(self, addr, mask, gw):
        recvData = self.__sendData("{0}{1}-{2}-{3}\r\n".format(self.hbteConst.SET_IP,
                                                               addr.strip(), mask.strip(), gw.strip()))
        if "OK".encode("utf8") not in recvData:
            raise HbteException("change ip failed.")
        return True

    def setAxisOffset(self, axisId=0x01, offset=20.05):
        if self.hbteConst._version >= "1_3":
            recvData = self.__sendData("{0}{1}\r\n".format(self.hbteConst.SET_ORIGIN, str(axisId)))
            tmps = self.__handleRecvData(recvData, self.hbteConst.SET_ORIGIN)
            if axisId in tmps.keys():
                if tmps[axisId] != "OK":
                    raise HbteException("set {0} axis offset failed.".format(axisId))
            return True
        else:
            tmp = "_{0}".format("{:.2f}".format(-offset)) if offset < 0 else "{:.2f}".format(offset)
            recvData = self.__sendData("$TA,C,{0}-{1}*\r\n".format(str(axisId).zfill(2), tmp))
            if "$TA,C" not in recvData:
                raise HbteException("Failed to set offset for {0}-axis".format(axisId))
            return True

    def queryAxisOffset(self):
        if self.hbteConst._version >= "1_3":
            recvData = self.__sendData("{0}?\r\n".format(self.hbteConst.QUERY_ORIGIN))
            return self.__handleRecvData(recvData, self.hbteConst.QUERY_ORIGIN)
        else:
            recvData = self.__sendData("$TA,C*\r\n")
            if "$TA,C" not in recvData:
                raise HbteException("Failed to query offset for axis")
            recvData = recvData[6:len(recvData) - 1]
            tmp = recvData.split("-")
            offset = int(tmp[1].replace("_", "-"))
            print("query axis offset: {0}-{1}.".format(tmp[0], offset))
