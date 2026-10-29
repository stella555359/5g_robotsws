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


class ADBClient():

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
            alias=alias,
            look_for_keys=False)

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
        pass

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


class InitClient(object):

    def __init__(self):
        self.conn = None
        self.ue_config = {}
        self.multiue_traffic_config = {}

    def init_config(self, multiue_traffic_config, get_spark_license=True, **kwargs):
        """
        Init ue config from ROBOTFRAMEWORK BuiltIn
        :param **kwargs: ue config from input
        :return: None
        """
        mutiue_imsi = {}
        mutiue_sn = {}
        mutiue_appserver = {}
        self.multiue_traffic_config = multiue_traffic_config
        try:
            for i, idx in enumerate(multiue_traffic_config['ue_index_for_call']):
                varstr = "${tl.ues[" + str(idx) + "]}"
                ueobj = BuiltIn().get_variable_value(varstr)
                if i == 0:
                    self.ue_config['host'] = ueobj.ssh_connection_details.addr
                    self.ue_config['username'] = ueobj.ssh_connection_details.username
                    self.ue_config['password'] = ueobj.ssh_connection_details.password
                    self.ue_config['port'] = 30999
                    self.ue_config['apppath'] = ueobj.server_dir
                mutiue_imsi[idx] = ueobj.imsi
                mutiue_sn[idx] = ueobj.serial_number
                mutiue_appserver[idx] = ueobj.iperf_details
            self.ue_config['imsi'] = mutiue_imsi
            self.ue_config['sn'] = mutiue_sn
            self.ue_config['appserver'] = mutiue_appserver
            if get_spark_license:
                self.ue_config["licenseusername"] = ueobj.licensekeeper.username
                self.ue_config["licensepassword"] = ueobj.licensekeeper.password
        except BaseException as error:
            logging.info(
                "init config from robot testline failed : {}".format(
                    str(error)))
            self.ue_config = kwargs
        logging.info("ues config:{}".format(self.ue_config))
        return self.ue_config['host']

    def startapp(self, dur=10, timeout=300, reset=False):
        """
        Start App by schtasks cmd
        :param dur: check app setup interval time (s)
        :param timeout: check app setup timeout (s)
        :reset: force reset app tag
        :return None
        """
        pass

    def setup(self, conn=None, get_spark_license=True, max_ue_num=8, is_need_reconnect_spark=True):
        """
        Setup connection with sigspark TA client and connect ues
        """
        for i in range(5):
            try:
                if conn is None:
                    self.conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                    self.conn.settimeout(60)
                    self.conn.connect((self.ue_config['host'], self.ue_config['port']))
                else:
                    self.conn = conn
                if get_spark_license:
                    self._get_spark_license()
                ue_list_get_imsi_fail = self._connect_ues(max_ue_num=max_ue_num,
                                                          is_need_reconnect_spark=is_need_reconnect_spark)
                break
            except socket.error as msg:
                logging.info("Connect to server failed with Error: {}".format(msg))
                time.sleep(5)
        if i == 5:
            raise Exception("Socket failed after retry 5 times")
        logging.info("############# self.conn: {}".format(self.conn))
        logging.info("############# ue_list_get_imsi_fail: {}".format(ue_list_get_imsi_fail))
        return self.conn, ue_list_get_imsi_fail

    def teardown(self):
        """
        Close connection with sigspark TA client and disconnect ues
        """
        self._disconnect_ues()
        r = self.conn.close()

    def _send_msg(self, cmd, index, param=None):
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

    def _receive_msg(self, timeout=None):
        """
        Get message from sigspark client
        :return <dict>
        Example: {"CMD":"Attach","EQIndex":1,"Param":{"State":0}}
        """
        self.conn.settimeout(timeout)
        recv = self.conn.recv(1024)
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
                logging.info("receive response timeout, try again")
            retry = retry - 1
            if retry == 0:
                raise Exception(
                    "Can get response with '{}' !".format(
                        recv['CMD']))
        if recv['Param']['State'] == -1:
            raise Exception("Execute {} failed!".format(recv['CMD']))
        else:
            return recv['Param']

    def _get_multi_msg(self, cmds, timeout=100):
        recv = ""
        flag = 0

        self.conn.settimeout(60)
        start = time.time()
        while True:
            try:
                msg = self.conn.recv(1024)
                recv = recv + msg.decode()
                # recv = recv + msg
                recv = recv.replace("}{", "}||{")
                items = recv.split("||")
                num_recv = {}
                for cmd in cmds:
                    num_recv[cmd] = 0
                for item in items:
                    item = json.loads(item)
                    if item['CMD'] in num_recv:
                        num_recv[item['CMD']] = num_recv[item['CMD']] + 1

                for cmd in num_recv:
                    if num_recv[cmd] == cmds[cmd]:
                        flag = 1
                    else:
                        flag = 0
                        break
                if flag == 1:
                    logging.info("all msg received,return")
                    logging.info("Receive:{}".format(items))
                    return items
            except socket.timeout:
                logging.info("receive response timeout, try again!")
            end = time.time()
            if end - start >= timeout:
                logging.info("timeout break duration:{}".format(end - start))
                break
        return -1


class SigSparkMultiUEClient(InitClient, ADBClient):

    def __init__(self):
        super(SigSparkMultiUEClient, self).__init__()
        self.ueindex = {}
        self.ue_ip = {}

    def _get_spark_license(
            self,
            cmd="LoginAuth",
            license_server_ip="10.101.36.4",
            license_server_port=3002):
        """
        :param cmd: get spark license
        :return: None
        """
        param = {
            "IP": license_server_ip,
            "Port": license_server_port,
            "Account": self.ue_config["licenseusername"],
            "Password": self.ue_config["licensepassword"],
        }
        total_num = 5
        num = 0
        while num < total_num:
            num = num + 1
            self._send_common_msg(cmd, param=param)
            res = self._get_msg(cmd)
            res_state = res["State"]
            if res_state == 0:
                print("Get spark license success!")
                break
            elif res_state == 1:
                raise Exception("Login failed. The dog ID is not exist!")
            elif res_state == 2:
                print(
                    "Login failed, try again! The number of online users exceeded the limit!"
                )
            elif res_state == 4:
                raise Exception("Login failed. The password or account is error!")
            elif res_state == 5:
                raise Exception("Login failed. The Account is not exist!")
            elif res_state == 6:
                raise Exception(
                    "Login failed. all of the account password and dog ID should not be empty"
                )
            elif res_state == 7:
                raise Exception(
                    "Login failed. some invalid value, please check your configuration"
                )
            time.sleep(60)
        if num >= total_num:
            raise Exception("Get spark license failed after try 5 times!")

    def _release_license(self, cmd="LogoutAuth"):
        """
        :param cmd: log out license
        :return: None
        """
        self._send_common_msg(cmd)
        self._get_msg(cmd)

    def detach(self):
        num_detach = 0
        num_poweroff = 0
        for idx in self.multiue_traffic_config['ue_index_for_call']:
            if idx in self.ueindex:
                if self.multiue_traffic_config[idx]['power_reset'] == 'true':
                    self._send_msg(cmd="PowerOff", index=self.ueindex[idx])
                    num_poweroff += 1
                else:
                    self._send_msg(cmd="Detach", index=self.ueindex[idx])
                    num_detach += 1
        cmds = {}
        if num_poweroff != 0:
            cmds['PowerOff'] = num_poweroff
        if num_detach != 0:
            cmds['Detach'] = num_detach
        res = self._get_multi_msg(cmds)
        return res

    def detach_before_traffic(self):
        num_detach = 0
        num_poweroff = 0
        print("###########################################")
        print(self.multiue_traffic_config['ue_index_for_call'])
        print(self.ueindex)
        for idx in self.multiue_traffic_config['ue_index_for_call']:
            if idx in self.ueindex and self.multiue_traffic_config[idx]['detach_request'] == 'true':
                if self.multiue_traffic_config[idx]['power_reset'] == 'true':
                    self._send_msg(cmd="PowerOff", index=self.ueindex[idx])
                    num_poweroff += 1
                else:
                    self._send_msg(cmd="Detach", index=self.ueindex[idx])
                    num_detach += 1
        cmds = {}
        if num_poweroff != 0:
            cmds['PowerOff'] = num_poweroff
        if num_detach != 0:
            cmds['Detach'] = num_detach
        res = self._get_multi_msg(cmds)
        return res

    def attach(self, ue_mode=None, cmd="Attach"):
        """
        Attach UE (attach and setup pdu)
        :param cmd: Attach define by sigspark api
        :return  attach state
        """
        num_attach = 0
        num_poweron = 0
        for idx in self.multiue_traffic_config['ue_index_for_call']:

            if idx in self.ueindex and self.multiue_traffic_config[idx]['power_reset'] == 'true':
                self._send_msg(cmd="PowerOn", index=self.ueindex[idx])
                num_poweron += 1
            elif idx in self.ueindex:
                ue_mode = self.multiue_traffic_config[idx]['attach_mode']
                param = {"UEMode": ue_mode}
                self._send_msg(cmd="Attach", index=self.ueindex[idx], param=param)
                num_attach += 1
        cmds = {}
        if num_poweron != 0:
            cmds['PowerOn'] = num_poweron
        if num_attach != 0:
            cmds['Attach'] = num_attach
        res = self._get_multi_msg(cmds)
        return res

    def get_pdu_ip(self, apnaddress, index, cmd="GetPDUInfo", timeout=30):
        """
        Get IMSI and IP on UE
        :param pduid: GetParamIMSI define by sigspark api
        :return <str> imsi
        """
        param = {"APN": apnaddress}
        self._send_msg(cmd=cmd, index=index, param=param)

    def get_pdu_ip_by_AT(self, index, id=1, timeout=30000):
        """
        Get ueip via ATCOMMAND
        :param id: ATCOMMAND pdu id
        :return <str> ueip
        """
        param = {"Command": "AT+CGPADDR", "Timeout": timeout, "SuccStr": "+CGPADDR"}
        self._send_msg(cmd='SendAT', index=index, param=param)

    def get_imsi_by_AT(self, index=None, timeout=30):
        """
        Get imsi via ATCOMMAND
        :return <str> imsi
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            try:
                res = self.send_at_command(command="AT+CIMI", index=index)
                logging.info("################### res:{}".format(res))
                res = re.findall(r'(\d+)'.format(id), res)
                logging.info("################### res:{}".format(res))
                if len(res) > 0:
                    return res[0]
            except BaseException as error:
                logging.info("get imsi failed with error :{}".format(str(error)))
            time.sleep(2)
        else:
            logging.info("get ue{}'s imsi failed, Go to next ue".format(index))
        return ''

    def reconnect_ue_by_AT(self, index=None, timeout=20):
        """
        Recoonect UE via ATCOMMAND
        :return <str> None
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            try:
                res = self.send_at_command(command="AT+CFUN=1,1", index=index, succStr='')
                logging.info("################### res:{}".format(res))
                if len(res) > 0:
                    return res[0]
            except BaseException as error:
                logging.info("reconnect ue failed with error :{}".format(str(error)))
            time.sleep(2)
        else:
            logging.info("reconnect ue failed, Go to next ue".format(index))
        return ''

    def restart_5G_network_AT(self, index=None, timeout=20):
        """
        Restart UE 5G netwrok via ATCOMMAND
        :return <str> None
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            try:
                res1 = self.send_at_command(command='AT+QNWPREFCFG="nr5g_disable_mode",2', index=index)
                res2 = self.send_at_command(command='AT+QNWPREFCFG="mode_pref",NR5G', index=index)
                logging.info("################### res:{}".format(res1))
                if len(res1) > 0 and len(res2) > 0:
                    return res2[0]
            except BaseException as error:
                logging.info("restart ue 5G network failed with error :{}".format(str(error)))
            time.sleep(2)
        else:
            logging.info("restart ue 5G network failed, Go to next ue".format(index))
        return ''

    def set_SA_mode(self, index=None, timeout=20):
        """
        set UE to SA mode via ATCOMMAND
        :return <str> None
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            try:
                res1 = self.send_at_command(command="AT+QNWPREFCFG=\\\"nr5g_disable_mode\\\",0", succStr='',
                                            index=index)
                time.sleep(5)
                res2 = self.send_at_command(command="AT+QNWPREFCFG=\\\"mode_pref\\\",AUTO", succStr='',
                                            index=index)
                time.sleep(5)
                res3 = self.send_at_command(command="AT+QNWPREFCFG=\\\"nr5g_disable_mode\\\",2", succStr='',
                                            index=index)
                time.sleep(5)
                res4 = self.send_at_command(command="AT+QNWPREFCFG=\\\"mode_pref\\\",NR5G", succStr='',
                                            index=index)
                time.sleep(5)
                res5 = self.send_at_command(command="at+cgdcont=1,\\\"ip\\\",\\\"wap2.nokia.com\\\"", succStr='',
                                            index=index)
                time.sleep(5)
                logging.info("################### res:{}".format(res1))
                if len(res1) > 0 and len(res2) > 0:
                    return res2[0]
            except BaseException as error:
                raise Exception("set ue model to SA failed with error :{}".format(str(error)))
            time.sleep(2)
        else:
            logging.info("set ue model to SA failed, Go to next ue".format(index))
        return ''

    def set_NSA_mode(self, index=None, timeout=20):
        """
        set UE to NSA mode via ATCOMMAND
        :return <str> None
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            try:
                res1 = self.send_at_command(command="AT+QNWPREFCFG=\\\"nr5g_disable_mode\\\",0", succStr='',
                                            index=index, timeout=8000)
                time.sleep(5)
                print(res1)
                res2 = self.send_at_command(command="AT+QNWPREFCFG=\\\"mode_pref\\\",AUTO", succStr='',
                                            index=index, timeout=8000)
                time.sleep(5)
                res3 = self.send_at_command(command="AT+QNWPREFCFG=\\\"nr5g_disable_mode\\\",1", succStr='',
                                            index=index, timeout=8000)
                time.sleep(5)
                res4 = self.send_at_command(command="AT+QNWPREFCFG=\\\"mode_pref\\\",LTE:NR5G", succStr='',
                                            index=index, timeout=8000)
                time.sleep(5)
                res5 = self.send_at_command(command="at+cgdcont=1,\\\"ip\\\",\\\"dxdata1\\\"", succStr='',
                                            index=index, timeout=8000)
                time.sleep(5)
                logging.info("################### res:{}".format(res1))
                if len(res1) > 0 and len(res2) > 0:
                    return res2[0]
            except BaseException as error:
                raise Exception("set ue model to NSA failed with error :{}".format(str(error)))
            time.sleep(2)
        else:
            logging.info("set ue model to NSA failed, Go to next ue".format(index))
        return ''

    def reboot_UE_by_outage(self, index=None, timeout=120):
        """
        Power off UE by outage
        :return <str> None
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            try:
                res1 = self._send_msg(cmd="MTUPowerOff", index=index)
                time.sleep(20)
                res2 = self._send_msg(cmd="MTUPowerOn", index=index)
                time.sleep(100)
                logging.info("################### res:{}".format(res1))
                # if len(res1) > 0 and len(res2) > 0:
                #     return res2[0]
            except BaseException as error:
                raise Exception("reboot UE failed with error :{}".format(str(error)))
            time.sleep(2)
        else:
            logging.info("reboot UE failed failed, Go to next ue".format(index))
        return ''

    def start_ul_traffic(self, cmd="StartULtraffic", buffersize=1024, packetsize=1400):
        """
        Start UL traffic on UE
        :param cmd: Attach define by sigspark api
        :return None
        """
        for idx in self.multiue_traffic_config['ue_index_for_call']:
            if idx in self.ueindex:
                if self.multiue_traffic_config[idx]['multidrb_QoS_dest'] is None:
                    dest = self.ue_config['appserver'][idx].network_interface_address
                else:
                    dest = self.multiue_traffic_config[idx]['multidrb_QoS_dest']
                if self.multiue_traffic_config[idx]['iperf_port'] == 'default':
                    iperfport = self.ue_config['appserver'][idx].port
                else:
                    iperfport = self.multiue_traffic_config[idx]['iperf_port']
                tp, unit = re.match(r'(\d+)([@-~]*)/sec',
                                    self.multiue_traffic_config[idx]['ul']['target_throughput']).groups()
                tp = int(tp)
                if "Bytes" in unit:
                    tp = tp * 8
                if "M" in unit:
                    tp = tp * 1024
                if "G" in unit:
                    tp = tp * 1024 * 1024
                protocol = self.multiue_traffic_config[idx]['protocol'].upper()
                param = {
                    "Protocol": protocol,
                    "Address": dest,
                    "Port": iperfport,
                    "TestTime": self.multiue_traffic_config[idx]['ul']['duration'],
                    "Bandwidth": tp,
                    "BufferSize": buffersize,
                    "PacketSize": packetsize}
                self._send_msg(cmd=cmd, param=param, index=self.ueindex[idx])
        cmd = {}
        cmd['StartULtraffic'] = len(self.ueindex)
        res = self._get_multi_msg(cmd)
        return res

    def start_dl_traffic(self, process=1, buffer=1024):
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
        num_SendAT = 0
        num_GetPduInfo = 0
        for idx in self.multiue_traffic_config['ue_index_for_call']:
            if idx in self.ueindex and self.multiue_traffic_config[idx]['ue_mode'] == "SA":
                self.get_pdu_ip(apnaddress=self.multiue_traffic_config[idx]['apn'], index=self.ueindex[idx])
                num_GetPduInfo += 1
            elif idx in self.ueindex:
                self.get_pdu_ip_by_AT(id=1, index=self.ueindex[idx])
                num_SendAT += 1

        cmds = {}
        if num_GetPduInfo != 0:
            cmds['GetPDUInfo'] = num_GetPduInfo
        if num_SendAT != 0:
            cmds['SendAT'] = num_SendAT
        result = self._get_multi_msg(cmds)
        for res in result:
            ip = ''
            ue_index = 0
            res = json.loads(res)
            if res['CMD'] == 'GetPDUInfo':
                if res['Param']['IP'] != '':
                    ip = res['Param']['IP'].split(":")[-1]
                    ue_index = res['EQIndex']
                else:
                    ip = ''
                    ue_index = res['EQIndex']
                    logging.info("ue index: {},get pdu ip fail".format(res['EQIndex']))
            elif res['CMD'] == 'SendAT':
                tmp = res['Param']['Back'].strip()
                tmp = re.findall(
                            r'\+CGPADDR: ' +
                            str(1) +
                            r',"?((\d+\.?){4})"?',
                            tmp)
                if len(tmp) > 0:
                    ip = tmp[0][0]
                    ue_index = res['EQIndex']
                else:
                    ip = ''
                    ue_index = res['EQIndex']
                    logging.info("ue index: {},get pdu ip fail".format(res['EQIndex']))
            for idx in self.ueindex:
                if ue_index == self.ueindex[idx]:
                    self.ue_ip[idx] = ip
                    break

        logging.info("ue_ip:{}".format(self.ue_ip))

        for idx in self.multiue_traffic_config['ue_index_for_call']:
            if idx in self.ueindex:
                if self.multiue_traffic_config[idx]['iperf_port'] == 'default':
                    iperfport = self.ue_config['appserver'][idx].port
                else:
                    iperfport = self.multiue_traffic_config[idx]['iperf_port']
                tp, unit = re.match(r'(\d+)([@-~]*)/sec',
                                    self.multiue_traffic_config[idx]['dl']['target_throughput']).groups()
                tp = int(tp)
                if "Bytes" in unit:
                    tpstr = "{}K".format(tp)
                if "M" in unit:
                    tpstr = "{}M".format(tp)
                if "G" in unit:
                    tpstr = "{}G".format(tp)
                iperf_path = self.ue_config['appserver'][idx].iperf_path
                ip = self.ue_ip[idx]
                if ip == '':
                    logging.info("ue index: {} get pdu ip fail,so start dl traffic fail".format(self.ueindex[idx]))
                else:
                    cmd = "{} -c {} -u -t {} -i 1 -p {} -P {} -f m -b {} -l {}B -T 64".format(
                        iperf_path, ip, self.multiue_traffic_config[idx]['dl']['duration'], iperfport,
                        process, tpstr, buffer)
                    logging.info("ue index: {} start DL taffic cmd: {}".format(idx, cmd))
                    sshconn = self._appserver_connect(conn=self.multiue_traffic_config[idx]['dt_name'],
                                                      index=idx)
                    sshconn.send_command(command=cmd, connection=self.multiue_traffic_config[idx]['dt_name'])
                    sshconn.disconnect(connection=self.multiue_traffic_config[idx]['dt_name'])

    def TL750_start_dl_traffic(self):
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
        num_SendAT = 0
        num_GetPduInfo = 0
        for idx in self.multiue_traffic_config['ue_index_for_call']:
            if idx in self.ueindex and self.multiue_traffic_config[idx]['ue_mode'] == "SA":
                self.get_pdu_ip(apnaddress=self.multiue_traffic_config[idx]['apn'], index=self.ueindex[idx])
                num_GetPduInfo += 1
            elif idx in self.ueindex:
                self.get_pdu_ip_by_AT(id=1, index=self.ueindex[idx])
                num_SendAT += 1

        cmds = {}
        if num_GetPduInfo != 0:
            cmds['GetPDUInfo'] = num_GetPduInfo
        if num_SendAT != 0:
            cmds['SendAT'] = num_SendAT
        result = self._get_multi_msg(cmds)
        for res in result:
            ip = ''
            ue_index = 0
            res = json.loads(res)
            if res['CMD'] == 'GetPDUInfo':
                if res['Param']['IP'] != '':
                    ip = res['Param']['IP'].split(":")[-1]
                    ue_index = res['EQIndex']
                else:
                    ip = ''
                    ue_index = res['EQIndex']
                    logging.info("ue index: {},get pdu ip fail".format(res['EQIndex']))
            elif res['CMD'] == 'SendAT':
                tmp = res['Param']['Back'].strip()
                tmp = re.findall(
                            r'\+CGPADDR: ' +
                            str(1) +
                            r',"?((\d+\.?){4})"?',
                            tmp)
                if len(tmp) > 0:
                    ip = tmp[0][0]
                    ue_index = res['EQIndex']
                else:
                    ip = ''
                    ue_index = res['EQIndex']
                    logging.info("ue index: {},get pdu ip fail".format(res['EQIndex']))
            for idx in self.ueindex:
                if ue_index == self.ueindex[idx]:
                    self.ue_ip[idx] = ip
                    break

        logging.info("ue_ip:{}".format(self.ue_ip))

        for idx in self.multiue_traffic_config['ue_index_for_call']:
            if idx in self.ueindex:
                if self.multiue_traffic_config[idx]['iperf_port'] == 'default':
                    iperfport = self.ue_config['appserver'][idx].port
                else:
                    iperfport = self.multiue_traffic_config[idx]['iperf_port']
                tp, unit = re.match(r'(\d+)([@-~]*)/sec',
                                    self.multiue_traffic_config[idx]['dl']['target_throughput']).groups()
                tp = int(tp)
                if "Bytes" in unit:
                    tpstr = "{}K".format(tp)
                if "M" in unit:
                    tpstr = "{}M".format(tp)
                if "G" in unit:
                    tpstr = "{}G".format(tp)
                iperf_path = self.ue_config['appserver'][idx].iperf_path
                ip = self.ue_ip[idx]
                if ip == '':
                    logging.info("ue index: {} get pdu ip fail,so start dl traffic fail".format(self.ueindex[idx]))
                else:
                    cmd = "{} -c {} -u -t {} -i 1 -p {} -b {} -l 1500B -T 64 -P 2".format(
                        iperf_path, ip, self.multiue_traffic_config[idx]['dl']['duration'], iperfport, tpstr)
                    sshconn = self._appserver_connect(conn=self.multiue_traffic_config[idx]['dt_name'],
                                                      index=idx)
                    sshconn.send_command(command=cmd, connection=self.multiue_traffic_config[idx]['dt_name'])
                    sshconn.disconnect(connection=self.multiue_traffic_config[idx]['dt_name'])
        UE_IP = self.ue_ip
        return UE_IP

    def get_ue_ip_client(self):
        num_SendAT = 0
        num_GetPduInfo = 0
        for idx in self.multiue_traffic_config['ue_index_for_call']:
            if idx in self.ueindex and self.multiue_traffic_config[idx]['ue_mode'] == "SA":
                self.get_pdu_ip(apnaddress=self.multiue_traffic_config[idx]['apn'], index=self.ueindex[idx])
                num_GetPduInfo += 1
            elif idx in self.ueindex:
                self.get_pdu_ip_by_AT(id=1, index=self.ueindex[idx])
                num_SendAT += 1

        cmds = {}
        if num_GetPduInfo != 0:
            cmds['GetPDUInfo'] = num_GetPduInfo
        if num_SendAT != 0:
            cmds['SendAT'] = num_SendAT
        result = self._get_multi_msg(cmds)
        for res in result:
            ip = ''
            ue_index = 0
            res = json.loads(res)
            if res['CMD'] == 'GetPDUInfo':
                if res['Param']['IP'] != '':
                    ip = res['Param']['IP'].split(":")[-1]
                    ue_index = res['EQIndex']
                else:
                    ip = ''
                    ue_index = res['EQIndex']
                    logging.info("ue index: {},get pdu ip fail".format(res['EQIndex']))
            elif res['CMD'] == 'SendAT':
                tmp = res['Param']['Back'].strip()
                tmp = re.findall(
                    r'\+CGPADDR: ' +
                    str(1) +
                    r',"?((\d+\.?){4})"?',
                    tmp)
                if len(tmp) > 0:
                    ip = tmp[0][0]
                    ue_index = res['EQIndex']
                else:
                    ip = ''
                    ue_index = res['EQIndex']
                    logging.info("ue index: {},get pdu ip fail".format(res['EQIndex']))
            for idx in self.ueindex:
                if ue_index == self.ueindex[idx]:
                    self.ue_ip[idx] = ip
                    break
        return self.ue_ip

    def stop_dl_traffic(self, iperf_port=None, apnaddress="wap1nokiacom", ue_mode="SA"):
        """
        Stop DL traffic
        :param iperf_port: port value of traffic, it can be get from __int__.py file or TCs eg: 50001
        :param apnaddress: apn address of PDU, only used when ue mode is SA
        :ue_mode: SA or NSA
        :return None
        """
        for idx in self.multiue_traffic_config['ue_index_for_call']:
            if idx in self.ue_ip:
                if self.multiue_traffic_config[idx]['iperf_port'] == 'default':
                    iperfport = self.ue_config['appserver'][idx].port
                else:
                    iperfport = self.multiue_traffic_config[idx]['iperf_port']

                ip = self.ue_ip[idx]
                cmd = "ps aux |grep iperf |grep " + \
                    str(ip) + " |grep " + str(iperfport) + " |awk '{print $2}' | xargs kill -9"
                sshconn = self._appserver_connect(conn='killdl', index=idx)
                sshconn.send_command(command=cmd, connection="killdl")
                sshconn.disconnect(connection="killdl")

    def stop_ul_traffic(self, cmd="StopTest"):
        """
        Stop UL traffic on UE
        :return None
        """
        self._send_msg(cmd=cmd, index=-1)
        self._get_msg(cmd=cmd, index=-1)

    def get_lte_tp(self, cmd="GetParamValue"):
        """
        Get lte throughput on UE
        :param param:  <list> param with sigspark format
        :param cmd: GetParamValue define by sigspark api
        :return None
        """
        param = "['LTE PHY Thr. DL [Mbps]','LTE PHY Thr. UL [Mbps]']"
        for idx in self.multiue_traffic_config['ue_index_for_call']:
            if idx in self.ueindex:
                self._send_msg(cmd=cmd, index=self.ueindex[idx], param=param)
        cmd = {}
        cmd['GetParamValue'] = len(self.ueindex)
        result = self._get_multi_msg(cmd)
        index_checkthroughput_fail = []

        for res in result:
            res = json.loads(res)
            if res['Param']['Values'][0] != "" or res['Param']['Values'][1] != "":
                ul_actual_tput = float(res['Param']['Values'][1])
                dl_actual_tput = float(res['Param']['Values'][0])
                for idx in self.ueindex:
                    if res['EQIndex'] == self.ueindex[idx]:
                        target_percent = float(self.multiue_traffic_config[idx]['target_percent'])
                        ul_tput = float(self.multiue_traffic_config[idx]['ul']['target_throughput'][0:-10])
                        dl_tput = float(self.multiue_traffic_config[idx]['dl']['target_throughput'][0:-10])

                        ul_target = ul_tput * target_percent
                        dl_target = dl_tput * target_percent
                        logging.info(
                            'UE Index:{}, lte ul target throughput:{}Mbits/sec, ul actual throughput:{}Mbits/sec'
                            .format(res['EQIndex'], ul_target, ul_actual_tput))
                        logging.info(
                            'UE Index:{}, lte dl target throughput:{}Mbits/sec, dl actual throughput:{}Mbits/sec'
                            .format(res['EQIndex'], dl_target, dl_actual_tput))
                        if ul_actual_tput < ul_target or dl_actual_tput < dl_target:
                            index_checkthroughput_fail.append(res['EQIndex'])
                        break
            else:
                raise Exception("Get param_value failed, param_value should not be none!")
        if len(index_checkthroughput_fail) != 0:
            raise Exception("Ue Index {} check lte throughput fail!".format(index_checkthroughput_fail))

    def get_mac_tp(self, cmd="GetParamMAC"):
        """
        Get throughput on UE
        :param cmd: GetParamMAC define by sigspark api
        :return <tuple> (ul , dl)  (byte)
        """
        for idx in self.multiue_traffic_config['ue_index_for_call']:
            if idx in self.ueindex:
                self._send_msg(cmd=cmd, index=self.ueindex[idx])
        cmd = {}
        cmd['GetParamMAC'] = len(self.ueindex)
        result = self._get_multi_msg(cmd)
        index_checkthroughput_fail = []

        for res in result:
            res = json.loads(res)
            ul_actual_tput = float(res['Param']['MACUL'] / 1024 / 1024)
            dl_actual_tput = float(res['Param']['MACDL'] / 1024 / 1024)
            for idx in self.ueindex:
                if res['EQIndex'] == self.ueindex[idx]:
                    target_percent = float(self.multiue_traffic_config[idx]['target_percent'])
                    ul_tput = float(self.multiue_traffic_config[idx]['ul']['target_throughput'][0:-10])
                    dl_tput = float(self.multiue_traffic_config[idx]['dl']['target_throughput'][0:-10])

                    ul_target = ul_tput * target_percent
                    dl_target = dl_tput * target_percent
                    logging.info('UE Index:{}, ul target throughput:{}MKbits/sec, ul actual throughput:{}MKbits/sec'
                                 .format(res['EQIndex'], ul_target, ul_actual_tput))
                    logging.info('UE Index:{}, dl target throughput:{}MKbits/sec, dl actual throughput:{}MKbits/sec'
                                 .format(res['EQIndex'], dl_target, dl_actual_tput))
                    if ul_actual_tput < ul_target or dl_actual_tput < dl_target:
                        index_checkthroughput_fail.append(res['EQIndex'])
                    break
        if len(index_checkthroughput_fail) != 0:
            raise Exception("Ue Index {} check throughput fail!".format(index_checkthroughput_fail))

    def operate_ue_dataservice(self, action='enable'):
        self.setup_adb_connect(alias='sigspark')
        cmd = "svc data {}".format(action)
        for idx in self.multiue_traffic_config['ue_index_for_call']:
            self.send_adb_command(command=cmd, alias='sigspark', sn=self.ue_config['sn'][idx])

    def send_at_command(self, command="AT", timeout=5000, cmd='SendAT', succStr='\r\n\r\nOK', index=None):
        """
        Send ATCOMMAND via sigspark
        :param command: ATCOMMAND define on 3gpp
        :param timeout: Get return timeout
        :param cmd: SendAT define by sigspark api
        :return <str> response of ATCOMMAND
        """
        param = {"Command": command, "Timeout": timeout, "SuccStr": succStr}
        self._send_msg(cmd=cmd, index=index, param=param)
        res = self._get_msg(cmd=cmd, index=index, timeout=5)
        return res['Back'].strip()

    def send_adb_command(self, command, alias, sn, timeout=30, interval=2):
        """
        Send adb command via ssh connection with UE control PC
        :param command: ADB command
        :param alias: connection alias
        :param timeout: waittime unitl action successful
        :param interval: retry action interval
        :return: None
        """
        adbpath = self.ue_config['apppath'].replace("Spark.exe", "adb.exe")
        cmd = "'{}' -s {} shell {}".format(adbpath, sn, command)
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
        try:
            res = sshconn.connect_to(
                self.ue_config['host'],
                self.ue_config['username'],
                self.ue_config['password'],
                alias='sigspark',
                look_for_keys=False)
            logging.info("SSH to Control PC success:{}".format(str(res)))
        except BaseException as error:
            logging.info("SSH to Control PC Error : {}".format(str(error)))
            pingcmd = "ping -c 4 {} >ping.txt".format(self.ue_config['host'])
            logging.info(pingcmd)
            os.system(pingcmd)
            try:
                f = open('ping.txt', 'r')
                logging.info(f.read())
            finally:
                if f:
                    f.close()
        ta_status_cmd = "netstat -ano|findstr :{}".format(
            self.ue_config['port'])
        check_app_status = "tasklist | findstr Spark.exe"
        endtime = time.time() + 10
        while endtime > time.time() and reset is False:
            res = sshconn.execute(command=ta_status_cmd, connection='sigspark')
            if ":{}".format(self.ue_config['port']) in res or reset:
                app_status = sshconn.execute(command=check_app_status, connection='sigspark')
                if "Spark.exe" in app_status:
                    sshconn.disconnect(connection='sigspark')
                    return True
        else:
            restart_cmds = [
                "taskkill /f /im SSSRXX.exe",
                "taskkill /f /im adb.exe",
                "taskkill /f /im Spark.exe",
                "schtasks /end /tn spark",
                "schtasks /delete /tn spark /f",
                "schtasks /create /tn spark /sc once /tr '{}' /st 00:00 /RL highest /f".format(
                    self.ue_config['apppath']),
                "schtasks /run /tn spark"]
            for cmd in restart_cmds:
                sshconn.execute(command=cmd, connection='sigspark')
                time.sleep(2)
            while timeout >= 0:
                res = sshconn.execute(
                    command=ta_status_cmd, connection='sigspark')
                if ":{}".format(self.ue_config['port']) in res:
                    break
                else:
                    time.sleep(dur)
                    timeout = timeout - dur
                    if timeout <= 0:
                        raise Exception(
                            "Check TA port {} timeout".format(
                                self.ue_config['port']))
            sshconn.disconnect(connection='sigspark')
            return False

    def restart_uemanager(self):
        """
        Restart Uemanager
        :return: None
        """
        self.setup_adb_connect(alias='sigspark')
        cmd1 = "am force-stop com.ue.dmanager"
        cmd2 = (
            "am start -a android.intent.action.MAIN -c "
            "android.intent.category.LAUNCHER -n com.ue.dmanager/com.box.test.MainActivity")
        for idx in self.multiue_traffic_config['ue_index_for_call']:
            if self.multiue_traffic_config[idx]['reset_sol'] != 'none':
                self.send_adb_command(command=cmd1, alias='sigspark', sn=self.ue_config['sn'][idx])
                self.send_adb_command(command=cmd2, alias='sigspark', sn=self.ue_config['sn'][idx])

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
            alias='sigspark',
            look_for_keys=False)
        sshconn.download_file(localfile, logpath, connection='sigspark')
        sshconn.disconnect(connection='sigspark')

    def export_log_file(
            self,
            logpath,
            localpath,
            localname,
            ue_index,
            template='auto_test',
            cmd="ExportLogfile"):
        """
        export filter log file to csv and download to UTE
        :param logpath: log full path for saving on UTE
        :param template: filter template name on spark
        :return None
        """
        localfile = "{}/{}-{}.csv".format(localpath, localname, ue_index)
        localsaf = "{}/{}-{}.saf".format(localpath,
                                         localname, ue_index)
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
            alias='sigspark',
            look_for_keys=False)
        logpath = "{}/UE-{}.csv".format(logpath, ue_index)
        sshconn.download_file(localfile, logpath, connection='sigspark')

    def _connect_ues(self, cmd="ConnectEQ", max_ue_num=8, is_need_reconnect_spark=True):
        """
        Connect all UEs on controlpc
        :param cmd: ConnectEQ define by sigspark api
        :return None
        """
        ue_num = self._auto_check()
        ue_num = int(ue_num)
        sn_adb_list = "adb devices"
        logging.info("################# ues ue_num:{}".format(ue_num))
        ue_list_get_imsi_fail = []
        if ue_num > 0:
            if is_need_reconnect_spark:
                self._send_common_msg("DisConnectEQ")
                time.sleep(10)
                self._send_common_msg(cmd)
                self._get_msg(cmd=cmd, timeout=600)
                time.sleep(10)
            for idx in self.ue_config['sn']:
                # self.ueindex[idx] = int(idx) + 1
                self.ueindex[idx] = int(idx) % max_ue_num + 1
            logging.info("################# ueindex:{}".format(self.ueindex))
            return ue_list_get_imsi_fail
        else:
            self.teardown()
            raise Exception("No UE find on PC!")
        return None

    def _auto_check(self, cmd="AutoCheck"):
        """
        Auto check sigspark UEs connect on controlpc
        :param cmd: AutoCheck define by sigspark api
        :return <int> number of UEs
        """
        self._send_common_msg(cmd)
        res = self._get_msg(cmd)
        return res['Count']

    def _appserver_connect(self, conn, index):
        """
        Connect to appserver by ssh
        :param conn: conn alias
        :return ssh connection
        """
        hostname = self.ue_config['appserver'][index].ssh_connection_details.addr
        username = self.ue_config['appserver'][index].ssh_connection_details.username
        password = self.ue_config['appserver'][index].ssh_connection_details.password
        sshconn = ssh.ssh()
        sshconn.connect_to(
            hostname=hostname,
            username=username,
            password=password,
            alias=conn,
            look_for_keys=False)
        return sshconn


class SigSparkMutiUE():

    def __init__(self):
        self.store = {}
        self.client = {}

    def _update_socket_conn(self, serverip, conn):
        """
        Update client socket connection when restart socket client
        :param serverip: Controlpc ip
        :param conn: socket connection object
        """
        for alias in self.store:
            if self.store[alias].ue_config['host'] == serverip:
                self.store[alias].conn = conn

    def require_platform(self, ue_alias, multiue_traffic_config, restart_ue, restart_network, get_spark_license=True,
                         max_ue_num=8, is_need_reconnect_spark=True):
        """
        Require platform to prepare like sigspark or Pioneer to start and remote connecting create
        :return client
        """
        client = SigSparkMultiUEClient()
        serverip = client.init_config(multiue_traffic_config=multiue_traffic_config,
                                      get_spark_license=get_spark_license)
        if restart_ue:
            for idx in client.ueindex:
                client.reconnect_ue_by_AT(index=client.ueindex[idx])
        if restart_network:
            for idx in client.ueindex:
                client.restart_5G_network_AT(index=client.ueindex[idx])
        res = client.startapp()
        logging.info("################# serverip:{}".format(serverip))
        logging.info("################# res:{}".format(res))
        logging.info("################# self.client:{}".format(self.client))
        if serverip in self.client and res:
            conn, ue_get_imsi_fail = client.setup(self.client[serverip]['conn'], get_spark_license=get_spark_license,
                                                  max_ue_num=max_ue_num,
                                                  is_need_reconnect_spark=is_need_reconnect_spark)
        else:
            conn, ue_get_imsi_fail = client.setup(get_spark_license=get_spark_license, max_ue_num=max_ue_num,
                                                  is_need_reconnect_spark=is_need_reconnect_spark)
            self._update_socket_conn(serverip, conn)
            self.client[serverip] = {"conn": conn, 'log': {'state': 0}}
        client.restart_uemanager()
        self.store[ue_alias] = client
        print("########### client ############")
        print(client)
        print(ue_get_imsi_fail)
        return client, ue_get_imsi_fail

    def require_ue(self, ue_alias, multiue_traffic_config, restart_ue=False, restart_network=False,
                   get_spark_license=True, max_ue_num=8, is_need_reconnect_spark=True, prepare_ue=True):
        """
        Require UE
        :param ue_alias:<str> store ue by ue_alias
        :return None
        """
        client, ue_Getimsifail = self.require_platform(ue_alias=ue_alias,
                                                       multiue_traffic_config=multiue_traffic_config,
                                                       restart_ue=restart_ue,
                                                       restart_network=restart_network,
                                                       get_spark_license=get_spark_license,
                                                       max_ue_num=max_ue_num,
                                                       is_need_reconnect_spark=is_need_reconnect_spark)
        if prepare_ue:
            try:
                client.operate_ue_dataservice(action="disable")
            except BaseException:
                pass
            try:
                client.stop_log()
            except BaseException:
                pass
            try:
                client.stop_ul_traffic()
            except BaseException:
                pass
            try:
                client.detach_before_traffic()
            except BaseException:
                pass
        self.store[ue_alias] = client
        logging.info("###############  store[ue_alias]:{}".format(self.store[ue_alias]))
        if len(ue_Getimsifail) > 0:
            raise Exception("UE index {} get imsi fail!".format(ue_Getimsifail))

    def attach_ue(self, ue_alias):
        """
        Attach UE
        :param ue_alias:<str> store ue by ue_alias
        :param attach_mode:<str> 5G_SA 5G_NSA use to check whether 4G attach success or 5G attach success
        :param power_reset: <str> true or false, if true, attach_ue will use power on
        :param timeout: not used, adapt to MTK api
        :return None
        """
        res = self.store[ue_alias].attach()
        time.sleep(15)
        # logging.info("it's already sleep 30 seconds")
        return res

    def detach_ue(self, ue_alias):
        """
        Detach UE
        :param ue_alias:<str> store ue by ue_alias
        :param power_reset: <str> true or false, if true, detach ue will use power off
        :param timeout: not used, adapt to MTK api
        :return None
        """
        res = self.store[ue_alias].detach()
        return res

    def start_data_transfer(self, ue_alias, direction, process=1, buffer=1024):
        """
        Start traffic
        :param ue_alias: <str> store ue by ue_alias
        :param direction: ul/dl
        :return None
        """
        """
        EXPLANATION
        sigpark still use adb command to disable/enable mobile data because of some ues do not
        support spark command TurnOffMobileData/TurnOnMobileData, such as Qualcomm/spark modle
        so sigspark.py use a temp solution adb to adapt different kinds of UEs
        """
        self.store[ue_alias].operate_ue_dataservice(action='enable')
        time.sleep(10)
        if direction == "ul":
            self.store[ue_alias].start_ul_traffic()
            time.sleep(30)
        elif direction == "dl":
            self.store[ue_alias].start_dl_traffic(process=process, buffer=buffer)

    def TL750_start_data_transfer(self, ue_alias, direction):
        """
        Start traffic
        :param ue_alias: <str> store ue by ue_alias
        :param direction: ul/dl
        :return None
        """
        """
        EXPLANATION
        sigpark still use adb command to disable/enable mobile data because of some ues do not
        support spark command TurnOffMobileData/TurnOnMobileData, such as Qualcomm/spark modle
        so sigspark.py use a temp solution adb to adapt different kinds of UEs
        """
        self.store[ue_alias].operate_ue_dataservice(action='enable')
        time.sleep(10)
        if direction == "ul":
            self.store[ue_alias].start_ul_traffic()
            time.sleep(30)
        elif direction == "dl":
            self.store[ue_alias].TL750_start_dl_traffic()

    def stop_data_transfer(self, direction, ue_alias):
        """
        stop traffic
        :param ue_alias: <str> store ue by ue_alias
        :return None
        """
        if direction == "ul":
            self.store[ue_alias].stop_ul_traffic()
        elif direction == "dl":
            self.store[ue_alias].stop_dl_traffic()

    def check_throughput_on_ue(self, ue_alias):
        """
        Check throughput on ue
        :param ue_alias: <str> store ue by ue_alias
        :return <tuple> (ul , dl)  (byte)
        """
        res = self.store[ue_alias].get_mac_tp()
        return res

    def check_lte_throughput_on_ue(self, ue_alias):
        """
        Check throughput on ue
        :param ue_alias: <str> store ue by ue_alias
        :return <tuple> (ul , dl)  (Mbit)
        """
        res = self.store[ue_alias].get_lte_tp()
        return res

    def start_log(self, ue_alias):
        """
        Start capture log on spark
        Logpath is in spark install path,
        such as "C:/Program Files (x86)/Spark/Data/Auto/1587435380"
        :param ue_alias: <str> store ue by ue_alias
        :return None
        """
        serverip = self.store[ue_alias].ue_config['host']
        if self.client[serverip]['log']['state'] == 0:
            loginfo = self.store[ue_alias].start_log()
            self.client[serverip]['log']['state'] = 1
            self.client[serverip]['log']['logpath'] = loginfo[0]
            self.client[serverip]['log']['logname'] = loginfo[1]
        else:
            logging.info(
                "Nothing to do, Log process is already started! Localfile:{}/{}" .format(
                    self.client[serverip]['log']['logpath'],
                    self.client[serverip]['log']['logname']))

    def stop_log(self, ue_alias):
        """
        Stop capture log on spark, export and downlaod to UTE
        :param ue_alias: <str> store ue by ue_alias
        :logname:<str> logname for saving on UTE
        :filter:<str> filter template name on spark(need set on spark)
        :return None
        """
        serverip = self.store[ue_alias].ue_config['host']
        localpath = self.client[serverip]['log']['logpath']
        localname = self.client[serverip]['log']['logname']
        if self.client[serverip]['log']['state'] == 1:
            logging.info("Stopping log process!")
            self.store[ue_alias].stop_log()
            self.client[serverip]['log']['state'] = 0
        else:
            logging.info(
                "Log process already stopped! Localfile:{}/{}".format(localpath, localname))

    def export_log_file(self, ue_alias, logpath, filter):
        """
        export spark log and covert it to csv file
        :param ue_alias: <str> store ue by ue_alias
        :logpath:<str> logpath for saving on UTE
        :filter:<str> filter template name on spark(need set on spark)
        :return None
        """
        serverip = self.store[ue_alias].ue_config['host']
        localpath = self.client[serverip]['log']['logpath']
        localname = self.client[serverip]['log']['logname']
        logging.info("ueindex:{}".format(self.store[ue_alias].ueindex))
        for idx in self.store[ue_alias].ueindex:
            self.store[ue_alias].export_log_file(
                logpath=logpath, template=filter, ue_index=self.store[ue_alias].ueindex[idx],
                localpath=localpath, localname=localname)
        return self.store[ue_alias].ueindex

    def get_ue_ip(self, ue_alias):
        return self.store[ue_alias].get_ue_ip_client()

    def Change_network_mode(self, ue_alias, if_SA):
        """
        Change the SA or NSA mode of UE by issuing the AT command
        :param ue_alias: <str> store ue by ue_alias
        :if_SA: <Bool>  representative SA or NSA
        :return None
        """
        if if_SA is True:
            for idx in self.store[ue_alias].ueindex:
                self.store[ue_alias].set_SA_mode(index=self.store[ue_alias].ueindex[idx], timeout=20)
        else:
            for idx in self.store[ue_alias].ueindex:
                self.store[ue_alias].set_NSA_mode(index=self.store[ue_alias].ueindex[idx], timeout=20)

    def reboot_UE_by_outage(self, ue_alias):
        """
        Reboot UE by Outage
        :param ue_alias: <str> store ue by ue_alias
        :return None
        """
        for idx in self.store[ue_alias].ueindex:
            self.store[ue_alias].reboot_UE_by_outage(index=self.store[ue_alias].ueindex[idx], timeout=120)

    def lockUeWithPciAndFreq(self, ue_alias, lock_info, retry=3):
        result_print = []
        client = self.store[ue_alias]
        for idx, eqindex in client.ueindex.items():
            print(f'idx:{idx}, client.ueindex:{client.ueindex}')
            pci = lock_info[str(idx)]['pci']
            freq = lock_info[str(idx)]['ssb_freq']
            scs = lock_info[str(idx)]['scs']
            band = lock_info[str(idx)]['band']
            command = fr'at+qnwlock="common/5g",{pci},{freq},{scs},{band}'
            num, isOK = 1, False
            while (num <= retry and isOK is False):
                res = client.send_at_command(index=eqindex, command=command, timeout=10000)
                time.sleep(3)
                logging.info(f"UE{eqindex}, retry:{num}, result:{res}")
                isOK = True if res.strip() == 'OK' else False
                num += 1
            result_print.append(f'UE{eqindex}, retry:{num-1}, result:{res}')
        return result_print

    def unlockUeWithPciAndFreq(self, ue_alias, retry=3):
        result_print = []
        client = self.store[ue_alias]
        for idx, eqindex in client.ueindex.items():
            command = fr'at+qnwlock="common/5g",0'
            num, isOK = 1, False
            while (num <= retry and isOK is False):
                res = client.send_at_command(index=eqindex, command=command, timeout=10000)
                time.sleep(3)
                logging.info(f"UE{eqindex}, retry:{num}, result:{res}")
                isOK = True if res.strip() == 'OK' else False
                num += 1
            result_print.append(f'UE{eqindex}, retry:{num-1}, result:{res}')
        return result_print
