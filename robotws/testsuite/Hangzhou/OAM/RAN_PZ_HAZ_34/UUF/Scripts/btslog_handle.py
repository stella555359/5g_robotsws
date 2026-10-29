#!/usr/bin/python
# -*- coding: UTF-8 -*-

from robot.libraries.BuiltIn import BuiltIn
# from Resource.UUF_vars import *  # for windows
from UUF_vars import *  # for linux


def split_btslog_via_ip(file_path, gnb_file_path, ru_file_path):
    with open(file_path, "r") as btslog_file:
        base_lines = btslog_file.readlines()
        gnb_lines = ""
        ru_lines = ""
        for line in base_lines:
            if line.count('[192.168.255.129]') > 0:
                gnb_lines += line
            elif line.count('[192.168.100.1]') > 0:
                ru_lines += line
    gnb_btslog = "".join(gnb_lines)
    ru_btslog = "".join(ru_lines)
    with open(gnb_file_path, "a") as btslog_file:
        btslog_file.write(gnb_btslog)
    with open(ru_file_path, "a") as btslog_file:
        btslog_file.write(ru_btslog)


def get_gnb_and_ru_control_pc_info():
    tl = BuiltIn().get_variable_value("${tl}")
    bts_info = []
    need_gnb_info = True
    gnb_addr_pc = tl.test_pc.default_ssh_connection_details.addr
    rus_info = get_ru_info(tl)
    for index, ru_info in enumerate(rus_info):
        if ru_info['ctrl_addr'] == gnb_addr_pc:
            ru_info['module_type'] = ['ru', 'gnb']
            ru_info['btslog_name'] = 'btslog_gnb_ru_' + str(index + 1)
            need_gnb_info = False
        else:
            ru_info['module_type'] = ['ru']
            ru_info['btslog_name'] = 'btslog_ru_' + str(index + 1)
        ru_info['ru_username'] = ru_info['username']
        ru_info.pop('username')
        ru_info['ru_password'] = ru_info['password']
        ru_info.pop('password')
        if ru_info['ctrl_username'] != 'nokia5G':
            bts_info.append(ru_info)
    if need_gnb_info:
        gnb_pc_username = tl.test_pc.default_ssh_connection_details.username
        gnb_pc_password = tl.test_pc.default_ssh_connection_details.password
        gnb_info = {'ctrl_addr': gnb_addr_pc, 'ctrl_username': gnb_pc_username, 'ctrl_password': gnb_pc_password,
                    'module_type': ['gnb'], 'btslog_name': 'btslog_gnb'}
        bts_info.append(gnb_info)
    return bts_info


def get_windows_ru_control_pc_info():
    tl = BuiltIn().get_variable_value("${tl}")
    windows_ru_info = []
    rus_info = get_ru_info(tl)
    for index, ru_info in enumerate(rus_info):
        ru_info['module_type'] = ['ru']
        ru_info['btslog_name'] = 'btslog_ru_' + str(index + 1)
        ru_info['ru_username'] = ru_info['username']
        ru_info.pop('username')
        ru_info['ru_password'] = ru_info['password']
        ru_info.pop('password')
        if ru_info['ctrl_username'] == 'nokia5G':
            windows_ru_info.append(ru_info)
    return windows_ru_info


if __name__ == "__main__":
    file_path_tmp = 'D://SYSLOG_20.LOG'
    gnb_file_path_tmp = 'D://SYSLOG_20_gnb.LOG'
    ru_file_path_tmp = 'D://SYSLOG_20_ru.LOG'
    split_btslog_via_ip(file_path_tmp, gnb_file_path_tmp, ru_file_path_tmp)
