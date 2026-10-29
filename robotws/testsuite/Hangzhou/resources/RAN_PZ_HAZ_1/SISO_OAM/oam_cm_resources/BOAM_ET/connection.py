# -*- coding: utf-8 -*-
"""
:<Change Log>
:2017-10-27  Xie Yunyi   initial creatation
:2017-11-29  Xie Yunyi   solve the switch connection problem
:2018-03-07  Lin licai   add new function "set_shell_prompt"
:2018-03-13  Lin licai   add new function "execute_command_with_Prompt"
:2018-03-14  Lin licai   add new function "set_shell_timeout"
:
:copyright: Nokia
:author: Xie Yunyi
:contact: yunyi.xie@nokia-sbell.com.cn
"""

import os
import subprocess
import time
from SSHLibrary import SSHLibrary
import warnings
warnings.filterwarnings(action='ignore', module='.*paramiko.*')

ftm_host_ip = '192.168.255.129'
ftm_username = 'toor4nsn'
ftm_password = 'oZPS0POrRieRtu'


class connection(object):

    def __init__(self):
        super(connection, self).__init__()
        self.ssh_client = SSHLibrary()

    def set_shell_timeout(self, newTO='30 seconds'):
        """
         :param String newTO: set timeout for shell command
         :return old timeout
         """
        myTimeout = self.ssh_client.get_connection(timeout=True)
        self.ssh_client.set_client_configuration(timeout=newTO)
        return myTimeout

    def set_shell_prompt(self, newprompt='$'):
        """
         :param String newprompt: set new prompt
         :return old prompt
         """
        myPrompt = self.ssh_client.get_connection(prompt=True)
        self.ssh_client.set_client_configuration(prompt=newprompt)
        return myPrompt

    def execute_command_with_Prompt(self, cmd, alias=None):
        """
         :param String cmd: input the command
         :param String alias: Switch to the existed host by alias
         :return command output.
         """
        if alias:
            self.switch_host(alias)
        self.ssh_client.write(cmd)
        return self.ssh_client.read_until_prompt()

    def connect(self, host='127.0.0.1', username='ute', password='ute', alias='default'):
        """
        Connect to BTS by ssh
        :param String bts_host: hostname or IP address
        :param String username: username for ssh connection
        :param String password: password for ssh connection
        """

        connection_index = self.ssh_client.open_connection(host, alias)
        self.ssh_client.login(username, password)
        return connection_index

    def switch_host(self, alias):
        """
        Switch to the existed host by alias
        :param String alias: alias set when connect
        """
        self.ssh_client.switch_connection(alias)

    def disconnect(self, alias='default'):
        self.switch_host(alias)
        self.ssh_client.close_connection()

    def disconnect_all(self):
        self.ssh_client.close_all_connections()

    def execute_shell_command(self, cmd, alias=None, return_stdout=True, return_stderr=False, return_rc=False):
        """
        Execute command after connected to related NE.
        :param cmd: command to execute
        :param return_stdout: To enable/disable the standard output for the execution result
        :param return_stderr: To enable/disable the error output for the execution result
        :param return_rc: To enable/disable the return code for the execution result
        :return:
        """
        if alias:
            self.switch_host(alias)
        return self.ssh_client.execute_command(cmd, return_stdout, return_stderr, return_rc)

    def get_active_bts_sw_version(self, bts_host=ftm_host_ip):
        """
        Get the active version of target BTS
        :param bts_host:
        :return:
        """
        sw_version = None
        # ssh_bts = SSHLibrary()
        try:
            self.ssh_client.open_connection(bts_host, alias='get_version')
            self.ssh_client.login(ftm_username, ftm_password)
            ret = self.ssh_client.execute_command('cd /rom;ls TargetBD*.xml', True, True)
            for line in ret[0].splitlines():
                if line.startswith("TargetBD_") and line.endswith(".xml"):
                    sw_version = line.split("TargetBD_")[1].split(".xml")[0]
                    break
            return sw_version
        finally:
            self.ssh_client.close_connection()


if __name__ == "__main__":
    con1 = connection()
    local_alias = con1.connect()
    print("1.KW connect() verify result: %s" % local_alias)
    output = con1.execute_shell_command('ls')
    print("2.KW execute_shell_command('ls') verify result: %s" % output)
    bts_alias = con1.connect(ftm_host_ip, ftm_username, ftm_password, 'bts')
    con1.switch_host('bts')
    print("3.KW switch_host('bts') verify result: %s" % bts_alias)
    TO = con1.set_shell_timeout(newTO='20')
    print("4.KW set_shell_timeout(newTO='20') verify result: %s" % TO)
    prompt = con1.set_shell_prompt(newprompt='>')
    print("5.KW set_shell_prompt(newprompt='>') verify result: %s" % prompt)
    output = con1.execute_command_with_Prompt('date', alias=bts_alias)
    print("6.KW execute_command_with_Prompt('date') verify result: %s" % output)
    con1.switch_host(local_alias)
    version = con1.get_active_bts_sw_version('192.168.255.129')
    print("7.KW get_active_bts_sw_version('192.168.255.129') verify result: %s" % version)
    con1.disconnect(alias=bts_alias)
    print("8.KW disconnect(alias=bts_alias) verify result: pass")
    con1.disconnect_all()
