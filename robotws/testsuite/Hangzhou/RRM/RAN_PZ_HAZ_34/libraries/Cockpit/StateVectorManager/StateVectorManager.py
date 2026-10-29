# description:  These functions are used to gather the traces from the different State Variables Builders
#               sort them and creates the XML files to interface with the Use Case Detectors
#
# history:
#               22/03/2019 - RJO: creation


import time
import os
import json
import threading
import traceback
from operator import itemgetter
from ..utilities.SortedCollection import SortedCollection
from ..Cockpit_Debug import debugWrite
from .StateMachineInputFile import StateMachineInputFile
from ..utilities.TCPServer import TCPServer


class StateVectorManager:
    def __init__(self, dbFolder, tcpPort):
        """
        Initialize the class and launch the mainloop in a new thread
        :param dbFolder: TODO : Delete
        :param tcpPort: tcp port number to the State Variable Builder message receiving server
        """
        self._dbFolder = dbFolder
        self._tcpPort = tcpPort
        self._tcpServer = TCPServer(tcpPort)
        self._eventStop = False
        self._sortedTrace = SortedCollection(key=itemgetter("frame.timestamp"))
        self._stateMachineRequiredFields = []
        self._stateMachineInputFile = StateMachineInputFile()
        self._stateVector = {}
        try:
            server_handler = threading.Thread(
                target=self._tcpServer.launchServer, args=())
            server_handler.start()
        except Exception:
            debugWrite("Exception: " + traceback.format_exc(limit=5))
        time.sleep(0.01)
        threading.Thread(target=self._mainLoop).start()

    def _mainLoop(self):
        """
        Loop to get and treat the messages coming from the states variables builders
        :return: None
        """
        debugWrite("StateVectorManager mainLoop started")
        try:
            while not self._eventStop:
                data = self._tcpServer.recv()
                if data is not None:
                    traceDict = json.loads(data.decode("UTF-8"))
                    # debugWrite(traceDict)
                    self._sortedTrace.insert_right(traceDict)
        except Exception:
            debugWrite("Exception: " + traceback.format_exc(limit=5))
        debugWrite("StateVectorManager mainLoop stopped")
        self._tcpServer.stopServer()

    def fillStateMachineRequiredFields(self, stateMachineRequiredFields):
        """
        save the list of required field needed by the states machines
        :param stateMachineRequiredFields: list of string containing required fields
        :return: None
        """
        self._stateMachineRequiredFields = stateMachineRequiredFields

    def stop(self):
        """
        Stop the state vector manager
        :return:  None
        """
        self._eventStop = True
        time.sleep(1)

    def stopStateVectorReceiving(self):
        """
        Stop the server receiving the state variable builders messages and
        wait for the last messages in queue to be received
        :return: None
        """
        debugWrite("StopStateVectorReceiving - Enter")
        time.sleep(3)
        self._tcpServer.stopServer()
        time.sleep(2)
        while self._tcpServer.hasNewMessages():
            time.sleep(1)
        debugWrite("StopStateVectorReceiving - Return")

    def writeSmInputFiles(self, destFolder):
        """
        Write the XML and CSV files that will be used as entry of the Use Case Detectors
        :param destFolder: Path to the folder where the files will be located
        :return: None
        """
        self._stateMachineInputFile.initialize(destFolder)
        smFolder = destFolder + "/"
        try:
            os.makedirs(smFolder)
        except OSError:
            pass
        self._stateMachineInputFile.setDestFolder(smFolder)
        traceNb = 0
        for traceDict in self._sortedTrace:
            traceNb += 1
            eventVector = self._getStateAndEventVector(traceDict)
            self._stateMachineInputFile.write(
                self._stateMachineRequiredFields,
                eventVector,
                self._stateVector,
                traceNb)
        self._stateMachineInputFile.finalizeAllTraces()

    def _getStateAndEventVector(self, traceDict):
        """
        get the event vector from a State Variable Builder message and update the state vector according to the message
        :param traceDict: State Variable builder message
        :return: event vector
        """
        returnEventVector = {}
        firstStateVector = True
        returnEventVector['frame.time_epoch'] = traceDict['frame.time_epoch']
        returnEventVector['frame.timestamp'] = traceDict['frame.timestamp']
        for requiredField in self._stateMachineRequiredFields:
            try:
                if requiredField.startswith('state.'):
                    self._stateVector[requiredField] = traceDict[requiredField]
                    if firstStateVector:
                        firstStateVector = False
                        self._stateVector['frame.time_epoch'] = traceDict['frame.time_epoch']
                        self._stateVector['frame.timestamp'] = traceDict['frame.timestamp']
                else:
                    returnEventVector[requiredField] = traceDict[requiredField]
            except Exception:
                pass
        return returnEventVector


if __name__ == '__main__':
    stateVectorManager = StateVectorManager(
        "c:/traces/StateVectorManager", 5001)
    time.sleep(20)
    stateVectorManager.stop()
