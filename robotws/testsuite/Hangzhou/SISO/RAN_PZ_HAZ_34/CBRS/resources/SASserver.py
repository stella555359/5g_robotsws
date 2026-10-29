# -*- coding: utf-8 -*-
import os
import re
import json
import types
import sys
import time
import subprocess
import configparser
import subprocess
import shutil
from io import StringIO
from LogChecker import LogChecker


class SASserver(object):

    def __init__(self, sas_sim_conf_file, sas_server_path):
        self.SAS_SIM_DIR = sas_server_path
        self.SAS_SIM_CONFIG_FILE = sas_sim_conf_file
        self.SAS_SIM_LOG_FILE = None
        self.logchecker = None
        self.process = None

    def start_service(self):
        os.chdir(self.SAS_SIM_DIR)
        config = configparser.ConfigParser()
        config.read(self.SAS_SIM_CONFIG_FILE)
        print("SAS_SIM_CONFIG_FILE: %s\n" % (self.SAS_SIM_CONFIG_FILE))
        items = config.items('conf')
        sec = 'conf'
        if config.has_option(sec, 'log_file_name'):
            log_file = config.get(sec, 'log_file_name')
        if "SASSim_HZ" in self.SAS_SIM_DIR:
            self.SAS_SIM_LOG_FILE = self.SAS_SIM_DIR + "/" + log_file
            self.logchecker = LogChecker(self.SAS_SIM_LOG_FILE)
            print("SAS_SIM_LOG_FILE: %s\n" % (self.SAS_SIM_LOG_FILE))
            cmd = "sudo rm -f " + self.SAS_SIM_LOG_FILE
            os.system(cmd)
            self.process = subprocess.Popen(["python", self.SAS_SIM_DIR + "/SAS_Sim_persistent.py", "-c",
                                            self.SAS_SIM_CONFIG_FILE])
            print("SAS start cmd %s... \n" % (["python", self.SAS_SIM_DIR + "/SAS_Sim_persistent.py", "-c",
                                              self.SAS_SIM_CONFIG_FILE]))
        elif "SASSim_TS2" or "SASSim3" in self.SAS_SIM_DIR:
            self.SAS_SIM_LOG_FILE = self.SAS_SIM_DIR + "/" + log_file
            self.logchecker = LogChecker(self.SAS_SIM_LOG_FILE)
            print("SAS_SIM_LOG_FILE: %s\n" % (self.SAS_SIM_LOG_FILE))
            cmd = "sudo rm -f " + self.SAS_SIM_LOG_FILE
            os.system(cmd)
            self.process = subprocess.Popen(["python", self.SAS_SIM_DIR + "/SAS_Sim.py", "-c",
                                            self.SAS_SIM_CONFIG_FILE])
            print("SAS start cmd %s... \n" % (["python", self.SAS_SIM_DIR + "/SAS_Sim.py", "-c",
                                              self.SAS_SIM_CONFIG_FILE]))
        else:
            self.SAS_SIM_LOG_FILE = self.SAS_SIM_DIR + "/SASlog/" + log_file
            self.logchecker = LogChecker(self.SAS_SIM_LOG_FILE)
            print("log file: %s\n" % (log_file))
            print("SAS_SIM_DIR: %s\n" % (self.SAS_SIM_DIR))
            print("SAS_SIM_LOG_FILE: %s\n" % (self.SAS_SIM_LOG_FILE))
            cmd = "sudo rm -f " + self.SAS_SIM_LOG_FILE
            os.system(cmd)
            self.process = subprocess.Popen(["sudo", "python", self.SAS_SIM_DIR + "/SAS_Sim_persistent.py",
                                             self.SAS_SIM_CONFIG_FILE])
            # self.process = subprocess.Popen(["python", self.SAS_SIM_DIR + "/SAS_Sim_persistent.py",
            #                                  self.SAS_SIM_CONFIG_FILE])
            print("SAS start cmd %s... \n" % (["sudo", "python", self.SAS_SIM_DIR + "/SAS_Sim_persistent.py",
                                              self.SAS_SIM_CONFIG_FILE]))
        time.sleep(10)
        print("Start SAS simulator [pid: %s]... \n" % (self.process.pid))

    def start_service_V2(self):
        os.chdir(self.SAS_SIM_DIR)
        config = configparser.ConfigParser()
        config.read(self.SAS_SIM_CONFIG_FILE)
        print("SAS_SIM_CONFIG_FILE: %s\n" % (self.SAS_SIM_CONFIG_FILE))
        items = config.items('conf')
        sec = 'conf'
        if config.has_option(sec, 'log_file_name'):
            log_file = config.get(sec, 'log_file_name')
        self.SAS_SIM_LOG_FILE = log_file
        self.logchecker = LogChecker(self.SAS_SIM_LOG_FILE)
        print("SAS_SIM_LOG_FILE: %s\n" % (self.SAS_SIM_LOG_FILE))
        cmd = "sudo rm -f " + self.SAS_SIM_LOG_FILE
        os.system(cmd)
        self.process = subprocess.Popen(["python3", self.SAS_SIM_DIR + "/SAS_Sim_persistent_v2.py", "-c",
                                         self.SAS_SIM_CONFIG_FILE])
        print("SAS start cmd %s... \n" % (["python3", self.SAS_SIM_DIR + "/SAS_Sim_persistent_v2.py", "-c",
                                           self.SAS_SIM_CONFIG_FILE]))
        time.sleep(10)
        print("Start SAS simulator [pid: %s]... \n" % (self.process.pid))

    def kill_service(self):
        pid = str(self.process.pid)
        print("pid: %s\n" % pid)
        try:
            pid_list = subprocess.check_output(["ps", "-o", "pid", "--ppid", pid, "--noheaders"]).split()
            print("pid_list: %s\n" % pid_list)
        except subprocess.CalledProcessError:
            pid_list = 0
            print("only have one sas process need to kill, pid_list: %s\n" % pid_list)

        process_to_kill = subprocess.call(["kill", "-2", pid])
        if process_to_kill:
            process_to_kill = subprocess.call(["sudo", "kill", "-9", pid])
            if process_to_kill:
                raise RuntimeError("SAS server not be killed success.")
        print("Process killed: {} {}".format(process_to_kill, pid))

        if pid_list:
            print("pid_list[0]: %s\n" % pid_list[0])
            kill_result = subprocess.call(["sudo", "kill", "-9", pid_list[0]])
            print("Process killed pld_list: {} {}".format(kill_result, pid_list[0]))
        # pid_list = subprocess.check_output(["ps", "-o", "pid", "--ppid", pid, "--noheaders"]).split()

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
            # if ((Responsemessage.has_key("responseCode")) and (int(Responsemessage["responseCode"]) == 0)):
            if (("responseCode" in Responsemessage) and (int(Responsemessage["responseCode"]) == 0)):
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
            # if ((Responsemessage.has_key("responseCode")) and (int(Responsemessage["responseCode"]) == 0)):
            if (("responseCode" in Responsemessage) and (int(Responsemessage["responseCode"]) == 0)):
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
            # if ((Responsemessage.has_key("responseCode")) and (int(Responsemessage["responseCode"]) == 0)):
            if (("responseCode" in Responsemessage) and (int(Responsemessage["responseCode"]) == 0)):
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
            # if ((Responsemessage.has_key("responseCode")) and (int(Responsemessage["responseCode"]) == 0)):
            if (("responseCode" in Responsemessage) and (int(Responsemessage["responseCode"]) == 0)):
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

    def verify_sas_messages_total_times(self, sasMessage, messageCount):
        command = "grep -c "
        command = command + sasMessage
        command = command + " " + self.SAS_SIM_LOG_FILE
        print(command)
        return_code, output = subprocess.getstatusoutput(command)
        print(output)
        print(return_code)
        if output == str(messageCount):
            return True
        # if return_code == 0:
        #     if output == str(messageCount):
        #         return True
        #     else:
        #         return False
        else:
            return False

    def verify_string_in_message_sequence(self, sasMessage, sequence, string):
        command = "grep -m " + str(sequence)
        command = command + " " + sasMessage
        command = command + " " + self.SAS_SIM_LOG_FILE + "|tail -n1"
        command = command + "|grep " + "'" + string + "'"
        print(command)
        return_code, output = subprocess.getstatusoutput(command)
        print(output)
        print(return_code)
        if return_code == 0:
            if output == "":
                return False
            else:
                return True
        else:
            return False

    def prepare_to_check_message(self, init_pos):
        self.logchecker.prepare_to_check_message(init_pos)

    def find_message(self, messageTag):
        return self.logchecker.find_message(messageTag)

    def count_message(self, messageTag):
        return self.logchecker.count_message(messageTag)

    def end_to_check(self):
        self.logchecker.end_to_check()

    def save_sas_log(self, dstFile):
        fpath, fname = os.path.split(dstFile)
        if not os.path.exists(fpath):
            os.makedirs(fpath)
        shutil.copyfile(self.SAS_SIM_LOG_FILE, dstFile)
        print("copy %s -> %s" % (self.SAS_SIM_LOG_FILE, dstFile))
