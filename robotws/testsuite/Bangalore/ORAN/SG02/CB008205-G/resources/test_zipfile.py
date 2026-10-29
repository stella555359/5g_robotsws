#!/usr/bin/env python
import os
import zipfile
from pathlib import Path


def file_ex(a, b):
    for path in Path(a).rglob('runtime_DEFAULT.log'):
        print(path.name)
    location = '/home/ute/results/BTS1_2011_part_1.zip/BTS1_2018_runtime.zip/runtime_DEFAULT.log.xz'
    for filename in os.listdir(location):
        if filename == 'runtime_DEFAULT.log':
            f = open(os.path.join(location, 'runtime_DEFAULT.log'), "r")
            return f.read()
# file_ex('/home/ute/results/Snapshot_step1.zip/BTS1_2011_part_1.zip/BTS1_2018_runtime.zip/runtime_DEFAULT.log.xz',
# 'runtime_DEFAULT.log')
