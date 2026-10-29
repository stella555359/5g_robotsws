# -*- coding: utf-8 -*
"""
Author: Wang Yixiang
Contacts: yixiang.x.wang@nokia-sbell.com
Description:
"""
import re


def get_time_relative_item(tcpdump_pdml):
    """
    msg_file:
    tcpdump_pdml:
    """
    msg_list = []
    # read msg list in msg txt file
    with open(tcpdump_pdml) as f:
        lines = f.readlines()
        for line in lines:
            ret = re.search(r'frame\.time_relative.*show="(\d+\.\d+)"', line)
            if ret:
                time_item = ret.group(1)
                msg_list.append(time_item)
    return msg_list


# if __name__ == '__main__':
#     tcpdump_pdml = "/opt/ute/results/loner_561_A_02.pdml"
#     ret = get_time_relative_item(tcpdump_pdml)
#     print ret
