#!/usr/bin/env python
# -*- coding: utf-8 -*-


import logging


class LoggerHandler(object):

    def __init__(self, logger_name, log_file, level):
        logger = logging.getLogger(logger_name)
        formatter = logging.Formatter('%(asctime)s [%(levelname)s] %(message)s', datefmt='%m/%d/%Y %H:%M:%S')
        handler = None
        if log_file is None:
            handler = logging.StreamHandler()
        else:
            handler = logging.FileHandler(log_file)
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        logger.setLevel(level)
        # do NOT pass message to ancestor logger's handler
        logger.propagate = False
        self.logger = logger

    def info(self, msg, *args, **kwargs):
        self.logger.info(msg, *args, **kwargs)

    def debug(self, msg, *args, **kwargs):
        self.logger.debug(msg, *args, **kwargs)

    def warning(self, msg, *args, **kwargs):
        self.logger.warning(msg, *args, **kwargs)

    def error(self, msg, *args, **kwargs):
        self.logger.error(msg, *args, **kwargs)

    def critical(self, msg, *args, **kwargs):
        self.logger.critical(msg, *args, **kwargs)
