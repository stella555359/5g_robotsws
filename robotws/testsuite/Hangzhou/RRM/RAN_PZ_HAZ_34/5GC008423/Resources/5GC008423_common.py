# -*- coding: utf-8 -*
import re
import linecache
from xml.dom.minidom import parse
from robot.libraries.BuiltIn import BuiltIn
import os


def Covert_BTS_Version(version):
    package = version.split('_')[2]
    if package == '9999':
        scf_name = 'SCF_SBTS00.xml'
    else:
        package_version = version.split('_')[0]
        scf_name = 'SCF_' + package_version + '.xml'
    return scf_name


def get_value_from_biplog_divided_Frame(file_name, message="startSymbol (Uint8):"):
    file = open(file_name, 'r').readlines()
    pattern = re.compile(r'Frame (\d+)')
    index_list = []
    for file_line in file:
        if pattern.match(file_line) is not None:
            index = file.index(file_line)
            index_list.append(index)
    index_list.append(len(file))
    startSymbol_list = []
    startSymbol_sub_list = []
    for i in range(0, len(index_list)-1):
        start_index = i
        end_index = i + 1
        for j in range(index_list[start_index], index_list[end_index]):
            search_list = linecache.getline(file_name, j)
            if message in search_list:
                startSymbol_value = linecache.getline(file_name, j).split(':')[-1].strip()
                startSymbol_sub_list.append(startSymbol_value)
        startSymbol_list.append(startSymbol_sub_list)
        startSymbol_sub_list = []
    return startSymbol_list


def check_list_is_Periodic(list_name):
    flag = False
    null_list = []
    while null_list in list_name:
        list_name.remove(null_list)
    for i in range(4):
        if len(list_name)//4 > 1:
            for j in range(1, len(list_name)//4):
                if list_name[i] != list_name[i+j*4]:
                    flag = True
                    break
    if flag:
        raise Exception("list is not periodic")


def spilt_string(str):
    str_list = str.split()
    return str_list[0]


def get_update_or_skip_message(file_name, message):
    file = open(file_name)
    count = len(file.readlines())
    status_message_list = []
    for i in range(0, count):
        fst_line = linecache.getline(file_name, i)
        if str(message) in fst_line:
            meesage_line = linecache.getline(file_name, i).split(' ')
            for i in range(0, len(meesage_line)):
                if meesage_line[i] == message:
                    status_message = meesage_line[i+2]
                    status_message_list.append(status_message)
    status_message_list = list(set(status_message_list))
    file.close()
    return status_message_list
