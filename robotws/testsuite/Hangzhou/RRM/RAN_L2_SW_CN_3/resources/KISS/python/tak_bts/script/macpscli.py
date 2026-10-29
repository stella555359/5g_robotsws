#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
:author: Meng Na
:contact: na-sophia.meng@nokia-sbell.com
"""
import os
import sys
import time
import subprocess


TOOL_NAME = "macpscli"
SRC_TOOL_PATH = "/opt/ute/python/lib/python2.7/site-packages/ta_kiss_bts/resources/"


def copy_tool_to_opt_path():
    """copy tool to head file"""
    find_cmd = "find /opt/TtiTracer/ -name PsFeatureLevels.hpp"
    ret = subprocess.Popen(find_cmd, shell=True, bufsize=-1, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE)
    out = ret.stdout.readlines()
    file_path = os.path.dirname(out[0].strip()) if len(out) > 0 else ''
    if file_path == '':
        print("There is no PsFeatureLevels.hpp file exist in /opt/TtiTracer/. This tool can't run.")
        return
    cp_cmd = "cp {}{} {}/".format(SRC_TOOL_PATH, TOOL_NAME, file_path)
    subprocess.Popen(cp_cmd, shell=True, bufsize=-1, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                     stderr=subprocess.PIPE)
    time.sleep(1)
    return os.path.join(file_path, TOOL_NAME)


def change_tool_permission(tool_path):
    """change tool permission"""
    if not os.access(tool_path, os.X_OK):
        os.system("chmod -R 777 {}".format(tool_path))


def main(argument):
    """Logic of the script."""
    try:
        tool_path = copy_tool_to_opt_path()
        change_tool_permission(tool_path)
        parameter = " ".join(argument[i] for i in range(1, len(argument)))
        cmd = "cd {};./{} {}".format(os.path.dirname(tool_path), os.path.basename(tool_path), parameter)
        os.system(cmd)
    except Exception as e:
        pass


if __name__ == '__main__':
    main(sys.argv)
