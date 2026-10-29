#!/usr/bin/python
# -*- coding: UTF-8 -*-
from robot.libraries.BuiltIn import BuiltIn
from CB006292_vars import *  # for linux


def get_gnb_control_pc_info():
    tl = BuiltIn().get_variable_value("${tl}")
    bts_info = []
    need_gnb_info = True
    gnb_addr_pc = tl.test_pc.default_ssh_connection_details.addr
    if need_gnb_info:
        gnb_pc_username = tl.test_pc.default_ssh_connection_details.username
        gnb_pc_password = tl.test_pc.default_ssh_connection_details.password
        gnb_info = {'ctrl_addr': gnb_addr_pc, 'ctrl_username': gnb_pc_username, 'ctrl_password': gnb_pc_password,
                    'module_type': ['gnb'], 'btslog_name': 'btslog_gnb'}
        bts_info.append(gnb_info)
    return bts_info


def get_fault_id_via_nom(alarms_list):
    list_alarm = []
    for alarms in alarms_list:
        for key, value in alarms.items():
            print(value)
            try:
                if value.split('additionalFaultID=')[1].split()[0]:
                    list_alarm.append(int(value.split('additionalFaultID=')[1].split()[0]))
            except BaseException as e:
                pass
    return list_alarm
