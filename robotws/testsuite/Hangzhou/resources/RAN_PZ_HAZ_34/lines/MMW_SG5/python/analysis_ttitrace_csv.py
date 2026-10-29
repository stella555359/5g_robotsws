# -*- coding: utf-8 -*-
# @Time    : 2023/4/12 17:20
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : analysis_ttitrace_csv.py
# @Software: PyCharm
import zipfile
import csv
import os


def get_rrmslice_from_ttitrace(tti_zip, mcc_list, mnc_list, sst_list, sd_list):
    f = zipfile.ZipFile(tti_zip, 'r')
    dl_csvs = []
    for file in f.namelist():
        file_path = f.extract(file, os.path.dirname(tti_zip))
        if file_path.endswith("dl__all.csv"):
            dl_csvs.append(file_path)
    f.close()

    with open(dl_csvs[0], "r") as csv_file:
        reader = list(csv.reader(csv_file))
    mcc_col = 0
    mnc_col = 0
    sst_col = 0
    sd_col = 0
    rrmSliceAvgLowShare_col = 0
    for i in range(len(reader[0])):
        if reader[0][i] == "mcc":
            mcc_col = i
        elif reader[0][i] == "mnc":
            mnc_col = i
        elif reader[0][i] == "sst":
            sst_col = i
        elif reader[0][i] == "sd":
            sd_col = i
        elif reader[0][i] == "rrmSliceAvgLowShare":
            rrmSliceAvgLowShare_col = i

    slice_list = []
    for item in reader[1:]:
        if not item[0].startswith("dlSliceData"):
            continue
        mcc = item[mcc_col]
        mnc = item[mnc_col]
        sst = item[sst_col]
        sd = item[sd_col]
        rrmSliceAvgLowShare = item[rrmSliceAvgLowShare_col]
        for i in range(len(sst_list)):
            if sst == sst_list[i] and sd == sd_list[i] and mcc == mcc_list[i] and mnc == mnc_list[i]:
                slice_list.append(float(rrmSliceAvgLowShare))
        if len(sst_list) == len(slice_list):
            break
    print(slice_list)
    return slice_list
