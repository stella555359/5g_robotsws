# -*- coding: utf-8 -*
from robot.libraries.BuiltIn import BuiltIn
import logging
import copy


def Change_TLConfigration_Info(ue_config, UE_call_info):
    copy_ue_config = copy.deepcopy(ue_config)
    copy_ue_config['MultiUECFG']['ue_index_for_call'] = UE_call_info['ue_index_for_call']
    if 'ue_tp' in UE_call_info.keys():
        for ue_index in UE_call_info['ue_tp'].keys():
            if 'ul' in UE_call_info['ue_tp'][ue_index].keys():
                copy_ue_config['MultiUECFG'][ue_index]['ul']['target_throughput'] \
                    = str(UE_call_info['ue_tp'][ue_index]['ul']) + 'MKbits/sec'
            if 'dl' in UE_call_info['ue_tp'][ue_index].keys():
                copy_ue_config['MultiUECFG'][ue_index]['dl']['target_throughput'] \
                    = str(UE_call_info['ue_tp'][ue_index]['dl']) + 'MKbits/sec'
    print(copy_ue_config)
    return copy_ue_config


def Check_Syslog_signaling(check_list, syslog):
    result_list = []
    with open(syslog, 'r') as file:
        syslog_content = file.readlines()
    for i in check_list:
        result = Check_info(info=i, syslog_content=syslog_content)
        if result:
            result_list.append(True)
        else:
            print(" Not Find signaling:{}".format(i))
            result_list.append(False)
    return result_list


def Check_info(info, syslog_content):
    num = 0
    for line in syslog_content:
        num = num + 1
        if info in line:
            print(num)
            return True
    return False


def get_list_index(my_list, value):
    if value in my_list:
        return my_list.index(value)
    else:
        return -1
