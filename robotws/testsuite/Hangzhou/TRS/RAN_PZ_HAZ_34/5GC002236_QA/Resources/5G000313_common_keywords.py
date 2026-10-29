# -*- coding: utf-8 -*
import re
import linecache
from xml.dom.minidom import parse
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

gNB_ip = str(tl.gnbs[0].dus[0].f1_m_ip_addr)


def class_list_function(input_list):
    output_list = []
    for i in range(0, len(input_list), 4):
        output_list.append(input_list[i: i + 4])
    return output_list


def get_time_index_list(input_list):
    output_list = []
    for i in range(0, len(input_list) - 1):
        if input_list[i] != input_list[i + 1]:
            output_list.append(i + 1)
    return output_list


def check_message_number_in_seconds(input_list, number):
    if len(input_list) == int(number):
        return True
    else:
        return False


def check_dscp_value(input_list, number):
    if number in input_list[0]:
        return True
    else:
        return False


def get_txt_content_by_line_index(file_path, message):
    count = len(open(file_path).readlines())
    fst_line_list = []
    time_line_list = []
    time_convert_list = []
    time_line_list_2 = []
    for i in range(0, count):
        fst_line = linecache.getline(file_path, i)
        if str(message) in fst_line:
            fst_line_list.append(i)
            if str(message) == 'control: Sync Message (0)':
                time_line = linecache.getline(file_path, i + 2).split(' ')[-1]
                time_line_list.append(int(time_line))
            elif str(message) == 'messageId: Announce Message':
                time_line = linecache.getline(file_path, i + 29).split(' ')[-1]
                time_line_list.append(int(time_line))
            elif str(message) == 'DSCP':
                if 'Src: ' + gNB_ip + ', Dst: 10.57.249.62' in linecache.getline(file_path, i - 3):
                    time_line = linecache.getline(file_path, i + 1)
                    time_line = Get_Number_And_Ip_In_String(time_line)[-1]
                    time_line_list.append(int(time_line))
    time_line_list.sort()
    for time_index in range(0, len(time_line_list) - 1):
        if time_line_list[time_index] != time_line_list[time_index + 1]:
            time_convert_list.append(time_index)
    if str(message) == 'control: Sync Message (0)':
        number = time_convert_list[2] - time_convert_list[1]
    elif str(message) == 'messageId: Announce Message':
        for i in time_line_list:
            if i != 0:
                time_line_list_2.append(i)
        number = time_line_list_2[1] - time_line_list_2[0]
    elif str(message) == 'DSCP':
        number = time_line_list[0]
    return number


def check_parameter_ppb_in_btslog_file(input_content, keyword):
    for i in input_content.split(','):
        if keyword in i:
            value = float(i.split(':')[-1].split(' ')[0])
    if abs(value) < float(20):
        return True
    else:
        return False


def check_parameter_ns_in_btslog_file(input_content):
    if 'source: ESelectedClockSource_Top' in input_content:
        return True
    else:
        return False


def get_active_alarms_faultId(alarms_list, keyword):
    fault_id_list = []
    for alarms in alarms_list:
        fault_id_list.append(alarms[keyword])
    return fault_id_list


def check_active_alarms_faultId(faultId_list, faultId):
    if int(faultId) in faultId_list:
        return True
    else:
        return False


def check_syncSourceInfo_if_right(input_list):
    key_list = ['isActive', 'status', 'syncInputPrio']
    topp_list = []
    for syncSourceInfo_dic in input_list:
        if syncSourceInfo_dic['syncInputType'] == 'TOPP':
            for key in key_list:
                topp_list.append(syncSourceInfo_dic[key])
    return topp_list


def check_value_scope(flag='0', number_list=None, except_number_list=None):
    count = 0
    for i in range(1, len(number_list)-1):
        if abs(number_list[i]) < int(except_number_list[i]):
            count = count + 1
    for m in [0, 4]:
        if flag == '0':
            if number_list[m] == int(except_number_list[m]):
                count = count + 1
        elif flag == '1':
            if number_list[m] < int(except_number_list[m]):
                count = count + 1
    if count == len(number_list):
        return True
    else:
        return False


def Get_Number_And_Ip_In_String(input_String):
    res = []
    temp = ''
    for item in input_String:
        if (ord(item) >= 48 and ord(item) <= 57) or item == '.':
            temp += item
        else:
            if len(temp) != 0:
                res.append(temp)
                temp = ''
    if len(temp) != 0:
        res.append(temp)
    return res


def Get_txt_file_content(file_path, content):
    line_list = []
    file = open(file_path, 'r')
    for line in file.readlines():
        if content in line:
            line_list.append(line)
    return line_list


def Read_XML_File(xml_path, check_list):
    miss_content_list = []
    file = open(xml_path, 'r')
    for line in file.readlines():
        for content in check_list:
            if content not in line:
                miss_content_list.append(content)
    return miss_content_list


def Covert_BTS_Version(version):
    package = version.split('_')[-2]
    package_21B = version.split('_')[-3]
    if package == '000400':
        scf_name = 'SCF_14.400_DU.xml'
    elif package == '001100':
        scf_name = 'SCF_10.1100_DU.xml'
    if package_21B == '0012':
        scf_name = 'SCF_12.400_DU.xml'
    return scf_name
