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


class SASserver(object):

    def __init__(self, sas_sim_conf_file, sas_server_path):
        self.SAS_SIM_DIR = sas_server_path
        self.SAS_SIM_CONFIG_FILE = sas_sim_conf_file
        self.SAS_SIM_LOG_FILE = None
        self.fileHandler = None
        self.process = None

    def start_service(self):
        os.chdir(self.SAS_SIM_DIR)
        config = ConfigParser.ConfigParser()
        config.read(self.SAS_SIM_CONFIG_FILE)
        print("SAS_SIM_CONFIG_FILE: %s\n" % (self.SAS_SIM_CONFIG_FILE))
        items = config.items('conf')
        sec = 'conf'
        if config.has_option(sec, 'log_file_name'):
            log_file = config.get(sec, 'log_file_name')
        self.SAS_SIM_LOG_FILE = self.SAS_SIM_DIR + "/SASlog/" + log_file
        print("SAS_SIM_LOG_FILE: %s\n" % (self.SAS_SIM_LOG_FILE))
        cmd = "sudo rm -f " + self.SAS_SIM_LOG_FILE
        os.system(cmd)

        self.process = subprocess.Popen(
            ["sudo", "python", self.SAS_SIM_DIR + "/SAS_Sim_persistent.py", self.SAS_SIM_CONFIG_FILE])
        time.sleep(10)
        print("Start SAS simulator [pid: %s]... \n" % (self.process.pid))

    def kill_service(self):
        pid = bytes(self.process.pid)
        pid_list = subprocess.check_output(["ps", "-o", "pid", "--ppid", pid, "--noheaders"]).split()
        print("pinfo {}".format(pid_list))
        for pid in pid_list:
            process_to_kill = subprocess.call(["sudo", "kill", "-2", pid])
            time.sleep(30)
            print("Process killed: {} {}".format(process_to_kill, pid))

    def check_registrationRequest_message(self):
        with open(self.SAS_SIM_LOG_FILE, 'r') as file:
            content = file.read()
        reg = "{\"registrationRequest\":.*"
        match = re.findall(reg, content)
        return match[0]

    def check_registrationResponse_message(self):
        with open(self.SAS_SIM_LOG_FILE, 'r') as file:
            content = file.read()
        reg = "{\"registrationResponse\":.*"
        matchMessageSet = re.findall(reg, content)

        for i in range(len(matchMessageSet)):
            registrationResponseMessage = json.loads(matchMessageSet[i])
            print("registrationResponseMessage: %s\n" % (registrationResponseMessage))
            registrationResponseDate = registrationResponseMessage['registrationResponse'][0]
            Responsemessage = registrationResponseDate['response']
            if "responseCode" in Responsemessage and int(Responsemessage["responseCode"]) == 0:
                return registrationResponseMessage
        return None

    def check_spectrumInquiryRequest_message(self):
        with open(self.SAS_SIM_LOG_FILE, 'r') as file:
            content = file.read()
        reg = "{\"spectrumInquiryRequest\":.*"
        match = re.findall(reg, content)
        return match[0]

    def check_spectrumInquiryResponse_message(self):
        with open(self.SAS_SIM_LOG_FILE, 'r') as file:
            content = file.read()
        reg = "{\"spectrumInquiryResponse\":.*"
        matchMessageSet = re.findall(reg, content)

        for i in range(len(matchMessageSet)):
            InquiryResponseMessage = json.loads(matchMessageSet[i])
            print("InquiryResponseMessage: %s\n" % (InquiryResponseMessage))
            InquiryResponseDate = InquiryResponseMessage['spectrumInquiryResponse'][0]
            Responsemessage = InquiryResponseDate['response']
            if "responseCode" in Responsemessage and int(Responsemessage["responseCode"]) == 0:
                return InquiryResponseMessage
        return None

    def check_heartbeatRequest_message(self):
        with open(self.SAS_SIM_LOG_FILE, 'r') as file:
            content = file.read()
        reg = "{\"heartbeatRequest\":(.*)"
        match = re.findall(reg, content)
        return match[0]

    def check_heartbeatResponse_message(self):
        with open(self.SAS_SIM_LOG_FILE, 'r') as file:
            content = file.read()
        reg = "{\"heartbeatResponse\":.*"
        matchMessageSet = re.findall(reg, content)

        for i in range(len(matchMessageSet)):
            heartbeatResponseMessage = json.loads(matchMessageSet[i])
            print("heartbeatResponseMessage: %s\n" % (heartbeatResponseMessage))
            heartbeatResponseDate = heartbeatResponseMessage['heartbeatResponse'][0]
            Responsemessage = heartbeatResponseDate['response']
            if "responseCode" in Responsemessage and int(Responsemessage["responseCode"]) == 0:
                return heartbeatResponseMessage
        return None

    def check_spectrumGrantRequest_message(self):
        with open(self.SAS_SIM_LOG_FILE, 'r') as file:
            content = file.read()
        reg = "{\"grantRequest\":(.*)"
        match = re.findall(reg, content)
        return match[0]

    def check_spectrumGrantResponse_message(self):
        with open(self.SAS_SIM_LOG_FILE, 'r') as file:
            content = file.read()
        reg = "{\"grantResponse\":.*"
        matchMessageSet = re.findall(reg, content)

        for i in range(len(matchMessageSet)):
            grantResponseMessage = json.loads(matchMessageSet[i])
            print("grantResponseMessage: %s\n" % (grantResponseMessage))
            grantResponseDate = grantResponseMessage['grantResponse'][0]
            Responsemessage = grantResponseDate['response']
            if "responseCode" in Responsemessage and int(Responsemessage["responseCode"]) == 0:
                return grantResponseMessage
        return None

    def check_RelinquishRequest_message(self):
        print("SAS_SIM_LOG_FILE: %s\n" % (self.SAS_SIM_LOG_FILE))
        with open(self.SAS_SIM_LOG_FILE, 'r') as file:
            content = file.read()
        reg = "{\"relinquishmentRequest \":(.*)"
        match = re.findall(reg, content)
        return match[0]

    def check_tls_connection(self):
        with open(self.SAS_SIM_LOG_FILE, 'r') as file:
            content = file.read()
        #     reg = "{\"" + message +"\":(.*)"
        reg = "accepted new connection.*"
        match = re.findall(reg, content)
        return match[0]

    ############################

    def prepare_to_check_message(self):
        self.fileHandler = open(self.SAS_SIM_LOG_FILE, 'r')
        self.fileHandler.seek(0, os.SEEK_END)

    def find_message(self, messageTag):
        print("messageTag: %s\n" % (messageTag))
        if self.fileHandler is None:
            print("file should be opened by prepare_to_check_message function!!! \n")
            return None
        while True:
            line = self.fileHandler.readline()
            print("Line: %s \n" % line)
            if not line:
                break
            matchMessageSet = re.findall(messageTag, line)
            if (matchMessageSet):
                print("message: %s\n" % (matchMessageSet[0]))
                return matchMessageSet[0]
            else:
                continue
        return None

    def count_message(self, messageTag):
        print("messageTag: %s\n" % (messageTag))
        i = 0
        if self.fileHandler is None:
            print("file should be opened by prepare_to_check_message function!!! \n")
            return None
        while True:
            line = self.fileHandler.readline()
            print("Line: %s \n" % line)
            if not line:
                break
            matchMessageSet = re.findall(messageTag, line)
            if (matchMessageSet):
                print("message: %s\n" % (matchMessageSet[0]))
                i = i + 1
            else:
                continue
        return i

    def end_to_check(self):
        self.fileHandler.close()
        self.fileHandler = None

#############################
