####################################################################################
#   VERSION          DATE                AUTHOR                     	    COMMENTS
#   1.0              16-Aug-2022         nupur.rupram_kohadkar@nokia.com     Initial
####################################################################################

import smtplib
import argparse
import datetime
import time
from email.MIMEMultipart import MIMEMultipart
from email.MIMEBase import MIMEBase
from email.MIMEText import MIMEText
from email.Utils import COMMASPACE, formatdate
from email import Encoders
from os.path import join, expanduser
from collections import OrderedDict
import os
import logging
import json
import re
import shlex
import subprocess
import paramiko
from robot.libraries.BuiltIn import BuiltIn
import sys
from taf.sbts.oam.coam.admin import admin as ute_admin
from tabulate import tabulate
from ute_syslog import ute_syslog

#####################################################################################################################
robot_log_path = '/home/ute/logs_archive'
params_json_host_path = '/home/automation_batch_execution_utility/params.json'
params_json_local_path = "/home/ute/params.json"
log_archive_script_path = '/home/automation_batch_execution_utility/logs_archive.py'
# central_host={'ip':'10.43.254.141' ,'username':'root', 'password': '#Li&2TrsL0ckTe!'}
central_host = {'ip': '10.43.254.141', 'username': 'ute', 'password': 'Secur!ty@123'}
build_download_upgrade = 'build_download_upgrade_debug.log'


#####################################################################################################################


def parse_arguments():
    '''This function validates the type of batch file'''

    parser = argparse.ArgumentParser(description="TRS Pz Automation utility for batch executions")
    parser.add_argument("-r", "--release", help="Enter Release e.g. SBTS00, SBTS22R3, SBTS22R4 [Mandatory]",
                        required=True)
    argument = parser.parse_args()
    build_release = argument.release
    build_release = build_release.upper()
    write_debug_log(build_release, "DEBUG")
    return build_release


def create_script_debug_log():
    script_log = open(build_download_upgrade, 'w')
    script_log.close()


def get_time():
    return datetime.datetime.now().strftime('%Y-%m-%d%H:%M:%S')


def write_debug_log(msg, msg_type):
    script_log = open(build_download_upgrade, 'a')
    script_log.write(get_time() + msg_type + '   ' + str(msg) + '\n')
    script_log.close()


def nice_print(message, sign='*'):
    print(''.join([' ', sign * len(message)]))
    print(''.join([' ', message]))
    print(''.join([' ', sign * len(message)]))
    logging.info(message)


def build_download(build_release):
    write_debug_log("Downloading Lastest Build", "INFO")
    write_debug_log("sshpass -p {0} scp {1}@{2}:{3} {4}".format(central_host['password'], central_host['username'],
                                                                central_host['ip'], params_json_host_path,
                                                                params_json_local_path), "INFO")
    os.system("sshpass -p {0} scp {1}@{2}:{3} {4}".format(central_host['password'], central_host['username'],
                                                          central_host['ip'], params_json_host_path,
                                                          params_json_local_path))
    os.system("sed -i '0,/Required_Release/s//{0}/' {1}".format(build_release, params_json_local_path))
    curl_cmd = "curl -H 'Accept: application/json' -H 'Content-Type:application/json' -d@{0} {1} -o {2}".format(
        "params.json", "https://wft.int.net.nokia.com:8091/SBTS/api/v1/build.json", "response.json")
    write_debug_log(curl_cmd, "INFO")
    stdout = os.system(curl_cmd)
    if stdout != 0:
        nice_print("curl: (6) Could not resolve host")
        write_debug_log("curl: (6) Could not resolve host", "ERROR")
        sys.exit(1)
    f = open("response.json")
    data = json.load(f)
    try:
        latest_release_build = data["items"][0]["version"]
        print("Latest Release Build : " + latest_release_build)
    except Exception as e:
        nice_print("Failed: " + data["error"])
        write_debug_log("Unsupported Release Version", "ERROR")
        sys.exit(1)
    if os.path.exists("/home/ute/{0}_release_BTSSM_downloadable_A54.zip".format(latest_release_build)):
        os.system("rm -rf /home/ute/{0}_release_BTSSM_downloadable_A54.zip".format(latest_release_build))

    link = "aria2c --all-proxy='http://10.158.100.6:8080' -x 16 -s 16 " \
           "http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/{0}/{1}_release_BTSSM_downloadable_A54.zip".format(
            build_release, latest_release_build)
    stdout = os.system(link)
    write_debug_log(stdout, "INFO")
    build_path = "/home/ute/{0}_release_BTSSM_downloadable_A54.zip".format(latest_release_build)
    return build_path


def setup_admin():
    admin = ute_admin()
    admin.setup_admin(bts_host="192.168.255.129", bts_port="443", username="Nemuadmin", password="nemuuser",
                      use_ssl=True)
    return admin


def check_active_alarms(execution):
    write_debug_log("Checking Active Alarms", "INFO")
    admin = setup_admin()
    alarm_list = admin.get_active_alarms(timeout=10)
    table = []
    for index in range(len(alarm_list)):
        table.append([alarm_list[index]["faultId"], alarm_list[index]["faultName"]])
    print("\n\n===== Active Alarms {0} Upgrade ======\n".format(execution))
    print(tabulate(table, headers=['Fault ID', 'Fault Name']))
    # print(alarm_list[index]["faultId"], alarm_list[index]["faultName"])
    admin.teardown_admin()


def check_mrbts_status(execution):
    write_debug_log("Checking MRBTS Status", "INFO")
    admin = setup_admin()
    mrbts_state = admin.get_mrbts_state(timeout=10)
    print("\n\nMRBTS Status {0} Upgrade : {1}\n".format(execution, mrbts_state))
    admin.teardown_admin()


def build_upgrade(build_path):
    write_debug_log("Upgrading BTS Software...", "INFO")
    write_debug_log(build_path, "INFO")
    print("\n\nUpgrading BTS SW..\n")
    admin = setup_admin()
    try:
        admin.update_software(build_path, should_activate=True, timeout=2400)
        print("\nSW Build Upgraded in 1st Attempt\n")
    except Exception as e:
        write_debug_log("Software Upgrade Failed due to {}".format(e), "DEBUG")
        time.sleep(120)
        try:
            write_debug_log("Upgrading BTS Software...", "INFO")
            admin.update_software(build_path, should_activate=True, timeout=2400)
            print("\nSW Build Upgraded in 2nd Attempt\n")
        except Exception as e:
            write_debug_log("Software Upgrade Failed due to {}".format(e), "DEBUG")
            time.sleep(120)
            try:
                write_debug_log("Upgrading BTS Software...", "INFO")
                admin.update_software(build_path, should_activate=True, timeout=2400)
                print("\nSW Build Upgraded in 3rd Attempt\n")
            except Exception as e:
                write_debug_log("Software Upgrade Failed due to {}".format(e), "ERROR")
                admin.teardown_admin()
                sys.exit(1)
    write_debug_log("Software Upgraded Sucessfully!!", "INFO")
    os.system("rm -rf {0}".format(build_path))
    admin.teardown_admin()


class syslog_collection():
    def __init__(self):
        self.syslog = ute_syslog()

    def start_syslog(self):
        try:
            print("\nStarting Syslog ")
            write_debug_log("Starting Syslog", "INFO")
            file_name = "Syslog" + ".log"
            self.syslog.start_syslog("/tmp/", file_name, host_ip='192.168.255.126', file_limit=10000000,
                                     add_line_number=True, alias='btslog')
            print("\nSyslog Started\n")
            write_debug_log("Syslog Started", "INFO")
        except Exception as e:
            print("\nUnable to Start Syslog due to " + str(e) + "\n")
            write_debug_log("Syslog Started", "INFO")

    def count_syslog_prints(self, error_warning):
        count = self.syslog.count_syslog_messages(error_warning, alias='btslog')
        return count

    def return_message(self, error_warning):
        message = self.syslog.message_should_exist_in_syslog_file(error_warning, alias='btslog')
        return message

    def stop_syslog(self):
        try:
            self.syslog.stop_syslog(alias='btslog')
            print("\nSyslog Stopped\n")
            self.syslog.teardown_all_aliases_for_syslog()
        except Exception as e:
            print("\nUnable to Stop Syslog due to " + str(e) + "\n")


######################################################################################################################

def analyse_syslog(s):
    unexpected_err = {"ERR/tas/Trs": 0,
                      "ERR/LFS.*trs": 0,
                      "ERR/WRN": 0,
                      "ERR/TRSW/TRSWSyslog": 0,
                      "TRS.*FATAL": 0,
                      "WRN/TRSW/TRSWSyslog": 0,
                      "ERR/TAS": 0,
                      "ERR/TEM": 0,
                      "WRN/tas": 0,
                      "WRN/TEM": 0,
                      "ERR/CCS.*tas": 0,
                      "ERR/CCS.*trs": 0,
                      "ERR/DEM": 0,
                      "ERR/Has/PLH": 0,
                      "ERR/Lim": 0,
                      "INF/TRSW/TRSWSyslog,*ERROR*": 0,
                      "Starting resetting procedure": 0,
                      "inactive 4559": 0,
                      "trswDdal_sfp_cooled_transciver_check cooled_implemented_get FAILED retVal : 0": 0
                      }

    file_name = "Analysed_logs_" + get_time() + ".txt"
    file_object = open('/tmp/' + file_name, 'a')
    table = []
    for i in unexpected_err:
        count = s.count_syslog_prints(i)
        table.append([i, str(count)])
        # print(i + " : " + str(count))
        if count > unexpected_err[i]:
            unexpected_message = s.return_message(i)
            file_object.write(unexpected_message.encode('utf-8'))
            file_object.write("\n")
        else:
            pass
    print("+++++++ SYSLOG Analysis +++++++")
    print(tabulate(table, headers=['Error Category', 'Count']))


def main_func_block():
    """This function controls the flow of utility"""
    create_script_debug_log()

    build_release = parse_arguments()
    s = syslog_collection()
    build_path = build_download(build_release)
    print(build_path)
    check_active_alarms("before")
    check_mrbts_status("before")
    s.start_syslog()
    build_upgrade(build_path)
    time.sleep(300)
    analyse_syslog(s)
    s.stop_syslog()
    check_active_alarms("after")
    check_mrbts_status("after")


if __name__ == "__main__":
    main_func_block()
