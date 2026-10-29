# -*- encoding: utf-8 -*-
"""
:copyright: Nokia
:author: xxxx
:contact:
"""

import paramiko
import os
import re


def ssh_connect(_host, _username, _password):
    try:
        _ssh_fd = paramiko.SSHClient()
        _ssh_fd.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        _ssh_fd.connect(_host, username=_username, password=_password)
    except Exception as e:
        print('ssh %s@%s: %s' % (_username, _host, e))
        exit()
    return _ssh_fd


def sftp_open(_ssh_fd):
    return _ssh_fd.open_sftp()


def sftp_put(_sftp_fd, _put_from_path, _put_to_path):
    return _sftp_fd.put(_put_from_path, _put_to_path)


def sftp_get(_sftp_fd, _get_from_path, _get_to_path):
    return _sftp_fd.get(_get_from_path, _get_to_path)


def sftp_close(_sftp_fd):
    _sftp_fd.close()


def ssh_close(_ssh_fd):
    _ssh_fd.close()


def exec_cmd(command):
    stdin, stdout, stderr = ssh.exec_command(command)
    err = stderr.readline()
    out = stdout.readline()
    print(out)


def ssh_file(_sftp_fd, remote_dir, Pattern):
    files = _sftp_fd.listdir(remote_dir)
    for f in files:
        rule = re.compile(Pattern)
        if re.findall(rule, f):
            return f
