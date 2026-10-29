# -*- coding: utf-8 -*-
# pylint: disable=no-name-in-module
"""
:created on: 03-30-2021

:copyright: Nokia
:author: Chen jin Emily
:contact: jin_emily.chen@nokia-sbell.com.cn
"""

import logging
import os
import re
import ftplib
import shutil
import pysftp
import platform
import subprocess
if platform.python_version().startswith('3'):
    subprocess.call(['pip', 'install', '-U', 'numpy', 'robotframework-ftplibrary'])
    from FtpLibrary import FtpLibrary
else:
    subprocess.call(['pip', 'install', '-U', 'numpy', 'robotframework-ftplibrary'])
    import FtpLibrary


class FtpHandler(object):
    """ftp download and upload
    """
    def __init__(self):
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)
        self._host = None
        self._port = None
        if platform.python_version().startswith('3'):
            self.FtpLibrary = FtpLibrary()
        else:
            self.FtpLibrary = FtpLibrary

    def connect_ftp(self, host, port, usr, pwd, **kwargs):
        """connect ftp
        """
        self._host = host
        self._port = port
        self.FtpLibrary.ftp_connect(self._host, usr, pwd, self._port)

    def close_ftp(self, **kwargs):
        """ftp close
        """
        self.FtpLibrary.ftp_close()

    def ftp_download(self, remote, local, **kwargs):
        """ftp download
        """
        if '*.*' in remote:
            file_list = []
            remote_folder = remote.strip('*.*')
            self.FtpLibrary.cwd(remote_folder)
            for f in self.FtpLibrary.dir():
                if not f.startswith('d'):
                    file_list.append(self._ftp_download_one_file(f.split()[-1], '%s/' % local))
            return file_list
        else:
            return self._ftp_download_one_file(remote, local)

    def _ftp_download_one_file(self, remote, local):
        if local is not None and os.path.split(local)[0] != '':
            if os.path.exists(os.path.split(local)[0]) is False:
                os.makedirs(os.path.split(local)[0])
            if os.path.split(local)[1] == '':
                local = local + '/' + os.path.split(remote)[1]
        elif local is not None and os.path.split(local)[0] == '':
            local = os.getcwd() + '/' + local
        else:
            local = os.getcwd() + '/' + os.path.split(remote)[1]
        self.FtpLibrary.download_file(remote, local)
        return local

    def ftp_download_latest_file(self, host, port, usr, pwd, remote, local, filter_file, **kwargs):
        """ftp download
        """
        ftp = ftplib.FTP()
        try:
            ftp.connect(host, int(port))
            self._log.info("ftp connect to %s:%s" % (host, port))
        except Exception as err:
            raise Exception("ftp connect to %s:%s failed for %s" % (host, port, err))
        try:
            ftp.login(usr, pwd)
            self._log.info("ftp login %s/%s" % (usr, pwd))
        except Exception as err:
            raise Exception("ftp login %s:%s with %s/%s failed for %s" % (host, port, usr, pwd, err))

        self._log.info(ftp.getwelcome())
        ftp.cwd(remote)
        self._log.info("cd to %s" % remote)

        data = []
        ftp.retrlines('MLSD', data.append)
        self._log.info(data)
        latest_file_name = self._parse_latest_file(data, filter_file)

        file_handle = open(os.path.join(local, latest_file_name), "wb").write
        ftp.retrbinary("RETR %s" % latest_file_name, file_handle)
        ftp.set_debuglevel(0)
        ftp.close()

    def _parse_latest_file(self, data, filter_file):
        result_list = []
        for d in data:
            result_dict = {}
            content = d.split(';')
            for c in content:
                if c.startswith('type'):
                    result_dict['type'] = c.split('=')[-1]
                elif c.startswith('modify'):
                    result_dict['modify'] = c.split('=')[-1]
                elif c.startswith('size'):
                    result_dict['size'] = c.split('=')[-1]
                else:
                    result_dict['name'] = c.strip()
            result_list.append(result_dict)
        sort_list = sorted(result_list, key=lambda obj: obj["modify"], reverse=True)
        latest_file_name = ""
        for s in sort_list:
            if s['type'] == 'file' and re.search(filter_file, s['name']):
                latest_file_name = s['name']
                break
        if not latest_file_name:
            raise Exception("Not find the filter file '%s'" % filter_file)
        self._log.info("latest file is %s" % latest_file_name)
        return latest_file_name

    def ftp_upload(self, local, remote, **kwargs):
        """ftp upload
        """
        current_dir = self.FtpLibrary.pwd()
        if remote is not None and os.path.split(remote)[0] != '':
            try:
                self.FtpLibrary.cwd(os.path.split(remote)[0])
            except (IOError, OSError):
                self.FtpLibrary.mkd(os.path.split(remote)[0])
                self._log.info('make dir; %s', os.path.split(remote)[0])
        elif remote is not None and os.path.split(remote)[0] == '':
            remote = current_dir + '/' + remote
        else:
            remote = current_dir

        if os.path.split(remote)[1] == '':
            remote = remote + '/' + os.path.split(local)[1]

        self.FtpLibrary.cwd(current_dir)
        local = os.path.normpath(local)
        remote = os.path.normpath(remote)
        self.FtpLibrary.upload_file(local, remote)


class SFtpHandler(object):
    """sftp download and upload
    """
    def __init__(self):
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)
        self.sftp = None

    def sftp_download(self, host, port, usr, pwd, remote, local=None, **kwargs):
        """sftp download
        """
        if local is not None and os.path.split(local)[0] != '':
            if os.path.exists(os.path.split(local)[0]) is False:
                os.makedirs(os.path.split(local)[0])
            if os.path.split(local)[1] == '':
                local = local + '/' + os.path.split(remote)[1]
        elif local is not None and os.path.split(local)[0] == '':
            local = os.getcwd() + '/' + local
        else:
            local = os.getcwd() + '/' + os.path.split(remote)[1]

        local = os.path.normpath(local)

        try:
            cnopts = pysftp.CnOpts()
            cnopts.hostkeys = None
            pysftp_con = pysftp.Connection(host, username=usr, password=pwd, port=int(port), cnopts=cnopts)
        except Exception as err:
            pysftp_con = pysftp.Connection(host, username=usr, password=pwd, port=int(port))
        with pysftp_con as sftp:
            if os.path.split(remote)[1] != '':
                sftp.get(remote, local)
                ret = local
            else:
                localpath = os.path.join(local, remote.split('/')[-2])
                if os.path.isdir(localpath) is True:
                    shutil.rmtree(localpath)
                sftp.get_r(remote, local)
                ret = None
            sftp.close()
            return ret

    def mtime(self, filename):
        """return the creation time of the file
        """
        return self.sftp.stat(filename).st_mtime

    def sftp_download_latest_file(self, host, port, usr, pwd, remote, local=None, **kwargs):
        """sftp download the latest file with the same file name but different time stamps
        """
        filefilter = kwargs.get('filter')
        try:
            cnopts = pysftp.CnOpts()
            cnopts.hostkeys = None
            pysftp_con = pysftp.Connection(host, username=usr, password=pwd, port=int(port), cnopts=cnopts)
        except Exception as err:
            pysftp_con = pysftp.Connection(host, username=usr, password=pwd, port=int(port))
        with pysftp_con as self.sftp:
            try:
                self.sftp.chdir(remote)
                self._log.debug('sftp walking to %s', remote)
            except (IOError, OSError):
                self._log.debug("sftp cd to dir '%s' failed!", remote)

            sftp_curr_dir = self.sftp.getcwd()
            files = self.sftp.listdir(sftp_curr_dir)
            statfiles = list("%s/%s" % (sftp_curr_dir, fname) for fname in files if re.search(filefilter, fname))
            sorted_statfiles = list(sorted([fname for fname in statfiles], key=self.mtime))
            try:
                target_file = sorted_statfiles[-1]
            except Exception as err:
                self._log.debug("'%s' not found!", filefilter)

            if local is None:
                local = os.getcwd()
            if '.' not in os.path.basename(local):
                local = os.path.join(local, target_file.split('/')[-1])
            if os.path.exists(os.path.split(local)[0]) is False:
                os.makedirs(os.path.split(local)[0])

            self.sftp.get(target_file, local)
            self.sftp.close()

    def sftp_upload(self, host, port, usr, pwd, local, remote=None, **kwargs):
        """sftp upload
        """
        try:
            cnopts = pysftp.CnOpts()
            cnopts.hostkeys = None
            pysftp_con = pysftp.Connection(host, username=usr, password=pwd, port=int(port), cnopts=cnopts)
        except Exception as err:
            pysftp_con = pysftp.Connection(host, username=usr, password=pwd, port=int(port))
        with pysftp_con as sftp:
            current_path = ['', sftp.getcwd()][sftp.getcwd() is not None]
            if remote is not None and os.path.split(remote)[0] != '':
                if sftp.exists(os.path.split(remote)[0]) is not True:
                    sftp.makedirs(os.path.split(remote)[0])
                    self._log.info('make dir; %s', os.path.split(remote)[0])
            elif remote is not None and os.path.split(remote)[0] == '':
                remote = current_path + '/' + remote
            else:
                remote = current_path + '/' + os.path.split(local)[1]

            if remote is not None and os.path.split(remote)[1] == '':
                remote = remote + '/' + os.path.split(local)[1]

            local = os.path.normpath(local)
            remote = os.path.normpath(remote)

            sftp.put(local, remote)
            sftp.close()


if __name__ == '__main__':
    pass
