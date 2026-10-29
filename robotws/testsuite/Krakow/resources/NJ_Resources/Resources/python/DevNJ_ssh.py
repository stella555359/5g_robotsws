#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import socket
import paramiko

import logging


logging.basicConfig(level=logging.INFO)


class SshClient(object):
    def __init__(self, host, user, passwd):
        self._connect(host, user, passwd)

    def __del__(self):
        if self.ssh is not None:
            self.ssh.close()

    def _connect(self, ip, user, passwd):
        self.ssh = paramiko.SSHClient()
        try:
            # self.ssh.load_system_host_keys()
            self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            logging.info("{}:{}/{}".format(ip, user, passwd))
            self.ssh.connect(hostname=ip, username=user, password=passwd, timeout=20)
        except paramiko.AuthenticationException:
            self.ssh = None
            raise Exception("SSH Error: Authentication failed!")
        except socket.error:
            self.ssh = None
            raise Exception("SSH Error: Server is unreachable!")

    def run_cmd(self, command):
        logging.info(command)
        return self.ssh.exec_command(command, timeout=300)

    def exist_file(self, file):
        _, _, stderr = self.ssh.exec_command("ls {}".format(file), timeout=60)
        if "No such file" in stderr.read():
            return False

        return True

    def check_file(self, file):
        if not self.exist_file(file):
            return (False, 0)

        sftp = self.ssh.open_sftp()
        info = sftp.stat(file)
        size = info.st_size
        return (True, size)

    def get(self, remote, local, force=False):
        sftp = self.ssh.open_sftp()
        self._get(sftp, remote, local, force)
        sftp.close()

    def get_dir(self, remote_dir, local_dir):
        self._get_files(remote_dir, local_dir)

    def get_files(self, remote_dir, keywords, local_dir):
        self._get_files(remote_dir, local_dir, keywords)

    def put(self, local, remote):
        sftp = self.ssh.open_sftp()
        sftp.put(local, remote)
        sftp.close()

    def _get(self, sftp, remote, local, force=False):
        logging.info("get file from {} to {}.".format(remote, local))

        # remote file size
        info = sftp.stat(remote)
        remote_size = info.st_size

        local_size = 0
        if not force and os.path.exists(local):
            local_size = os.path.getsize(local)
            if remote_size and remote_size == local_size:
                logging.info("file {} exist, no need download again.".format(local))
                return
            else:
                logging.info(
                    "file {} exist, but file size is not correct. retrieve it...".format(
                        local
                    )
                )

        sftp.get(remote, local)

        # check result. it should check MD5, but it no needs for our application.
        local_size = os.path.getsize(local)
        if remote_size != local_size:
            logging.error(
                "Error: the local file {} which size not equal to remote file.".format(
                    local
                )
            )
            sys.exit(1)

        logging.info("get file {} done.".format(local))

    def _get_files(self, remote_dir, local_dir, keywords=None):
        sftp = self.ssh.open_sftp()

        all_files = self.__get_all_files_in_remote_dir(sftp, remote_dir)
        for x in all_files:
            filename = x.split("/")[-1]
            if keywords is not None and keywords not in filename:
                continue

            local_filename = os.path.join(local_dir, filename)
            self._get(sftp, x, local_filename)

        sftp.close()

    def __get_all_files_in_remote_dir(self, sftp, remote_dir):
        all_files = list()

        if remote_dir[-1] == "/":
            remote_dir = remote_dir[0:-1]

        files = sftp.listdir_attr(remote_dir)
        for x in files:
            filename = remote_dir + "/" + x.filename
            if os.path.isdir(filename):
                all_files.extend(self.__get_all_files_in_remote_dir(sftp, filename))
            else:
                all_files.append(filename)
        return all_files
