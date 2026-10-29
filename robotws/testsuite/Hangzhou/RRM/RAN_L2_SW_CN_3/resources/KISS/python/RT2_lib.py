# from __future__ import absolute_import
# from __future__ import print_function
import os
import re
import sys
import types
import shutil
import time
# from tdd_ev_robotws import CommonLib
import codecs
import glob
import math
import datetime
import string
import math
import paramiko
from six.moves import range


def get_snr(log_path, min_value, max_value, percent):
    try:
        file_handle = open('%s' % log_path, 'r')
    except Exception:
        raise Exception("UDP log '%s' open failed" % log_path)
    lines = file_handle.readlines()
    snr = []
    count = 0
    pattern = "snr:"
    try:
        for line in lines:
            if re.search(pattern, line):
                search_result = re.search(r"pre-snr:\\s*(\\d+)", line)
                if search_result:
                    snr_num = search_result.groups()[0]
                    snr.append(snr_num)
    finally:
        file_handle.close()
    for i in range(len(snr)):
        if float(snr[i]) < float(min_value):
            print("failed in line %s !" % snr[i])
            count = count + 1
        if float(snr[i]) > float(max_value):
            print("failed in line %s !" % snr[i])
            count = count + 1
    print("===============================")
    print(snr)
    print(count)
    print(len(snr))
    print(float(count)/len(snr))
    print("===============================")
    if float(count)/len(snr) > float(percent):
        raise Exception("Error snr rate over 1% !")


def get_releasetime(tm500_log):
    try:
        file_handle = open('%s' % (glob.glob(tm500_log)[0]), 'r')
        print("Protocol log '%s' open success" % glob.glob(tm500_log)[0])
    except Exception:
        raise Exception("Protocol log '%s' open failed" % glob.glob(tm500_log)[0])
    lines = file_handle.read()
    try:
        rlstime = re.findall(r"(\\d+):(\\d+):(\\d+):(\\d+)\\s+PCO_RRC_DL_DCCH_Message.*\\n+\\{\\n+.*\\n.*\\n.*\\n.*\\n"
                             r"\\s+drb-ToReleaseList.*\\n", lines, re.M)
        releasetime = rlstime[0][0] + ':' + rlstime[0][1] + ':' + rlstime[0][2] + ':' + rlstime[0][3]
        print("releasetime is '%s'" % releasetime)
    finally:
        file_handle.close()
    return releasetime


def calc_diff(log_path, pattern, filterkw):
    try:
        file_handle = open('%s' % (glob.glob(log_path)[0]), 'r')
        print("Protocol log '%s' open success" % glob.glob(log_path)[0])
    except Exception:
        raise Exception("Protocol log '%s' open failed" % glob.glob(log_path)[0])
    lines = file_handle.readlines()
    kwvaluelist = []
    filterkwall = ".*" + filterkw+"(-?\\d+).*"
    try:
        for line in lines:
            if re.search(pattern, line):
                search_result = re.search(filterkwall, line)
                if search_result:
                    kwvalue = []
                    kwvalue = search_result.groups()
                    kwvaluelist.append(kwvalue)
        kwvaluediff = int(kwvaluelist[-1][0]) - int(kwvaluelist[0][0])
        print("kwvaluediff is %d." % kwvaluediff)
    finally:
        file_handle.close()
    return kwvaluediff


def calc_ExceedingRb(log_path):
    try:
        file_handle = open('%s' % (glob.glob(log_path)[0]), 'r')
        print("UDP log '%s' open success" % glob.glob(log_path)[0])
    except Exception:
        raise Exception("UDP log '%s' open failed" % glob.glob(log_path)[0])
    lines = file_handle.readlines()
    kwvaluelist = []
    pattern0 = "Mac_CongestionResolutionReq"
    pattern1 = "ExceedingRb"
    try:
        for line in lines:
            if re.search(pattern0, line):
                search_result = re.search(".*Mac_CongestionResolutionReq.*\\((-?\\d+),(-?\\d+)\\)", line)
                CellC = search_result.groups()
            if re.search(pattern1, line):
                search_result = re.search(".*ExceedingRb\\s=\\s(-?\\d+)", line)
                ExceedingRb = search_result.groups()
        CellC_A = int(CellC[0])
        CellC_B = int(CellC[1])
        ExceedingRb = int(ExceedingRb[0])
        print("CellC is (%d,%d),and ExceedingRb is %d" % (CellC_A, CellC_B, ExceedingRb))
    finally:
        file_handle.close()
    if int(math.ceil(float(CellC_A - CellC_B)/100)*4) != ExceedingRb:
        raise Exception("CellC and ExceedingRb dosn't meet the rule!")
    else:
        print("pass")


def ssh_connect(_host, _username, _password):
    try:
        _ssh_fd = paramiko.SSHClient()
        _ssh_fd.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        _ssh_fd.connect(_host, username=_username, password=_password)
    except Exception as e:
        print('ssh %s@%s: %s' % (_username, _host, e))
        exit()
    return _ssh_fd


def bts_and_iphy_software_reboot():
    sshd1 = ssh_connect('192.168.255.1', 'toor4nsn', 'oZPS0POrRieRtu')
    sshd2 = ssh_connect('192.168.255.20', 'toor4nsn', 'oZPS0POrRieRtu')
    stdin, stdout, stderr = sshd1.exec_command('reboot')
    stdin, stdout, stderr = sshd2.exec_command('reboot')
    sshd1.close
    sshd2.close


if __name__ == '__main__':
    bts_and_iphy_software_reboot()
    pass
