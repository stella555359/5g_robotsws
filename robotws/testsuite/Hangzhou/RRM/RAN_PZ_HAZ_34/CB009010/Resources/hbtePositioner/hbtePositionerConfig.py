import socket
import time
from positionerBase import PositionerBase, HbteException

# 定义读取的错误次数
readTimes = 3


class HbtePositionerConst():
    def __init__(self, version):
        self._version = version
        if version >= "1_3":
            self.__instruction_1_3()
        else:
            self.__instruction_1_2()

    def __instruction_1_2(self):
        self.QUERY_IDN = "*IDN"
        self.QUERY_VERSION = "SYSTEM:VERSION"
        self.QUERY_IP = "QUERY:IP"
        self.REBOOT = "REBOOT"
        self.SET_IP = "SET:IP:"
        self.QUERY_CONFIG = ""
        self.SET_POSITION = "SET:AXIS:"
        self.QUERY_POSITION = "QUERY:POSITION"
        self.RESET = "RESET:AXIS:"
        self.QUERY_STATE = "QUERY:STATE"
        self.STOP = "STOP:AXIS:"
        self.SET_ORIGIN = "$TA,C,"
        self.QUERY_ORIGIN = "$TA,C"
        self.HELP = "HELP"
        self.SEPARATOR = " "
        self.DELIMITER = ","

    def __instruction_1_3(self):
        self.QUERY_IDN = "*IDN"
        self.QUERY_VERSION = "SYSTEM:VERSION"
        self.QUERY_IP = "QUERY:IP"
        self.REBOOT = "REBOOT"
        self.SET_IP = "SET:IP:"
        self.QUERY_CONFIG = "QUERY:CONFIG"
        self.SET_POSITION = "SET:ABSOLUTE:POSITION:"
        self.QUERY_POSITION = "QUERY:ABSOLUTE:POSITION"
        self.RESET = "RESET:AXIS:"
        self.QUERY_STATE = "QUERY:STATE"
        self.STOP = "STOP:AXIS:"
        self.SET_ORIGIN = "SET:RELATIVE:ORIGIN:AXIS:"
        self.QUERY_ORIGIN = "QUERY:RELATIVE:ORIGIN:AXIS"
        self.HELP = "HELP"
        self.SEPARATOR = ","
        self.DELIMITER = ";"
