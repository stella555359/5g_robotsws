# description:  These functions are used to create the files to interface with the Use Case Detectors
#
# history:
#               22/03/2019 - RJO: creation

import os
import glob
from ..Cockpit_Debug import debugWrite
from xml.sax.saxutils import escape


class StateMachineInputFile:
    def __init__(self):
        self._fileNames = []
        self._fileDescriptors = []
        self._MAX_OPENED_FILES = 50
        self._destFolder = "./"

    def _open(self, filename):
        """
        open a new file in writing if it does not exist yet, in append if t exists
        :param filename: name of the file to be written
        :return: file descriptor
        """
        fullFileName = self._destFolder + "/" + filename
        if os.path.isfile(fullFileName):
            result = (open(fullFileName, "a"), True)
        else:
            result = (open(fullFileName, "w"), False)
        # debugWrite(result)
        return (result)

    def _getFile(self, ueCorrelatedId, fileExtension, type):
        """
        get the file descriptor of the file in which the data must be written according to the parameters
        :param ueCorrelatedId: filename suffix
        :param fileExtension: XML or CSV file
        :param type: State or Event vector file
        :return: tuple: 1 - file descriptor   2 - boolean indicating if the file existed before
        """
        fileName = "%sVector_%s.%s" % (
            type, str(ueCorrelatedId), fileExtension)
        if fileName in self._fileNames:
            fileIdx = self._fileNames.index(fileName)
            fileDesc = self._fileDescriptors[fileIdx]
            fileAlreadyExists = True
            del (self._fileNames[fileIdx])
            del (self._fileDescriptors[fileIdx])
        else:
            if len(self._fileNames) > self._MAX_OPENED_FILES:
                # #debugWrite "Closing %s, opening %s, %d files opened"%(fileNames[0], parFileName, len(fileNames))
                self._fileDescriptors[0].close()
                del (self._fileNames[0])
                del (self._fileDescriptors[0])
            (fileDesc, fileAlreadyExists) = self._open(fileName)
        self._fileNames.append(fileName)
        self._fileDescriptors.append(fileDesc)
        return ((fileDesc, fileAlreadyExists))

    def _writeSectionField(
            self,
            field,
            xmlFile,
            csvFile,
            concatCsvFile,
            writeConcat=True):
        """
        Write a section field in the header of the xml file and a column name of the csv file
        :param field: Name of the field to be written
        :param xmlFile: xml file name
        :param csvFile: csv file name
        :param concatCsvFile: concatenated csv file name
        :param writeConcat: boolean indicating if the concatenated csv file name has to be written
        :return: None
        """
        xmlFile.write('<section>' + escape(str(field)) + '</section>\n')
        csvFile.write('"' + str(field).replace('"', '""') + '"' + ';')
        if writeConcat:
            concatCsvFile.write(
                '"' +
                str(field).replace(
                    '"',
                    '""') +
                '"' +
                ';')

    def write(
            self,
            stateMachineRequiredFields,
            eventVector,
            stateVector,
            traceNb):
        """
        Write a new packet to the XML and CSV file. If the files does not exist yet, the files are created and
        their headers are filled
        :param stateMachineRequiredFields: minimum required fields for the use case detectors
        :param eventVector: event Vector
        :param stateVector: state Vector
        :param traceNb: Packet number
        :return: None
        """
        (outFileEvent, fileAlreadyExists) = self._getFile(0, "xml", "event")
        (csvFileEvent, fileAlreadyExists) = self._getFile(0, "csv", "event")
        (concatCsvFileEvent, concatEventFileAlreadyExists) = self._getFile(
            "all", "csv", "event")
        # file structure:
        # <?xml version="1.0" encoding="utf-8"?>
        # <psml version="0" creator="wireshark/2.4.5">
        # <structure>
        # <section>frame.number</section>
        # <section>frame.time_epoch</section>
        # <section>s1ap.ENB_UE_S1AP_ID</section>
        # <section>s1ap.HandoverType</section>
        # <section>s1ap.MME_UE_S1AP_ID</section>
        # <section>s1ap.radioNetwork</section>
        # <section>nas_eps.nas_msg_emm_type</section>
        # <section>lte-rrc.c1</section>
        # <section>s1ap.procedureCode</section>
        # </structure>
        #
        # <packet>
        # <section>1</section>
        # <section>1466008401.085688000</section>
        # <section>5</section>
        # <section></section>
        # <section>4203737</section>
        # <section></section>
        # <section>Tracking area update accept</section>
        # <section></section>
        # <section>id-downlinkNASTransport</section>
        # </packet>
        #
        # </psml>
        if not fileAlreadyExists:
            outFileEvent.write('<?xml version="1.0" encoding="utf-8"?>\n')
            outFileEvent.write(
                '<psml version="0" creator="StateMachineInputFile">\n')
            outFileEvent.write('<structure>\n')
            self._writeSectionField(
                "frame.number",
                outFileEvent,
                csvFileEvent,
                concatCsvFileEvent,
                writeConcat=not concatEventFileAlreadyExists)
            self._writeSectionField(
                "frame.time_epoch",
                outFileEvent,
                csvFileEvent,
                concatCsvFileEvent,
                writeConcat=not concatEventFileAlreadyExists)

            for requiredField in stateMachineRequiredFields:
                self._writeSectionField(
                    requiredField,
                    outFileEvent,
                    csvFileEvent,
                    concatCsvFileEvent,
                    writeConcat=not concatEventFileAlreadyExists)

            self._writeSectionField(
                "frame.timestamp",
                outFileEvent,
                csvFileEvent,
                concatCsvFileEvent,
                writeConcat=not concatEventFileAlreadyExists)
            outFileEvent.write('</structure>\n')
            csvFileEvent.write('\n')
            if not concatEventFileAlreadyExists:
                concatCsvFileEvent.write('\n')

        outFileEvent.write('<packet>\n')
        self._writeSectionField(
            traceNb,
            outFileEvent,
            csvFileEvent,
            concatCsvFileEvent,
            writeConcat=True)
        self._writeSectionField(
            eventVector["frame.time_epoch"],
            outFileEvent,
            csvFileEvent,
            concatCsvFileEvent,
            writeConcat=True)

        for requiredField in stateMachineRequiredFields:
            if requiredField in eventVector:
                self._writeSectionField(
                    eventVector[requiredField],
                    outFileEvent,
                    csvFileEvent,
                    concatCsvFileEvent,
                    writeConcat=True)
            else:
                self._writeSectionField(
                    "",
                    outFileEvent,
                    csvFileEvent,
                    concatCsvFileEvent,
                    writeConcat=True)

        self._writeSectionField(
            eventVector["frame.timestamp"],
            outFileEvent,
            csvFileEvent,
            concatCsvFileEvent,
            writeConcat=True)
        outFileEvent.write('</packet>\n')
        csvFileEvent.write('\n')
        concatCsvFileEvent.write('\n')

        if stateVector:

            (outFileState, fileAlreadyExists) = self._getFile(0, "xml", "state")
            (csvFileState, fileAlreadyExists) = self._getFile(0, "csv", "state")
            (concatCsvFileState, concatStateFileAlreadyExists) = self._getFile(
                "all", "csv", "state")

            if not fileAlreadyExists:

                outFileState.write('<?xml version="1.0" encoding="utf-8"?>\n')
                outFileState.write(
                    '<psml version="0" creator="StateMachineInputFile">\n')
                outFileState.write('<structure>\n')
                self._writeSectionField(
                    "frame.number",
                    outFileState,
                    csvFileState,
                    concatCsvFileState,
                    writeConcat=not concatStateFileAlreadyExists)
                self._writeSectionField(
                    "frame.time_epoch",
                    outFileState,
                    csvFileState,
                    concatCsvFileState,
                    writeConcat=not concatStateFileAlreadyExists)

                for requiredField in stateMachineRequiredFields:
                    self._writeSectionField(
                        requiredField,
                        outFileState,
                        csvFileState,
                        concatCsvFileState,
                        writeConcat=not concatStateFileAlreadyExists)

                self._writeSectionField(
                    "frame.timestamp",
                    outFileState,
                    csvFileState,
                    concatCsvFileState,
                    writeConcat=not concatStateFileAlreadyExists)
                outFileState.write('</structure>\n')
                csvFileState.write('\n')
                if not concatStateFileAlreadyExists:
                    concatCsvFileState.write('\n')

            outFileState.write('<packet>\n')
            self._writeSectionField(
                traceNb,
                outFileState,
                csvFileState,
                concatCsvFileState,
                writeConcat=True)
            self._writeSectionField(
                stateVector["frame.time_epoch"],
                outFileState,
                csvFileState,
                concatCsvFileState,
                writeConcat=True)

            for requiredField in stateMachineRequiredFields:
                if requiredField in stateVector:
                    self._writeSectionField(
                        stateVector[requiredField],
                        outFileState,
                        csvFileState,
                        concatCsvFileState,
                        writeConcat=True)
                else:
                    self._writeSectionField(
                        "",
                        outFileState,
                        csvFileState,
                        concatCsvFileState,
                        writeConcat=True)

            self._writeSectionField(
                stateVector["frame.timestamp"],
                outFileState,
                csvFileState,
                concatCsvFileState,
                writeConcat=True)
            outFileState.write('</packet>\n')
            csvFileState.write('\n')
            concatCsvFileState.write('\n')

    def finalizeAllTraces(self):
        """
        Write the footer for all the files.
        :return:
        """
        for fileDesc in self._fileDescriptors:
            fileDesc.close()

        fileList = glob.glob(self._destFolder + "SM_*.xml")
        for fileName in fileList:
            fileDesc = open(fileName, "a")
            fileDesc.write('</psml>\n')
            fileDesc.close()

        self._fileNames = []
        self._fileDescriptors = []

    def initialize(self, destFolder):
        """
        Initialize the writing of SM Input files by creating the destination folder and cleaning inside the folder
        :param destFolder: destination folder for the XML and CSV files
        :return: None
        """
        debugWrite("StateMachineInputFile initialize, ", destFolder)
        self._destFolder = destFolder
        try:
            os.makedirs(self._destFolder)
        except OSError:
            pass

        for root, dirs, files in os.walk(self._destFolder):
            fileList = glob.glob(root + "/" + "SM_*.xml")
            for fileName in fileList:
                os.remove(fileName)

            fileList = glob.glob(self._destFolder + "SM_*.csv")
            for fileName in fileList:
                os.remove(fileName)

    def setDestFolder(self, destFolder):
        """
        Set a new destination folder
        :param destFolder: new destination folder
        :return: None
        """
        self._destFolder = destFolder
