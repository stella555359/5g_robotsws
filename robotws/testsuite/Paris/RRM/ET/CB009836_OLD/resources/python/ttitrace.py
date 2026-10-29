# -*- coding: utf-8 -*-
"""
:created on: 2025-10-15

:copyright: Nokia
"""

import os
import glob
import logging
import subprocess

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn


def _is_csv_file_exit(output):
    split_path = os.path.split(output)
    base_path, file_name = split_path[0], split_path[1]
    nb_file_csv = len(glob.glob(base_path + "/" + file_name + ".*.csv"))
    logging.info("[INFO] decode_ttitrace generates {} csv files".format(nb_file_csv))
    csv_exist = True if len(glob.glob(base_path + "/" + file_name + ".*.csv")) > 0 else False
    return csv_exist


def _return_nb_csv_files(output):
    split_path = os.path.split(output)
    base_path, file_name = split_path[0], split_path[1]
    nb_file_csv = len(glob.glob(base_path + "/" + file_name + ".*.csv"))
    return nb_file_csv


def add_file_ending_if_missing(file_path, file_ending):
    if file_ending not in file_path:
        file_path += file_ending
    return file_path


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
        cmd2 = "python3 /opt/tti-dec/tti-dec-bin/TtiTraceDecoder.py {} {} -o {}".format(tti_file,
                                                                                        decode_form,
                                                                                        output)
        cmd3 = "deactivate"
        ret = self._execute_command("{};{};{}".format(cmd1, cmd2, cmd3))
        if not _is_csv_file_exit(output):
            logging.info("{};{};{}".format(cmd1, cmd2, cmd3))
            logging.info(ret)
            BuiltIn().log("Decode Result is 'Fail', there is no decode file (*.csv) generated.", level="ERROR",
                          console="yes")
            BuiltIn().log("{};{};{}".format(cmd1, cmd2, cmd3), level="ERROR", console="yes")
            raise Exception("Decode Result is 'Fail', there is no decode file (*.csv) generated.")
        nb_file_csv = _return_nb_csv_files(output)
        return nb_file_csv

    def _create_directory(self, output):
        split_path = os.path.split(output)
        base_path, file_name = split_path[0], split_path[1]
        if not os.path.exists(base_path):
            self._execute_command("mkdir {}".format(base_path))

    def _execute_command(self, cmd):
        ret = subprocess.check_output(cmd, shell=True, executable="/bin/bash")
        return ret.decode()


def decode_ttitrace_file(tti_file, output, decode_form):
    return Ttitrace().decode_ttitrace_file(tti_file, output, decode_form)


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)

    tti_file = '/home/ute/csamson/TRACES/ttitrace_streaming.pcap'
    output = '/home/ute/csamson/TRACES/ttitrace_streaming'
    decode_form = 'legacyCsv'
    nb_file_csv = decode_ttitrace_file(tti_file=tti_file, output=output, decode_form=decode_form)
    print('nb_file_csv={}'.format(nb_file_csv))
