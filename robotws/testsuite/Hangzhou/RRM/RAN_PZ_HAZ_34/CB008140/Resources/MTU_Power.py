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

    def restart_uemanager(self):
        """
        Restart Uemanager
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


class InitClient():

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

    def setup_MTU(self, conn=None, get_spark_license=True):
        """
        Setup connection with sigspark TA client and connect ues
        """
        self.store = {}
        num = 5
        for i in range(num):
            try:
                if conn is None:
                    self.conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                    self.conn.settimeout(600)
                    self.conn.connect((self.ue_config['host'], self.ue_config['port']))
                else:
                    self.conn = conn
                if get_spark_license:
                    self._get_spark_license()
                break
            except socket.error as msg:
                print("=====Connect to server failed with Error: {}=====".format(msg))
                time.sleep(5)
        if i >= (num - 1):
            raise Exception("=====Socket failed after retry 5 times=====")
        return self.conn

    def connect_socket(self):
        self.conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.conn.settimeout(600)
        self.conn.connect((self.ue_config['host'], self.ue_config['port']))
        return self.conn

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
        if index:
            msg['EQIndex'] = index
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


class BaseClient(InitClient, ADBClient):

    def _auto_check(self, cmd="AutoCheck"):
        """
        Auto check sigspark UEs connect on controlpc
        :param cmd: AutoCheck define by sigspark api
        :return <int> number of UEs
        """
        self._send_common_msg(cmd)
        res = self._get_msg(cmd)
        return res['Count']

    def stop_log(self, cmd="StopLog"):
        """
        Stop sigspark log on controlpc
        :param cmd: StopLog define by sigspark api
        :return None
        """
        self._send_common_msg(cmd)
        self._get_msg(cmd)

    def get_imsi_by_AT(self, index=None, timeout=30):
        """
        Get imsi via ATCOMMAND
        :return <str> imsi
        """
        endtime = time.time() + timeout
        while endtime > time.time():
            try:
                res = self.get_imsi(command="AT+CIMI", index=index)
                res = re.findall(r'(\d+)'.format(id), res)
                if len(res) > 0:
                    return res[0]
            except BaseException as error:
                logging.info("get imsi failed with error :{}".format(str(error)))
            time.sleep(2)
        else:
            print("get ue{}'s imsi failed, Go to next ue".format(index))

    def get_imsi(
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
        param = {"Command": command, "Timeout": timeout, "SuccStr": "\r\n\r\nOK"}
        if index is None:
            self._send_msg(cmd, param=param)
        else:
            self._send_msg(cmd, index=index, param=param)
        if index is None:
            res = self._get_msg(cmd=cmd, timeout=5)
        else:
            res = self._get_msg(cmd=cmd, index=index, timeout=5)
        return res['Back'].strip()

    def mtu_poweron(self, index=1, cmd="MTUPowerOn"):
        """
        Shutdown RF on UE (not reboot)
        :param cmd: PowerOff define by sigspark api
        :return None
        """
        self._send_msg(cmd, index=index)
        res = self._get_msg(cmd, index=index)
        res_state = res["State"]
        if res_state == 0:
            print("MTU power off success!")

    def mtu_poweroff(self, index=1, cmd="MTUPowerOff"):
        """
        Shutdown RF on UE (not reboot)
        :param cmd: PowerOff define by sigspark api
        :return None
        """
        self._send_msg(cmd, index=index)
        res = self._get_msg(cmd, index=index)
        res_state = res["State"]
        if res_state == 0:
            print("MTU power off success!")

    def power_off(self, cmd="PowerOff"):
        """
        Shutdown RF on UE (not reboot)
        :param cmd: PowerOff define by sigspark api
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def detach(self, cmd="Detach"):
        """
        Dttach UE
        :param cmd: Detach define by sigspark api
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)

    def DisConnectEQ(self, cmd="DisConnectEQ"):
        """
        DisConnect UE
        :param cmd: DisConnectEQ define by sigspark api
        :return None
        """
        self._send_msg(cmd)
        self._get_msg(cmd)


class SigSparkClient(BaseClient):

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
                alias='sigspark')
            print("SSH to Control PC success:{}".format(str(res)))
        except BaseException as error:
            print("SSH to Control PC Error : {}".format(str(error)))
            pingcmd = "ping -c 4 {} >ping.txt".format(self.ue_config['host'])
            print(pingcmd)
            os.system(pingcmd)
            try:
                f = open('ping.txt', 'r')
                print(f.read())
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


class SigSpark():

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

    def require_platform_MTU(
            self,
            ue_alias,
            index=0,
            reset_sol=None,
            get_spark_license=True):
        """
        Require platform to prepare like sigspark or Pioneer to start and remote connecting create
        :param ue_alias:<str> store ue by ue_alias
        :param index: ue index of ${tl.ues} , count from 0
        :param reset_sol: if not None ,Restart UEmanager on UE
        :return client
        """
        try:
            varstr = "${tl.ues[" + str(index) + "]}"
            ueobj = BuiltIn().get_variable_value(varstr)
            apppath = ueobj.server_dir
            serverip = ueobj.ssh_connection_details.addr
        except BaseException as error:
            logging.info(str(error))

        if "Spark.exe" in apppath:
            client = SigSparkClient()
        else:
            raise Exception("This UE not in support list!")
        client.init_config(index=index, get_spark_license=get_spark_license)
        print("============ssh Done=============")
        if serverip in self.client:
            print("============socket ready=============")
            client.setup_MTU(self.client[serverip]['conn'], get_spark_license=get_spark_license)
        else:
            print("============socket new=============")
            conn = client.setup_MTU(get_spark_license=get_spark_license)
            self._update_socket_conn(serverip, conn)
            self.client[serverip] = {"conn": conn, 'log': {'state': 0}}
        print("============socket Done=============")
        if reset_sol != "none" and reset_sol is not None:
            client.restart_uemanager()
        self.store[ue_alias] = client
        return client

    def init_and_connect_socket(self, ue_alias, index=0, get_spark_license=True):
        try:
            varstr = "${tl.ues[" + str(index) + "]}"
            ueobj = BuiltIn().get_variable_value(varstr)
            apppath = ueobj.server_dir
            serverip = ueobj.ssh_connection_details.addr
        except BaseException as error:
            logging.info(str(error))

        if "Spark.exe" in apppath:
            client = SigSparkClient()
        client.init_config(index=index, get_spark_license=get_spark_license)
        print("============ssh Done=============")
        if serverip in self.client:
            print("============socket ready=============")
            client.connect_socket()
        else:
            print("============socket new=============")
            conn = client.connect_socket()
            self._update_socket_conn(serverip, conn)
            self.client[serverip] = {"conn": conn, 'log': {'state': 0}}
        print("============socket Done=============")
        self.store[ue_alias] = client
        return client

    def mtu_power(
            self,
            ue_alias='ue_0',
            power_on='true',
            mtu_index=1,
            index=0,
            get_spark_license=True,
            reset_sol=None):
        """
        Require UE
        :param ue_alias:<str> store ue by ue_alias
        :param mtu_index:<str> store ue by ue_alias
        :param power_on: ue index of ${tl.ues} , count from 0
        :param reset_sol: if not None ,Restart UEmanager on UE
        :return None
        """
        client = self.require_platform_MTU(ue_alias=ue_alias, index=index, reset_sol=reset_sol,
                                           get_spark_license=get_spark_license)
        if power_on.lower() == "true":
            client.mtu_poweron(index=mtu_index)
        else:
            client.mtu_poweroff(index=mtu_index)

    def mtu_power_revocery(
            self,
            ue_alias='ue_0',
            power_on='true',
            mtu_index=1,
            index=0,
            get_spark_license=True):
        """
        Require UE
        :param ue_alias:<str> store ue by ue_alias
        :param mtu_index:<str> store ue by ue_alias
        :param power_on: ue index of ${tl.ues} , count from 0
        :param reset_sol: if not None ,Restart UEmanager on UE
        :return None
        """
        client = self.init_and_connect_socket(ue_alias=ue_alias, index=index, get_spark_license=get_spark_license)
        if power_on.lower() == "true":
            client.mtu_poweron(index=mtu_index)
        else:
            client.mtu_poweroff(index=mtu_index)

    def disconnect_ues(
            self,
            ue_alias='ue_0',
            index=0,
            get_spark_license=True,
            reset_sol=None):
        """
        Require UE
        :param ue_alias:<str> store ue by ue_alias
        :param mtu_index:<str> store ue by ue_alias
        :param power_on: ue index of ${tl.ues} , count from 0
        :param reset_sol: if not None ,Restart UEmanager on UE
        :return None
        """
        client = self.require_platform_MTU(ue_alias=ue_alias, index=index, reset_sol=reset_sol,
                                           get_spark_license=get_spark_license)
        client.DisConnectEQ()
