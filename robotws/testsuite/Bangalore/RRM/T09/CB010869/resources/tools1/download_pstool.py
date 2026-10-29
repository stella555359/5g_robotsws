#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Wang Xiaoling
:contact: xiaoling.wang@nokia-sbell.com
:maintainer: None
:contact: None
"""

import os
import glob
from robot.libraries.Process import Process

proc_obj = Process()


class DownloadPstools(object):
    """Download pstools files from enb builder site
    """

    def __init__(self):
        """init
        """
        self.pkname = ''
        self.file_name = ''
        self.local_path = ''
        self.file_address = ''
        self.ttitracer_app_lst = []
        self.onlineTtiStream_app_lst = []

    def _set_attr(self, pkname, **kwargs):
        self.file_name = 'pstools.zip'
        should_convert_pkname = "_9999_" in pkname or "_9000_" in pkname or "_9990_" in pkname
        if should_convert_pkname:
            target_name = 'SBTS00' if 'SBTS' in pkname else 'TL00'
            trunk_tag = pkname.split('_')[0]
            pkname = pkname.replace(trunk_tag, target_name)

        self.pkname = pkname
        self.local_path = kwargs.get('local_path', '/opt/TtiTracer/')
        self.file_address = "http://files.ute.nsn-rdnet.net/builds/enb/base/%s/%s" % (self.pkname, self.file_name)
        self.ttitracer_app_lst = ['tti_trace_parser_64', 'tti_trace_parser', 'DevC_tti_trace_parser_64',
                                  'DevC_tti_trace_parser', 'ttiStream', 'sicftp']
        self.onlineTtiStream_app_lst = ['onlineTtiStream_64', 'onlineTtiStream']

    def _remove_local_zip_file(self):
        zip_files = '%s*' % self.file_name
        zip_files_path = os.path.join(self.local_path, zip_files)
        found_zip_file = glob.iglob(zip_files_path)
        for zip_file in found_zip_file:
            os.remove(zip_file)

    def _make_local_dir(self):
        """create local directory
        """
        if not os.path.exists(self.local_path):
            os.makedirs(self.local_path)

    def _execute_cmd(self, cmd):
        result = proc_obj.run_process(cmd, timeout="30", shell="True")
        out = result.stdout + result.stderr
        print("command output is %s" % out)
        return out

    def _chmod2x(self, file_name):
        cmd = 'chmod +x %s' % file_name
        self._execute_cmd(cmd)

    def _get_files(self):
        """wget file from build site.

        :return: the zip file path
        """
        self._make_local_dir()
        self._remove_local_zip_file()
        cmd_ping = "ping -c 1 files.ute.nsn-rdnet.net"
        out = self._execute_cmd(cmd_ping)
        if out.count("100% packet loss"):
            raise Exception("ping files.ute.nsn-rdnet.net failed")
        cmd = 'wget -P %s %s' % (self.local_path, self.file_address)
        out = self._execute_cmd(cmd)
        if out.count("100%") == 0:
            raise Exception("fail to download pstool.zip")
        zip_file_path = os.path.join(self.local_path, self.file_name)
        return zip_file_path

    def _unzip_file(self, zip_file):
        """unzip file

        :param zip_file: zip file name
        :return: the absolute path of tool
        """
        cmd = "unzip -o %s -d %s" % (zip_file, self.local_path)
        self._execute_cmd(cmd)
        os.remove(zip_file)
        pstool_path = os.path.join(self.local_path, 'pstools')
        return pstool_path

    def _chmod2x_files(self, tool_path):
        """change the file attribute to execute.

        :param tool_path: the absolute path of tool
        :return: None
        """
        files = []

        pscli_path = os.path.join(tool_path, 'pscli')
        files.append(
            os.path.join(
                pscli_path,
                'pscli'))

        ttitracer_path = os.path.join(tool_path, 'TtiTracer')
        for ttiapp in self.ttitracer_app_lst:
            files.append(
                os.path.join(
                    ttitracer_path,
                    ttiapp))

        onlineTtiStream_path = os.path.join(ttitracer_path, 'onlineTtiStream')
        for onlineTtiStreamapp in self.onlineTtiStream_app_lst:
            files.append(
                os.path.join(
                    onlineTtiStream_path,
                    onlineTtiStreamapp))

        for file_name in files:
            self._chmod2x(file_name)

    def download_pstools(self, pkname, **kwargs):
        """download pstools from build site

        :param pkname: indicate the package name, it is mandatory paramter.
        :param kwargs: optional paramters, such as 'local_path', default value:/opt/TtiTracer/
        :return: None
        """
        self._set_attr(pkname, **kwargs)
        pstool_zip_file = self._get_files()
        pstool_path = self._unzip_file(pstool_zip_file)
        self._chmod2x_files(pstool_path)
