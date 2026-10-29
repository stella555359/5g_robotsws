# -*- coding: utf-8 -*
import re
import os


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


def Check_Value_From_Tcpdump(txt, para):
    with open(txt, 'r') as file:
        for line in file.readlines():
            if line.lstrip().startswith(para):
                value = line.split(':')[-1].strip()
                return value
    file.close()


def Count_Info_Frequency(txt, Info):
    count = 0
    with open(txt, 'r') as file:
        for line in file.readlines():
            if Info in line:
                count = count + 1
    file.close()
    return count


def Check_Info_Count(value1, value2, exp_count):
    if exp_count == 0:
        if value1 > 0 and value2 > 0:
            return True
        else:
            return False
    else:
        if value1 == exp_count and value2 == exp_count:
            return True
        else:
            return False


def Sum_list_value(input_list1, input_list2, exp_sum):
    list_sum1 = sum(input_list1)
    list_sum2 = sum(input_list2)
    if list_sum1 == exp_sum and list_sum2 == exp_sum:
        return True
    else:
        return False


def Get_Parameter_Value_From_Pcap(file, para_dict):
    result_dic = {}
    with open(file, 'r') as fl:
        fl_list = [line.lstrip() for line in fl]
    fl.close()
    for para in para_dict.keys():
        for line in fl_list:
            if line.startswith(para):
                tmp_index = fl_list.index(line)
                para_index = tmp_index + para_dict[para]
                new_line = fl_list[para_index]
                result = ''.join(re.findall(r'[A-Za-z0-9\-]', new_line.split(' ')[1]))
                result_dic[para] = result
                break
    return result_dic


def Get_Parameter_Line_Index(file, para_dict):
    with open(file, 'r') as fl:
        fl_list = [line.lstrip() for line in fl]
    fl.close()
    result_para_dict = {}
    for para_key in para_dict.keys():
        for line in fl_list:
            if line.startswith(para_key):
                line_index = fl_list.index(line)
                for i in range(line_index, len(fl_list)):
                    if fl_list[i].startswith(para_dict[para_key]):
                        result_para_dict[para_key] = i - line_index
                        break
    return result_para_dict


def Get_Infor_Count(txt, info):
    count = 0
    with open(txt, 'r') as fl:
        for line in fl.readlines():
            if line.lstrip().startswith(info):
                count = count + 1
    return count


def Get_Viavi_CSV_Log_Path(log_str):
    log_list = []
    replace_list = [[r'\\', r'/'], ["'", ""], ['C:', '/cygdrive/c'], [r'\r', '']]
    log = re.search('Current logging folder is .*', log_str).group()
    log = re.search('C:.*', log).group()
    for sub_list in replace_list:
        log = re.sub(sub_list[0], sub_list[1], log)
    dir_name = log.split(r'/')[-1]
    log_list = [log, dir_name]
    return log_list


def Covert_BTS_Version(version, gnbnumber):
    scf_name = ''
    package1 = version.split('_')[2]
    package2 = version.split('_')[0]
    if package1 == '9999':
        if str(gnbnumber) == '7002':
            scf_name = 'SCF_Trunk_gNB1.xml'
        else:
            scf_name = 'SCF_Trunk_gNB2.xml'
    elif package2 == 'SBTS22R1':
        if str(gnbnumber) == '7003':
            scf_name = 'SCF_SBTS22R1_gNB2.xml'
        else:
            scf_name = 'SCF_SBTS22R1_gNB1.xml'
    elif package2 == 'SBTS22R2':
        if str(gnbnumber) == '7003':
            scf_name = 'SCF_SBTS22R2_gNB2.xml'
        else:
            scf_name = 'SCF_SBTS22R2_gNB1.xml'
    return scf_name
