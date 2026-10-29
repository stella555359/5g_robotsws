"""
Author:         Wu Fangmin
Contact Mail:   fangmin.wu@nokia-sbell.com
Description:    Emil log analysis
"""

import os
from subprocess import Popen, PIPE, STDOUT
from time import sleep
import shlex
import datetime


def Convert_Emil_log_to_txt(log_path, end_file):
    emil_path = 'C:\\Program Files\\Emil\\Emil.exe'
    emil_path = emil_path.encode('unicode_escape')
    profile_path = 'C:\\Program Files\\Emil\\profiles\\5G\\'
    profile_path = profile_path.encode('unicode_escape')
    log_path = str(log_path)
    log_path = log_path.encode('unicode_escape')
    file_name = 'emil_msg_output_' + \
        str(datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')) + '.txt'
    output_path = str(os.path.join(log_path, file_name))
    output_path = output_path.encode('unicode_escape')
    cmd = emil_path + " " + log_path + end_file + " -Profile SourceProfile.ini -ProfilePath " \
        + profile_path + " -AutoClose -Variable OutPath " + output_path
    print("cmd: ", cmd)
    po = Popen(shlex.split(cmd), stdout=PIPE, stderr=PIPE)
    output, error = po.communicate()
    po.terminate()
    output_path = output_path.decode('unicode_escape')
    return output_path


def Covert_Emil_log_to_txt_with_scrambled(log_path, end_file):
    emil_path = get_emil_windows_path()
    emil_path = emil_path.encode('unicode_escape')
    profile_path = get_emil_profiles_path()
    profile_path = profile_path.encode('unicode_escape')
    log_path = str(log_path)
    log_path = log_path.encode('unicode_escape')
    file_name = 'emil_msg_output_' + \
        str(datetime.datetime.now().strftime(
            '%Y-%m-%d_%H-%M-%S')) + '_scrambled' + '.txt'
    output_path = str(os.path.join(log_path, file_name))
    output_path = output_path.encode('unicode_escape')
    cmd_scramble = emil_path + " " + log_path + end_file + " -Scramble -AutoClose"
    print("cmd: ", cmd_scramble)
    spo = Popen(shlex.split(cmd_scramble), stdout=PIPE, stderr=PIPE)
    output, error = spo.communicate()
    spo.terminate()
    cmd = emil_path + " " + log_path + "*scrambled.emil" + " -Profile SourceProfile.ini -ProfilePath " \
        + profile_path + " -AutoClose -Variable OutPath " + output_path
    print("cmd: ", cmd)
    po = Popen(shlex.split(cmd), stdout=PIPE, stderr=PIPE)
    output, error = po.communicate()
    po.terminate()
    output_path = output_path.decode('unicode_escape')
    return output_path


def get_emil_msg_parameter_value(file_path, msg_name, para_name):
    fh = open(file_path)
    output = fh.readlines()
    para_value = "None"
    for i in range(len(output)):
        line = output[i].strip('\n')
        if line.find(msg_name) == -1:
            continue
        for j in range(i + 1, len(output)):
            line = output[j].strip('\n')
            index = line.find(para_name)
            if index == -1:
                continue
            para_value = line.lstrip(para_name + ": ")
            if para_value == '"0.0.0.0"':
                continue
            if para_value == '"::"':
                continue
            break
        break
    fh.close()
    return para_value


def get_emil_windows_path():
    possible_paths = ['C:\\Program Files\\Emil']
    for path in possible_paths:
        path = os.path.join(path, 'Emil', 'Emil.exe')
        if os.path.exists(path):
            return path
    raise AssertionError("Emil.exe is not found please check")


def get_emil_profiles_path():
    possible_paths = ['C:\\Program Files']
    for path in possible_paths:
        path = os.path.join(path, 'Emil', 'profiles', "5G")
        if os.path.exists(path):
            return path
    raise AssertionError("profiles is not found please check")
