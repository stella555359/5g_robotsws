# -*- coding: utf-8 -*
"""
:copyright: Nokia Networks
:author: Wang kk/ Liu Jia-rebecca
:contact: kk.wang@nokia-sbell.com
:maintainer: Liu Jia-rebecca
:contact: jia-rebecca.liu@nokia-sbell.com
"""
import csv
import os
import json


def read_tti_csv(tti_file_path):
    with open(tti_file_path, 'r') as f:
        csv_reader = csv.reader(f)
        csv_list = list()
        for row in csv_reader:
            csv_list.append(row)
    f.close()
    return csv_list


def get_index(path, *name):
    csv_list = read_tti_csv(path)
    index_list = list()
    for i in name:
        index_name = csv_list[0].index(i)
        index_list.append(index_name)

    return index_list


def read_mumimo_rank2_paired(tti_file_path):
    csv_list = read_tti_csv(tti_file_path)
    mumimo_list = list()
    count = 0
    index_list = get_index(tti_file_path, 'sfn', 'slot', 'rnti', 'beamId', 'status', 'streamIndexList', 'ueGroupIdx')
    for each_list in csv_list:
        if each_list[0] == 'muMimoSchedData':
            mumimo_list.append(each_list)
    mumimo_list_number = int(len(mumimo_list))
    for start_index in range(mumimo_list_number-1):
        if mumimo_list[start_index][index_list[0]] == mumimo_list[start_index+1][index_list[0]] and \
                mumimo_list[start_index][index_list[1]] == mumimo_list[start_index+1][index_list[1]] and \
                mumimo_list[start_index][index_list[2]] != mumimo_list[start_index+1][index_list[2]] and \
                mumimo_list[start_index][index_list[3]] != mumimo_list[start_index+1][index_list[3]] and \
                mumimo_list[start_index][index_list[4]] == mumimo_list[start_index+1][index_list[4]] == 'PAIRED' and \
                mumimo_list[start_index][index_list[5]] in ['STREAMS_0_1_2_3'] and \
                mumimo_list[start_index+1][index_list[5]] in ['STREAMS_0_1_2_3'] and \
                mumimo_list[start_index][index_list[6]] in ['0', '1'] and \
                mumimo_list[start_index+1][index_list[6]] in ['0', '1']:
            count += 1

    return count


def read_cri_rate(tti_file_path, target_CRI):
    csv_list = read_tti_csv(tti_file_path)
    index_cri = get_index(tti_file_path, 'cri')
    csiSrReportData_list = list()
    cri_list = list()
    for each in csv_list:
        if each[0] == 'csiSrReportData':
            csiSrReportData_list.append(each)
    for each_value in csiSrReportData_list:
        cri_list.append(each_value[index_cri[0]])
    cri_list = [int(x) for x in cri_list]
    target_CRI = int(target_CRI)
    cri_total = int(len(cri_list))
    target_cri_num = cri_list.count(target_CRI)
    rate = float(target_cri_num) / float(cri_total)

    return rate


def read_json(path):
    file = open(path, "rb")
    filejson = json.load(file)
    elements = filejson["payload"]["complex_fixed16_vectors"]
    re_total = list()
    im_total = list()
    for each in elements:
        element_content = each["elements"]
        for each_r_i in element_content:
            re_value = each_r_i['re']
            im_value = each_r_i['im']
            re_total.append(re_value)
            im_total.append(im_value)
    return im_total, re_total


def read_beam_weight_size(path):
    im_re = read_json(path)
    im_re[0].sort()
    im_re[1].sort()
    max_im = im_re[0][len(im_re[0])-1]
    min_im = im_re[0][0]
    max_re = im_re[1][len(im_re[1]) - 1]
    min_re = im_re[1][0]
    return max_im, min_im, max_re, min_re


def read_statistics_result(getvalue, stavalue, rage):
    """
    this keyword to extract CDF/PDF values from the result of 'Get Statistics Result'

    :param getvalue: the output of Get_statistics_result.
    :param stavalue: "CQI" , "DLBler" or "ULBler"
    :param rage:  the default rage values from pioneer template. e.g.
        CQI default 'Rage': '(-INF,3]', '(3,6]', '(6,9]', '(9,12]', '(12,+INF)'
    :return: CDF & PDF
    """
    target = getvalue['Param'][stavalue]
    for each in target:
        print(each['Rage'])
        if each['Rage'] == rage:
            CDF = each['CDF']
            PDF = each['PDF']
    try:
        if CDF.strip():
            print(CDF, PDF)
    except UnboundLocalError as TS:
        raise AttributeError("rage must match with Dingli template")
    return CDF, PDF


def get_value(csv_file, filter_name):
    """
    as per filter name get all values per col
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :return: list_col_filter_name: list of all values under col filter name
             total_num_filter_value: total num of list_col_filter_name
    """
    list_col_filter_name = []
    with open(csv_file) as f:
        reader = csv.DictReader(f=f)
        for row in reader:
            if row[filter_name] != '':
                list_col_filter_name.append(int(float(row[filter_name])))
    total_num_filter_value = len(list_col_filter_name)
    return list_col_filter_name, total_num_filter_value


def count_required_value(csv_file, filter_name, count_value):
    """
    count per value num on list
    :param csv_file: csv file name
    :param filter_name: head of filter name
    :param count_value: parameter of required calculate num
    :return: rate: rate of count_value
    """
    rate = ''
    list_col_filter_name, total_num_filter_value = get_value(csv_file=csv_file, filter_name=filter_name)
    num_filter_value = list_col_filter_name.count(count_value)
    try:
        rate = round(num_filter_value / total_num_filter_value, 1)
    except ZeroDivisionError as e:
        print("total_num_filter_value equal 0, need to check {}".format(e))
    return rate
