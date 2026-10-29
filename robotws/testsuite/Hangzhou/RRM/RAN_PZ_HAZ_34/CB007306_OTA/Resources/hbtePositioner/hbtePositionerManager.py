from rotateControl import RotateControl
from hbtePositioner1_3 import HBTEPositioner
from positionerBase import HbteException
import time

X = 0x01     # 代表轴号，需要对应，轴1
Y = 0x02     # 代表轴号，轴2
Z = 0x03
T = 0x04
AllAxis = 0xFF


class PositionerManager(object):
    def __init__(self, ip, port=5000):
        self._map = {}
        self._map["HBTE-SCPI"] = HBTEPositioner
        self._positioner = None

        for key in self._map.keys():
            try:
                self._positioner = self._map[key](ip, port)
                self.queryXPosition()
                break
            except HbteException as e:
                self._positioner = None
                print("{0}: {1}".format(key, e.error))
        if self._positioner is None:
            raise HbteException("No available positioner class was found, or socket connection failed.")

    def setXPosition(self, position=20.1, speed=5.0):
        return self._positioner.setAxisPosition(X, float(position), float(speed))

    def setYPosition(self, position=20.1, speed=5.0):
        return self._positioner.setAxisPosition(Y, float(position), float(speed))

    def setZPosition(self, position=20.1, speed=5.0):
        return self._positioner.setAxisPosition(Z, float(position), float(speed))

    def setTPosition(self, position=20.1, speed=5.0):
        return self._positioner.setAxisPosition(T, float(position), float(speed))

    def reset(self):
        return self._positioner.resetAxis(AllAxis)

    def stopXPosition(self):
        return self._positioner.stopAxis(X)

    def stopYPosition(self):
        return self._positioner.stopAxis(Y)

    def stopZPosition(self):
        return self._positioner.stopAxis(Z)

    def stopTPosition(self):
        return self._positioner.stopAxis(T)

    def queryXPosition(self):
        tmp = self._positioner.queryAxisPosition()
        return float(tmp[X])

    def queryYPosition(self):
        tmp = self._positioner.queryAxisPosition()
        return float(tmp[Y])

    def queryZPosition(self):
        tmp = self._positioner.queryAxisPosition()
        return float(tmp[Z])

    def queryTPosition(self):
        tmp = self._positioner.queryAxisPosition()
        return float(tmp[T])
