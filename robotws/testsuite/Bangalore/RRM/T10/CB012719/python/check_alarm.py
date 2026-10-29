from taf.sbts.oam.coam.admin import admin
import csv
import json
# import numpy as np
import xml.etree.ElementTree as ET
import subprocess
import pkgutil
import importlib
import os
import time
from datetime import datetime
import math


# def install_package(package):
#     try:
#         subprocess.call(['pip', 'install', '-U', 'numpy', package])
#     except Exception as e:
#         raise (AssertionError("Error installing package " + str(e)))
#
#
#
#
class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


def check_alarm_description(faultid, fault_name, description=None, cellid='MRBTS-1/NRBTS-1/NRCELL-1'):
    api = admin()
    connection = api.connect_to()
    result = connection.get_active_alarms()
    cellist = AutoDict()
    count = 0
    for alarms in result:
        indx = AutoDict()
        indx[alarms['faultId']] = count
        cell = alarms["alarmingObjectIds"]
        try:
            cellist[cell[0]['configuration']].append(indx)
        except Exception:
            cellist[cell[0]['configuration']] = [indx]
        count += 1
    alarmIds = cellist.get(cellid)
    if alarmIds is None:
        print("*WARN* No Alarms found in the cell")
        return False
    print(alarmIds)
    id = None
    for item in alarmIds:
        id = item.get(faultid)
        if id is not None:
            break
    if id is None:
        print("*WARN*  Alarm is not present in the cell")
        return False
    _fault_name = result[id]['faultName']
    _description = result[id]['alarmText']['alarmAdditionalInfo']['supplAlarmInfo']
    if _fault_name != fault_name:
        print(f"fault name mismatched, expected:{fault_name}, current:{_fault_name}")
        return False
    if _description != description:
        print(f"fault discription mismatched, expected:{description}, current:{_description}")
        return False
    return True


# def download_measurements(path="/home/ute/Downloads/",file='nori.zip'):
#     tp = path + file
#     api = admin()
#     connection = api.connect_to()
#     connection.collect_pm_files(tp)
#     tp=file.replace('.zip','')
#     tp=path + tp
#     zf= path+file
#     cmd= 'unzip -d '+tp+' ' +zf
#     print(cmd)
#     os.system(cmd)
#     uz = path+file.replace('.zip','')
#     cmd=' cd '+uz+'/PERFMON_FILES;'+'gunzip *'
#     print(cmd)
#     os.system(cmd)
#
#
# def update_delta_upload(file,value):
#     value = str(value*10)
#     with open(file) as fp:
#         data=json.load(fp)
#         data[0]['parameters'][0].update({"value": value})
#         print(data)
#     with open(file,'w') as fp:
#         json.dump(data,fp)
#         print(data)
#
#     upload_delta(file)
#     time.sleep(40)

# update_delta_upload('/home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/CB012719/config/SBTS25R2/pwr_upd.json',12)


def get_list_of_faults_check(alarm_info, active=None):
    fault_list = []
    for fault in alarm_info:
        fault_list.append(fault['additionalFaultID'])
    print(fault_list)
    cnt = 0
    for alrm_act in active:
        if alrm_act in fault_list:
            cnt = cnt + 1
        else:
            print('Alarm ', alrm_act, 'is not presnet in the list', active)
    if len(active) == cnt:
        return 'pass'
    else:
        return 'fail'

# def upload_delta(file):
#    api = admin()
#    connection = api.connect_to()
#    connection.perform_delta_recommissioning(delta_file=file)
#    #print(help(connection))

# upload_delta("CB012719/config/SBTS25R3/Delta_Configuration_1CC_TDD_GBR_FS_tddlte_0ms_4_gp_RIM_FW1.json")
# time.sleep(180)
# upload_delta("CB012719/config/SBTS25R2/rim_pwr.json")
# time.sleep(180)
# upload_delta(CB012719/config/SBTS25R2/CB008246-TDD_Dynamic_AL_Delta_Configuration.json")
# time.sleep(180)
#
# download_measurements()
# read_file_list(r"C:\Users\kumarnay\Downloads\cmp\plotting\kpi\counter\PERFMON_FILES")
