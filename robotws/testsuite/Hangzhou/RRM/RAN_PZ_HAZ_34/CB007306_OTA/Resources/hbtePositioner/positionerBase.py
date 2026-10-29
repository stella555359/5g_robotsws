import socket
import time


class HbteException(Exception):
    def __init__(self, args):
        self.error = args


class PositionerBase(object):
    def __init__(self, ip, port, serialNum):
        self._ip = ip
        self._port = port
        self._serialNum = serialNum
        self._clientSocket = None

    def __openDevice(self):
        raise NotImplementedError

    def setAxisPosition(self, axisId, position, speed):
        raise NotImplementedError

    def queryAxisPosition(self):
        raise NotImplementedError

    def resetAxis(self, axisId=0xFF):
        raise NotImplementedError

    def stopAxis(self, axisId):
        raise NotImplementedError

    def close(self):
        raise NotImplementedError
