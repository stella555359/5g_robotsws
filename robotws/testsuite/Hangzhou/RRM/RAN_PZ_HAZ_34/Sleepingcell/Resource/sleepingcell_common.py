# -*- coding: utf-8 -*-
"""
Author:         zhang shanshan
Contact Mail:   shanshan.zhang@nokia-sbell.com
Description:    get snapshot name from path

"""
import os


def get_snapshot_filename(filepath):
    file_name = []
    return_snapshot_name = []
    for i in os.listdir(filepath):
        data_collect = ''.join(i)
        file_name.append(data_collect)
        if 'snapshot-' in data_collect:
            return_snapshot_name.append(data_collect)
    return return_snapshot_name
