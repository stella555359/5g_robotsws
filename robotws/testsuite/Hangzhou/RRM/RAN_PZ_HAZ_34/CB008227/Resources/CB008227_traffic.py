# *-coding=utf-8-*

# Name: Li Xiaodan
# Time: 2023/10/13

import threading
import time
import taf.transport.ssh as ssh
from robot.libraries.BuiltIn import BuiltIn
import re

built_in = BuiltIn()
tl = built_in.get_variable_value("${tl}")
s_n = tl.ues[0].serial_number
appserver = tl.ues[-1].iperf_details.ssh_connection_details.addr


def check_beare_value(file_name):
    value_list = []
    with open(file_name, 'r') as f:
        f = open(file_name, 'r')
        lines = f.readlines()
        for line in lines:
            if 'Mbits/sec' in line:
                line = re.findall("Bytes(.*)Mbits/sec", line, 0)
                line = line[0].strip()
                line = float(line)
                value_list.append(line)
            elif 'Kbits/sec' in line:
                line = re.findall("Bytes(.*)Kbits/sec", line, 0)
                line = line[0].strip()
                line = round((int(line))/10000, 2)
                value_list.append(line)
    average = sum(value_list) / len(value_list)
    return value_list, average


def listen_tput_via_cpc(filename, dl_port, timeout1=30, serial_number=s_n, ue_index=0,
                        iperf_path='/data/local/tmp/', alias='cpc', timeout=60):
    """
    download hanging_resource.exe file from app server to ute of per tl
    para server_ip: iperf server ip
    para server_name: iperf server username
    para server_pwd: iperf server password
    para server_alias: iperf server alias, default value is 'appserver'
    """
    try:
        sshcon = ssh.ssh()
        sshcon.connect_to(hostname=tl.ues[ue_index].ssh_connection_details.addr,
                          username=tl.ues[ue_index].ssh_connection_details.username,
                          password=tl.ues[ue_index].ssh_connection_details.password,
                          alias=alias, timeout=timeout)
    except Exception as e:
        print('{} connection failed, reason: {}'.format(dl_port, e))
    else:
        sshcon.execute(command='rm -rf /tmp/{}'.format(filename + '_' + str(dl_port) + '.txt'), connection=alias)
        time.sleep(2)
        command = 'timeout {} adb -s {} shell {}iperf -s -t 600 -u -p {} -i 1 -w 2M->/tmp/{}'.format(
                timeout1, serial_number, iperf_path, dl_port, filename + '_' + str(dl_port) + '.txt')
        sshcon.send_command(command=command, connection=alias)
        print('send command:{}'.format(command))
        print('{} iperf listened successfully'.format(dl_port))


def listen_tput_via_appserver(filename, ul_port, ue_index=-1, timeout1=30, alias='appserver', timeout=60):
    """
    download hanging_resource.exe file from app server to ute of per tl
    para server_ip: iperf server ip
    para server_name: iperf server username
    para server_pwd: iperf server password
    para server_alias: iperf server alias, default value is 'appserver'
    """
    try:
        sshcon = ssh.ssh()
        sshcon.connect_to(hostname=tl.ues[ue_index].iperf_details.ssh_connection_details.addr,
                          username=tl.ues[ue_index].iperf_details.ssh_connection_details.username,
                          password=tl.ues[ue_index].iperf_details.ssh_connection_details.password,
                          alias=alias, timeout=timeout)
    except Exception as e:
        print('{} connection failed, reason: {}'.format(alias, e))
    else:
        sshcon.execute(command='rm -rf /tmp/{}'.format(filename + '_' + str(ul_port) + '.txt'), connection=alias)
        time.sleep(2)
        command = 'timeout {} iperf -s -t 600 -u -p {} -i 1 -w 2M->/tmp/{}'.format(
            timeout1, ul_port, filename + '_' + str(ul_port) + '.txt')
        sshcon.send_command(command=command, connection=alias)
        print(command)
        print('{} iperf listened successfully'.format(alias))


def connect_cpc(ue_index=0, pc_name='nokia5G', pc_pwd='noki@123', pc_alias='cpc', timeout=60):
    try:
        sshcon = ssh.ssh()
        sshcon.connect_to(hostname=tl.ues[ue_index].ssh_connection_details.addr, username=pc_name, password=pc_pwd,
                          alias=pc_alias, timeout=timeout)
    except Exception as e:
        print('{} connection failed, reason: {}'.format(pc_alias, e))
    return sshcon


def start_traffic_via_appserver(ue_ips, traffic, dl_port, times=600, ue_index=-1, alias='appserver', timeout=60):
    try:
        sshcon = ssh.ssh()
        sshcon.connect_to(hostname=tl.ues[ue_index].iperf_details.ssh_connection_details.addr,
                          username=tl.ues[ue_index].iperf_details.ssh_connection_details.username,
                          password=tl.ues[ue_index].iperf_details.ssh_connection_details.password,
                          alias=alias, timeout=timeout)
    except Exception as e:
        print('{} connection failed, reason: {}'.format(alias, e))
    else:
        print('connect to {}@{}'.format(tl.ues[ue_index].iperf_details.ssh_connection_details.username,
                                        tl.ues[ue_index].iperf_details.ssh_connection_details.addr))
        command = "ps -ef|grep iperf|grep -v grep|grep {}|awk ".format(
            dl_port) + "\'" + '{print $2}' + "\'" + "|xargs kill -9"
        sshcon.execute(command=command, connection=alias)
        time.sleep(2)
        command1 = "iperf -c {} -u -t {} -i 1 -p {} -P 1 -f m -b {} -l 1400 -T 64&".format(
            ue_ips, times, dl_port, traffic)
        print('UE {} send command is {}'.format(ue_ips, command1))
        sshcon.send_command(command=command1, connection=alias)
        time.sleep(2)
        print('UE{} udp dl iperf start'.format(ue_ips))


def start_traffic_via_cpc(serial_number, traffic, ul_port, ue_index=0,
                          appserver=appserver, pc_alias='cpc', timeout=60, times=600):
    try:
        sshcon = ssh.ssh()
        sshcon.connect_to(hostname=tl.ues[ue_index].ssh_connection_details.addr,
                          username=tl.ues[ue_index].ssh_connection_details.username,
                          password=tl.ues[ue_index].ssh_connection_details.password,
                          alias=pc_alias, timeout=timeout)
    except Exception as e:
        print('{} connection failed, reason: {}'.format(pc_alias, e))
    else:
        command = "ps -ef|grep iperf|grep -v grep|grep {}|awk ".format(
            ul_port) + "\'" + '{print $2}' + "\'" + "|xargs kill -9"
        sshcon.execute(command=command, connection=pc_alias)
        time.sleep(2)
        command1 = "adb -s {} shell /data/local/tmp/" \
                   "iperf -c {} -u -p {} -t {} -P 1 -i 1 -f m -b {} -l 1024B -T 64 -w 2M&".format(serial_number,
                                                                                                  appserver, ul_port,
                                                                                                  times, traffic)
        print('UE {} send command is {}'.format(serial_number, command1))
        sshcon.send_command(command=command1, connection=pc_alias)
        time.sleep(2)
        print('appserver {} udp ul iperf start'.format(ul_port))


def operate_all_bearer_of_tput_listen_threading_via_cpc(filename, dl_ports, serial_numbers,
                                                        iperf_path='/data/local/tmp/', timeout1=30, ue_index=0):
    threads = []
    for index in range(len(dl_ports)):
        th = threading.Thread(target=listen_tput_via_cpc, args=(filename, dl_ports[index], timeout1,
                                                                serial_numbers[index], ue_index, iperf_path))
        threads.append(th)
    for t in threads:
        t.start()
    for t in threads:
        t.join()


def operate_all_bearer_of_tput_traffic_threading_via_appserver(ue_ips, dl_ports, traffic, times=600, ue_index=-1):
    threads = []
    for index in range(len(dl_ports)):
        th = threading.Thread(target=start_traffic_via_appserver, args=(ue_ips[index], traffic, dl_ports[index], times,
                                                                        ue_index))
        threads.append(th)
    for t in threads:
        t.start()
    for t in threads:
        t.join()


def operate_all_bearer_of_tput_listen_threading_via_appserver(filename, ul_ports, ue_index=-1, timeout1=30):
    threads = []
    for index in range(len(ul_ports)):
        th = threading.Thread(target=listen_tput_via_appserver, args=(filename, ul_ports[index], ue_index, timeout1))
        threads.append(th)
    for t in threads:
        t.start()
    for t in threads:
        t.join()


def operate_all_bearer_of_tput_traffic_threading_via_cpc(serial_numbers, traffic, ul_ports, ue_index=0):
    threads = []
    for index in range(len(ul_ports)):
        th = threading.Thread(target=start_traffic_via_cpc, args=(serial_numbers[index], traffic,
                                                                  ul_ports[index], ue_index))
        threads.append(th)
    for t in threads:
        t.start()
    for t in threads:
        t.join()
