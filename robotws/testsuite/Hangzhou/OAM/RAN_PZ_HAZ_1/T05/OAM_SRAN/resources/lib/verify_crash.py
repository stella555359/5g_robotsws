# -*- coding:utf-8 -*-
"""
Author: Li Yanan
Contacts: amaand.li@nokia-sbell.com
Description: provide the api for verifying crashes

"""
import queue
import random
import re
import subprocess
import time
import os
import tarfile
import paramiko
import xlwt
import xlrd
from xlutils.copy import copy
from queue import Queue
import threading

CRASH_PRINTS = [
    "EU name",
    "fatality",
]


def un_tar(file_path):
    sp_file_lists = []
    sm_path_lists = []
    filenames = os.listdir(file_path)
    if filenames:
        for filename in filenames:
            sm_path = os.path.join(file_path, filename)
            if os.listdir(sm_path):
                time.sleep(1)
                sm_path_lists.append(sm_path)
                tar_filename = os.listdir(sm_path)[0]
                if os.path.splitext(tar_filename)[1] == ".tgz":
                    filefullpath = os.path.join(sm_path, tar_filename)
                    tar = tarfile.open(filefullpath)
                    names = tar.getnames()
                    for name in names:
                        if name != '.':
                            tar.extract(name, sm_path)
                            sp_file = filename + '/' + name
                            sp_file_lists.append(sp_file)
                    tar.close()
        return sp_file_lists, sm_path_lists


def time_consuming(q):
    start = time.time()
    time.sleep(random.randint(5, 10))
    res_status = {"status": "succeed"}
    q.put(res_status)
    end = time.time()
    print("Consuming thread: {}".format(end - start))


def check_syslog_for_crashes(
        suitename, crashfile, crashfilefullpath, casename, qc_id, syslog_path
):
    tmp_bool = "NO"
    subfiles, subfiles_path = un_tar(syslog_path)
    list_log = []
    print("start checking crashes...")
    start = time.time()
    print(start)
    q = Queue()
    t = threading.Thread(target=time_consuming, args=(q,))
    t.daemon = True
    t.start()
    try:
        for subfile in subfiles:
            subfile_path = os.path.join(syslog_path, subfile)
            if os.path.getsize(subfile_path):
                CheckLog(
                    subfile, syslog_path, subfile_path, list_log, crash_log=crashfile
                ).search_crash_log()

        if len(list_log):
            tmp_bool = "YES"
            crash_type = "Unexpected Crash"
            dict_log = [deal_static(casename, qc_id, crash_type, list_log)]
            append2xls(crashfilefullpath, suitename, dict_log)
        remove_untar_files(subfiles_path)
        res_1 = q.get(timeout=1200)
        print(res_1)
    except queue.Empty:
        res_2 = {"status": "timeout"}
        print(res_2)
    if len(list_log):
        upload_crashfile_to_server(crashfile, crashfilefullpath, '10.108.184.40', 'ute', 'ute')
    return tmp_bool


def syslog_contains(syslog_path, wait_validate_msg):
    """
    Return result of wait_validate_msg in syslog.
    :param syslog_path: syslog path to be checked, e.g. '/home/ute/udplogs'
    :param wait_validate_msg: string types to be checked,
    e.g. 'send RESET_TASK with Type_CloseVirtualConnection for /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/RMOD_L-2516/RU_L-1'
    :return: True or False.
    """
    tmp_bool = False
    list_log = []
    if contain_smod_foleder(syslog_path):
        subfiles, subfiles_path = un_tar(syslog_path)
        print("start checking meg in syslog...")
        start = time.time()
        print(start)
        q = Queue()
        t = threading.Thread(target=time_consuming, args=(q,))
        t.daemon = True
        t.start()
        try:
            for subfile in subfiles:
                subfile_path = os.path.join(syslog_path, subfile)
                if os.path.getsize(subfile_path):
                    CheckLog(
                        subfile, syslog_path, subfile_path, list_log, info=wait_validate_msg).search_msg_log()
            if len(list_log):
                tmp_bool = True
            remove_untar_files(subfiles_path)
        except queue.Empty:
            res_s = {"status": "timeout"}
            print(res_s)
    else:
        for root, dirs, files in os.walk(syslog_path):
            print(root, dirs, files)
            for file in files:
                if file.startswith('SYSLOG'):
                    file_path = os.path.join(root, file)
                    if os.path.getsize(file_path):
                        CheckLog(file, syslog_path, file_path, list_log, info=wait_validate_msg).search_msg_log()
        if len(list_log):
            tmp_bool = True
    return tmp_bool


def contain_smod_foleder(f_path):
    for root, dirs, files in os.walk(f_path):
        if 'SMOD1' in dirs or 'SMOD2' in dirs:
            return True
    return False


def upload_unexpected_alarm(suitename, crashfile, crashfilefullpath, casename, qc_id, unexp_alarm_info):
    type_issue = "Unexpected Alarm"
    issue_log = str(unexp_alarm_info)[:32767]
    dict_log = [deal_static(casename, qc_id, type_issue, issue_log)]
    append2xls(crashfilefullpath, suitename, dict_log)
    upload_crashfile_to_server(crashfile, crashfilefullpath, '10.108.184.40', 'ute', 'ute')
    return True


def remove_untar_files(folderlist):
    pattern = "S[Yy][Ss][Ll][Oo][Gg]*"
    for folder in folderlist:
        file_path = folder
        for root, dirs, files in os.walk(file_path):
            for file in filter(lambda x: re.search(pattern, x), files):
                try:
                    os.remove(os.path.join(root, file))
                except Exception as e:
                    print(e, "error")


def deal_static(testcase_name, qc_id, crash_has, crash_info):
    list_item = [testcase_name, qc_id, crash_has, crash_info]
    return list_item


def write2xls(filefullpath, sheetname):
    data = [["Case_Name", "QC_ID", "Issue", "Syslog Info"]]
    index = len(data)
    workbook = xlwt.Workbook()
    sheet = workbook.add_sheet(sheetname)
    for i in range(index):
        for j in range(len(data[i])):
            sheet.write(i, j, data[i][j])  #
    workbook.save(filefullpath)


def append2xls(file_path, sheetname, value):
    index = len(value)
    workbook = xlrd.open_workbook(file_path)
    worksheet = workbook.sheet_by_name(sheetname)
    rows_old = worksheet.nrows
    new_workbook = copy(workbook)
    new_worksheet = new_workbook.get_sheet(0)
    for i in range(index):
        for j in range(len(value[i])):
            new_worksheet.write(i + rows_old, j, value[i][j])
    new_workbook.save(file_path)
    print("xls append successful")


def upload_crashfile_to_server(file, localfilefullpath, serverip, usr, pwd):
    server = (serverip, 22)
    t = paramiko.Transport(server)
    t.connect(username=usr, password=pwd)
    sftp = paramiko.SFTPClient.from_transport(t)
    file_list = sftp.listdir("/home/ute")
    file_list_scan = sftp.listdir("/home/ute/CRASH_COLLECT")
    print("remote file list:{}".format(file_list))
    remote_filepath = "/home/ute/CRASH_COLLECT/"
    remote_folder = "CRASH_COLLECT"
    remote_filepath_scan = "/home/ute/CRASH_COLLECT/scan-temp/"
    remote_scan = "scan-temp"
    if remote_folder in file_list:
        print(True)
        remote_file = remote_filepath + file
        print(remote_file)
    else:
        sftp.mkdir(remote_filepath)
        remote_file = remote_filepath + file
    local_file = localfilefullpath
    sftp.put(local_file, remote_file)
    if remote_scan not in file_list_scan:
        sftp.mkdir(remote_filepath_scan)
    remote_scan_file = remote_filepath_scan + file
    sftp.put(local_file, remote_scan_file)
    t.close()


class CheckLog:
    def __init__(self, logname, log_path, log_fullpath, list_log, info=None, crash_log=None):
        """
        Sets up checklog.

        """
        self.logname = logname
        self.log_fullpath = log_fullpath
        self.log_path = log_path
        self.crash_log = crash_log
        self.list_log = list_log
        self.msg = info

    def save_crashlog(self, text):
        if self.log_path:
            with open(self.crash_log, "a+") as writers:
                writers.write("\r\n" + text)

    def search_crash_log(self):
        try:
            crashes = str(
                subprocess.check_output(
                    "grep -E '{0}|{1}' '{2}'".format(
                        CRASH_PRINTS[0], CRASH_PRINTS[0], self.log_fullpath
                    ),
                    shell=True,
                    universal_newlines=True,
                )
            )
            print("Crashes: {}".format(crashes))
            print(len(crashes))
            if len(crashes):
                print("{0},{1}".format(self.log_fullpath, crashes))
                text = "\r\n" + self.logname + " : " + crashes
                self.list_log.append(text)
                return self.list_log
            else:
                text = "no crash"
                self.save_crashlog(text)
            return True
        except subprocess.CalledProcessError as e:
            if e.returncode == 1:
                return True
            raise RuntimeError("Error occurred during executing {0}".format(e.cmd))
        except Exception as e:
            print(e, "error")

    def search_msg_log(self):
        try:
            contain_msg = str(
                subprocess.check_output(
                    "grep -E '{0}' '{1}'".format(
                        self.msg, self.log_fullpath
                    ),
                    shell=True,
                    universal_newlines=True,
                )
            )
            print("Search result: {}".format(contain_msg))
            print(len(contain_msg))
            if len(contain_msg):
                print("{0},{1}".format(self.log_fullpath, contain_msg))
                text = "\r\n" + self.logname + " : " + contain_msg
                self.list_log.append(text)
                return self.list_log
            else:
                print("syslog doesn't contain {0}".format(self.msg))
            return True
        except subprocess.CalledProcessError as e:
            if e.returncode == 1:
                return True
            raise RuntimeError("Error occurred during executing {0}".format(e.cmd))
        except Exception as e:
            print(e, "error")


if __name__ == '__main__':
    path = '/tmp/btslog2/'
    msg = "send RESET_TASK with Type_CloseVirtualConnection for /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/RMOD_L-2516/RU_L-1"
    res = syslog_contains(path, msg)
    print("res:{}".format(res))
