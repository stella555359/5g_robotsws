import re


def get_specify_values(list_of_text, dict_with_all_values, sequence_list, l1_pool_id, full_dict, pattern1, pattern2):
    for item in list_of_text:
        str_item = str(item)
        str_l1_sub_pool_id = str(re.findall('(?<=SubPoolId=).+?\\b', str_item)[0])
        parameter_value = check_number_of_data(str_item, pattern1, pattern2)
        dict_with_all_values, sequence_list = set_values_to_dict_and_list(parameter_value, l1_pool_id,
                                                                          str_l1_sub_pool_id, full_dict,
                                                                          dict_with_all_values, sequence_list)
    sequence_list = set(sequence_list)
    return dict_with_all_values, sequence_list


def check_number_of_data(str_item, pattern1, pattern2):
    parameter_value = re.findall(pattern1, str_item)
    number_of_data = len(parameter_value)
    if number_of_data != 5:
        parameter_value = re.findall(pattern2, str_item)
        number_of_data = len(parameter_value)
        if number_of_data != 5:
            raise Exception("Both patterns are wrong, check data construction from Sherpa and compare with regexp")
    elif number_of_data == 5:
        parameter_value = parameter_value
    return parameter_value


def set_values_to_dict_and_list(parameter_value, l1_pool_id, str_l1_sub_pool_id, full_dict, dict_with_all_values,
                                sequence_list):
    if parameter_value[1] == l1_pool_id and parameter_value[2] == str_l1_sub_pool_id:
        key_inside = str(int(parameter_value[3], 0))
        key_main = "id_" + str_l1_sub_pool_id
        full_dict[key_main][key_inside] = str(int(parameter_value[4], 0))
        dict_with_all_values[parameter_value[0]] = full_dict
        sequence_list.append(parameter_value[0])
    return dict_with_all_values, sequence_list
