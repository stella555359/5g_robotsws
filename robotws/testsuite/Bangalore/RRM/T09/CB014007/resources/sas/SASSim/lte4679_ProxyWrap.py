# -*- coding: utf-8 -*-
import os
import re
import json
import types
import sys
import time
import subprocess
import ConfigParser
from cStringIO import StringIO


class ProxyWrap(object):

    def __init__(self, proxy_conf_file, proxy_path):
        self.PROXY_DIR = proxy_path
        self.PROXY_CONFIG_FILE = proxy_conf_file
        self.PROXY_LOG_FILE = None
        self.fileHandler = None
        self.process = None

    def start_proxy(self):
        os.chdir(self.PROXY_DIR)
        config = ConfigParser.ConfigParser()
        config.read(self.PROXY_CONFIG_FILE)
        print("PROXY_CONFIG_FILE: %s\n" % (self.PROXY_CONFIG_FILE))
        items = config.items('conf')
        sec = 'conf'
        parameters = ''
        if config.has_option(sec, 'log_file_name'):
            log_file = config.get(sec, 'log_file_name')
            self.PROXY_LOG_FILE = self.PROXY_DIR + "/SASlog/" + log_file
            print("PROXY_LOG_FILE: %s\n" % (self.PROXY_LOG_FILE))
            cmd = "sudo rm -f " + self.PROXY_LOG_FILE
            os.system(cmd)
            parameter = ' -logFile ' + log_file
        if config.has_option(sec, 'port_number'):
            port_num = config.get(sec, 'port_number')
            parameter = ' -port ' + port_num
        if config.has_option(sec, 'enable_ipv6'):
            ipv6 = config.get(sec, 'enable_ipv6')
            parameter = ' -ipv6 ' + ipv6
        if config.has_option(sec, 'log_level'):
            logLevel = config.get(sec, 'log_level')
            parameter = ' -logLevel ' + logLevel

        self.process = subprocess.Popen(["sudo", "python", self.PROXY_DIR + "/HttpsProxy.py", parameters])
        time.sleep(10)
        print("Start Proxy [pid: %s]... \n" % (self.process.pid))

    def kill_proxy(self):
        pid = bytes(self.process.pid)
        pid_list = subprocess.check_output(["ps", "-o", "pid", "--ppid", pid, "--noheaders"]).split()
        print("pinfo {}".format(pid_list))
        for pid in pid_list:
            process_to_kill = subprocess.call(["sudo", "kill", "-2", pid])
            time.sleep(30)
            print("Process killed: {} {}".format(process_to_kill, pid))

#############################
