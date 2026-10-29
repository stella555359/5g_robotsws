import json
import re


def get_origin_ver(sw_info):
    sw_def = json.loads(sw_info)
    return sw_def['value0']['value2']


def def_illegal_ver(origin_ver):
    last_num = re.findall("\\d", origin_ver)
    index = origin_ver.rfind(last_num[-1])
    illegal_set = abs(int(last_num[-1])-1)
    illegal = origin_ver[0:index] + str(illegal_set)
    if index < len(origin_ver) - 1:
        illegal += origin_ver[index+1:]
    return illegal


def get_active_number(active_info):
    files = active_info.split("File[")
    for info in files:
        if info.count("it's active") > 0:
            return int(info[0]) - 1


def ru_list_to_str(ru_list):
    ru_no_dup_list = list(set(ru_list))
    ru_no_dup_list.sort(key=ru_list.index)
    return ru_no_dup_list
