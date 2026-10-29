# -*- coding: utf-8 -*-
"""
Author: Chen Tong
Contacts: tong.chen@nokia-sbell.com
Squard: HGZ SG2

"""
from taf.transport.ssh import ssh
import sys
import os
import re
import ast
import time

csn = ssh()


def enable_ssh_to_ru(ip, username, password, com, ru_ip, ru_info):
    command = "ping " + ru_ip + " -n 3\n"
    print(command)
    enable = "TTL"
    print(ru_info)
    try:
        pc_conn = csn.connect_to(hostname=ip, username=username, password=password, alias='controlPC')
        pc_shell = pc_conn.invoke_shell()
        pc_shell.send('sudo -i\n')
        # while True:
        # output = csn.execute(command=command, connection='controlPC', timeout=120)
        time.sleep(2)
        print(pc_shell.recv(65535))
        pc_shell.send(command)
        time.sleep(20)
        # print(pc_shell.recv(65535))
        output = pc_shell.recv(65535)
        output = output.decode()
        print(output)
        if enable not in output:
            for item in ru_info:
                item_dict = ast.literal_eval(str(item))
                com_path = '/dev/' + com
                command1 = 'stty -F ' + com_path + ' 115200 parodd\n'
                command2 = 'echo "' + item_dict['username'] + '" > ' + com_path + '\n'
                command3 = 'echo "' + item_dict['password'] + '" > ' + com_path + '\n'
                command4 = 'echo "sudo lmi-eth" > ' + com_path + '\n'
                command5 = 'echo "sudo lmi-eth on" > ' + com_path + '\n'
                pc_shell.send(command1)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command2)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command3)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command4)
                time.sleep(2)
                print(pc_shell.recv(65535))
                pc_shell.send(command5)
                time.sleep(2)
                print(pc_shell.recv(65535))
                time.sleep(60)
                pc_shell.send(command)
                time.sleep(20)
                output = pc_shell.recv(65535)
                output = output.decode()
                print(output)
                if enable in output:
                    break
    finally:
        csn.disconnect(connection='controlPC')


def ssh_to_ru(ru_index, ip, username, password, ru_ip, ru_username, ru_password):
    pc_alias = 'PC' + ru_index
    ru_alias = 'RU' + ru_index
    pc_conn = csn.connect_to(hostname=ip, username=username, password=password, alias=pc_alias)
    csn.connect_to(hostname=ru_ip, username=ru_username, password=ru_password, proxy=pc_conn, alias=ru_alias)


if __name__ == "__main__":
    # ip = sys.argv[1]
    # username = sys.argv[2]
    # password = sys.argv[3]
    # ru_ip = sys.argv[4]
    # ru_info = sys.argv[5:]
    ip = "10.71.217.211"
    username = "nokia5G"
    password = "noki@123"
    com = 'ttyS5'
    ru_ip = "192.168.100.1"
    rf_username = 'rfsw'
    rf_password = '5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ='
    ru_info = [{'username': rf_username, 'password': rf_password}]
    print("monitor and download file...")
    enable_ssh_to_ru(ip, username, password, com, ru_ip, ru_info)
