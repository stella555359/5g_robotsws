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


def Get_csv_is_exsit(input_list):
    return_list = []
    for i in input_list:
        if len(i) != 0:
            if 'L1DLSTATS' in i and i.split('.')[-1] == 'csv':
                return_list.append(i)
            elif 'L1ULSTATS' in i and i.split('.')[-1] == 'csv':
                return_list.append(i)
    return return_list


def Get_Each_Frame_Info(log_path):
    file = open(log_path, 'r')
    line_list = [line for line in file.readlines()]
    index_list = []
    frame_list = []
    all_frame_list = []
    for i in range(0, len(line_list)):
        if line_list[i].startswith('Frame '):
            index_list.append(i)
    for i in range(0, len(index_list)):
        if i != len(index_list) - 1:
            tmp_list = line_list[index_list[i]: index_list[i + 1] - 1]
        else:
            tmp_list = line_list[index_list[i]: len(line_list)]
        frame_list.append(tmp_list)
    for sub_list in frame_list:
        tmp_list1 = [line.lstrip(' ').strip('\n') for line in sub_list]
        all_frame_list.append(tmp_list1)
    return all_frame_list


def Check_Signalling_Info_order(frame_list, except_value_list):
    start_index = 0
    for value in except_value_list:
        tmp_index = start_index
        for j in range(start_index, len(frame_list)):
            sub_frame_list = frame_list[j]
            if value in sub_frame_list:
                start_index = j + 1
                print(start_index)
                break
        if tmp_index == start_index:
            print(value)
            raise Exception("except_value not in tcpdump info")
            return False
    return True


def Check_tcpdump_signal_order(log_path, except_value_list):
    frame_list = Get_Each_Frame_Info(log_path=log_path)
    result = Check_Signalling_Info_order(frame_list=frame_list, except_value_list=except_value_list)
    return result


def Get_measId_value(log_path, except_measId_list):
    frame_list = Get_Each_Frame_Info(log_path)
    measId_list = []
    measurementReport_list = [sub_list for sub_list in frame_list if 'measurementReport' in sub_list]
    for sub_list in measurementReport_list:
        for i in sub_list:
            if 'measId:' in i:
                measId_list.append(int(i.split(':')[-1]))
    print(measId_list)
    if except_measId_list == measId_list:
        return True
    else:
        raise Exception("actual measId list not euqal as except measId list")
        return False


def Check_measId_Info(log_path, check_message_list, index, check_message='rrcReconfiguration'):
    rrc_index = []
    message_list = []
    message_dict = {}
    frame_list = Get_Each_Frame_Info(log_path=log_path)
    start_index = [i for i in range(0, len(frame_list)) if 'measurementReport' in frame_list[i]]
    for i in range(0, len(start_index)):
        if i != len(start_index) - 1:
            for j in range(start_index[i], start_index[i + 1]):
                if check_message in frame_list[j]:
                    rrc_index.append(j)
        else:
            for j in range(start_index[i], len(frame_list)):
                if check_message in frame_list[j]:
                    rrc_index.append(j)
                    break
    end_index = rrc_index[index]
    for message in check_message_list:
        for line in frame_list[end_index]:
            if message in line:
                message_list.append(line.lower())
    index_list = [j for j in range(0, len(message_list)) if 'measid:' not in message_list[j]]
    for j in index_list:
        if j == 0:
            message_dict[message_list[j].split(':')[0]] = [message_list[i].split(':')[-1].strip(' ') for i in
                                                           range(j + 1, index_list[1])]
        else:
            message_dict[message_list[j].split(':')[0]] = [message_list[i].split(':')[-1].strip(' ') for i in
                                                           range(j + 1, len(message_list))]
    return message_dict


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
