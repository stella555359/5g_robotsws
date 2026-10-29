"""
Author:         Han Ruiyu
Contact Mail:   ruiyu.han@nokia-sbell.com
Description:    Emil log analysis
"""

import os
from subprocess import Popen, PIPE, STDOUT
import shlex
import datetime
import re


def output_emil_log_info_to_txt(log_path, end_file):
    emil_path = get_emil_windows_path()
    profile_path = get_emil_profiles_path()
    file_name = 'emil_msg_output_' + \
        str(datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')) + '.txt'
    output_path = os.path.join(log_path, file_name)
    output_path = output_path.replace("\\", "\\\\")
    cmd = "\"" + emil_path + "\"" + " " + "\"" + os.path.join(log_path, end_file) + "\""\
          + " -Profile SourceProfileUser.ini -ProfilePath " \
          + "\"" + profile_path + "\"" + \
        " -AutoClose -Variable OutPath " + "\"" + output_path + "\""
    cmd = cmd.replace("\\", "\\\\")
    print("cmd: ", cmd)
    Po = Popen(shlex.split(cmd), stdout=PIPE, stderr=PIPE)
    output, error = Po.communicate()
    print("output: ", output)
    print("error: ", error)
    Po.terminate()
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
            break
        try:
            assert index != -1
        except Exception:
            raise Exception(
                "file cannot find msg_param:%s in msg_name:%s!" % (para_name, msg_name))
        break
    fh.close()
    return para_value


def check_emil_syscom_msg_name_existing(file_path, msg_name):
    with open(file_path)as f:
        # file_lines = f.readlines()
        file_context = f.read()
        # for line in file_lines:
        #     if line.find(msg_name) >= 0:
        #         return line
        #         break
        # Emil context is with upper while node id is with lower
        file_context_lower = file_context.lower()
        try:
            assert file_context_lower.find(msg_name) >= 0
        except Exception:
            raise Exception("file cannot find msg_name:%s!" % msg_name)


def check_emil_msg_name_existing(file_path, msg_name):
    with open(file_path)as f:
        # file_lines = f.readlines()
        file_context = f.read()
        # for line in file_lines:
        #     if line.find(msg_name) >= 0:
        #         return line
        #         break
        try:
            assert file_context.find(msg_name) >= 0
        except Exception:
            raise Exception("file cannot find msg_name:%s!" % msg_name)


def check_emil_msg_param_existing(file_path, msg_name, msg_param):
    fh = open(file_path)
    output = fh.readlines()
    for i in range(len(output)):
        line = output[i].strip('\n')
        if line.find(msg_name) == -1:
            continue
        for j in range(i + 1, len(output)):
            line = output[j].strip('\n')
            index = line.find(msg_param)
            if index == -1:
                continue
            break
        try:
            assert index != -1
        except Exception:
            raise Exception(
                "file cannot find msg_param:%s in msg_name:%s!" % (msg_param, msg_name))
        break
    fh.close()


def get_emil_windows_path():
    possible_paths = ['C:\\tool', 'C:\\Program Files']
    for path in possible_paths:
        path = os.path.join(path, 'Emil', 'Emil.exe')
        if os.path.exists(path):
            return path
    raise AssertionError("Emil.exe is not found please check")


def get_emil_profiles_path():
    possible_paths = ['C:\\tool', 'C:\\Program Files']
    for path in possible_paths:
        path = os.path.join(path, 'Emil', 'profiles', "5G")
        if os.path.exists(path):
            return path
    raise AssertionError("profiles is not found please check")


def check_emil_msg_data_existing(file_path, boardcpu):
    with open(file_path)as f:
        file_lines = f.readlines()
        for line in file_lines:
            if line.find("0x00000000(0)") >= 0:
                index = line.find(":")
                line_cut = line[index+1:]
                p = re.compile(r'\s')
                data_list = p.split(line_cut)
                if data_list[8] == boardcpu[0] and data_list[9] == boardcpu[1]:
                    return line
                    break
    raise Exception("file cannot find boardcpu!")
