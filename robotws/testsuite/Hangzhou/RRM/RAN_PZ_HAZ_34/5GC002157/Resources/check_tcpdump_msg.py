# -*- coding: utf-8 -*
"""
Author: Wang Yixiang
Contacts: yixiang.x.wang@nokia-sbell.com
Description:
"""
import re


def check_tcpdump_msg(msg_file, tcpdump_pdml):
    """
    msg_file:
    tcpdump_pdml:
    """
    msg_list = []
    pdml_str = ""

    # read msg list in msg txt file
    with open(msg_file) as f:
        lines = f.readlines()
        for line in lines:
            if line.startswith("#"):
                continue
            line = line.strip("\n\r")
            msg_list.append(line)

    # read all content of pdml
    with open(tcpdump_pdml) as f:
        pdml_str = f.read()

    for msg_item in msg_list:
        if '|' in msg_item:
            msg_item_or_list = msg_item.split('|')
            find_flag = 0
            for item in msg_item_or_list:
                pattern = re.compile(r'showname=".*%s.*"' % item)
                find_ret = pattern.findall(pdml_str)
                if len(find_ret) >= 1:
                    find_flag = find_flag + 1
                    print('MSG:"%s" Verify success!' % item)
            if find_flag == 0:
                raise Exception('MSG:"%s" not found in tcpdump file' % msg_item)
        else:
            pattern = re.compile(r'showname=".*%s.*"' % msg_item)
            find_ret = pattern.findall(pdml_str)
            if len(find_ret) >= 1:
                print('MSG:"%s" Verify success!' % msg_item)
            else:
                raise Exception('MSG:"%s" not found in tcpdump file' % msg_item)


# if __name__ == '__main__':
#     msg_file = "msg_basic_l3_call.txt"
#     tcpdump_pdml = "tcpdump_oam.pdml"
#     check_tcpdump_msg(msg_file, tcpdump_pdml)
