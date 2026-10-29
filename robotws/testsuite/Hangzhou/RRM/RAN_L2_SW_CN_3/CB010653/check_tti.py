# -*- coding: utf-8 -*-
# @Time    : 2024/1/24 20:07
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : my_variable.py
# @Software: PyCharm
import subprocess
import pkgutil
import importlib
import math
import time
import datetime


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', 'numpy', package, '-i',
                         'https://artifactory-hz1.ext.net.nokia.com/artifactory/api/pypi/ta-lib-5g-virtual/simple'])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def is_pandas_installed():
    return bool(pkgutil.find_loader('pandas'))


def install_and_import_pandas():
    if not is_pandas_installed():
        install_package('pandas')
    return importlib.import_module('pandas')


def handle_txnumber(df):
    values = []
    for i in range(len(df)):
        if df.iloc[i]['txNumber'] > 1:
            # Find the previous row where rnti and dlHarqProcessIndex are equal and txNumber is 1
            for j in range(i-1, -1, -1):
                if df.iloc[j]['rnti'] == df.iloc[i]['rnti']:
                    if df.iloc[j]['dlHarqProcessIndex'] == df.iloc[i]['dlHarqProcessIndex']:
                        if df.iloc[j]['txNumber'] == 1:
                            values.append(df.iloc[j]['scheduledBytesPerBearer'])
                            break
    df.loc[df['txNumber'] > 1, 'scheduledBytesPerBearer'] = values
    return df


def parse_csv(file_path, columns, lcrId):
    pd = install_and_import_pandas()
    pd.set_option('display.max_columns', None)
    pd.set_option('display.max_colwidth', None)
    pd.set_option('display.width', None)
    data = pd.read_csv(file_path, usecols=columns)
    data = data.dropna()
    data = data.rename(columns={"dlFdSchedData.txNumber": "txNumber"})
    data = data.rename(columns={"dlFdSchedData.dlHarqProcessIndex": "dlHarqProcessIndex"})
    data = data.rename(columns={"dlFdSchedData.muStatus": "muStatus"})
    data = data.rename(columns={"dlFdSchedData.numOfLayers": "numOfLayers"})
    data = data.rename(columns={"dlFdSchedData.tbSize": "tbSize"})
    data = data.rename(columns={"dlFdSchedData.rat0Bitmap": "rat0Bitmap"})
    data = data.rename(columns={"dlFdSchedData.scheduledBytesPerBearer[4]": "scheduledBytesPerBearer"})
    if 'dlFdSchedData.scheduledBytesPerBearer[5]' in data.columns:
        data = data.rename(columns={"dlFdSchedData.scheduledBytesPerBearer[5]": "scheduledBytesPerBearer2"})
    data = data.query('muStatus == "MUPAIR"')
    data = data.query('lcrId == @lcrId')
    # data = data.query('lcId > 3')
    # data = handle_txnumber(data)
    # txnumber_2_df = data[data['txNumber'] > 1]
    # print(txnumber_2_df)
    # data = data.query('scheduledBytesPerBearer != 0')
    return data


def parse_ul_csv(file_path, columns, lcrId, virtualUeIndex=0):
    pd = install_and_import_pandas()
    pd.set_option('display.max_columns', None)
    pd.set_option('display.max_colwidth', None)
    pd.set_option('display.width', None)
    data = pd.read_csv(file_path, usecols=columns)
    data = data.rename(columns={"ulFdSchedData.startPrb": "startPrb"})
    data = data.rename(columns={"ulFdSchedData.numOfPrb": "numOfPrb"})
    data = data.rename(columns={"ulFdSchedData.ulMuStatus": "ulMuStatus"})
    data = data.rename(columns={"ulFdSchedData.numOfLayers": "numOfLayers"})
    data = data.rename(columns={"ulFdSchedData.tbSize": "tbSize"})
    data = data.rename(columns={"ulFdSchedData.virtualUeIndex": "virtualUeIndex"})
    data = data.rename(columns={"ulPduDemuxData.rcvdBearers[0].lcId": "lcId1"})
    data = data.rename(columns={"ulPduDemuxData.rcvdBearers[0].rcvdBytes": "rcvdBytes1"})
    data = data.rename(columns={"ulPduDemuxData.rcvdBearers[1].lcId": "lcId2"})
    data = data.rename(columns={"ulPduDemuxData.rcvdBearers[1].rcvdBytes": "rcvdBytes2"})
    data['lcId1'] = data['lcId1'].fillna(0)
    data['rcvdBytes1'] = data['rcvdBytes1'].fillna(0)
    data['lcId2'] = data['lcId2'].fillna(0)
    data['rcvdBytes2'] = data['rcvdBytes2'].fillna(0)
    if "virtualUeIndex" in data:
        data = data[data['virtualUeIndex'] == virtualUeIndex]
    data = data.query('ulMuStatus == "MUPAIRED_NO_TAPERING"')
    return data


def filter_continuous_data(df):
    df["id"] = range(1, len(df) + 1)
    indices2 = []
    indices3 = []
    indices4 = []

    for i in range(len(df) - 1):
        l1 = df.iloc[i]
        l2 = df.iloc[i + 1]
        if l1['slot'] == l2['slot'] and l1['sfn'] == l2['sfn']:
            if i + 2 < len(df) and l1['slot'] == df.iloc[i + 2]['slot'] and l1['sfn'] == df.iloc[i + 2]['sfn']:
                if i + 3 < len(df) and l1['slot'] == df.iloc[i + 3]['slot'] and l1['sfn'] == df.iloc[i + 3]['sfn']:
                    indices4.extend([i, i + 1, i + 2, i + 3])
                else:
                    if i not in indices4 and i + 1 not in indices4 and i + 2 not in indices4:
                        indices3.extend([i, i + 1, i + 2])
            else:
                if i not in indices3 and i not in indices4:
                    indices2.extend([i, i + 1])

    filtered_df2 = df.iloc[indices2].drop_duplicates()
    filtered_df3 = df.iloc[indices3].drop_duplicates()
    filtered_df4 = df.iloc[indices4].drop_duplicates()

    return filtered_df2, filtered_df3, filtered_df4


def analysis_single_line(line, layer):
    line_info = dict()
    line_info['rnti'] = line['rnti']
    line_info['sfn'] = line['sfn']
    line_info['slot'] = line['slot']
    line_info['bin'] = bin(int(line['rat0Bitmap']))[2:]
    line_info['rank'] = int(line['numOfLayers'][-1])
    line_info['scheduledBytesPerBearer'] = line['scheduledBytesPerBearer']
    line_info['tbSize'] = line['tbSize']
    line_info['drb_ratio'] = line['scheduledBytesPerBearer'] / (line['tbSize'] / 8)
    line_info['drb_ratio2'] = line_info['drb_ratio']
    if 'scheduledBytesPerBearer2' in line:
        line_info['drb_ratio2'] = line['scheduledBytesPerBearer2'] / (line['tbSize'] / 8)
    line_info['layer_ratio'] = line_info['rank'] / layer
    return line_info


def analysis_single_line_ul(line, layer):
    line_info = dict()
    line_info['startPrb'] = line['startPrb']
    line_info['numOfPrb'] = line['numOfPrb']
    line_info['lcId1'] = line['lcId1']
    line_info['rcvdBytes1'] = line['rcvdBytes1']
    line_info['lcId2'] = line['lcId2']
    line_info['rcvdBytes2'] = line['rcvdBytes2']
    if line['lcId1'] < 4:
        line_info['lcId1'] = line['lcId2']
        line_info['rcvdBytes1'] = line['rcvdBytes2']
        line_info['lcId2'] = 0
        line_info['rcvdBytes2'] = line['rcvdBytes2']
    line_info['rnti'] = line['rnti']
    line_info['sfn'] = line['sfn']
    line_info['slot'] = line['slot']
    line_info['rank'] = int(line['numOfLayers'][-1])
    line_info['tbSize'] = line['tbSize']
    line_info['layer_ratio'] = line_info['rank'] / layer
    return line_info


def cal_prb_line2(df, sum_rnti, layer):
    if layer not in sum_rnti:
        sum_rnti[layer] = 0
        sum_rnti[44] = 0
        sum_rnti[55] = 0
    for i in range(0, len(df), 2):
        l1 = analysis_single_line(df.iloc[i], layer)
        l2 = analysis_single_line(df.iloc[i+1], layer)
        if l1["rnti"] not in sum_rnti:
            sum_rnti[l1["rnti"]] = {
                4: 0,
                5: 0
            }
        if l2["rnti"] not in sum_rnti:
            sum_rnti[l2["rnti"]] = {
                4: 0,
                5: 0
            }
        round1 = 0
        round2 = 0
        round11 = 0
        round22 = 0
        min_len = min(len(l1["bin"]), len(l2["bin"]))
        for j in range(1, min_len + 1):
            if j == 1:
                prb = 2
            else:
                prb = 8
            if (int(l1["bin"][-j])*l1["rank"] + int(l2["bin"][-j])*l2["rank"] == layer):
                round1 += l1["drb_ratio"] * prb * l1["layer_ratio"]
                round2 += l2["drb_ratio"] * prb * l2["layer_ratio"]
                round11 += l1["drb_ratio2"] * prb * l1["layer_ratio"]
                round22 += l2["drb_ratio2"] * prb * l2["layer_ratio"]
        sum_rnti[l1["rnti"]][4] += round(round1)
        sum_rnti[l2["rnti"]][4] += round(round2)
        sum_rnti[l1["rnti"]][5] += round(round11)
        sum_rnti[l2["rnti"]][5] += round(round22)
        sum_rnti[44] += round(round1 + round2)
        sum_rnti[55] += round(round11 + round22)


def cal_prb_line2_ul(df, sum_rnti, layer):
    if layer not in sum_rnti:
        sum_rnti[layer] = 0
    for i in range(0, len(df), 2):
        l1 = analysis_single_line_ul(df.iloc[i], layer)
        l2 = analysis_single_line_ul(df.iloc[i+1], layer)
        prb_min = max(l1['startPrb'], l2['startPrb'])
        prb_max = min(l1['startPrb'] + l1['numOfPrb'], l2['startPrb'] + l2['numOfPrb'])
        prb = prb_max - prb_min
        if l1["rnti"] not in sum_rnti:
            sum_rnti[l1["rnti"]] = {
                4: 0,
                5: 0
            }
        if l2["rnti"] not in sum_rnti:
            sum_rnti[l2["rnti"]] = {
                4: 0,
                5: 0
            }
        round1 = 0
        round2 = 0
        round11 = 0
        round22 = 0
        if l1['lcId1'] == 4.0 or l1['lcId1'] == 5.0:
            if 0 < l1['rcvdBytes1']/(l1['tbSize']/8)*prb*l1['layer_ratio'] < 0.5:
                sum_rnti[l1["rnti"]][int(l1['lcId1'])] += 1
            sum_rnti[l1["rnti"]][int(l1['lcId1'])] += round(l1['rcvdBytes1']/(l1['tbSize']/8)*prb*l1['layer_ratio'])
        if l1['lcId2'] == 4.0 or l1['lcId2'] == 5.0:
            if 0 < l1['rcvdBytes2']/(l1['tbSize']/8)*prb*l1['layer_ratio'] < 0.5:
                sum_rnti[l1["rnti"]][int(l1['lcId2'])] += 1
            sum_rnti[l1["rnti"]][int(l1['lcId2'])] += round(
                l1['rcvdBytes2'] / (l1['tbSize'] / 8) * prb * l1['layer_ratio'])
        if l2['lcId1'] == 4.0 or l2['lcId1'] == 5.0:
            if 0 < l2['rcvdBytes1']/(l2['tbSize']/8)*prb*l2['layer_ratio'] < 0.5:
                sum_rnti[l2["rnti"]][int(l2['lcId1'])] += 1
            sum_rnti[l2["rnti"]][int(l2['lcId1'])] += round(
                l2['rcvdBytes1'] / (l2['tbSize'] / 8) * prb * l2['layer_ratio'])
        if l2['lcId2'] == 4.0 or l2['lcId2'] == 5.0:
            if 0 < l2['rcvdBytes2']/(l2['tbSize']/8)*prb*l2['layer_ratio'] < 0.5:
                sum_rnti[l2["rnti"]][int(l2['lcId2'])] += 1
            sum_rnti[l2["rnti"]][int(l2['lcId2'])] += round(
                l2['rcvdBytes2'] / (l2['tbSize'] / 8) * prb * l2['layer_ratio'])


def cal_prb_line2_4_ul(df, sum_rnti, layer):
    if layer not in sum_rnti:
        sum_rnti[layer] = 0
    for i in range(0, len(df), 2):
        l1 = analysis_single_line_ul(df.iloc[i], layer)
        l2 = analysis_single_line_ul(df.iloc[i+1], layer)
        sum_rnti[layer] += round(l1['rcvdBytes1']/(l1['tbSize']/8)*l1['numOfPrb']*l1['layer_ratio'])
        sum_rnti[layer] += round(l2['rcvdBytes1']/(l2['tbSize']/8)*l2['numOfPrb']*l2['layer_ratio'])


def cal_prb_line3(df, sum_rnti, layer, max_prb=8, min_prb=2):
    if layer not in sum_rnti:
        sum_rnti[layer] = 0
    for i in range(0, len(df), 3):
        l1 = analysis_single_line(df.iloc[i], layer)
        l2 = analysis_single_line(df.iloc[i+1], layer)
        l3 = analysis_single_line(df.iloc[i+2], layer)
        round1 = 0
        round2 = 0
        round3 = 0
        min_len = min(len(l1["bin"]), len(l2["bin"]), len(l3["bin"]))
        for j in range(1, min_len + 1):
            if j == 1:
                prb = min_prb
            else:
                prb = max_prb
            if (int(l1["bin"][-j])*l1["rank"] + int(l2["bin"][-j])*l2["rank"] + int(l3["bin"][-j])*l3["rank"] == layer):
                round1 += l1["drb_ratio"] * prb * l1["layer_ratio"]
                round2 += l2["drb_ratio"] * prb * l2["layer_ratio"]
                round3 += l3["drb_ratio"] * prb * l3["layer_ratio"]
        value = round(round1 + round2 + round3)
        sum_rnti[layer] += value


def cal_prb_line4(df, sum_rnti, layer):
    if layer not in sum_rnti:
        sum_rnti[layer] = 0
        sum_rnti[12] = 0
    for i in range(0, len(df), 4):
        l1 = analysis_single_line(df.iloc[i], layer)
        l2 = analysis_single_line(df.iloc[i+1], layer)
        l3 = analysis_single_line(df.iloc[i+2], layer)
        l4 = analysis_single_line(df.iloc[i+3], layer)
        round1 = 0
        round2 = 0
        round3 = 0
        round4 = 0
        value12 = 0
        min_len = min(len(l1["bin"]), len(l2["bin"]), len(l3["bin"]), len(l4["bin"]))
        for j in range(1, min_len + 1):
            if j == 1:
                prb = 1
            else:
                prb = 16
            if (int(l1["bin"][-j])*l1["rank"] + int(l2["bin"][-j])*l2["rank"]
                    + int(l3["bin"][-j])*l3["rank"] + int(l4["bin"][-j])*l4["rank"] == layer):
                round1 += l1["drb_ratio"] * prb * l1["layer_ratio"]
                round2 += l2["drb_ratio"] * prb * l2["layer_ratio"]
                round3 += l3["drb_ratio"] * prb * l3["layer_ratio"]
                round4 += l4["drb_ratio"] * prb * l4["layer_ratio"]
        if l1["rank"] == 2:
            value12 = round(round2 + round3 + round4)
        elif l2["rank"] == 2:
            value12 = round(round1 + round3 + round4)
        elif l3["rank"] == 2:
            value12 = round(round2 + round1 + round4)
        elif l4["rank"] == 2:
            value12 = round(round2 + round3 + round1)
        value = round(round1 + round2 + round3 + round4)
        sum_rnti[layer] += value
        sum_rnti[12] += value12


def cal_prb_line234(df2, df3, df4, sum_rnti, layer):
    if layer not in sum_rnti:
        sum_rnti[layer] = 0
    for i in range(0, len(df2), 2):
        l1 = analysis_single_line(df2.iloc[i], layer)
        l1["bin"] = l1["bin"].zfill(14)
        l2 = analysis_single_line(df2.iloc[i+1], layer)
        l2["bin"] = l2["bin"].zfill(14)
        round1 = 0
        round2 = 0
        for j in range(14):
            if j == 13:
                prb = 2
            else:
                prb = 8
            if int(l1["bin"][j]) == int(l2["bin"][j]) == 1:
                round1 += l1["drb_ratio"] * prb * l1["layer_ratio"]
                round2 += l2["drb_ratio"] * prb * l2["layer_ratio"]
        sum_rnti[layer] += round(round1 + round2)
    for i in range(0, len(df3), 3):
        l1 = analysis_single_line(df3.iloc[i], layer)
        l1["bin"] = l1["bin"].zfill(14)
        l2 = analysis_single_line(df3.iloc[i+1], layer)
        l2["bin"] = l2["bin"].zfill(14)
        l3 = analysis_single_line(df3.iloc[i+2], layer)
        l3["bin"] = l3["bin"].zfill(14)
        round1 = 0
        round2 = 0
        round3 = 0
        for j in range(14):
            if j == 13:
                prb = 2
            else:
                prb = 8
            if (int(l1["bin"][j])*l1["rank"] + int(l2["bin"][j])*l2["rank"] + int(l3["bin"][j])*l3["rank"] == layer):
                round1 += l1["drb_ratio"] * prb * l1["layer_ratio"] * int(l1["bin"][j])
                round2 += l2["drb_ratio"] * prb * l2["layer_ratio"] * int(l2["bin"][j])
                round3 += l3["drb_ratio"] * prb * l3["layer_ratio"] * int(l3["bin"][j])
        sum_rnti[layer] += round(round1 + round2 + round3)
    for i in range(0, len(df4), 4):
        l1 = analysis_single_line(df4.iloc[i], layer)
        l2 = analysis_single_line(df4.iloc[i+1], layer)
        l3 = analysis_single_line(df4.iloc[i+2], layer)
        l4 = analysis_single_line(df4.iloc[i+3], layer)
        l1["bin"] = l1["bin"].zfill(14)
        l2["bin"] = l2["bin"].zfill(14)
        l3["bin"] = l3["bin"].zfill(14)
        l4["bin"] = l4["bin"].zfill(14)
        round1 = 0
        round2 = 0
        round3 = 0
        round4 = 0
        for j in range(14):
            if j == 13:
                prb = 2
            else:
                prb = 8
            if (int(l1["bin"][j])*l1["rank"] + int(l2["bin"][j])*l2["rank"] + int(l3["bin"][j])*l3["rank"] +
                    int(l4["bin"][j])*l4["rank"] == layer):
                round1 += l1["drb_ratio"] * prb * l1["layer_ratio"] * int(l1["bin"][j])
                round2 += l2["drb_ratio"] * prb * l2["layer_ratio"] * int(l2["bin"][j])
                round3 += l3["drb_ratio"] * prb * l3["layer_ratio"] * int(l3["bin"][j])
                round4 += l4["drb_ratio"] * prb * l4["layer_ratio"] * int(l4["bin"][j])
        sum_rnti[layer] += round(round1 + round2 + round3 + round4)


def parse_4ue_dl_csv(file_path, lcrId, layer):
    columns = ['sfn', 'slot', 'rnti', 'lcrId', 'dlFdSchedData.txNumber', 'dlFdSchedData.dlHarqProcessIndex',
               'dlFdSchedData.numOfLayers', 'dlFdSchedData.muStatus', 'dlFdSchedData.tbSize',
               'dlFdSchedData.rat0Bitmap', 'dlFdSchedData.scheduledBytesPerBearer[4]']
    df = parse_csv(file_path, columns, lcrId)
    df = handle_txnumber(df)
    filtered_df2, filtered_df3, filtered_df4 = filter_continuous_data(df)
    sum_rnti = {}
    cal_prb_line4(filtered_df4, sum_rnti, layer=layer)
    return sum_rnti


def parse_3ue_dl_csv(file_path, lcrId, layer):
    columns = ['sfn', 'slot', 'rnti', 'lcrId', 'dlFdSchedData.txNumber', 'dlFdSchedData.dlHarqProcessIndex',
               'dlFdSchedData.numOfLayers', 'dlFdSchedData.muStatus', 'dlFdSchedData.tbSize',
               'dlFdSchedData.rat0Bitmap', 'dlFdSchedData.scheduledBytesPerBearer[4]']
    df = parse_csv(file_path, columns, lcrId)
    df = handle_txnumber(df)
    filtered_df2, filtered_df3, filtered_df4 = filter_continuous_data(df)
    sum_rnti = {}
    cal_prb_line3(filtered_df3, sum_rnti, layer=layer)
    return sum_rnti


def parse_2ue_dl_csv(file_path, lcrId, layer, multi_drb=True):
    columns = ['sfn', 'slot', 'rnti', 'lcrId', 'dlFdSchedData.txNumber', 'dlFdSchedData.dlHarqProcessIndex',
               'dlFdSchedData.numOfLayers', 'dlFdSchedData.muStatus', 'dlFdSchedData.tbSize',
               'dlFdSchedData.rat0Bitmap', 'dlFdSchedData.scheduledBytesPerBearer[4]']
    if multi_drb:
        columns.append('dlFdSchedData.scheduledBytesPerBearer[5]')
    df = parse_csv(file_path, columns, lcrId)
    filtered_df2, filtered_df3, filtered_df4 = filter_continuous_data(df)
    sum_rnti = {}
    cal_prb_line2(filtered_df2, sum_rnti, layer=layer)
    return sum_rnti


def parse_234ue_dl_csv(file_path, lcrId, layer):
    columns = ['sfn', 'slot', 'rnti', 'lcrId', 'dlFdSchedData.txNumber', 'dlFdSchedData.dlHarqProcessIndex',
               'dlFdSchedData.numOfLayers', 'dlFdSchedData.muStatus', 'dlFdSchedData.tbSize',
               'dlFdSchedData.rat0Bitmap', 'dlFdSchedData.scheduledBytesPerBearer[4]']
    df = parse_csv(file_path, columns, lcrId)
    df = handle_txnumber(df)
    filtered_df2, filtered_df3, filtered_df4 = filter_continuous_data(df)
    sum_rnti = {}
    cal_prb_line234(filtered_df2, filtered_df3, filtered_df4, sum_rnti, layer=layer)
    print(sum_rnti)
    return sum_rnti


def parse_2ue_ul_csv(file_path, lcrId, layer):
    columns = ['sfn', 'slot', 'rnti', 'lcrId', 'ulFdSchedData.startPrb', 'ulFdSchedData.numOfPrb',
               'ulFdSchedData.numOfLayers', 'ulFdSchedData.ulMuStatus', 'ulFdSchedData.tbSize',
               'ulPduDemuxData.rcvdBearers[0].lcId', 'ulPduDemuxData.rcvdBearers[0].rcvdBytes',
               'ulPduDemuxData.rcvdBearers[1].lcId', 'ulPduDemuxData.rcvdBearers[1].rcvdBytes']
    df = parse_ul_csv(file_path, columns, lcrId)
    filtered_df2, filtered_df3, filtered_df4 = filter_continuous_data(df)
    sum_rnti = {}
    cal_prb_line2_ul(filtered_df2, sum_rnti, layer=layer)
    return sum_rnti


def parse_4ue_ul_csv(file_path, lcrId, layer):
    columns = ['sfn', 'slot', 'rnti', 'lcrId', 'ulFdSchedData.startPrb', 'ulFdSchedData.numOfPrb',
               'ulFdSchedData.numOfLayers', 'ulFdSchedData.ulMuStatus', 'ulFdSchedData.tbSize',
               'ulFdSchedData.virtualUeIndex',
               'ulPduDemuxData.rcvdBearers[0].lcId', 'ulPduDemuxData.rcvdBearers[0].rcvdBytes',
               'ulPduDemuxData.rcvdBearers[1].lcId', 'ulPduDemuxData.rcvdBearers[1].rcvdBytes']
    sum_rnti = {}
    df = parse_ul_csv(file_path, columns, lcrId, 0)
    filtered_df2, filtered_df3, filtered_df4 = filter_continuous_data(df)
    cal_prb_line2_4_ul(filtered_df2, sum_rnti, layer=layer)

    df = parse_ul_csv(file_path, columns, lcrId, 1)
    filtered_df2, filtered_df3, filtered_df4 = filter_continuous_data(df)
    cal_prb_line2_4_ul(filtered_df2, sum_rnti, layer=layer)
    print(sum_rnti)
    return sum_rnti


def check_target_mustatus_num(file_path, type):
    columns = ['ulFdSchedData.ulMuStatus']
    pd = install_and_import_pandas()
    data = pd.read_csv(file_path, usecols=columns)
    data = data.dropna()
    data = data.rename(columns={"ulFdSchedData.ulMuStatus": "muStatus"})
    data = data.query('muStatus == @type')
    return len(data)


def check_layer_num(file_path, layer):
    columns = ['ulFdSchedData.numOfLayers']
    pd = install_and_import_pandas()
    data = pd.read_csv(file_path, usecols=columns)
    data = data.dropna()
    data = data.rename(columns={"ulFdSchedData.numOfLayers": "numOfLayers"})
    data = data.query('numOfLayers == @layer')
    return len(data)


def check_rcvd_num(file_path, rcvd=3):
    columns = ['ulPduDemuxData.rcvdBearers[0].rcvdBytes']
    pd = install_and_import_pandas()
    data = pd.read_csv(file_path, usecols=columns)
    data = data.dropna()
    data = data.rename(columns={"ulPduDemuxData.rcvdBearers[0].rcvdBytes": "rcvdBytes"})
    data = data.query('rcvdBytes == @rcvd')
    return len(data)


def check_dl_beam_type_id(file_path, type):
    columns = ['dlFdSchedData.beamType', 'dlFdSchedData.bestPatternId']
    pd = install_and_import_pandas()
    data = pd.read_csv(file_path, usecols=columns)
    data = data.dropna()
    data = data.rename(columns={"dlFdSchedData.beamType": "beamType"})
    data = data.rename(columns={"dlFdSchedData.bestPatternId": "bestPatternId"})
    column_values = data['bestPatternId'].values
    data = data.query('beamType == @type')
    assert len(data) > 1
    return set(column_values)


def check_ul_srs_beam_pattern_id(file_path):
    columns = ['ulFdSchedData.ulSrsBmBestBeamPatternId']
    pd = install_and_import_pandas()
    data = pd.read_csv(file_path, usecols=columns)
    data = data.dropna()
    data = data.rename(columns={"ulFdSchedData.ulSrsBmBestBeamPatternId": "ulSrsBmBestBeamPatternId"})
    column_values = data['ulSrsBmBestBeamPatternId'].values
    return set(column_values)


def check_dl_doah_doav_25r1(file_path):
    columns = ['dlFdSchedAdditionalData.doaH', 'dlFdSchedAdditionalData.doaV']
    pd = install_and_import_pandas()
    data = pd.read_csv(file_path, usecols=columns)
    data = data.dropna()
    data = data.rename(columns={"dlFdSchedAdditionalData.doaH": "doaH"})
    data = data.rename(columns={"dlFdSchedAdditionalData.doaV": "doaV"})
    data_53 = data[(data['doaH'] == -41.7695) & (data['doaV'] == -3.37109)]
    data_55 = data[(data['doaH'] == -10.4648) & (data['doaV'] == -1.68359)]
    data_66 = data[(data['doaH'] == 10.4648) & (data['doaV'] == 1.68359)]
    data_78 = data[(data['doaH'] == 41.7695) & (data['doaV'] == 5.0625)]
    return len(data_53), len(data_55), len(data_66), len(data_78)


def check_dl_doah_doav_25r2(file_path):
    columns = ['dlFdSchedData.bestPatternId']
    pd = install_and_import_pandas()
    data = pd.read_csv(file_path, usecols=columns)
    data = data.dropna()
    data = data.rename(columns={"dlFdSchedData.bestPatternId": "bestPatternId"})
    data_53 = data[(data['bestPatternId'] == 1413) | (data['bestPatternId'] == 1819)]
    data_55 = data[(data['bestPatternId'] == 1434) | (data['bestPatternId'] == 1840)]
    data_66 = data[(data['bestPatternId'] == 1109) | (data['bestPatternId'] == 1515)]
    data_78 = data[(data['bestPatternId'] == 1159) | (data['bestPatternId'] == 1565)]
    return len(data_53), len(data_55), len(data_66), len(data_78)


def check_dl_doah_doav_25r3(file_path):
    columns = ['dlFdSchedData.bestPatternId']
    pd = install_and_import_pandas()
    data = pd.read_csv(file_path, usecols=columns)
    data = data.dropna()
    data = data.rename(columns={"dlFdSchedData.bestPatternId": "bestPatternId"})
    data_43 = data[(data['bestPatternId'] == 1718)]
    return len(data_43)


def check_dl_doah_doav(file_path, branch):
    if branch == "SBTS25R1":
        len53, len55, len66, len78 = check_dl_doah_doav_25r1(file_path)
    else:
        len53, len55, len66, len78 = check_dl_doah_doav_25r2(file_path)
    return len53, len55, len66, len78


def wait_until_next_5_min(extra_sleep_time=None):
    now = datetime.datetime.now()
    seconds_past_last_5_min = (now.minute % 5) * 60 + now.second
    seconds_until_next_5_min = 300 - seconds_past_last_5_min
    time.sleep(seconds_until_next_5_min)
    if extra_sleep_time:
        time.sleep(int(extra_sleep_time))


if __name__ == "__main__":
    pass
    # parse_4ue_dl_csv("tcpdump_dl.csv", 1, 14)
    # parse_2ue_dl_csv("tcpdump_dl.csv", 1, 2)
    # parse_2ue_ul_csv("tcpdump_ul (1).csv", 1, 2)
    # parse_3ue_dl_csv("tcpdump_dl.csv", 1, 8)
    # a = check_dl_beam_type_id("tcpdump_dl.csv", "PMI")
    # b = check_ul_srs_beam_pattern_id("tcpdump_ul.csv")
    # print(a, b)
    # a,b,c,d = check_dl_doah_doav("tcpdump_dl.csv")
    # print(a,b,c,d)
