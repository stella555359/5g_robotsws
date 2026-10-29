# -*- coding: utf-8 -*
"""
Author: Wang Yixiang
Contacts: yixiang.x.wang@nokia-sbell.com
Description:
    https://confluence.int.net.nokia.com/display/5GRANHZ/How+to+check+new+deployment%28L2-HI-DU+and+TRSW+%29+in+1726-H
    asik slave:
    /tmp/node_0xe00a/tmp/FCT-E00A_startup.log
    asik master:
    /tmp/startup_TRSW.log

"""
import logging
import re


def get_l2hi_delopment_core_list(log_path):
    """
    author:Wang Yixiang
    asik slave:
    /tmp/node_0xe00a/tmp/FCT-E00A_startup.log filter string like following to get core list
    ccs_em_rt_dispatcher_affinity_set: ccs_em_rt_dispatcher_affinity_set for EM RT dispatcher 6 to physical core 7
    expected cores:2,3,4,5,6,7
    Also can check by cmd: pstree, check there are 6 dispatchers
    :param log_path:
    :return: core_list
    """
    core_list = []
    with open(log_path) as f:
        lines = f.readlines()
        for line in lines:
            reg = re.search('ccs_em_rt_dispatcher_affinity_set.*Successfully.*physical core\\s+(\\d+)', line)
            if reg:
                core = reg.group(1)
                core_list.append(core)
    return sorted(core_list)


def get_trsw_delopment_core_list(log_path):
    """
    author:Wang Yixiang
    asik master:
    /tmp/startup_TRSW.log filter string like "lcores 0@(7),4,5,6,7" to get core list
    expected cores:4,5,6,7
    :param log_path:
    :return: core_list
    """
    core_list = []
    with open(log_path) as f:
        lines = f.readlines()
        for line in lines:
            reg = re.search(r'lcores.*\),(\d+),(\d+),(\d+),(\d+)', line)
            if reg:
                core1 = reg.group(1)
                core2 = reg.group(2)
                core3 = reg.group(3)
                core4 = reg.group(4)
                core_list.append(core1)
                core_list.append(core2)
                core_list.append(core3)
                core_list.append(core4)
                break
    return sorted(core_list)


# if __name__ == '__main__':
#     print get_l2hi_delopment_core_list(log_path='FCT-E00A_startup.log')
#     print get_trsw_delopment_core_list(log_path='startup_TRSW.log')
