#  -*- coding: utf-8 -*-
import re
import linecache
from xml.dom.minidom import parse
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

gNB_ip = str(tl.gnbs[0].dus[0].f1_m_ip_addr)


def check_parameter_value_in_btslog_file(input_content, keyword, except_value):
    for i in input_content.split(','):
        if keyword in i:
            value = re.findall(r'\d+\.?\d+', i)
            print (value)
            if abs(float(value[0])) < float(except_value):
                return True
            else:
                return False


def check_syncSourceInfo_if_right(input_list):
    key_list = ['isActive', 'status', 'syncInputPrio']
    topp_list = []
    other_list = []
    total_list = []
    for syncSourceInfo_dic in input_list:
        if syncSourceInfo_dic['syncInputType'] == 'TOPP':
            for key in key_list:
                topp_list.append(syncSourceInfo_dic[key])
        else:
            for key in key_list:
                other_list.append(syncSourceInfo_dic[key])
    total_list.append(topp_list)
    total_list.append(other_list)
    return total_list


def check_active_alarms_faultId(faultId_list, faultId):
    if int(faultId) in faultId_list:
        return True
    else:
        return False


def get_active_alarms_faultId(alarms_list, keyword):
    fault_id_list = []
    for alarms in alarms_list:
        fault_id_list.append(alarms[keyword])
    return fault_id_list


def check_relation_error(input_list, excpect_list):
    for i in excpect_list:
        if i not in input_list:
            return True
        else:
            return False


def Covert_BTS_Version(version):
    package = version.split('_')[-2]
    package_21B = version.split('_')[-3]
    if package == '000400':
        scf_name = 'SCF_0.400_DU.xml'
    elif package == '001100':
        scf_name = 'SCF_10.1100_DU.xml'
    if package_21B == '0012':
        scf_name = 'SCF_12.400_DU.xml'
    return scf_name


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


def get_pmtu(output_str):
    pattern = re.compile(r'Resume: pmtu (\w+)')
    result = re.search(pattern, output_str)
    return result.group(1)


def swith_number_to_16(list):
    for i in range(0, len(list)):
        list[i] = str(int(list[i], 16))
    return list


def Get_line_message(file_path):
    file = open(file_path, 'r')
    line_list = [line.strip('\n') for line in file.readlines()]
    for line in line_list:
        if 'Estimator output' in line:
            return line
    return None
    file.close()
