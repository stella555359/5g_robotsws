import xml.etree.ElementTree as ET
import csv
from taf.sbts.oam.coam.admin import admin
import os
import tinny_parser
import subprocess
import pkgutil
import importlib
import json


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', 'numpy', package])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def is_pandas_installed():
    return bool(pkgutil.find_loader('pandas'))


def is_matplotlib_installed():
    print('mta_isn-->', bool(pkgutil.find_loader('matplotlib')))
    return bool(pkgutil.find_loader('matplotlib'))


def install_and_import_pandas():
    print("pandas library installation")
    if not is_pandas_installed():
        install_package('pandas')
    return importlib.import_module('pandas')


def install_and_import_matplotlib():
    print("matplot library installation")
    if not is_matplotlib_installed():
        install_package('matplotlib')
    return importlib.import_module('matplotlib')


def clean_target(before, after):
    info = os.walk(before)
    for (c_bef, d, bef_fl) in info:
        break
    info = os.walk(after)
    for (c_aft, d, aft_fl) in info:
        break

    for rem_fl in bef_fl:
        try:
            os.remove(c_aft + '/' + rem_fl)
        except FileNotFoundError:
            print('NP', rem_fl)


#
# mnp = clean_target(r'C:\Users\kumarnay\Downloads\tmp_del\clean_up\before\PERFMON_FILES',
#                    r'C:\Users\kumarnay\Downloads\tmp_del\clean_up\after\PERFMON_FILES')


def get_cqi_derived_verify(file, protected_slots=None):
    install_and_import_pandas()
    install_and_import_matplotlib()
    import pandas as pd
    import matplotlib.pyplot as plt
    df = pd.read_csv(file)
    req_flds = ['sfn', 'slot', 'rnti', 'cqiDerivedMcs', 'suPdschTbTransmitPower']
    req_info = df.loc[df['type'] == 'dlFdSchedData'][req_flds]
    # print(req_info)
    avg_cqi_slt = get_avg_cqiDerivedMcs_per_slot(req_info)
    ret = verify_avg_with_others(avg_cqi_slt, protected_slots)
    avg_pdsch_tb_slt = get_avg_pdschtb_transmit_pwr(req_info)
    ret1 = verify_avg_with_others(avg_pdsch_tb_slt, protected_slots)

    if (ret == 'pass') and (ret1 == 'pass'):
        return 'pass'
    else:
        return 'false'


def get_avg_cqiDerivedMcs_per_slot(req_info):
    req_info = req_info.loc[req_info['cqiDerivedMcs'] != 255]
    # print("-->",req_info)
    slots = req_info['slot'].unique().tolist()
    # print(slots)
    avg_cqi_slt = {}
    for slt in slots:
        tmp = req_info.loc[req_info['slot'] == slt]['cqiDerivedMcs'].mean()
        avg_cqi_slt[slt] = tmp
        # print('slt',avg_cqi_slt)
    return avg_cqi_slt


def verify_avg_with_others(avg_cqi_slt, protected_slots):
    cnt = 0
    print('protected_slots', protected_slots, avg_cqi_slt.keys())
    for slt in protected_slots:
        if slt not in avg_cqi_slt.keys():
            continue
        mcs_level = avg_cqi_slt[slt]
        for o_slts in avg_cqi_slt.keys():
            if o_slts in protected_slots:
                continue
            elif mcs_level < avg_cqi_slt[o_slts]:
                cnt = cnt + 1
            else:
                print('Error: avg mcs/power on slot {0} MCS/power on protected {1} mcs/power on other slot {2}'.format(
                    o_slts, mcs_level, avg_cqi_slt[o_slts]))
                return 'fail'
    if cnt >= len(protected_slots):
        return 'pass'
    else:
        return 'fail'


def get_avg_pdschtb_transmit_pwr(req_info):
    req_info = req_info.loc[req_info['cqiDerivedMcs'] != 255]
    # print("-->",req_info)
    slots = req_info['slot'].unique().tolist()
    # print(slots)
    avg_pdsch_tb_slt = {}
    for slt in slots:
        tmp = req_info.loc[req_info['slot'] == slt]['suPdschTbTransmitPower'].mean()
        avg_pdsch_tb_slt[slt] = tmp
        # print('slt',avg_pdsch_tb_slt)
    return avg_pdsch_tb_slt


def get_list_of_faults(alarm_info, active=None):
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


def check_scheduling(file, protected_slots):
    install_and_import_pandas()
    install_and_import_matplotlib()
    import pandas as pd
    import matplotlib.pyplot as plt
    df = pd.read_csv(file)
    req_flds = ['slot']
    req_info = df.loc[df['type'] == 'dlFdSchedData'][req_flds]
    slots = req_info['slot'].unique().tolist()
    cnt = 0
    for p_slot in protected_slots:
        if p_slot in slots:
            cnt = cnt + 1
    if cnt == len(protected_slots):
        print("Traffic is scheduled on protected slot")
        return 'pass'
    else:
        print("Slots", slots, 'protect', protected_slots, 'cnt', cnt)
        return 'fail'
