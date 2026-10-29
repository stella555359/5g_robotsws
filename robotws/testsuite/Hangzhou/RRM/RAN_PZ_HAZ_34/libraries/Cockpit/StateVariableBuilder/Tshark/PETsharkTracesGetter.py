import os
import glob
from ...Cockpit_Debug import debugWrite
import subprocess
import shutil
import shlex


# import cProfile, pstats, io


class Class_PETsharkTracesGetter:
    def __init__(self, tlInfo, swModule, destFolder):
        """
            Init Function of module
            param:  tlInfo:                 Information on the Test Line from Cockpit_Config
            param:  swModule:               Module where the traces must be downloaded (e.g. "asik")
            param:  destFolder:             Folder where traces must be stored
            return: No return
        """
        self._tlInfo = tlInfo
        self._swModule = swModule
        self._sourceFolder = tlInfo[swModule]["tcpDumpPath"]
        self._destFolder = destFolder

        self._transferredFile = []

        self._stopped = False

        if self._swModule in ("asik",):
            self._sudoTemplate = ""
        else:
            self._sudoTemplate = "echo %s | sudo -S -k " % (
                self._sourcePassword)

        self._peTsharkExe = '"C:/Program Files/PE-Wireshark/pe_tshark.exe"'
        self._configFile = '[LSU]PAROS_CV63_UU-4G5G-feature475.cfg'

    # ##-----------------------------------------------------------------------------------------------------------###

    def F_transformLSUToXML(self, LSUFilePath, XMLFilePath):
        """
            Transform a LSU file into a PDML file on distant airmosaic computer
            param:  LSUFilePath:  Path to the LSU File
            param:  XMLFilePath:  Path to the XML file
            return: No return
        """

        command = '%s -r %s -T pdml' % (self._peTsharkExe, LSUFilePath)
        command = command.replace("\\", "\\\\")
        debugWrite("F_transformLSUToXML")
        debugWrite(command)
        with open(XMLFilePath, "w") as outFile:
            subprocess.run(shlex.split(command), stdout=outFile)

    # ##----------------------------------------------------------------------------------------------------------###

    def F_startCollection(self):
        """
            Start the collection of pcap files on swModule
            param:  No param
            return: No return
        """
        debugWrite("F_startCollection enter")

        subprocess.run(shlex.split("taskkill /F /IM pe_tshark.exe"))
        debugWrite(
            "%s -b filesize:50000 -b files:10 -i %s -w \"GSM-A1.lsu\"" %
            (self._peTsharkExe, self._configFile))
        subprocess.Popen(
            shlex.split(
                "%s -b filesize:25000 -b files:100 -i %s -w \"%sGSM-A1.lsu\"" %
                (self._peTsharkExe, self._configFile, self._sourceFolder)))
        # debugWrite(comOut)
        self._stopped = False

        debugWrite("F_startCollection return")

    # ##-----------------------------------------------------------------------------------------------------------###

    def F_stopCollection(self):
        """
            Stop the collection of pcap files on swModule
            param:  No param
            return: No return
        """
        debugWrite("F_stopCollection enter")

        subprocess.run(shlex.split("taskkill /F /IM pe_tshark.exe"))
        # debugWrite(comOut)
        self._stopped = True
        debugWrite("F_stopCollection return")

    # ##-----------------------------------------------------------------------------------------------------------###

    def F_getLastFile(self):
        """
            Download a new file from the module
            return: If there is a file not downloaded of the swModule: Path to the output File
                    Otherwise: None
        """
        returnFile = None

        # Get the directory and file listing
        debugWrite("getting file list")
        dirListFull = glob.glob(self._sourceFolder + '*.lsu')
        debugWrite("file list:", dirListFull)
        if self._stopped:
            dirList = dirListFull[:]
        else:
            dirList = dirListFull[:-1]

        # debugWrite("file list:", dirListFull)
        # debugWrite("file list:", dirList)
        if len(dirList) > 0:
            for fileName in dirList:
                if fileName not in self._transferredFile:
                    pdmlFilePath = os.path.splitext(fileName)[0] + '.xml'
                    pdmlFileName = os.path.basename(pdmlFilePath)
                    self.F_transformLSUToXML(fileName, pdmlFilePath)
                    destFile = self._destFolder + pdmlFileName
                    try:
                        os.remove(destFile)
                    except OSError:
                        pass
                    shutil.move(pdmlFilePath, destFile)
                    shutil.move(
                        fileName,
                        self._destFolder +
                        os.path.basename(fileName))
                    self._transferredFile.append(fileName)
                    returnFile = destFile
                    break

        return (returnFile)
