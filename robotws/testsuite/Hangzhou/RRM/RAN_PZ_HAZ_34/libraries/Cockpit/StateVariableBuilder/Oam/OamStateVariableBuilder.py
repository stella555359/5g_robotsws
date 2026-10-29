import time
import os
import json
import socket
import threading
import calendar
import pysftp
import traceback
import struct
from ...utilities.SshConnection import SshConnection
from taf.gnb.oam.megazone_client.interface import megazone_client
from taf.gnb.oam.megazone_client.session import *
from ...Cockpit_Debug import debugWrite


class TimeoutException(Exception):
    pass


class OamStateVariableBuilder:
    def __init__(self, tlInfo, swModule, configFolder, tcpDestIp, tcpDestPort):
        self._tlInfo = tlInfo
        self._swModule = swModule
        self._sourceIp = tlInfo["oam-0"]["hostname"]
        self._sourceUser = tlInfo["oam-0"]["username"]
        self._sourcePassword = tlInfo["oam-0"]["password"]
        self._configFolder = configFolder
        try:
            os.makedirs(configFolder)
        except OSError:
            pass

        self._tcpDestIp = tcpDestIp
        self._tcpDestPort = tcpDestPort
        self._outSock = socket.socket(
            socket.AF_INET, socket.SOCK_STREAM)  # TCP
        self._outSock.connect((self._tcpDestIp, self._tcpDestPort))
        self._lastValue = {}
        self._eventStop = False
        # self._cnopts = pysftp.CnOpts()
        # self._cnopts.hostkeys = None
        self._cnopts = None
        self._transferredFile = []
        self._traceCollection = {}

        # if "oam-0" in swModule:
        #    self._destFolder = self._configFolder + "BB3/"
        #    try:
        #        os.makedirs(self._destFolder)
        #    except FileExistsError:
        #        pass
        #
        # if "upue-0" in swModule:
        #    self._destFolder = self._configFolder + "BB3/"
        #
        # if "rtm" in swModule:
        #    self._destFolder = self._configFolder + "BB2/"
        #    try:
        #        os.makedirs(self._destFolder)
        #    except FileExistsError:
        #        pass
        #
        # if "rap01" in swModule:
        #    self._destFolder = self._configFolder + "BB1/RAP01/"
        #    try:
        #        os.makedirs(self._destFolder)
        #    except FileExistsError:
        #        pass
        #
        # if "fspj-1a" in swModule:
        #    self._destFolder = self._configFolder + "BB1/ABIK/"
        #    try:
        #        os.makedirs(self._destFolder)
        #    except FileExistsError:
        #        pass
        #
        # if "abil" in swModule:
        #    self._destFolder = self._configFolder + "BB1/ABIL/"
        #    try:
        #        os.makedirs(self._destFolder)
        #    except FileExistsError:
        #        pass
        #
        # if "ru" in swModule:
        #    self._destFolder = self._configFolder + "RU/"
        #    try:
        #        os.makedirs(self._destFolder)
        #    except FileExistsError:
        #        pass
        #
        # if "egate" in swModule:
        #    self._destFolder = self._configFolder + "EGATE/"
        #    try:
        #        os.makedirs(self._destFolder)
        #    except FileExistsError:
        #        pass
        #
        #
        debugWrite("OamStateVariableBuilder: launching _mainLoop")
        threading.Thread(target=self._mainLoop).start()

    def _analyzeSCF(self, SCF_data):
        itemValue = SCF_data.replace("\n", "")
        traceDict = self._getTraceDict("configuration")
        self._storeItem(traceDict, "state.oam.scf", itemValue)
        self._flushTrace(traceDict)

    def _analyzeFiles(self):
        # os.makedirs(self._destFolder, exist_ok=True)
        # self._retrieveFiles()
        fileIn = open("%s/5G18A_VendorFile.xml" % self._destFolder, "r")
        traceDict = self._getTraceDict("message")
        for lineIn in fileIn.readlines():
            lineIn = lineIn.strip()
            if lineIn.startswith('<p name="') and lineIn.endswith('</p>'):
                # <p name="dtxThresholdPUSCH1Tx2RxRBG_01">2506</p>
                itemName = lineIn.split('"')[1]
                itemValue = lineIn.split('>')[1][:-3]
                self._storeItem(traceDict, "state.oam." + itemName, itemValue)
        self._flushTrace(traceDict, minNumber=4)
        fileIn.close()

    def stop(self):
        self._eventStop = True
        self._outSock.close()

    def _retrieveFiles(self):
        sftpConn = pysftp.Connection(
            host=self._sourceIp,
            username=self._sourceUser,
            password=self._sourcePassword,
            cnopts=self._cnopts)

        sftpConn.get(
            "/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G18A_VendorFile.xml",
            "%s/5G18A_VendorFile.xml" %
            self._destFolder)

        sftpConn.get(
            "/opt/nokia/SS_MzOam/cloud-racoam/racoam/config/cloud.json",
            "%s/cloud.json" %
            self._destFolder)
        # Closes the connection
        sftpConn.close()

    def _getconfigFiles(self, sshConnection=None, config_file_list=[]):
        for cfgfilepath in config_file_list:
            # cfgpath = PurePosixPath(cfgfilepath)
            print(cfgpath)
            p = cfgpath.parts
            n = len(p)
            try:
                sftp = sshConnection.open_sftp()
                sftp.get(cfgfilepath, self._destFolder + '/' + p[n - 1])
            except Exception:
                print("Exception in sftp\n" + str(self._tlInfo) + "\n" +
                      self._swModule + cfgfilepath + "\nEnd of Exception")
            print("Closing connection")
            sftp.close()

    def _getSWversion(self, sshConnection=None, cmd_list=[], pattern_list=[]):
        for cmd, pattern in zip(cmd_list, pattern_list):
            print("Get Software Version")
            try:
                stdin, stdout, stderr = sshConnection.exec_command(cmd)
                out_lines = stdout.readlines()
                err_lines = stderr.readlines()
                out_resp = ''.join(out_lines)
                err_resp = ''.join(err_lines)
                print("stdout=%s" % out_resp)
                print("stderr=%s" % err_resp)
                print(
                    "Opening " +
                    self._configFolder +
                    "/" +
                    "Cmd_SW_Version.txt")
                outFile = open(
                    self._configFolder +
                    "/" +
                    "Cmd_SW_Version.txt",
                    "a")
                outFile.write(
                    "%s \nThe result of the command %s is:\n%s\n" %
                    (pattern, cmd, out_resp))
                if err_resp != "":
                    outFile.write(
                        "\nThe command %s is in error:\n%s\n" %
                        (cmd, err_resp))
            except Exception:
                print("Exception in command: %s\n" +
                      str(self._tlInfo) + self._swModule % (cmd))
            outFile.close()

    def _flushTrace(self, traceItem, minNumber=0):
        if len(traceItem) >= minNumber:
            jsonMsg = json.dumps(traceItem)
            jsonMsg = struct.pack('>I', len(jsonMsg)) + jsonMsg.encode('utf-8')
            self._outSock.send(jsonMsg)
            # print(jsonMsg)

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

    def _fillTraceDictHeader(self, traceDict, timestamp, timeEpoch, trigger):
        traceDict["frame.timestamp"] = timestamp
        traceDict["frame.time_epoch"] = timeEpoch
        traceDict["frame.traceType"] = "oam"
        traceDict["frame.trigger"] = trigger

    def _getTraceDict(self, trigger):
        timeStruct = time.gmtime()

        # print("timeStruct", timeStruct)
        # PRONTO 335783 [5G18A][ASIK/ABIK] Asik slave is not synchronized (NTP)
        secondsEpoch = round(calendar.timegm(timeStruct)) - 100000000
        fractionSecond = "0"
        localTime = time.strftime(
            "%Y/%m/%d %H:%M:%S",
            time.localtime(secondsEpoch))
        timestamp = localTime + "." + fractionSecond
        timeEpoch = str(secondsEpoch) + "." + fractionSecond

        traceDict = {}
        self._fillTraceDictHeader(traceDict, timestamp, timeEpoch, trigger)

        return traceDict

    def _mainLoop(self):
        print("OamStateVariableBuilder._mainLoop started for ", self._swModule)
        try:
            while not self._eventStop:
                try:
                    print(
                        "Trying connection to ",
                        self._tlInfo,
                        self._swModule)
                    sshConnection = SshConnection()
                    sshConnection.connect(self._tlInfo, self._swModule)
                    print("Connected to ", self._tlInfo, self._swModule)
                    break
                except Exception:
                    print("Exception in OamStateVariableBuilder\n" +
                          traceback.format_exc() +
                          "\n" +
                          str(self._tlInfo) +
                          "\n" +
                          self._swModule +
                          "\nEnd of Exception")
                    time.sleep(1)

            try:
                # Connecting to AnotherMachine and executing... anything...
                if "gNodeB" in self._tlInfo["type"]:
                    if "oam-0" in self._swModule:

                        try:
                            base_url = "https://" + \
                                self._tlInfo["oam-0"]["hostname"] + "/"
                            # print(base_url)
                            megazone_client.create_session(
                                self, base_url=base_url, user='Nemuadmin', password='nemuuser', port=None)
                            # print("megazone_client create session OK")
                            megazone_swversion = megazone_client.get_sw_version(
                                self)
                            # print(megazone_swversion)
                            outFile = open(
                                self._configFolder + "/" + "WebUI_SW_Version.txt", "a")
                            outFile.write(megazone_swversion)
                            scf_config = megazone_client.get_current_scf_content(
                                self)
                            outFile = open(
                                self._destFolder + "/" + time.strftime("SCF_%Y%m%d-%H%M%S.xml"), "a")
                            outFile.write(scf_config)
                            outFile.close()
                            self._analyzeSCF(scf_config)
                        except Exception:
                            # print("Exception has occurred using megazone_client")
                            pass
                        config_file_list = [
                            '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G18A_VendorFile.xml',
                            '/opt/nokia/SS_MzOam/cloud-racoam/racoam/config/cloud.json']
                        self._getconfigFiles(
                            sshConnection=sshConnection,
                            config_file_list=config_file_list)

                        cmd_list = [
                            'cat /etc/system-release',
                            'cat /etc/system-sw-version']
                        pattern_list = ["BB3:", "BB3:"]
                        self._getSWversion(
                            sshConnection=sshConnection,
                            cmd_list=cmd_list,
                            pattern_list=pattern_list)

                    if "upue-0" in self._swModule:
                        config_file_list = ['/var/preserve/swconfig.txt']
                        self._getconfigFiles(
                            sshConnection=sshConnection,
                            config_file_list=config_file_list)

                    if "rtm" in self._swModule:
                        config_file_list = [
                            '/etc/systemd/network/05-eth0.network',
                            '/etc/ntp_common.conf',
                            '/var/preserve/swconfig.txt',
                            '/var/preserve/feature_log_activation.txt']
                        self._getconfigFiles(
                            sshConnection=sshConnection,
                            config_file_list=config_file_list)

                        cmd_list = [
                            'cat /etc/system-release',
                            'strings /opt/nokia/lib64/lib/libl2ps.so | grep release']
                        pattern_list = ["BB2:", "BB2_L2-PS git version:"]
                        self._getSWversion(
                            sshConnection=sshConnection,
                            cmd_list=cmd_list,
                            pattern_list=pattern_list)

                    if "rap01" in self._swModule:
                        config_file_list = [
                            '/ffs/run/swconfig.txt',
                            '/ffs/run/config/fsp/swconfig_local.txt']
                        self._getconfigFiles(
                            sshConnection=sshConnection,
                            config_file_list=config_file_list)

                        cmd_list = [
                            'cat /ffs/run/TargetBD_5G*.xml | grep -i release',
                            'cat /etc/fsmpsl_version']
                        pattern_list = ["BB1_ASIK:", "BB1_ASIK LFS Version:"]
                        self._getSWversion(
                            sshConnection=sshConnection,
                            cmd_list=cmd_list,
                            pattern_list=pattern_list)

                    if "fspj-1a" in self._swModule:
                        config_file_list = [
                            '/ffs/run/swconfig.txt',
                            '/ffs/run/config/fsp/swconfig_local.txt']
                        self._getconfigFiles(
                            sshConnection=sshConnection,
                            config_file_list=config_file_list)

                        cmd_list = [
                            'cat /tmp/FSP-123A*.log | grep VIP/L1_SW_VERSION',
                            'fpga-cli regr 0 0x1004; fpga-cli regr 1 0x1004',
                            'fpga-cli regr 2 0x1004',
                            'cat /sys/bus/i2c/devices/0-0031/fpga_version',
                            'cat /etc/fsmpsl_version']
                        pattern_list = [
                            "BB1 ABIK L1 K2 Version:",
                            "BB1 ABIK Codec Version:",
                            "BB1 ABIK FE Version:",
                            "BB1 ABIK BMUQr Version:",
                            "BB1 ABIK LFS Version:"]
                        self._getSWversion(
                            sshConnection=sshConnection,
                            cmd_list=cmd_list,
                            pattern_list=pattern_list)

                    if "abil" in self._swModule:
                        config_file_list = [
                            '/ffs/run/swconfig.txt',
                            '/ffs/run/config/fsp/swconfig_local.txt']
                        self._getconfigFiles(
                            sshConnection=sshConnection,
                            config_file_list=config_file_list)

                        cmd_list = [
                            'fpga_rw ra 0xDF020000; fpga_rw ra 0xDF020000; fpga_rw ra 0xDF020000;'
                            ' fpga_rw ra 0xDF020000; fpga_rw ra 0xDF020000; fpga_rw ra 0xDF020000',
                            'cat /etc/os-release',
                            '/usr/bin/i2c_rw r 0 0x33 0 1; /usr/bin/i2c_rw r 0 0x33 3 1',
                            'cat /etc/fsmpsl_version']
                        pattern_list = [
                            "BB1 ABIL FPGA Register:",
                            "BB1 ABIL Loner version:",
                            "BB1 ABIL Loner BMU version:",
                            "BB1 ABIL LFS Version:"]
                        self._getSWversion(
                            sshConnection=sshConnection,
                            cmd_list=cmd_list,
                            pattern_list=pattern_list)

                    if "ru" in self._swModule:
                        config_file_list = ['/mnt/runtime/swconfig_local.txt']
                        self._getconfigFiles(
                            sshConnection=sshConnection,
                            config_file_list=config_file_list)

                        cmd_list = ['cat /etc/version']
                        pattern_list = ["RU AEQA:"]
                        self._getSWversion(
                            sshConnection=sshConnection,
                            cmd_list=cmd_list,
                            pattern_list=pattern_list)

                if "UE AirPhone" in self._tlInfo["type"]:
                    if "oam-0" in self._swModule:
                        cmd_list = ['cat /etc/system-release']
                        pattern_list = ["BB3:"]
                        self._getSWversion(
                            sshConnection=sshConnection,
                            cmd_list=cmd_list,
                            pattern_list=pattern_list)

                    if "rtm" in self._swModule:
                        config_file_list = [
                            '/mnt/services/OamAgent-distro/rtm.xml',
                            '/mnt/services/OamAgentJs-distro/network.json',
                            '/etc/systemd/network/05-eth0.network',
                            '/opt/AirPhone/5g_uec/ue_config.xml',
                            '/opt/AirPhone/L3/L3Cfg.xml',
                            '/opt/AirPhone/L2/ApOamConfig.xml',
                            '/opt/AirPhone/L2/L2config.xml',
                            '/opt/AirPhone/L2/SubCellBFGroupConfig.xml',
                            '/opt/AirPhone/L2/UeConfig.xml',
                            '/var/preserve/swconfig.txt']
                        self._getconfigFiles(
                            sshConnection=sshConnection,
                            config_file_list=config_file_list)

                        cmd_list = ['cat /etc/system-release']
                        pattern_list = ["BB2:"]
                        self._getSWversion(
                            sshConnection=sshConnection,
                            cmd_list=cmd_list,
                            pattern_list=pattern_list)

                    if "rap01" in self._swModule:
                        config_file_list = [
                            '/ffs/run/swpool/5G/L1CTRLNODE/addons/5gl1sw_56220224.tgz',
                            '/ffs/run/swconfig.txt',
                            '/ffs/run/config/fsp/swconfig_local.txt']
                        self._getconfigFiles(
                            sshConnection=sshConnection,
                            config_file_list=config_file_list)

                        cmd_list = [
                            'cat /ffs/run/TargetBD_5G*.xml | grep -i release',
                            'cat /etc/fsmpsl_version']
                        pattern_list = [
                            "BB1_ASIx(ASIA or ASIK):",
                            "BB1_ASIx(ASIA or ASIK) LFS Version:"]
                        self._getSWversion(
                            sshConnection=sshConnection,
                            cmd_list=cmd_list,
                            pattern_list=pattern_list)

                    if "fspj-1a" in self._swModule:
                        config_file_list = [
                            '/ffs/run/swpool/5G/L1CTRLNODE/addons/5gl1sw_56220224.tgz',
                            '/ffs/run/swconfig.txt',
                            '/ffs/run/config/fsp/swconfig_local.txt']
                        self._getconfigFiles(
                            sshConnection=sshConnection,
                            config_file_list=config_file_list)

                        cmd_list = [
                            'cat /tmp/FSP-123A*.log | grep VIP/L1_SW_VERSION',
                            'fpga-cli regr 0 0x1004; fpga-cli regr 1 0x1004',
                            'fpga-cli regr 2 0x1004',
                            'cat /sys/bus/i2c/devices/0-0031/fpga_version',
                            'cat /etc/fsmpsl_version']
                        pattern_list = [
                            "BB1 ABIK L1 K2 Version:",
                            "BB1 ABIK Codec Version:",
                            "BB1 ABIK FE Version:",
                            "BB1 ABIK BMUQr Version:",
                            "BB1 ABIK LFS Version:"]
                        self._getSWversion(
                            sshConnection=sshConnection,
                            cmd_list=cmd_list,
                            pattern_list=pattern_list)

                    if "abil" in self._swModule:
                        config_file_list = [
                            '/ffs/run/swconfig.txt',
                            '/ffs/run/config/fsp/swconfig_local.txt']
                        self._getconfigFiles(
                            sshConnection=sshConnection,
                            config_file_list=config_file_list)

                        cmd_list = [
                            'fpga_rw ra 0xDF020000; fpga_rw ra 0xDF020000; fpga_rw ra 0xDF020000;'
                            ' fpga_rw ra 0xDF020000; fpga_rw ra 0xDF020000; fpga_rw ra 0xDF020000',
                            'cat /etc/os-release',
                            '/usr/bin/i2c_rw r 0 0x33 0 1; /usr/bin/i2c_rw r 0 0x33 3 1',
                            'cat /etc/fsmpsl_version']
                        pattern_list = [
                            "BB1 ABIL FPGA Register:",
                            "BB1 ABIL Loner version:",
                            "BB1 ABIL Loner BMU version:",
                            "BB1 ABIL LFS Version:"]
                        self._getSWversion(
                            sshConnection=sshConnection,
                            cmd_list=cmd_list,
                            pattern_list=pattern_list)

                    if "ru" in self._swModule:
                        config_file_list = ['/mnt/runtime/swconfig_local.txt']
                        self._getconfigFiles(
                            sshConnection=sshConnection,
                            config_file_list=config_file_list)

                        cmd_list = ['cat /etc/version']
                        pattern_list = ["RU AEQA:"]
                        self._getSWversion(
                            sshConnection=sshConnection,
                            cmd_list=cmd_list,
                            pattern_list=pattern_list)

                    if "egate" in self._swModule:
                        config_file_list = [
                            '/home/ute/5g_uec/basic_cfg_5guec.lua']
                        self._getconfigFiles(
                            sshConnection=sshConnection,
                            config_file_list=config_file_list)

                sshConnection.close()
            except Exception:
                print("Exception in OamStateVariableBuilder\n" +
                      str(self._tlInfo) +
                      "\n" +
                      self._swModule +
                      "\nEnd of Exception")

            # self._analyzeFiles()

        except Exception:
            print(
                "Exception in OamStateVariableBuilder\n" +
                traceback.format_exc(
                    limit=5))
        print("OamStateVariableBuilder._mainLoop stopped")
