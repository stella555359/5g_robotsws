# pylint: skip-file
# -*- coding: utf-8 -*-
"""
:created on: 04-22-2021

:copyright: Nokia
:author: Chen jin Emily
:contact: jin_emily.chen@nokia-sbell.com.cn
"""

import os
import time
import logging
from functools import partial
from .xml_files import IphyXmlFileModify
from .ta_parallel import Ta_Parallel
from .paramter_parser import Parameter_Parser
from .ta_process import Ta_Process
from .kill_syslog import KillSyslog
from ta_kiss_core.sshconnection.sshconnection import SshConnection


class InterfaceBase(object):
    """
    InterfaceBase
    """

    def __init__(self):
        """init
        """
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)

    def _execute_command_by_ssh(self, command, host_ip):
        """
        """
        ssh_client = SshConnection(host_ip, 'ute', 'ute')
        try:
            ssh_client._setup()
            self._log.info("execute command:{}".format(command))
            ret = ssh_client.execute(command)
            self._log.debug(ret)
        except Exception as e:
            self._log.warning("exception happened! {}$$$.".format(e))
            raise Exception("{} execute fail!Detail is {}".format(command, str(e)))
        finally:
            ssh_client._teardown()
            return ret

    def _stop_running_process(self, host_ip='127.0.0.1', **kwargs):
        """
        stop running process:
        'btslog', 'IMViewer', 'IMCommander', 'cli_server_aatrace.py', 'fsyslog', 'com.nokia.em.sitemgr.SitemgrStarter',
        'com.nokia.em.poseidon.PoseidonStarter', 'ute_common_admin/resource/node/linux/bin/node'.
        """
        proc_list = kwargs.get('proc_list', ['btslog', 'IMViewer', 'IMCommander', 'cli_server_aatrace.py', 'fsyslog',
                                             'com.nokia.em.sitemgr.SitemgrStarter',
                                             'com.nokia.em.poseidon.PoseidonStarter',
                                             'ute_common_admin/resource/node/linux/bin/node'])
        self._log.info("try to stop processes: %s" % proc_list)
        for proc in proc_list:
            dfOutput = self._execute_command_by_ssh("timeout 2 ps -ef|grep %s|grep -v grep" % proc, host_ip)
            self._log.debug("before stop, check [%s] process:\n%s" % (proc, dfOutput))
            cmd = "timeout 5 sudo kill -9 $(ps -ef|grep %s|grep -v grep|awk '{print $2}') 1>/dev/null 2>&1" % proc
            self._execute_command_by_ssh(cmd, host_ip)
            dfOutput, stderr, returncode = self._execute_command_by_ssh("timeout 2 ps -ef|grep %s|grep -v grep" % proc,
                                                                        host_ip)
            self._log.debug("after stop, check process:\n%s" % dfOutput)

    def clean_up_env(self, host_ip='127.0.0.1'):
        """
        clean up env, including stop running process
        :param host_ip: '127.0.0.1' for local control pc, other ip for other control pc
        :return:
        """
        self._stop_running_process(host_ip)


class tak_common(InterfaceBase, Ta_Parallel, IphyXmlFileModify, Parameter_Parser, Ta_Process, KillSyslog):
    """ common operation such as clean up env, modify files
    """

    def __init__(self):
        """init
        """
        InterfaceBase.__init__(self)
        IphyXmlFileModify.__init__(self)
        Ta_Parallel.__init__(self)
        Parameter_Parser.__init__(self)
        Ta_Process.__init__(self)
        KillSyslog.__init__(self)
