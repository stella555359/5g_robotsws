#!/usr/bin/python3
# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
:maintainer: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
"""

import os
import time
import paramiko
import logging


class c_rrm_gnbtool(object):

    def __init__(self, logger=None):
        self.logger = logger or logging.getLogger('RRM')
        self.app_path = ''
        self.log_path = ''
        self.ssh_shell = None
        self.ssh = None
        self.log_dire = ''
        self.start_filelist = []
        self.tool_location = '/tmp/gnb_logs_tool'
        self.gitllabe2_url = 'https://gitlabe2.ext.net.nokia.com/p5li/gnb_logs_tool.git'

    def _exec_local_command(self, command):
        self.logger.info('Run command: {}'.format(command))
        return os.popen(command).read()

    def prepare_app(self):
        """
        This keyword will prepare gnb_tool from gitlab2.

        """
        if not os.path.exists('/tmp/gnb_logs'):
            self.logger.info('gnb_logs_tool does not exist.')
            cmd1 = 'sshpass -p qqwweeRR0- scp -o ConnectTimeout=30 -r ute@10.56.111.190:/home/ute/store/gnb_logs/ /tmp/'
            result = os.system(cmd1)
            if result != 0:
                self.logger.info('scp from VM:10.56.111.190 is failed ,try to wget from EEcloud')
                cmd2 = ('wget -P /tmp -r -np -nH --cut-dirs=4 -R index.html '
                        'http://sw1.tc.china.nsn-net.net/build/tools/TA/gnb_tools/gnb_logs/')
                os.system(cmd2)
        else:
            self.logger.info('gnb_logs_tool already exists')
        self.app_path = '/tmp/gnb_logs/gnb_logs'
        self._exec_local_command('sudo chmod +x ' + self.app_path)
        self.logger.info('gnb log app path: ' + self.app_path)

    def _start_to_capture_log(self, log_type='bip', log_dire='', dest_ip='192.168.255.129',
                              host='127.0.0.1', port=22, username='ute', password='uteUTE!', add_options=''):
        option = '-b' if log_type.lower() == 'bip' else ''
        option = '-T' if log_type.lower() == 'tti' else option
        if add_options:
            option += ' ' + add_options
            if "-t" in add_options:
                option = option.replace("-T ", "")
            if "--ip" in add_options:
                import re
                dest_ip = re.search(r"--ip\s+\d+\.\d+\.\d+\.\d+", add_options).group(0).split(" ")[-1]
                option = option.replace("--ip " + dest_ip, "")

        self.log_dire = log_dire
        if not os.path.exists(log_dire):
            os.mkdir(log_dire)

        self.ssh = paramiko.SSHClient()
        self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.ssh.connect(host, port, username, password)

        cmd = 'cd {};sudo {} --ip {} {}'.format(log_dire, self.app_path, dest_ip, option)
        self.logger.info(cmd)
        self.ssh_shell = self.ssh.invoke_shell()
        self.ssh_shell.send(cmd + '\n')

        # exp_str = 'Wait for Press <Enter> again to stop and dump logs'
        exp_str = 'Press a key to stop trace...'
        output = ''
        start_time = time.time()
        while exp_str not in output and time.time() < start_time + 60:
            lines = self.ssh_shell.recv(9999).decode()
            if lines:
                output += lines
            time.sleep(1)
        self.start_filelist = os.listdir(log_dire)

    def stop_log(self):
        self.ssh_shell.send('\n')
        tool_log = os.path.join(self.log_dire, 'tool.log')
        # exp_str = 'Duration seconds'
        exp_str = 'Tool finished running'
        start_time = time.time()
        logfilename = ''
        while time.time() < start_time + 3600:
            if exp_str.lower() in open(tool_log).read().lower():
                break
            else:
                time.sleep(1)
        self.ssh.close()

        self.end_filelist = os.listdir(self.log_dire)
        logfilename = [x for x in self.end_filelist if x not in self.start_filelist]
        if logfilename:
            logfilename = logfilename[0]
        else:
            raise Exception('No new log file name found.')
        logfilename = os.path.join(self.log_dire, logfilename)
        self.logger.info('Log file is: {}'.format(logfilename))
        return logfilename
