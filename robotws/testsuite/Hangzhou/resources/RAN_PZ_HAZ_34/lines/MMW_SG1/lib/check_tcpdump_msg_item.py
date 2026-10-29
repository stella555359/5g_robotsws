# -*- coding: utf-8 -*
"""
Author: Wang Yixiang
Contacts: yixiang.x.wang@nokia-sbell.com
Description:
msg_file content should define like following:
sCellToAddModList: 1 item
nr-rrc.c1.*c1: rrcReconfigurationComplete
SgNBAdditionRequest==1
SgNBReconfigurationComplete>=2
SgNBReleaseRequest|SgNBReleaseRequired
SNStatusTransfer>1
!UEContextRelease
"""
import re


def check_msg_item_tcpdump(msg_file, tcpdump_pdml):
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
                pattern = re.compile(item)
                find_ret = pattern.findall(pdml_str)
                if len(find_ret) >= 1:
                    find_flag = find_flag + 1
                    print('MSG:"%s" Verify success!' % item)
            if find_flag == 0:
                raise Exception('MSG:"%s" not found in tcpdump file' % msg_item)
        elif '>' in msg_item:
            msg_item_or_list = msg_item.split('>')
            ret_find_all = re.findall(msg_item_or_list[0], pdml_str)
            occurrence_num = int(msg_item_or_list[1])
            if len(ret_find_all) > occurrence_num:
                print('MSG:"%s" Verify success!' % msg_item)
            else:
                raise Exception('MSG:"%s" verify failed' % msg_item)
        elif '>=' in msg_item:
            msg_item_or_list = msg_item.split('>=')
            ret_find_all = re.findall(msg_item_or_list[0], pdml_str)
            occurrence_num = int(msg_item_or_list[1])
            if len(ret_find_all) >= occurrence_num:
                print('MSG:"%s" Verify success!' % msg_item)
            else:
                raise Exception('MSG:"%s" verify failed' % msg_item)
        elif '<' in msg_item:
            msg_item_or_list = msg_item.split('>')
            ret_find_all = re.findall(msg_item_or_list[0], pdml_str)
            occurrence_num = int(msg_item_or_list[1])
            if len(ret_find_all) > occurrence_num:
                print('MSG:"%s" Verify success!' % msg_item)
            else:
                raise Exception('MSG:"%s" verify failed' % msg_item)
        elif '<=' in msg_item:
            msg_item_or_list = msg_item.split('<=')
            ret_find_all = re.findall(msg_item_or_list[0], pdml_str)
            occurrence_num = int(msg_item_or_list[1])
            if len(ret_find_all) <= occurrence_num:
                print('MSG:"%s" Verify success!' % msg_item)
            else:
                raise Exception('MSG:"%s" verify failed' % msg_item)
        elif '==' in msg_item:
            msg_item_or_list = msg_item.split('==')
            ret_find_all = re.findall(msg_item_or_list[0], pdml_str)
            occurrence_num = int(msg_item_or_list[1])
            if len(ret_find_all) == occurrence_num:
                print('MSG:"%s" Verify success!' % msg_item)
            else:
                raise Exception('MSG:"%s" verify failed' % msg_item)
        else:
            if msg_item.startswith("!"):
                msg_item = msg_item[1:]
                pattern = re.compile(msg_item)
                find_ret = pattern.findall(pdml_str)
                if len(find_ret) >= 1:
                    raise Exception('MSG:"%s" should not found in tcpdump file' % msg_item)
                else:
                    print('MSG:"%s" should not exist in tcpdump file. Verify success!' % msg_item)
            else:
                pattern = re.compile(msg_item)
                find_ret = pattern.findall(pdml_str)
                if len(find_ret) >= 1:
                    print('MSG:"%s", should exist in tcpdump file. Verify success!' % msg_item)
                else:
                    raise Exception('MSG:"%s" not found in tcpdump file' % msg_item)


# if __name__ == '__main__':
#     msg_file = "CA_exist.txt"
#     tcpdump_pdml = "attach_ca.pdml"
#     check_msg_item_tcpdump(msg_file, tcpdump_pdml)
