#!/usr/bin/python

# import urllib3
import os
import sys
import time
import json
import requests
import wget
from taf.sbts.oam.coam.admin import admin

DL_SERVER = "https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/"
DL_SERVER_5G = "https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/"
BUILD_HISTORY_DIR = "/home/ute/jenkins/logs/test_run_log_archive/"
BUILD_HISTORY_LOG = "/home/ute/jenkins/logs/test_run_log_archive/build_execution_history.txt"
BUILD_PATH = "/home/ute/jenkins/Build/"
CONFIG_PATH = "/home/ute/jenkins/logs/Configuration"
POMPKA_PATH = "/home/ute/robotlte/testsuite/WMP/SOAM1/resources_taf/pompka/"
ADMIN_ALIAS = "admin_1"
ADMIN_API_LOGS = '/home/ute/jenkins/logs/Api_logs/Admin'
WFT = "https://wft.int.net.nokia.com:8091/SBTS/api/v1/promotion.json?"
ACCESS_KEY = "access_key=st75Ssr1C7SJQFVu9XSRpImoAriXuehDAvFSW4Po"
ITEMS = "&view[items]=1"
SORT_BY = "&view[sorting_field]=created_at"
SORT_DIR = "&view[sorting_direction]=DESC"
GROUP_BY = "&view[group_by]=promotion_tag.tag"
COLUMN_1 = "&view[columns[][id]]=build.baseline"
COLUMN_2 = "&view[columns[][id]]=branch.title"
COLUMN_3 = "&view[columns[][id]]=created_at"
COLUMN_4 = "&view[columns[][id]]=build%7Cpromotion_status"
COLUMN_5 = "&view[columns[][id]]=promotion_tag.tag"
FILTER_1 = "&view[view_filters_attributes[241061535675924]][column]=active"
FILTER_2 = "&view[view_filters_attributes[241061535675924]][operation]=eq"
FILTER_3 = "&view[view_filters_attributes[241061535675924]][value][]=1"
FILTER_4 = "&view[view_filters_attributes[846075306168896]][column]=promotion_tag.tag"
FILTER_5 = "&view[view_filters_attributes[846075306168896]][operation]=eq"
FILTER_6 = "&view[view_filters_attributes[852447244083180]][column]=branch.title"
FILTER_7 = "&view[view_filters_attributes[852447244083180]][operation]=cont"
COLUMNS = COLUMN_1 + COLUMN_2 + COLUMN_3 + COLUMN_4 + COLUMN_5
FILTERS = FILTER_1 + FILTER_2 + FILTER_3 + FILTER_4 + FILTER_5 + FILTER_6 + FILTER_7
url = WFT + ACCESS_KEY + ITEMS + SORT_BY + SORT_DIR + COLUMNS + FILTERS


def candidate_checker(branch, build_tag):
    branch_url = "&view[view_filters_attributes[852447244083180]][value][]=" + branch
    tag_url = "&view[view_filters_attributes[846075306168896]][value][]=" + build_tag
    json_url = url + branch_url + tag_url
    print("WFT link prapared for " + branch + " branch with " + build_tag + " tag is:")
    print(json_url)
    try:
        request_wft = requests.get(json_url)
        json_str = json.loads(request_wft.text)
        latest_candidate = json_str['items'][0]['build.baseline']
    except Exception as e:
        print("Something went wrong, please provided branch and tag")
        quit(-1)
    print("Latest candidate: %s\n" % latest_candidate)
    return latest_candidate, branch


def candidate_downloader(latest_candidate, branch, test_package):
    package_suffix = ""
    package_suffix_testpack = ""
    package_name = ""
    server = ""
    check_build_history(latest_candidate)
    print("[INFO] Starting SW download from:")

    if branch.strip() != "5G19":
        package_suffix = "_release_BTSSM_downloadable_A54"
        package_suffix_testpack = "_release_BTSSM_downloadable_testpackage_"
        package_name = latest_candidate
        server = DL_SERVER
    if branch.strip() == "5G19":
        latest_candidate = latest_candidate.split("_")[1]
        package_name = "AirScale-" + latest_candidate
        server = DL_SERVER_5G
    if test_package == 0:
        dl_url = server + branch + "/" + package_name + package_suffix + ".zip"
        print(dl_url)
        expected_name = package_name + package_suffix + ".zip"
    elif test_package == 1 or test_package == 2:
        if test_package == 1:
            downloadable_package_name = package_name + package_suffix_testpack + "T1.zip"
        if test_package == 2:
            downloadable_package_name = package_name + package_suffix_testpack + "T2.zip"
        dl_url = server + latest_candidate + "/" + downloadable_package_name
        expected_name = downloadable_package_name
    else:
        print("[FAILED] Please specify test_package parameter\n")
        quit(-1)
    if not os.path.isfile(BUILD_PATH + "%s" % expected_name):
        print("Build to download: %s\n" % expected_name)
        try:
            build_get = wget.download(dl_url, out=BUILD_PATH)
            # print('Usun po testach')
        except Exception as e:
            print("[FAILED] Build download failed, reseon:", e)
            quit(-1)
    else:
        print("Build already tested, stopping execution\n")
        quit(-1)
    return expected_name


def sw_updater(build_name, scf_file):
    print("\nStart SW update")
    os.system("mkdir -p /home/ute/results/swupdate/")
    log_path = "/home/ute/results/swupdate/"
    command = "/opt/ute/python/bin/robot "
    config_var = "--variable CONFIGURATION:DEV_WRO_TL161 "
    # backup_scf = "--variable BACKUP:%s " % backup_conf
    # build_dir = "--variable ENB_BUILD_PATH:" + BUILD_PATH + " "
    build_package = "--variable ENB_BUILD:" + build_name + " "
    scf = "--variable SCF_FILE:" + scf_file + " "
    # sw_update_method = "--variable UPD_METHOD:" + upd_method + " "
    # conf_and_meth = config_var + sw_update_method
    log_params = "-L TRACE -b swupdate.log "
    log_dir = "-d %s" % log_path + " "
    file_name = "pompka.robot"
    print("Command: %s" + command + scf + build_package + scf + log_params + log_dir + POMPKA_PATH + file_name)
    os.system(command + scf + build_package + scf + log_params + log_dir + POMPKA_PATH + file_name)
    sw_update_verification(log_path)
    log_build_history(build_name)
    time.sleep(600)


def log_build_history(build_name):
    i = 0
    indices = []
    for index in build_name:
        if index == "_":
            indices.append(i)
        i = i + 1
    command2 = "echo %s >> " % build_name[:indices[4]]
    log_backup_dir = BUILD_HISTORY_LOG
    os.system(command2 + log_backup_dir)


def check_build_history(latest_candidate):
    if not os.path.isdir(BUILD_HISTORY_DIR):
        os.system("sudo mkdir -p " + BUILD_HISTORY_DIR)
    if not os.path.isfile(BUILD_HISTORY_LOG):
        os.system("sudo touch " + BUILD_HISTORY_LOG)
        os.system("sudo chown -R ute:ute " + BUILD_HISTORY_DIR)
    print("[INFO] Build execution history check")
    with open(BUILD_HISTORY_LOG, 'r') as f:
        Lines = f.readlines()
    f.close
    # build_history_log = file(BUILD_HISTORY_LOG)
    for line in Lines:
        if latest_candidate.strip() in line:
            print("[FAILED] Build was already tested")
            exit(-1)
        else:
            pass
    with open(BUILD_HISTORY_LOG, 'a+') as f:
        f.writelines(latest_candidate)
        print("[OK] Build was not tested, adding to history")
    f.close


def sw_updater_via_api(candidate, scf_file, expected_state):
    print("\n[INFO] Starting SW updater")
    api = admin()
    connection = api.connect_to(admin_api_log_dir=ADMIN_API_LOGS)
    bts_state = connection.get_bts_statuses()
    print("BTS is currently in " + bts_state['proceduralState'] + " state.")
    bts_software = connection.get_software_info()
    active_software = (bts_software['Active SW version'])
    print('Active SW: ' + active_software)
    passive_software = (bts_software['Passive SW version'])
    print('Passive SW: ' + passive_software)
    print('Planned SW: ' + candidate)
    print('[INFO] Commissioning started')
    connection.get_current_scf_file(CONFIG_PATH, 'Current_SCF.xml')
    bts_id = connection.get_id_for_current('BTS')
    connection.wait_sw_update_possible()
    try:
        connection.perform_commissioning(bts_id, scf_file)
    except Exception as e:
        print("[FAILED] SCF commisioning failed, reseon: ", e)
    connection.wait_sw_update_possible()
    print("[OK] Commisioning completed")
    print("[INFO] SWupdate started")
    try:
        software_path = BUILD_PATH + candidate
        connection.update_software(software_path, timeout=3600)
        print("[OK] SWupdate completed")
    except Exception as e:
        print("[FAILED] Software update failed, reason: ", e)
    timeout = 900
    # expected_state = "OnAir"
    period = 0.25
    mustend = time.time() + timeout
    print("[INFO] Checking if BTS not reponding to ping")
    while time.time() < mustend:
        bts_host_129 = os.system("ping -c 1 192.168.255.129 2>&1 >/dev/null")
        bts_host_1 = os.system("ping -c 1 192.168.255.1 2>&1 >/dev/null")
        if ((bts_host_129 == 256) and (bts_host_1 == 256)):
            print("[OK] BTS not responding to ping, restart started")
            mustend = time.time()
        else:
            time.sleep(period)
    mustend = time.time() + timeout
    print("[INFO] Checking if BTS reponding to ping")
    while time.time() < mustend:
        bts_host_129 = os.system("ping -c 1 192.168.255.129 2>&1 >/dev/null")
        bts_host_1 = os.system("ping -c 1 192.168.255.1 2>&1 >/dev/null")
        if ((bts_host_129 == 0) and (bts_host_1 == 0)):
            print("[OK] BTS starts responding to ping, restart completed")
            mustend = time.time()
        else:
            time.sleep(period)
    mustend = time.time() + timeout
    print("[INFO] Checking BTS SWupdate status")
    while time.time() < mustend:
        bts_state = connection.get_bts_statuses(timeout=100)
        if bts_state['proceduralState'] == expected_state:
            swupdate_status = "completed"
            mustend = time.time()
        else:
            swupdate_status = "ongoing"
            time.sleep(period)
    api.teardown_all_aliases_for_admin()
    print("[INFO] Providing final results of Software update")
    if swupdate_status == "completed":
        print("[OK] Software update complted and BTS in " + expected_state + " state")
    else:
        print("[FAILED] Software update complted but BTS is not in " + expected_state + " state")
        exit(-1)


def pompka():
    feature_branch = sys.argv[1]
    build_tag = sys.argv[2]
    custom_build = sys.argv[3]
    install_now = sys.argv[4]
    scf_path = sys.argv[5]
    expected_state = sys.argv[6]
    print("Branch: " + feature_branch)
    print("Path to scf file: " + scf_path)
    print("Promotion tag: " + build_tag)
    path = ""
    name = ""
    print("Cleaning: " + BUILD_PATH + " from files: *.bin, *.zip, *.html")
    os.system("sudo rm -f " + BUILD_PATH + "*.bin " + BUILD_PATH + "*.zip " + BUILD_PATH + "*.html ")
    os.system("sudo mkdir -p " + BUILD_PATH)
    os.system("sudo chown -R ute:ute /home/ute/jenkins/")
    print("Cleanig logs: " + ADMIN_API_LOGS + " from files: *.log, *.txt, *.ims2")
    os.system("sudo rm -f " + ADMIN_API_LOGS + "/" + "*.txt " + ADMIN_API_LOGS + "*.log " + ADMIN_API_LOGS + "*.ims2 ")
    os.system("sudo mkdir -p " + ADMIN_API_LOGS)

    if custom_build.strip() == "false":
        print("Download promoted package")
        latest_candidate, branch = candidate_checker(feature_branch, build_tag)
        name = candidate_downloader(latest_candidate, feature_branch, 0)
    elif custom_build.strip() == "test_1":
        print("Download standard and test packages")
        latest_candidate, branch = candidate_checker(feature_branch, build_tag)
        name = candidate_downloader(latest_candidate, branch, 0)
        candidate_downloader(latest_candidate, feature_branch, 1)
    elif custom_build.strip() == "test_2":
        print("Download standard and test packages")
        latest_candidate, branch = candidate_checker(feature_branch, build_tag)
        name = candidate_downloader(latest_candidate, feature_branch, 0)
        candidate_downloader(latest_candidate, feature_branch, 2)
    else:
        print("Download custom package: " + custom_build)
        latest_candidate = custom_build
        name = candidate_downloader(latest_candidate, feature_branch, 0)
    if install_now.strip() == "true":
        sw_updater_via_api(name, scf_path, expected_state)
    else:
        print("\nInstallation was not activated, finishing script")


pompka()
