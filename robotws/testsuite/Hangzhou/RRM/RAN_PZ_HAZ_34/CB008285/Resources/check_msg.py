# -*- coding: utf-8 -*
"""
Author: Wang Yixiang
Contacts: yixiang.x.wang@nokia-sbell.com
Description:
"""
import re


def check_emil_msg(msg_file, emil_file):
    """
    msg_file:
    emil_file:
    """
    msg_list = []
    emil_str = ""

    # read msg list in msg txt file
    with open(msg_file) as f:
        lines = f.readlines()
        for line in lines:
            if line.startswith("#"):
                continue
            line = line.strip("\n\r")
            msg_list.append(line)

    # read all content of pdml
    with open(emil_file) as f:
        emil_str = f.read()

    for msg_item in msg_list:
        if '|' in msg_item:
            msg_item_or_list = msg_item.split('|')
            find_flag = 0
            for item in msg_item_or_list:
                pattern = re.compile(r'.*%s.*' % item)
                find_ret = pattern.findall(emil_str)
                if len(find_ret) >= 1:
                    find_flag = find_flag + 1
                    print('MSG:"%s" Verify success!' % item)
            if find_flag == 0:
                raise Exception('MSG:"%s" not found in tcpdump file' % msg_item)
        else:
            pattern = re.compile(r'.*%s.*' % msg_item)
            find_ret = pattern.findall(emil_str)
            if len(find_ret) >= 1:
                print('MSG:"%s" Verify success!' % msg_item)
            else:
                raise Exception('MSG:"%s" not found in emil file' % msg_item)


# if __name__ == '__main__':
#     msg_file = "f1_msg.txt"
#     emil_file = "Emil_20201218_1048.txt"
#     check_emil_msg(msg_file, emil_file)
