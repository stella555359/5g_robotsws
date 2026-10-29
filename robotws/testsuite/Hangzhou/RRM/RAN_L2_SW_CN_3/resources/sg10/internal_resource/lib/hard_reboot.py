# -*- coding: UTF-8 -*-

import sys
import getopt
import datetime
import re
import os
import csv
import shutil
import time
import traceback
import requests
import socket
from fnmatch import fnmatch
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh
from robot.libraries.OperatingSystem import OperatingSystem
from taf.pdu import pdu
from ute_fsmaccess import ute_fsmaccess


bbu_pb1 = ['10.108.163.42', 2, 'FACOM']
bbu_pb2 = ['10.108.163.49', 3, 'FACOM']
bbu_pb3 = ['10.108.163.42', 3, 'FACOM']
bbu_pb4 = ['10.108.163.49', 2, 'FACOM']
bbu_pb5 = ['10.108.163.42', 4, 'FACOM']
bbu_pb6 = ['10.69.80.41', 3, 'FACOM']
bbu_pb7 = ['10.108.163.49', 4, 'FACOM']
bbu_pb8 = ['10.108.163.49', 7, 'FACOM']


pb = {
    "10.108.184.73": bbu_pb1,
    "10.106.164.173": bbu_pb2,
    "10.108.184.34": bbu_pb3,
    "10.108.134.118": bbu_pb4,
    "10.108.184.91": bbu_pb5,
    "10.108.184.77": bbu_pb6,
    "10.108.134.119": bbu_pb7,
    "10.69.9.91": bbu_pb8}
gnb_ip = "192.168.255.1"
ap_ip = "192.168.200.1"
user_name = "toor4nsn"
pwd = "oZPS0POrRieRtu"

ute_fsmaccess = ute_fsmaccess()
op = OperatingSystem()


def pdu_outlet_set(host, model, outlet, alia='reboot'):
    ppdu = pdu()
    try:
        ppdu.setup_pdu(model=model, host=host, alias=alia)
        status = ppdu.get_port_status(port=outlet, pdu_device=alia)
        print(status)
        if status == 'on':
            print('power off')
            ppdu.power_off(port=outlet, pdu_device=alia)
            time.sleep(5)
            ppdu.power_on(port=outlet, pdu_device=alia)
        elif status == 'off':
            print('power on')
            ppdu.power_on(port=outlet, pdu_device=alia)
    except BaseException:
        print("[ERR]FACOM power on/off fail")


def wait_after_reset():
    host1 = gnb_ip
    host2 = ap_ip
    reset_finish_flag = False
    for idx in range(20):
        try:
            ute_fsmaccess.wait_until_host_is_available(host1)
            ute_fsmaccess.wait_until_host_is_available(host2)
            print("host is available now")
            reset_finish_flag = True
            break
        except Exception as e:
            time.sleep(15)
            print("wait for host available")
            reset_finish_flag = False
    return reset_finish_flag


def wait_host_unavailable():
    host1 = gnb_ip
    host2 = ap_ip
    hard_reboot_finish_flag = False
    for idx in range(15):
        try:
            ute_fsmaccess.wait_until_host_is_unavailable(host2)
            ute_fsmaccess.wait_until_host_is_unavailable(host1)
            print("host is unavailable")
            break
        except Exception as e:
            time.sleep(1)
            print("wait until host unavailable")
    return hard_reboot_finish_flag


def hard_reboot():
    print('Start to hard reboot...')
    pc_ip = get_bbu_info()
    host_name = socket.gethostname()
    if 'UTE5G' in host_name:
        hn = host_name.replace('-', '_')
        print(hn)
        case_path = [
            'robotws',
            'testsuite',
            'Hangzhou',
            'RRM',
            'RAN_L2_SW_CN_3',
            'resources',
            'sg10',
            'internal_resource',
            'hard_reboot.robot']
        execute_robot_path = os.path.abspath(
            os.path.join(os.getcwd(), ".")).split('robotws')
        execute_robot_path.pop(1)
        l1 = execute_robot_path + case_path
        head = ''
        for path in l1:
            head = os.path.join(head, path)
        command = "robot -V /home/ute/testline_configuration/" + hn + " " + head
        print(command)
        op.run(command)
        reset_flag = wait_host_unavailable()
        reset_finish_flag = wait_after_reset()
        if reset_finish_flag is False:
            op.run(command)
            wait_host_unavailable()
            wait_after_reset()
        time.sleep(60)
    else:
        bbu_pb = pb[pc_ip]
        print(pc_ip)
        print(pb.keys())
        if pc_ip in pb.keys():
            pdu_outlet_set(host=bbu_pb[0], model=bbu_pb[2], outlet=bbu_pb[1])
            reset_finish_flag = wait_after_reset()
            time.sleep(60)
        else:
            raise AssertionError("Onair fail")


def get_bbu_info():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
    finally:
        s.close()
    return ip
