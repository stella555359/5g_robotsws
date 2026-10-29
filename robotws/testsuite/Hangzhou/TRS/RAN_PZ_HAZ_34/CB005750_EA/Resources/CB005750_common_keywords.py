# -*- coding: utf-8 -*
import re
import linecache
from xml.dom.minidom import parse
import os
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


def check_parameter_value_in_btslog_file(input_content, keyword, except_value):
    for i in input_content.split(','):
        if keyword in i:
            value = re.findall(r'\d+\.?\d+', i)
            if abs(float(value[0])) < float(except_value):
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


def check_total_syncSourceInfo_if_right(input_list):
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


def Get_Dist_Name(input_list):
    dist_name_list = []
    for input_dict in input_list:
        dist_name_list.append(input_dict['distName'])
    for dist_name in dist_name_list:
        if 'SYNC_CONF_M-1' in dist_name:
            return dist_name


def Covert_BTS_Version(version):
    package = version.split('_')[0]
    if package == 'SBTS22R1':
        scf_name = 'SCF_SBTS22R1.xml'
    elif package == 'SBTS21B':
        scf_name = 'SCF_SBTS21B.xml'
    else:
        scf_name = 'SCF_SBTS00.xml'
    return scf_name


def Get_File_And_Dir(root_path):
    dir_list = []
    for i in os.listdir(root_path):
        abs_path = os.path.join(root_path, i)
        if os.path.isdir(abs_path):
            dir_list.append(abs_path)
    return dir_list


def Judge_List_Is_Change(input_list1, input_list2):
    for i in input_list2:
        if i not in input_list1:
            return False
    return True


def Modify_Structure_Value(input_list, new_value, index):
    input_dict = input_list[int(index)]
    for keys in new_value.keys():
        input_dict[keys] = new_value[keys]
    for keys in input_dict.keys():
        if input_dict[keys] is None:
            del input_dict[keys]
    return input_dict


def Return_Structure_Mofify_Value(input_list, modify_list, keywords_list, index):
    output_dict_list = []
    structure_value_tmp = []
    for i in range(len(keywords_list)):
        for item_dict in input_list:
            if keywords_list[i] in item_dict['distName']:
                output_dict = {}
                parameters_value = item_dict['parameters']
                modify_parameter = modify_list[i]['parameter']
                structure_value = parameters_value[modify_parameter]
                vartype = isinstance(structure_value, dict)
                if vartype is True:
                    structure_value_tmp.append(structure_value)
                    structure_value = structure_value_tmp
                new_value = modify_list[i]['value']
                output_dict['dist_name'] = modify_list[i]['dist_name']
                output_dict['parameter'] = modify_list[i]['parameter']
                output_valuelist = []
                for j in index:
                    output_list = Modify_Structure_Value(structure_value, new_value[j], j)
                    output_valuelist.append(output_list)
                output_dict['value'] = output_valuelist
                output_dict_list.append(output_dict)
                output_dict['value'] = output_valuelist
    return output_dict_list
