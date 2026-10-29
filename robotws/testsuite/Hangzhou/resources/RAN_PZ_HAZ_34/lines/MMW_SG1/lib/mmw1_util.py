# -*- coding: utf-8 -*
import os
import re

"""
Author:         Wang Yixiang
Contact Mail:   yixiang.x.wang@nokia-sbell.com
Description:
1. convert rest api parameters to dict
"""


def convert_rest_api_paras_to_dict(dict_ret, rest_api_paras_item):
    """
    example:
    CELL_A2_MEAS_CONFIG_REST_API = [
    dict(dist_name="NRBTS-564/NRCELL-1", parameter='a2MeashoEnabledSA', value='rsrp'),
    dict(dist_name="NRBTS-564/NRCELL-1", parameter='a2MeashoSsbRsrp',
         value=[dict(a2HysteresishoSsbRsrp='0', a2ThresholdhoSsbRsrp='90', a2TimeToTriggerhoSsbRsrp='ms80')]),
    ]

    ==>

    {'a2HysteresishoSsbRsrp': '0', 'a2ThresholdhoSsbRsrp': '90', 'a2MeashoEnabledSA': 'rsrp',
    'a2TimeToTriggerhoSsbRsrp': 'ms80'}
    """

    # for item in rest_api_paras:
    value_type = type(rest_api_paras_item['value'])
    value = rest_api_paras_item['value']
    if value_type == list:
        for sub_item in value:
            dict_ret.update(sub_item)
    else:
        dict_ret[rest_api_paras_item['parameter']] = value
    return dict_ret


def find_all_files(folder, pattern=None, recurse=True, depth=3, search_pattern=None, find_type='file', count=0):
    """
    return a list of files under folder and sub-folders, filename matching given pattern(regex format),
    and file content match search_pattern;
    if recurse is False, do not search subfolders, otherwise search maximum "depth" level of sub-folder.
    depth = -1 means unlimited depth,  depth = 0 is equivalent to recurse=False
    parameter 'folder' can be a single path or multiple paths in a list or tuple.
    parameter 'pattern' can be a single regex pattern or patterns in a list or tuple.
    parameter 'count' count=0 means return all files, count=2 means return only two files
    """
    files = []
    folder_list = folder if type(folder) in (list, tuple) else (folder,)
    pattern_list = pattern if type(pattern) in (list, tuple) else (pattern,)
    for pattern in pattern_list:
        for folder in folder_list:
            for (path, folder_names, file_names) in os.walk(folder):
                next_depth = 1 if path == folder else path[len(folder) + 1:].count(os.sep) + 2
                if find_type == 'folder':
                    file_names[:] = folder_names
                if not recurse or depth != -1 and depth < next_depth:
                    folder_names[:] = []
                for name in file_names:
                    if not pattern or re.search(pattern, name, re.IGNORECASE):
                        find_file = os.path.join(path, name)
                        if search_pattern:
                            with open(find_file, 'r') as rf:
                                if not re.search(search_pattern, rf.read()):
                                    continue
                        files.append(find_file)
                        if count and len(files) >= count:
                            return files
    return files


def delete_unuseful_file_py(file_path, pattern):
    """
    file_path:log path, can be ${TS_CASE_LOG_PATH} or ${SUITE_LOG_PATH}
    pattern:regular expression
    """
    file_list = find_all_files(folder=file_path, pattern=pattern)
    print("Delete files:{}".format(file_list))
    for f in file_list:
        os.remove(f)

# if __name__ == '__main__':
#     file_path = '/opt/ute/results/Case_Logs/5G21A_GNB_0011_000800_001660/TS_5GC00xxxx/TC_[1]Case_name_tempate/'
#     file_list = delete_unuseful_file_py(file_path=file_path,pattern=['scf_\d+.*xml', 'update_\d+.*json', '.*\.pdml'])
#     dict_ret = {}
#     for rest_api_paras_item in CELL_A2_MEAS_CONFIG_REST_API:
#         convert_rest_api_paras_to_dict(dict_ret, rest_api_paras_item)
#     print dict_ret
