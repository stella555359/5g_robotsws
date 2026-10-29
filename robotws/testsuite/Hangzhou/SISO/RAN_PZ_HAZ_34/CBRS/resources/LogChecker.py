# -*- coding: utf-8 -*-
import os
import re
import json
import types
import sys
import time
import subprocess
import configparser
from io import StringIO


class LogChecker(object):

    def __init__(self, logFile):
        self.LOG_FILE = logFile
        self.fileHandler = None

    def prepare_to_check_message(self, init_pos=0):
        self.fileHandler = open(self.LOG_FILE, 'r')
        if init_pos == 0:
            context = self.fileHandler.read()
            print(context)
            self.fileHandler.seek(0, os.SEEK_END)
        pos = self.fileHandler.tell()
        print("current position: %d" % (pos))

    def find_message(self, messageTag):
        print("messageTag: %s\n" % (messageTag))
        if self.fileHandler is None:
            print("file should be opened by prepare_to_check_message function!!! \n")
            return None
        while True:
            line = self.fileHandler.readline()
            print("Line: %s \n" % line)
            pos = self.fileHandler.tell()
            print("current position: %d" % (pos))
            if not line:
                break
            matchMessageSet = re.findall(messageTag, line)
            if (matchMessageSet):
                print("message: %s\n" % (matchMessageSet[0]))
                return matchMessageSet[0]
            else:
                continue
        return None

    def count_message(self, messageTag):
        print("messageTag: %s\n" % (messageTag))
        i = 0
        if self.fileHandler is None:
            print("file should be opened by prepare_to_check_message function!!! \n")
            return None
        while True:
            line = self.fileHandler.readline()
            print("Line: %s \n" % line)
            if not line:
                break
            matchMessageSet = re.findall(messageTag, line)
            if (matchMessageSet):
                print("message: %s\n" % (matchMessageSet[0]))
                i = i + 1
            else:
                continue
        return i

    def end_to_check(self):
        self.fileHandler.close()
        self.fileHandler = None
