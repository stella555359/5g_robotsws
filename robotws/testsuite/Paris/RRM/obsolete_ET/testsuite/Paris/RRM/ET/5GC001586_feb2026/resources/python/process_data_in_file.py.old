#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
To facilitate checkpoint verification, you can use this module to process data in different file, including:
json : currently it is used for analyse trace result from DCAP.
csv : currently it is mainly for parse sherpa log.
html: currently it is used for get the mcshark version from its download url
txt:  currently it is used for create personal profile for wireshark.

"""

import string
import os


def write_lines_to_file(file_path, file_name, lines):
    if not os.path.isdir(file_path):
        os.mkdir(file_path)
    file = os.path.join(file_path, file_name)
    line_num = 0
    with open(file, 'w') as f:
        for item in lines:
            f.write(item)
            line_num = line_num + 1
