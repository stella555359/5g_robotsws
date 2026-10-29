# -*- coding: utf-8 -*
"""
Author: Bi jiajian
Contacts: jiajian.bi@nokia-sbell.com
Description: some py script by SG2
"""

import re
import socket
import json
import openpyxl
import random
import time
import csv


# FOR KPI KEYWORD
def put_value_to_xlsx(values):
    wb = openpyxl.load_workbook("/home/ute/Downloads/KPI.xlsx")
    print("excel path: /home/ute/Downloads/KPI.xlsx")
    sheet = wb["KPI"]
    sheet.append(values)
    wb.save("/home/ute/Downloads/KPI.xlsx")


# get MRBTSID NRBTSID NRCELLID from scf
def get_mrbtsid_from_scf(file_path):
    p = re.compile(r'MRBTS-(\d*)/NRBTS-(\d*)/NRCELL-(\d*)')
    f = open(file_path)
    tex = f.read()
    f.close
    m = p.search(tex)
    print(m.group())
    mrbtsid = m.group(1)
    nrbtsid = m.group(2)
    nrcellid = m.group(3)
    return mrbtsid, nrbtsid, nrcellid


def search_list_from_snap(file_name, cprt_name):
    f = open(file_name)
    tex = f.read()
    f.close
    part_re = re.compile(r'(BTS\d*_[\w\W]*?)\s\n')
    part = part_re.findall(tex)
    flag = 0
    zip_file = 'test'
    for i in range(len(part)-1):
        line_re = re.compile(r'\s*([\w\W]*?)\s')
        line = line_re.findall(part[i])
        for j in range(len(line)-1):
            if cprt_name in line[j]:
                flag = 1
                zip_file = line[0]
                break
        if flag == 1:
            break
    zip_re = re.compile(r'\s*([\w\W]*?)(?=:)')
    zip_name = zip_re.findall(zip_file)
    print(zip_name[0])
    return zip_name[0]


# get item from scf
# use:${item}   get_item_from_scf   scf_file_path=${scf_path_recover}   ref=<p name="nrCellIdentity">([\\w\\W]*?)</p>
# ([\\w\\W]*?): expert item
def get_item_from_scf(scf_file_path, ref):
    p = re.compile(r'{}'.format(ref))
    f = open(scf_file_path)
    tex = f.read()
    f.close
    item = p.findall(tex)
    print(item)
    return item


# unzip and get item from xz file
def get_item_from_xzfile(file_path):
    f = open(file_path)
    tex = f.read()
    f.close
    p = re.compile(r'{"l2SubPoolId":(\d*)')
    m = p.findall(tex)
    print(m)
    q = re.compile(r'forgettingRatio":50,"l2SubPoolId":(\d*)')
    n = q.findall(tex)
    print(n)
    return m, n


# unzip and get item from xz file
def get_item_from_xzfile_8322(file_path):
    f = open(file_path, errors='ignore')
    tex = f.read()
    f.close
    a = re.compile(r'"pSRSact":(\w*),')
    b = a.findall(tex)
    print(b)
    c = re.compile(r'"pSRSBwvAct":(\w*),')
    d = c.findall(tex)
    print(d)
    e = re.compile(r'"bwvSubbandSize":(\d*)')
    f = e.findall(tex)
    print(d)
    g = re.compile(r'"maxRtBwvDownloadPerSlot":(\d*)')
    h = g.findall(tex)
    print(d)
    m = re.compile(r'"transmissionComb":"(.*)","sequenceId"')
    n = m.findall(tex)
    print(d)
    o = re.compile(r'"rtBeamStartPid":(\d*)')
    p = o.findall(tex)
    print(d)
    return b, d, f, h, n, p


# get dl bip info from pdml
def get_dl_bip_info_from_pdml(file_path, rnti_traget_num, pid_target_num):
    f = open(file_path)
    tex = f.read()
    f.close
    sfn_re = re.compile(r'showname="sfn+.*: (\d*)"')
    sfn = sfn_re.findall(tex)
    slot_re = re.compile(r'showname="slot+.*: (\d*)"')
    slot = slot_re.findall(tex)
    rnti_re = re.compile(r'showname="rnti+.*: (\d*)"')
    rnti = rnti_re.findall(tex)
    pid_re = re.compile(r'showname="patternId_item_0+.*: (\d*)"')
    pid = pid_re.findall(tex)
    rnti_l = [rnti[0]]
    pid_l = [pid[0]]
    bip_dic = dict()
    bip_list = []
    rnti_count_pass = 0
    pid_count_pass = 0
    for i in range(len(sfn)-1):
        if sfn[i] == sfn[i+1] and slot[i] == slot[i+1]:
            rnti_l.append(rnti[i+1])
            pid_l.append(pid[i+1])
        else:
            rnti_l_l = list(set(rnti_l))
            pid_l_l = list(set(pid_l))
            if len(rnti_l_l) == int(rnti_traget_num):
                rnti_count_pass += 1
            if len(pid_l_l) == int(pid_target_num):
                pid_count_pass += 1
            bip_dic = dict(sfn=sfn[i], slot=slot[i], rnti=rnti_l, pid=pid_l)
            bip_list.append(bip_dic)
            rnti_l = [rnti[i+1]]
            pid_l = [pid[i+1]]
    count_total = len(bip_list)
    rnti_pass_rate = rnti_count_pass/count_total
    pid_pass_rate = pid_count_pass/count_total
    print(count_total)
    print(rnti_count_pass)
    print(pid_count_pass)
    return rnti_pass_rate, pid_pass_rate


# get ul bip info from pdml
def get_ul_bip_info_from_pdml(file_path, rnti_traget_num, pid_target_num):
    f = open(file_path)
    tex = f.read()
    f.close
    pkt_re = re.compile(r'<packet>([\w\W]*?)</packet>')
    pkt = pkt_re.findall(tex)
    sfn_re = re.compile(r'showname="sfn+.*: (\d*)"')
    slot_re = re.compile(r'showname="slot+.*: (\d*)"')
    rnti_re = re.compile(r'showname="rnti+.*: (\d*)"')
    pid_re = re.compile(r'showname="patternId_item_0+.*: (\d*)"')
    rnti_count_pass = 0
    pid_count_pass = 0
    for i in range(len(pkt)):
        sfn = sfn_re.findall(pkt[i])
        slot = slot_re.findall(pkt[i])
        rnti = rnti_re.findall(pkt[i])
        pid = pid_re.findall(pkt[i])
        rnti_l = list(set(rnti))
        pid_l = list(set(pid))
        if len(rnti_l) == int(rnti_traget_num):
            rnti_count_pass += 1
        if len(pid_l) == int(pid_target_num):
            pid_count_pass += 1
    count_total = len(pkt)
    rnti_pass_rate = rnti_count_pass/count_total
    pid_pass_rate = pid_count_pass/count_total
    print(count_total)
    print(rnti_count_pass)
    print(pid_count_pass)
    return rnti_pass_rate, pid_pass_rate


# for test 2052 524 case
def check_524_from_pdml(file_path):
    f = open(file_path)
    tex = f.read()
    f.close
    sfn_re = re.compile(r'showname="sfn+.*: (\d*)"')
    sfn = sfn_re.findall(tex)
    slot_re = re.compile(r'showname="slot+.*: (\d*)"')
    slot = slot_re.findall(tex)
    rnti_re = re.compile(r'showname="rnti+.*: (\d*)"')
    rnti = rnti_re.findall(tex)
    prb_re = re.compile(r'showname="numOfPrb+.*: (\d*)"')
    prb = prb_re.findall(tex)
    antport_re = re.compile(r'showname="antPort+.*: (\d*)"')
    antport = antport_re.findall(tex)
    success_num = 0
    total_num = 0
    for i in range(len(sfn)-1):
        if sfn[i] == sfn[i+1] and slot[i] == slot[i+1] and rnti[i] != rnti[i+1]:
            total_num += 1
            if prb[i] == prb[i+1] and antport[i] != antport[i+1]:
                success_num += 1
    pass_rate = success_num/total_num
    print(total_num)
    print(success_num)
    print(pass_rate)
    return pass_rate


def close_ssh(hostname, username, password):
    a = "sshd.exe"
    b = "{print$2}"
    c = "1,1p"
    d = "END{print}"
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname=hostname, username=username, password=password, port=22)
    stdin, stdout, stderr = ssh.exec_command("tasklist | findstr '%s' | awk '%s' | sed -n '%s'" % (a, b, c))
    first = stdout.read().decode()
    stdin, stdout, stderr = ssh.exec_command("tasklist | findstr '%s' | awk '%s' | awk '%s'" % (a, b, d))
    last = stdout.read().decode()
    stdin, stdout, stderr = ssh.exec_command("tasklist | findstr '%s' | awk '%s'" % (a, b))
    allcon = stdout.read().decode()
    new_first = first.split('\n')
    new_first.pop()
    new_last = last.split('\n')
    new_last.pop()
    new_all = allcon.split('\n')
    new_all.pop()
    for num in range(len(new_all)):
        '''if new_all[num]==new_first[0] or new_all[num]==new_last[0]:'''
        if new_all[num] == new_first[0]:
            pass
        else:
            stdin, stdout, stderr = ssh.exec_command("taskkill /F /PID %s" % new_all[num])
    ssh.close()


def get_value_from_log_file(file_path, check_item):
    f = open(file_path, errors='ignore')
    text = f.read()
    f.close
    p = re.compile(r'%s' % check_item)
    m = p.findall(text)
    return m


# for single ue
def get_info_from_pdml(pdml_path, item):
    f = open(pdml_path)
    tex = f.read()
    f.close
    pkt_re = re.compile(r'<packet>([\w\W]*?)</packet>')
    pkt = pkt_re.findall(tex)
    pkt_len = len(pkt)
    rnti_re = re.compile(r'showname="rnti+.*: (\d*)"')
    rnti = rnti_re.findall(tex)
    rnti_set = 0
    bip_dic = dict()
    bip_list = []
    value_list = []
    flag = 0
    for i in range(len(rnti)-1):
        if rnti[i+1] == rnti[i]:
            flag += 1
        else:
            flag = 0
        if flag > 100:
            rnti_set = rnti[i]
            break
    pkt_b = list(pkt)
    j = 0
    for i in range(len(pkt)):
        rnti = rnti_re.findall(pkt[i])
        rnti_l = list(set(rnti))
        if len(rnti_l) > 1:
            pkt_b.pop(i-j)
            j += 1
    pkt_c = list(pkt_b)
    k = 0
    for i in range(len(pkt_b)):
        rnti = rnti_re.findall(pkt_b[i])
        if rnti[0] != rnti_set:
            pkt_c.pop(i-k)
            k += 1
    count_total = len(pkt_c)
    pass_rate = count_total/pkt_len
    print(pass_rate)
    tex = "".join(pkt_c)
    for i in range(len(item)):
        item_name = item[i]
        msg = re.findall(r'\w*_(\w*)\.', item_name, re.I)
        name = re.findall(r'[\w\W]*\.(\w*)', item_name, re.I)
        item_re = re.sub(r'grants_item_\d*', 'grants_item_\\d*', item_name, re.I)
        p = re.compile(r'"{}"(.*?)/>'.format(item_re))
        value = p.findall(tex)
        for i in range(len(value)-1):
            p = re.compile(r'showname=.*?\((\w*)\):\s(\w*)\s?\((.*?)\)')
            val = p.search(value[i])
            if val.group(1) == "Enum":
                value_list.append(val.group(2))
            else:
                value_list.append(val.group(3))
        values = [int(x) for x in value_list]
        value_list = []
        bip_dic = dict(MSG=msg[0], item=name[0], value=values)
        bip_list.append(bip_dic)
    return bip_list


def calcu_kpi_from_pmfile(file_name, pm_name):
    f = open(file_name)
    ftex = f.read()
    f.close
    p = open(pm_name)
    ptex = p.read()
    p.close
    item_re = re.compile(r'M55\w{9}')
    item = item_re.findall(ptex)
    kpi = 0
    for i in range(len(item)):
        pm = item[i]
        f_re = re.compile(r'<{}>(\d*)</{}>'.format(pm, pm))
        value = f_re.findall(ftex)
        value = value[0]
        ptex = ptex.replace(pm, value)
    kpi = eval(ptex)
    return kpi


def check_tti(file_path, filte_item, index):
    f = open(file_path)
    lines = f.readlines()
    info_list = []
    item_list = []
    i = eval(index)
    for line in lines:
        if filte_item in line:
            info_list = line.split(',')
            item_list.append(info_list[i])
    f.close
    return item_list


def remove_dup_value_in_list(L):
    for index in L:
        if L.count(index) != 1:
            for i in range((L.count(index)-1)):
                L.remove(index)
    return L


def get_row_number(file_path, check_row):
    with open(file_path) as f:
        reader = csv.reader(f)
        header = next(reader)
        for index in range(len(header)):
            if header[index] == check_row:
                break
        return index


def get_tti_value(file_path, row_header, line_header):
    row_number = get_row_number(file_path=file_path, check_row=row_header)
    with open(file_path) as f:
        value = []
        reader = csv.reader(f)
        for line in reader:
            if line[0] == line_header:
                value.append(line[row_number])
        return value


def get_max_value_in_list(L):
    max_value = max(L)
    return max_value


def type_change_string_to_ini(L):
    R = []
    for i in L:
        a = int(i)
        R.append(a)
    return R


def get_value_from_long_dic(dic, key1, key2, key3, key4, key5, key6):
    value = dic[key1][key2][key3][key4][key5][key6]
    return value


def get_counter_sum(counters):
    counter_int = []
    for index in range(0, len(counters)):
        counter_int.append(int(counters[index]))
    counter_sum = sum(counter_int)
    return counter_sum


# get sfn slo from pdml
def get_sfn_slo_from_pdml(file_path):
    f = open(file_path)
    tex = f.read()
    f.close
    sfn_re = re.compile(r'showname="sfn+.*: (\d*)"')
    sfn = sfn_re.findall(tex)
    slot_re = re.compile(r'showname="slot+.*: (\d*)"')
    slot = slot_re.findall(tex)
    sfn = list(map(int, sfn))
    slot = list(map(int, slot))
    return sfn, slot


# get sfn index list by mod
def get_sfn_index_list_by_mod(sfn_list, mod_num, remainder):
    sfn_index = []
    cout = len(sfn_list)
    for i in range(cout):
        result = sfn_list[i] % mod_num
        if result == remainder:
            sfn_index.append(i)
    return sfn_index


# List deduplication and output list sorted from small to large
def list_to_repeat(old_list):
    old_list = list(map(int, old_list))
    key_list = list(set(old_list))
    return key_list


def get_value_from_cprt_log(file_path):
    f = open(file_path)
    tex = f.read()
    f.close
    pattern = r'(.*)CellSetupResp:\s'
    golbal_str = re.sub(pattern, '', tex)
    golbal_str_1 = re.sub(r'\r\n|\r|\n', '', golbal_str)
    CsiRs_re = re.compile(r'("availablePucchAndCsiRsResources":.*?"goldenPucchResourceForCsiReport":0}])')
    CsiRs_str_list = CsiRs_re.findall(golbal_str_1)
    InSsSlot_re = re.compile(r'"?Slots":(\d*)')
    InSsSlot_list_0 = InSsSlot_re.findall(CsiRs_str_list[0])
    InSsSlot_list_1 = InSsSlot_re.findall(CsiRs_str_list[1])
    InSsSlot_list_2 = InSsSlot_re.findall(CsiRs_str_list[2])
    InSsSlot_list_3 = InSsSlot_re.findall(CsiRs_str_list[3])
    InSsSlot_list_0 = list(map(int, InSsSlot_list_0))
    InSsSlot_list_1 = list(map(int, InSsSlot_list_1))
    InSsSlot_list_2 = list(map(int, InSsSlot_list_2))
    InSsSlot_list_3 = list(map(int, InSsSlot_list_3))
    return InSsSlot_list_0, InSsSlot_list_1, InSsSlot_list_2, InSsSlot_list_3


def get_value_from_cprt(file_path):
    f = open(file_path, errors='ignore')
    tex = f.read()
    f.close
    pattern = r'(.*)CellSetupResp:\s'
    golbal_str = re.sub(pattern, '', tex)
    pattern_0 = r'(.*)StorePucchResourcesInCell.cpp:\d*\s'
    golbal_str_0 = re.sub(pattern_0, '', golbal_str)
    golbal_str_1 = re.sub(r'\r\n|\r|\n', '', golbal_str_0)
    CsiRs_re = re.compile(r'(availablePucchAndCsiRsResources.*?goldenPucchResourceForCsiReport.*?}])')
    CsiRs_str_list = CsiRs_re.findall(golbal_str_1)
    # InSsSlot_re = re.compile(r'csiRsResourcesInSsSlots.*?(\d*),|csiRsResourcesInDataSlots.*?(\d*),')
    InSsSlot_re = re.compile(r'Slots.*?(\d*),')
    InSsSlot_list_0 = InSsSlot_re.findall(CsiRs_str_list[0])
    InSsSlot_list_1 = InSsSlot_re.findall(CsiRs_str_list[1])
    InSsSlot_list_2 = InSsSlot_re.findall(CsiRs_str_list[2])
    InSsSlot_list_3 = InSsSlot_re.findall(CsiRs_str_list[3])
    InSsSlot_list_0 = list(map(int, InSsSlot_list_0))
    InSsSlot_list_1 = list(map(int, InSsSlot_list_1))
    InSsSlot_list_2 = list(map(int, InSsSlot_list_2))
    InSsSlot_list_3 = list(map(int, InSsSlot_list_3))
    return InSsSlot_list_0, InSsSlot_list_1, InSsSlot_list_2, InSsSlot_list_3


# def change_date_to_list(gap_data):
#     gap_len = len(gap_data)
#     new_list = []
#     for i in range(gap_len):
#         count = len(gap_data[i])
#         sub_data = gap_data[i]
#         for j in range(count):
#             if sub_data[j] != '':
#                 new_list.append(sub_data[j])
#     return new_list


def get_list_index_by_target_value(gobal_list, target_value):
    index_list = []
    count = len(gobal_list)
    for i in range(count):
        if gobal_list[i] == target_value:
            index_list.append(i)
    return index_list


def get_random_num(count, range_value):
    nums = random.sample(range(range_value), k=count)
    return nums


def get_mod_result(num, mod_num):
    result = num % mod_num
    return result


def get_need_info_from_pdml_for_check_1(file_path):
    f = open(file_path)
    tex = f.read()
    f.close
    sfn_re = re.compile(r'showname="sfn+.*: (\d*)"')
    sfn = sfn_re.findall(tex)
    slot_re = re.compile(r'showname="slot+.*: (\d*)"')
    slot = slot_re.findall(tex)
    startSymbol_re = re.compile(r'showname="startSymbol+.*: (\d*)"')
    startSymbol = startSymbol_re.findall(tex)
    startPrb_re = re.compile(r'showname="startPrb+.*: (\d*)"')
    startPrb = startPrb_re.findall(tex)
    numOfPrb_re = re.compile(r'showname="numOfPrb+.*: (\d*)"')
    numOfPrb = numOfPrb_re.findall(tex)
    sfn = list(map(int, sfn))
    slot = list(map(int, slot))
    startSymbol = list(map(int, startSymbol))
    startPrb = list(map(int, startPrb))
    numOfPrb = list(map(int, numOfPrb))
    return sfn, slot, startSymbol, startPrb, numOfPrb


def judge_num(gap, num1, num2):
    if gap == num1:
        status = True
    elif gap == num2:
        status = True
    else:
        status = False
    return status


def judge_num_three(gap, num1, num2, num3):
    if gap == num1:
        status = True
    elif gap == num2:
        status = True
    elif gap == num3:
        status = True
    else:
        status = False
    return status


def get_need_info_from_pdml_for_check_2(file_path):
    f = open(file_path)
    tex = f.read()
    f.close
    sfn_re = re.compile(r'showname="sfn+.*: (\d*)"')
    sfn = sfn_re.findall(tex)
    slot_re = re.compile(r'showname="slot+.*: (\d*)"')
    slot = slot_re.findall(tex)
    pwrReduction_re = re.compile(r'showname="pwrReductionPerCsiRsResource_dB+.*: (\d*)"')
    pwrReduction = pwrReduction_re.findall(tex)
    sfn = list(map(int, sfn))
    slot = list(map(int, slot))
    pwrReduction = list(map(int, pwrReduction))
    return sfn, slot, pwrReduction


def get_usedmcs_avge_list_for_CNI110468(gap_slot, usedmcs):
    slot3_usedmcs = 0
    slot6_usedmcs = 0
    slot7_usedmcs = 0
    slot8_usedmcs = 0
    slot13_usedmcs = 0
    slot16_usedmcs = 0
    slot17_usedmcs = 0
    slot18_usedmcs = 0

    slot3_num = 0
    slot6_num = 0
    slot7_num = 0
    slot8_num = 0
    slot13_num = 0
    slot16_num = 0
    slot17_num = 0
    slot18_num = 0

    usedmcs_avge_list = []

    cout = len(gap_slot)
    for i in range(cout):
        if gap_slot[i] == '3' and usedmcs[i] != '31.0':
            slot3_usedmcs = slot3_usedmcs + int(float(usedmcs[i]))
            slot3_num = slot3_num + 1
        if gap_slot[i] == '6' and usedmcs[i] != '31.0':
            slot6_usedmcs = slot6_usedmcs + int(float(usedmcs[i]))
            slot6_num = slot6_num + 1
        if gap_slot[i] == '7' and usedmcs[i] != '31.0':
            slot7_usedmcs = slot7_usedmcs + int(float(usedmcs[i]))
            slot7_num = slot7_num + 1
        if gap_slot[i] == '8' and usedmcs[i] != '31.0':
            slot8_usedmcs = slot8_usedmcs + int(float(usedmcs[i]))
            slot8_num = slot8_num + 1
        if gap_slot[i] == '13' and usedmcs[i] != '31.0':
            slot13_usedmcs = slot13_usedmcs + int(float(usedmcs[i]))
            slot13_num = slot13_num + 1
        if gap_slot[i] == '16' and usedmcs[i] != '31.0':
            slot16_usedmcs = slot16_usedmcs + int(float(usedmcs[i]))
            slot16_num = slot16_num + 1
        if gap_slot[i] == '17' and usedmcs[i] != '31.0':
            slot17_usedmcs = slot17_usedmcs + int(float(usedmcs[i]))
            slot17_num = slot17_num + 1
        if gap_slot[i] == '18' and usedmcs[i] != '31.0':
            slot18_usedmcs = slot18_usedmcs + int(float(usedmcs[i]))
            slot18_num = slot18_num + 1

    if slot3_usedmcs != 0:
        n = slot3_usedmcs // slot3_num
        usedmcs_avge_list.append(n)
    if slot6_usedmcs != 0:
        n = slot6_usedmcs // slot6_num
        usedmcs_avge_list.append(n)
    if slot7_usedmcs != 0:
        n = slot7_usedmcs // slot7_num
        usedmcs_avge_list.append(n)
    if slot8_usedmcs != 0:
        n = slot8_usedmcs // slot8_num
        usedmcs_avge_list.append(n)
    if slot13_usedmcs != 0:
        n = slot13_usedmcs // slot13_num
        usedmcs_avge_list.append(n)
    if slot16_usedmcs != 0:
        n = slot16_usedmcs // slot16_num
        usedmcs_avge_list.append(n)
    if slot17_usedmcs != 0:
        n = slot17_usedmcs // slot17_num
        usedmcs_avge_list.append(n)
    if slot18_usedmcs != 0:
        n = slot18_usedmcs // slot18_num
        usedmcs_avge_list.append(n)
    return usedmcs_avge_list


def check_target_list_deviation(target_list, deviation):
    result = False
    count = len(target_list)
    for i in range(count):
        for j in range(0, count-i-1):
            n = target_list[j] - target_list[j+1]
            n = abs(n)
            if 0 <= n <= deviation:
                result = True
            else:
                break
    return result


def get_target_list(gap_list):
    count = len(gap_list)
    result = []
    for i in range(count):
        slot = get_mod_result(num=i, mod_num=20)
        result.append(slot)
    return result


def get_no_8192_slot_list(slot, value_list):
    count = len(slot)
    dele_list = [4, 9, 14, 19]
    for i in range(count):
        if value_list[i] == 8192:
            dele_list.append(slot[i])
    dele_list = list_to_repeat(old_list=dele_list)
    slot = list_to_repeat(old_list=slot)
    count1 = len(slot)
    n = len(dele_list)
    for i in range(count1-1, -1, -1):
        for j in range(n):
            if slot[i] == dele_list[j]:
                slot.remove(slot[i])
    no_8192_slot = slot
    return no_8192_slot


def check_list_by_gap_value(list1, list2, gap_value):
    result = False
    count = len(list1)
    for i in range(count):
        list_sum = list1[i] + list2[i]
        if list_sum == gap_value:
            result = False
        else:
            result = True
    return result


def get_need_info_from_pdml_for_11117(file_path):
    f = open(file_path)
    tex = f.read()
    f.close
    dlDmrsAddPos_re = re.compile(r'showname="dlDmrsAddPos+.*: (\d*)"')
    dlDmrsAddPos = dlDmrsAddPos_re.findall(tex)
    dlDmrsAddPos = list(map(int, dlDmrsAddPos))
    return dlDmrsAddPos


def check_tti_by_value(file_path, filte_item, find_value):
    f = open(file_path)
    lines = f.readlines()
    info_list = []
    item_list = []
    for line in lines:
        if filte_item in line:
            info_list = line.split(',')
            item_count = int(len(info_list)/2)
            value_item_index = info_list.index(find_value)
            value_index = item_count + value_item_index
            item_list.append(info_list[value_index])
    f.close
    return item_list


def find_ue_attach_id(file_path, filte_item, find_value):
    f = open(file_path)
    lines = f.readlines()
    info_list = []
    item_list = []
    for line in lines:
        if filte_item in line:
            info_list = line.split(',')
            item_count = int(len(info_list)/2)
            value_item_index = info_list.index(find_value)
            value_index = item_count + value_item_index
            if info_list[value_index] == '0':
                info_list[value_item_index] = 'no_attach'
                value_item_index = info_list.index(find_value)
                value_index = item_count + value_item_index
                item_list.append(info_list[value_index])
            else:
                item_list.append(info_list[value_index])
    f.close
    return item_list


def check_list_accrod_gap_value(gap_list, first_value, last_value):
    result = False
    first_index = gap_list.index(first_value)
    last_index = gap_list.index(last_value)
    if first_index > last_index:
        result = True
    else:
        result = False
    return result


def count_kpi_value_in_list(gap_list, find_value):
    value_count = 0
    count = len(gap_list)
    for i in range(count):
        if gap_list[i] == find_value:
            value_count = value_count + 1
    return value_count


def get_avge(gap_list):
    sum = 0
    gap_list = list(map(int, gap_list))
    count = len(gap_list)
    for i in range(count):
        sum = sum + gap_list[i]
    avge = sum // count
    return avge


def get_need_info_from_pdml_for_check_3(file_path):
    f = open(file_path)
    tex = f.read()
    f.close
    sfn_re = re.compile(r'showname="sfn+.*: (\d*)"')
    sfn = sfn_re.findall(tex)
    slot_re = re.compile(r'showname="slot+.*: (\d*)"')
    slot = slot_re.findall(tex)
    numOfPdschSymbols_re = re.compile(r'showname="numOfPdschSymbols+.*_(\d*)_')
    numOfPdschSymbols = numOfPdschSymbols_re.findall(tex)
    startSymbol_re = re.compile(r'showname="startSymbol+.*: (\d*)"')
    startSymbol = startSymbol_re.findall(tex)
    subcellId_re = re.compile(r'showname="subcellId+.*: (\d*)"')
    subcellId = subcellId_re.findall(tex)
    sfn = list(map(int, sfn))
    slot = list(map(int, slot))
    numOfPdschSymbols = list(map(int, numOfPdschSymbols))
    startSymbol = list(map(int, startSymbol))
    subcellId = list(map(int, subcellId))
    return sfn, slot, numOfPdschSymbols, startSymbol, subcellId


def get_need_info_from_pdml_for_check_4(file_path):
    f = open(file_path)
    tex = f.read()
    f.close
    sfn_re = re.compile(r'showname="sfn+.*: (\d*)"')
    sfn = sfn_re.findall(tex)
    slot_re = re.compile(r'showname="slot+.*: (\d*)"')
    slot = slot_re.findall(tex)
    subcellId_re = re.compile(r'showname="subcellId+.*: (\d*)"')
    subcellId = subcellId_re.findall(tex)
    sfn = list(map(int, sfn))
    slot = list(map(int, slot))
    subcellId = list(map(int, subcellId))
    return sfn, slot, subcellId


def get_target_list_value(target_list, target_index):
    value_list = []
    count = len(target_index)
    for i in range(count):
        value_list.append(target_list[target_index[i]])
    return value_list


def check_syslog(file_path, target):
    f = open(file_path)
    tex = f.read()
    f.close
    count = len(target)
    result = []
    target_num = 0
    for i in range(count):
        target_re = re.compile(r'(.*' + target[i] + '.*)')
        result_1 = target_re.findall(tex)
        result = result + result_1
        target_num = target_num + len(result_1)
    return result, target_num


def sinmple_timer(min, gap_time):
    while min not in gap_time:
        time.sleep(60)
        min = min + 1
        if min == 60:
            min = 0


def sinmple_timer_2(min):
    gap = min % 15
    if gap != 0:
        gap = 15 - gap
    return gap


def check_newformat_tti_by_value(file_path, filte_item, find_value):
    f = open(file_path)
    lines = f.readlines()
    info_list = []
    item_list = []
    type_line = lines[0].split(',')
    for line in lines:
        if filte_item in line:
            info_list = line.split(',')
            value_item_index = type_line.index(find_value)
            value_index = value_item_index
            item_list.append(info_list[value_index])
    f.close
    return item_list


def get_sum_for_list(gap_list):
    sum = 0
    gap_list = list(map(int, gap_list))
    for i in gap_list:
        sum = sum + gap_list[i]
    return sum


def find_gap_value(file_path, filte_item, txt):
    f = open(file_path)
    lines = f.readlines()
    item_list = []
    for line in lines:
        if filte_item in line:
            find_value_re = re.compile(r'' + txt + '')
            find_value_1 = find_value_re.findall(line)
            item_list.append(find_value_1)
    f.close
    return item_list


def check_newformat_tti_by_value_2(file_path, filte_item, find_value):
    f = open(file_path)
    lines = csv.DictReader(f)
    item_list = []
    for line in lines:
        if filte_item in line['type']:
            item_list.append(line[find_value])
    f.close
    return item_list


def get_avge_2(gap_list):
    sum = 0
    gap_list = list(map(float, gap_list))
    gap_list = list(map(int, gap_list))
    count = len(gap_list)
    for i in range(count):
        sum = sum + gap_list[i]
    avge = round(sum / count, 6)
    return avge


def get_gap_line(gobal_info):
    find_value_re = re.compile(r'(\d*?):')
    find_value_1 = find_value_re.findall(gobal_info)
    line = find_value_1[0]
    return line


def get_value_from_syslog(file_path):
    f = open(file_path, errors='ignore')
    tex = f.read()
    f.close
    pattern = r'(.*)CellSetupResp:\s'
    golbal_str = re.sub(pattern, '', tex)
    golbal_str_1 = re.sub(r'\r\n|\r|\n', '', golbal_str)
    print(golbal_str_1)
    CsiRs_re = re.compile(r'(availablePucchAndCsiRsResources.*?goldenPucchResourceForCsiReport.*?}])')
    CsiRs_str_list = CsiRs_re.findall(golbal_str_1)
    # InSsSlot_re = re.compile(r'csiRsResourcesInSsSlots.*?(\d*),|csiRsResourcesInDataSlots.*?(\d*),')
    InSsSlot_re = re.compile(r'Slots.*?(\d*),')
    InSsSlot_list_0 = InSsSlot_re.findall(CsiRs_str_list[0])
    InSsSlot_list_1 = InSsSlot_re.findall(CsiRs_str_list[1])
    InSsSlot_list_2 = InSsSlot_re.findall(CsiRs_str_list[2])
    InSsSlot_list_3 = InSsSlot_re.findall(CsiRs_str_list[3])
    InSsSlot_list_0 = list(map(int, InSsSlot_list_0))
    InSsSlot_list_1 = list(map(int, InSsSlot_list_1))
    InSsSlot_list_2 = list(map(int, InSsSlot_list_2))
    InSsSlot_list_3 = list(map(int, InSsSlot_list_3))
    return InSsSlot_list_0, InSsSlot_list_1, InSsSlot_list_2, InSsSlot_list_3
