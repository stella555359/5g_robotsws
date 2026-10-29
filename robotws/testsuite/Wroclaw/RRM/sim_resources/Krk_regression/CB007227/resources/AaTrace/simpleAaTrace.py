"""
:copyright: Nokia Networks
:author: unknown
:maintainer: Jacek Kozmic
:contact: jacek.kozmic@nokia.com

Version from year 2017
"""

import socket
import select
import sys
import os
import time as time_
import struct
import signal
import errno
from datetime import datetime

VERS = "30.6-2017 / 0.9 --> ported to L2 SCT"
USE_HEAVY_FILT = False
AA_TEST_PORT_CPID = {
    15001: 0x0308,
    15002: 0x04CF,
    15003: 0x0315,
    15004: 0x031D,
    15005: 0x030A
}
AA_TEST_PORT = 15003
SENDER_SIC_ADDR = 0x10110315
MCU_IP = "192.168.255.1"

HEAVY_FILT_COUNT = 500
MSG_ID_SET_FILTER = 0x1819

FILTER_CPID_DSP = 0x60A
FILTER_CPID_MCU = 0x309

# forever
TIME_TO_TRACE = -1

CURRENT_TIME = datetime.now()
OUTPUT_FILE = "aatrace" + str(CURRENT_TIME) + ".bin"
FILTER_NODE_ID_LIST = []
FILTER_MSG_ID_LIST = []

# 0:default 1:aggregate
USE_MSG_AGGREGATION = 1


class SIGINT_handler():
    def __init__(self):
        self.SIGINT = False

    def signal_handler(self, signal, frame):
        self.SIGINT = True


handler = SIGINT_handler()


def convertFromStr(strList):
    intList = strList
    for i in range(len(strList)):
        intList[i] = int(strList[i], 16)
    return intList


def openSocket():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 10000000)
    sock.connect((MCU_IP, AA_TEST_PORT))
    return sock


def sendTraceConf(sock, conf):
    try:
        sock.sendall(conf)
    finally:
        pass


global lastPrint, saveSum
lastPrint = 0
saveSum = 0


def saveData(data, outFile):
    global lastPrint, saveSum
    byteCount = len(data)
    saveSum += byteCount
    outFile.write(data)
    if time_.time() > lastPrint + 1:
        print("\t", time_.asctime(), "stored", saveSum)
        lastPrint = time_.time()
        saveSum = 0
    return byteCount


def savePid():
    pidFilePath = "{}/simpleAaTracePid.txt".format(os.getcwd())
    if not os.path.isfile(pidFilePath):
        pid = str(os.getpid())
        f = open(pidFilePath, "w")
        f.write(pid)
        f.close()


def waitAndDump(sock, delay, outFile):
    startTime = time_.time()

    def tracingStopped():
        return handler.SIGINT or (delay >= 0 and (time_.time() > startTime + delay))

    byteCount = 0
    inputSockets = [sock]
    outputSockets = []
    timeout = 0.10
    while not tracingStopped():
        try:
            readable, writable, exceptional = select.select(inputSockets, outputSockets, inputSockets, timeout)
        except select.error as e:
            if e[0] != errno.EINTR:
                raise
        savePid()
        for sock in readable:
            byteCount += saveData(sock.recv(5000000), outFile)
    return byteCount


def makeFilterMessage(receiverNode, enable):
    MSG_LEN = 0x02A0
    msg = b''
    msg += struct.pack('>I', MSG_ID_SET_FILTER)  # msg id
    msg += struct.pack('>H', receiverNode)
    msg += struct.pack('>H', FILTER_CPID_DSP)
    msg += struct.pack('>I', SENDER_SIC_ADDR)
    msg += struct.pack('>H', MSG_LEN)
    msg += struct.pack('>H', 0)  # flags

    NUM_OF_FILTERS = 64
    NUM_OF_HEAVY_LOAD = 8
    if enable:
        msg += struct.pack('>I', 1)  # monitor mode
        msg += struct.pack('>I', 1)  # monitor type
    else:
        msg += struct.pack('>I', 0)  # monitor mode
        msg += struct.pack('>I', 0)  # monitor type
    # msg filter ranges
    for i in range(NUM_OF_FILTERS):
        if i < len(FILTER_MSG_ID_LIST):
            msg += struct.pack('>I', FILTER_MSG_ID_LIST[i])
            msg += struct.pack('>I', FILTER_MSG_ID_LIST[i])
        else:
            msg += struct.pack('>I', 0)
            msg += struct.pack('>I', 0)
    # set 1 to range indication
    for i in range(NUM_OF_FILTERS):
        if i < len(FILTER_MSG_ID_LIST):
            msg += struct.pack('>B', 1)
        else:
            msg += struct.pack('>B', 0)
    # heavy load msg ids
    for i in range(NUM_OF_HEAVY_LOAD):
        if USE_HEAVY_FILT and i < len(FILTER_MSG_ID_LIST):
            msg += struct.pack('>I', FILTER_MSG_ID_LIST[i])
        else:
            msg += struct.pack('>I', 0)
    # heavy load counts
    for i in range(NUM_OF_HEAVY_LOAD):
        if USE_HEAVY_FILT and i < len(FILTER_MSG_ID_LIST):
            msg += struct.pack('>I', HEAVY_FILT_COUNT)
        else:
            msg += struct.pack('>I', 0)
    msg += struct.pack('>I', SENDER_SIC_ADDR)
    msg += struct.pack('>I', USE_MSG_AGGREGATION)
    if len(msg) != MSG_LEN:
        print("Error in filter message length", len(msg), "expected", MSG_LEN)
    return msg


def startTracing(sock, nodes):
    for nid in nodes:
        print('%s start trace 0x%X' % (time_.asctime(), nid))
        conf = makeFilterMessage(nid, True)
        sendTraceConf(sock, conf)


def stopTracing(sock, nodes):
    for nid in nodes:
        print('Node 0x%X trace stopped' % (nid))
        conf = makeFilterMessage(nid, False)
        sendTraceConf(sock, conf)


def parseArgs():
    global AA_TEST_PORT_CPID, AA_TEST_PORT, SENDER_SIC_ADDR, MCU_IP, OUTPUT_FILE, TIME_TO_TRACE, FILTER_NODE_ID_LIST
    global FILTER_MSG_ID_LIST, USE_MSG_AGGREGATION, USE_HEAVY_FILT
    mcuNode = 0x2011
    for i in range(len(sys.argv)):
        if sys.argv[i] == '--testPort' or sys.argv[i] == '-p':
            if len(sys.argv) > i + 1:
                AA_TEST_PORT = int(sys.argv[i + 1])

        elif sys.argv[i] == '--mcuIp' or sys.argv[i] == '-i':
            if len(sys.argv) > i + 1:
                MCU_IP = str(sys.argv[i + 1])

        elif sys.argv[i] == '--outputFile' or sys.argv[i] == '-o':
            if len(sys.argv) > i + 1:
                OUTPUT_FILE = str(sys.argv[i + 1])

        elif sys.argv[i] == '--timeToTrace' or sys.argv[i] == '-t':
            if len(sys.argv) > i + 1:
                TIME_TO_TRACE = float(sys.argv[i + 1])

        elif sys.argv[i] == '--nodeList' or sys.argv[i] == '-n':
            if len(sys.argv) > i + 1:
                FILTER_NODE_ID_LIST = sys.argv[i + 1].split(",")

        elif sys.argv[i] == '--msgList' or sys.argv[i] == '-m':
            if len(sys.argv) > i + 1:
                FILTER_MSG_ID_LIST = sys.argv[i + 1].split(",")

        elif sys.argv[i] == '--aggregate' or sys.argv[i] == '-a':
            if len(sys.argv) > i + 1:
                USE_MSG_AGGREGATION = int(sys.argv[i + 1])

        elif sys.argv[i] == '--mcuNode':
            if len(sys.argv) > i + 1:
                mcuNode = int(sys.argv[i + 1], 16)

        elif sys.argv[i] == '--heavy':
            if len(sys.argv) > i + 1:
                USE_HEAVY_FILT = int(sys.argv[i + 1], 16)

    print("nodeList:", FILTER_NODE_ID_LIST)
    FILTER_NODE_ID_LIST = convertFromStr(FILTER_NODE_ID_LIST)
    if len(FILTER_NODE_ID_LIST) == 0:
        print("Error - no nodeList given")
        exit(1)

    print("msgList:", FILTER_MSG_ID_LIST)
    FILTER_MSG_ID_LIST = convertFromStr(FILTER_MSG_ID_LIST)
    if len(FILTER_MSG_ID_LIST) == 0:
        print("Error - no msgList given")
        exit(1)

    SENDER_SIC_ADDR = (mcuNode << 16) | AA_TEST_PORT_CPID[AA_TEST_PORT]
    print("testPort:", AA_TEST_PORT, "(", hex(SENDER_SIC_ADDR), ")")
    print("mcuIp:", MCU_IP)
    print("outputFile:", OUTPUT_FILE)
    print("timeToTrace:", TIME_TO_TRACE)


def main():
    """
    Establishes a socket connection to gNB and sends messages, which configure gNB to send syscom messages to that
    socket, messages that should be traced and nodes on which listening should be active can be provided.
    Example usage: python simpleAaTrace.py --nodeList 0x123a,0x124a --msgList 0x442a,0x4ec6

    :return:                   None.
    """
    print("Simplest possible AaTrace, vers", VERS)
    parseArgs()

    signal.signal(signal.SIGINT, handler.signal_handler)
    print("Stop tracing with Ctrl+C")

    outFile = open(OUTPUT_FILE, "wb")
    sock = openSocket()
    startTracing(sock, FILTER_NODE_ID_LIST)
    byteCount = waitAndDump(sock, TIME_TO_TRACE, outFile)
    stopTracing(sock, FILTER_NODE_ID_LIST)
    sock.close()
    outFile.close()

    print(time_.asctime(), 'Saved %.2f MB' % (1.0 * byteCount / (1024 * 1024)))


if __name__ == "__main__":
    main()
