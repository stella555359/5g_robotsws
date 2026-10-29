# -*- coding: utf-8 -*
"""

"""
import xlrd
import csv


def analysis_viavi_log_to_tp(file_path, tp_name='UL-SCH throughput(kbps)', target_begin_time='10:22:13:141',
                             target_end_time='10:26:21:141', during='300', target_ul_tp=None, target_dl_tp=None):
    with open(file_path, 'r') as csv_file:
        reader = list(csv.reader(csv_file))
    start_index = 0
    for item in reader:
        if len(item) == 0:
            continue
        if item[0] == '#State':
            start_index = reader.index(item)
            break
    new_reader = reader[start_index:]
    print(len(new_reader))
    for item in new_reader:
        if len(item) < 13:
            new_reader.remove(item)
    print(len(new_reader))
    time_column = new_reader[0].index('Time')
    tp_column = new_reader[0].index(tp_name)
    cell_column = new_reader[0].index('Cell ID')
    time_list = []
    tp_list = []
    for item in new_reader[1:]:
        # print (type(item[cell_column]))
        if item[cell_column] != '50':
            new_reader.remove(item)
    for item in new_reader[1:]:
        time_list.append(item[time_column])
        tp_list.append(item[tp_column])
    print(time_list)
    print(tp_list)
    finally_tp = caculate_tp_according_time(time_list, tp_list, target_begin_time, target_end_time, during)
    return finally_tp


def caculate_tp_according_time(time_list, tp_list, target_begin_time, target_end_time, during):
    tp_sum = len(tp_list)
    start_time_index = 0
    end_time_index = 0
    for time in time_list:
        if target_begin_time in time:
            start_time_index = time_list.index(time)
            print(start_time_index)
        if target_end_time in time:
            end_time_index = time_list.index(time)
            print(end_time_index)
    print('########')
    if start_time_index == 0 and end_time_index == 0:
        finally_tp = 0
        print(finally_tp)
    else:
        if end_time_index == 0 and start_time_index != 0:
            end_time_index = len(time_list)-2
        end_time_index = end_time_index + 1
        # print(end_time_index)
        new_tp_list = tp_list[start_time_index: end_time_index]
        tp_length = len(new_tp_list)
        tp_sum = 0.0
        for item in new_tp_list:
            tp_sum = float(tp_sum) + float(item)
        average = float(tp_sum)/float(tp_length)
        print(tp_sum)
        print(tp_length)
        print(average)
        finally_tp = average * float(during) * 1000.0 / 8.0
        print(finally_tp)
    return finally_tp
