# -*- coding: UTF-8 -*-
"""
This module provides utilities for cloud alarm or scfc tree info
:copyright: Nokia Networks
:author: changyan li

"""


def check_alarm_fault_exist(alarm_info_list, fault_id, fault_name=None):
    """
    check alarm fault whether is exist in alarm_info_list
    AUTHOR* changyan.li@nokia-sbell.com
    | Input Parameters | Man. | Description |
    | alarm_info_list | Yes | alarm info list |
    | fault_id | Yes | alarm fault id|
    | fault_name | Yes | alarm fault name |
    *RETURN VALUE*
    True or False . fault id is exist in alarm info list True or False
    """
    if not isinstance(alarm_info_list, list):
        raise Exception('alarm_info_list should be list')
    is_exist = False
    for alarm in alarm_info_list:
        print("alarm=", alarm)
        if alarm["fault_id"] == str(fault_id):
            if fault_name and alarm["fault_name"] == str(fault_name):
                is_exist = True
            if not fault_name:
                is_exist = True
        if is_exist:
            break

    return is_exist


def get_value_from_plan_tree_info(info_list, dist_name, key, parent_mo_uuid=''):
    """
    Get Value From Plan Tree Info
    *AUTHOR* changyan.li@nokia-sbell.com
    | Input Parameters | Man. | Description |
    | dist_name | Yes | Dist Name, like MRBTS-10790/TNLSVC-1/TNL-9 |
    | info_list | Yes | info list get from keyword get_tree_of_current_plan, get_tree_of_delta_plan |
    | key | Yes | what's key you want get from info, like mo_uuid |
    | parent_mo_uuid | No | parent mo uuid, default is EMPTY str |

    *RETURN VALUE*
    value

    Example
    | value | get_value_from_plan_tree_info | tree_info | MRBTS-10790/TNLSVC-1 | mo_uuid |
    """
    dist_name_list = dist_name.split('/')
    print("dist_name_list=", dist_name_list)
    print("info_list type=", type(info_list))
    if len(dist_name_list) > 1:
        for info in info_list:
            if info['parent_mo_uuid'] is None:
                parent_mo_uuid_in_plan = ''
            else:
                parent_mo_uuid_in_plan = info['parent_mo_uuid']
            if info['name'] == dist_name_list[0] and parent_mo_uuid_in_plan == parent_mo_uuid:
                return get_value_from_plan_tree_info(info_list, '/'.join(dist_name_list[1:]), key, info['mo_uuid'])
        else:
            raise Exception('distName %s not exist, please check.' % dist_name_list[0])
    else:
        for info in info_list:
            if info['parent_mo_uuid'] is None:
                parent_mo_uuid_in_plan = ''
            else:
                parent_mo_uuid_in_plan = info['parent_mo_uuid']
            if info['name'] == dist_name_list[0] and parent_mo_uuid_in_plan == parent_mo_uuid:
                return info[key]
        else:
            raise Exception('distName %s not exist, please check.' % dist_name_list[0])
