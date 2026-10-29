import re
import linecache
from xml.dom.minidom import parse
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
gNB_ip = str(tl.gnbs[0].dus[0].f1_m_ip_addr)


def GET_lxc_active(file_path):
    with open(file_path, 'r') as f:
        data = f.readline()
        data_list = data.split(' ')
        return data_list[0]


def read_log_alarm(file_path, alarm_id):
    fp = open(file_path, 'r')
    read = fp.read()
    regex = re.compile(alarm_id)
    alarm_list = regex.findall(read)
    return alarm_list


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
