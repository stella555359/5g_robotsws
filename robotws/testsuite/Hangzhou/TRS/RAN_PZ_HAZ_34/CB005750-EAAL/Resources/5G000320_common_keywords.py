# -*- coding: utf-8 -*


def check_parameter_ns_in_btslog_file(input_content, parameter, expect_value):
    input_list = input_content.split(',')
    for i in input_list:
        if parameter in i:
            value = i.split(':')[-1].split(' ')[0]
            print (value)
            if abs(float(value)) < float(expect_value):
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


def Get_File_And_Dir(root_path):
    dir_list = []
    for i in os.listdir(root_path):
        abs_path = os.path.join(root_path, i)
        if os.path.isdir(abs_path):
            dir_list.append(abs_path)
    return dir_list


def Modify_Structure_Value(input_list, new_value, index):
    input_dict = input_list[int(index)]
    for keys in new_value.keys():
        input_dict[keys] = new_value[keys]
    for keys in input_dict.keys():
        if input_dict[keys] is None:
            del input_dict[keys]
    input_dict
    return input_dict


def Return_Structure_Mofify_Value(input_list, modify_list, keywords_list, index):
    output_dict_list = []
    for i in range(len(keywords_list)):
        for item_dict in input_list:
            if keywords_list[i] in item_dict['distName']:
                output_dict = {}
                parameters_value = item_dict['parameters']
                modify_parameter = modify_list[i]['parameter']
                structure_value = parameters_value[modify_parameter]
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


def Judge_List_Is_Change(input_list1, input_list2):
    for i in input_list2:
        if i not in input_list1:
            return False
    return True
