import time
import os
import json
import socket
import threading
import calendar
import pysftp
import struct
from operator import itemgetter
from ...utilities.SortedCollection import SortedCollection
from ...utilities.SshConnection import SshConnection
from ...Cockpit_Debug import debugWrite
import cProfile
import pstats
import io
import traceback


class TtiTraceStateVariableBuilder:
    def __init__(
            self,
            tlInfo,
            swModule,
            sourceFolder,
            ttiTraceFolder,
            tcpDestIp,
            tcpDestPort):
        self._tlInfo = tlInfo
        self._swModule = swModule
        # self._sourceIp = tlInfo["fct-1-0b"]["hostname"]
        # self._sourceUser = tlInfo["fct-1-0b"]["username"]
        # self._sourcePassword = tlInfo["fct-1-0b"]["password"]
        self._sourceFolder = sourceFolder
        self._ttiTraceFolder = ttiTraceFolder
        self._tcpDestIp = tcpDestIp
        self._tcpDestPort = tcpDestPort
        self._outSock = socket.socket(
            socket.AF_INET, socket.SOCK_STREAM)  # TCP
        self._outSock.connect((self._tcpDestIp, self._tcpDestPort))
        self._lastValue = {}
        self._eventStop = False
        self._cnopts = pysftp.CnOpts()
        self._cnopts.hostkeys = None
        self._transferredFile = []
        self._traceCollection = {}
        self._end = False
        self._start()

    def _start(self):
        os.makedirs(self._ttiTraceFolder, exist_ok=True)
        # ssh = paramiko.SSHClient()
        # ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        try:
            while not self._eventStop:
                try:
                    debugWrite(
                        "Trying connection to ",
                        self._tlInfo,
                        self._swModule)
                    sshConnection = SshConnection()
                    sshConnection.connect(self._tlInfo, self._swModule)
                    debugWrite("Connected to ", self._tlInfo, self._swModule)
                    break
                except Exception:
                    debugWrite("Exception in TtiStateVariableBuilder\n" +
                               traceback.format_exc() +
                               "\n" +
                               str(self._tlInfo) +
                               "\n" +
                               self._swModule +
                               "\nEnd of Exception")
                    time.sleep(1)

            stdin, stdout, stderr = sshConnection.exec_command(
                'rm %s/*.tar.gz' % (self._sourceFolder))
            out_lines = stdout.readlines()
            err_lines = stderr.readlines()
            out_resp = ''.join(out_lines)
            err_resp = ''.join(err_lines)
            # debugWrite("stdout=%s" % out_resp)
            # debugWrite("stderr=%s" % err_resp)

            transport = sshConnection.get_transport()
            channel = transport.open_session()
            channel.exec_command('nohup /opt/tools/ttiTrace/collect.sh')

            # ssh.connect(self._sourceIp, username = self._sourceUser, password = self._sourcePassword)

            # stdin, stdout, stderr = ssh.exec_command('rm %s/*.tar.gz'%(self._sourceFolder))
            # debugWrite(stdout.readlines())
            # debugWrite(stderr.readlines())

            # transport = ssh.get_transport()
            # channel = transport.open_session()
            # channel.exec_command('nohup /opt/tools/ttiTrace/collect.sh')

            debugWrite("TtiTraceStateVariableBuilder._start return")

            sshConnection.close()
        except Exception:
            debugWrite("Exception in TtiStateVariableBuilder\n" +
                       traceback.format_exc() +
                       "\n" +
                       str(self._tlInfo) +
                       "\n" +
                       self._swModule +
                       "\nEnd of Exception")

        debugWrite("launching _mainLoop")
        threading.Thread(target=self._mainLoop).start()

    def _mainLoop(self):
        while not self._eventStop:
            # sleep the time to have new files - must wake up before we risk to have
            #  a full disk space and after at least two files are created
            time.sleep(60)
            # Retrieve all files except the last
            NbOfFilesToProcess, SeqNumber = self._retrieveFiles()
            # analyze CSV files
            self._analyzeCsv(NbOfFilesToProcess, SeqNumber)

        # Retrieve and analyze remaining files
        NbOfFilesToProcess, SeqNumber = self._retrieveFiles()
        self._analyzeCsv(NbOfFilesToProcess, SeqNumber)
        # indicate the end to the stop function
        self._end = True

    def stop(self):
        self._eventStop = True
        self._end = False
        debugWrite("enter")
        while not self._end:
            pass
        self._outSock.close()
        debugWrite("return")

    def _retrieveFiles(self):
        returnNbOfFiles = 0
        seqNb = 0
        debugWrite("enter")
        # for f in glob.glob("%s/*.csv"%(self._ttiTraceFolder)):
        # try:
        # os.remove(f)
        # except:
        # debugWrite("Can not remove: " + f)

        try:
            debugWrite("Trying connection to ", self._tlInfo, self._swModule)
            sshConnection = SshConnection()
            sshConnection.connect(self._tlInfo, self._swModule)
            debugWrite("Connected to ", self._tlInfo, self._swModule)

            stdin, stdout, stderr = sshConnection.exec_command(
                'pkill collect.sh')
            out_lines = stdout.readlines()
            err_lines = stderr.readlines()
            out_resp = ''.join(out_lines)
            err_resp = ''.join(err_lines)
            # debugWrite("stdout=%s" % out_resp)
            # debugWrite("stderr=%s" % err_resp)

            # stdin, stdout, stderr = ssh.exec_command('pkill collect.sh')
            # debugWrite(stdout.readlines())
            # debugWrite(stderr.readlines())

            # sftpConn = pysftp.Connection(host=self._sourceIp, username=self._sourceUser,
            #  password=self._sourcePassword, cnopts=self._cnopts)

            stdin, stdout, stderr = sshConnection.exec_command(
                'ls -l %s' % (self._sourceFolder))
            # debugWrite(stderr.readlines())
            outLines = stdout.readlines()
            sftp = sshConnection.open_sftp()

            if self._eventStop:
                NumberOfFilesNotToDL = None
            else:
                NumberOfFilesNotToDL = -1
            for line in outLines[:NumberOfFilesNotToDL]:
                if ".tar.gz" in line:
                    # -rw-r--r-- 1 root root  196588 Mar 27 14:50 5GTtiTrace.bin.7.tar.gz
                    seqNb = line.split('.')[-3]
                    # debugWrite("seqNb", seqNb)
                    fileName = "5GTtiTrace.bin.%s" % (seqNb)

                    stdin, stdout, stderr = sshConnection.exec_command(
                        'tar xvf %s/%s.tar.gz' % (self._sourceFolder, fileName))
                    debugWrite(stdout.readlines())
                    debugWrite(stderr.readlines())

                    stdin, stdout, stderr = sshConnection.exec_command(
                        '/opt/tools/ttiTrace/TtiTraceDecoder %s %s' %
                        (fileName, fileName))
                    debugWrite(stdout.readlines())
                    debugWrite(stderr.readlines())

                    try:
                        sftp.get(
                            "%s.dl.csv" %
                            (fileName),
                            "%s/%s.dl.csv" %
                            (self._ttiTraceFolder,
                             fileName))
                    except Exception:
                        debugWrite(
                            "counld not get %s.dl.csv" %
                            (fileName), traceback.format_exc())

                    try:
                        sftp.get(
                            "%s.ul.csv" %
                            (fileName),
                            "%s/%s.ul.csv" %
                            (self._ttiTraceFolder,
                             fileName))
                    except Exception:
                        debugWrite(
                            "counld not get %s.ul.csv" %
                            (fileName), traceback.format_exc())

                    stdin, stdout, stderr = sshConnection.exec_command(
                        'rm %s.dl.csv' % (fileName))
                    # debugWrite(stdout.readlines())
                    # debugWrite(stderr.readlines())

                    stdin, stdout, stderr = sshConnection.exec_command(
                        'rm %s.ul.csv' % (fileName))
                    # debugWrite(stdout.readlines())
                    # debugWrite(stderr.readlines())

                    stdin, stdout, stderr = sshConnection.exec_command(
                        'rm %s' % (fileName))
                    # debugWrite(stdout.readlines())
                    # debugWrite(stderr.readlines())

                    returnNbOfFiles += 1

            sshConnection.close()
            sftp.close()
        except Exception:
            debugWrite("Exception in TtiStateVariableBuilder\n" +
                       traceback.format_exc() +
                       "\n" +
                       str(self._tlInfo) +
                       "\n" +
                       self._swModule +
                       "\nEnd of Exception")

        debugWrite("return", returnNbOfFiles)

        # return NbOfFiles and First SeqNumber downloaded
        return (returnNbOfFiles, seqNb - returnNbOfFiles + 1)

    def _flushTrace(self, traceItem, minNumber=0):
        if len(traceItem) >= minNumber:
            jsonMsg = json.dumps(traceItem)
            jsonMsg = struct.pack('>I', len(jsonMsg)) + jsonMsg.encode('utf-8')
            self._outSock.send(jsonMsg)
            # debugWrite(jsonMsg)

    def _storeItem(self, traceDict, itemName, itemValue):
        if itemValue is not None:
            try:
                traceDict[itemName] = int(itemValue, 0)
            except ValueError:
                try:
                    traceDict[itemName] = float(itemValue)
                except ValueError:
                    if itemValue != "":
                        traceDict[itemName] = itemValue

    def _fillTraceDictHeader(
            self,
            traceDict,
            timestamp,
            timeEpoch,
            trigger,
            crnti):
        traceDict["frame.timestamp"] = timestamp
        traceDict["frame.time_epoch"] = timeEpoch
        traceDict["frame.traceType"] = "ttiTrace"
        traceDict["frame.trigger"] = trigger
        traceDict["event.ttiTrace.crnti"] = crnti

    def _getTraceDict(self, timeSecond, nanoSeconds, crnti, trigger):
        # debugWrite("crnti", crnti)
        crnti = int(crnti, 0)
        timeStruct = time.strptime(timeSecond, "%Y-%m-%d %H:%M:%S")
        # debugWrite("timeStruct", timeStruct)
        secondsEpoch = round(calendar.timegm(timeStruct))
        fractionSecond = "%09d" % (int(nanoSeconds))
        localTime = time.strftime(
            "%Y/%m/%d %H:%M:%S",
            time.localtime(secondsEpoch))
        timestamp = localTime + "." + fractionSecond
        timeEpoch = str(secondsEpoch) + "." + fractionSecond

        if crnti not in self._traceCollection:
            self._traceCollection[crnti] = SortedCollection(
                key=itemgetter("frame.timestamp"))

        try:
            traceDict = self._traceCollection[crnti].find(timestamp)
        except ValueError:
            traceDict = {}
            self._fillTraceDictHeader(
                traceDict, timestamp, timeEpoch, trigger, crnti)
            self._traceCollection[crnti].insert_right(traceDict)

        return (traceDict)

    def _storeTtiTraceCsvColumnName(self, firstLine):
        self._columnNameToColId = {}
        self._columnName = firstLine.split(',')
        for colId in range(len(self._columnName)):
            self._columnNameToColId[self._columnName[colId]] = colId

    def _openAndStoreHeader(self, fileName):
        fileIn = open(fileName, "r")
        firstLine = fileIn.readline().strip('\n')
        self._storeTtiTraceCsvColumnName(firstLine)
        return (fileIn)

    def _getSplittedLine(self, fileIn):
        result = None
        lineIn = fileIn.readline()
        if lineIn:
            result = lineIn.strip('\n').split(',')
        return (result)

    def _getItemByName(self, itemName, splittedLineIn):
        result = splittedLineIn[self._columnNameToColId[itemName]]
        if result == "":
            result = None
        return (result)

    def _getItemByColId(self, colId, splittedLineIn):
        # debugWrite("colId", colId)
        # debugWrite("splittedLineIn", splittedLineIn)
        result = None
        try:
            result = splittedLineIn[colId]
        except IndexError:
            pass
        if result == "":
            result = None
        return (result)

    def _flushAllTraces(self):
        for crntiTrace in self._traceCollection:
            # debugWrite(crntiTrace)
            for traceDict in self._traceCollection[crntiTrace]:
                self._flushTrace(traceDict, minNumber=6)

        self._traceCollection = {}

    def _analyzeCsv(self, nbOfFilesToProcess, FirstSeqNb):
        pr = cProfile.Profile()
        pr.enable()

        for i in range(FirstSeqNb, nbOfFilesToProcess):
            currentFileName = "%s/5GTtiTrace.bin.%d" % (
                self._ttiTraceFolder, i)
            try:
                fileIn = self._openAndStoreHeader(currentFileName + ".ul.csv")
            except Exception:
                continue

            debugWrite("Analysing " + currentFileName + ".ul.csv")

            splittedLineIn = self._getSplittedLine(fileIn)
            while (splittedLineIn is not None):
                timeSecond = self._getItemByName("time", splittedLineIn)
                if timeSecond is not None:
                    nanoSeconds = self._getItemByName(
                        "tv_nsec", splittedLineIn)
                    crnti = self._getItemByName("crnti", splittedLineIn)
                    traceDict = self._getTraceDict(
                        timeSecond, nanoSeconds, crnti, "message")
                    for colId in range(2, len(self._columnName)):
                        columnName = self._columnName[colId]
                        if columnName != "crnti":
                            self._storeItem(
                                traceDict,
                                "event.ttiTrace.ul." +
                                columnName,
                                self._getItemByColId(
                                    colId,
                                    splittedLineIn))

                splittedLineIn = self._getSplittedLine(fileIn)
                # debugWrite(traceDict)
            fileIn.close()

            try:
                fileIn = self._openAndStoreHeader(currentFileName + ".dl.csv")
            except Exception:
                continue

            debugWrite("Analysing " + currentFileName + ".dl.csv")

            splittedLineIn = self._getSplittedLine(fileIn)
            while (splittedLineIn is not None):
                timeSecond = self._getItemByName("time", splittedLineIn)
                if timeSecond is not None:
                    nanoSeconds = self._getItemByName(
                        "tv_nsec", splittedLineIn)
                    crnti = self._getItemByName("crnti", splittedLineIn)
                    traceDict = self._getTraceDict(
                        timeSecond, nanoSeconds, crnti, "message")
                    for colId in range(2, len(self._columnName)):
                        columnName = self._columnName[colId]
                        if columnName != "crnti":
                            self._storeItem(
                                traceDict,
                                "event.ttiTrace.dl." +
                                columnName,
                                self._getItemByColId(
                                    colId,
                                    splittedLineIn))

                splittedLineIn = self._getSplittedLine(fileIn)
                # debugWrite(traceDict)

            fileIn.close()

            self._flushAllTraces()

        debugWrite("TtiTraceStateVariableBuilder _analyzeCsv stopped")
        pr.disable()
        s = io.StringIO()
        sortby = 'cumulative'
        ps = pstats.Stats(pr, stream=s).sort_stats(sortby)
        ps.print_stats()
        # debugWrite(s.getvalue())
