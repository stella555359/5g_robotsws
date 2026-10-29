# -*- coding: utf-8 -*-

from ctesPerf import *
from pTTI_P27 import parserTTI
from pQCT_P27 import parserQCT
import argparse
import sys
import traceback
import telnetlib
import time
from datetime import datetime
import paramiko
import os
import socket
from paramiko import (
    SSHClient,
    MissingHostKeyPolicy,
)

from robot.libraries.BuiltIn import BuiltIn
rolb = BuiltIn()


def getTimeStamp():
    return datetime.now().strftime("_%Y%m%d_%H%M%S")


class DescTest:
    'Class to connect to remote server'

    def __init__(self):
        self.timeStamp = getTimeStamp()
        self.logsTest = None

        self.testName = cLA_TESTNAME
        self.profile = cLA_PROFILE
        self.trafficType = cLA_TRAFICTYPE
        self.captureDuration = cLA_CAPTUREDURATION

        self.typeAtten = cLA_TYPEATTEN
        self.iattenPwr = cLA_IATTENPWR
        self.iattenCN = cLA_IATTENCN

        self.iatten = cLA_IATTEN
        self.fatten = cLA_FATTEN
        self.step = cLA_STEP
        self.nbLoop = cLA_NBLOOP
        self.allerRetour = cLA_ALLERRETOUR
        self.traceType = cLA_TRACETYPE
        self.hdf2txt = cLA_HDF2TXR
        self.nbResFile = -1

        self.resFlag = True
        self.ssh_ASIK = None
        self.ssh_ASIK_ABIL = None
        self.ssh_PC_UE = None
        self.ssh_PC_SPIRENT = None
        self.tnSpirent = None
        self.sshproxy = None

        self.ASIK_OAM_IP = cLA_ASIK_OAM_IP
        self.ASIK_OAM_LOGIN = cLA_ASIK_OAM_LOGIN
        self.ASIK_OAM_PWD = cLA_ASIK_OAM_PWD
        self.ABIL_IP_TTI = cLA_ABIL_IP_TTI

        self.SPIRENT_IP = cLA_SPIRENT_IP
        self.SPIRENT_PORT = cLA_SPIRENT_PORT
        self.SSH_PORT = cLA_SSH_PORT
        self.SSH_TO = cLA_SSH_TO
        self.STABILISATIONTIME = cLA_STABILISATIONTIME

        self.spirentOutputPortsDL = cLA_SPIRENT_OUTPUT_PORTS_DL
        self.spirentOutputPortsUL = cLA_SPIRENT_OUTPUT_PORTS_UL

        self.PC_SPIRENT_IP = cLA_PC_SPIRENT_IP
        self.PC_SPIRENT_LOGIN = cLA_PC_SPIRENT_LOGIN
        self.PC_SPIRENT_PWD = cLA_PC_SPIRENT_PWD

        self.SPIRENT_IP = cLA_SPIRENT_IP

        self.getTTItraces = cLA_getTTItraces
        self.ASIK_PATH = cLA_ASIK_PATH

        self.PC_UE_IP = cLA_PC_UE_IP
        self.PC_UE_LOGIN = cLA_PC_UE_LOGIN
        self.PC_UE_PWD = cLA_PC_UE_PWD
        self.UE_IP = cLA_UE_IP

        self.getQCTtraces = cLA_getQCTtraces
        self.UE_5G_DMC_CONF = cLA_UE_5G_DMC_CONF
        self.UE_5G_TRACES = cLA_UE_5G_TRACES
        self.UE_5G_EXEC_QCAT = cLA_UE_5G_EXEC_QCAT

        self.TTI = cLA_TTI
        self.QCT = cLA_QCT

        self.VM_PATH = cLA_VM_PATH
        self.VM_PATH_TST = self.VM_PATH + self.trafficType + \
            '_' + self.testName + self.timeStamp + '/'
        self.VM_PATH_TTI = self.VM_PATH_TST + self.TTI + '/'
        self.VM_PATH_QCT = self.VM_PATH_TST + self.QCT + '/'
        self.ASIK_PATH_TTI = self.ASIK_PATH + self.testName
        self.UE_PATH_QCT = self.UE_5G_TRACES + self.testName

        self.DLrecap_output = None
        self.ULrecap_output = None
        self.atten = ''
        self.dlRecapQCT = cLA_DLemptyQCT
        self.ulRecapQCT = cLA_ULemptyQCT
        self.dlRecapTTI = cLA_DLemptyTTI
        self.ulRecapTTI = cLA_ULemptyTTI

    def imprimerLog(self):
        self.log(
            '===============================================================================================')
        self.log(('LA DL-UL : {}').format(self.testName))
        self.log('-'*(len(self.testName)+11))
        self.log('')
        self.log(('\tTrafficType                  : {}').format(self.trafficType))
        self.log(('\tProfile                      : {}').format(self.profile))
        self.log(('\tType atten                   : {}').format(self.typeAtten))
        self.log(('\tOutput Ports DL              : {}').format(
            self.spirentOutputPortsDL))
        self.log(('\tOutput Ports UL              : {}').format(
            self.spirentOutputPortsUL))
        self.log(('\tInitial atten                : {}').format(self.iatten))
        self.log(('\tFinal atten                  : {}').format(self.fatten))
        self.log(('\tStep (db)                    : {}').format(self.step))
        self.log(('\tNumber of loops              : {}').format(self.nbLoop))
        self.log(('\tAller Retour                 : {}').format(self.allerRetour))
        self.log(('\tCapture Duration             : {}').format(
            self.captureDuration))
        self.log(('\tStabilisation time           : {}').format(
            self.STABILISATIONTIME))
        self.log(('\tTraces Collected             : {}').format(self.traceType))
        self.log(('\tDecode hdf to txt            : {}').format(self.hdf2txt))
        self.log(('\tResults on VM (TTI,QCT,logs) : {}').format(self.VM_PATH_TST))
        self.log(('\tLogs Test                    : {}').format(self.logFileName))
        self.log(('\tTraces TTI                   : {}').format(self.VM_PATH_TTI))
        self.log(('\tTraces QCT                   : {}').format(self.VM_PATH_QCT))
        self.log(
            '==============================================================================================\n\n')

    def log(self, mes):
        tmpMes = mes + '\n'
        self.logsTest.write(tmpMes)
        rolb.log(tmpMes, 'INFO')
        rolb.log_to_console(tmpMes)

    def update(self,  testName, trafficType, profile, captureDuration, typeAtten, iatten, fatten, step, nbLoop,
               allerRetour, stabilisationTime, traceType, hdf2txt, timeStamp, vmPathTst):
        self.testName = testName
        self.trafficType = trafficType
        self.profile = profile
        self.captureDuration = captureDuration
        self.typeAtten = typeAtten
        self.iatten = float(iatten)
        self.fatten = float(fatten)
        self.step = float(step)
        self.nbLoop = int(nbLoop)
        self.allerRetour = allerRetour
        self.STABILISATIONTIME = stabilisationTime

        self.traceType = traceType
        self.hdf2txt = hdf2txt

        self.timeStamp = timeStamp
        self.VM_PATH_TST = vmPathTst
        self.VM_PATH_TTI = self.VM_PATH_TST + self.TTI + '/'
        self.VM_PATH_QCT = self.VM_PATH_TST + self.QCT + '/'
        self.ASIK_PATH_TTI = self.ASIK_PATH + self.testName
        self.UE_PATH_QCT = self.UE_5G_TRACES + self.testName

        self.logFileName = self.VM_PATH_TST + self.testName + '.log'
        self.logsTest = open(self.logFileName, 'w')
        self.logsTest.close()
        self.logsTest = open(self.logFileName, 'a')

        # self.getTTItraces = '{} {} {} {}{{}} \\&' . format(
        self.getTTItraces = '{} {} {} {}{{}}' . format(
            self.getTTItraces, str(self.captureDuration), self.testName, self.TTI)
        self.getQCTtraces = '{} -t {} -c {} -s {}/{}{{}}.hdf -x {}' . format(
            self.getQCTtraces, str(self.captureDuration), self.UE_5G_DMC_CONF, self.UE_PATH_QCT, self.QCT, self.hdf2txt)

    def closeLogsTest(self):
        self.logsTest.close()

    def openRecapOutputFiles(self):
        tmpResFileNameDL = self.VM_PATH_TST + 'DL__' + self.testName + '.csv'
        tmpResFileNameUL = self.VM_PATH_TST + 'UL__' + self.testName + '.csv'

        self.DLrecap_output = open(tmpResFileNameDL, 'w')
        self.DLrecap_output.close()
        self.DLrecap_output = open(tmpResFileNameDL, 'a')
        self.DLrecap_output.write(cLA_h1DL + '\n')
        self.DLrecap_output.write(cLA_h2DL + '\n')

        self.ULrecap_output = open(tmpResFileNameUL, 'w')
        self.ULrecap_output.close()
        self.ULrecap_output = open(tmpResFileNameUL, 'a')
        self.ULrecap_output.write(cLA_h1UL + '\n')
        self.ULrecap_output.write(cLA_h2UL + '\n')

    def closeRecapOutputFiles(self):
        self.DLrecap_output.close()
        self.ULrecap_output.close()

    def writeRecapOutputFiles(self, resFileName):
        tmpDlRecapTTIsplit = self.dlRecapTTI.split('|')
        for i in range(len(tmpDlRecapTTIsplit)):
            if (i == 0):
                self.DLrecap_output.write(
                    self.atten + ';' + self.dlRecapQCT + tmpDlRecapTTIsplit[i] + ';' + resFileName + '\n')
            else:
                self.DLrecap_output.write(
                    self.atten + ';' + cLA_DLemptyQCT + tmpDlRecapTTIsplit[i] + ';' + resFileName + '\n')

        tmpUlRecapTTIsplit = self.ulRecapTTI.split('|')
        for i in range(len(tmpUlRecapTTIsplit)):
            if (i == 0):
                self.ULrecap_output.write(
                    self.atten + ';' + self.ulRecapQCT + tmpUlRecapTTIsplit[i] + ';' + resFileName + '\n')
            else:
                self.ULrecap_output.write(
                    self.atten + ';' + cLA_ULemptyQCT + tmpUlRecapTTIsplit[i] + ';' + resFileName + '\n')


def dos2cyg(dir):
    tmpDir = dir
    tmpDir = tmpDir.replace('C:', '/cygdrive/c')
    tmpDir = tmpDir.replace('D:', '/cygdrive/d')
    tmpDir = tmpDir.replace('\\', '/')
    return tmpDir


def removeTraceDir(traceType):
    TEST.log(('\n\tRemove Remote Trace Directory ({}) traces').format(traceType))

    if (traceType == 'T'):
        cde = 'rm -rf ' + TEST.ssh_ASIK.remoteFilePath
        TEST.log(('\t\tDirectory to be removed : {}  ==> {}').format(
            TEST.ssh_ASIK.remoteFilePath, cde))
        TEST.ssh_ASIK.execCmd(cde)

    elif (traceType == 'Q'):
        cde = 'rm -rf ' + dos2cyg(TEST.ssh_PC_UE.remoteFilePath)
        TEST.log(('\t\tDirectory to be removed : {}  ==> {}').format(
            TEST.ssh_PC_UE.remoteFilePath, cde))
        TEST.ssh_PC_UE.execCmd(cde)

    else:
        TEST.log(('\t\t{} : type of trace unknown').format(traceType))


def createTracesDir(traceType):
    TEST.log(('\n\tCreate Remote Trace Directory for ({}) traces :').format(traceType))

    if (traceType == 'T'):
        cde = 'mkdir ' + TEST.ssh_ASIK.remoteFilePath
        TEST.log(('\t\tDirectory to be created : {}  ==> {}').format(
            TEST.ssh_ASIK.remoteFilePath, cde))
        TEST.ssh_ASIK.execCmd(cde)

    elif (traceType == 'Q'):
        cde = 'mkdir ' + dos2cyg(TEST.ssh_PC_UE.remoteFilePath)
        TEST.log(('\t\tDirectory to be created : {}  ==> {}').format(
            TEST.ssh_PC_UE.remoteFilePath, cde))
        TEST.ssh_PC_UE.execCmd(cde)

    else:
        TEST.log(('\t\t{} : type of trace unknown').format(traceType))


# ===============
TEST = DescTest()
# ===============


class ConnectionSSH (object):
    'Class to connect to remote server'

    def __init__(self, host='', userName='', password='', remoteFilePath='', localFilePath='', hostDest='', pkey=''):
        self.sshOutput = None
        self.sshError = None
        self.client = None
        self.host = host
        self.hostDest = hostDest
        self.userName = userName
        self.password = password
        self.timeout = TEST.SSH_TO
        self.pkey = pkey
        self.port = TEST.SSH_PORT
        self.testName = TEST.testName
        self.remoteFilePath = remoteFilePath
        self.localFilePath = localFilePath

    def connectSSH(self):
        try:
            TEST.log('\t\tEstablishing ssh connection ...')

            self.client = paramiko.SSHClient()
            self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

            if (self.password == ''):
                private_key = paramiko.RSAKey.from_private_key_file(self.pkey)
                self.client.connect(
                    hostname=self.host, port=self.port, username=self.userName, pkey=private_key,
                    timeout=self.timeout, allow_agent=False, look_for_keys=False)
            else:
                self.client.connect(hostname=self.host, port=self.port, username=self.userName, password=self.password,
                                    timeout=self.timeout, allow_agent=False, look_for_keys=False)

        except paramiko.AuthenticationException:
            TEST.log('\t\tAuthentication failed, please verify your credentials')
            resFlag = False

        except paramiko.SSHException as sshException:
            TEST.log(
                ('\t\tCould not establish SSH connection : {}').format(sshException))
            resFlag = False

        except socket.timeout as e:
            TEST.log(('\t\tConnection timed out : {}').format(e))
            resFlag = False

        except Exception as e:
            TEST.log(('\t\tException in connecting to the server : {}').format(e))
            resFlag = False
            self.client.close()

        else:
            resFlag = True

        return resFlag

    def connectSSHThroughProxy(self):
        ssh_ASIK_proxy = ConnectionSSH(self.host, self.userName, self.password,
                                       self.remoteFilePath, self.localFilePath)
        ssh_ASIK_proxy.connectSSH()

        proxy = ssh_ASIK_proxy.client
        transport = proxy.get_transport()
        dest_addr = (self.hostDest, 22)
        local_addr = ('127.0.0.1', 10022)

        proxy_transport = transport.open_channel(
            'direct-tcpip', dest_addr, local_addr)
        try:
            self.client = paramiko.SSHClient()
            self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

            if (self.password == ''):
                private_key = paramiko.RSAKey.from_private_key_file(self.pkey)
                self.client.connect(hostname=self.hostDest, port=self.port, username=self.userName, pkey=private_key,
                                    timeout=self.timeout, allow_agent=False, look_for_keys=False, sock=proxy_transport)
            else:
                self.client.connect(hostname=self.hostDest, port=self.port, username=self.userName,
                                    password=self.password, timeout=self.timeout, allow_agent=False,
                                    look_for_keys=False, sock=proxy_transport)

        except paramiko.AuthenticationException:
            TEST.log(
                '\t\tAuthentication failed, please verify your credentials : {}')
            resFlag = False

        except paramiko.SSHException as sshException:
            TEST.log(
                ('\t\tCould not establish SSH connection : {}').format(sshException))
            resFlag = False

        except socket.timeout as e:
            TEST.log(('\t\tConnection timed out : {}').format(e))
            resFlag = False

        except Exception as e:
            TEST.log(('\t\tException in connecting to the server : {}').format(e))
            resFlag = False
            self.client.close()
        else:
            resFlag = True

        return resFlag

    def execCmd(self, cde):
        # TEST.log (('\texecCmd_started : {}').format(datetime.now()))
        self.sshOutput = None
        self.sshError = None
        resFlag = True

        try:
            stdin, stdout, stderr = self.client.exec_command(cde, self.timeout)
            if ('&' not in cde):
                self.sshOutput = stdout.read()
                self.sshError = stderr.read()
                if (self.sshError):
                    TEST.log(
                        ('\t\tProblem occurred while running command  --> {}').format(self.sshError))
                    resFlag = False

        except socket.timeout as e:
            TEST.log(('\t\tCommand timed out : {}').format(e))
            resFlag = False

        except paramiko.SSHException:
            TEST.log(('\t\tFailed to execute the command! : {}').format(cde))
            resFlag = False

        # TEST.log (('\texecCmd_ended : {}').format(datetime.now()))
        return resFlag

    def downloadDir(self):
        resFlag = True
        try:
            sftpclient = self.client.open_sftp()

            dirList = sftpclient.listdir(self.remoteFilePath)
            for file in dirList:
                localFile = self.localFilePath + file
                remoteFile = self.remoteFilePath + '/' + file
                TEST.log(('\t{} --> {}').format(remoteFile, localFile))
                sftpclient.get(remoteFile, localFile)
            sftpclient.close()

        except Exception as e:
            TEST.log(
                ('\t\t{} --> Unable to download the file from remote server').format(self.remoteFilePath))
            TEST.log(('\t\tException :  {}').format(e))
            resFlag = False
            sftpclient.close()

        return resFlag

    def downloadFile(self, file):
        resFlag = True

        localFile = self.localFilePath + file
        remoteFile = self.remoteFilePath + '/' + file
        remoteFile = dos2cyg(remoteFile)

        try:
            sftpclient = self.client.open_sftp()
        except Exception as e:
            TEST.log(
                ('\t\t{} --> Unable to download the file from remote server (sftOpen failed)').format(remoteFile))
            TEST.log(('\t\tException :  {}').format(e))
            resFlag = False
            return resFlag

        time.sleep(5)

        try:
            TEST.log(('\tDownload file : {} --> {}').format(remoteFile, localFile))
            sftpclient.get(remoteFile, localFile)
            time.sleep(2)
            TEST.log(('\tRemove file : {}').format(remoteFile))
            sftpclient.remove(remoteFile)
            time.sleep(1)
            sftpclient.close()

        except Exception as e:
            TEST.log(
                ('\t\t{} --> Unable to download the file from remote server').format(remoteFile))
            TEST.log(('\t\tException :  {}').format(e))
            resFlag = False
            sftpclient.close()

        return resFlag

    def downloadRemoveLastFilesDir(self):
        resFlag = True

        try:
            sftpclient = self.client.open_sftp()
        except Exception as e:
            TEST.log(
                ('\t\t{} --> Unable to open sftp conexion with remote server').format(self.remoteFilePath))
            TEST.log(('\t\tException :  {}').format(e))
            resFlag = False

        if resFlag:
            dirList = sftpclient.listdir(self.remoteFilePath)
            for file in dirList:
                localFile = self.localFilePath + file
                remoteFile = self.remoteFilePath + '/' + file
                remoteFile = dos2cyg(remoteFile)  # ???

                TEST.log(
                    ('\tDownload file : {} --> {}').format(remoteFile, localFile))
                try:
                    sftpclient.get(remoteFile, localFile)
                    time.sleep(2)
                except Exception as e:
                    TEST.log(
                        ('\t\t{} --> Unable to download the file from remote server').format(remoteFile))
                    TEST.log(('\t\tException :  {}').format(e))
                    resFlag = False

                TEST.log(('\tRemove file : {}').format(remoteFile))

                try:
                    sftpclient.remove(remoteFile)
                    time.sleep(1)
                except Exception as e:
                    TEST.log(
                        ('\t\t{} --> Unable to remove the file from remote server').format(remoteFile))
                    TEST.log(('\t\tException :  {}').format(e))
                    resFlag = False

            sftpclient.close()

        return resFlag


def openConnectionASIK():
    resFlag = True
    TEST.log('\n\tOpen Connection SSH ASIK')
    if (TEST.ssh_ASIK is not None):
        TEST.log('\t\tClose previous SSH ASIK')
        TEST.ssh_ASIK.client.close()

    TEST.ssh_ASIK = ConnectionSSH(
        TEST.ASIK_OAM_IP, TEST.ASIK_OAM_LOGIN, TEST.ASIK_OAM_PWD, TEST.ASIK_PATH_TTI, TEST.VM_PATH_TTI)
    if TEST.ssh_ASIK.connectSSH():
        TEST.log(
            ('\t\tuccessfully establish SSH connection to ASIK-ASIB     : {}').format(TEST.ASIK_OAM_IP))
    else:
        TEST.log(
            ('\\t not establish SSH connection to ASIK-ASIB      : {}').format(TEST.ASIK_OAM_IP))
        resFlag = False

    return resFlag


def openConnectionABIL():
    resFlag = True
    TEST.log('\n\tOpen Connection SSH ABIL-ABIO')
    if (TEST.ssh_ASIK_ABIL is not None):
        TEST.log('\t\tClose previous ABIL-ABIO')
        TEST.ssh_ASIK_ABIL.client.close()

    TEST.ssh_ASIK_ABIL = ConnectionSSH(
        TEST.ASIK_OAM_IP, TEST.ASIK_OAM_LOGIN, TEST.ASIK_OAM_PWD, TEST.ASIK_PATH_TTI,
        TEST.VM_PATH_TTI, TEST.ABIL_IP_TTI)
    if TEST.ssh_ASIK_ABIL.connectSSHThroughProxy():
        TEST.log(
            ('\t\tSuccessfully establish SSH connection to ABIL-ABIO     : {}').format(TEST.ABIL_IP_TTI))

    else:
        TEST.log(
            ('\t\tCould not establish SSH connection to ABIL-ABIO      : {}').format(TEST.ABIL_IP_TTI))
        resFlag = False

    return resFlag


def openConnectionPCUE():
    resFlag = True
    TEST.log('\n\tOpen Connection SSH PC UE')
    if (TEST.ssh_PC_UE is not None):
        TEST.log('\t\tClose previous SSH PC UE')
        TEST.ssh_PC_UE.client.close()

    TEST.ssh_PC_UE = ConnectionSSH(
        TEST.PC_UE_IP, TEST.PC_UE_LOGIN, TEST.PC_UE_PWD, TEST.UE_PATH_QCT, TEST.VM_PATH_QCT)
    if TEST.ssh_PC_UE.connectSSH():
        TEST.log(('\t\tSuccessfully establish SSH connection to PC UE    : {}').format(
            TEST.PC_UE_IP))
    else:
        TEST.log(('\t\tCould not establish SSH connection to PC UE   : {}').format(
            TEST.PC_UE_IP))
        resFlag = False

    return resFlag


def openConnectionPCSPIRENT():
    resFlag = True
    TEST.log('\n\tOpen Connection SSH PC SPIRENT')
    if (TEST.ssh_PC_SPIRENT is not None):
        TEST.log('\t\tClose previous SSH PC SPIRENT')
        TEST.ssh_PC_SPIRENT.client.close()

    TEST.ssh_PC_SPIRENT = ConnectionSSH(
        TEST.PC_SPIRENT_IP, TEST.PC_SPIRENT_LOGIN, TEST.PC_SPIRENT_PWD)
    if TEST.ssh_PC_SPIRENT.connectSSH():
        TEST.log(('\t\tSuccessfully establish SSH connection to PC SPIRENT    : {}').format(
            TEST.PC_SPIRENT_IP))
    else:
        TEST.log(('\t\tCould not establish SSH connection to PC SPIRENT   : {}').format(
            TEST.PC_SPIRENT_IP))
        resFlag = False

    return resFlag


def openConnectionSPIRENT():
    resFlag = True

    client = SSHClient()
    client.set_missing_host_key_policy(MissingHostKeyPolicy())
    client.connect(hostname=TEST.PC_SPIRENT_IP,
                   username=TEST.PC_SPIRENT_LOGIN, password=TEST.PC_SPIRENT_PWD)
    transport = client.get_transport()
    tunnel = transport.open_channel(
        'direct-tcpip', (TEST.SPIRENT_IP, 3000), ('127.0.0.1', 0))

    # if  (TEST.tnSpirent is not None):
    #     TEST.log ('\t\tClose previous Telnet Connection Spirent')
    #     TEST.tnSpirent.close ()

    TEST.tnSpirent = telnetlib.Telnet()
    TEST.tnSpirent.sock = tunnel
    # res = TEST.ssh_PC_SPIRENT.tnSpirent.open(str(TEST.SPIRENT_IP), int(TEST.SPIRENT_PORT), 5)
    # TEST.log (('\t\tSuccessfully establish Telnet Connection Spirent   : {}').format(TEST.SPIRENT_IP))

    return resFlag


def openConnections():
    resFlag = True
    resFlag = openConnectionASIK()

    if (resFlag):
        resFlag = openConnectionABIL()

        if (resFlag):
            resFlag = openConnectionPCUE()

            if (resFlag):
                resFlag = openConnectionPCSPIRENT()

                if (resFlag):
                    resFlag = openConnectionSPIRENT()

    return resFlag


def closeConnections():
    TEST.log('\nClose Connections SSH & Telnet :')

    if (TEST.ssh_ASIK_ABIL is not None):
        TEST.log('\tClose SSH Connection ABIL-ABIO')
        TEST.ssh_ASIK_ABIL.client.close()

    if (TEST.ssh_ASIK is not None):
        TEST.log('\tClose SSH Connection ASIK-ASIB')
        TEST.ssh_ASIK.client.close()

    if (TEST.ssh_PC_UE is not None):
        TEST.log('\tClose SSH Connection PC UE')
        TEST.ssh_PC_UE.client.close()

    if (TEST.tnSpirent is not None):
        TEST.log('\tClose Telnet Connection Spirent')
        TEST.tnSpirent.close()


def startSpirentInitialConf():
    TEST.log('\nStart Spirent Initial configuration')

    resFlag = True

    setSpirentInitialConf()

    # TEST.tnSpirent.write ('SYST:PLAY' + b'\r\n')
    # time.sleep (0.5)

    if TEST.typeAtten == 'CN':
        TEST.tnSpirent.write(
            ('SYST:PORT:' + TEST.spirentOutputPortsDL + ':INTerferer:MOD ON\r\n').encode('ascii'))
        time.sleep(0.5)

    setAtten(TEST.iatten)

    tmpWaitTime = 20
    TEST.log(('\tWait Spirent Stabilisation : ({})').format(tmpWaitTime))
    time.sleep(float(tmpWaitTime))

    return resFlag


def setSpirentInitialConf():
    TEST.log('\tSet Spirent Initial configuration')

    resFlag = True

    setPower(TEST.iattenPwr)
    setCn(TEST.iattenCN)

    # TEST.tnSpirent.write (('SYST:STOP\r\n').encode('ascii'))
    # time.sleep (0.5)
    TEST.tnSpirent.write(('SYST:PORT:' + TEST.spirentOutputPortsDL +
                         ':INTerferer:MOD OFF\r\n').encode('ascii'))
    TEST.log('END SETTING INTerferer:MOD OFF')

    time.sleep(0.5)

    return resFlag


def setAtten(atten):
    if TEST.typeAtten == 'Pwr':
        setPower(atten)
    elif TEST.typeAtten == 'CN':
        setCn(atten)
    else:
        TEST.log(('\n\tLA DL/UL Atten : ({})  unknown)').format(TEST.typeAtten))
    time.sleep(float(TEST.STABILISATIONTIME))


def setPower(power):
    str_power = str(power)

    TEST.tnSpirent.write(('SYST:PORT:' + TEST.spirentOutputPortsDL +
                         ':OUTPut -' + str_power + '\r\n').encode('ascii'))
    time.sleep(0.5)
    TEST.tnSpirent.write(('SYST:PORT:' + TEST.spirentOutputPortsUL +
                         ':OUTPut -' + str_power + '\r\n').encode('ascii'))
    time.sleep(0.5)


def setCn(cn):
    str_cn = str(cn)
    TEST.tnSpirent.write(
        ('SYST:PORT:' + TEST.spirentOutputPortsDL + ':INTerferer:CTON ' + str_cn + '\r\n').encode('ascii'))
    time.sleep(0.5)
    TEST.tnSpirent.write(
        ('SYST:PORT:' + TEST.spirentOutputPortsUL + ':INTerferer:CTON ' + str_cn + '\r\n').encode('ascii'))
    time.sleep(0.5)


def downloadAnalyseTracesTTI_QCT(resFileName):
    TEST.dlRecapTTI = cLA_DLemptyTTI
    TEST.ulRecapTTI = cLA_ULemptyTTI
    if TEST.traceType in ['T', 'TQ', 'QT']:
        ttiFileName = TEST.TTI + resFileName + '_dl.csv'
        if (TEST.ssh_ASIK_ABIL.downloadFile(ttiFileName)):
            fullTtiFileName = TEST.ssh_ASIK_ABIL.localFilePath + ttiFileName
            TEST.log(('\tParsing file : {}').format(fullTtiFileName))
            tmpTTI_DL, tmpTTI_UL = parserTTI(fullTtiFileName)
            if (len(tmpTTI_DL) == 0):
                TEST.dlRecapTTI = cLA_DLemptyTTI
            else:
                TEST.dlRecapTTI = tmpTTI_DL
            TEST.log(('\t\tResult Parsing DL : {}').format(TEST.dlRecapTTI))

        ttiFileName = TEST.TTI + resFileName + '_ul.csv'
        if (TEST.ssh_ASIK_ABIL.downloadFile(ttiFileName)):
            fullTtiFileName = TEST.ssh_ASIK_ABIL.localFilePath + ttiFileName
            TEST.log(('\tParsing file : {}').format(fullTtiFileName))
            tmpTTI_DL, tmpTTI_UL = parserTTI(fullTtiFileName)
            if (len(tmpTTI_UL) == 0):
                TEST.ulRecapTTI = cLA_ULemptyTTI
            else:
                TEST.ulRecapTTI = tmpTTI_UL
            TEST.log(('\t\tResult Parsing UL : {}').format(TEST.ulRecapTTI))

    TEST.dlRecapQCT = cLA_DLemptyQCT
    TEST.ulRecapQCT = cLA_ULemptyQCT
    if TEST.traceType in ['Q', 'TQ', 'QT']:
        qctFileName = TEST.QCT + resFileName + '.txt'
        if (TEST.ssh_PC_UE.downloadFile(qctFileName)):
            fullQctFileName = TEST.ssh_PC_UE.localFilePath + qctFileName
            TEST.log(('\tParsing file : {}').format(fullQctFileName))
            TEST.dlRecapQCT, TEST.ulRecapQCT = parserQCT(fullQctFileName)
            TEST.log(('\t\tResult Parsing DL : {}').format(TEST.dlRecapQCT))
            TEST.log(('\t\tResult Parsing UL : {}').format(TEST.ulRecapQCT))

    TEST.writeRecapOutputFiles(resFileName)


def LA_DLUL_atten(atten, nbL, direction):
    TEST.log(
        ('\n\nLA DL/UL Atten : Loop ({})  Direction ({}) atten ({})').format(nbL, direction, atten))

    setAtten(atten)
    TEST.nbResFile += 1

    TEST.atten = '{:0>5.2f}'.format(abs(atten-TEST.iatten))
    resFileName = '_{:0>3d}_{:0>2d}_{:s}_{:0>5.2f}_{:s}'.format(
        TEST.nbResFile, nbL, direction, atten, TEST.atten)

    if TEST.traceType in ['T', 'TQ', 'QT']:
        resFlag = openConnectionABIL()
        cmdTTItraces = TEST.getTTItraces.format(resFileName)
        TEST.log(('\tTTI traces : {}').format(cmdTTItraces))
        TEST.log(('\tTTI traces started : {}').format(datetime.now()))
        TEST.ssh_ASIK_ABIL.execCmd(cmdTTItraces)

    if TEST.traceType in ['Q', 'TQ', 'QT']:
        resFlag = openConnectionPCUE()
        cmdQCTtraces = TEST.getQCTtraces.format(resFileName)
        TEST.log(('\tQCT traces : {}').format(cmdQCTtraces))
        TEST.log(('\tQCT traces started : {}').format(datetime.now()))
        TEST.ssh_PC_UE.execCmd(cmdQCTtraces)

    if TEST.traceType not in ['Q', 'TQ', 'QT']:
        tmpWaitTime = 30
        TEST.log(('\tWait end of traces : ({})').format(tmpWaitTime))
        time.sleep(float(tmpWaitTime))

    downloadAnalyseTracesTTI_QCT(resFileName)


def getTracesTTI_QCT(testName='Test', trafficType='DL', profile='AWGN', typeAtten='Pwr', iatten=45, fatten=45,
                     step=1, nbLoop=1, allerRetour='A', stabilisationTime=2, captureDuration=10, traceType='T',
                     hdf2txt='Y', timeStamp="", vmPathTst=""):
    if (timeStamp == ''):
        timeStamp = TEST.timeStamp

    if (vmPathTst == ''):
        vmPathTst = TEST.VM_PATH + trafficType + '_' + testName + TEST.timeStamp + '/'

        print('\nCreate Local Trace Directory for (TTI & QCT) and logs :')
        print(('\tDirectory to be created : {}').format(vmPathTst))
        try:
            os.mkdir(vmPathTst)
        except Exception as e:
            print(
                ('\t\t{} --> Unable to Create Trace Directory for (TTI & QCT) and logs').format(vmPathTst))
            print(('\t\tException:  {}').format(e))
            sys.exit(1)

    TEST.update(testName, trafficType, profile, captureDuration, typeAtten, iatten, fatten, step, nbLoop, allerRetour,
                stabilisationTime, traceType, hdf2txt, timeStamp, vmPathTst)
    TEST.imprimerLog()

    resFlag = openConnections()

    if resFlag:
        if TEST.traceType in ['T', 'TQ', 'QT']:
            removeTraceDir('T')
            createTracesDir('T')

            TEST.log('\nCreate Local Trace Directory for (T) traces :')
            TEST.log(('\tDirectory to be created : {}').format(TEST.VM_PATH_TTI))

            try:
                os.mkdir(TEST.VM_PATH_TTI)
            except Exception as e:
                TEST.log(
                    ('\t\t{} --> Unable to Trace Directory for (T) traces').format(TEST.VM_PATH_TTI))
                TEST.log(('\t\tException:  {}').format(e))
                return

        if TEST.traceType in ['Q', 'TQ', 'QT']:
            removeTraceDir('Q')
            createTracesDir('Q')

            TEST.log('\nCreate Local Trace Directory for (Q) traces :')
            TEST.log(('\tDirectory to be created : {}').format(TEST.VM_PATH_QCT))
            try:
                os.mkdir(TEST.VM_PATH_QCT)
            except Exception as e:
                TEST.log(
                    ('\t\t{} --> Unable to Create Local Trace Directory for (Q) traces').format(TEST.VM_PATH_QCT))
                TEST.log(('\t\tException :  {}').format(e))
                return

        TEST.log(
            '\n\n--------------------------------------------------------------------------------------------')
        TEST.log(('LA DL-UL : from Initial ({}) to Final ({}) atten..., Number of Loops ({})  Direction ({})')
                 .format(TEST.iatten, TEST.fatten, TEST.nbLoop, TEST.allerRetour))
        TEST.log(
            '--------------------------------------------------------------------------------------------')

        TEST.openRecapOutputFiles()

        startSpirentInitialConf()
        for loop in range(TEST.nbLoop):
            TEST.log(('\nLoop Number ({})').format(loop+1))
            TEST.log(('\nLoop from initial {} to final {} atten...').format(
                TEST.iatten, TEST.fatten))

            atten = TEST.iatten
            LA_DLUL_atten(atten, loop+1, 'A')

            if TEST.iatten < TEST.fatten:
                while ((atten + TEST.step) <= TEST.fatten):
                    atten = atten + TEST.step
                    LA_DLUL_atten(atten, loop+1, 'A')

                if (TEST.allerRetour == 'AR'):
                    TEST.log('\n\nback from final={} to initial={} atten'.format(
                        TEST.fatten, TEST.iatten))
                    while ((atten - TEST.step) >= TEST.iatten):
                        atten = atten - TEST.step
                        LA_DLUL_atten(atten, loop+1, 'R')

            elif TEST.iatten > TEST.fatten:
                while ((atten-TEST.step) >= TEST.fatten):
                    atten = atten - TEST.step
                    LA_DLUL_atten(atten, loop+1, 'A')
                if (TEST.allerRetour == 'AR'):
                    TEST.log('\n\nback from final={} to initial={} atten'.format(
                        TEST.fatten, TEST.iatten))
                    while ((atten + TEST.step) <= TEST.iatten):
                        atten = atten + TEST.step
                        LA_DLUL_atten(atten, loop+1, 'R')

        TEST.closeRecapOutputFiles()

        setSpirentInitialConf()

        openConnectionASIK()
        removeTraceDir('T')

        openConnectionPCUE()
        removeTraceDir('Q')

        closeConnections()

    else:
        TEST.log('\n\tOpen Connections SSH & Telnet ==> NOK')

    TEST.closeLogsTest()


if __name__ == '__main__':
    getTracesTTI_QCT(
        testName='test_t1', trafficType='DL', profile='AWGNdl', typeAtten='Pwr', iatten=14, fatten=17, step=0.5,
        nbLoop=1, allerRetour='A', stabilisationTime=2, captureDuration=10, traceType='TQ', hdf2txt='Y',
        timeStamp=datetime.now().strftime("_%Y%m%d_%H%M%S"), vmPathTst='/tmp/')

    # parser = argparse.ArgumentParser()
    # parser.add_argument('iatten', type=int,
    # help='initial atten')
    # parser.add_argument('fatten', type=int,
    # help='final atten')
    # parser.add_argument('-ta', '--typeAtten', type=str,
    # help='typeAtten')
    # parser.add_argument('-tn', '--testName', type=str,
    # help='testName')
    # parser.add_argument('-tr', '--trafficType', type=str,
    # help='trafficType')
    # parser.add_argument('-pr', '--profile', type=str,
    # help='profile')
    # parser.add_argument('-s', '--step', type=float,
    # help='step')
    # parser.add_argument('-nl', '--nbLoop', type=int,
    # help='number of Loops')
    # parser.add_argument('-ar', '--allerRetour', type=str,
    # help='allerRetour [A,AR]')
    # parser.add_argument('-st', '--stabilisationTime', type=int,
    # help='stabilisationTime')
    # parser.add_argument('-cd','--captureDuration', type=int,
    # help='trace duration in ms (ex: 10s ==> 10)')
    # parser.add_argument('-tt', '--traceType', type=str,
    # help='traceType [T,Q,TQ] ==> [TTI, QCT, TTI+QCT]')
    # parser.add_argument('-x', '--hdf2txt', type=str,
    # help='convert hdf 2 Txt [Y/N]')
    # parser.add_argument('-ts', '--timeStamp', type=str,
    # help='timeStamp')
    # parser.add_argument('-vmpt', '--vmPathTst', type=str,
    # help='vmPathTst')
    # args = parser.parse_args()

    # iatten = args.iatten
    # fatten = args.fatten

    # if args.typeAtten:
    # typeAtten=args.typeAtten
    # else:
    # typeAtten=TEST.typeAtten

    # if args.testName:
    # testName=args.testName
    # else:
    # testName=TEST.testName

    # if args.trafficType:
    # trafficType=args.trafficType
    # else:
    # trafficType=TEST.trafficType

    # if args.profile:
    # profile=args.profile
    # else:
    # profile=TEST.profile

    # if args.step:
    # step = args.step
    # else:
    # step=TEST.step

    # if args.nbLoop:
    # nbLoop=args.nbLoop
    # else:
    # nbLoop = TEST.nbLoop

    # if args.allerRetour:
    # allerRetour=args.allerRetour
    # else:
    # allerRetour = TEST.allerRetour

    # if args.stabilisationTime:
    # stabilisationTime=args.stabilisationTime
    # else:
    # stabilisationTime = TEST.STABILISATIONTIME

    # if args.captureDuration:
    # captureDuration = args.captureDuration
    # else:
    # captureDuration = TEST.captureDuration

    # if args.traceType:
    # traceType=args.traceType
    # else:
    # traceType = TEST.traceType

    # if args.hdf2txt:
    # hdf2txt=args.hdf2txt
    # else:
    # hdf2txt = TEST.hdf2txt

    # if args.timeStamp:
    # timeStamp=args.timeStamp
    # else:
    # timeStamp = TEST.timeStamp

    # if args.vmPathTst:
    # vmPathTst=args.vmPathTst
    # else:
    # vmPathTst = ''

    # getTracesTTI_QCT(testName, trafficType, profile, typeAtten, iatten, fatten, step, nbLoop, allerRetour,
    # stabilisationTime, captureDuration, traceType, hdf2txt, timeStamp, vmPathTst)
