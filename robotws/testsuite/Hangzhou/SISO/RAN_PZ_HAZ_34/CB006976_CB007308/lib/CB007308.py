import re
import os
import time


def get_part_id(snapshotfile):
    with open(snapshotfile, 'r') as f:
        cont = True
        part = ''
        li1 = []
        li2 = []
        while cont:
            cont = f.readline()
            li1.append(cont)
            if cont == '\n':
                li2.append(li1)
                li1 = []
    for item in reversed(li2):
        for i in item:
            if 'RD.BTS' in i:
                part = item[0]
                break
            else:
                continue
        if part != '':
            break
    part = re.match(r'(.*):', part).group(1)
    return part


def checkflag(rmod, smod, newvalue):
    flag = 0
    if rmod == newvalue and smod == newvalue:
        flag = 1
    return flag


def check_label_info(str1):
    symbol = 0
    if 'RF' in str1:
        symbol = 1
    return symbol


def get_sfp_info(portlist):
    sfplist = []
    for port in portlist:
        if 'RF' in port:
            sfpinfo = port.replace('RF', 'SFP-', 1)
            sfplist.append(sfpinfo)
        else:
            continue
    return sfplist


def check_sfp(sfp_wr, modinfo):
    if 'RMOD' in modinfo:
        sfp_wr = sfp_wr + '/LANE-1'
    return sfp_wr


def check_version(version):
    flag = 0
    list1 = version.split("S")
    list2 = list1[2].split('R')
    if int(list2[0]) > 22:
        flag = 1
    else:
        if int(list2[1]) > 2:
            flag = 1
    return flag


def check_value_info(value_list):
    info = 0
    for i in value_list:
        if i == '1':
            info = 1
            break
        else:
            continue
    return info


def check_len_info(len_list):
    len_check = 1
    for i in len_list:
        if i == 0:
            len_check = 0
            break
    return len_check
