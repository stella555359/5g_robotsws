"""
:copyright: Nokia Networks
:author: SKY&Xie Jia
:contact:sky.mei@nokia-sbell.com
:maintainer: SKY
:contact: sky.mei@nokia-sbell.com
"""
from taf.transport.ssh import ssh
import sys
import os
import re
import ast
import time
import socket

csn = ssh()


def LMI_Enable_SSH(ip, username, password, ru_ip, ru_username, ru_password):
    command = "ping " + ru_ip + " -c 3\n"
    print(command)
    enable = "3 packets transmitted, 3 received"
    status = False
    try:
        pc_conn = csn.connect_to(
            hostname=ip, username=username, password=password, alias="controlPC"
        )
        pc_shell = pc_conn.invoke_shell()
        pc_shell.send("sudo -i\n")
        # while True:
        # output = csn.execute(command=command, connection='controlPC', timeout=120)
        time.sleep(2)
        print(pc_shell.recv(65535))
        pc_shell.send(command)
        time.sleep(10)
        # print(pc_shell.recv(65535))
        output = pc_shell.recv(65535)
        output = output.decode()
        print(output)
        if enable not in output:
            # item_dict = ast.literal_eval(item)
            command1 = "echo '" + ru_username + "' > /dev/ttyUSB0\n"
            command2 = "echo '" + ru_password + "' > /dev/ttyUSB0\n"
            pc_shell.send("stty -F /dev/ttyUSB0 115200 parodd\n")
            time.sleep(2)
            print(pc_shell.recv(65535))
            pc_shell.send(command1)
            time.sleep(2)
            print(pc_shell.recv(65535))
            pc_shell.send(command2)
            time.sleep(2)
            print(pc_shell.recv(65535))
            pc_shell.send('echo "sudo lmi-eth on" > /dev/ttyUSB0\n')
            time.sleep(2)
            print(pc_shell.recv(65535))
            pc_shell.send(command)
            time.sleep(10)
            output = pc_shell.recv(65535)
            output = output.decode()
            print(output)
            if enable in output:
                status = True
        else:
            status = True

    finally:
        csn.disconnect(connection="controlPC")
        return status
