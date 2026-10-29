#!-*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Xiang Liang
:contact: liang.xiang@nokia-sbell.com
"""
import os
import time
from robot.api import logger
import paramiko
import datetime

MakeAnaModiBearer = 1
DelBearer = 2
MME = '10_107_182_64'
PCMD_HOST = '10.57.252.3'
base = [str(x) for x in range(10)] + [chr(x) for x in range(ord('A'), ord('A') + 6)]


def find_record(filepath, cell_id, check_dic):
    """
    Find_correct_PCMD_record_and_return_it
    Add pcmd record index 88 check
    Add RRC Failure Scenario check
    if check_list=[],it will only check RRC failure scenario
    Get the correct PCMD record and write it into a txt
    """
    find_result = 0
    cell_id = int(cell_id)
    print('find_record cell_id = %s' % cell_id)
    if ('pcmd' in filepath) and (filepath[-3:] == '.gz'):
        print('find_record filepath = %s' % filepath)
        with open(un_gz(filepath)) as f:
            lines = f.readlines()
            for line in lines:
                counter = 0
                record_list = line.split(';')
                if record_list[20] != '':  # field 21: current cell ID
                    if cell_id == int(record_list[20].split(':')[-1], 16):  # Get cell_id as decimalism
                        for k, v in check_dic.items():
                            value = is_num_by_except(v)
                            index = int(k.encode("utf-8")) - 1
                            check_value = is_num_by_except(record_list[index])
                            if value == check_value:
                                counter += 1
                if counter == len(list(check_dic.keys())):
                    print("find_record: one PCMD record has been found: %s" % record_list)
                    pathf = os.path.dirname(filepath)
                    record_txt = pathf + '/'
                    find_result += 1
                    f2 = open(record_txt + 'record_pcmd.txt', 'a')
                    f2.write(line)
                    f2.close()
    if find_result == 0:
        print("No normal scenario PCMD Record be found")
    elif find_result == 1:
        print("Find %d normal scenario PCMD record," % find_result)
    elif find_result > 1:
        print("Find %d normal scenario PCMD records," % find_result)
    return find_result


def get_pcmd_record(filepath):
    """
    Read the txt and return the first record
    """
    record_result = False
    filenames = os.listdir(filepath)
    if not filenames:
        print('No Log files,path=%s' % filepath)
        return record_result
    pcmdlog_list = []
    for filename in filenames:
        if filename[-8:] == 'pcmd.txt':
            record_file = filepath + '/' + filename
            with open(record_file) as f:
                lines = f.readlines()
                for line in lines:
                    pcmdlog_list.append(line)
    return pcmdlog_list


def find_pcmd_flie_tar_path(gummei='/0:0:0:0'):
    base_path = '/oamdata/ca4mn/PCMD/global/'
    now = datetime.datetime.now()
    today = now.strftime('%Y%m%d')
    print('find_pcmd_flie_tar_path get_date_format todat=%s' % today)
    tar_path = base_path + today + gummei
    return tar_path


def conver_timStr_to_time(str_fname):
    t_time = time.strptime(str_fname, '%Y%m%d%H%M')  # format: '201702250821'
    t_time = time.mktime(t_time)
    t_time = time.localtime(t_time)
    t_time = time.strftime('%Y-%m-%d %H:%M', t_time)  # format: 2017-02-25 08:21
    return t_time


def download_log_from_pcmd(gummei, local_log_dir, record_type_value):
    pcmd_path = None
    print('NPC IP: %s' % PCMD_HOST)
    try:
        sec_path = paramiko.Transport((PCMD_HOST, 2222))
        sec_path.connect(username='pcmduser1', password='Nokia@out')
        sftp = paramiko.SFTPClient.from_transport(sec_path)
        if int(record_type_value) == 1:
            pcmd_path = find_pcmd_flie_tar_path(gummei)
            print('download_log_from_pcmd normal pcmd files path %s generated!!!' % pcmd_path)
        elif int(record_type_value) == 2:
            pcmd_path = find_pcmd_flie_tar_path()
            print('download_log_from_pcmd RRC connection fialure pcmd files path %s generated!!!' % pcmd_path)
        files_list = sftp.listdir(pcmd_path)
        files_list.sort(reverse=True)
        print("PCMD files list with sort:%s" % files_list[:7:])
        for file1 in files_list[:7:]:  # get the last 5 pcmd files
            if ('TMP' not in file1) and ('gz' in file1):  # get file fromat:2017-02-28.11_56.+0800.MMEpcmd.gz
                sftp.get(os.path.join(pcmd_path, file1), os.path.join(local_log_dir, file1))
        sec_path.close()
    except Exception as e:
        print('ssh %s@%s: %s' % ('pcmduser1', PCMD_HOST, e))
    return None


def dec2hex(string_num):
    num = int(string_num)
    mid = []
    while True:
        if num == 0:
            break
        num, rem = divmod(num, 16)
        mid.append(base[rem])
    return ''.join([str(xe) for xe in mid[::-1]])


def un_gz(file_name):
    f_name = file_name.replace(".gz", "")
    os.system('gzip -dc ' + file_name + ' > ' + f_name)
    return f_name


def is_num_by_except(num):
    try:
        return int(num)
    except ValueError:
        return num.encode("utf-8")
