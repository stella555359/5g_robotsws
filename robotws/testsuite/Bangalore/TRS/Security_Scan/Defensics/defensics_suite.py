#######################################################################################################################
#   VERSION          DATE                AUTHOR                     	               COMMENTS
#   1.0              20-09-2021          nupur.rupram_kohadkar@nokia.com                Initial
#######################################################################################################################


import re
import sys
from taf.sw.security.defensics import defensics
import time
import os
import datetime
import json
from exceptions import *
import subprocess

token = 'dnl6lmhojhk5llbed9ccaajukq'


class defensics_suite:
    def __init__(self, defensics_ip, defensics_token):
        self.dfs = defensics()
        print("[INFO] Connecting to " + defensics_ip)
        self.dfs.connect_to(ip_address=defensics_ip, port=3140, token=defensics_token)

    def check_suite_status(self):
        status = self.dfs.get_suite_status(name=suite_name, timeout=10)
        print("[INFO] Suite is " + status)
        return status

    def load_suite(self, suite_path):
        print("[INFO] Loading " + suite_name + " suite")
        time.sleep(30)
        self.dfs.load_suite(suite_file=r"{}".format(suite_path), name=suite_name, use_newest=True, timeout=30)
        print("[INFO] Suite Loaded Successfully")

    def set_arguments(self, *arg):
        print("[INFO] Setting Arguments")
        print(arg)
        self.dfs.set_suite_settings(suite_name, *arg, timeout=20)

    def check_interoperability(self):
        print("[INFO] Checking interoperability")
        interoperability = self.dfs.start_interoperability_probe(name=suite_name, apply_flag=True, timeout=60)
        return interoperability

    def start_suite(self):
        print("[INFO] Starting Suite")
        response = self.dfs.start_suite(name=suite_name, timeout=10)
        print(response)

    def unload_suite(self):
        print("[INFO] Unloading " + suite_name + " suite")
        self.dfs.unload_suite(name=suite_name, timeout=10)

    def save_report(self):
        print("[INFO] Saving Report")
        result = self.dfs.get_recent_result_of_suite(timeout=10)
        path = result[0].split('/')
        path.pop()
        dir_path = "\\\\".join(path)
        self.dfs.save_report(dest_dir="/home/ute/Defensics/results", result_dir=r"{}".format(dir_path),
                             report_type='zip', timeout=60)
        current_date = datetime.datetime.now()
        folder_name = current_date.strftime("%y%m%d_%H%M%S")
        os.system("mkdir /home/ute/Defensics/results/" + folder_name)
        os.system("unzip /home/ute/Defensics/results/report.zip -d /home/ute/Defensics/results/" + folder_name)
        print("[INFO] Report saved Successfully")


def main_block():
    if check_for_idle_status() is True:
        defensics_p.set_arguments(*arguments)
        time.sleep(60)
        if check_for_correct_interoperability_msg() is True:
            defensics_p.start_suite()
            time.sleep(10)
            if wait_until_suite_fininshes() is True:
                print("[PASS] Suite is Finished")
        else:
            print("[ERROR] Unable to Start Suite because of invalid interoperability status")
    else:
        print("[ERROR] Unable to Start Suite")

    defensics_p.unload_suite()


def check_for_idle_status():
    try:
        print("[INFO] Checking Suite Status")
        time.sleep(30)
        suite_status = defensics_p.check_suite_status()
        if suite_status == "Idle":
            print("[INFO] Suite is " + suite_status)
            return True
        else:
            print("[ERROR] Suite is " + suite_status)
    except Exception as e:
        print("[ERROR] " + str(e))

    return False


def check_for_correct_interoperability_msg():
    for i in range(60):
        interoperability_status = defensics_p.check_interoperability()
        print("[INFO] " + str(interoperability_status))
        if interoperability_status.description != "null":
            if re.search("All.{0,15}passed", interoperability_status.description) or re.search(
                    "are interoperable", interoperability_status.description):
                print("[INFO] " + interoperability_status.description)
                return True
            else:
                print("[ERROR] " + interoperability_status.description)
        else:
            time.sleep(1)
    return False


def wait_until_suite_fininshes():
    print("[INFO] Checking Suite Status")
    for i in range(2880):
        suite_status = defensics_p.check_suite_status()
        if suite_status == "Finished":
            defensics_p.save_report()
            return True
        elif suite_status == "Failed":
            print("[FAIL] Suite is Failed")

        else:
            time.sleep(60)

    return False


if __name__ == '__main__':
    defensics_ip = '10.43.82.57'
    defensics_token = token
    pwd = subprocess.check_output('pwd')
    pwd = pwd.strip("\n")
    f = open("{0}/defensics_info.json".format(pwd))
    data = json.load(f)
    global suite_path, arguments, suite_name
    suite_name = sys.argv[1]
    suite_path = data["suite"][suite_name]["suite_file_path"]
    arguments_list = data["suite"][suite_name]["arguments"]
    arguments = tuple(arguments_list)
    defensics_p = defensics_suite(defensics_ip, defensics_token)

    try:
        defensics_p.load_suite(suite_path)
        main_block()

    except Exception as e:
        print(e)
        try:
            defensics_p.unload_suite()
            defensics_p.load_suite(suite_path)
            main_block()
        except Exception as e:
            print("[ERROR] " + str(e))
