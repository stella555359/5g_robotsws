# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Zhu Haofeng
:contact: haofeng.zhu@nokia-sbell.com
:maintainer: Zhu Haofeng
:contact: haofeng.zhu@nokia-sbell.com
"""

import time
import logging
from typing import Optional
from taf.internal.aliasing import aliasing_scope
from taf.transport.ssh import ssh


class IpmiCommandExecuteFailed(Exception):
    pass


class ConnectIpmiFailed(Exception):
    pass


class Executor(object):

    def __init__(self, ctrl_pc_ip, ctrl_pc_username, ctrl_pc_password,
                 ipmi_ip, ipmi_username, ipmi_password):
        self._ssh = ssh()
        self._ctrl_pc_ip = ctrl_pc_ip
        self._ctrl_pc_username = ctrl_pc_username
        self._ctrl_pc_password = ctrl_pc_password
        self._ipmi_ip = ipmi_ip
        self._ipmi_username = ipmi_username
        self._ipmi_password = ipmi_password
        self._alias_name = "{}_CTRL_PC".format(self._ctrl_pc_ip)
        self._channel = None

    def connect(self):
        connection = self._ssh.connect_to(self._ctrl_pc_ip, self._ctrl_pc_username, self._ctrl_pc_password,
                                          alias=self._alias_name)
        self._channel = connection.invoke_shell()
        self._connect_to_ipmi(self._ipmi_ip, self._ipmi_username, self._ipmi_password)

    def _connect_to_ipmi(self, ipmi_ip, ipmi_username, ipmi_password):
        self.send_command("ssh {}@{}".format(ipmi_username, ipmi_ip))
        time.sleep(2)
        output = self.read_output()
        if "password:" not in output:
            raise ConnectIpmiFailed(output)
        self.send_command(ipmi_password)
        logging.info("connect to ipmi successfully")

    def send_command(self, command):
        command = "{}\n".format(command)
        self._channel.send("{}\n".format(command))
        time.sleep(1)
        logging.debug("execute {}".format(command))

    def read_output(self):
        output = self._channel.recv(65535)
        logging.debug("read output: {}".format(output))
        return output

    def disconnect(self):
        self._ssh.disconnect(connection=self._alias_name)
        logging.info("disconnect ipmi successfully")


class IpmiCommand(object):

    def __init__(self, executor):
        self._executor = executor

    def connect(self):
        self._executor.connect()

    def disconnect(self):
        self._executor.disconnect()

    def reset(self):
        output = self._execute_command("reset")
        if "reset done" not in output:
            raise IpmiCommandExecuteFailed(output)
        logging.info(output)

    def _execute_command(self, command):
        self._executor.send_command("cd /system1/pwrmgtsvc1")
        self._executor.send_command(command)
        return self._executor.read_output()


class Facade(object):

    def __init__(self):
        self._executor = None

    def setup(self, ctrl_pc_ip, ctrl_pc_username, ctrl_pc_password,
              ipmi_ip="1.1.10.11", ipmi_username="ADMIN", ipmi_password="ADMIN"):
        executor = Executor(ctrl_pc_ip, ctrl_pc_username, ctrl_pc_password,
                            ipmi_ip, ipmi_username, ipmi_password)
        ipmi = IpmiCommand(executor)
        ipmi.connect()
        return ipmi

    def teardown(self, ipmi):
        ipmi.disconnect()

    def reset(self, ipmi):
        ipmi.reset()


class prisma(object):

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    lookup_handler, configured_ipmi = aliasing_scope(lookup_arg='ipmi', lookup_type=IpmiCommand)

    def __init__(self):
        self._facade = Facade()

    def setup(self, ctrl_pc_ip, ctrl_pc_username, ctrl_pc_password,
              ipmi_ip="1.1.10.11", ipmi_username="ADMIN", ipmi_password="ADMIN", alias=None):
        # type: (str, str, str, Optional[str], Optional[str], Optional[str], Optional[str]) -> IpmiCommand
        """
        seup ipmi instance, will connect to ctrl pc and create channel to ipmi
        :param ctrl_pc_ip: prisma ctrl pc ip address
        :param ctrl_pc_username: prisma ctrl pc user name
        :param ctrl_pc_password: prisma ctrl pc password
        :param ipmi_ip: ipmi ip
        :param ipmi_username: ipmi user name
        :param ipmi_password: ipmi password
        :param alias: ipmi alias name
        :return: ipmi instance
        """
        configured_ipmi = self._facade.setup(ctrl_pc_ip, ctrl_pc_username, ctrl_pc_password,
                                             ipmi_ip, ipmi_username, ipmi_password)
        self.configured_ipmi.add(configured_ipmi, alias)
        return configured_ipmi

    @lookup_handler.implicit_lookup
    def teardown(self, ipmi=None):
        # type: (Optional[str]) -> None
        """
        ipmi teardown
        disconnect ssh
        :param ipmi: ipmi alias name
        """
        self._facade.teardown(ipmi)

    @lookup_handler.implicit_lookup
    def reset(self, ipmi=None):
        # type: (Optional[str]) -> None
        """
        reset prisma
        :param ipmi: ipmi alias name
        """
        self._facade.reset(ipmi)
