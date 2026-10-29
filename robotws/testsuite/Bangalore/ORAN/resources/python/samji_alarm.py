import paramiko
import os
import time
import re
import telnetlib
from pathlib import Path
from taf.transport.ssh import ssh


class orualarm:
    def __init__(self):
        self.SSH = ssh()

    def RU_execute(self, host, username, password, oru_ip, oru_username, oru_pwd, cmd_list):
        remote_conn = self.SSH.connect_to(host, username, password, alias='remote')
        print(remote_conn)
        conn = self.SSH.get_connection_by_alias('remote')
        conn.execute("mv /home/inbabtslabuser/.ssh/known_hosts /home/inbabtslabuser/.ssh/known_hosts_bk8")
        oru_conn = conn.invoke_shell()
        oru_conn.send('ssh -o "StrictHostKeyChecking no" '+oru_username+"@"+oru_ip+"\n")
        time.sleep(5)
        print(oru_conn.recv(99999))
        oru_conn.send(oru_pwd+"\n")
        time.sleep(5)
        print(oru_conn.recv(99999))
        for cmd in cmd_list.split(","):
            print("executing command "+cmd)
            time.sleep(1)
            oru_conn.send(cmd+"\n")
            time.sleep(5)
            print(oru_conn.recv(99999))
