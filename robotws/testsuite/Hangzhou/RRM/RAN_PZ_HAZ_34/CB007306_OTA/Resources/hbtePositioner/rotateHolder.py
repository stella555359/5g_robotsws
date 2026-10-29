import socket
import struct
import time
from positionerBase import HbteException


class RotateHolder:
    def __init__(self, ip="127.0.0.1", port=5000):
        self.ip = ip
        self.port = port
        self.com_header = 0xAA
        self.com_len = 0x00
        self.com_cardId = 0x00
        self.com_check = 0x00
        self.dt_checkSum = 0x00
        self.dt_cmdType = 0x00
        self.dt_len = 0x00
        self.dt_cmdNo = 0x00
        self.__recvData = ""

    def __connectToHost(self, ip, port):
        clientSocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        clientSocket.settimeout(2)
        time.sleep(0.05)
        clientSocket.connect((ip, port))
        return clientSocket

    def searchAxisPosition(self, axisd=0xFF, paraidx=0x80):
        self.__setBaseParameter(0x06, 0xF6, [axisd, paraidx])
        self.__sendData([axisd, paraidx])
        data = self.__handlerRecvData(self.__recvData)
        if data is None:
            return self.searchAxisPostion(axisd, paraidx)
        return data

    def searchAxisStatus(self, axisd=0xFF, paraidx=0x0B):
        self.__setBaseParameter(0x06, 0xF6, [axisd, paraidx])
        self.__sendData([axisd, paraidx])
        data = self.__handlerRecvData(self.__recvData)
        if data is None:
            return self.searchAxisStatus(axisd, paraidx)
        return data
        if data is None:
            print("search axis status failed: data is none.")
        return None
        cmd, subCmd, length, err, xStatus, check = struct.unpack("BBBBiB", data)
        return [err, xStatus]

# Sets the parameters of the axis.
    def setAxisParamete(self, axisd=0x00, paraIndex=0x00, paramete=150.6):
        self.__setBaseParameter(0x0a, 0xF2, [axisd, paraIndex, paramete])
        self.__sendData([axisd, paraIndex, float(paramete)])

# Read the parameters of the axis
    def readAxisParamete(self, axisd=0x00, paraIndex=0x00):
        self.__setBaseParameter(0x06, 0xF5, [axisd, paraIndex])
        self.__sendData([axisd, paraIndex])

# Manual control
    def manualControl(self, subCmd=0x00, axisid=0x00, spdDir=0x01,
                      dummy=0x00, posCmd=0.0, velCmd=0.0, accCmd=0.0):
        self.__setBaseParameter(0x14, 0xF4, [subCmd, axisid, spdDir, dummy, posCmd, velCmd, accCmd])
        self.__sendData([subCmd, axisid, spdDir, dummy, float(posCmd), float(velCmd), float(accCmd)])
        data = self.__handlerRecvData(self.__recvData)
        if data is None:
            self.manualControl(subCmd, axisid, spdDir, dummy, posCmd, velCmd, accCmd)

# reset axis:
    def resetAxis(self, subCmd=0xA1, axisid=0xFF):
        self.manualControl(subCmd, axisid)
        data = self.searchAxisStatus()
        while data[1] & 0x01:
            data = self.searchAxisStatus()
        self.clearAxis()

# Clears the axis's coordinate position and goes to zero；
    def clearAxis(self, subCmd=0x01, axisId=0xFF, dummy=0x00, posCmd=0.0):
        self.__setBaseParameter(0x0C, 0xF8, [subCmd, axisId, struct.pack("H", dummy), float(posCmd)])
        self.__sendData([subCmd, axisId, struct.pack("H", dummy), float(posCmd)])
        self.__handlerRecvData(self.__recvData)

# Save parameters；
    def saveParameter(self):
        self.__setBaseParameter(0x04, 0xFF, [])
        self.__sendData([])

# Erase encoder values.
    def resetEncodeValue(self, axisId=0x00, dummy1=0x00, dummy2=0x00, enCoderVal=0x00):
        self.__setBaseParameter(0x0C, 0xFC, [axisId, dummy1, struct.pack("H", dummy2), struct.pack("i", enCoderVal)])
        self.__sendData([axisId, dummy1, struct.pack("H", dummy2), struct.pack("i", enCoderVal)])

# Send G control instructions
    def sendGControl(self, intrpltType=0x01, axisEn=0x00, targtPosX=12.0, targtPosY=12.0,
                     targtPosZ=12.0, targtPosT=12.0, cmdVelX=12.0, cmdVelY=12.0, cmdVelZ=12.0,
                     cmdVelT=12.0, targtAccX=12.0, targtAccY=12.0, targtAccZ=12.0,
                     targtAccT=12.0, radius=12.0, delayCmd=12.0):
        self.__setBaseParameter(0x40, 0xF3, [struct.pack("H", intrpltType), struct.pack("H", axisEn),
                                             targtPosX, targtPosY, targtPosZ, targtPosT, cmdVelX, cmdVelY,
                                             cmdVelZ, cmdVelT, targtAccX, targtAccY, targtAccZ, targtAccT,
                                             radius, delayCmd])
        self.__sendData([struct.pack("H", intrpltType), struct.pack("H", axisEn),
                         targtPosX, targtPosY, targtPosZ, targtPosT, cmdVelX, cmdVelY,
                         cmdVelZ, cmdVelT, targtAccX, targtAccY, targtAccZ, targtAccT,
                         radius, delayCmd])

# Sets the basic parameters of the shaft；
    def __setBaseParameter(self, dataLen=0x00, cmdType=0xF6, data=[]):
        self.com_len = dataLen
        self.dt_len = self.com_len
        self.com_check = (self.dt_len) % 256
        self.dt_cmdType = cmdType
        self.dt_cmdNo += 0x01
        if self.dt_cmdNo > 0xFF:
            self.dt_cmdNo = 0
        self.dt_checkSum = 0
        self.dt_checkSum += (self.dt_cmdNo + self.dt_cmdType + self.dt_len)
        for x in data:
            if isinstance(x, float):
                for y in struct.pack("f", x):
                    self.dt_checkSum += ord(y)
            elif isinstance(x, str):
                for y in x:
                    self.dt_checkSum += ord(y)
            else:
                self.dt_checkSum += x
        self.dt_checkSum %= 256

    def __sendData(self, data):
        clientSocket = None
        try:
            clientSocket = self.__connectToHost(self.ip, self.port)
            temp = struct.pack("BBBBBBBB", self.com_header, self.com_len, self.com_cardId, self.com_check,
                               self.dt_checkSum, self.dt_cmdType, self.dt_len, self.dt_cmdNo)
            for x in data:
                if isinstance(x, float):
                    temp += struct.pack("f", x)
                elif isinstance(x, str):
                    temp += x
                else:
                    temp += struct.pack("B", x)
            clientSocket.sendall(temp)
            time.sleep(1)
            self.__recvData += clientSocket.recv(64)
            return None
        except socket.error as e:
            print("__send data error: {0}".format(e))
            raise HbteException("__send data error: {0}".format(e))
            return None
        finally:
            if clientSocket is not None:
                clientSocket.close()

    def __handlerRecvData(self, data):
        if len(data) < 4:
            return None
        cmd, subCmd, length, err = struct.unpack("BBBB", data[:4])
        if err != 0x00:
            return None
        if subCmd == 0x80:
            if len(data) < 21:
                return None
            elif len(data) > 21:
                return self.__handlerRecvData(data[21:])
            else:
                xPosition, yPosition, zPosition, tPosition, check = struct.unpack("ffffB", data[4:])
                self.__recvData = ""
                return [time.strftime("%Y-%m-%d %H:%M:%S"), round(xPosition, 1), round(yPosition, 1),
                        round(zPosition / 2.0, 1), round(tPosition, 1)]
        elif subCmd == 0x0B:
            if len(data) < 9:
                return None
            elif len(data) > 9:
                return self.__handlerRecvData(data[9:])
            else:
                xStatus, check = struct.unpack("iB", data[4:])
                self.__recvData = ""
                return [err, xStatus]
        else:
            self.__recvData = ""
            return [err]
