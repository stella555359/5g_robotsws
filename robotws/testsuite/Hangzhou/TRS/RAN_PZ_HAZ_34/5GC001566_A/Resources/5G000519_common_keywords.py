# -*- coding: utf-8 -*
import re
import os
import linecache
from robot.libraries.BuiltIn import BuiltIn
import xml.dom.minidom


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


def Get_Different_Package_Time(file_path_list):
    count_list = []
    for file_path in file_path_list:
        count = 0
        pattern = re.compile(r'Frame (.*) bytes on wire')
        with open(file_path, 'r') as file:
            for line in file.readlines():
                if re.search(pattern, line):
                    count = count + 1
        count_list.append(count)
    return count_list


def Modify_GNB_SCF(file_path, save_path, input_list):
    doc = xml.dom.minidom.parse(file_path)
    root = doc.documentElement
    cmdDataNode = root.getElementsByTagName('cmData')[0]
    manObjs = root.getElementsByTagName('managedObject')
    for i in range(len(input_list)):
        dist_name = input_list[i]['dist_name']
        p_name = input_list[i]['p_name']
        value = input_list[i]['value']
        for manObj in manObjs:
            if manObj.getAttribute('distName') == dist_name:
                listNode = manObj.getElementsByTagName('p')
                for node in listNode:
                    if node.getAttribute('name') == p_name:
                        n = node.childNodes[0]
                        n.data = value
    with open(save_path, 'w') as file:
        doc.writexml(file, encoding='UTF-8')
    return save_path


def Calculation_Different_Package_Ratio(input_list, value):
    total = input_list[0] + input_list[1]
    ratio = float(input_list[1])/float(total)*100
    if ratio >= float(value):
        return True
    else:
        return False


def Check_TRS_Counter_Value(input_number, drop_number, max):
    difference_value = float(input_number)/float(drop_number)*100
    if difference_value > int(max):
        return True
    else:
        return False


def Modify_Structure_Value(input_list, new_value, index):
    output_list = []
    input_dict = input_list[int(index)]
    for keys in new_value.keys():
        input_dict[keys] = new_value[keys]
    for keys in input_dict.keys():
        if input_dict[keys] is None:
            del input_dict[keys]
    output_list.append(input_dict)
    return output_list


def Return_Structure_Mofify_Value(input_list, modify_list, keywords_list, index):
    output_dict_list = []
    for i in range(len(keywords_list)):
        for item_dict in input_list:
            if keywords_list[i] == item_dict['distName'].split('/')[-1]:
                output_dict = {}
                parameters_value = item_dict['parameters']
                modify_parameter = modify_list[i]['parameter']
                structure_value = parameters_value[modify_parameter]
                new_value = modify_list[i]['value']
                output_list = Modify_Structure_Value(structure_value, new_value, index)
                output_dict['dist_name'] = modify_list[i]['dist_name']
                output_dict['parameter'] = modify_list[i]['parameter']
                output_dict['value'] = output_list
                output_dict_list.append(output_dict)
    return output_dict_list


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


def Parsing_Mac_Counters_File(file_path_list):
    counter_list = []
    for file_path in file_path_list:
        with open(file_path, 'r') as file:
            for line in file.readlines():
                if 'Size 128 to 255' in line:
                    counter_package_number = Get_Number_And_Ip_In_String(line)[-1]
                    counter_list.append(counter_package_number)
    drop_package_number = int(counter_list[1]) - int(counter_list[0])
    return drop_package_number
