# -*- coding: utf-8 -*

"""
Author:         Wang Yixiang
Contact Mail:   yixiang.x.wang@nokia-sbell.com
Description:    Split string to list and convert list to string
example:
        '1,2,3,5' => ['1', '2', '3', '5']
        '1-5' => ['1', '2', '3', '4', '5']
"""


def string2list(input_str, skip_minus=False):
    if isinstance(input_str, list):
        return input_str, False
    input_str = str(input_str)
    input_str = input_str.strip()
    print(input_str)
    temp_list = []
    return_list = []
    range_style = False
    if ('-' in input_str) \
            and (',' not in input_str) \
            and (not skip_minus):
        new_temp_list = []
        temp_list = input_str.split('-')
        range_style = True
        if temp_list[0]:
            ue_range = int(temp_list[1]) - int(temp_list[0]) + 1
        else:
            new_temp_list.append('-'+str(int(temp_list[1])))
            return new_temp_list, range_style
        if ue_range <= 0:
            print('input parameter error: ', input_str)
            raise Exception('input parameter error')
        else:
            for item in range(0, ue_range):
                new_temp_list.append(str(int(temp_list[0]) + item))
            temp_list = new_temp_list
    elif ',' in input_str and '-' in input_str and (not skip_minus):
        temp_list = input_str.split(',')
        temp_range_list = []
        for tem_item in temp_list:
            if '-' in tem_item:
                temp_range_list += (string2list(tem_item))[0]
            else:
                temp_range_list.append(tem_item)
        temp_list = temp_range_list
    elif ',' in input_str and '-' not in input_str and (not skip_minus):
        temp_list = input_str.split(',')
    else:
        temp_list.append(input_str)
    for item in temp_list:
        return_list.append(item.strip())
    print("temp_list ", temp_list)
    print("return_list ", return_list)
    return return_list
