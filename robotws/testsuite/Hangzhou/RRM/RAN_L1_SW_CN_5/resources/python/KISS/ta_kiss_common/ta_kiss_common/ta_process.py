# -*- coding: utf-8 -*-
"""
:created on: 01-26-2022
:copyright: Nokia
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia-sbell.com
"""
import os
import time
import subprocess
from SSHLibrary import SSHLibrary
from ute_common_store import Store
import logging as log


class Ta_Process():
    'Ta_Process'

    def __init__(self):
        ''
        self.store = Store()
        self.source_path = {}
        self.target_path = {}
        self.process_id = {}
        self.type = {}

    def _exe_subprocess(self, cmd):
        log.info('\n--> execute "{}"'.format(cmd))
        try:
            ret = subprocess.check_output(cmd, shell=True)
        except Exception as err:
            log.error(err)
            return
        ret = ret.decode()
        log.info('<-- return "{}"'.format(ret))
        return ret

    def nohup_bg_start_process(self, cmd, conn_info=None, **kwargs):
        ''
        alias = kwargs.get('alias')
        options = cmd.split()
        for opt in options:
            if opt.startswith('/'):
                self.source_path[alias] = opt
        if 'sudo' in cmd:
            self.opt = " ".join(options[2:4])
        else:
            self.opt = " ".join(options[1:3])
        if conn_info:
            self.type[alias] = 'remote'
            ret = self._remote_process_start(cmd, conn_info, alias)
        else:
            self.type[alias] = 'local'
            ret = self._local_process_start(cmd, alias)

        if not ret:
            raise Exception(
                'Fail to get process id, please check "%s" by manual in "%s"' %
                (cmd, alias))
        self.process_id[alias] = ret.splitlines()

    def _local_process_start(self, cmd, alias):
        self.store.add(self.ssh, alias=alias)
        ret = self._exe_subprocess(
            "/usr/bin/nohup %s 1>nul 2>&1 0</dev/null & " %
            cmd)

        return self._exe_subprocess(
            "ps -ef | grep %s | grep -v 'grep' | awk '{print $2}'" % self.opt)

    def _remote_process_start(self, cmd, conn_info, alias):

        self.ssh = SSHLibrary()
        self.store.add(self.ssh, alias=alias)

        self.store.get(alias).open_connection(conn_info["host"])
        self.store.get(alias).login(conn_info["user"], conn_info["password"])

        ret = self.store.get(alias).execute_command("ps -ef | grep %s | grep -v 'grep' | awk '{print $2}'" % self.opt,
                                                    return_stdout=True)
        log.info('before process is "%s"' % ret)
        ret = self.store.get(alias).execute_command("/usr/bin/nohup %s 1>nul 2>&1 0</dev/null & " % cmd,
                                                    return_stdout=True, return_rc=True)
        log.info('start process  %s' % cmd)

        # time.sleep(0.5)
        ret = self.store.get(alias).execute_command("ps -ef | grep %s | grep -v 'grep' | awk '{print $2}'" % self.opt,
                                                    return_stdout=True)
        log.info('after process is "%s"' % ret)
        return ret

    def nohup_bg_stop_process(self, save_path=None, **kwargs):
        alias = kwargs.get('alias')
        if save_path:
            self.target_path[alias] = os.path.join(save_path, "%s.pcap" % alias)
        if self.type[alias] == 'remote':
            self._remote_process_stop(alias)
        else:
            self._local_process_stop(alias)
        self.store.remove(alias=alias)

    def _local_process_stop(self, alias):
        for pid in self.process_id[alias]:
            cmd = "sudo kill -INT %s" % pid

            ret = self._exe_subprocess(cmd)
        if self.target_path:
            self._exe_subprocess(
                'cp %s %s' %
                (self.source_path[alias],
                 self.target_path[alias]))

    def _remote_process_stop(self, alias):
        for pid in self.process_id[alias]:
            self.store.get(alias).execute_command('kill -INT %s' % pid)
        if self.target_path:
            try:
                self.store.get(alias).get_file(
                    self.source_path[alias],
                    self.target_path[alias])
            except Exception as err:
                log.warn(err)
