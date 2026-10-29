# -*- coding: UTF-8 -*-

import os
import re


def get_ue_disp(fpath):
    log_path = find_egatelog_path(fpath)
    with open(log_path, 'r') as f:
        content = f.read()
        reg = "enb.*(\\d+).*(?:.|\\n)cell.*(\\d+)"
        value = re.findall(reg, content)
        print (value)
    latest_value = list(value[-1])
    return latest_value[0], latest_value[1]


def find_egatelog_path(fpath):
    log_name = "egate_console.log"
    list_file = os.listdir(fpath)
    for index, dirs in enumerate(list_file):
        if dirs.find(log_name) != -1:
            egate_dir_path = [fpath, dirs]
            egate_path = '/'.join(egate_dir_path)
    print (egate_path)
    return egate_path
