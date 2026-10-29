# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""
import time
import os
import re
import subprocess
import platform
import logging as log
import socket
import json
import time
import taf.transport.ssh as csn
from .misc import Misc


class SparkCpe(object):
    """deming """

    def __init__(self, host, **kwargs):
        self.user = kwargs.get("user", 'spark')
        self.pwd = kwargs.get("pwd", 'spark')
        self._ipver = str(kwargs.get("ipver", "ipv4")).lower()
        self.log_path = str(kwargs.get("log_path", r"C:\Logfiles1"))
        self._host = host
        self._port = 30999
        self.stop_test_list = []
        self.ssh = csn.ssh()
        self.ssh.connect_to(
            hostname=self._host,
            username=self.user,
            password=self.pwd,
            alias='sparkpc')
        ret = self.ssh.execute(
            'TASKKILL /F /T /IM "YHT-MTU Power Tool*"',
            connection='sparkpc')
        if not self._check_port():
            self._restart_spark()
        self.now = time.strftime(
            "%Y_%m_%d_%H_%M_%S", time.localtime(int(time.time())))
        self._connect_spark()

    def _restart_spark(self):
        f = Misc()
        base_path = "C:\\Program Files (x86)"
        latest_path = f.get_latest_direcotory(
            self._host, self.user, self.pwd, base_path, 'Spark')
        spark_path = latest_path + "\\\\Bin\\\\Spark.exe"
        restart_cmds = [
            # "taskkill /f /im SSSRXX.exe",
            # "taskkill /f /im adb.exe",
            'TASKKILL /F /T /IM "YHT-MTU Power Tool*"',
            "taskkill /f /im Spark.exe",
            "schtasks /end /tn spark",
            "schtasks /delete /tn spark /f",
            'schtasks /create /tn spark /sc once /tr "{}" /st 00:00 /RL highest /f'.format(
                spark_path),
            "schtasks /run /tn spark"]
        for cmd in restart_cmds:
            log.info(cmd)
            ret = self.ssh.execute(cmd, connection='sparkpc')
            time.sleep(2)
        st = time.time()
        cost = 0
        while (1):
            if self._check_port():
                break

            time.sleep(10)
            if time.time() - st > 300:
                raise Exception("Start spark failed!")
        time.sleep(3)

    def _check_port(self):
        ret = self.ssh.execute(
            'tasklist /svc /fi "imagename eq Spark.exe"',
            connection='sparkpc')
        log.info(ret)
        ta_status_cmd = "netstat -ano|findstr :{}".format(self._port)
        ret = self.ssh.execute(
            ta_status_cmd,
            connection='sparkpc')
        log.info(ret)
        if ":{}".format(self._port) in ret:
            return True
        else:
            return False

    def _connect_spark(self):
        self.clientsocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.clientsocket.settimeout(300)
        self.clientsocket.connect((self._host, int(self._port)))
        self._reconn_eq_and_start_log()

    def execute_at_command(self, cmd, para=None, index=None, timeout=0):
        rt = []
        for i in str(index).split(','):
            ret_dict, ret = self.execute_command(cmd, para, i, timeout)
            rt.append(ret_dict)
        return rt

    def _senc_recv_cmd(self, cmd, timeout):
        time.sleep(0.5)
        self.clientsocket.sendall(cmd.encode("utf-8"))
        log.info('Send: %s' % cmd)
        time.sleep(timeout)
        ret = self.clientsocket.recv(2000).decode()
        log.info("Recv: %s \r\n" % ret)
        return ret

    def execute_command(self, cmd, para=None, index=None, timeout=0.5):
        """execute command on ue connection
        @return: if False: execute cmd failed, else is cmd response, execute cmd succeed.
        """
        msg = {
            "CMD": cmd
        }

        if index:
            msg['EQIndex'] = int(index)

        if para:
            if cmd == "SendAT" and "Timeout" not in para.keys():
                para["Timeout"] = 50000
            msg['Param'] = para
        send_cmd = json.dumps(msg)

        ret = self._senc_recv_cmd(send_cmd, timeout)
        if 'State' not in ret or cmd not in ret:
            ret = self.clientsocket.recv(2000).decode()
            log.info("Recv: %s \r\n" % ret)
        ret_dict = json.loads(ret)
        state = ret_dict['Param']['State']
        if state != 0:
            log.warn("check '%s' wrong state!" % cmd)

        return ret_dict, ret

    def _reconn_eq_and_start_log(self):
        para = {"SuccStr": "\r\n\r\nOK",
                "Command": 'ATI'}
        state, ret = self.execute_command("SendAT", para, 1)
        if '"State":0' not in ret:
            log.warn('get spark type failed! try agian!')
            state, ret = self.execute_command("SendAT", para, 1)
            if '"State":0' not in ret:
                raise Exception('get spark type failed! please check!')
        if 'RG520F' in ret:
            self.type = 'x65'
        else:
            self.type = "other"
        self.execute_command("DisConnectEQ", timeout=2)
        time.sleep(3)
        if self.type != 'x65':
            for i in range(1, 9):
                self.execute_command("MTUPowerOff", index=i)
                self.execute_command("MTUPowerOn", index=i)

            time.sleep(30)
        ret_dict, ret = self.execute_command("AutoCheck")
        self.execute_command("ConnectEQ")
        num = ret_dict['Param']['Count']
        self.index_all = ','.join([str(i) for i in range(1, num + 1)])
        for i in range(1, num + 1):
            self.execute_command("PowerOff", index=i)

    def start_log(self, **kwargs):
        ue_index = kwargs.get("ue_index", 'all')

        para = {"LogPath": self.log_path,
                "LogName": self.now}
        if ue_index == 'all':
            self.execute_command("StartLog", para)
        else:
            for ind in str(ue_index).split(','):
                self.execute_command("StartOneLog", para, index=ind)

    def stop_log(self, **kwargs):
        ue_indexs = kwargs.get("ue_index", 'all')
        if ue_indexs == 'all':
            self.execute_command("StopLog")
            ue_indexs = self.index_all
        else:
            for ue_index in str(ue_indexs).split(','):
                self.execute_command("StopOneLog", index=ue_index)

    def collect_log(self, **kwargs):
        log_save_folder = kwargs.get("log_save_folder", '/tmp/')
        ue_indexs = kwargs.get("ue_index", 'all')
        log_type = kwargs.get("log_type", 'csv')
        if not os.path.exists(log_save_folder):
            os.makedirs(log_save_folder)
        save_log_list = []
        if ue_indexs == 'all':
            ue_indexs = self.index_all
        for ue_index in str(ue_indexs).split(','):
            log_file_name = "%s-%s" % (self.now, ue_index)
            rm_saf_file_path = "%s%s.saf" % (self.log_path, log_file_name)
            rm_raf_file_path = rm_saf_file_path.replace('.saf', '.raf')
            rm_csv_file_path = rm_saf_file_path.replace('.saf', '_data.csv')
            rm_xml_file_path = rm_saf_file_path.replace('.saf', '_msg.xml')

            saf_path = "%s/%s.saf" % (log_save_folder, log_file_name)
            raf_path = saf_path.replace('.saf', '.raf')
            csv_path = saf_path.replace('.saf', '_data.csv')
            msg_path = saf_path.replace('.saf', '_msg.xml')

            if log_type == 'all' or log_type == 'csv':
                para = {"TemplateName": "test",
                        "ExportFileName": rm_csv_file_path,
                        "Logfile": rm_saf_file_path}
                self.execute_command("ExportLogfile", para)
                self.ssh.download_file(
                    remote_path=rm_csv_file_path,
                    local_path=csv_path,
                    connection='sparkpc')
            if log_type == 'all' or log_type == 'xml':
                para = {"ExportFileName": rm_xml_file_path,
                        "Logfile": rm_saf_file_path}
                self.execute_command("ExportMessageDetail", para)
                self.ssh.download_file(
                    remote_path=rm_xml_file_path,
                    local_path=msg_path,
                    connection='sparkpc')

            self.ssh.download_file(
                remote_path=rm_saf_file_path,
                local_path=saf_path,
                connection='sparkpc')
            self.ssh.download_file(
                remote_path=rm_raf_file_path,
                local_path=raf_path,
                connection='sparkpc')

            if log_type == 'all' or log_type == 'csv':
                save_log_list.append(csv_path)
            else:
                save_log_list.append(msg_path)
        return save_log_list

    def attach(self, **kwargs):
        """ue attach
        """
        self.fGSACTR = kwargs.get("fGSACTR", 0)
        self.GTACT = kwargs.get("GTACT", 17)
        self.ue_index = kwargs.get("ue_index", '1')

        for i in str(self.ue_index).split(','):
            self.execute_command("PowerOn", index=i)
            time.sleep(10)
            if self.type == 'x65':
                continue
            para = {"SuccStr": "",
                    "Command": 'AT+GTRNDIS=0'}
            self.execute_command("SendAT", para, i)

            para = {"SuccStr": "",
                    "Command": 'AT+GTRNDIS=1,1'}
            self.execute_command("SendAT", para, i)

            para = {"SuccStr": "",
                    "Command": 'AT+GTSET=\"5GSACTR\",%s' % self.fGSACTR}

            self.execute_command("SendAT", para, i)

            para = {"SuccStr": "",
                    "Command": "AT+GTACT=%s" % self.GTACT}
            self.execute_command("SendAT", para, i)

            time.sleep(7)

            para = {"SuccStr": "", "Command": "AT+CFUN=1"}
            self.execute_command("SendAT", para, i)

    def get_ip(self, **kwargs):
        self.ue_index = kwargs.get("ue_index", '1')
        self.start_test = kwargs.get("start_test", False)
        if self.type == 'x65':
            cmd = 'AT+cgpaddr=1'
            ip_reg = r'CGPADDR.*?\\"(\d+.\d+.\d+.\d+)'
        else:
            cmd = "AT+GTRNDIS?"
            ip_reg = r'GTRNDIS.*?\\"(\d+.\d+.\d+.\d+)'
        ip_list = []
        for i in str(self.ue_index).split(','):
            para = {"SuccStr": "\r\n\r\nOK",
                    "Command": cmd}
            state, ret = self.execute_command("SendAT", para, i)
            tmp = re.search(ip_reg, ret)
            ip = None
            if tmp:
                ip = tmp.group(1)
            ip_list.append(ip)
        return ip_list

    def detach(self, **kwargs):
        self.ue_index = kwargs.get("index", '1')
        for i in str(self.ue_index).split(','):
            self.execute_command("Detach", index=i.strip())
