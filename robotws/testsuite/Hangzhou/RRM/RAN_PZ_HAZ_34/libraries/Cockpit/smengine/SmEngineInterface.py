from __future__ import print_function
from ..Cockpit_Debug import debugWrite
import re

# Package needed to parse input arguments
import sys

# Needed to check Python version
import platform

import glob
import datetime
import os
import subprocess

# Package needed to launch SM Engine
from ..smengine.sm_engine import sm_engine


# Package needed to parse XML output from tshark
import xml.etree.ElementTree as xmlTree
from xml.sax.saxutils import unescape


class SmEngineInterface:
    def __init__(self, smFolder):
        self._inputFilesFolder = "./"
        self._smFolder = smFolder
        self._smShortFileNames = ()
        self._smUCDCounterDictionary = {}

    def _analysePyUseCaseDetector(self, ucdShortFileName):
        os.system("")
        ucdName = ucdShortFileName.replace(
            "\\", "/").split("/")[-1].replace(".sm", "")
        ucdFileName = self._smFolder + "/" + ucdShortFileName
        debugWrite(
            "Launching python %s from %s" %
            (ucdFileName, self._inputFilesFolder))
        p = subprocess.Popen(("python", ucdFileName),
                             cwd=self._inputFilesFolder)
        p.wait()
        # os.system(ucdFileName)

    def _analyseSmUseCaseDetector(self, smShortFileNames):
        # print (smShortFileName)
        # smName = smShortFileName.replace("\\", "/").split("/")[-1].replace(".sm", "")
        # requiredFields = ["frame.number", "frame.time_epoch"] +
        #  self._getStateMachineRequiredFields(smShortFileName) + ["frame.timestamp"]
        smEngine = sm_engine()
        smEngine.initLib(False, False, "")
        smResultFile = None
        requiredFields = [
            "frame.number",
            "frame.time_epoch",
            "frame.timestamp"]
        # Logger.logDEBUG(__file__, "Initlib done")
        for smShortFileName in smShortFileNames:
            print('running State Machine: ' + smShortFileName)
            smFileName = self._smFolder + "/" + smShortFileName
            smEngine.loadStateMachine(smFileName)
            requiredFields = requiredFields + \
                self._getStateMachineRequiredFields(smShortFileName)

        # remove double values
        requiredFields = list(set(requiredFields))

        readIter = 0  # Used to print smEngine report every 100 lines
        process_time_start = datetime.datetime.now()

        debugWrite(smFileName, requiredFields)

        smEngine.start()

        for smInputFileName in glob.glob(
                self._inputFilesFolder + "/eventVector" + "*.xml"):
            sectionField = []
            stateStartTimeStamp = 0
            stateInputFileName = smInputFileName.replace('event', 'state')
            stateEndTimeStamp = 0
            states = None

            try:
                stateInputFile = open(stateInputFileName, "r")
                line = stateInputFile.readline()
                while not line.startswith('<packet>'):
                    line = stateInputFile.readline()
                line = stateInputFile.readline()
                line = stateInputFile.readline()
                stateEndTimeStamp = float(line[9:-12])

            except Exception as e:
                stateInputFile = None

            smInputFile = open(smInputFileName, "r")
            debugWrite("Start of analysis" + smInputFileName)

            smResultFile = smInputFileName.replace(".xml", ".json")
            if os.path.isfile(smResultFile):
                os.remove(smResultFile)
            # Init state machine engine

            # Skip first lines containing XML header and structure, wait for
            # first "<packet>" label
            foundFirstPacket = False
            xmlPacketText = ""
            line = smInputFile.readline()
            while line:
                # print (line)
                if len(line) > 0:
                    '''
                    <packet>
                    <section>10</section>
                    <section>1466008406.943677000</section>
                    <section>id-Reset</section>
                    <section></section>
                    section></section>
                    </packet>
                    '''
                    if not foundFirstPacket and line.startswith("<section>"):
                        sectionField.append(re.findall(
                            r'\>+[\w\.-]+\<', line)[0][1:-1])

                    if not foundFirstPacket and line.startswith(
                            "</structure>"):
                        matchingList = self._correlateStateMachineFields(
                            requiredFields, sectionField)

                    if line.startswith("<packet>"):
                        '''
                            Ignore first <packet> group describing output structure
                            xmlPacketText: used to concatenate XML packet key/value information
                        '''
                        xmlPacketText = line
                        foundFirstPacket = True

                    elif foundFirstPacket:
                        if line.startswith("<section>"):
                            '''
                                Add key/value information to xmlPacketText
                            '''
                            xmlPacketText += line
                        elif line.startswith("</packet>"):
                            '''
                                End of packet key/value information
                                Use xmlTree.fromstring(xmlPacketText) to extract key/value in dictionary
                            '''
                            xmlPacketText += line
                            xmlPacket = xmlTree.fromstring(xmlPacketText)
                            keyIndex = 0
                            # print(xmlPacketText)
                            # print(requiredFields)
                            for keyValue in xmlPacket.iter("section"):
                                # print(keyIndex)

                                if keyValue.text is not None:
                                    if keyIndex == 1:
                                        # Set Event timestamp, time_epoch is at
                                        # position 1
                                        smEngine.setTimestamp(
                                            float(keyValue.text))
                                        timeStamp = float(keyValue.text)
                                        pass
                                    elif keyIndex > 1:
                                        # Set Event key/value pair
                                        # print(requiredFields[keyIndex])
                                        # print(keyValue.text)

                                        if matchingList[keyIndex] is True:
                                            # print(sectionField[keyIndex])
                                            smEngine.addEvent(
                                                sectionField[keyIndex], keyValue.text)
                                        pass
                                keyIndex += 1

                            # Add States
                            if timeStamp > stateEndTimeStamp and stateInputFile:
                                nbIndex = keyIndex
                                stateStartTimeStamp = stateEndTimeStamp
                                states = [None] * nbIndex
                                for keyIndex in range(2, nbIndex):
                                    line = stateInputFile.readline()
                                    states[keyIndex] = unescape(line[9:-12])
                                    keyIndex += 1
                                try:
                                    stateInputFile.readlines(3)
                                    line = stateInputFile.readline()
                                    stateEndTimeStamp = float(line[9:-12])
                                except Exception:
                                    stateEndTimeStamp = float("inf")
                            if timeStamp > stateStartTimeStamp and states and stateInputFile:
                                keyIndex = 0
                                for section in sectionField:
                                    if matchingList[keyIndex] is True:
                                        if states[keyIndex]:
                                            smEngine.addEvent(
                                                section, states[keyIndex])
                                    keyIndex += 1

                            # Process Event
                            smEngine.processEvent()
                            readIter += 1
                            if readIter > 1000:
                                readIter = 0
                                # reportInfo = smEngine.getReport("JSON", smResultFile, True)
                                # if reportInfo != None:
                                #    debugWrite ("REPORT:" + reportInfo)

                line = smInputFile.readline()

            if readIter > 0:
                # FDEL reportInfo = smEngine.getReport("JSON", smResultFile, True)
                # if reportInfo != None:
                #    debugWrite ("REPORT:" + reportInfo)
                pass

            smInputFile.close()
            debugWrite("End of File Analysis")
        debugWrite(
            'Analyze time: {}'.format(
                datetime.datetime.now() -
                process_time_start))
        smEngine.stop()

        # stop
        reportInfo = smEngine.getReport("JSON", smResultFile, True)

        smEngine.exitLib()

    def launchSmAnalysis(self, destFolder):

        self._inputFilesFolder = destFolder + "/"
        if not os.path.exists(self._inputFilesFolder):
            try:
                os.mkdir(self._inputFilesFolder)
            except OSError:
                pass

        smFiles = []
        for smShortFileName in self._smShortFileNames:
            UCD = smShortFileName.replace(
                "\\", "/").split("/")[-1].replace(".sm", "").replace(".py", "")

            self._outputFilesFolder = destFolder + UCD + "/"

            if not os.path.exists(self._outputFilesFolder):
                try:
                    os.mkdir(self._outputFilesFolder)
                except OSError:
                    pass
            try:
                os.remove(self._outputFilesFolder + "DetectedUseCases.log")
            except OSError:
                pass
            if smShortFileName.endswith(".sm"):
                smFiles.append(smShortFileName)
            if smShortFileName.endswith(".py"):
                self._analysePyUseCaseDetector(smShortFileName)
                self._addUCDResultToDictionnary(
                    UCD, self._outputFilesFolder + "DetectedUseCases.log")

        os.chdir(destFolder)
        self._analyseSmUseCaseDetector(smFiles)
        for smFile in smFiles:
            UCD = smFile.replace("\\", "/").split("/")[-1].replace(".sm", "")
            self._addUCDResultToDictionnary(
                UCD, destFolder + UCD + '/' + "DetectedUseCases.log")
        # add UCD for every u=output files

    def _addUCDResultToDictionnary(self, UCD, logfile):
        if UCD not in self._smUCDCounterDictionary:
            self._smUCDCounterDictionary[UCD] = {}
        with open(logfile) as file:
            for line in file:
                if (line.startswith('#') or line.startswith('\n')):
                    pass
                else:
                    temp = line.split(": ")
                    self._smUCDCounterDictionary[UCD][temp[0]] = int(temp[1])

    def getUseCaseDetectorCounter(self, UCD, CounterName):
        print('UCD:' + UCD)
        print('CounterName' + CounterName)
        return self._smUCDCounterDictionary[UCD][CounterName]

    def _getStateMachineRequiredFields(self, smShortFileName):
        stateMachineRequiredFields = []
        smFileName = self._smFolder + "/" + smShortFileName
        smFile = open(smFileName, "r")
        line = smFile.readline()
        while line:
            if line.strip().startswith("<varkey") or line.strip().startswith("#INPUT <varkey"):
                fieldName = line.split('"')[3]
                stateMachineRequiredFields.append(fieldName)
            line = smFile.readline()
            if line.strip().startswith("</param>"):
                break
        smFile.close()
        return (stateMachineRequiredFields)

    def _correlateStateMachineFields(self, requiredFields, sectionFields):
        matchingList = [False] * len(sectionFields)
        for field in requiredFields:
            for index, sectionField in enumerate(sectionFields):
                if field == sectionField:
                    matchingList[index] = True
        return matchingList

    def getStateMachinesInfo(self, smShortFileNames):
        stateMachines = []
        # stateMachineRequiredFields = {}
        # stateMachineRequiredFields["smName"] = "rrcSm"
        # stateMachineRequiredFields["fields"] = []
        # stateMachineRequiredFields["fields"].append("emil.rrcMessageId")
        # stateMachineRequiredFields["fields"].append("emil.nasMessageId")
        # stateMachines.append(stateMachineRequiredFields)

        # smList = glob.glob(self._smFolder + "/*.sm")
        # for smFileName in smList:
        #    stateMachines.append(self._getStateMachineRequiredFields(smFileName))
        self._smShortFileNames = smShortFileNames[:]
        for smShortFileName in smShortFileNames:
            stateMachines = list(
                set().union(
                    stateMachines,
                    self._getStateMachineRequiredFields(smShortFileName)))

        debugWrite(stateMachines)
        return (stateMachines)
