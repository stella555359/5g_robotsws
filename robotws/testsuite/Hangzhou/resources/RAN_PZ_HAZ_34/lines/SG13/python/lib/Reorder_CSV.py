'''
Author:Zhang Shuang
Function:reorder the columns of a csv file acording a given column list
'''
import csv
import sys
import os


def _read_csv_as_list(filename):
    with open(filename, 'r') as infile:
        list_reader = list(csv.DictReader(infile))
        # step 1: get initial key list
        list_key_ini = []
        for key in list_reader[0]:
            list_key_ini.append(key)
        #   print('ini_col:', list_key_ini)
        return list_reader, list_key_ini


def _output_filename(filename):
    output_filename = ''
    i = 0
    for str in filename:
        if filename[i:i + 4] == '.csv':     # get str before''.csv
            output_filename = filename[:i] + '_Reorder.csv'
            break
        i += 1
    if os.path.exists(output_filename):
        os.remove(output_filename)
    if output_filename:
        return output_filename
    else:
        print('err name')


def _write_list_to_csv(filename, new_col, list_reader):
    output_filename = _output_filename(filename)
    with open(output_filename, 'a', encoding='utf8', newline='') as outfile:
        writer = csv.DictWriter(
            outfile, fieldnames=new_col)  # reorder as reorder_col
        writer.writeheader()
        for row in list_reader:
            writer.writerow(row)


def _new_col(list_key, _front_col):
    # get new column list
    # print('\n==front:', _front_col)
    _front_col_cp = _front_col.copy()
    for i in _front_col_cp:
        if i not in list_key:
            print('WRN:No item in tti:', i)
            _front_col.remove(i)
            # raise Exception('No item in tti:', i)

    list_key_1 = list_key.copy()
    # remove front element from old list_key
    for key in list_key:
        if key in _front_col:
            list_key_1.remove(key)

    # insert front element to list_key front
    insert_pos = 4
    len_front = len(_front_col)
    for key in _front_col[::-1]:
        list_key_1.insert(insert_pos, key)
    # print('\n==new_key:', list_key_1)
    return list_key_1


def reorder_csv(filename, front_col):
    list_reader, list_key = _read_csv_as_list(filename)
    new_col = _new_col(list_key, front_col)
    _write_list_to_csv(filename, new_col, list_reader)
