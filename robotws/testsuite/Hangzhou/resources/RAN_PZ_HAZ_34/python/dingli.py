# -*- coding: utf-8 -*-
"""
Author: Zhang Haijun
Contacts: haijun.zhang@nokia-sbell.com
Squard: HGZ SG1
Description: SigSpark and Pioneer keywords with Nokia TA interface auto API.

"""
import os
import socket
import time
import json
import logging
import taf.transport.ssh as ssh
import re
from robot.libraries.BuiltIn import BuiltIn
import xml.etree.ElementTree as ET
from datetime import datetime


class Pioneer_sparkxml:

    """
    spark L3 message log parse function
    """

    def __init__(self):
        pass

    def open(self, logname):
        """
        open log and format to dict
        """
        root = ET.parse(logname)
        msgs = root.findall("OneMessage")
        self.message = {}
        for message in msgs:
            msgname = message.get('Name').strip()
            if msgname in self.message:
                self.message[msgname].append(message)
            else:
                self.message[msgname] = [message]

    def find(self, msg, path=None, type='last'):
        """
        get expect val form spark L3 message log
        """
        if msg in self.message:
            if type == 'last':
                trees = [self.message[msg][-1]]
            elif type == 'all':
                trees = self.message[msg]
            else:
                trees = [self.message[msg][0]]
            if path is not None:
                value = []
                for msgtree in trees:
                    res = self._find_val_by_path(msgtree, path)
                    if res is not None:
                        value = value + res
                if len(value) == 0:
                    return None
                elif len(value) == 1:
                    return value[0]
                else:
                    return value
            else:
                return msg
        else:
            return None

    def check(self, msg, expression):
        """
        check expression form spark L3 message log
        """
        if msg not in self.message:
            raise Exception('Can not find message : "{}"'.format(msg))
        trees = self.message[msg]
        eps = expression.split("&&")
        for ep in eps:
            kv = ep.split("=")
            if len(kv) != 2:
                raise Exception('Error expression format!')
            path = kv[0].strip()
            value = kv[1].strip()
            for msgtree in trees:
                res = self._find_val_by_path(msgtree, path)
                if res is not None and value in res:
                    break
            else:
                raise Exception('Check failed : "{}"'.format(ep))

    def _find_val_by_path(self, msgtree, path):
        """
        get expect val form spark xml tree
        """
        path = path.split(".")
        trees = [msgtree]
        for name in path:
            tmp = []
            for tree in trees:
                res = tree.findall(".//{}".format(name))
                if len(res) > 0:
                    tmp = tmp + res
            if len(tmp) == 0:
                return None
            else:
                trees = tmp
        res = []
        for msgtree in trees:
            value = self._format_val(msgtree)
            res.append(value)
        return res

    def _format_val(self, msgtree):
        """
        format value from xml format
        """
        if len(msgtree.getchildren()) > 0:
            if len(msgtree.getchildren()) > 1:
                msginfo = ET.tostring(msgtree)
            else:
                msginfo = ET.tostring(msgtree.getchildren()[0])
            rule = re.compile(r'<\/[^>]*>')
            # For python3 adaption
            msginfo = msginfo.decode('utf-8')
            msginfo = rule.sub('', msginfo)
            msginfo = msginfo.replace(
                "/>",
                "").replace(
                "<",
                "").replace(
                ">",
                ":").strip()
            return msginfo
        else:
            return msgtree.text


class Pioneer_sparkcsv:

    """
    spark IE data parse function
    """

    def __init__(self):
        pass

    def open(self, logname):
        """
        open log and format to dict
        """
        f = open(logname)
        lines = f.readlines()
        f.close()
        data = {}
        title = lines[0].strip().split(",")
        del lines[0]
        for line in lines:
            line = re.sub(
                '(\".*)(,)(.*\")',
                lambda x: x.group(1) + " and" + x.group(3),
                line)
            for i in range(0, len(title)):
                linedata = line.strip().split(",")
                if title[i] not in data:
                    data[title[i]] = []
                if title[i] == "Time":
                    linedata[i] = datetime.strptime(
                        linedata[i][0:-4], "%Y-%m-%d %H:%M:%S")
                    linedata[i] = int(time.mktime(linedata[i].timetuple()))
                data[title[i]].append(linedata[i])
        self.data = data

    def find(self, ie, starttime=None, endtime=None):
        """
        get IE value list during starttime to endtime
        """
        if starttime is None:
            starttime = self.data['Time'][0]
        else:
            starttime = int(starttime)
        if endtime is None:
            endtime = self.data['Time'][-1]
        else:
            endtime = int(endtime)
        for i in range(0, len(self.data['Time'])):
            if self.data['Time'][i] >= starttime:
                startindex = i
                break
        for i in range(0, len(self.data['Time'])):
            if self.data['Time'][len(self.data['Time']) - i - 1] <= endtime:
                endindex = len(self.data['Time']) - i
                break
        return self.data[ie][startindex:endindex]


class Pioneer_ADBClient():

    def setup_adb_connect(self, alias):
        """
        Setup ssh connection for adb command
        :param alias: connection alias
        :return: None
        """
        sshconn = ssh.ssh()
        sshconn.connect_to(
            self.ue_config['host'],
            self.ue_config['username'],
            self.ue_config['password'],
            alias=alias)

    def send_adb_command(self, command, alias, timeout=30, interval=2):
        """
        Send adb command via ssh connection with UE control PC
        :param command: ADB command
        :param alias: connection alias
        :param timeout: waittime unitl action successful
        :param interval: retry action interval
        :return: None
        """
        pass

    def operate_ue_dataservice(self, action='enable'):
        """
        Open/close UE data
        :param action: enable/disable
        :return: None
        """
        self.setup_adb_connect(alias='sigspark')
        cmd = "svc data {}".format(action)
        self.send_adb_command(command=cmd, alias='sigspark')

    def restart_uemanager(self):
        """
        Restart Uemanager
        :return: None
        """
        pass

    def _adb_select_setting_menu_cmds(self, menu_num):
        """
        Format adb command to switch to menu
        :param menu_num: <list> index of eachh menu list page
        :return: adb commands
        """
        cmds = []
        for num in menu_num:
            cmds.append("input roll 0 -100")
            cmds.append("input roll 0 {}".format(num))
            cmds.append("input keyevent 66")
        return cmds

    def _adb_delkey_cmds(self, length):
        """
        Format adb input delete keyevent
        :param length: <int> length of text
        :return: adb commands
        """
        cmd = "input keyevent"
        for num in range(length):
            cmd = cmd + " 67"
        return [cmd]

    def _apn_adb_command(self, apn, model="EVR-AN00"):
        """
        Format set apn adb commands. Only supports HuaWei Mate 20X(EVR-AN00)
        :param apn: apn that set on UE
        :param model: Model of UE.
        :return: support UEs retrun commands, else return None
        """
        commands = {
            "EVR-AN00": [
                ["input keyevent 224", "input keyevent 3", "input swipe 300 1000 300 500"],
                ["am start com.android.phone/.MSimMobileNetworkSettings"],
                self._adb_select_setting_menu_cmds([3, 1, 1]),
                self._adb_delkey_cmds(60),
                ["input text {}".format(apn)],
                ["input keyevent 61 61", "input keyevent 66"],
                ["input tap 1000 100"],
                ["input roll 0 -100", "input keyevent 61 61", "input roll 0 1", "input keyevent 66"],
                ["input keyevent 3"]
            ]
        }
        if model in commands:
            return commands[model]
        else:
            return None

    def _depleyment_adb_command(self, depleyment=1, model="EVR-AN00"):
        """
        Format set depleyment adb commands. Only supports HuaWei Mate 20X(EVR-AN00)
        :param depleyment: 0:NSA 1:SA 2:NSA+SA
        :param model: Model of UE.
        :return: support UEs retrun commands, else return None
        """
        commands = {"EVR-AN00": [["input keyevent 224",
                                  "input keyevent 3",
                                  "input swipe 300 1000 300 500"],
                                 ["am start com.android.settings"],
                                 self._adb_select_setting_menu_cmds([100,
                                                                     10,
                                                                     23]),
                                 ["input roll 0 -100",
                                  "input roll 0 {}".format(depleyment),
                                  "input keyevent 66"]]}
        if model in commands:
            return commands[model]
        else:
            return None

    def set_apn(self, apn):
        """
        Set APN on UE via adb command
        :param apn: APN address
        :return: None
        """
        self.setup_adb_connect(alias='sigspark')
        cmd = "getprop ro.product.model"
        model = self.send_adb_command(command=cmd, alias='sigspark')
        model = model.split("\n")
        model = model[0].strip()
        steps = self._apn_adb_command(apn, model)
        if steps is None:
            logging.info("Can not set APN for '{}'".format(model))
        else:
            for step in steps:
                for cmd in step:
                    self.send_adb_command(command=cmd, alias='sigspark')

    def set_depleyment(self, depleyment=1):
        """
        Set APN on UE via adb command, UE will auto reboot
        :param depleyment: 0:NSA 1:SA 2:NSA+SA
        :return: None
        """
        self.setup_adb_connect(alias='sigspark')
        cmd = "getprop ro.product.model"
        model = self.send_adb_command(command=cmd, alias='sigspark')
        model = model.split("\n")
        model = model[0].strip()
        steps = self._depleyment_adb_command(depleyment, model)
        if steps is None:
            logging.info("Can not set APN for '{}'".format(model))
        else:
            for step in steps:
                for cmd in step:
                    self.send_adb_command(command=cmd, alias='sigspark')
        logging.info("waitting 60s for UE reboot")
        time.sleep(60)
        self.restart_uemanager()
        self.detach()


class Pioneer_InitClient():

    def init_config(self, index=0, get_spark_license=True, **kwargs):
        """
        Init ue config from ROBOTFRAMEWORK BuiltIn
        :param index: ue index of ${tl.ues} , count from 0
        :param **kwargs: ue config from input
               :config port: socket port default 30999
               :config host: controlpc host ip
               :config username: controlpc ssh username
               :config password: controlpc ssh password
               :config apppath: software install path on controlpc
               :config imsi: ue imsi
               :config appserver: DL/UL appserver
        :return: None
        """
        try:
            logging.info("----------dingli------------")
            varstr = "${tl.ues[" + str(index) + "]}"
            ueobj = BuiltIn().get_variable_value(varstr)
            self.ue_config = {
                "port": 30999,
                "host": ueobj.ssh_connection_details.addr,
                "username": ueobj.ssh_connection_details.username,
                "password": ueobj.ssh_connection_details.password,
                "apppath": ueobj.server_dir,
                "imsi": ueobj.imsi,
                "sn": ueobj.serial_number,
                "appserver": ueobj.iperf_details,
            }
            if get_spark_license:
                self.ue_config["licenseusername"] = ueobj.licensekeeper.username
                self.ue_config["licensepassword"] = ueobj.licensekeeper.password
        except BaseException as error:
            logging.info(
                "init config from robot testline failed : {}".format(
                    str(error)))
            self.ue_config = kwargs
        logging.info(self.ue_config)
        return (self.ue_config['host'], self.ue_config['apppath'])

    def startapp(self, dur=10, timeout=300, reset=False):
        """
        Start App by schtasks cmd
        :param dur: check app setup interval time (s)
        :param timeout: check app setup timeout (s)
        :reset: force reset app tag
        :return None
        """
        pass

    def setup(self, conn=None, get_spark_license=True, ue_num_input=None, required_spark_license_time=2,
              force_check_ue=False, eq_index=None):
        """
        Setup connection with sigspark TA client and connect ues
        """
        self.store = {}
        num = 5
        for i in range(num):
            try:
                if conn is None:
                    self.conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                    self.conn.settimeout(60)
                    self.conn.connect((self.ue_config['host'], self.ue_config['port']))
                else:
                    self.conn = conn
                if get_spark_license:
                    self._get_spark_license()
                self._connect_ues(ue_num_input=ue_num_input)
                break
            except socket.error as msg:
                print("=====Connect to server failed with Error: {}=====".format(msg))
                time.sleep(5)
        if i >= (num - 1):
            raise Exception("=====Socket failed after retry 5 times=====")
        return self.conn

    def teardown(self):
        """
        Close connection with sigspark TA client and disconnect ues
        """
        self._disconnect_ues()
        r = self.conn.close()

    def _send_msg(self, cmd, param=None, index=None):
        """
        Send message to sigspark client with EQIndex
        :param cmd: command define by sigspark api
        :param param: param define by sigspark api
        :param index: EQIndex define by sigspark api , count from 1
        :return None
        """
        msg = {
            "CMD": cmd
        }
        msg['EQIndex'] = self.ueindex
        if index:
            msg['EQIndex'] = index
        if param:
            msg['Param'] = param
        msg = json.dumps(msg)
        msg = msg.encode('utf-8')
        logging.info('Send "{}" to control pc'.format(msg))
        self.conn.send(msg)

    def _send_common_msg(self, cmd, param=None):
        """
        Send message to sigspark client without EQIndex
        :param cmd: command define by sigspark api
        :param param: param define by sigspark api
        Example: {"CMD": "GetParamMAC", "EQIndex": 1}
        :return None
        """
        msg = {
            "CMD": cmd
        }
        if param:
            msg['Param'] = param
        msg = json.dumps(msg)
        msg = msg.encode('utf-8')
        logging.info('Send "{}" to control pc'.format(msg))
        self.conn.send(msg)

    def _receive_msg(self, timeout=None, buflen=1024):
        """
        Get message from sigspark client
        :return <dict>
        Example: {"CMD":"Attach","EQIndex":1,"Param":{"State":0}}
        """
        self.conn.settimeout(timeout)
        recv = self.conn.recv(buflen)
        time.sleep(1)
        logging.info('Receive "{}"'.format(recv))
        recv = json.loads(recv)
        return recv

    def _get_msg(self, cmd, index=None, retry=5, timeout=60):
        """
        Filter message from sigspark client with retry
        :param cmd: command define by sigspark api
        :param retry: get needed message retry times
        :return <dict>
        Example: {"State":0,"MACDL":11325064,"MACUL":5622736}
        """
        while retry > 0:
            try:
                recv = self._receive_msg(timeout)
                if recv['CMD'] == cmd:
                    if "EQIndex" in recv:
                        if index is None:
                            index = self.ueindex
                        if recv["EQIndex"] == index:
                            break
                    else:
                        break
            except socket.timeout:
                print("receive response timeout, try again")
            retry = retry - 1
            if retry == 0:
                raise Exception(
                    "Can get response with '{}' !".format(
                        recv['CMD']))
        if recv['Param']['State'] == -1:
            raise Exception("Execute {} failed!".format(recv['CMD']))
        else:
            return recv['Param']

    def _get_events_msg(self, cmd, retry=2, buflen=102400, timeout=180):
        """
        Filter message from sigspark client with retry
        :param cmd: command define by sigspark api
        :param retry: get needed message retry times
        :return <dict>
        Example: {"State":0,"MACDL":11325064,"MACUL":5622736}
        """
        while retry > 0:
            try:
                recv = self._receive_msg(timeout, buflen)
                if recv['Param']['LastEventIndex'] == recv['Param']['EventCount']:
                    break
            except socket.timeout:
                print("receive response timeout, try again")
            retry = retry - 1
            print("retry value is: ", retry)
            if retry == 0:
                raise Exception("Can get response with '{}' !".format(recv['CMD']))
        if recv['Param']['State'] == -1:
            raise Exception("Execute {} failed!".format(recv['CMD']))
        else:
            return recv


class Pioneer_BaseClient(Pioneer_InitClient, Pioneer_ADBClient):

    def _auto_check(self, cmd="AutoCheck"):
        """
        Auto check sigspark UEs connect on controlpc
        :param cmd: AutoCheck define by sigspark api
        :return <int> number of UEs
        """
        self._send_common_msg(cmd)
        res = self._get_msg(cmd)
        return res['Count']

    def _connect_ues(self, cmd="ConnectEQ", ue_num_input=None, force_check_ue=False, eq_index=None):
        """
        Connect all UEs on controlpc
        :param cmd: ConnectEQ define by sigspark api
        :return None
        """
        if ue_num_input:
            ue_num = int(ue_num_input)
        else:
            ue_num = self._auto_check()
            ue_num = int(ue_num)
        if ue_num > 0:
            self._send_common_msg(cmd)
            self._get_msg(cmd=cmd, timeout=600)
            self.ueindex = 1
            time.sleep(10)
            for i in range(1, ue_num + 1):
                imsi = self.get_imsi_by_AT(index=i)
                logging.info(imsi)
                if imsi == self.ue_config['imsi']:
                    self.ueindex = i
                    break
        else:
            self.teardown()
            raise Exception("No UE find on PC!")

    def _disconnect_ues(self, cmd="DisConnectEQ"):
        """
        Disconnect all UEs on controlpc
        :param cmd: DisConnectEQ define by sigspark api
        :return None
        """
        self._send_common_msg(cmd)
        self._get_msg(cmd)

    def start_log(self, logname="TA_LOG", logpath=None, cmd="StartLog"):
        """
        Start sigspark log on controlpc
        :param logpath: Log path on controlpc
        :param logname: Log name for saving
        :param cmd: StartLog define by sigspark api
        :return None
        """
        if logpath is None:
            logpath = "C:/tmp/uelog/AUTO/{}".format(int(time.time()))
        param = {"LogName": logname, "LogPath": logpath}
        self._send_common_msg(cmd, param=param)
        self._get_msg(cmd)
        return [logpath, logname]

    def stop_log(self, cmd="StopLog"):
        """
        Stop sigspark log on controlpc
        :param cmd: StopLog define by sigspark api
        :return None
        """
        self._send_common_msg(cmd)
        self._get_msg(cmd)

    def start_ul_traffic(
            self,
            protocol="UDP",
            testtime="120",
            bandwidth=1000,
            buffersize=1024,
            packetsize=1400,
            multidrb_QoS_dest=None,
            iperf_port=None,
            connectiontype='app',
            apnaddress="wap1nokiacom",
            ue_mode="SA",
            cmd="StartULtraffic"):
        """
        Start UL traffic on UE
        :param cmd: Attach define by sigspark api
        :param protocol: "UDP", //  means default protocol UDP
        :param testtime: "120",    //Test time.
        :param bandwidth: 1000,    //Kbps.
        :param buffersize: 1024,     //KB
        :param packetsize: 1400     //Byte
        :param multidrb_QoS_dest: <option> multidrb QoS rule server ipaddr
        :param iperf_port: port value of traffic, it can be get from __int__.py file or TCs eg: 50001
        :return None
        """
        if ue_mode == "SA":
            ueip = self.get_pdu_ip(apnaddress=apnaddress)
        else:
            ueip = self.get_pdu_ip_by_AT(id=1)

        logging.info(ueip)
        if multidrb_QoS_dest is None:
            dest = self.ue_config['appserver'].network_interface_address
        else:
            dest = multidrb_QoS_dest
        param = {
            "Protocol": protocol,
            "Address": dest,
            "Port": iperf_port,
            "TestTime": testtime,
            "Bandwidth": bandwidth,
            "BufferSize": buffersize,
            "PacketSize": packetsize}
        self._send_msg(cmd, param=param)
        self._get_msg(cmd)

    def stop_ul_traffic(self, cmd="StopULtraffic"):
        """
        Stop UL traffic on UE
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def create_test_plan(
            self,
            taskname="Test",
            times=1,
            interval=10,
            content={},
            cmd="CreateTestPlan"):
        """
        Create test plan
        :param taskname: task name
        :param times: test times
        :param interval: sleep time before replay
        :param content: <dict>, test content define by vendor
        :return None
        """
        param = {
            "TestPlans": [
                {
                    "TaskName": taskname,
                    "TestTimes": int(times),
                    "TestInterval": int(interval),
                    "TestContent": content
                }
            ]
        }
        self._send_msg(cmd, param=param)
        self._get_msg(cmd)

    def start_test(self, cmd="StartTest"):
        """
        Excute testplan
        :param cmd: StartTest define by sigspark api
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def stop_test(self, cmd="StopTest"):
        """
        Stop testplan
        :param cmd: StopTest define by sigspark api
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def attach(self, ue_mode, cmd="Attach"):
        """
        Attach UE (attach and setup pdu)
        :param ue_mode: attach mode,"4G" or "5G_SA" or "5G_NSA"
        :param cmd: Attach define by sigspark api
        :return <int> attach state
        """
        param = {"UEMode": ue_mode}
        self._send_msg(cmd, param=param)
        attach_resp = self._get_msg(cmd)
        return attach_resp['State']

    def detach(self, cmd="Detach"):
        """
        Dttach UE
        :param cmd: Detach define by sigspark api
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def power_on(self, cmd="PowerOn"):
        """
        Open RF on UE (not reboot)
        :param cmd: PowerOn define by sigspark api
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def power_off(self, cmd="PowerOff"):
        """
        Shutdown RF on UE (not reboot)
        :param cmd: PowerOff define by sigspark api
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def lock_band(self, band, cmd="LockBand"):
        """
        Lock band on UE
        :param band: <str> "1,3,5" means lock Band1, Band3 and Band5, and so forth
        :return None
        """
        param = {"BandStr": band}
        self._send_msg(cmd, param=param)
        self._get_msg(cmd)

    def unlock_band(self, cmd="UnlockBand"):
        """
        UnlockBand the bands specified by “LockBand” cmd
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def config_5g_deployment(self, nettype, cmd="Config5GDeployment"):
        """
        Configure the UE 5G deployment
        :param nettype: <int> 0:"AUTO", 8:"NSA", 20:"SA+NSA"
        :return None
        """
        param = {"NetType": int(nettype)}
        self._send_msg(cmd, param=param)
        self._get_msg(cmd)

    def get_mac_tp(self, cmd="GetParamMAC"):
        """
        Get throughput on UE
        :param cmd: GetParamMAC define by sigspark api
        :return <tuple> (ul , dl)  (byte)
        """
        self._send_msg(cmd)
        res = self._get_msg(cmd)
        ul = float(res['MACUL'])
        dl = float(res['MACDL'])
        return (ul, dl)

    def get_imsi(self, cmd="GetParamIMSI"):
        """
        Get IMSI and IP on UE
        :return <str> imsi
        """
        self._send_msg(cmd)
        res = self._get_msg(cmd)
        imsi = res['IMSI']
        return imsi

    def get_pdu_ip(self, apnaddress, cmd="GetPDUInfo", timeout=30):
        """
        Get IMSI and IP on UE
        :param pduid: GetParamIMSI define by sigspark api
        :return <str> imsi
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            param = {"APN": apnaddress}
            self._send_msg(cmd, param=param)
            try:
                res = self._get_msg(cmd)
                if res['IP'] != "":
                    print(res['IP'])
                    PDU_IP = res['IP'].split(":")[-1]
                    return PDU_IP
#                    return res['IP']
            except BaseException:
                pass
            time.sleep(2)
        else:
            raise Exception("Get ueip timeout!")

    def export_message_detail(
            self,
            logpath,
            localpath,
            localname,
            cmd="ExportMessageDetail"):
        """
        export L3 message detail and download to UTE
        :param logpath: log full path for saving on UTE
        :return None
        """
        localfile = "{}/{}.xml".format(localpath, localname)
        localsaf = "{}/{}-{}.saf".format(localpath,
                                         localname, self.ueindex)
        param = {"ExportFileName": localfile,
                 "Logfile": localsaf}
        self._send_common_msg(cmd, param=param)
        res = self._get_msg(cmd)
        sshconn = ssh.ssh()
        sshconn.connect_to(
            self.ue_config['host'],
            self.ue_config['username'],
            self.ue_config['password'],
            alias='sigspark')
        sshconn.download_file(localfile, logpath, connection='sigspark')
        sshconn.disconnect(connection='sigspark')

    def export_log_file(
            self,
            logpath,
            localpath,
            localname,
            template='auto_test',
            cmd="ExportLogfile"):
        """
        export filter log file to csv and download to UTE
        :param logpath: log full path for saving on UTE
        :param template: filter template name on spark
        :return None
        """
        localfile = "{}/{}.csv".format(localpath, localname)
        localsaf = "{}/{}-{}.saf".format(localpath,
                                         localname, self.ueindex)
        param = {
            "TemplateName": template,
            "ExportFileName": localfile,
            "Logfile": localsaf}
        self._send_common_msg(cmd, param=param)
        res = self._get_msg(cmd)
        sshconn = ssh.ssh()
        sshconn.connect_to(
            self.ue_config['host'],
            self.ue_config['username'],
            self.ue_config['password'],
            alias='sigspark')
        sshconn.download_file(localfile, logpath, connection='sigspark')

    def setup_pdu(
            self,
            id=1,
            type="IP",
            apn="wap1.nokia.com",
            ssc=0,
            slice=None,
            cmd="SetupPDU"):
        """
        Setup PDU session
             Use 'AT command' like 'AT+CGDCONT=2,"IP","wap2.nokia.com"'
             and 'AT+CGACT=1,2'
        :param id: <int,str> PDU cofing,context id
        :param type: <str> PDU cofing, IP/IPV4V6
        :param apn: <str> PDU cofing,APN
        :param ssc: <str> SSC_mode,0 or 1
        :param slice: <str> S_NSSAI like "1.123456;2F.654321"
        :return response of udp command
        """
        if slice is None:
            param = {"Type": type, "APN": apn, "ID": id}
        else:
            param = {
                "Type": type,
                "APN": apn,
                "ID": id,
                "SSC_mode": ssc,
                "S_NSSAI": slice}
        self._send_msg(cmd, param=param)
        res = self._get_msg(cmd)
        return res

    def release_pdu(self, cmd="ReleasePDU", id=id):
        """
        Release PDU session
             Use 'AT command' like 'AT+CGACT=0,2'
        :id: <int,str> PDU cofing,context id
        :return None
        """
        param = {"ID": id}
        self._send_msg(cmd, param=param)
        res = self._get_msg(cmd)
        return res

    def configure_apn(
            self,
            apn,
            mcc="460",
            mnc="02",
            cmd="ConfigureAPN"):
        """
        Update or insert APN on UE
        :param apnname: <str> apnname dispaly on UE,if apn name existed,update this apn,else insert apn
        :param apn: <str> apn address
        :param mcc: <str> mcc mode, '460' default
        :param mnc: <str> mnc mode, '02' default
        :return None
        """
        param = {"APN": apn}
        self._send_msg(cmd, param=param)
        res = self._get_msg(cmd)

    def send_at_command(
            self,
            command="AT",
            timeout=5000,
            cmd='SendAT',
            index=None):
        """
        Send ATCOMMAND via sigspark
        :param command: ATCOMMAND define on 3gpp
        :param timeout: Get return timeout
        :param cmd: SendAT define by sigspark api
        :return <str> response of ATCOMMAND
        """
        param = {"Command": command, "Timeout": timeout}
        if index is None:
            self._send_msg(cmd, param=param)
        else:
            self._send_msg(cmd, index=index, param=param)
        if index is None:
            res = self._get_msg(cmd=cmd, timeout=5)
        else:
            res = self._get_msg(cmd=cmd, index=index, timeout=5)
        return res['Back'].strip()

    def get_pdu_ip_by_AT(self, id=1, timeout=30):
        """
        Get ueip via ATCOMMAND
        :param id: ATCOMMAND pdu id
        :return <str> ueip
        """
        endtime = time.time() + timeout
        ueip = ""
        while endtime > time.time():
            try:
                res = self.send_at_command(command="AT+CGPADDR")
                res = re.findall(
                    r'\+CGPADDR: ' +
                    str(id) +
                    r',"?((\d+\.?){4})"?',
                    res)
                if len(res) > 0:
                    return res[0][0]
            except BaseException as error:
                logging.info("get ueip failed with error :{}".format(str(error)))
            time.sleep(2)
        else:
            raise Exception("Get ueip timeout!")

    def get_imsi_by_AT(self, index=None, timeout=30):
        """
        Get imsi via ATCOMMAND
        :return <str> imsi
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            try:
                res = self.send_at_command(command="AT+CIMI", index=index)
                res = re.findall(r'(\d+)'.format(id), res)
                if len(res) > 0:
                    return res[0]
            except BaseException as error:
                logging.info("get imsi failed with error :{}".format(str(error)))
            time.sleep(2)
        else:
            print("get ue{}'s imsi failed, Go to next ue".format(index))

    def _appserver_connect(self, conn):
        """
        Connect to appserver by ssh
        :param conn: conn alias
        :return ssh connection
        """
        hostname = self.ue_config['appserver'].ssh_connection_details.addr
        username = self.ue_config['appserver'].ssh_connection_details.username
        password = self.ue_config['appserver'].ssh_connection_details.password
        sshconn = ssh.ssh()
        sshconn.connect_to(
            hostname=hostname,
            username=username,
            password=password,
            alias=conn)
        return sshconn

    def start_dl_traffic(
            self,
            iperf_port,
            tp="10M",
            dur=120,
            taskname="UL test",
            timeout=30,
            apnaddress="wap1nokiacom",
            ue_mode="SA",
            buffer_size="1024B"):
        """
        Start DL traffic
        :param iperf_port: port value of traffic, eg: 50001, if None, read from configuration file
                           if not None, read from TCs
        :param tp:<str> DL traffic throughput , 10M , 10K, 10G
        :param dur: DL traffic execute duration
        :param taskname: ssh connection alias
        :param taskname: check ue ip timeout
        :return None
        """
        if ue_mode == "SA":
            ueip = self.get_pdu_ip(apnaddress=apnaddress, timeout=timeout)
        else:
            ueip = self.get_pdu_ip_by_AT(id=1)
        sshconn = self._appserver_connect(taskname)
        port = iperf_port
        iperf_path = self.ue_config['appserver'].iperf_path
        cmd = "{} -c {} -u -t {} -i 1 -p {} -P 1 -f m -b {} -l {} -T 64".format(
            iperf_path, ueip, dur, port, tp, buffer_size)
        sshconn.send_command(command=cmd, connection=taskname)
        sshconn.disconnect(connection=taskname)

    def stop_dl_traffic(self, iperf_port, apnaddress="wap1nokiacom", ue_mode="SA"):
        """
        Stop DL traffic
        :param iperf_port: port value of traffic, it can be get from __int__.py file or TCs eg: 50001
        :param apnaddress: apn address of PDU, only used when ue mode is SA
        :ue_mode: SA or NSA
        :return None
        """
        if ue_mode == "SA":
            ueip = self.get_pdu_ip(apnaddress=apnaddress)
        else:
            ueip = self.get_pdu_ip_by_AT(id=1)
        sshconn = self._appserver_connect("killdl")
        port = iperf_port
        iperf_path = self.ue_config['appserver'].iperf_path
        cmd = "ps aux |grep iperf |grep " + \
            str(ueip) + " |grep " + str(port) + " |awk '{print $2}' | xargs kill -9"
        sshconn.send_command(command=cmd, connection="killdl")
        sshconn.disconnect(connection="killdl")

    def get_parm_value(self, param, cmd="GetParamValue", timeout=5):
        """
        Get param value on UE
        :param cmd: GetParamValue define by sigspark api
        :param param: <list> param with sigspark format
        :return <STR> (RSRP , SINR , PCI)
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            self._send_msg(cmd, param=param)
            try:
                res = self._get_msg(cmd)
                if res['Values'] != "":
                    print(res['Values'])
                    param_value = res['Values']
                    return param_value
                else:
                    raise Exception("Get param_value failed, param_value should not be none!")
            except BaseException:
                pass
            time.sleep(2)
        else:
            raise Exception("Get param_value failed!")

    def get_IMS_PDU_status(self, param, cmd="GetEvents", timeout=10):
        """
        Get param value on UE
        :param cmd: GetParamValue define by sigspark api
        :param param: <list> param with sigspark format
        :return IMS PDU session status
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            self._send_msg(cmd, param=param)
            try:
                res = self._get_events_msg(cmd)
                if res['CMD'] == cmd:
                    Events_list = res['Param']['EventList']
                    Events_conut = res['Param']['EventCount']
                    for i in range(0, Events_conut):
                        Event_name = Events_list[i]['Name']
                        IMS_PDU = "SIP Register Complete"
                        if Event_name == IMS_PDU:
                            print("IMS PDU Establish accept")
                            IMS_PDU_Establish_Accept = 1
                            break
                        else:
                            print("IMS PDU Establish fail")
                            IMS_PDU_Establish_Accept = 0
                    print(IMS_PDU_Establish_Accept)
                    if IMS_PDU_Establish_Accept == 1:
                        return True
                    else:
                        return False
                else:
                    raise Exception("IMS PDU Establish fail, Event should not be none!")
            except BaseException:
                pass
            time.sleep(2)
        else:
            raise Exception("IMS PDU Establish fail!")

    def get_Vonr_call_status(self, param, cmd="GetEvents", timeout=10):
        """
        Get param value on UE
        :param cmd: GetParamValue define by sigspark api
        :param param: <list> param with sigspark format
        :return vonr call status
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            self._send_msg(cmd, param=param)
            try:
                res = self._get_events_msg(cmd)
                if res['CMD'] == cmd:
                    Events_list = res['Param']['EventList']
                    Events_conut = res['Param']['EventCount']
                    for i in range(0, Events_conut):
                        Event_name = Events_list[i]['Name']
                        Vonr_call = "SIP MO Call Established"
                        if Event_name == Vonr_call:
                            print("SIP MO Call Established")
                            Vonr_call_Establish_Accept = 1
                            break
                        else:
                            print("SIP MO Call Establish fail")
                            Vonr_call_Establish_Accept = 0
                    print(Vonr_call_Establish_Accept)
                    if Vonr_call_Establish_Accept == 1:
                        return True
                    else:
                        return False
                else:
                    raise Exception("SIP MO Call Establish fail, Event should not be none!")
            except BaseException:
                pass
            time.sleep(2)
        else:
            raise Exception("SIP MO Call Establish fail!")

    def get_Vonr_call_release_status(self, param, cmd="GetEvents", timeout=10):
        """
        Get param value on UE
        :param cmd: GetParamValue define by sigspark api
        :param param: <list> param with sigspark format
        :return vonr call status
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            self._send_msg(cmd, param=param)
            try:
                res = self._get_events_msg(cmd)
                time.sleep(3)
                if res['CMD'] == cmd:
                    Events_list = res['Param']['EventList']
                    Events_conut = res['Param']['EventCount']
                    for i in range(0, Events_conut):
                        Event_name = Events_list[i]['Name']
                        Vonr_call = "SIP MO Call End"
                        if Event_name == Vonr_call:
                            print("SIP MO Call release fail")
                            Vonr_call_Establish_Accept = 1
                            break
                        else:
                            print("SIP MO Call release fail")
                            Vonr_call_Establish_Accept = 0
                    print(Vonr_call_Establish_Accept)
                    if Vonr_call_Establish_Accept == 1:
                        return True
                    else:
                        return False
                else:
                    raise Exception("SIP MO Call release fail, Event should not be none!")
            except BaseException:
                pass
            time.sleep(2)
        else:
            raise Exception("SIP MO Call release fail!")

    def get_Data_PDU_status(self, param, cmd="GetEvents", timeout=10):
        """
        Get param value on UE
        :param cmd: GetParamValue define by sigspark api
        :param param: <list> param with sigspark format
        :return vonr call status
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            self._send_msg(cmd, param=param)
            try:
                res = self._get_events_msg(cmd)
                if res['CMD'] == cmd:
                    Events_list = res['Param']['EventList']
                    Events_conut = res['Param']['EventCount']
                    for i in range(0, Events_conut):
                        Event_name = Events_list[i]['Name']
                        Data_PDU = "SA PDU Establish Accept"
                        if Event_name == Data_PDU:
                            Event_detail = Events_list[i]['Detail']
                            Event_data_detail = Event_detail.split(' ')
                            Event_DATA_PDU = Event_data_detail[3]
                            print(Event_DATA_PDU)
                            DNN = "DNN:wap2nokiacom"
                            if Event_DATA_PDU == DNN:
                                print("DATA PDU Establish Accept")
                                DATA_PDU_Establish_Accept = 1
                                break
                            else:
                                print("DATA PDU Establish fail")
                                DATA_PDU_Establish_Accept = 0
                        else:
                            DATA_PDU_Establish_Accept = 0
                    print(DATA_PDU_Establish_Accept)
                    if DATA_PDU_Establish_Accept == 1:
                        return True
                    else:
                        return False
                else:
                    raise Exception("DATA PDU Establish fail, Event should not be none!")
            except BaseException:
                pass
            time.sleep(2)
        else:
            raise Exception("DATA PDU Establish fail!")

    def start_stop_check_vonr_AT(self, param, timeout=5, cmd='SendAT'):
        """
        :param cmd: GetParamValue define by sigspark api
        :param param: <str> , vonr call command like:ATD004488;
        """
        endtime = time.time() + timeout
        param_value = {"Command": param, "Timeout": 50000, "SuccStr": "OK"}
        while endtime > time.time():
            self._send_msg(cmd, param=param_value)
            try:
                res = self._get_msg(cmd)
                if res['Back'] == '\r\nOK\r\n\r\nNO CARRIER\r\n' or res['Back'] == '\r\nOK\r\n' or "OK" in res['Back']:
                    print(param, ' command send ok')
                    break
                else:
                    raise Exception("command send fail")
            except BaseException:
                raise Exception("command send fail!")
            time.sleep(2)

    def send_at_command_with_succStr(
            self,
            command="AT",
            timeout=50000,
            cmd='SendAT',
            index=None):
        """
        Send ATCOMMAND via sigspark
        :param command: ATCOMMAND define on 3gpp
        :param timeout: Get return timeout
        :param cmd: SendAT define by sigspark api
        :return <str> response of ATCOMMAND
        """
        param = {"Command": command, "Timeout": timeout, "SuccStr": ""}
        if index is None:
            self._send_msg(cmd, param=param)
        else:
            self._send_msg(cmd, index=index, param=param)
        if index is None:
            res = self._get_msg(cmd=cmd, timeout=5)
        else:
            res = self._get_msg(cmd=cmd, index=index, timeout=5)
        return res['Back'].strip()


class PioneerClient(Pioneer_BaseClient):

    def send_adb_command(self, command, alias, timeout=30, interval=2):
        """
        Send adb command via ssh connection with UE control PC
        :param command: ADB command
        :param alias: connection alias
        :param timeout: waittime unitl action successful
        :param interval: retry action interval
        :return: None
        """
        adbpath = self.ue_config['apppath'].replace(
            "Pioneer.exe", "ADB/adb.exe")
        cmd = "'{}' -s {} shell {}".format(adbpath,
                                           self.ue_config['sn'], command)
        sshconn = ssh.ssh()
        endtime = time.time() + timeout
        while time.time() < endtime:
            logging.info("Send ADB: {}".format(cmd))
            res = sshconn.execute(command=cmd, connection='sigspark')
            ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
            res = ansi_escape.sub('', res)
            res = res.strip()
            logging.info("Response ADB: {}".format(res))
            if "error:" not in res:
                return res
            time.sleep(interval)
        else:
            raise RuntimeError("Execute ADB cmd failed!")

    def startapp(self, dur=10, timeout=300, reset=False):
        """
        Start App by schtasks cmd
        :param dur: check TA port setup interval time (s)
        :param timeout: check TA port setup timeout (s)
        :reset: force reset spark tag
        :return <boolean> True means socket connection not reset
        """
        dur = int(dur)
        timeout = int(timeout)
        sshconn = ssh.ssh()
        sshconn.connect_to(
            self.ue_config['host'],
            self.ue_config['username'],
            self.ue_config['password'],
            alias='sigspark')
        ta_status_cmd = "tasklist |findstr Pioneer"
        endtime = time.time() + 10
        while endtime > time.time() and reset is False:
            res = sshconn.execute(command=ta_status_cmd, connection='sigspark')
            if "Pioneer.exe" in res:
                sshconn.disconnect(connection='sigspark')
                return True
            time.sleep(1)
        else:
            restart_cmds = [
                "taskkill /f /im adb.exe",
                "taskkill /f /im Pioneer.exe",
                "schtasks /delete /tn dingli /f",
                "schtasks /create /tn dingli /sc once /tr '{}' /st 00:00 /RL highest /f".format(
                    self.ue_config['apppath']),
                "schtasks /run /tn dingli"]
            for cmd in restart_cmds:
                sshconn.execute(command=cmd, connection='sigspark')
                time.sleep(2)
            while timeout >= 0:
                res = sshconn.execute(
                    command=ta_status_cmd, connection='sigspark')
                if "Pioneer.exe" in res and "LogoPioneer.exe" not in res:
                    break
                time.sleep(dur)
            else:
                raise Exception("Start Pioneer failed in 300s")
            sshconn.disconnect(connection='sigspark')
            return False

    def restart_uemanager(self):
        """
        Restart Uemanager
        :return: None
        """
        self.setup_adb_connect(alias='sigspark')
        cmd = "am force-stop com.dingli.pioneer"
        self.send_adb_command(command=cmd, alias='sigspark')
        cmd = (
            "am start -a android.intent.action.MAIN -c "
            "android.intent.category.LAUNCHER -n com.dingli.pioneer/.MainActivity")
        self.send_adb_command(command=cmd, alias='sigspark')

    def create_test_plan(self, testplanslocation=None, cmd="CreateTestPlan"):
        """
        Create test plan
        :param testplanslocation: file location .dlp is project plan and .tpl is test plan
        :return None
        """
        param = {"TestPlansLocation": testplanslocation}
        self._send_msg(cmd, param)
        self._get_msg(cmd)

    def start_test(self, cmd="StartTest"):
        """
        Excute testplan
        :param cmd: StartTest define by pioneer
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def stop_test(self, cmd="StopTest"):
        """
        Stop testplan
        :param cmd: StopTest define by pioneer
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def lock_band(self, band, cmd="LockBand"):
        """
        Lock band on UE
        :param band: <str> "1,3,5" means lock Band1, Band3 and Band5, and so forth
        :return None
        """
        pass

    def unlock_band(self, cmd="UnlockBand"):
        """
        UnlockBand the bands specified by “LockBand” cmd
        :return None
        """
        pass

    def export_message_detail(
            self,
            logpath,
            localpath,
            localname,
            cmd="ExportMessageDetail"):
        """
        export L3 message detail and download to UTE
        :param logpath: log full path for saving on UTE
        :return None
        """
        sshconn = ssh.ssh()
        sshconn.connect_to(
            self.ue_config['host'],
            self.ue_config['username'],
            self.ue_config['password'],
            alias='sigspark')
        for i in range(1, self.ueindex + 1):
            localfile_l = "{}{}UE{}.xml".format(localpath, localname, i)
            localfile_w = localfile_l.replace("/", "\\")
            localsaf_l = sshconn.execute(command="ls {}{}*UE{}*.rcu".format(localpath, localname, i),
                                         connection='sigspark').split()
            localsaf_w = localsaf_l[0].replace("/", "\\")
            param = {"ExportFileName": localfile_w, "Logfile": localsaf_w}
            self._send_common_msg(cmd, param=param)
            res = self._get_msg(cmd, timeout=360)
            logpath1 = "{}UE{}.xml".format(logpath, i)
            sshconn.download_file(localfile_l, logpath1, connection='sigspark')
        sshconn.disconnect(connection='sigspark')

    def export_log_file(
            self,
            logpath,
            localpath,
            localname,
            template='auto_test',
            cmd="ExportLogfile"):
        """
        export filter log file to csv and download to UTE
        :param logpath: log full path for saving on UTE
        :param template: filter template name on spark
        :return None
        """
        sshconn = ssh.ssh()
        sshconn.connect_to(
            self.ue_config['host'],
            self.ue_config['username'],
            self.ue_config['password'],
            alias='sigspark')
        for i in range(1, self.ueindex + 1):
            localfile_l = "{}{}UE{}.csv".format(localpath, localname, i)
            localfile_w = localfile_l.replace("/", "\\")
            localsaf_l = sshconn.execute(command="ls {}{}*UE{}*.rcu".format(localpath, localname, i),
                                         connection='sigspark').split()
            localsaf_w = localsaf_l[0].replace("/", "\\")
            param = {"TemplateName": template, "ExportFileName": localfile_w, "Logfile": localsaf_w}
            self._send_common_msg(cmd, param=param)
            res = self._get_msg(cmd)
            logpath1 = "{}UE{}.csv".format(logpath, i)
            sshconn.download_file(localfile_l, logpath1, connection='sigspark')
        sshconn.disconnect(connection='sigspark')

    def configure_apn(
            self,
            apn,
            mcc="460",
            mnc="02",
            cmd="ConfigureAPN"):
        """
        Release PDU session
        :param apnname: <str> apnname dispaly on UE
        :param apn: <str> apn address
        :param mcc: <str> '460' default
        :param mnc: <str> '02' default
        :return None
        """
        pass

    def start_log(self, logname="LOG", logpath=None, cmd="StartLog"):
        """
        Start pioneer log on controlpc
        :param logpath: Log path on controlpc
        :param logname: Log name for saving
        :param cmd: StartLog define by pioneer
        :return None
        """
        if logpath is None:
            logpath = "C:/tmp/{}/".format(int(time.time()))
        param = {"LogName": logname, "LogPath": logpath}
        self._send_common_msg(cmd, param=param)
        self._get_msg(cmd)
        return [logpath, logname]
