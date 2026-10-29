# -*- coding: utf-8 -*
import re
import linecache
from xml.dom.minidom import parse
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

gNB_ip = str(tl.gnbs[0].dus[0].f1_m_ip_addr)


def Covert_BTS_Version(version, gnbnumber):
    package = version.split('_')[2]
    if package == '9999':
        if gnbnumber == 1:
            scf_name = 'SCF_Trunk_gNB1.xml'
        elif gnbnumber == 0:
            scf_name = 'SCF_Trunk_enb.xml'
        else:
            scf_name = 'SCF_Trunk_gNB2.xml'
    elif package == '0000':
        if gnbnumber == 2:
            scf_name = 'SCF_SBTS22R1_gNB2.xml'
        elif gnbnumber == 0:
            scf_name = 'SCF_Trunk_enb.xml'
        else:
            scf_name = 'SCF_SBTS22R1_gNB1.xml'
    return scf_name


def return_structure_value(input_list, modify_list, keywords_list):
    output_dict_list = []
    for i in range(len(keywords_list)):
        for item_dict in input_list:
            if keywords_list[i] == item_dict['distName'].split('/')[-1]:
                output_dict = {}
                parameters_value = item_dict['parameters']
                modify_parameter = modify_list[i]['parameter']
                structure_value = parameters_value[modify_parameter]
                new_value = modify_list[i]['value']
                output_list = modify_structure_value(structure_value, new_value)
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
