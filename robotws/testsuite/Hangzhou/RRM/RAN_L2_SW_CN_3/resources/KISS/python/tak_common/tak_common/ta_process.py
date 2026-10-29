# -*- coding: utf-8 -*-
"""
:created on: 01-26-2022
:copyright: Nokia
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia-sbell.com
"""
import os
import subprocess
import taf.transport.ssh as csn
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
        self.store.add('noobj', alias=alias)
        ret = self._exe_subprocess(
            "/usr/bin/nohup %s 1>nul 2>&1 0</dev/null & " %
            cmd)
        return self._exe_subprocess(
            "ps -ef | grep %s | grep -v 'grep' | awk '{print $2}'" % self.opt)

    def _remote_process_start(self, cmd, conn_info, alias):

        self.ssh = csn.ssh()
        self.store.add(self.ssh, alias=alias)
        for key, value in conn_info.items():
            if key in ('host', 'ip'):
                host = value
            elif key in ('user', 'username'):
                user = value
            elif key == 'password':
                password = value
        self.store.get(alias).connect_to(
            host,
            user,
            password,
            alias=alias)
        check_process_cmd = "ps -ef | grep %s | grep -v 'grep' | awk '{print $2}'" % self.opt
        ret = self.store.get(alias).execute(check_process_cmd, connection=alias)
        if self.source_path and self.source_path[alias]:
            ret = self.store.get(alias).execute('rm %s*' % self.source_path[alias], connection=alias)
        log.info(
            'before process is "%s", check with %s' %
            (ret, check_process_cmd))
        self.store.get(alias).send_command(
            "/usr/bin/nohup %s 1>nul 2>&1 0</dev/null & " % cmd, connection=alias)
        log.info('start process  %s' % cmd)
        ret = self.store.get(alias).execute(check_process_cmd, connection=alias)
        log.info(
            'after process is "%s, check with %s"' %
            (ret, check_process_cmd))
        return ret

    def nohup_bg_stop_process(self, save_path=None, **kwargs):
        alias = kwargs.get('alias')
        if save_path:
            self.target_path[alias] = os.path.join(
                save_path, "%s.pcap" % alias)
        if self.type[alias] == 'remote':
            self._remote_process_stop(alias)
        else:
            self._local_process_stop(save_path, alias)
        self.store.remove(alias=alias)

    def _local_process_stop(self, save_path, alias):
        for pid in self.process_id[alias]:
            cmd = "sudo kill -INT %s" % pid

            ret = self._exe_subprocess(cmd)
        if save_path:
            self._exe_subprocess(
                'mv %s %s' %
                (self.source_path[alias],
                 self.target_path[alias]))

    def _remote_process_stop(self, alias):
        for pid in self.process_id[alias]:
            cmd = "kill -INT %s" % pid
            log.info('stop process with %s' % cmd)
            self.store.get(alias).execute(cmd, connection=alias)
        if self.target_path:
            src_path = os.path.dirname(self.source_path[alias])
            tgt_path = os.path.dirname(self.target_path[alias])
            if not os.path.exists(tgt_path):
                os.makedirs(tgt_path)
            ret = self.store.get(alias).execute("ls %s |grep %s.pcap" % (src_path, alias), connection=alias)
            log.info(ret)

            try:
                for f in ret.splitlines():
                    self.store.get(alias).download_file(
                        os.path.join(src_path, f),
                        os.path.join(tgt_path, f),
                        connection=alias)
                self.store.get(alias).execute("rm -rf %s/%s.pcap*" % (src_path, alias), connection=alias)
            except Exception as err:
                log.warn(err)
