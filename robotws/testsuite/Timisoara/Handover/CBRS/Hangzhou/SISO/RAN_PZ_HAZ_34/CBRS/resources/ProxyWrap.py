# -*- coding: utf-8 -*-
import os
import shlex
import time
import subprocess
import configparser
from LogChecker import LogChecker


class ProxyWrap(object):

    def __init__(self, proxy_conf_file, proxy_path):
        self.PROXY_DIR = proxy_path
        self.PROXY_CONFIG_FILE = proxy_conf_file
        self.PROXY_LOG_FILE = self.PROXY_DIR + "/SASlog/HttpsProxy.log"
        self.logchecker = None
        self.process = None

    def start_proxy(self):
        os.chdir(self.PROXY_DIR)
        config = configparser.ConfigParser()
        config.read(self.PROXY_CONFIG_FILE)
        print("PROXY_CONFIG_FILE: %s\n" % (self.PROXY_CONFIG_FILE))
        items = config.items('conf')
        sec = 'conf'
        logPath = self.PROXY_DIR + "/SASlog/"
        parameters = ''
        if config.has_option(sec, 'log_file_name'):
            log_file = config.get(sec, 'log_file_name')
            self.PROXY_LOG_FILE = logPath + log_file
            print("PROXY_LOG_FILE: %s\n" % (self.PROXY_LOG_FILE))
            cmd = "sudo rm -f " + self.PROXY_LOG_FILE
            os.system(cmd)
            parameters += ' -logFile ' + self.PROXY_LOG_FILE
        if config.has_option(sec, 'port_number'):
            port_num = config.get(sec, 'port_number')
            parameters += ' -port ' + port_num
        if config.has_option(sec, 'enable_ipv6'):
            ipv6 = config.getboolean(sec, 'enable_ipv6')
            if (ipv6 is True):
                parameters += ' -ipv6 '
        if config.has_option(sec, 'log_level'):
            logLevel = config.get(sec, 'log_level')
            parameters += ' -logLevel ' + logLevel
        print("Start Proxy with parameters: %s \n" % (parameters))
        command_line = "sudo python " + self.PROXY_DIR + "/HttpsProxy.py" + parameters
        print("Start Proxy command_line: %s]... \n" % (command_line))
        args = shlex.split(command_line)
        print("Start Proxy command: %s]... \n" % (args))
        if os.path.exists(logPath):
            pass
        else:
            os.system("mkdir -p " + logPath)
        self.logchecker = LogChecker(self.PROXY_LOG_FILE)
        self.process = subprocess.Popen(args)
        #        self.process = subprocess.Popen(["sudo", "python", self.PROXY_DIR + "/HttpsProxy.py", args])
        time.sleep(10)
        print("Start Proxy [pid: %s]... \n" % (self.process.pid))

    def kill_proxy(self):
        pid = str(self.process.pid)
        pid_list = subprocess.check_output(["ps", "-o", "pid", "--ppid", pid, "--noheaders"]).split()
        print("pinfo {}".format(pid_list))
        for pid in pid_list:
            process_to_kill = subprocess.call(["sudo", "kill", "-2", pid])
            time.sleep(30)
            print("Process killed: {} {}".format(process_to_kill, pid))

    def prepare_to_check_message(self):
        self.logchecker.prepare_to_check_message(0)

    def find_message(self, messageTag):
        return self.logchecker.find_message(messageTag)

    def count_message(self, messageTag):
        return self.logchecker.count_message(messageTag)

    def end_to_check(self):
        self.logchecker.end_to_check()
