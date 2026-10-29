# -*- coding: utf-8 -*
import re
import os
import linecache
from robot.libraries.BuiltIn import BuiltIn
import xml.dom.minidom
tl = BuiltIn().get_variable_value('${tl}')

cPlaneDscp_dist_name = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id)
Dscp_dist_name = cPlaneDscp_dist_name + '/NRDRB-1'


def Covert_PcapFileName_To_TxtFileName(input_list):
    txt_list = []
    for i in input_list:
        txt_name = i.split('.')[0] + '.txt'
        txt_list.append(txt_name)
    return txt_list


def check_dscp_value(input_list, number):
    if number in input_list[0]:
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


def Get_DscpValue_By_Ip(file_path, src_ip, dst_ip):
    keywords = 'Src: ' + src_ip + ', Dst: ' + dst_ip
    count = len(open(file_path).readlines())
    for i in range(0, count):
        line = linecache.getline(file_path, i)
        if keywords in line:
            dscp_line = linecache.getline(file_path, i + 3)
            if 'DSCP' in dscp_line:
                dscp_value = linecache.getline(file_path, i + 4)
                digital_list = Get_Number_And_Ip_In_String(dscp_value)
                dscp_value = digital_list[-1]
                return dscp_value


def Get_IpAddress_In_Text(file_path, src_ip, dst_ip):
    keywords = 'Src: ' + src_ip + ', Dst: ' + dst_ip
    file = open(file_path, 'r')
    for line in file.readlines():
        if keywords in line:
            return True
    return False


def Get_F1_DscpValue(file_path, src_ip, dst_ip):
    pattern = re.compile(r'(.*)Frame Length: (.*) bytes (.*) bits')
    keywords = 'Src: ' + src_ip + ', Dst: ' + dst_ip
    count = len(open(file_path).readlines())
    for i in range(0, count):
        line = linecache.getline(file_path, i)
        if re.search(pattern, line):
            pac = re.search(pattern, line).group(3).strip('(')
            if int(pac) > 900 and int(pac) < 9000:
                keywords_line = linecache.getline(file_path, i + 15)
                if keywords in keywords_line and 'DSCP' in linecache.getline(file_path, i + 18):
                    dscp_value = linecache.getline(file_path, i + 19)
                    digital_list = Get_Number_And_Ip_In_String(dscp_value)
                    dscp_value = digital_list[-1]
                    return dscp_value
    return None


def Modify_eNB_DSCP_Value(input_dict, new_value):
    output_list = []
    input_dict['dscp'] = int(new_value)
    input_dict['prio'] = 70
    for keys in input_dict.keys():
        if input_dict[keys] is None:
            del input_dict[keys]
    output_list.append(input_dict)
    return output_list


def paramsFile(filePath, save_path, dscp_value, cPlanedscp_value):
    doc = xml.dom.minidom.parse(filePath)
    root = doc.documentElement
    cmdDataNode = root.getElementsByTagName('cmData')[0]
    manObjs = root.getElementsByTagName('managedObject')
    for manObj in manObjs:
        if manObj.getAttribute('distName') == cPlaneDscp_dist_name:
            listNode = manObj.getElementsByTagName('p')
            for node in listNode:
                if node.getAttribute('name') == 'cPlaneDscp':
                    n = node.childNodes[0]
                    n.data = cPlanedscp_value
        elif manObj.getAttribute('distName') == Dscp_dist_name:
            listNode = manObj.getElementsByTagName('p')
            for node in listNode:
                if node.getAttribute('name') == 'dscp':
                    n = node.childNodes[0]
                    n.data = dscp_value
    with open(save_path, 'w') as file:
        doc.writexml(file, encoding='UTF-8')
    return save_path


def Modify_dlDataSplitMode_Value(filePath, save_path, dlDataSplitMode_value):
    doc = xml.dom.minidom.parse(filePath)
    root = doc.documentElement
    manObjs = root.getElementsByTagName('managedObject')
    for manObj in manObjs:
        if manObj.getAttribute('distName') == Dscp_dist_name:
            listNode = manObj.getElementsByTagName('p')
            for node in listNode:
                if node.getAttribute('name') == 'dlDataSplitMode':
                    n = node.childNodes[0]
                    n.data = dlDataSplitMode_value
    with open(save_path, 'w') as file:
        doc.writexml(file, encoding='UTF-8')
    return save_path


def get_file_path(file_path):
    dir_path = os.path.dirname(file_path)
    return dir_path


def Parsing_Asslog(file_path, min_value, max_value):
    file = open(file_path, 'r')
    for line in file.readlines():
        if 'bytes/s' in line:
            digital_list = Get_Number_And_Ip_In_String(line)
            tran_rate = float(digital_list[-3])/131072
            if tran_rate > float(min_value) and tran_rate < float(max_value):
                return True
    return False
