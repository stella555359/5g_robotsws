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
from taf.converters.eventdecoder import eventdecoder


class Ttitrace(object):
    """Config Gnb to expected status.
    """
    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def is_csv_file_generated(self, output):
        if not self._is_csv_file_exit(output):
            raise Exception("There is no csv file generated.")

    def decode_ttitrace_file_fail(self, tti_file, output, decode_form='excelCsv', excel_csv_options='-w',
                                  conversion_filter=None):
        logging.info("excel_csv_options:{},type:{}".format(excel_csv_options, type(excel_csv_options)))
        decoder_obj = eventdecoder()
        decoder_obj.create_eventdecoder_converter(name='converter', input_file_path=tti_file, output_file_path=output,
                                                  output_file_format=decode_form, excel_csv_options=excel_csv_options,
                                                  conversion_filter=conversion_filter)
        decoder_obj.convert(name='converter')
        if not self._is_csv_file_exit(output):
            raise Exception("Decode result is abnormal.There is no decode file (*.csv) generated.")

    def decode_ttitrace_file_2(self, tti_file, output, decode_form):
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


def decode_ttitrace_file(tti_file, output, decode_form, excel_csv_options, conversion_filter):
    Ttitrace().decode_ttitrace_file(tti_file, output, decode_form, excel_csv_options, conversion_filter)


def is_csv_file_generated(output):
    Ttitrace().is_csv_file_generated(output)
