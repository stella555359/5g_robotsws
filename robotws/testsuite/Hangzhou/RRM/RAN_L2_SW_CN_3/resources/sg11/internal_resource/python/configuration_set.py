# -*- coding: utf-8 -*-
"""
:created on: 2021-06-07

:copyright: Nokia
:author: Wen chao Zhang
:contact: wenchao.zhang@nokia-sbell.com
this function is private, only use to SG11 testing.
if you need it, please contact leo.y.wang@nokia-sbell.com, he will provide public keyword like this.
"""

import os
import fnmatch


def _walk_dir(directory, ext='*.*', topdown=True):
    file_array = []
    for root, dirs, files in os.walk(directory, topdown):
        for name in files:
            if fnmatch.fnmatch(name, ext):
                file_array.append(os.path.abspath(os.path.join(root, name)))
    return file_array
