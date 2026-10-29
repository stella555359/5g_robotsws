
#################################################################################
# File           : AIC_LogCapture.py
# Version        : 1.0
# Modified       : Vivek GV 12.09.2021
# Description    :
# Supported HW  :
# Version        :
#   1.0			 :
# Requires files : -
# Requires options: -
# Copyright (C) Nokia 2021. All Rights Reserved.
# Author: GV Vivek
# Log of changes : $Log:
# ================================================================================
# Functions           Descriptions
# -------------------------------------------------------------------------------
#
#
#################################################################################
import paramiko
import os
import pexpect
import sys


class sFTP_Logs:
    def __init__(self, remotepath, localpath):
        self.remote_path = remotepath
        self.localpath = localpath

    def sFTP_Files(self):
        self.localpath = self.localpath.replace('"', "")
        self.localpath = os.path.join(self.localpath, '', '')
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(hostname=self.ip, port=22, username=self.Uname, password=self.passw)
        ftp_client = client.open_sftp()
        try:
            listfile = ftp_client.listdir(self.remote_path)
        except Exception as e:
            print("Exception ", e.__class__, "occurred.")
            print("ERROR: PCAP FILE NOT FOUND IN TARGET FOLDER")
            return -1
        for fname in listfile:
            try:
                ftp_client.get(self.remote_path + fname, self.localpath + fname)
            except Exception as e:
                print("Exception ", e.__class__, "occurred.")
                print("ERROR: PCAP FILE NOT FOUND TO COPY")
                return -1
        ftp_client.close()
        client.close()

    def sFTP_Files_put(self):
        self.localpath = self.localpath.replace('"', "")
        self.localpath = os.path.join(self.localpath, '', '')
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(hostname=self.ip, port=22, username=self.Uname, password=self.passw)
        ftp_client = client.open_sftp()
        try:
            listfile = os.listdir(self.localpath)
        except Exception as e:
            print("Exception ", e.__class__, "occurred.")
            print("ERROR: PCAP FILE NOT FOUND IN TARGET FOLDER")
            return -1
        for fname in listfile:
            try:
                ftp_client.put(self.localpath + fname, self.remote_path + fname)
            except Exception as e:
                print("Exception ", e.__class__, "occurred.")
                print("ERROR: PCAP FILE NOT FOUND TO COPY")
                return -1
        ftp_client.close()
        client.close()

    def sFTP_TargetBD_File(self):
        print("********************Debug*****************", self.localpath)
        print("********************Debug*****************", self.remote_path)
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(hostname=self.ip, port=22, username=self.Uname, password=self.passw)
        ftp_client = client.open_sftp()
        ftp_client.get(self.remote_path, self.localpath)


class Cmd_Executor:
    def __init__(self, ip, uname, passw):
        self.ip = ip
        self.Uname = uname
        self.Passw = passw
        self.stream_ip = None               # Not in use yet
        self.stream_login = None            # Not in use yet
        self.stream_pass = None             # Not in use yet

    def exec_cmd(self, cmd, targethw):
        sshp = paramiko.SSHClient()
        sshp.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        sshp.connect(self.ip, port=22, username=self.Uname, password=self.Passw)
        print(cmd)
        stdin, stdout, stderr = sshp.exec_command(cmd)
        sshp.close()

    def exec_cmd_bg(self, cmd, targethw):
        sshp = paramiko.SSHClient()
        sshp.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        sshp.connect(self.ip, port=22, username=self.Uname, password=self.Passw)
        try:
            print(cmd)
            stdin, stdout, stderr = sshp.exec_command(cmd, timeout=1)
        except Exception as e:
            print("Exception ", e.__class__, " occurred.")
            print("INFO: STARTED SYSLOG")
        sshp.close()

    def exec_get_output(self, cmd, targethw):
        sshp = paramiko.SSHClient()
        sshp.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        sshp.connect(self.ip, port=22, username=self.Uname, password=self.Passw)
        print(cmd)
        stdin, stdout, stderr = sshp.exec_command(cmd)
        output = stdout.readlines()
        output = "".join(output)
        output = output.strip()
        sshp.close()
        return output

    def exec_get_output_timeout(self, cmd, targethw):
        sshp = paramiko.SSHClient()
        sshp.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        sshp.connect(self.ip, port=22, username=self.Uname, password=self.Passw)
        print(cmd)
        try:
            stdin, stdout, stderr = sshp.exec_command(cmd, timeout=3)
            output = stdout.readlines()
            output = "".join(output)
            output = output.strip()
            sshp.close()
            return output
        except Exception as e:
            raise Exception("ERROR - Cmd Timeout ")

    def expect_list(self, cmd_list, targethw):
        sshenb = 'ssh ' + self.Uname + '@' + self.ip
        print("DEBUG, CMD EXECUTED=", sshenb)    # for debug only.
        child = pexpect.spawnu(sshenb)
#        child.logfile_read = sys.stdout.buffer
        child.logfile_read = sys.stdout          # does not work on python 3.6.10
        for col_m, col_n in cmd_list:
            print("DEBUG, CMD EXECUTED=", col_m, col_n)   # for debug only.
            child.expect(col_m)
            child.sendline(col_n)
        child.close()

    def exec_cmd_list(self, cmd_list, targethw):
        sshp = paramiko.SSHClient()
        sshp.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        if targethw == 'GNB' or 'AP' or 'vDU' or 'vCU':
            sshp.connect(self.ip, port=22, username=self.Uname, password=self.Passw)
        if targethw == 'STREAMING_PC':
            sshp.connect(self.stream_ip, port=22, username=self.stream_login, password=self.stream_pass)
        for _ in cmd_list:
            print(_)
            stdin, stdout, stderr = sshp.exec_command(_)
            opt = stdout.readlines()
            opt = "".join(opt)
            print(opt)
        sshp.close()
