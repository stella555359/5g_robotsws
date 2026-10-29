import rotateHolder
from positionerBase import PositionerBase


class RotateControl(PositionerBase):
    def __init__(self, ip="192.168.1.254", port=5000):
        self.holder = rotateHolder.RotateHolder(ip, port)
        PositionerBase.__init__(self, ip=ip, port=port, serialNum=None)

    def setIP(self, ip, port=5000):
        self.holder.ip = ip
        self.holder.port = port

    def setAxisPosition(self, axisId, position, speed):
        if axisId - 1 == 0x02:
            position = float(position) * 2
        self.holder.manualControl(subCmd=0x04, axisid=(axisId-1), spdDir=0x00, dummy=0x00,
                                  posCmd=-float(position), velCmd=float(speed), accCmd=0.0)

    def queryAxisPosition(self):
        recvData = self.holder.searchAxisPosition()
        positions = {}
        for i in range(1, len(recvData)):
            positions[i] = -recvData[i]
        return positions

    def stopAxis(self, axisId):
        PositionerBase.stopAxis(self, axisId)

    def resetAxis(self, axisId=0xFF):
        self.holder.resetAxis(subCmd=0xA1, axisid=axisId)
