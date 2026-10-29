# -*- coding: utf-8 -*-
"""
:created on: 2020-08-11

:copyright: Nokia
:author: Yao Yonna
:contact: yonna.yao@nokia-sbell.com
"""

import os
import glob
import logging
import subprocess


class Ttitrace(object):
    """Config Gnb to expected status.
    """
    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        """"""
        pass

    def decode_ttitrace_file(self, tti_file, output, decode_form):
        self._create_directory(output)
        cmd1 = "source /opt/tti-dec/venv/bin/activate"
        cmd2 = "python3 /opt/tti-dec/tti-dec-bin/TtiTraceDecoder.py {} {} -o {}".format(tti_file, decode_form, output)
        cmd3 = "deactivate"
        ret = self._execute_command("{};{};{}".format(cmd1, cmd2, cmd3))
        if not self._is_csv_file_exit(output):
            logging.info("{};{};{}".format(cmd1, cmd2, cmd3))
            logging.info(ret)
            raise Exception("Decode Result is 'Fail', there is no decode file (*.csv) generated.")

    def _create_directory(self, output):
        split_path = os.path.split(output)
        base_path, tag = split_path[0], split_path[1]
        if tag == '':
            raise Exception("Tag is needed, please set 'output_path_with_tag' like /home/tti_decode_path/mytag")
        if not os.path.exists(base_path):
            self._execute_command("mkdir {}".format(base_path))

    def _is_csv_file_exit(self, output):
        split_path = os.path.split(output)
        base_path, tag = split_path[0], split_path[1]
        csv_exist = True if len(glob.glob(base_path + "/" + tag + "_*.csv")) > 0 else False
        return csv_exist

    def _execute_command(self, cmd):
        ret = subprocess.check_output(cmd, shell=True, executable="/bin/bash")
        return ret.decode()


def decode_ttitrace_file(tti_file, output, decode_form):
    Ttitrace().decode_ttitrace_file(tti_file, output, decode_form)
