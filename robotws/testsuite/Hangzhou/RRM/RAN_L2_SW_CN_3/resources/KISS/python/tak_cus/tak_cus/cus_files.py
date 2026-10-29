# -*- coding: utf-8 -*-
"""
:created on: 06-16-2023
:copyright: Nokia
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia-sbell.com
"""
import os
import re
import time
import subprocess
import glob
import logging


class CusFiles():
    'files handle'

    def __init__(self):
        ''
        pass

    def _exe_subprocess(self, cmd):
        logging.info('\n--> execute "{}"'.format(cmd))
        try:
            ret = subprocess.check_output(cmd, shell=True)
        except Exception as err:
            logging.error(err)
            return
        ret = ret.decode()
        logging.info('<-- return "{}"'.format(ret))
        return ret

    def cus_dump_cells_log(self, save_folder,
                           file_folder="/home/cus/logs/uex/latest/"):
        # cell_logs = glob.glob(file_folder, recursive=True)
        ret = self._exe_subprocess("cd %s;find -name 'cell-*.log'" % file_folder)
        tmp = ret.splitlines()
        cell_logs = []
        for t in tmp:
            cell_logs.append(os.path.join(file_folder, t.strip('./')))

        if not cell_logs:
            raise Exception("Not find any cell log")
        if not os.path.exists(save_folder):
            os.makedirs(save_folder)
        for log in cell_logs:
            name = log.split('latest/')[-1].replace('/', '_')
            self._exe_subprocess("uesim-dump %s > %s/%s" % (log,
                                 save_folder,
                                 name.replace('.log', '_dump.txt')))
