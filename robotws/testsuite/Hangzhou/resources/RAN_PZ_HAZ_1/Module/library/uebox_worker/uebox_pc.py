# -*- coding: utf-8 -*-

"""
:copyright: Nokia
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
:maintainer: fei.ju@nokia-sbell.com
"""

import re
import os
import time
import logging
from xmlrpc import client as xml_client
import paramiko


PCS = {

}


class WinPc(object):

    def __init__(self, hostname: str, username: str, password: str, port: int = 22,
                 logger: object = None) -> None:
        self.hostname = hostname
        self.username = username
        self.password = password
        self.port = port
        self.rdp_session_id = 2
        self.conn = None
        self.rpc = None
        self.logger = logger or logging.getLogger('UEBOX')

    def __repr__(self) -> str:
        return f'CPC({self.hostname}, {self.username}, {self.port})'

    def connect(self) -> None:
        if self.conn is None:
            self.logger.info(f'Connect to WinPC {self.hostname}:{self.port}...')
            self.conn = paramiko.SSHClient()
            self.conn.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.conn.connect(self.hostname, self.port, self.username, self.password)
            self.shell = self.conn.invoke_shell()
            self.trans = paramiko.Transport(sock=(self.hostname, self.port))
            self.trans.connect(username=self.username, password=self.password)
            self.sftp = paramiko.SFTPClient.from_transport(self.trans)
            self.logger.info('Connect OK')
            self.rdp_session_id = self.get_rdp_session()
        return self

    def disconnect(self) -> None:
        if self.conn:
            if self.shell:
                self.shell.close()
            if self.trans:
                self.trans.close()
                self.trans = None
            self.conn.close()
            self.conn = None

    def get_rdp_session(self):
        lines = [x for x in self.execute('query session').splitlines() if x.strip()]
        lines = [x for x in lines if x.strip() and 'RDP-Tcp'.lower() in x.lower()]
        lines = [x for x in lines if self.username.lower().split('\\')[-1] in x.lower()]
        if lines:
            return int(lines[0].split()[2].strip())
        else:
            return 2

    def _smart_decode(self, output1: str, log: bool = True) -> str:
        try:
            output = output1.decode("utf8")
        except Exception:
            try:
                output = output1.decode("gbk")
                if log:
                    self.logger.info(output)
            except Exception:
                self.logger.debug('Try to use iso-8859-1 decode...')
                output = output1.decode("iso-8859-1", "ignore")
        ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
        output = ansi_escape.sub('', output)
        return output

    def execute(self, command: str = '', get_pty: bool = False, log: bool = True) -> str:
        self.connect()
        self.logger.info('    ssh command: --> ' + str(command))
        _, stdout, stderr = self.conn.exec_command(command, get_pty=get_pty)

        while not stdout.channel.exit_status_ready() and not stdout.channel.recv_ready():
            time.sleep(1)
        while not stderr.channel.exit_status_ready() and not stderr.channel.recv_ready():
            time.sleep(1)
        output = self._smart_decode(stdout.read(), log)
        response = output
        if output.strip():
            self.logger.debug('    <-- STDOUT:')
            if log:
                for line in output.splitlines():
                    if line.strip():
                        self.logger.debug(f'    <---- {line}')

        output = self._smart_decode(stderr.read(), log)
        response += '\n{}'.format(output)
        if output.strip():
            self.logger.debug('    <-- STDERR:')
            if log:
                for line in output.splitlines():
                    if line.strip():
                        self.logger.debug(f'    <-- {line}')
        if 'PsExec could not start' in output:
            raise Exception('PSexec execute failed.')
        return response

    def find_process(self, include_keywords: list) -> list:
        result = []
        cmd = 'wmic process get Processid, commandline'
        for keyword in include_keywords:
            cmd += '|find "{}" '.format(keyword)
        cmd += '|findstr -v "find"'
        lines = self.execute(cmd)
        lines = [x.strip() for x in lines.splitlines() if x.strip() if 'wmic' not in x]

        for line in lines:
            processid = line.split()[-1].strip()
            if processid.isdigit():
                result.append(processid)
        return result

    def kill_process_by_keywords(self, include_keywords: list) -> None:
        for processid in self.find_process(include_keywords):
            self.execute('taskkill /T /F /PID {}'.format(processid))

    def exec_psexec(self, cmd: str):
        self.connect()
        cmd = f'psexec -i {self.rdp_session_id} -d -u {self.username} -p {self.password} {cmd}'
        return self.execute(cmd)

    def deploy_rpc(self):
        self.connect()
        self.kill_process_by_keywords(['python', 'comrpc.py'])
        path = os.path.abspath(os.path.expanduser(__file__))
        rpcfile = os.path.join(os.path.dirname(path), 'comrpc.py')
        self.sftp.put(rpcfile, 'c:\\ta\\comrpc.py')
        self.exec_psexec('-s c:\\python38\\python.exe c:\\ta\\comrpc.py')

    def connect_rpc(self):
        if self.rpc is None:
            self.rpc = xml_client.ServerProxy(f'http://{self.hostname}:8001')

    def exec_at_command(self, comport, atcommand, delay=0):
        self.connect_rpc()
        self.logger.info(f'执行 AT 命令： {comport} --> {atcommand}')
        resp = self.rpc.exec_command_on_port(comport, atcommand, delay)
        resp = '/'.join(resp.splitlines())
        self.logger.info(f'返回： [{resp}]')
        return resp

    def port_is_listening(self, port_num: int) -> bool:
        output = self.execute(f'netstat -na|find /I "{port_num}"')
        return 'LISTENING' in output

    def check_firewall_rule(self, rule_name):
        cmd = f'netsh advfirewall firewall show rule name="{rule_name}"'
        output = self.execute(cmd)
        self.logger.info(f'firewall status is {rule_name in output}')
        return rule_name in output

    def auto_enable_firewall(self, port):
        if self.check_firewall_rule(f"tcp_{port}") is False:
            cmd = (f'/s netsh advfirewall firewall add rule name="tcp_{port}"'
                   f' protocol=TCP dir=in localport={port} action=allow')
            self.exec_psexec(cmd)
        if self.check_firewall_rule(f"udp_{port}") is False:
            cmd = (f'/s netsh advfirewall firewall add rule name="udp_{port}"'
                   f' protocol=UDP dir=in localport={port} action=allow')
            self.exec_psexec(cmd)
