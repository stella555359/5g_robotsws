# -*- coding: utf-8 -*-
"""
2022/05/22 first version by @author: xiang.5.li@nokia-sbell.com
2023/04/12 fix case when path="", by Ye Sheng
"""
import logging
import time
import os


class LoggingEt(object):
    """repack logging"""
    def __init__(self, path=None, logger="Log", debug_flag="off"):
        self.logger = logging.getLogger(logger)
        self.logger.setLevel(logging.DEBUG)
        self.log_time = time.strftime("%Y_%m_%d_")
        self.path = path or os.path.abspath(os.path.dirname(__file__))
        self.log_path = os.path.join(self.path, "log")
        self.creat_log_folder()
        self.log_name = self.log_path + os.sep + self.log_time + '_5g_log.log'
        self.fh, self.ch = None, None
        self.debug_flag = logging.INFO if debug_flag == "off" else logging.DEBUG

        # judge the current handler has logger.handlers or not, if not create
        if not self.logger.handlers:
            # fh = logging.FileHandler(self.log_name, 'a')   # python2
            self.fh = logging.FileHandler(self.log_name, 'a', encoding='utf-8')  # python3
            self.fh.setLevel(logging.DEBUG)

            # handler for output to control panel
            self.ch = logging.StreamHandler()
            self.ch.setLevel(self.debug_flag)

            # define handler output format
            formatter = logging.Formatter(
                '[%(asctime)s.%(msecs)03d] %(filename)s->%(funcName)s line:%(lineno)d [%(levelname)s]: %(message)s',
                datefmt="%m-%d %T")

            self.fh.setFormatter(formatter)
            self.ch.setFormatter(formatter)

            self.logger.addHandler(self.fh)
            self.logger.addHandler(self.ch)

            # fh.close()
            # ch.close()

    def log(self):
        return self.logger

    def creat_log_folder(self):
        if os.path.exists(self.log_path):
            return
        else:
            os.makedirs(self.log_path)
