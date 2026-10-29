import os
import subprocess
import shlex
import sys
from ...Cockpit_Debug import debugWrite
from ...utilities.SshConnection import SshConnection


# import cProfile, pstats, io


class Class_L1L2TracesGetter:
    def __init__(
            self,
            tlInfo,
            swModule,
            itf,
            destFolder,
            fieldList,
            tsharkDissector,
            Filter):
        """
            Init Function of module
            param:  tlInfo:          Information on the Test Line from Cockpit_Config
            param:  swModule:        Module where the traces must be downloaded (e.g. "asik")
            param:  itf:             Interface (backhaul or fronthaul)
            param:  destFolder:      Folder where traces must be stored
            param:  fieldList:       List of fields in wiresark that must be extracted
                                     (e.g. "frame.number", "eth.addr")
            param:  tsharkDissector: TShark dissector path
                                     (e.g. "C:\tools\\wireshark\\experimental_fixed_master_R3_luashark\\luashark.lua")
            param:  Filter:          TShark filter on messages (e.g. "((!(uldata_syncind)) && !(dldata_slottypereq))")
            return: No return
        """
        self._tlInfo = tlInfo
        self._swModule = swModule
        self._sourceIp = tlInfo[swModule]["hostname"]
        self._sourceUser = tlInfo[swModule]["username"]
        self._sourcePassword = tlInfo[swModule]["password"]
        if itf is None:
            self._sourceItf = tlInfo[swModule]["itf"]
        else:
            self._sourceItf = itf
        self._tcpdumpFolder = tlInfo[swModule]["tcpDumpPath"] + \
            "/" + self._sourceItf + "/"
        self._sourceFolder = tlInfo[swModule]["ftpPath"]
        self._destFolder = destFolder

        self._tsharkDissector = tsharkDissector
        self._transferredFile = []
        self._Filter = Filter
        self._FieldList = fieldList

        self._stopped = False

        if self._swModule in ("asik",):
            self._sudoTemplate = ""
        else:
            self._sudoTemplate = "echo %s | sudo -S -k " % (
                self._sourcePassword)

        if "linux" in sys.platform:
            self._tsharkExe = "tshark"
        else:
            self._tsharkExe = '"C:/Program Files/Wireshark/tshark.exe"'

        self._sshConnection = SshConnection()
        self._sshConnection.connect(self._tlInfo, self._swModule)

    # ##-----------------------------------------------------------------------------------------------------------###

    def F_startCollection(self):
        """
            Start the collection of pcap files on swModule
            param:  No param
            return: No return
        """
        debugWrite("F_startCollection enter")
        comOut = self._sshConnection.executeAndWaitEnd(
            '%s pkill -f "tcpdump -i %s"' %
            (self._sudoTemplate, self._sourceItf))
        # debugWrite(comOut)
        if self._sudoTemplate == "":
            comOut = self._sshConnection.executeAndWaitEnd(
                '%s sh -c "mkdir -p %s;'
                ' chmod 777 %s;'
                ' rm %s/tcpdump*.pcap*;'
                ' ls -ltr %s;'
                ' echo tcpdump -i %s proto 0x84 -G 20 -C 100 -B 9000 -w %s/tcpdump-%%Y-%%m-%%d_%%Hh%%Mm%%S.pcap'
                ' -W 50 > tcpdump.sh ;'
                ' chmod 777 tcpdump.sh;'
                ' nohup ./tcpdump.sh"' %
                (self._sudoTemplate,
                 self._tcpdumpFolder,
                 self._tcpdumpFolder,
                 self._tcpdumpFolder,
                 self._tcpdumpFolder,
                 self._sourceItf,
                 self._tcpdumpFolder))
        else:
            comOut = self._sshConnection.executeAndWaitEnd(
                '%s -- sh -c "mkdir -p %s;'
                ' chmod 777 %s;'
                ' rm %s/tcpdump*.pcap*;'
                ' ls -ltr %s;'
                ' echo tcpdump -i %s proto 0x84 -G 20 -C 100 -B 9000 -w %s/tcpdump-%%Y-%%m-%%d_%%Hh%%Mm%%S.pcap'
                ' -W 50 > tcpdump.sh ;'
                ' chmod 777 tcpdump.sh;'
                ' nohup ./tcpdump.sh"' %
                (self._sudoTemplate,
                 self._tcpdumpFolder,
                 self._tcpdumpFolder,
                 self._tcpdumpFolder,
                 self._tcpdumpFolder,
                 self._sourceItf,
                 self._tcpdumpFolder))

        # debugWrite('%s sh -c "mkdir -p %s; chmod 777 %s; rm %s/tcpdump*.pcap*; ls -ltr %s;
        #  echo tcpdump -i %s -G 20 -C 100 -B 9000 -w %s/tcpdump-%%Y-%%m-%%d_%%Hh%%Mm%%S.pcap -W 50 > tcpdump.sh ;
        #  chmod 777 tcpdump.sh; nohup ./tcpdump.sh"'%(self._sudoTemplate, self._sourceFolder,
        # self._sourceFolder, self._sourceFolder, self._sourceFolder,
        # self._sourceItf, self._sourceFolder))
        self._stopped = False

        debugWrite("F_startCollection return")

    # ##----------------------------------------------------------------------------------------------------------###

    def F_stopCollection(self):
        """
            Stop the collection of pcap files on swModule
            param:  No param
            return: No return
        """
        debugWrite("F_stopCollection enter")

        comOut = self._sshConnection.executeAndWaitEnd(
            '%s pkill -f "tcpdump -i %s"' %
            (self._sudoTemplate, self._sourceItf))
        # debugWrite(comOut)
        self._stopped = True
        debugWrite("F_stopCollection return")

    # ##----------------------------------------------------------------------------------------------------------###

    def F_reconnect(self):
        reconnected = False
        while not self._stopped and not reconnected:
            try:
                self._sshConnection = SshConnection()
                self._sshConnection.connect(self._tlInfo, self._swModule)
                reconnected = True
            except Exception:
                pass
        if reconnected:
            self.F_startCollection()

    def F_getLastFile(self, FileExtension):
        """
            Download a new file from the module
            param:  FileExtension:   File extension of the output file. Can be either CSV or Json
            return: If there is a file not downloaded of the swModule: Path to the output File
                    Otherwise: None
        """
        returnFile = None

        # Get the directory and file listing
        debugWrite("getting file list")
        try:
            dirListFull = self._sshConnection.fileList(self._tcpdumpFolder)
        except Exception:
            self.F_reconnect()
        debugWrite("file list:", dirListFull)
        dirListFull.sort()
        if self._stopped:
            dirList = dirListFull[:]
        else:
            dirList = dirListFull[:-1]

        # debugWrite("file list:", dirListFull)
        # debugWrite("file list:", dirList)
        debugWrite(str(len(dirList)))
        debugWrite(str(dirList))
        if len(dirList) > 0:
            for fileName in dirList:
                sourceFile = self._tcpdumpFolder + "/" + fileName
                if sourceFile not in self._transferredFile:
                    pCapFile = self._destFolder + "/" + fileName
                    try:
                        os.remove(pCapFile)
                    except OSError:
                        pass
                    debugWrite("getting", sourceFile)
                    comOut = self._sshConnection.executeAndWaitEnd(
                        "mv %s %s" % (sourceFile, self._sourceFolder))

                    ftpFile = self._sourceFolder + "/" + fileName
                    debugWrite(ftpFile)
                    debugWrite(pCapFile)
                    self._sshConnection.downloadFile(ftpFile, pCapFile)
                    debugWrite("end of transfer", sourceFile)
                    self._sshConnection.executeAndWaitEnd(
                        '%s rm %s' % (self._sudoTemplate, ftpFile))
                    self._transferredFile.append(sourceFile)
                    if (FileExtension == "CSV"):
                        returnFile = self._F_CreateCSVFile(pCapFile)
                    else:
                        returnFile = self._F_CreateJsonFile(pCapFile)
                    break

        return (returnFile)

    # ##-----------------------------------------------------------------------------------------------------------###

    def _F_CreateJsonFile(self, sourceFile):
        """
            Create a Json file from a pcap file, using Tshark Dissectors
            param:  sourceFile:   Pcap file path
            return: new json file path
        """
        jsonFilename = os.path.splitext(sourceFile)[0] + ".json"
        if self._Filter:
            cmdLine = self._tsharkExe +  \
                ' -Y "' + self._Filter + '" -T json -r "' + sourceFile + '"'
        else:
            cmdLine = self._tsharkExe +  \
                 ' -T json -r "' + sourceFile + '"'

        debugWrite(cmdLine)
        debugWrite(jsonFilename)

        jsonFileDesc = open(jsonFilename, "w")
        returnCode = subprocess.call(
            cmdLine,
            stdout=jsonFileDesc,
            stderr=subprocess.DEVNULL)
        debugWrite("Finished", cmdLine)
        jsonFileDesc.close()

        return jsonFilename

    # ##----------------------------------------------------------------------------------------------------------###

    def _F_CreateCSVFile(self, sourceFile):
        """
            Create a CSV file from a pcap file, using Tshark Dissectors
            param:  sourceFile:   Pcap file path
            return: new CSV file path
        """
        csvFilename = os.path.splitext(sourceFile)[0] + ".csv"
        if self._Filter:
            cmdLine = self._tsharkExe +  \
                ' -Y "' + self._Filter + '" -T fields -E header=y -E separator=; -r ' + sourceFile
        else:
            cmdLine = self._tsharkExe +  \
                ' -T fields -E header=y -E separator=; -r ' + sourceFile
        for requestedField in self._FieldList:
            cmdLine += " -e " + requestedField
        debugWrite(cmdLine)
        csvFileDesc = open(csvFilename, "w")
        returnCode = subprocess.call(
            shlex.split(cmdLine),
            stdout=csvFileDesc,
            stderr=subprocess.DEVNULL)
        debugWrite("Finished", cmdLine)
        csvFileDesc.close()
        return csvFilename
