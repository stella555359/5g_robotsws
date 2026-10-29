import re
import os


def get_cell_counter_value(counter_values, cellId,
                           measType, measId, epochTime):
    counter_id_all_value = counter_values['BTS']['CELLS'][cellId][measType][measId]
    counter_value_list = counter_id_all_value.values()
    return counter_value_list


def Find_Element_In_Wireshark(file_path, element):
    element_value_list = []
    with open(file_path, 'r') as file:
        for line in file.readlines():
            if element + ':' in line:
                tmp_emlement_value = re.findall(r'\d+', line)
                for value in tmp_emlement_value:
                    element_value_list.append(value)
    return element_value_list
