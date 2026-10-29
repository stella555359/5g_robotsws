from collections import Counter


def get_index_of_header(path_to_trace, header_name):
    tti_trace = open(path_to_trace)
    table_of_lines = tti_trace.readlines()
    list_of_headers = table_of_lines[1].split(',')
    header_index = 0
    for header in list_of_headers:
        if header != header_name:
            header_index += 1
        else:
            break
    tti_trace.close()
    return header_index


def get_column_with_name(path_to_trace, header_name):
    tti_trace = open(path_to_trace)
    header_index = get_index_of_header(path_to_trace, header_name)
    position_line = 0
    column_with_name = []
    while True:
        line = tti_trace.readline()
        if not line:
            break
        splited_line = line.split(',')
        if position_line >= 2:
            if str(splited_line[header_index]) != '-':
                column_with_name.append(splited_line[header_index])
        position_line += 1
    tti_trace.close()
    return column_with_name


def get_unique_values_list(input_list):
    unique_list = []
    for x in input_list:
        if x not in unique_list:
            unique_list.append(x)
    return unique_list


def get_values_in_percents(input_list):
    list_all_occurances = []
    index_occurances = 0
    ue_indexes = get_unique_values_list(input_list)
    for ueindex in ue_indexes:
        index_occurances = input_list.count(ueindex)
        list_all_occurances.append(index_occurances)
    list_all_occurances.sort(reverse=True)
    first_ueIndex_couter = list_all_occurances[0]
    second_ueIndex_couter = list_all_occurances[1]
    all_values_counter = len(input_list)
    first_ueIndex_percents = int(round(first_ueIndex_couter * 100 / all_values_counter))
    second_ueIndex_percents = int(round(second_ueIndex_couter * 100 / all_values_counter))
    return first_ueIndex_percents, second_ueIndex_percents
