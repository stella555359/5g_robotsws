# -*- coding: utf-8 -*-
"""
:created on: 15-04-2017

:copyright: Nokia
:author: Lily Xu
:contact: lily.l.xu@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""

import logging
import subprocess
import os
import re
from SSHLibrary import SSHClient
from robot.libraries.Remote import Remote
from functools import partial


class ObjectDict(dict):
    """A dictionary that allows attribute-based access (dictionary.key instead
    of dictionary['key']).
    """

    def __getattr__(self, attr):
        value = self[attr]
        return ObjectDict(value) if isinstance(value, dict) else value

    def __setattr__(self, name, value):
        self[name] = value

    def __delattr__(self, name):
        del self[name]


class RemoteLib(object):
    """basic remote lib"""
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self, uri, timeout=None):
        self.__uri = uri
        self._remote = Remote(uri, timeout=timeout)

    def _run_keyword(self, _kw_name, *_args, **_kwargs):
        result = self._remote.run_keyword(_kw_name, _args, _kwargs)
        return ObjectDict(result) if isinstance(result, dict) else result

    def __getattr__(self, name):
        if name not in self._remote.get_keyword_names():
            raise AttributeError("No keyword '%s' in remote lib." % name)
        return partial(self._run_keyword, name)

    def __str__(self):
        return "RemoteLibInstance: %s" % self.__uri


class SshExecutor(object):

    def __init__(self, host_ip, user, pwd, prompt="$"):
        self.host_ip = host_ip
        self.user = user
        self.pwd = pwd
        self.ssh = SSHClient(host=self.host_ip, prompt=prompt, timeout=15, port=22)
        self.ssh.login(self.user, self.pwd)

    def exec_cmd(self, cmd, start_or_execute):
        if 'start_cmd' == start_or_execute:
            self.ssh.start_command(cmd)
        else:
            out, err, rc = self.ssh.execute_command(cmd)
            return out

    def get_file(self, remote, local):
        self.ssh.sftp_client.get_file(remote, local, False)

    def put_file(self, local, remote):
        self.ssh.put_file(local, remote)

    def close_connection(self):
        self.ssh.close()
