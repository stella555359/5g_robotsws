#################################################################################
# File           : BIP_Library.py
# Version        : 1.0
# Modified       : Vivek GV 28.07.2021
# Description    : This script triggers and collects BIP Log on Airphone ASIK_ABIL HW.
# Supported HW  : ASIK and ABIL on Airphone side
# Version        : Improvements:
#   1.0			 : Added SFTP of logs to local directory.
# Requires files : -
# Requires options: -
# Copyright (C) Nokia 2021. All Rights Reserved.
# Author: GV Vivek
# Log of changes : $Log:
# ================================================================================
# Functions           Descriptions
# -------------------------------------------------------------------------------
# BIP_Configuration_AP_ASIK_ABIL()  :
# BIP_Monitoring_Start_AP_ASIK_ABIL() :
# BIP_Monitoring_Stop_AP_ASIK_ABIL("local_path for log to collect")
# Plz check below variable before using
# -------------------------------------
#
#################################################################################


import paramiko
import sys
import os
import time
import yaml
from yaml.loader import SafeLoader
import pexpect


class BipMonitoring:
    def __init__(self, envtype, smod, bbmod=None, stream_ip=None, stream_iface=None, local_path=None, L1Bypass=None):
        self.EnvType = envtype
        self.SMOD = smod
        self.BBMOD = bbmod
        self.object = self._getinfo()
        self.ip = self.object.get('Ipaddress')
        self.Uname = self.object.get('UserName')
        self.passw = self.object.get('PassWord')
        self.stream_ip = stream_ip
        self.stream_login = 'root'
        self.stream_pass = 'BT5l@bus3rl0g1n'
        self.stream_iface = stream_iface
        self.localpath = local_path
        self.l1bypass = L1Bypass

    def bip_conf_ap_asik_abil(self):
        self._exec_cmd_list(self.object.get(self.SMOD).get(self.BBMOD).get('Cmd_Enable'), 'AP')

    def bip_mon_start_ap_asik_abil(self):
        self._exec_cmd_list_bg(self.object.get(self.SMOD).get(self.BBMOD).get('tcpcmd'), 'AP')

    def bip_mon_stop_ap_asik_abil(self):
        print("Cmd_Disable Execution started at time in sec ", time.time())
        self._exec_cmd_list(self.object.get(self.SMOD).get(self.BBMOD).get('Cmd_Disable'), 'AP')
        print("Cmd_Disable Execution done  at time in sec ", time.time())
        time.sleep(10)
        self._sFTP_Files(self.object.get(self.SMOD).get(self.BBMOD).get('remote_path'))

    def bip_conf_start_asoe(self):
        cmd_list = self.object.get(self.SMOD).get('Cmd_enable_FS')
        if self.l1bypass:
            cmd_list.insert(0, (self.object.get(self.SMOD).get('Cmd_L1bypass')))
        streaming_cmd = self.object.get(self.SMOD).get('cmd_on_streaming')
        streaming_cmd.append("nohup tcpdump -i " + self.stream_iface + " -w /tmp/tmpauto/BIP_L1L2_ASOE.pcap")
        self._exec_cmd_list(cmd_list, "GNB")
        self._expect_list(self.object.get(self.SMOD).get('Cmd_enable_FS1'))
        self._exec_cmd_list_bg(streaming_cmd, "STREAMING_PC")

    def bip_stop_collect_asoe(self):
        killcmd = [
            "kill -9 `ps -ef| grep -i '" + self.stream_iface + " -w /tmp/tmpauto/' | grep -v grep |head -n 1 |tr -s ' "
                                                               "'| cut -d ' ' -f2`"]
        self._exec_cmd_list(self.object.get(self.SMOD).get('Cmd_disable'), "GNB")
        self._expect_list(self.object.get(self.SMOD).get('Cmd_disable1'))
        self._exec_cmd_list(killcmd, "STREAMING_PC")
        self._sFTP_Files(self.object.get(self.SMOD).get('remote_path'))

    def bip_mon_start_asim_abip(self):
        self._exec_cmd_list_bg(self.object.get(self.SMOD).get(self.BBMOD).get('Cmd_enable_FS'), "GNB")

    def bip_mon_stop_asim_abip(self):
        self._exec_cmd_list(self.object.get(self.SMOD).get(self.BBMOD).get('Cmd_disable_FS'), "GNB")
        time.sleep(10)
        self._sFTP_Files(self.object.get(self.SMOD).get(self.BBMOD).get('remote_path'))

    def bip_mon_start_asil_asib_abio_abin(self):
        self._exec_cmd_list_bg(self.object.get(self.SMOD).get(self.BBMOD).get('Cmd_enable_FS'), "GNB")

    def bip_mon_stop_asil_asib_abio_abin(self):
        self._exec_cmd_list(self.object.get(self.SMOD).get(self.BBMOD).get('Cmd_disable_FS'), "GNB")
        time.sleep(10)
        self._sFTP_Files(self.object.get(self.SMOD).get(self.BBMOD).get('remote_path'))

    def _exec_cmd_list(self, cmd_list, targethw):
        sshp = paramiko.SSHClient()
        sshp.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        if targethw == 'GNB' or 'AP':
            sshp.connect(self.ip, port=22, username=self.Uname, password=self.passw)
        if targethw == 'STREAMING_PC':
            sshp.connect(self.stream_ip, port=22, username=self.stream_login, password=self.stream_pass)
        for _ in cmd_list:
            print(_)
            stdin, stdout, stderr = sshp.exec_command(_)
            opt = stdout.readlines()
            opt = "".join(opt)
            print(opt)
        sshp.close()

    def _exec_cmd_list_bg(self, cmd_list, targethw):
        sshp = paramiko.SSHClient()
        sshp.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        if targethw == 'GNB' or 'AP':
            sshp.connect(self.ip, port=22, username=self.Uname, password=self.passw)
        if targethw == 'STREAMING_PC':
            sshp.connect(self.stream_ip, port=22, username=self.stream_login, password=self.stream_pass)
        for _ in cmd_list:
            try:
                print(_)
                stdin, stdout, stderr = sshp.exec_command(_, timeout=1)
                opt = stdout.readlines()
                opt = "".join(opt)
                print(opt)
            except Exception as e:
                print("Exception ", e.__class__, " occurred.")
                print("INFO: STARTED TCPDUMP")
        sshp.close()

    def _expect_list(self, cmd_list):
        sshenb = 'ssh ' + self.Uname + '@' + self.ip
        child = pexpect.spawn(sshenb)
        child.logfile_read = sys.stdout.buffer
#        child.logfile_read = sys.stdout          # does not work on python 3.6.10
        for m, n in cmd_list:
            child.expect(m)
            child.sendline(n)
        child.close()

    def _sFTP_Files(self, remote_path):
        print("Inside sFTP_fun Time Stamp ", time.time())
        print("remote_path=", remote_path)
        self.localpath = self.localpath.replace('"', "")
        self.localpath = os.path.join(self.localpath, '', '')
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        if self.stream_ip:
            client.connect(hostname=self.stream_ip, port=22, username=self.stream_login, password=self.stream_pass)
        else:
            client.connect(hostname=self.ip, port=22, username=self.Uname, password=self.passw)
        ftp_client = client.open_sftp()
        try:
            listfile = ftp_client.listdir(remote_path)
        except Exception as e:
            print("Exception ", e.__class__, "occurred.")
            print("ERROR: PCAP FILE NOT FOUND IN TARGET FOLDER")
            return -1
        for fname in listfile:
            try:
                ftp_client.get(remote_path + fname, self.localpath + fname)
                print("sFTP of ", fname, " Done...")
            except Exception as e:
                print("Exception ", e.__class__, "occurred.")
                print("ERROR: PCAP FILE NOT FOUND TO COPY")
                return -1
        ftp_client.close()
        client.close()
        print("Exit _sFTP_fun Time Stamp ", time.time())

    def _getinfo(self):
        dir_path = os.path.dirname(os.path.realpath(__file__))
        with open(dir_path + '/' + 'abstract.yaml') as f:
            data = yaml.load(f, Loader=SafeLoader)
            return data['BIPSection'][self.EnvType]


##########################################################################################################


def Bip_Mon_Start_AP_ASIK_ABIL():
    y = BipMonitoring('AirPhone', 'ASIK', 'ABIL')
    y.bip_conf_ap_asik_abil()
    y.bip_mon_start_ap_asik_abil()
    del y


def Bip_Mon_Stop_AP_ASIK_ABIL(vm_path):
    x = BipMonitoring('AirPhone', 'ASIK', 'ABIL', local_path=vm_path)
    x.bip_mon_stop_ap_asik_abil()
    del x


##########################################################################################################


def Bip_Conf_Start_ASOE_FS(streaming_pc_ip, streaming_pc_iface):
    y = BipMonitoring('gNB', 'ASOE', stream_ip=streaming_pc_ip, stream_iface=streaming_pc_iface, L1Bypass=False)
    y.bip_conf_start_asoe()
    del y


def Bip_Stop_Collect_ASOE_FS(streaming_pc_ip, streaming_pc_iface, vm_path):
    x = BipMonitoring('gNB', 'ASOE', stream_ip=streaming_pc_ip, stream_iface=streaming_pc_iface, local_path=vm_path)
    x.bip_stop_collect_asoe()
    del x


##########################################################################################################


def Bip_Conf_Start_ASOE_L1bypass(streaming_pc_ip, streaming_pc_iface):
    y = BipMonitoring('gNB', 'ASOE', stream_ip=streaming_pc_ip, stream_iface=streaming_pc_iface, L1Bypass=True)
    y.bip_conf_start_asoe()
    del y


def Bip_Stop_Collect_ASOE_L1bypass(streaming_pc_ip, streaming_pc_iface, vm_path):
    x = BipMonitoring('gNB', 'ASOE', stream_ip=streaming_pc_ip, stream_iface=streaming_pc_iface, local_path=vm_path)
    x.bip_stop_collect_asoe()
    del x


##########################################################################################################


def Bip_Mon_Start_ASIM_ABIP():
    y = BipMonitoring('gNB', 'ASIM_ASIL', 'ABIP')
    y.bip_mon_start_asim_abip()
    del y


def Bip_Mon_Stop_Collect_ASIM_ABIP(vm_path):
    x = BipMonitoring('gNB', 'ASIM_ASIL', 'ABIP', local_path=vm_path)
    x.bip_mon_stop_asim_abip()
    del x


##########################################################################################################


def Bip_Mon_Start_ASIL_ASIB_ABIO_ABIN():
    y = BipMonitoring('gNB', 'ASIL_ASIB', 'ABIO_ABIN')
    y.bip_mon_start_asil_asib_abio_abin()
    del y


def Bip_Mon_Stop_Collect_ASIL_ASIB_ABIO_ABIN(vm_path):
    x = BipMonitoring('gNB', 'ASIL_ASIB', 'ABIO_ABIN', local_path=vm_path)
    x.bip_mon_stop_asil_asib_abio_abin()
    del x


##########################################################################################################
