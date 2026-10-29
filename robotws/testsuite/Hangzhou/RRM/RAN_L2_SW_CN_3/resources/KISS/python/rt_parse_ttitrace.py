# -*- coding: UTF-8 -*-
# author : zhangwenchao
# version: 1.0

import csv
import re


def _reader_csv(filename):
    lists = []
    with open(filename, 'r') as file:
        datas = csv.reader(file)
        for Row_of_date in datas:
            lists.append(Row_of_date)
        lists = lists[1:]
        return lists


def _list_transpose(lists):
    return map(list, zip(*lists))


def _convert_list_to_dict(lists):
    dicts = {}
    temp_dict = {}
    for num, value in enumerate(lists[1:], 1):
        temp_dict[num] = value
    dicts[lists[0]] = temp_dict
    return dicts


def rt_get_element_index_from_ttitrace(listed, element_name):
    return listed[0].index(element_name)


def rt_filter_listed_via_condition(listed, element_name, condition, string):
    """ This keyword is used to get the list of not equal to string no_equal of colnum_index.
        Example:
       | rt_filter_listed_via_condition | /TA/zhangwenchao/_20161114024040_1231_dl.csv |
       ETtiTraceUlParUe_rrmScheduleTag | '!=' | '-' |
    """
    new_list = []
    Row_Number = 0
    colnum_index = rt_get_element_index_from_ttitrace(listed, element_name)
    for Row_of_date in listed:
        try:
            if Row_Number < 1:
                new_list.append(Row_of_date)
            elif (condition == '==' and (re.match(string, Row_of_date[colnum_index]) is not None)):
                new_list.append(Row_of_date)
            elif (condition == '!=' and (re.match(string, Row_of_date[colnum_index]) is None)):
                new_list.append(Row_of_date)
            elif (condition == '>' and Row_of_date[colnum_index] != '-' and int(Row_of_date[colnum_index]) > int(
                    string)):
                new_list.append(Row_of_date)
            elif (condition == '>=' and Row_of_date[colnum_index] != '-' and int(Row_of_date[colnum_index]) >= int(
                    string)):
                new_list.append(Row_of_date)
            elif (condition == '<' and Row_of_date[colnum_index] != '-' and int(Row_of_date[colnum_index]) < int(
                    string)):
                new_list.append(Row_of_date)
            elif (condition == '<=' and Row_of_date[colnum_index] != '-' and int(Row_of_date[colnum_index]) <= int(
                    string)):
                new_list.append(Row_of_date)
            Row_Number = Row_Number + 1
        except TypeError:
            print('TypeError')
    return new_list


def _iscondition_sysbol(text):
    if '==' in text:
        return text.split('==')[0], '==', text.split('==')[1]
    elif '!=' in text:
        return text.split('!=')[0], '!=', text.split('!=')[1]
    elif '>=' in text:
        return text.split('>=')[0], '>=', text.split('>=')[1]
    elif '<=' in text:
        return text.split('<=')[0], '<=', text.split('<=')[1]
    elif '>' in text and '='not in text:
        return text.split('>')[0], '>', text.split('>')[1]
    elif '<' in text and '=' not in text:
        return text.split('<')[0], '<', text.split('<')[1]
    else:
        raise _conditionerror()


def _conditionerror():
    print('condition is invalid !')


def rt_multi_condition_filter_from_list(listed, *arg):
    """
     Example:
       rt_multi_condition_filter_from_list(listed, 'ETtiTraceDlParUe_crnti==2631',
       'ETtiTraceDlParUe_averTbSize>=5000000')
    """
    for key in arg:
        element_name = _iscondition_sysbol(key)[0]
        condition = _iscondition_sysbol(key)[1]
        string = _iscondition_sysbol(key)[2]
        listed = rt_filter_listed_via_condition(listed, element_name, condition, string)
    return listed


def rt_ttitrace_convert_dict(filename, *arg):
    listed = _reader_csv(filename)
    if arg:
        listed = rt_multi_condition_filter_from_list(listed, *arg)
    else:
        pass
    new_listed = _list_transpose(listed)
    dict = {}
    for lists in new_listed:
        temp_dict = _convert_list_to_dict(lists)
        for key, value in temp_dict.items():
            dict[key] = value
    return dict


def has_exists_value_in_ttitrace_filename(filename, parameter, value):
    listed = rt_ttitrace_convert_dict(filename)[parameter].values()
    if value in listed:
        return True
    else:
        raise "{} is not exists of {} in ttitrace {}".format(value, parameter, filename)


if __name__ == "__main__":
    rt_ttitrace_convert_dict(filename)
    pass
