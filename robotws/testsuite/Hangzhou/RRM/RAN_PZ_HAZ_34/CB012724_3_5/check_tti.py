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


def wait_until_next_5_min(extra_sleep_time=None):
    now = datetime.datetime.now()
    seconds_past_last_5_min = (now.minute % 5) * 60 + now.second
    seconds_until_next_5_min = 300 - seconds_past_last_5_min
    time.sleep(seconds_until_next_5_min)
    if extra_sleep_time:
        time.sleep(int(extra_sleep_time))


def check_dtx_cellBwpId_UL(file_path, dci_format="UL_01", cell_bwp_id_1=1, cell_bwp_id_2=2, cell_bwp_id_3=3):
    columns = ['ulHarqRxData.dtx', 'ulFdSchedData.cellBwpId']
    pd = install_and_import_pandas()
    data = pd.read_csv(file_path, usecols=columns)
    data = data.dropna()
    data = data.rename(columns={"ulHarqRxData.dtx": "dtx"})
    data = data.rename(columns={"ulFdSchedData.cellBwpId": "cellBwpId"})
    count1 = len(data[(data['dtx'] == "NON_DTX") & (data['cellBwpId'] == cell_bwp_id_1)])
    count2 = len(data[(data['dtx'] == "NON_DTX") & (data['cellBwpId'] == cell_bwp_id_2)])
    count3 = len(data[(data['dtx'] == "NON_DTX") & (data['cellBwpId'] == cell_bwp_id_3)])
    return count1, count2, count3


def count_and_export_non_dtx_per_sched_1(
    file_path,
    output_txt="non_dtx_per_sched.txt",
    bwp_id=3,
    slots_per_sfn=20
):
    import pandas as pd

    df = pd.read_csv(
        file_path,
        usecols=[
            'hfnTickCount', 'sfn', 'slot', 'dlFdSchedData.cellBwpId',
            'dlFdSchedData.K1', 'dlHarqRxDataArray.dtx'
        ],
        low_memory=False
    )

    # ========== Step 1: ��ȡ BWP=3 �ĵ����� ==========
    sched_mask = (
        (df['dlFdSchedData.cellBwpId'] == bwp_id) &
        pd.notna(df['dlFdSchedData.K1']) &
        (df['dlFdSchedData.K1'] > 0) &
        pd.notna(df['sfn']) &
        pd.notna(df['slot']) &
        pd.notna(df['hfnTickCount'])
    )
    sched = df[sched_mask][['hfnTickCount', 'sfn', 'slot', 'dlFdSchedData.K1']].copy()
    sched.columns = ['hfnTickCount', 'sfn', 'slot', 'K1']
    sched[['hfnTickCount', 'sfn', 'slot', 'K1']] = sched[['hfnTickCount', 'sfn', 'slot', 'K1']].apply(
        pd.to_numeric, errors='coerce'
    )
    sched = sched.dropna()

    if sched.empty:
        open(output_txt, 'w').close()
        return 0

    # ========== Step 2: 提取所有 NON_DTX 反馈位置（仅这些才有效）==========
    harq_mask = (
        df['dlHarqRxDataArray.dtx'].notna() &
        (df['dlHarqRxDataArray.dtx'].astype(str).str.strip().str.upper() == 'NON_DTX') &
        pd.notna(df['sfn']) &
        pd.notna(df['slot']) &
        pd.notna(df['hfnTickCount'])
    )
    harq = df[harq_mask][['hfnTickCount', 'sfn', 'slot']].copy()
    harq[['hfnTickCount', 'sfn', 'slot']] = harq[['hfnTickCount', 'sfn', 'slot']].apply(pd.to_numeric, errors='coerce')
    harq = harq.dropna().astype(int)
    non_dtx_set = set(zip(harq['hfnTickCount'], harq['sfn'], harq['slot']))

    # ========== Step 3: 遍历调度，计算反馈时刻，检查是否在 NON_DTX 集合中 ==========
    matched_records = []
    for _, row in sched.iterrows():
        global_fb = int(row['sfn']) * slots_per_sfn + int(row['slot']) + int(row['K1'])
        fb_sfn = global_fb // slots_per_sfn
        fb_slot = global_fb % slots_per_sfn
        hfnTickCount = int(row['hfnTickCount'])
        if (hfnTickCount, fb_sfn, fb_slot) in non_dtx_set:
            matched_records.append((fb_sfn, fb_slot, bwp_id))
            print(f"{fb_sfn=} {fb_slot=} {non_dtx_set=}")

    # ========== Step 4: 导出 ==========
    with open(output_txt, 'w', encoding='utf-8') as f:
        for sfn, slot, bwp in matched_records:
            f.write(f"{hfnTickCount} {sfn} {slot} {bwp}\n")

    return len(matched_records)


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
    # get_dl_priorityIndex('tcpdump_dl.csv', [b'63757', b'61917', b'60077', b'58237'])
    # get_ul_priorityIndex('tcpdump_ul.csv', [63757, 61917, 60077, 58237])
