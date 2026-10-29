# -*- coding: utf-8 -*

"""
Author:         Liu Zheng
Contact Mail:   zheng.4.liu@nokia-sbell.com
Description:    get 4G DL and UL throughput average value

"""
import re


def get_dl_throughput_for_each_cell(tput_file):
    dict_tput = {}
    with open(tput_file) as f:
        file_list = list(f.readlines())
    f.close()
    cell_list = list(set([line.split(";")[0] for line in file_list if re.match(r'\d+', line)]))
    for cell_id in cell_list:
        cell_tp_list = []
        tput_keys = 'cell' + cell_id + '_details'
        cell_average_tp = 'cell' + cell_id + '_average_tp'
        for line in file_list:
            if line.split(';')[0] == cell_id:
                cell_tp_list.append(float(line.split(';')[1]))
        dict_tput[tput_keys] = cell_tp_list
        dict_tput[cell_average_tp] = format(sum(cell_tp_list) / len(cell_tp_list), '.3f')
    return dict_tput


def get_ul_throughput_for_each_cell(tput_file):
    cell1_tp_list = []
    dict_tput = {}
    with open(tput_file) as f:
        lines = f.readlines()
        for line in lines:
            if line.startswith("sep") or line.startswith("cell"):
                continue
            (cell, tp) = line.split(";")
            if cell == '1':
                cell1_tp_list.append(float(tp))
            else:
                raise Exception('cell named as"%s" exist in this env. please check the configuration of ENB' % cell)
    dict_tput['cell1_details'] = cell1_tp_list
    cell1_average_tp = format(sum(cell1_tp_list) / len(cell1_tp_list), '.3f')
    dict_tput['cell1_average_tp'] = cell1_average_tp
    return dict_tput


def analysis_dl_data_from_aasyslog(log_path):
    result_list = []
    with open(log_path) as f:
        data = f.readlines()
        pattern = re.compile(r'DataPdu:(.+)')
        for line in data:
            if re.search(pattern, line):
                result = re.search(pattern, line).group(1)
                dl_data = result.split('|')
                result_list.append(dl_data[-1].split(']')[0])
    result_string = '\r\n'.join(result_list)
    return result_string
