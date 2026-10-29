# pylint: skip-file
# -*- coding: utf-8 -*-
"""
:created on: 05-11-2023

:copyright: Nokia
:author: Zhang Xiaping
:contact: xiaping.zhang@nokia-sbell.com.cn
"""
import subprocess
import pkgutil
import importlib
import os
import math


column_name_list = ['physCellId', 'sfn', 'slot', 'rnti', 'burstId', 'tbSize',
                    'amountBytes', 'logicalChannelId', 'requestType', 'sduNum', 'mcs']


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', 'numpy', package])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def is_pandas_installed():
    return bool(pkgutil.find_loader('pandas'))


def install_and_import_pandas():
    if not is_pandas_installed():
        install_package('pandas')
    return importlib.import_module('pandas')


def get_sfn_cycle_times(df_burst_without_last, output_f=None):
    if not df_burst_without_last.empty:
        df_1023 = df_burst_without_last[(df_burst_without_last['sfn'] == 1023)]
        slot_list = list(df_1023["slot"].tolist())
        sfn_cycle_times = 0
        if len(df_1023) > 0 and len(df_1023) != len(df_burst_without_last):
            sfn_cycle_times = 1
            for i, slot in enumerate(slot_list):
                if slot < slot_list[i-1] and i != 0:
                    sfn_cycle_times += 1
            if df_burst_without_last.iloc[-1]['sfn'] == 1023:
                sfn_cycle_times = sfn_cycle_times - 1
        print("sfn_cycle_times==", sfn_cycle_times, file=output_f)
        if (df_burst_without_last.iloc[-1]['sfn'] < df_burst_without_last.iloc[0]['sfn'] and sfn_cycle_times == 0):
            sfn_list = sorted(list(set(df_burst_without_last['sfn'].tolist())))
            df_sfn_max = df_burst_without_last[(df_burst_without_last['sfn'] == sfn_list[-1])]
            slot_list = list(df_sfn_max["slot"].tolist())
            sfn_cycle_times = 1
            for i, slot in enumerate(slot_list):
                if slot < slot_list[i-1] and i != 0:
                    sfn_cycle_times += 1
            print("(no 1023)sfn_cycle_times==", sfn_cycle_times, file=output_f)
    else:
        sfn_cycle_times = 0
    return sfn_cycle_times


def get_amountBytes_and_time_per_burst(df_burst_without_last, cell_type,
                                       volThresDiscardDlMacSdu=None, durationThresDiscardDlMacSdu=None,
                                       output_f=None):
    amountBytes = 0
    duration = 0
    if not df_burst_without_last.empty:
        if cell_type == 'FR1_FDD':
            if len(df_burst_without_last) == 1:
                duration = 1
            else:
                sfn_cycle_times = get_sfn_cycle_times(df_burst_without_last, output_f)
                duration = (
                    df_burst_without_last.iloc[-1]['sfn']*10 + 1023 * 10 * sfn_cycle_times +
                    df_burst_without_last.iloc[-1]['slot']+1) -\
                    (df_burst_without_last.iloc[0]['sfn']*10 + df_burst_without_last.iloc[0]['slot'])
        elif cell_type == 'FR1_TDD':
            if len(df_burst_without_last) == 1:
                duration = 1/2
            else:
                sfn_cycle_times = get_sfn_cycle_times(df_burst_without_last, output_f)
                duration = (
                    df_burst_without_last.iloc[-1]['sfn']*10 + 1023 * 10 * sfn_cycle_times +
                    (df_burst_without_last.iloc[-1]['slot']+1)/2) -\
                    (df_burst_without_last.iloc[0]['sfn']*10 + df_burst_without_last.iloc[0]['slot']/2)
        elif cell_type == 'FR2_TDD':
            if len(df_burst_without_last) == 1:
                duration = 1/8
            else:
                sfn_cycle_times = get_sfn_cycle_times(df_burst_without_last, output_f)
                duration = (
                    df_burst_without_last.iloc[-1]['sfn']*10 + 1023 * 10 * sfn_cycle_times +
                    (df_burst_without_last.iloc[-1]['slot']+1)/8) -\
                    (df_burst_without_last.iloc[0]['sfn']*10 + df_burst_without_last.iloc[0]['slot']/8)
        df_burst_without_last['padding'] = df_burst_without_last['tbSize'] - df_burst_without_last['amountBytes']
        padding_sdu_num = (df_burst_without_last['padding'] != 0).sum()
        print("padding_sdu_num: ", padding_sdu_num, file=output_f)
        amountBytes = (df_burst_without_last['amountBytes'].sum()
                       - 2.9 * (df_burst_without_last['sduNum'].sum() - padding_sdu_num)) * 8 / 1000
        amount_kB = (df_burst_without_last['amountBytes'].sum()
                     - 2.9 * (df_burst_without_last['sduNum'].sum() - padding_sdu_num)) / 1000
        if (volThresDiscardDlMacSdu is not None) and (durationThresDiscardDlMacSdu is not None):
            if (amount_kB < volThresDiscardDlMacSdu) or (duration < durationThresDiscardDlMacSdu):
                amountBytes = 0
                duration = 0
    return amountBytes, duration


def get_time_per_burst_for_RLC(df_burst_without_last, p_physCellId, pcell_type, scell_type, sfn_cycle_times,
                               output_f=None):
    duration = 0
    if len(df_burst_without_last) == 1:
        if df_burst_without_last.iloc[0]['physCellId'] == p_physCellId:
            if pcell_type == 'FR1_FDD':
                duration = 1
            elif pcell_type == 'FR1_TDD':
                duration = 1/2
        elif df_burst_without_last.iloc[0]['physCellId'] != p_physCellId:
            if scell_type == 'FR1_FDD':
                duration = 1
            elif scell_type == 'FR1_TDD':
                duration = 1/2
    else:
        # sfn_cycle_times = get_sfn_cycle_times(df_burst_without_last, output_f)
        if (df_burst_without_last.iloc[-1]['physCellId'] == p_physCellId and pcell_type == 'FR1_FDD') or\
           (df_burst_without_last.iloc[-1]['physCellId'] != p_physCellId and scell_type == 'FR1_FDD'):
            last_line_time = df_burst_without_last.iloc[-1]['sfn']*10 + 1023 * 10 * sfn_cycle_times +\
                             df_burst_without_last.iloc[-1]['slot']+1
        elif (df_burst_without_last.iloc[-1]['physCellId'] == p_physCellId and pcell_type == 'FR1_TDD') or\
             (df_burst_without_last.iloc[-1]['physCellId'] != p_physCellId and scell_type == 'FR1_TDD'):
            last_line_time = df_burst_without_last.iloc[-1]['sfn']*10 + 1023 * 10 * sfn_cycle_times +\
                             (df_burst_without_last.iloc[-1]['slot']+1)/2
        if (df_burst_without_last.iloc[0]['physCellId'] == p_physCellId and pcell_type == 'FR1_FDD') or\
           (df_burst_without_last.iloc[0]['physCellId'] != p_physCellId and scell_type == 'FR1_FDD'):
            first_line_time = df_burst_without_last.iloc[0]['sfn']*10 + df_burst_without_last.iloc[0]['slot']
        elif (df_burst_without_last.iloc[0]['physCellId'] == p_physCellId and pcell_type == 'FR1_TDD') or\
             (df_burst_without_last.iloc[0]['physCellId'] != p_physCellId and scell_type == 'FR1_TDD'):
            first_line_time = df_burst_without_last.iloc[0]['sfn']*10 + df_burst_without_last.iloc[0]['slot']/2
        duration = last_line_time - first_line_time
    return duration


def get_value_from_L2LO_ttitrace_log(physCellId, cell_type, log_dir,
                                     volThresDiscardDlMacSdu=None, durationThresDiscardDlMacSdu=None):
    output_dir = os.path.dirname(log_dir)
    output_file_name = "CB010240_check_debug_log_" + str(physCellId) + ".txt"
    output_file = os.path.join(output_dir, output_file_name)
    f = open(output_file, 'a')
    print("***get_value_from_L2LO_ttitrace_log***", file=f)
    pd = install_and_import_pandas()
    df_all = pd.read_csv(log_dir)
    df_col_all = df_all.loc[:, column_name_list]
    df = df_col_all[(df_col_all['requestType'] == 'EBUILDREQUEST') & (df_col_all['physCellId'] == int(physCellId)) &
                    (df_col_all['sduNum'] > 1) & (df_col_all['burstId'] != 65535)]
    # print("df= ", df)
    rnti_list = list(set(df["rnti"].tolist()))
    # print('rnti_list for physCellId %s: %s' % (physCellId, rnti_list))
    sum_amountBytes = 0
    sum_Duration = 0
    for rnti in rnti_list:
        df_rnti = df[(df['rnti'] == rnti)]
        # print("df_rnti:", df_rnti)
        burst_list = list(set(df_rnti["burstId"].tolist()))
        # print('burst_list for rnti %s and physCellId %s: %s' % (rnti, physCellId, burst_list))
        for burst in burst_list:
            df_burst_without_last = df_rnti[(df_rnti['burstId'] == burst)][:-1]
            # print('df_burst_without_last:', df_burst_without_last)
            amountBytes_burst, Duration = get_amountBytes_and_time_per_burst(df_burst_without_last, cell_type,
                                                                             volThresDiscardDlMacSdu,
                                                                             durationThresDiscardDlMacSdu, f)
            print("physCellId %s rnti %s burst %s Duration :%s amountBytes_burst: %s" % (
                   physCellId, rnti, burst, Duration, amountBytes_burst), file=f)
            sum_amountBytes = sum_amountBytes + amountBytes_burst
            sum_Duration = sum_Duration + Duration
        print("physCellId %s rnti %s : sum_Duration :%s sum_amountBytes: %s" %
              (physCellId, rnti, sum_Duration, sum_amountBytes), file=f)
    print("Volume for physCellId %s: %s" % (physCellId, sum_amountBytes))
    print("Time for physCellId %s: %s" % (physCellId, round(sum_Duration)))
    f.close()
    return sum_amountBytes, round(sum_Duration)


def get_value_for_multi_bearer_from_L2LO_ttitrace_log(physCellId, cell_type, log_dir, except_logicalChannelId=None):
    output_dir = os.path.dirname(log_dir)
    output_file_name = "CB010240_check_debug_log_" + str(physCellId) + ".txt"
    output_file = os.path.join(output_dir, output_file_name)
    f = open(output_file, 'a')
    print("***get_value_for_multi_bearer_from_L2LO_ttitrace_log***", file=f)
    pd = install_and_import_pandas()
    # log_file = os.path.join(log_dir, 'ttitrace_streaming', 'MacPduMuxReq.csv')
    df_all = pd.read_csv(log_dir)
    # print("index_all: ", df_all.index.tolist())
    # print("the first row:",df_all.loc[0,:])
    # print("the number of row:",df_all)
    column_name_list = ['sfn', 'slot', 'rnti', 'requestType', 'physCellId', 'tbSize', 'sduNum', 'mcs',
                        'logicalChannelId', 'amountBytes', 'burstId',
                        'logicalChannelId.1', 'amountBytes.1', 'burstId.1',
                        'logicalChannelId.2', 'amountBytes.2', 'burstId.2']
    df_col_all = df_all.loc[:, column_name_list]
    df = df_col_all[(df_col_all['requestType'] == 'EBUILDREQUEST') & (df_col_all['physCellId'] == int(physCellId)) &
                    (df_col_all['sduNum'] > 1)]
    rnti_list = list(set(df["rnti"].tolist()))
    # print('rnti_list for physCellId %s: %s' % (physCellId, rnti_list))
    sum_amountBytes = 0
    sum_Duration = 0
    for rnti in rnti_list:
        df_rnti = df[(df['rnti'] == rnti)]
        # print("df_rnti:", df_rnti)
        df_channel_1_notnull = df_rnti[df_rnti["logicalChannelId.1"].notnull()]
        df_channel_2_notnull = df_rnti[df_rnti["logicalChannelId.2"].notnull()]
        channelId_list = list(set(list(set(df_rnti["logicalChannelId"].tolist()))
                                  + list(set(df_channel_1_notnull["logicalChannelId.1"].tolist()))
                                  + list(set(df_channel_2_notnull["logicalChannelId.2"].tolist()))))
        if except_logicalChannelId is not None:
            channelId_list = channelId_list.remove(except_logicalChannelId)
        for logicalChannelId in channelId_list:
            if logicalChannelId == 1.0 or logicalChannelId == 2.0:
                continue
            df_channel = df_rnti[(df_rnti['logicalChannelId'] == logicalChannelId)]
            df_channel_1 = df_rnti[(df_rnti['logicalChannelId.1'] == logicalChannelId)]
            df_channel_2 = df_rnti[(df_rnti['logicalChannelId.2'] == logicalChannelId)]
            burst_list = list(set(list(set(df_channel['burstId'].tolist()))
                                  + list(set(df_channel_1['burstId.1'].tolist()))
                                  + list(set(df_channel_2['burstId.2'].tolist()))))
            for burstId in burst_list:
                burst_amountBytes = 0
                burst_sduNum = 0
                burst_Duration = 0
                df_channel_burst = df_col_all[(df_col_all['requestType'] == 'EBUILDREQUEST') &
                                              (df_col_all['physCellId'] == int(physCellId)) &
                                              (df_col_all['sduNum'] > 1) &
                                              (df_col_all['rnti'] == rnti) &
                                              (df_col_all['logicalChannelId'] == logicalChannelId) &
                                              (df_col_all['burstId'] == burstId)]
                df_channel_burst_1 = df_col_all[(df_col_all['requestType'] == 'EBUILDREQUEST') &
                                                (df_col_all['physCellId'] == int(physCellId)) &
                                                (df_col_all['sduNum'] > 1) &
                                                (df_col_all['rnti'] == rnti) &
                                                (df_col_all['logicalChannelId.1'] == logicalChannelId) &
                                                (df_col_all['burstId.1'] == burstId)]
                df_channel_burst_2 = df_col_all[(df_col_all['requestType'] == 'EBUILDREQUEST') &
                                                (df_col_all['physCellId'] == int(physCellId)) &
                                                (df_col_all['sduNum'] > 1) &
                                                (df_col_all['rnti'] == rnti) &
                                                (df_col_all['logicalChannelId.2'] == logicalChannelId) &
                                                (df_col_all['burstId.2'] == burstId)]
                index1 = df_channel_burst.index.tolist()
                # print("logicalChannelId: %s, burstId: %s, index1: %s" % (logicalChannelId, burstId, index1))
                index2 = df_channel_burst_1.index.tolist()
                # print("logicalChannelId: %s, burstId: %s, index2: %s" % (logicalChannelId, burstId, index2))
                index3 = df_channel_burst_2.index.tolist()
                # print("logicalChannelId: %s, burstId: %s, index3: %s" % (logicalChannelId, burstId, index3))
                index_burst = sorted(index1 + index2 + index3)[:-1]
                if len(index_burst) > 0:
                    # print("*****index_burst******", index_burst, file = f)
                    # print("*****index_burst******: start:%s---stop:%s" % (index_burst[0], index_burst[-1]), file = f)
                    df_burst_without_last = df.loc[index_burst, :]
                    useless, burst_Duration = get_amountBytes_and_time_per_burst(df_burst_without_last, cell_type,
                                                                                 output_f=f)
                else:
                    burst_Duration = 0
                for i in index_burst:
                    row = df_col_all.loc[i, :]
                    total_amountBytes = row['amountBytes']
                    # print("row: ", row['amountBytes'], row['amountBytes.1'], row['amountBytes.2'])
                    if not row.isna()['amountBytes.2']:
                        total_amountBytes = row['amountBytes'] + row['amountBytes.1'] + row['amountBytes.2']
                    elif not row.isna()['amountBytes.1']:
                        total_amountBytes = row['amountBytes'] + row['amountBytes.1']
                    else:
                        total_amountBytes = row['amountBytes']
                    if i in index1:
                        burst_amountBytes += row['amountBytes']
                        burst_sduNum += row['sduNum'] * (row['amountBytes']/total_amountBytes)
                    elif i in index2:
                        burst_amountBytes += row['amountBytes.1']
                        burst_sduNum += row['sduNum'] * (row['amountBytes.1']/total_amountBytes)
                    elif i in index3:
                        burst_amountBytes += row['amountBytes.2']
                        burst_sduNum += row['sduNum'] * (row['amountBytes.2']/total_amountBytes)
                amountBytes_burst = round((burst_amountBytes - 3 * burst_sduNum) * 8 / 1000)
                print("physCellId %s rnti %s logicalChannelId %s burstId %s burst_Duration :%s amountBytes_burst: %s" %
                      (physCellId, rnti, logicalChannelId, burstId, burst_Duration, amountBytes_burst), file=f)
                sum_amountBytes += amountBytes_burst
                sum_Duration += burst_Duration
            print("physCellId %s rnti %s logicalChannelId %s: sum_Duration :%s sum_amountBytes: %s" %
                  (physCellId, rnti, logicalChannelId, sum_Duration, sum_amountBytes), file=f)
    print("Volume for physCellId %s: %s" % (physCellId, sum_amountBytes))
    print("Time for physCellId %s: %s" % (physCellId, round(sum_Duration)))
    f.close()
    return sum_amountBytes, round(sum_Duration)


def is_CA_UE(df, rnti):
    CA_UE = False
    df_rnti = df[(df['rnti'] == rnti)]
    physCellId_list = list(set(df_rnti['physCellId'].tolist()))
    if len(physCellId_list) > 1:
        CA_UE = True
        # print("rnti %s is CA UE" % (rnti), file=output_f)
    # else:
        # print("rnti %s is NonCA UE" % (rnti), file=output_f)
    return CA_UE


def get_CA_set_FR1(df_ca_rnti, output_file):
    import pandas as pd
    physCellId_list = list(set(df_ca_rnti['physCellId'].tolist()))
    cell_burst_set_list = []
    df_burst_all_cell = pd.DataFrame()
    for i_physCellId in physCellId_list:
        df_physCellId = df_ca_rnti[(df_ca_rnti['physCellId'] == i_physCellId)]
        cell_burst_list = sorted(list(set(df_physCellId["burstId"].tolist())))
        for i_burst in cell_burst_list:
            cell_burst_dic = {}
            df_cell_burst = df_physCellId[(df_physCellId['burstId'] == i_burst)]
            begin_line = df_cell_burst.index[0]
            end_line = df_cell_burst.index[-1]
            new_data = {'physCellId': i_physCellId, 'burstId': i_burst,
                        'begin_line': begin_line, 'end_line': end_line}
            new_df = pd.DataFrame(new_data, index=[len(df_burst_all_cell)])
            df_burst_all_cell = pd.concat([df_burst_all_cell, new_df])
    df_burst_all_cell.columns = ['physCellId', 'burstId', 'begin_line', 'end_line']
    df_burst_all_cell.sort_values(["begin_line"], inplace=True, ascending=True)
    df_burst_all_cell = df_burst_all_cell.reset_index(drop=True)
    print("sorted****\n", df_burst_all_cell, file=output_file)
    set_list = []
    set_burst_dic_list = []
    for index, row in df_burst_all_cell.iterrows():
        df_data = df_ca_rnti[(df_ca_rnti['physCellId'] == row['physCellId']) &
                             (df_ca_rnti['burstId'] == row['burstId'])]
        if index == 0:
            set_burst_dic = {}
            start_line = row['begin_line']
            end_line = row['end_line']
            df_ca_set = df_data
        elif index == len(df_burst_all_cell)-1:
            df_ca_set = pd.concat([df_ca_set, df_data])
            set_list.append(df_ca_set.sort_index())
            for i_physCellId in physCellId_list:
                df_physCellId = df_ca_set[(df_ca_set['physCellId'] == i_physCellId)]
                cell_burst_list = sorted(list(set(df_physCellId["burstId"].tolist())))
                set_burst_dic[i_physCellId] = cell_burst_list
            set_burst_dic_list.append(set_burst_dic)
            print("****ca set burst****: %r", set_burst_dic, file=output_file)
        else:
            if (row['begin_line'] < start_line and start_line < row['end_line'] < end_line):
                start_line = row['begin_line']
                df_ca_set = pd.concat([df_ca_set, df_data])
            elif row['begin_line'] >= start_line and row['end_line'] <= end_line:
                df_ca_set = pd.concat([df_ca_set, df_data])
            elif row['begin_line'] < end_line and row['end_line'] > end_line:
                end_line = row['end_line']
                df_ca_set = pd.concat([df_ca_set, df_data])
            else:
                set_list.append(df_ca_set.sort_index())
                for i_physCellId in physCellId_list:
                    df_physCellId = df_ca_set[(df_ca_set['physCellId'] == i_physCellId)]
                    cell_burst_list = sorted(list(set(df_physCellId["burstId"].tolist())))
                    set_burst_dic[i_physCellId] = cell_burst_list
                set_burst_dic_list.append(set_burst_dic)
                print("****ca set burst****: %r", set_burst_dic, file=output_file)
                start_line = row['begin_line']
                end_line = row['end_line']
                df_ca_set = df_data
                set_burst_dic = {}
    return set_list, set_burst_dic_list


def get_RLC_value_from_L2LO_ttitrace_log(physCellId, cell_type, is_pcell=None, ca_type=None, log_dir=None,
                                         except_rnti=None, include_rnti=None):
    """Caculate DL_RLC_PDU_VOL_UE_TPUT and DL_RLC_PDU_TIME_UE_TPUT from L2LO ttitrace log
        | Return | Volume, Time |
        kwargs optional parameters:
            1, physCellId,
            2. cell_type, FR1_FDD/FR1_TDD/FR2_TDD
            3. is_pcell, true/false
            4. ca_type, 3F/1T2F/4T/1F1T
            5. log_dir. ${TEST_LOG_DIRECTORY}/ttitrace_streaming/MacPduMuxReq.csv
    """
    output_dir = os.path.dirname(log_dir)
    output_file_name = "CB010240_check_debug_log_" + str(physCellId) + ".txt"
    output_file = os.path.join(output_dir, output_file_name)
    f = open(output_file, 'a')
    print("\n\n***get_RLC_value_from_L2LO_ttitrace_log for FR1***", file=f)
    pd = install_and_import_pandas()
    # log_file = os.path.join(log_dir, 'ttitrace_streaming', 'MacPduMuxReq.csv')
    df_all = pd.read_csv(log_dir)
    df_col_all = df_all.loc[:, column_name_list]
    df = df_col_all[(df_col_all['requestType'] == 'EBUILDREQUEST') & (df_col_all['sduNum'] > 1)
                    & (df_col_all['burstId'] != 65535)]
    df_physCellId = df[(df['physCellId'] == int(physCellId))]
    rnti_list_all = list(set(df_physCellId["rnti"].tolist()))
    if include_rnti is not None:
        rnti_list = [include_rnti]
    elif except_rnti is not None and except_rnti in rnti_list_all:
        rnti_list = rnti_list_all.remove(except_rnti)
    else:
        rnti_list = rnti_list_all
    # print('rnti_list for physCellId %s: %s' % (physCellId, rnti_list))
    sum_amountBytes = 0
    sum_Duration = 0
    for rnti in rnti_list:
        if not is_CA_UE(df_col_all, rnti):
            print("rnti %s is NonCA UE" % (rnti), file=f)
            df_rnti = df_physCellId[(df_physCellId['rnti'] == rnti)]
            burst_list = list(set(df_rnti["burstId"].tolist()))
            print("****before calculate: physCellId %s rnti %s : sum_Duration :%s sum_amountBytes: %s" %
                  (physCellId, rnti, sum_Duration, sum_amountBytes), file=f)
            # print('burst_list for rnti %s and physCellId %s: %s' % (rnti, physCellId, burst_list))
            if len(burst_list) < 1:
                print("***rnti %s is nonCA UE but not on physCellId %s***" % (rnti, physCellId), file=f)
            else:
                print("***** rnti %s is nonCA UE on physCellId %s  *****" % (rnti, physCellId), file=f)
                for burst in burst_list:
                    df_burst_without_last = df_rnti[(df_rnti['burstId'] == burst)][:-1]
                    amountBytes_burst, Duration = get_amountBytes_and_time_per_burst(df_burst_without_last,
                                                                                     cell_type, output_f=f)
                    print("physCellId %s rnti %s burst %s Duration :%s amountBytes_burst: %s" %
                          (physCellId, rnti, burst, Duration, amountBytes_burst), file=f)
                    sum_amountBytes = sum_amountBytes + amountBytes_burst
                    sum_Duration = sum_Duration + Duration
            print("****after calculate: physCellId %s rnti %s : sum_Duration :%s sum_amountBytes: %s" %
                  (physCellId, rnti, sum_Duration, sum_amountBytes), file=f)
        elif is_CA_UE(df_col_all, rnti) and is_pcell:
            print("***** rnti %s is CA UE and physCellId %s is pcell *****" % (rnti, physCellId), file=f)
            print("****before calculate: physCellId %s rnti %s : sum_Duration :%s sum_amountBytes: %s" %
                  (physCellId, rnti, sum_Duration, sum_amountBytes), file=f)
            df_ca_rnti = df[(df['rnti'] == rnti)]
            # physCellId_list = list(set(df_ca_rnti['physCellId'].tolist()))
            # scell_physCellId_list = [x for x in physCellId_list if x != physCellId]
            # print("***** rnti %s is CA UE and physCellId %s is pcell *****" % (rnti, physCellId), file=f)
            # print("****before calculate: physCellId %s rnti %s : sum_Duration :%s sum_amountBytes: %s" %
            #       (physCellId, rnti, sum_Duration, sum_amountBytes), file=f)
            # df_pcell_rnti = df_ca_rnti[(df_ca_rnti['physCellId'] == physCellId)]
            # pcell_burst_list = sorted(list(set(df_pcell_rnti["burstId"].tolist())))
            # print("pcell_burst_list: ", pcell_burst_list, file=f)
            set_list, set_burst_dic_list = get_CA_set_FR1(df_ca_rnti, f)
            for df_ca, set_burst_dic in zip(set_list, set_burst_dic_list):
                print("****ca set****\n", df_ca, file=f)
                # delete last slot
                df_ca_without_last = df_ca.sort_index()
                last_sfn = df_ca_without_last.iloc[-1]['sfn']
                last_slot = df_ca_without_last.iloc[-1]['slot']
                print('row_no: %r, last_sfn: %s, last_sfn: %s' %
                      (df_ca_without_last.index, last_sfn, last_slot), file=f)
                df_last_10 = df_ca.sort_index().tail(10)
                df_last_slot = df_last_10[(df_last_10['sfn'] == last_sfn) &
                                          (df_last_10['slot'] == last_slot)]
                # df_ca_without_last.subtract(df_last_slot)
                df_ca_without_last.drop(df_last_slot.index, inplace=True)
                if df_ca_without_last.empty:
                    print("df_ca_without_last for physCellId burst %r is empty" %
                          set_burst_dic, file=f)
                else:
                    print("all index for df_ca_without_last: %s, length: %s " %
                          (df_ca_without_last.index, len(df_ca_without_last)), file=f)
                    print("physCellId burst_id %r the first line of df_ca_without_last: %s" %
                          (set_burst_dic, df_ca_without_last.iloc[0]), file=f)
                    print("physCellId burst_id %r the last line of df_ca_without_last: %s" %
                          (set_burst_dic, df_ca_without_last.iloc[-1]), file=f)
                    # amountBytes_burst, Duration = get_amountBytes_and_time_per_burst(df_ca[:-1], cell_type)
                    physCellId_last_slot = df_ca_without_last.iloc[-1]['physCellId']
                    df_sfn_cycle = df_ca_without_last[(df_ca_without_last['physCellId'] == int(physCellId_last_slot))]
                    if ca_type == '3F' or ca_type == '4T':
                        amountBytes_burst, Duration = get_amountBytes_and_time_per_burst(df_ca_without_last,
                                                                                         cell_type, output_f=f)
                        print("******CA UE rnti %s %r Duration :%s amountBytes_burst: %s" %
                              (rnti, set_burst_dic, Duration, amountBytes_burst), file=f)
                        sum_amountBytes = sum_amountBytes + amountBytes_burst
                        sum_Duration = sum_Duration + Duration
                    elif ca_type == '1T2F':
                        if not df_ca_without_last.empty:
                            amountBytes_burst, useless = get_amountBytes_and_time_per_burst(df_ca_without_last,
                                                                                            cell_type, output_f=f)
                            sfn_cycle_times = get_sfn_cycle_times(df_sfn_cycle, output_f=f)
                            Duration = get_time_per_burst_for_RLC(df_ca_without_last, physCellId, 'FR1_TDD', 'FR1_FDD',
                                                                  sfn_cycle_times, output_f=f)
                        else:
                            amountBytes_burst = 0
                            Duration = 0
                        sum_amountBytes = sum_amountBytes + amountBytes_burst
                        sum_Duration = sum_Duration + Duration
                        print("*****CA UE rnti %s %r  Duration :%s amountBytes_burst: %s" %
                              (rnti, set_burst_dic, Duration, amountBytes_burst), file=f)
                    elif ca_type == '1F1T':
                        if not df_ca_without_last.empty:
                            amountBytes_burst, useless = get_amountBytes_and_time_per_burst(df_ca_without_last,
                                                                                            cell_type, output_f=f)
                            sfn_cycle_times = get_sfn_cycle_times(df_sfn_cycle, output_f=f)
                            Duration = get_time_per_burst_for_RLC(df_ca_without_last, physCellId, 'FR1_FDD', 'FR1_TDD',
                                                                  sfn_cycle_times, output_f=f)
                        else:
                            amountBytes_burst = 0
                            Duration = 0
                        sum_amountBytes = sum_amountBytes + amountBytes_burst
                        sum_Duration = sum_Duration + Duration
                        print("*******CA UE rnti %s %r Duration :%s amountBytes_burst: %s" %
                              (rnti, set_burst_dic, Duration, amountBytes_burst), file=f)
            print("****after calculate:physCellId %s rnti %s : sum_Duration :%s sum_amountBytes: %s" %
                  (physCellId, rnti, sum_Duration, sum_amountBytes), file=f)
        elif is_CA_UE(df_col_all, rnti) and not is_pcell:
            print("***** rnti %s is CA UE and physCellId %s is scell *****" % (rnti, physCellId), file=f)
            print("****before calculate: physCellId %s rnti %s : sum_Duration :%s sum_amountBytes: %s" %
                  (physCellId, rnti, sum_Duration, sum_amountBytes), file=f)
            sum_amountBytes = sum_amountBytes + 0
            sum_Duration = sum_Duration + 0
            print("****after calculate:physCellId %s rnti %s : sum_Duration :%s sum_amountBytes: %s" %
                  (physCellId, rnti, sum_Duration, sum_amountBytes), file=f)
    print("Volume for physCellId %s: %s" % (physCellId, sum_amountBytes))
    print("Time for physCellId %s: %s" % (physCellId, round(sum_Duration)))
    f.close()
    return sum_amountBytes, round(sum_Duration)


def get_RLC_value_from_L2LO_ttitrace_log_FR2(physCellId, cell_type, is_pcell=None, ca_type=None, log_dir=None,
                                             except_rnti=None, include_rnti=None):
    """Caculate DL_RLC_PDU_VOL_UE_TPUT and DL_RLC_PDU_TIME_UE_TPUT from L2LO ttitrace log
        | Return | Volume, Time |
        kwargs optional parameters:
            1, physCellId,
            2. cell_type, FR1_FDD/FR1_TDD/FR2_TDD
            3. is_pcell, true/false
            4. ca_type, 3F/1T2F/4T/1F1T
            5. log_dir. ${TEST_LOG_DIRECTORY}/ttitrace_streaming/MacPduMuxReq.csv
    """
    output_dir = os.path.dirname(log_dir)
    output_file_name = "CB010240_check_debug_log_" + str(physCellId) + ".txt"
    output_file = os.path.join(output_dir, output_file_name)
    f = open(output_file, 'a')
    print("\n\n***get_RLC_value_from_L2LO_ttitrace_log_FR2***", file=f)
    pd = install_and_import_pandas()
    # log_file = os.path.join(log_dir, 'ttitrace_streaming', 'MacPduMuxReq.csv')
    df_all = pd.read_csv(log_dir)
    df_col_all = df_all.loc[:, column_name_list]
    df = df_col_all[(df_col_all['requestType'] == 'EBUILDREQUEST') & (df_col_all['sduNum'] > 1)
                    & (df_col_all['burstId'] != 65535)]
    # df = df_col_all[(df_col_all['requestType'] == 'EBUILDREQUEST')]
    df_physCellId = df[(df['physCellId'] == int(physCellId))]
    rnti_list_all = list(set(df_physCellId["rnti"].tolist()))
    if include_rnti is not None:
        rnti_list = [include_rnti]
    elif except_rnti is not None and except_rnti in rnti_list_all:
        rnti_list = rnti_list_all.remove(except_rnti)
    else:
        rnti_list = rnti_list_all
    # print('rnti_list for physCellId %s: %s' % (physCellId, rnti_list))
    sum_amountBytes = 0
    sum_Duration = 0
    for rnti in rnti_list:
        if not is_CA_UE(df_col_all, rnti):
            print("rnti %s is NonCA UE" % (rnti), file=f)
            df_rnti = df_physCellId[(df_physCellId['rnti'] == rnti)]
            burst_list = list(set(df_rnti["burstId"].tolist()))
            print("****before calculate: physCellId %s rnti %s : sum_Duration :%s sum_amountBytes: %s" %
                  (physCellId, rnti, sum_Duration, sum_amountBytes), file=f)
            # print('burst_list for rnti %s and physCellId %s: %s' % (rnti, physCellId, burst_list))
            if len(burst_list) < 1:
                print("***rnti %s is nonCA UE but not on physCellId %s***" % (rnti, physCellId), file=f)
            else:
                print("***** rnti %s is nonCA UE on physCellId %s  *****" % (rnti, physCellId), file=f)
                for burst in burst_list:
                    df_burst_without_last = df_rnti[(df_rnti['burstId'] == burst)][:-1]
                    amountBytes_burst, Duration = get_amountBytes_and_time_per_burst(df_burst_without_last, cell_type,
                                                                                     output_f=f)
                    print("physCellId %s rnti %s burst %s Duration :%s amountBytes_burst: %s" %
                          (physCellId, rnti, burst, Duration, amountBytes_burst), file=f)
                    sum_amountBytes = sum_amountBytes + amountBytes_burst
                    sum_Duration = sum_Duration + Duration
            print("****after calculate: physCellId %s rnti %s : sum_Duration :%s sum_amountBytes: %s" %
                  (physCellId, rnti, sum_Duration, sum_amountBytes), file=f)
        elif is_CA_UE(df_col_all, rnti) and is_pcell:
            print("***** rnti %s is CA UE and physCellId %s is pcell *****" % (rnti, physCellId), file=f)
            print("****before calculate: physCellId %s rnti %s : sum_Duration :%s sum_amountBytes: %s" %
                  (physCellId, rnti, sum_Duration, sum_amountBytes), file=f)
            df_ca_rnti = df[(df['rnti'] == rnti)]
            burst_list = sorted(list(set(df_ca_rnti["burstId"].tolist())))
            for burst in burst_list:
                df_ca = df_ca_rnti[(df_ca_rnti['burstId'] == burst)]
                print("physCellId %s rnti %s burst %s df_ca index: %s" %
                      (physCellId, rnti, burst,  df_ca.index), file=f)
                last_sfn = df_ca.iloc[-1]['sfn']
                last_slot = df_ca.iloc[-1]['slot']
                print('last_sfn: %s, last_sfn: %s' % (last_sfn, last_slot), file=f)
                df_last_slot = df_ca[(df_ca['sfn'] == last_sfn) & (df_ca['slot'] == last_slot)]
                # df_ca.subtract(df_last_slot)
                df_ca.drop(df_last_slot.index, inplace=True)
                print("physCellId %s rnti %s burst %s df_ca remove last slot index: %s" %
                      (physCellId, rnti, burst, df_ca.index), file=f)
                if df_ca.empty:
                    print("df_ca for physCellId %s burst_id %s is empty" %
                          (physCellId, burst), file=f)
                else:
                    print("all index for df_ca: %s, length: %s " %
                          (df_ca.index, len(df_ca)), file=f)
                    print("physCellId %s burst_id %s the first line of df_ca: %s" %
                          (physCellId, burst, df_ca.iloc[0]), file=f)
                    print("physCellId %s burst_id %s the last line of df_ca: %s" %
                          (physCellId, burst, df_ca.iloc[-1]), file=f)
                    amountBytes_burst, Duration = get_amountBytes_and_time_per_burst(df_ca, cell_type, output_f=f)
                    print("******CA UE rnti %s physCellId %r burstId %s Duration :%s amountBytes_burst: %s" %
                          (rnti, physCellId, burst, Duration, amountBytes_burst), file=f)
                    sum_amountBytes = sum_amountBytes + amountBytes_burst
                    sum_Duration = sum_Duration + Duration
        elif is_CA_UE(df_col_all, rnti) and not is_pcell:
            print("***** rnti %s is CA UE and physCellId %s is scell *****" % (rnti, physCellId), file=f)
            print("****before calculate: physCellId %s rnti %s : sum_Duration :%s sum_amountBytes: %s" %
                  (physCellId, rnti, sum_Duration, sum_amountBytes), file=f)
            sum_amountBytes = sum_amountBytes + 0
            sum_Duration = sum_Duration + 0
            print("****after calculate:physCellId %s rnti %s : sum_Duration :%s sum_amountBytes: %s" %
                  (physCellId, rnti, sum_Duration, sum_amountBytes), file=f)
    print("Volume for physCellId %s: %s" % (physCellId, sum_amountBytes))
    print("Time for physCellId %s: %s" % (physCellId, round(sum_Duration)))
    f.close()
    return sum_amountBytes, round(sum_Duration)


def get_pdcp_amountBytes_and_time_per_burst(df_burst_without_last, cell_type,
                                            volThresDiscardDlMacSdu=None,
                                            durationThresDiscardDlMacSdu=None,
                                            output_f=None):
    amountBytes = 0
    duration = 0
    if not df_burst_without_last.empty:
        if cell_type == 'FR1_FDD':
            if len(df_burst_without_last) == 1:
                duration = 1
            else:
                sfn_cycle_times = get_sfn_cycle_times(df_burst_without_last, output_f)
                duration = (
                    df_burst_without_last.iloc[-1]['sfn']*10 + 1023 * 10 * sfn_cycle_times +
                    df_burst_without_last.iloc[-1]['slot']+1) -\
                    (df_burst_without_last.iloc[0]['sfn']*10 + df_burst_without_last.iloc[0]['slot'])
        elif cell_type == 'FR1_TDD':
            if len(df_burst_without_last) == 1:
                duration = 1/2
            else:
                sfn_cycle_times = get_sfn_cycle_times(df_burst_without_last, output_f)
                duration = (
                    df_burst_without_last.iloc[-1]['sfn']*10 + 1023 * 10 * sfn_cycle_times +
                    (df_burst_without_last.iloc[-1]['slot']+1)/2) -\
                    (df_burst_without_last.iloc[0]['sfn']*10 + df_burst_without_last.iloc[0]['slot']/2)
        elif cell_type == 'FR2_TDD':
            if len(df_burst_without_last) == 1:
                duration = 1/8
            else:
                sfn_cycle_times = get_sfn_cycle_times(df_burst_without_last, output_f)
                duration = (
                    df_burst_without_last.iloc[-1]['sfn']*10 + 1023 * 10 * sfn_cycle_times +
                    (df_burst_without_last.iloc[-1]['slot']+1)/8) -\
                    (df_burst_without_last.iloc[0]['sfn']*10 + df_burst_without_last.iloc[0]['slot']/8)
        df_burst_without_last['padding'] = df_burst_without_last['tbSize'] - df_burst_without_last['amountBytes']
        padding_sdu_num = (df_burst_without_last['padding'] != 0).sum()
        print("padding_sdu_num: ", padding_sdu_num, file=output_f)
        amountBytes = ((df_burst_without_last['amountBytes'].sum()
                       - 2.9 * (df_burst_without_last['sduNum'].sum() - padding_sdu_num)) * 8 / 1000
                       - 3.3 * (df_burst_without_last['sduNum'].sum() - padding_sdu_num) * 8 / 1000)
        amount_kB = ((df_burst_without_last['amountBytes'].sum()
                     - 2.9 * (df_burst_without_last['sduNum'].sum() - padding_sdu_num)) / 1000
                     - 3.3 * (df_burst_without_last['sduNum'].sum() - padding_sdu_num) * 8 / 1000)
        if (volThresDiscardDlMacSdu is not None) and (durationThresDiscardDlMacSdu is not None):
            if (amount_kB < volThresDiscardDlMacSdu) or (duration < durationThresDiscardDlMacSdu):
                amountBytes = 0
                duration = 0
    return amountBytes, duration


def get_pdcp_value_from_L2LO_ttitrace_log(physCellId, cell_type, log_dir,
                                          volThresDiscardDlMacSdu=None,
                                          durationThresDiscardDlMacSdu=None):
    output_dir = os.path.dirname(log_dir)
    output_file_name = "CB010240_check_debug_log_" + str(physCellId) + ".txt"
    output_file = os.path.join(output_dir, output_file_name)
    f = open(output_file, 'a')
    print("\n\n***get_pdcp_value_from_L2LO_ttitrace_log***", file=f)
    pd = install_and_import_pandas()
    df_all = pd.read_csv(log_dir)
    df_col_all = df_all.loc[:, column_name_list]
    df = df_col_all[(df_col_all['requestType'] == 'EBUILDREQUEST') & (df_col_all['physCellId'] == int(physCellId)) &
                    (df_col_all['sduNum'] > 1) & (df_col_all['burstId'] != 65535)]
    # print("df= ", df)
    rnti_list = list(set(df["rnti"].tolist()))
    # print('rnti_list for physCellId %s: %s' % (physCellId, rnti_list))
    sum_amountBytes = 0
    sum_Duration = 0
    for rnti in rnti_list:
        df_rnti = df[(df['rnti'] == rnti)]
        # print("df_rnti:", df_rnti)
        burst_list = list(set(df_rnti["burstId"].tolist()))
        # print('burst_list for rnti %s and physCellId %s: %s' % (rnti, physCellId, burst_list))
        for burst in burst_list:
            df_burst_without_last = df_rnti[(df_rnti['burstId'] == burst)]
            # print('df_burst_without_last:', df_burst_without_last)
            amountBytes_burst, Duration = get_pdcp_amountBytes_and_time_per_burst(df_burst_without_last, cell_type,
                                                                                  volThresDiscardDlMacSdu,
                                                                                  durationThresDiscardDlMacSdu, f)
            print("physCellId %s rnti %s burst %s Duration :%s amountBytes_burst: %s" % (
                   physCellId, rnti, burst, Duration, amountBytes_burst), file=f)
            sum_amountBytes = sum_amountBytes + amountBytes_burst
            sum_Duration = sum_Duration + Duration
        print("physCellId %s rnti %s : sum_Duration :%s sum_amountBytes: %s" %
              (physCellId, rnti, sum_Duration, sum_amountBytes), file=f)
    print("Volume for physCellId %s: %s" % (physCellId, sum_amountBytes))
    print("Time for physCellId %s: %s" % (physCellId, round(sum_Duration)))
    f.close()
    return sum_amountBytes, round(sum_Duration)


if __name__ == "__main__":
    log_dir = 'C:\\0_work_5G\\CB010240_log\\AB2_BB1_FR1\\SBTS00_ENB_9999_231006_000009_108\\MacPduMuxReq.csv'
    # counter_50 = get_value_for_multi_bearer_from_L2LO_ttitrace_log(50, 'FR1_FDD', log_dir)
    # counter_50 = get_value_from_L2LO_ttitrace_log(50, 'FR1_FDD', log_dir, 30, 2)
    # counter_51 = get_value_from_L2LO_ttitrace_log(51, 'FR1_FDD', log_dir)
    # counter_52 = get_value_from_L2LO_ttitrace_log(52, 'FR1_TDD', log_dir)
    # counter_50 = get_value_from_L2LO_ttitrace_log(50, 'FR2_TDD', log_dir)
    # counter_51 = get_value_from_L2LO_ttitrace_log(51, 'FR2_TDD', log_dir)
    # counter_52 = get_value_from_L2LO_ttitrace_log(52, 'FR2_TDD', log_dir)
    # counter_53 = get_value_from_L2LO_ttitrace_log(53, 'FR2_TDD', log_dir)
    # CA_counter_50 = get_RLC_value_from_L2LO_ttitrace_log(50, 'FR1_FDD', True, '3F', log_dir)
    # CA_counter_52 = get_RLC_value_from_L2LO_ttitrace_log(52, 'FR1_TDD', True, '1T2F', log_dir)
    # CA_counter_51 = get_RLC_value_from_L2LO_ttitrace_log(51, 'FR1_FDD', False, '3F', log_dir)
    CA_counter_51 = get_RLC_value_from_L2LO_ttitrace_log(51, 'FR1_FDD', True, '1F1T', log_dir)
    # CA_counter_54 = get_RLC_value_from_L2LO_ttitrace_log(54, 'FR1_FDD', True, '3F', log_dir)
    # CA_counter_50 = get_RLC_value_from_L2LO_ttitrace_log(50, 'FR1_FDD', False, '1T2F', log_dir)
    # CA_counter_50 = get_RLC_value_from_L2LO_ttitrace_log_FR2(50, 'FR2_TDD', True, '4T', log_dir)
    # counter_54 = get_value_from_L2LO_ttitrace_log(54, 'FR1_FDD', log_dir)
    # counter_50 = get_pdcp_value_from_L2LO_ttitrace_log(50, 'FR2_TDD', log_dir)
    # counter_50 = get_pdcp_value_from_L2LO_ttitrace_log(50, 'FR1_FDD', log_dir)
