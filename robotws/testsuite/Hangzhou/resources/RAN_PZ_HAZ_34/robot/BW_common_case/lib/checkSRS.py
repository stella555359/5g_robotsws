import os
import shutil
import zipfile
import re
from os.path import join, getsize
from taf.sbts.oam.coam.admin import admin


def checkSRS_NSA(file):
    with open(file, 'r') as fp:
        lines = fp.readlines()
    s = ""
    for line in lines:
        if 'UserSetupReq_t' in line:
            line_after_split = line.split("::UserSetupReq_t:")
            line_after_split_con = line_after_split[1]
            s += line_after_split_con.strip().strip('\n').strip('\r')
    context = re.split('[,:="]+', s)
    num_freqDomainPosition = context.index('freqDomainPosition')
    freqDomainPosition = context[num_freqDomainPosition+1].strip()
    num_c_SRS = context.index('c_SRS')
    c_SRS = context[num_c_SRS + 1].strip()
    num_b_SRS = context.index('b_SRS')
    b_SRS = context[num_b_SRS + 1].strip()
    num_b_hop = context.index('b_hop')
    b_hop = context[num_b_hop + 1].strip('}').strip()[0]
    return freqDomainPosition, c_SRS, b_SRS, b_hop


def checkSRS_SA(file):
    with open(file, 'r') as fp:
        lines = fp.readlines()
    s = ""
    for line in lines:
        if 'UserModifyReq_t' in line:
            line_after_split = line.split("::UserModifyReq_t:")
            line_after_split_con = line_after_split[1]
            s += line_after_split_con.strip().strip('\n').strip('\r')
    context = re.split('[,:"]+', s)
    num_freqDomainPosition = context.index('freqDomainPosition')
    freqDomainPosition = context[num_freqDomainPosition+1].strip()
    num_c_SRS = context.index('c_SRS')
    c_SRS = context[num_c_SRS + 1].strip()
    num_b_SRS = context.index('b_SRS')
    b_SRS = context[num_b_SRS + 1].strip()
    num_b_hop = context.index('b_hop')
    b_hop = context[num_b_hop + 1].strip('}').strip()[0]
    return freqDomainPosition, c_SRS, b_SRS, b_hop


def get_file_name_list(file_dir):
    file_list_1021 = []
    for root, dirs, files in os.walk(file_dir):
        for file in files:
            if '_1021_part' in os.path.splitext(file)[0]:
                file_list_1021.append(os.path.join(root, file))
    return file_list_1021


def unzip_file(zip_src, dst_dir):
    r = zipfile.is_zipfile(zip_src)
    if r:
        fz = zipfile.ZipFile(zip_src, 'r')
        for file in fz.namelist():
            fz.extract(file, dst_dir)
    else:
        print('This is not zip')


def get_all_file_list(sub_file_dir):
    all_file_list = []
    for root, dirs, files in os.walk(sub_file_dir):
        for file in files:
            all_file_list.append(os.path.join(root, file))
    return all_file_list


def get_1520_file(file_dir, dst_dir):
    file_list = get_file_name_list(file_dir)
    for file in file_list:
        unzip_file(file, dst_dir)
        all_sub_file_list = get_all_file_list(dst_dir)
        for sub_file in all_sub_file_list:
            if '_1520_runtime.zip' in sub_file:
                break
    return sub_file


def checkSRS(file, gnb_type):
    if gnb_type == "'NSA'":
        freqDomainPosition, c_SRS, b_SRS, b_hop = checkSRS_NSA(file)
    else:
        freqDomainPosition, c_SRS, b_SRS, b_hop = checkSRS_SA(file)
    return freqDomainPosition, c_SRS, b_SRS, b_hop


def check_fsm(ipaddr):
    api = admin()
    try:
        connection1 = api.connect_to(bts_host=ipaddr, name="conn1")
        hw_info = connection1.get_fsm_info()
        hw_type = hw_info[0]['productName'].split(" ")[0]
    finally:
        api.teardown(connection="conn1")
    return hw_type
