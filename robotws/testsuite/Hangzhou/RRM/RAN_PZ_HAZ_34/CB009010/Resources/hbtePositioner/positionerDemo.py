from hbtePositionerManager import PositionerManager
from hbtePositionerManager import HbteException
import time


def setXPositionMotion(ip, start=0.0, end=180.0, speed=2.0, loopCount=1, exceed=180):
    positioner = PositionerManager(ip)
    start = float(start)
    end = float(end)
    speed = float(speed)
    start, end = min(exceed, start), min(exceed, end)
    for i in range(loopCount):
        print("loop count: ", i)
        positioner.setXPosition(start, speed=speed)
        pos = positioner.queryXPosition()
        print("current pos:", pos)
        while (pos-start) > 0.05 or (pos-start) < -0.05:
            time.sleep(1)
            pos = positioner.queryXPosition()
            print("pos: ", pos)
        positioner.setXPosition(end, speed=speed)
        while (pos-end) > 0.05 or (pos-end) < -0.05:
            time.sleep(1)
            pos = positioner.queryXPosition()
            print("change to: ", pos)


def setYPositionMotion(ip, start=0.0, end=180.0, speed=2.0, loopCount=1, exceed=180):
    positioner = PositionerManager(ip)
    start, end = min(exceed, start), min(exceed, end)
    for i in range(loopCount):
        print("loop count: ", i)
        positioner.setYPosition(start, speed=speed)
        pos = positioner.queryYPosition()
        print("current pos:", pos)
        while (pos-start) > 0.05 or (pos-start) < -0.05:
            time.sleep(1)
            pos = positioner.queryYPosition()
            print("pos: ", pos)
        positioner.setYPosition(end, speed=speed)
        while (pos-end) > 0.05 or (pos-end) < -0.05:
            time.sleep(1)
            pos = positioner.queryYPosition()
            print("change to: ", pos)


def setCurtainPositionMotion(positioner1, positioner2, start=0.0, end=180.0, speed=2.0, loopCount=1):
    start, end = min(800, start), min(800, end)    # start and end can't exceed 800
    for i in range(loopCount):
        print("loop count: ", i)
        positioner1.setXPosition(start, speed=speed)
        positioner2.setXPosition(start, speed=speed)
        pos1 = positioner1.queryXPosition()
        pos2 = positioner2.queryXPosition()
        print("current pos1={},pos2={}".format(pos1, pos2))
        while ((pos1-start) > 0.05 or (pos1-start) < -0.05) and ((pos2-start) > 0.05 or (pos2-start) < -0.05):
            time.sleep(1)
            pos1 = positioner1.queryXPosition()
            pos2 = positioner2.queryXPosition()
            print("back to: pos1={},pos2={}".format(pos1, pos2))
        positioner1.setXPosition(end, speed=speed)
        positioner2.setXPosition(end, speed=speed)
        while ((pos1-end) > 0.05 or (pos1-end) < -0.05) and ((pos2-end) > 0.05 or (pos2-end) < -0.05):
            time.sleep(1)
            pos1 = positioner1.queryXPosition()
            pos2 = positioner2.queryXPosition()
            print("change to: pos1={},pos2={}".format(pos1, pos2))
