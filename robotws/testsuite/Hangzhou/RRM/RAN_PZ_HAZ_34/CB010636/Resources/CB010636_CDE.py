# pylint: skip-file
# -*- coding: utf-8 -*-
"""
:created on: 05-16-2024

:copyright: Nokia
"""
import collections
import subprocess
import pkgutil
import importlib
import os
import re
import glob
from datetime import datetime, timedelta
import logging
from taf.transport.ssh import ssh

import warnings

warnings.filterwarnings('ignore', category=UserWarning)

ssh = ssh()
column_name_list = ['physCellId', 'timestamp', 'days', 'hours', 'minutes', 'seconds', 'microSeconds', 'sfn', 'slot',
                    'rnti', 'burstId', 'tbSize', 'amountBytes', 'logicalChannelId', 'requestType', 'sduNum', 'mcs',
                    'logicalChannelId.1', 'amountBytes.1', 'burstId.1', 'logicalChannelId.2', 'amountBytes.2',
                    'burstId.2']

Emil_column_name_list = [
    'Time',
    'Message name',
    'From',
    'To',
    'Interface',
    'Protocol',
    'Time diff',
    'Message body']


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', 'numpy', package])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def install_and_import_pandas():
    if not bool(pkgutil.find_loader('pandas')):
        install_package('pandas')
    return importlib.import_module('pandas')


def install_and_import_collections():
    if not bool(pkgutil.find_loader('collections')):
        install_package('collections')
    return importlib.import_module('collections')


def install_and_import_numpy():
    if not bool(pkgutil.find_loader('numpy')):
        install_package('numpy')
    return importlib.import_module('numpy')


def get_sfn_cycle_times(df_burst_without_last, output_f=None):
    if not df_burst_without_last.empty:
        df_1023 = df_burst_without_last[(df_burst_without_last['sfn'] == 1023)]
        slot_list = list(df_1023["slot"].tolist())
        sfn_cycle_times = 0
        if len(df_1023) > 0 and len(df_1023) != len(df_burst_without_last):
            sfn_cycle_times = 1
            for i, slot in enumerate(slot_list):
                if slot < slot_list[i - 1] and i != 0:
                    sfn_cycle_times += 1
            if df_burst_without_last.iloc[-1]['sfn'] == 1023:
                sfn_cycle_times = sfn_cycle_times - 1
        if (df_burst_without_last.iloc[-1]['sfn'] <
                df_burst_without_last.iloc[0]['sfn'] and sfn_cycle_times == 0):
            sfn_list = sorted(list(set(df_burst_without_last['sfn'].tolist())))
            df_sfn_max = df_burst_without_last[(
                df_burst_without_last['sfn'] == sfn_list[-1])]
            slot_list = list(df_sfn_max["slot"].tolist())
            sfn_cycle_times = 1
            for i, slot in enumerate(slot_list):
                if slot < slot_list[i - 1] and i != 0:
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
                sfn_cycle_times = get_sfn_cycle_times(
                    df_burst_without_last, output_f)
                if df_burst_without_last.iloc[-1]['sfn'] == 0:
                    duration = (
                        df_burst_without_last.iloc[-1]['sfn'] *
                        10 + 1023 * 10 * sfn_cycle_times
                        + 10 + df_burst_without_last.iloc[-1]['slot'] + 1) -\
                        (df_burst_without_last.iloc[0]['sfn'] *
                         10 + df_burst_without_last.iloc[0]['slot'])
                else:
                    duration = (
                        df_burst_without_last.iloc[-1]['sfn'] * 10 + 1023 * 10 * sfn_cycle_times +
                        + df_burst_without_last.iloc[-1]['slot'] + 1) -\
                        (df_burst_without_last.iloc[0]['sfn'] *
                         10 + df_burst_without_last.iloc[0]['slot'])
        elif cell_type == 'FR1_TDD':
            if len(df_burst_without_last) == 1:
                duration = 1 / 2
            else:
                sfn_cycle_times = get_sfn_cycle_times(
                    df_burst_without_last, output_f)
                if df_burst_without_last.iloc[-1]['sfn'] == 0:
                    duration = (
                        df_burst_without_last.iloc[-1]['sfn'] * 10 + 1023 * 10 * sfn_cycle_times + 10 +
                        (df_burst_without_last.iloc[-1]['slot'] + 1) / 2) -\
                        (df_burst_without_last.iloc[0]['sfn'] * 10 +
                         df_burst_without_last.iloc[0]['slot'] / 2)
                else:
                    duration = (
                        df_burst_without_last.iloc[-1]['sfn'] * 10 + 1023 * 10 * sfn_cycle_times +
                        (df_burst_without_last.iloc[-1]['slot'] + 1) / 2) -\
                        (df_burst_without_last.iloc[0]['sfn'] * 10 +
                         df_burst_without_last.iloc[0]['slot'] / 2)
        elif cell_type == 'FR2_TDD':
            if len(df_burst_without_last) == 1:
                duration = 1 / 8
            else:
                sfn_cycle_times = get_sfn_cycle_times(
                    df_burst_without_last, output_f)
                if df_burst_without_last.iloc[-1]['sfn'] == 0:
                    duration = (
                        df_burst_without_last.iloc[-1]['sfn'] * 10 + 1023 * 10 * sfn_cycle_times + 10 +
                        (df_burst_without_last.iloc[-1]['slot'] + 1) / 8) -\
                        (df_burst_without_last.iloc[0]['sfn'] * 10 +
                         df_burst_without_last.iloc[0]['slot'] / 8)
                else:
                    duration = (
                        df_burst_without_last.iloc[-1]['sfn'] * 10 + 1023 * 10 * sfn_cycle_times +
                        (df_burst_without_last.iloc[-1]['slot'] + 1) / 8) -\
                        (df_burst_without_last.iloc[0]['sfn'] * 10 +
                         df_burst_without_last.iloc[0]['slot'] / 8)
        df_burst_without_last['padding'] = df_burst_without_last['tbSize'] - \
            df_burst_without_last['amountBytes']
        padding_sdu_num = (df_burst_without_last['padding'] != 0).sum()
        amountBytes = (df_burst_without_last['amountBytes'].sum()
                       - 2.9 * (df_burst_without_last['sduNum'].sum() - padding_sdu_num)) * 8 / 1000
        amount_kB = (df_burst_without_last['amountBytes'].sum()
                     - 2.9 * (df_burst_without_last['sduNum'].sum() - padding_sdu_num)) / 1000
        if (volThresDiscardDlMacSdu is not None) and \
                (durationThresDiscardDlMacSdu is not None):
            if (amount_kB < volThresDiscardDlMacSdu) or\
                    (duration < durationThresDiscardDlMacSdu):
                amountBytes = 0
                duration = 0
    return amountBytes, duration


def get_vol_and_time_per_burst_per_bear(df_burst_without_last, logicalChannelId, burstId, cell_type,
                                        volThresDiscardDlMacSdu=None, durationThresDiscardDlMacSdu=None,
                                        f=None):
    install_and_import_numpy
    import numpy as np
    amountBytes = 0.0
    duration = 0.0
    burst_sduNum = 0
    burst_amountBytes = 0.0
    if not df_burst_without_last.empty:
        # print("df_burst_without_last: ", df_burst_without_last, file=f)
        # print("df_burst_without_last len: ", len(df_burst_without_last), file=f)
        if cell_type == 'FR1_FDD':
            if len(df_burst_without_last) == 1:
                duration = 1
            else:
                sfn_cycle_times = get_sfn_cycle_times(df_burst_without_last, f)
                if df_burst_without_last.iloc[-1]['sfn'] == 0:
                    duration = (
                        df_burst_without_last.iloc[-1]['sfn'] * 10 + 1023 * 10 * sfn_cycle_times + 10 +
                        df_burst_without_last.iloc[-1]['slot'] + 1) -\
                        (df_burst_without_last.iloc[0]['sfn'] *
                         10 + df_burst_without_last.iloc[0]['slot'])
                else:
                    duration = (
                        df_burst_without_last.iloc[-1]['sfn'] * 10 + 1023 * 10 * sfn_cycle_times +
                        df_burst_without_last.iloc[-1]['slot'] + 1) -\
                        (df_burst_without_last.iloc[0]['sfn'] *
                         10 + df_burst_without_last.iloc[0]['slot'])
        elif cell_type == 'FR1_TDD':
            if len(df_burst_without_last) == 1:
                duration = 1 / 2
            else:
                sfn_cycle_times = get_sfn_cycle_times(df_burst_without_last, f)
                if df_burst_without_last.iloc[-1]['sfn'] == 0:
                    duration = (
                        df_burst_without_last.iloc[-1]['sfn'] * 10 + 1023 * 10 * sfn_cycle_times + 10 +
                        (df_burst_without_last.iloc[-1]['slot'] + 1) / 2) -\
                        (df_burst_without_last.iloc[0]['sfn'] * 10 +
                         df_burst_without_last.iloc[0]['slot'] / 2)
                else:
                    duration = (
                        df_burst_without_last.iloc[-1]['sfn'] * 10 + 1023 * 10 * sfn_cycle_times +
                        (df_burst_without_last.iloc[-1]['slot'] + 1) / 2) -\
                        (df_burst_without_last.iloc[0]['sfn'] * 10 +
                         df_burst_without_last.iloc[0]['slot'] / 2)
        elif cell_type == 'FR2_TDD':
            if len(df_burst_without_last) == 1:
                duration = 1 / 8
            else:
                sfn_cycle_times = get_sfn_cycle_times(df_burst_without_last, f)
                if df_burst_without_last.iloc[-1]['sfn'] == 0:
                    duration = (
                        df_burst_without_last.iloc[-1]['sfn'] * 10 + 1023 * 10 * sfn_cycle_times + 10 +
                        (df_burst_without_last.iloc[-1]['slot'] + 1) / 8) -\
                        (df_burst_without_last.iloc[0]['sfn'] * 10 +
                         df_burst_without_last.iloc[0]['slot'] / 8)
                else:
                    duration = (
                        df_burst_without_last.iloc[-1]['sfn'] * 10 + 1023 * 10 * sfn_cycle_times +
                        (df_burst_without_last.iloc[-1]['slot'] + 1) / 8) -\
                        (df_burst_without_last.iloc[0]['sfn'] * 10 +
                         df_burst_without_last.iloc[0]['slot'] / 8)
        df_channel = df_burst_without_last[(df_burst_without_last['logicalChannelId']
                                            == logicalChannelId) & (df_burst_without_last['burstId'] == burstId)]
        df_channel_1 = df_burst_without_last[(df_burst_without_last['logicalChannelId.1']
                                              == logicalChannelId) & (df_burst_without_last['burstId.1'] == burstId)]
        df_channel_2 = df_burst_without_last[(df_burst_without_last['logicalChannelId.2']
                                              == logicalChannelId) & (df_burst_without_last['burstId.2'] == burstId)]
        index1 = df_channel.index.tolist()
        # print("logicalChannelId: %s, burstId: %s, index1: %s" % (logicalChannelId, burstId, index1), file=f)
        index2 = df_channel_1.index.tolist()
        index3 = df_channel_2.index.tolist()
        index_burst = sorted(index3 + index1 + index2)
        for i in index_burst:
            row = df_burst_without_last.loc[i, :]
            if not np.isnan(row['amountBytes.2']):
                total_amountBytes = row['amountBytes'] + \
                    row['amountBytes.1'] + row['amountBytes.2']
            elif not np.isnan(row['amountBytes.1']):
                total_amountBytes = row['amountBytes'] + row['amountBytes.1']
            elif not np.isnan(row['amountBytes']):
                total_amountBytes = row['amountBytes']
            if i in index1:
                burst_amountBytes += row['amountBytes']
                burst_sduNum += row['sduNum'] * \
                    (row['amountBytes'] / total_amountBytes)
            elif i in index2:
                burst_amountBytes += row['amountBytes.1']
                burst_sduNum += row['sduNum'] * \
                    (row['amountBytes.1'] / total_amountBytes)
            elif i in index3:
                burst_amountBytes += row['amountBytes.2']
                burst_sduNum += row['sduNum'] * \
                    (row['amountBytes.2'] / total_amountBytes)
        amountBytes = round((burst_amountBytes - 3 * burst_sduNum) * 8 / 1000)
        if (volThresDiscardDlMacSdu is not None) and (
                durationThresDiscardDlMacSdu is not None):
            if (amountBytes < volThresDiscardDlMacSdu *
                    8) or (duration < durationThresDiscardDlMacSdu):
                # print("volThresDiscardDlMacSdu  {}", volThresDiscardDlMacSdu, file=f)
                amountBytes = 0
                duration = 0
    return amountBytes, duration


def get_duration_and_merged_volume_for_all_bursts(df_data, cell_type, ue_cells, rnti,
                                                  ca_info_rnti, cell_bw, f, threshold_tim=None, threshold_vol=None):
    install_and_import_numpy
    install_and_import_collections
    import numpy as np
    import collections
    index = 1
    all_burst_action = {}
    DL_MAC_SDU_UE_TPUT_dic = {}
    rnti_counter = {}
    burst_last_slot = collections.defaultdict(dict)
    sum_cell_burst_volume = 0.0
    sum_cell_burst_time = 0.0
    rnti_last_slot_volume = 0.0
    rnti_last_slot_duration = 0.0
    volThresDiscardDlMacSdu = threshold_vol
    durationThresDiscardDlMacSdu = threshold_tim
    volThresDiscardDlMacSdu_RLC = 0.0
    durationThresDiscardDlMacSdu_RLC = 0.0
    df_data = df_data[(df_data['requestType'] == 'EBUILDREQUEST') & (df_data['sduNum'] > 1)
                      & (df_data['burstId'] != 65535) & (df_data['burstId'] != '') &
                      (df_data['logicalChannelId'] != '')]
    sorted_df_data = df_data.sort_values(by='timestamp', ascending=True)
    time_list = list(set(sorted_df_data["timestamp"].tolist()))
    ChannelId_list = list(set(sorted_df_data["logicalChannelId"].tolist()))
    DL_MAC_all_cell_duration = 0.0
    DL_MAC_all_cell_volume = 0.0
    DL_RLC_UE_TPUT_DENOM_FR1 = 0.0

    if len(time_list) >= 1:
        rnti_duration_RLC = sorted_df_data.iloc[-1]['timestamp'] - \
            sorted_df_data.iloc[0]['timestamp']
        for cell in ue_cells:
            DL_RLC_cell_duration = 0.0
            DL_MAC_cell_volume = 0.0
            DL_MAC_cell_duration = 0.0
            DL_MAC_cell_duration_Timestamp = 0.0
            for id in ChannelId_list:
                # print("cell is :{}".format(cell))
                is_pcell = True if ca_info_rnti['pcell'] == int(
                    cell) else False
                # filtered_cell = [d for d in filter_with_basic if d['physCellId'] == cell]
                df_cell = sorted_df_data[(sorted_df_data['physCellId'] == cell) & (
                    sorted_df_data['logicalChannelId'] == id)]
                # print("df_cell %s" % (df_cell))
                burst_list = list(set(df_cell["burstId"].tolist()))
                # print("filtered_cell_dic_sort[-1:] is :{}".format(filtered_cell_dic_sort[-1:]))
                DL_MAC_cell_volume_DRB = 0.0
                DL_MAC_cell_duration_DRB = 0.0
                DL_RLC_cell_duration_DRB = 0.0
                DL_RLC_cell_VOL_DRB = 0.0
                DL_MAC_cell_duration_Timestamp_DRB = 0.0
                for burst in burst_list:
                    last_slot_time = 0.0
                    volume = 0.0
                    df_cell_burst = df_cell[(df_cell['burstId'] == burst)]
                    # print("df_cell_burst is:", df_cell_burst, file=f)
                    if len(df_cell_burst) <= 1:
                        continue  # skip data only one row
                    else:
                        t_start = df_cell_burst.iloc[0]['timestamp']
                        timestamp = t_start
                        burst_id = df_cell_burst.iloc[0]['burstId']
                        t_stop = df_cell_burst.iloc[-1]['timestamp']
                        # print("RLC counter:", file=f)
                        volume_RLC, Duration_RLC = get_amountBytes_and_time_per_burst(
                            df_cell_burst, cell_type[int(
                                cell)], volThresDiscardDlMacSdu_RLC,
                            durationThresDiscardDlMacSdu_RLC, f)
                        volume_last_slot, Duration_last_slot = get_amountBytes_and_time_per_burst(
                            df_cell_burst.iloc[-1:], cell_type[int(
                                cell)], volThresDiscardDlMacSdu_RLC,
                            durationThresDiscardDlMacSdu_RLC, f)
                        if t_stop == sorted_df_data.iloc[-1]['timestamp']:
                            rnti_last_slot_volume = volume_last_slot
                            rnti_last_slot_duration = Duration_last_slot
                        if cell_type[int(cell)] == 'FR1_TDD':
                            last_slot_time = 0.5
                        elif cell_type[int(cell)] == 'FR1_FDD':
                            last_slot_time = 1
                        # burst_cell_duration = t_stop - t_start + last_slot_time
                        # print("Cell %s burst_cell_volume is: %s" % (cell, burst_cell_volume))
                        burst_cell_duration = np.int64(
                            t_stop - t_start + last_slot_time * 1000)
                        DL_RLC_cell_duration_DRB += burst_cell_duration / 1000
                        DL_RLC_cell_VOL_DRB += volume_RLC
                        sum_cell_burst_volume += volume_RLC
                        sum_cell_burst_time += burst_cell_duration / 1000
                        # CB010636-D DL_RLC_PDU_UE_TPUT_DENOM_FR1
                        DL_RLC_UE_TPUT_DENOM_FR1 += (
                            (burst_cell_duration / 1000) * (cell_bw[int(cell)]))
                        t_stop_add = np.int64(t_stop + last_slot_time * 1000)
                        all_burst_action[id][index] = {'timestamp': t_start,
                                                       't_start': t_start,
                                                       't_stop': t_stop_add,
                                                       'burst_duration_slot': Duration_RLC,
                                                       'burst_duration': DL_RLC_cell_duration,
                                                       'pci': cell,
                                                       'burst_id': burst,
                                                       'burst_volume': volume_RLC,
                                                       'last_slot_volume': volume_last_slot,
                                                       'burst_rate': volume_RLC / burst_cell_duration,
                                                       'rnti': rnti,
                                                       'action': 'start',
                                                       'logicalChannelId': id,
                                                       'last_slot_duration': Duration_last_slot}
                        index = index + 1
                        all_burst_action[id][index] = {'timestamp': t_stop_add,
                                                       't_start': t_start,
                                                       't_stop': t_stop_add,
                                                       'burst_duration_slot': Duration_RLC,
                                                       'burst_duration': DL_RLC_cell_duration,
                                                       'pci': cell,
                                                       'burst_id': burst,
                                                       'burst_volume': volume_RLC,
                                                       'last_slot_volume': volume_last_slot,
                                                       'burst_rate': volume_RLC / burst_cell_duration,
                                                       'rnti': rnti,
                                                       'action': 'stop',
                                                       'logicalChannelId': id,
                                                       'last_slot_duration': Duration_last_slot}
                        # print("start_burst_action: %s"
                        #      % (all_burst_action[index]), file=f)
                        index = index + 1
                    if len(df_cell_burst) >= 2:

                        volume_MAC, Duration_MAC = get_amountBytes_and_time_per_burst(
                            df_cell_burst.iloc[:-
                                               1], cell_type[int(cell)], volThresDiscardDlMacSdu,
                            durationThresDiscardDlMacSdu, f)
                        t_stop_mac = df_cell_burst.iloc[-2]['timestamp']
                        DL_MAC_cell_volume_DRB += volume_MAC
                        DL_MAC_cell_duration_DRB += Duration_MAC
                        # DL_MAC_cell_duration_RLC_SLOT += Duration_MAC_RLC_slot
                        DL_MAC_cell_duration_Timestamp_DRB += (
                            t_stop_mac - t_start + last_slot_time * 1000) / 1000
                        print(
                            "DL_MAC_cell_volume_DRB is: %s" %
                            (DL_MAC_cell_volume_DRB), file=f)
                        # print("cell %s burst_id %s ,DL_MAC_cell_duration_Timestamp %s, DL_MAC_cell_duration %s"
                        #        % (cell, burst_id, (t_stop_mac - t_start + last_slot_time * 1000) / 1000,
                        #        Duration_MAC), file=f)
            DL_MAC_cell_volume += DL_MAC_cell_volume_DRB
            DL_MAC_cell_duration += DL_MAC_cell_duration_DRB
            DL_MAC_cell_duration_Timestamp += DL_MAC_cell_duration_Timestamp_DRB
            print(
                "Cell %s DL_MAC_SDU_VOL_UE_TPUT is: %s" %
                (cell, DL_MAC_cell_volume), file=f)
            print("Cell %s DL_MAC_SDU_TIME_UE_TPUT_Timestamp is: %s ms" %
                  (cell, DL_MAC_cell_duration_Timestamp), file=f)
            print(
                "Cell %s DL_MAC_SDU_TIME_UE_TPUT is: %s ms" %
                (cell, DL_MAC_cell_duration), file=f)
            DL_MAC_SDU_UE_TPUT_dic[cell] = {'cellid': cell,
                                            'rnti': rnti,
                                            'DL_MAC_SDU_VOL_UE_TPUT': DL_MAC_cell_volume,
                                            'DL_MAC_SDU_TIME_UE_TPUT': DL_MAC_cell_duration}

        all_burst_action = sorted(
            all_burst_action.items(),
            key=lambda item: item[1]['timestamp'],
            reverse=False)
        all_burst_action = dict(all_burst_action)
        DL_RLC_PDU_VOL_UE_TPUT = sum_cell_burst_volume - rnti_last_slot_volume
        rnti_counter = {'rnti': rnti,
                        'pcell': ca_info_rnti['pcell'],
                        'rnti_last_slot_duration': rnti_last_slot_duration,
                        'rnti_last_slot_volume': rnti_last_slot_volume,
                        'DL_RLC_PDU_VOL_UE_TPUT': DL_RLC_PDU_VOL_UE_TPUT,
                        'DL_RLC_PDU_time': rnti_duration_RLC / 1000,
                        'DL_RLC_UE_TPUT_DENOM_FR1': DL_RLC_UE_TPUT_DENOM_FR1,
                        'DL_RLC_PDU_time': sum_cell_burst_time}
    return all_burst_action, rnti_counter, DL_MAC_SDU_UE_TPUT_dic


def get_time_and_vol_for_all_bursts_multi_bears(df_data, cell_type, ue_cells, rnti,
                                                ca_info_rnti, cell_bw, f, threshold_tim=None, threshold_vol=None):
    install_and_import_numpy
    import numpy as np
    index = 1
    all_burst_action = {}
    DL_MAC_SDU_UE_TPUT_dic = {}
    rnti_counter = {}
    burst_last_slot = collections.defaultdict(dict)
    sum_cell_burst_volume = 0.0
    sum_cell_burst_time = 0.0
    rnti_last_slot_volume = 0.0
    rnti_last_slot_duration = 0.0
    volThresDiscardDlMacSdu = threshold_vol
    durationThresDiscardDlMacSdu = threshold_tim
    rnti_duration_RLC = 0.0
    # print("df_data is %s" % (df_data['logicalChannelId']), file=f)
    # filtered_dic_sort = sorted(df_data, key=lambda x: x['timestamp'], reverse=False)
    sorted_df_data = df_data.sort_values(by='timestamp', ascending=True)
    # print("rnti is %s" % (rnti), file=f)
    time_list = list(set(sorted_df_data["timestamp"].tolist()))
    print("df_channel_1_notnull start")
    df_channel_0_notnull = sorted_df_data[sorted_df_data["logicalChannelId"].notnull(
    ) & (sorted_df_data['burstId'] != 65535.0)]
    df_channel_1_notnull = sorted_df_data[sorted_df_data["logicalChannelId.1"].notnull(
    ) & (sorted_df_data['burstId.1'] != 65535.0)]
    df_channel_2_notnull = sorted_df_data[sorted_df_data["logicalChannelId.2"].notnull(
    ) & (sorted_df_data['burstId.2'] != 65535.0)]
    channelId_list = list(set(list(set(df_channel_0_notnull["logicalChannelId"].tolist()))
                              + list(set(df_channel_1_notnull["logicalChannelId.1"].tolist()))
                              + list(set(df_channel_2_notnull["logicalChannelId.2"].tolist()))))
    # channelId_list = [4.0, 5.0, 6.0]
    print(
        "df_channel_1_notnull end and channelId_list is:",
        channelId_list,
        file=f)
    # print("rnti_duration_RLC %s" % (time_list), file=f)
    # print("sorted_df_data %s" % (sorted_df_data), file=f)
    DL_RLC_UE_TPUT_DENOM_FR1 = 0.0
    if len(time_list) >= 1:
        for logicalChannelId in channelId_list:
            all_burst_action_channel = {}
            # DL_RLC_cell_duration_DRB = 0.0
            # DL_RLC_cell_VOL_DRB = 0.0
            DL_MAC_SDU_UE_TPUT_channel = {}
            df_channel0 = sorted_df_data[(sorted_df_data['logicalChannelId'] == logicalChannelId) & (
                sorted_df_data['burstId'] != 65535.0)]
            df_channel1 = sorted_df_data[(sorted_df_data['logicalChannelId.1'] == logicalChannelId) & (
                sorted_df_data['burstId.1'] != 65535.0)]
            df_channel2 = sorted_df_data[(sorted_df_data['logicalChannelId.2'] == logicalChannelId) & (
                sorted_df_data['burstId.2'] != 65535.0)]
            channel_index1 = df_channel0.index.tolist()
            channel_index2 = df_channel1.index.tolist()
            channel_index3 = df_channel2.index.tolist()
            channel_index_list0 = sorted(
                channel_index1 + channel_index2 + channel_index3)
            df_channel = sorted_df_data.loc[channel_index_list0, :]
            df_channel = df_channel.sort_values(by='timestamp', ascending=True)
            RLC_tim_DRB_cell = df_channel.iloc[-1]['timestamp'] - \
                df_channel.iloc[0]['timestamp']
            rnti_duration_RLC += RLC_tim_DRB_cell
            for cell in ue_cells:
                df_cell = sorted_df_data[(
                    sorted_df_data['physCellId'] == cell)]
                # print("cell is :{}".format(cell))
                # filtered_cell = [d for d in filter_with_basic if d['physCellId'] == cell]
                if logicalChannelId == 1.0 or logicalChannelId == 2.0:
                    continue
                df_channel = df_cell[(df_cell['logicalChannelId'] == logicalChannelId) & (
                    df_cell['burstId'] != 65535.0)]
                df_channel_1 = df_cell[(df_cell['logicalChannelId.1'] == logicalChannelId) & (
                    df_cell['burstId.1'] != 65535.0)]
                df_channel_2 = df_cell[(df_cell['logicalChannelId.2'] == logicalChannelId) & (
                    df_cell['burstId.2'] != 65535.0)]
                channel_index1 = df_channel.index.tolist()
                # print("logicalChannelId: %s, burstId: %s, index1: %s" % (logicalChannelId, burstId, index1))
                channel_index2 = df_channel_1.index.tolist()
                # print("logicalChannelId: %s, burstId: %s, index2: %s" % (logicalChannelId, burstId, index2))
                channel_index3 = df_channel_2.index.tolist()
                # print("logicalChannelId: %s, burstId: %s, index3: %s" % (logicalChannelId, burstId, index3))
                # index_burst = sorted(index1 + index2 + index3)[:-1]
                channel_index_list = sorted(
                    channel_index1 + channel_index2 + channel_index3)

                burst_list = list(set(list(set(df_channel['burstId'].tolist()))
                                      + list(set(df_channel_1['burstId.1'].tolist()))
                                      + list(set(df_channel_2['burstId.2'].tolist()))))
                # df_cell_channel = pd.merge(df_channel, df_channel_1, on=column_name_list, how='right')

                # print("burst_list {}", burst_list, file=f)
                # print("df_cell %s" % (df_cell))
                DL_MAC_cell_volume = 0.0
                DL_MAC_cell_duration = 0.0
                DL_MAC_cell_duration_Timestamp = 0.0
                DL_RLC_cell_duration = 0.0
                for burstId in burst_list:
                    # print("physCellId %s rnti %s logicalChannelId %s burstId %s burst_Duration :%s
                    # amountBytes_burst: %s" %
                    # (physCellId, rnti, logicalChannelId, burstId, burst_Duration, amountBytes_burst), file=f)
                    last_slot_time = 0.0
                    df_channel_burst = df_cell[(df_cell['burstId'] == burstId) & (
                        df_cell['logicalChannelId'] == logicalChannelId)]
                    df_channel_burst_1 = df_cell[(df_cell['burstId.1'] == burstId) & (
                        df_cell['logicalChannelId.1'] == logicalChannelId)]
                    df_channel_burst_2 = df_cell[(df_cell['burstId.2'] == burstId) & (
                        df_cell['logicalChannelId.2'] == logicalChannelId)]
                    # df_cell_channel_burst =
                    # df_channel_burst.merge(df_channel_burst_1,
                    # on=column_name_list,
                    # how='right').merge(df_channel_burst_2,

                    index1 = df_channel_burst.index.tolist()
                    # print("logicalChannelId: %s, burstId: %s, index1: %s" % (logicalChannelId, burstId, index1))
                    index2 = df_channel_burst_1.index.tolist()
                    # if cell == 574:
                    #  print("logicalChannelId.1: %s, burstId: %s, index2: %s" %
                    #  (logicalChannelId, burstId, index2), file=f)
                    index3 = df_channel_burst_2.index.tolist()
                    # print("logicalChannelId: %s, burstId: %s, index3: %s" % (logicalChannelId, burstId, index3))
                    index_burst_mac = sorted(index1 + index2 + index3)[:-1]
                    index_burst = sorted(index1 + index2 + index3)
                    if len(index_burst) > 0:
                        df_cell_channel_burst = df_cell.loc[index_burst, :]
                        df_cell_channel_burst_mac = df_cell.loc[index_burst_mac, :]
                        df_cell_burst = df_cell_channel_burst.sort_values(
                            by='timestamp', ascending=True)
                        df_cell_burst_mac = df_cell_channel_burst_mac.sort_values(
                            by='timestamp', ascending=True)
                        # print("burstid %s df_cell_burst is: %s len is %s" % (
                        # burstId, df_cell_burst, len(df_cell_burst)), file=f)
                        if len(df_cell_burst) < 1:
                            continue  # skip data only one row
                        else:
                            t_start = df_cell_burst.iloc[0]['timestamp']
                            t_stop = df_cell_burst.iloc[-1]['timestamp']
                            # print("RLC counter:", df_cell_burst, file=f)
                            # print("Debug df_cell_burst:", df_cell_burst, file=f)
                            volume_RLC, Duration_RLC = get_vol_and_time_per_burst_per_bear(
                                df_cell_burst, logicalChannelId, burstId, cell_type[int(
                                    cell)],
                                volThresDiscardDlMacSdu, durationThresDiscardDlMacSdu, f)
                            volume_last_slot, Duration_last_slot = get_vol_and_time_per_burst_per_bear(
                                df_cell_burst.iloc[-1:], logicalChannelId, burstId, cell_type[int(
                                    cell)],
                                volThresDiscardDlMacSdu, durationThresDiscardDlMacSdu, f)
                            # print("Cell {} volume_RLC is: {}", cell, volume_RLC, file=f)
                            if t_stop == sorted_df_data.iloc[-1]['timestamp']:
                                rnti_last_slot_volume = volume_last_slot
                                rnti_last_slot_duration = Duration_last_slot
                            if cell_type[int(cell)] == 'FR1_TDD':
                                last_slot_time = 0.5
                            elif cell_type[int(cell)] == 'FR1_FDD':
                                last_slot_time = 1
                            # burst_cell_duration = t_stop - t_start + last_slot_time
                            # print("Cell %s burst_cell_volume is: %s" % (cell, burst_cell_volume))
                            burst_cell_duration = np.int64(
                                t_stop - t_start + last_slot_time * 1000)
                            DL_RLC_cell_duration = round(
                                (burst_cell_duration / 1000), 1)
                            # DL_RLC_cell_duration_DRB += burst_cell_duration/1000
                            # DL_RLC_cell_VOL_DRB += volume_RLC
                            sum_cell_burst_volume += volume_RLC
                            sum_cell_burst_time += round(
                                (burst_cell_duration / 1000), 1)
                            # CB010636-D DL_RLC_PDU_UE_TPUT_DENOM_FR1
                            DL_RLC_UE_TPUT_DENOM_FR1 += (
                                DL_RLC_cell_duration * (cell_bw[int(cell)]))
                            t_stop_add = np.int64(
                                t_stop + last_slot_time * 1000)
                            # if logicalChannelId == 4 or logicalChannelId == 7:
                            # print("RLC counter:::::Cell %s logicalChannelId %s burstid %s volume_RLC %s "
                            #     "Duration_RLC %s Duration_RLC_time %s is:"
                            #      % (cell, logicalChannelId, burstId, volume_RLC, Duration_RLC,
                            #         DL_RLC_cell_duration), file=f)
                            all_burst_action_channel[index] = {'timestamp': t_start,
                                                               't_start': t_start,
                                                               't_stop': t_stop_add,
                                                               'burst_duration_slot': Duration_RLC,
                                                               'burst_duration': burst_cell_duration,
                                                               'pci': cell,
                                                               'burst_id': burstId,
                                                               'burst_volume': volume_RLC,
                                                               'last_slot_volume': volume_last_slot,
                                                               'burst_rate': volume_RLC / burst_cell_duration,
                                                               'rnti': rnti,
                                                               'action': 'start',
                                                               'logicalChannelId': logicalChannelId,
                                                               'last_slot_duration': Duration_last_slot}

                            index = index + 1
                            all_burst_action_channel[index] = {'timestamp': t_stop_add,
                                                               't_start': t_start,
                                                               't_stop': t_stop_add,
                                                               'burst_duration_slot': burst_cell_duration,
                                                               'burst_duration': DL_RLC_cell_duration,
                                                               'pci': cell,
                                                               'burst_id': burstId,
                                                               'burst_volume': volume_RLC,
                                                               'last_slot_volume': volume_last_slot,
                                                               'burst_rate': volume_RLC / burst_cell_duration,
                                                               'rnti': rnti,
                                                               'action': 'stop',
                                                               'logicalChannelId': logicalChannelId,
                                                               'last_slot_duration': Duration_last_slot}
                            index = index + 1
                            if len(df_cell_burst) >= 2:
                                volume_MAC, Duration_MAC = get_vol_and_time_per_burst_per_bear(
                                    df_cell_burst_mac, logicalChannelId, burstId, cell_type[int(
                                        cell)],
                                    volThresDiscardDlMacSdu, durationThresDiscardDlMacSdu, f)
                                # print("MAC counter:::::Cell len logicalChannelId burstid,volume_MAC,
                                # Duration_MAC is: {}", cell,
                                #     len(df_cell_burst.iloc[:-1]),
                                #     logicalChannelId,
                                # burstId, volume_MAC, Duration_MAC, file=f)
                                t_stop_mac = df_cell_burst.iloc[-2]['timestamp']
                                DL_MAC_cell_volume += volume_MAC
                                DL_MAC_cell_duration += Duration_MAC
                                # DL_MAC_cell_duration_Timestamp += (t_stop_mac - t_start +
                                # last_slot_time * 1000) / 1000
                                Duration_MAC_Timestamp = round(
                                    ((t_stop_mac - t_start + last_slot_time * 1000) / 1000), 1)
                                DL_MAC_cell_duration_Timestamp += Duration_MAC_Timestamp
                                # print("logicalChannelId %s cell %s burst_id %s ,DL_MAC_cell_duration_Timestamp %s,
                                # DL_MAC_cell_duration %s"
                                #       % (logicalChannelId, cell, burstId, Duration_MAC_Timestamp,
                                #       Duration_MAC), file=f)
                                DL_MAC_SDU_UE_TPUT_channel[cell] = \
                                    {'cellid': cell,
                                     'rnti': rnti,
                                     'DL_MAC_SDU_VOL_UE_TPUT': DL_MAC_cell_volume,
                                     'DL_MAC_SDU_TIME_UE_TPUT': DL_MAC_cell_duration_Timestamp,
                                     'DL_MAC_SDU_TIME_UE_TPUT_Timestamp': DL_MAC_cell_duration_Timestamp}
            all_burst_action_channel = sorted(
                all_burst_action_channel.items(),
                key=lambda item: item[1]['timestamp'],
                reverse=False)
            all_burst_action_channel = dict(all_burst_action_channel)
            all_burst_action[int(logicalChannelId)] = all_burst_action_channel
            DL_MAC_SDU_UE_TPUT_dic[int(
                logicalChannelId)] = DL_MAC_SDU_UE_TPUT_channel
        DL_RLC_PDU_VOL_UE_TPUT = sum_cell_burst_volume - rnti_last_slot_volume
        rnti_counter = {'rnti': rnti,
                        'pcell': ca_info_rnti['pcell'],
                        'rnti_last_slot_duration': rnti_last_slot_duration,
                        'rnti_last_slot_volume': rnti_last_slot_volume,
                        'DL_RLC_PDU_VOL_UE_TPUT': DL_RLC_PDU_VOL_UE_TPUT,
                        'DL_RLC_UE_TPUT_DENOM_FR1': DL_RLC_UE_TPUT_DENOM_FR1,
                        'DL_RLC_PDU_time': rnti_duration_RLC / 1000
                        }
    return all_burst_action, rnti_counter, DL_MAC_SDU_UE_TPUT_dic


def calculate_cc_counters(burst_action, ue_cells, rnti_last_slot,
                          f, threshold_tim=None, threshold_vol=None):
    RNTI_RLC_CC_counter = {}
    for key1 in burst_action:
        cc_index = 0
        total_burst_duration_cc = {}
        total_burst_volume_cc = {}
        burst_state_list = []
        activate_cell_list = []
        all_burst_cc = {}
        burst_new_state = {}
        merged_burst_dic_sum = {}
        merged_burst_volume_0 = 0.0
        merged_burst_cc = []
        RNTI_RLC_CC_counter_DRB = {}
        free_time_sum = 0.0
        for i in range(1, len(ue_cells) + 1):
            total_burst_duration_cc[i] = 0.0
            total_burst_volume_cc[i] = 0.0
            all_burst_cc[i] = 0.0
        burst_action_DRB = burst_action[key1]
        # print("burst_action_DRB :{}".format(key1), file=f)
        for key in burst_action_DRB:
            burst_cell = burst_action_DRB[key]
            # if burst_cell['pci'] == 577:
            # print("burst_cell is :{}".format(burst_cell), file=f)
            # print("burst_new_state is :{}".format(burst_new_state))
            if len(activate_cell_list) == 0:
                # if index == 0 and item['action'] == 'start':
                if len(burst_new_state) > 0:
                    if (burst_new_state['t_start'] ==
                            burst_new_state['t_stop']):
                        # print("merged burst end is :{}".format( burst_new_state['t_stop']), file=f)
                        free_time = burst_cell['t_start'] - \
                            burst_new_state['t_stop']
                        # print("free_time :{}".format(free_time/1000), file=f)
                        free_time_sum += free_time
                # print("free_time_sum :{}".format(free_time_sum/1000), file=f)
                burst_new_state = {'t_start': burst_cell['t_start'],
                                   't_stop': burst_cell['t_stop'],
                                   'burst_id': burst_cell['burst_id'],
                                   'pci': burst_cell['pci'],
                                   'burst_volume': burst_cell['burst_volume'],
                                   'burst_rate': float(burst_cell['burst_rate'])}
                merged_burst_start = burst_cell['t_start']
                merged_burst_stop = burst_cell['t_stop']
                merged_burst_dic = {
                    't_start': merged_burst_start,
                    't_stop': merged_burst_stop,
                    'merged_burst_volume': merged_burst_volume_0,
                    'last_slot_volume': burst_cell['last_slot_volume'],
                    'last_slot_duration': burst_cell['last_slot_duration']
                }
                # print("merged_burst_dic :{}".format(merged_burst_dic), file=f)
                activate_cell_list.append(burst_new_state['pci'])
                burst_state_list.append(burst_new_state)
                merged_burst_cc = []
            elif len(activate_cell_list) != 0:
                burst_duration_sum = 0.0
                burst_volume_sum = 0.0
                for burst in burst_state_list:
                    burst_duration_sum = burst_cell['timestamp'] - \
                        burst['t_start']
                    burst_volume = burst['burst_rate'] * \
                        (burst_cell['timestamp'] - burst['t_start'])
                    burst_volume_sum = burst_volume_sum + burst_volume
                    burst['t_start'] = burst_cell['timestamp']
                burst_cc = {'t_start': burst_new_state['t_start'],
                            't_stop': burst_cell['timestamp'],
                            'burst_id': [burst_cell['burst_id']],
                            'pci': [burst_cell['pci']],
                            'burst_volume': burst_cell['burst_volume'],
                            'cc_volume': burst_volume_sum,
                            'cc_duration': burst_duration_sum,
                            'cc': len(activate_cell_list),
                            'last_slot_volume': burst_cell['last_slot_volume'],
                            'last_slot_duration': burst_cell['last_slot_duration']
                            }
                merged_burst_cc.append(burst_cc)
                # if burst_cell['rnti'] == 59701:
                # print("burst_cc is :{}".format(burst_cc), file=f)
                burst_new_state = {'t_start': burst_cell['timestamp'],
                                   't_stop': burst_cell['t_stop'],
                                   # 'burst_id': burst_cell['burst_id'],
                                   'pci': burst_cell['pci'],
                                   'burst_volume': burst_cell['burst_volume'],
                                   'burst_rate': float(burst_cell['burst_rate']),
                                   'last_slot_volume': burst_cell['last_slot_volume'],
                                   'last_slot_duration': burst_cell['last_slot_duration'],
                                   }
                # if burst_cell['rnti'] == 59701:
                # print("burst_new_state is :{}".format(burst_new_state), file=f)
                merged_burst_stop = burst_cell['timestamp']
                merged_burst_volume_0 += burst_volume_sum
                merged_burst_dic = {'t_start': merged_burst_start,
                                    't_stop': merged_burst_stop,
                                    'merged_burst_volume': merged_burst_volume_0,
                                    'last_slot_volume': burst_cell['last_slot_volume'],
                                    'last_slot_duration': burst_cell['last_slot_duration']
                                    }
                # print("merged_burst_dic is :{}".format(merged_burst_dic), file=f)
                if burst_cell['action'] == 'start' and burst_cell['pci'] not in activate_cell_list:
                    activate_cell_list.append(burst_new_state['pci'])
                    burst_state_list.append(burst_new_state)
                    # print("burst_state_list is :{}".format(burst_state_list))
                elif burst_cell['action'] == 'start' and burst_cell['pci'] in activate_cell_list:
                    del_dic = [
                        d for d in burst_state_list if d['pci'] == burst_cell['pci']]
                    # print("del_dic1 is :{}".format(del_dic), file=f)
                    burst_state_list.remove(del_dic[0])
                    burst_state_list.append(burst_new_state)
                elif burst_cell['action'] == 'stop' and burst_cell['pci'] in activate_cell_list:
                    # print("activate_cell_list is :{}".format(activate_cell_list), file=f)
                    activate_cell_list.remove(burst_cell['pci'])
                    del_dic = [
                        d for d in burst_state_list if d['pci'] == burst_cell['pci']]
                    # print("del_dic2 is :{}".format(del_dic), file=f)
                    burst_state_list.remove(del_dic[0])
                    # print("after remove activate_cell_list is :{}".format(activate_cell_list), file=f)
                elif burst_cell['action'] == 'stop' and burst_cell['pci'] not in activate_cell_list:
                    print("pci there is time overlap", burst_cell, file=f)
                    continue
                if len(activate_cell_list) == 0:
                    if len(burst_new_state) > 0:
                        if (burst_new_state['t_start'] ==
                                burst_new_state['t_stop']):
                            time_gap = 0.0
                            merged_burst_tim_list = list(
                                merged_burst_dic_sum.keys())
                            # if len(merged_burst_dic_sum) != 0:
                            #   max_tim = max(merged_burst_tim_list)
                            #   merged_burst_before = merged_burst_dic_sum[max_tim]
                            #   time_gap = ((merged_burst_dic['t_start'] - merged_burst_before['t_stop']) / 1000)
                            #   print("time_gap :{}".format(time_gap), file=f)
                            # print("merged burst end is :{}".format(merged_burst_dic['t_stop']), file=f)
                            merged_burst_volume_0 = 0.0
                            merged_burst_vol_sum_last_slot = merged_burst_dic['merged_burst_volume']
                            merged_burst_tim_sum_last_slot = (
                                (merged_burst_dic['t_stop'] - merged_burst_dic['t_start']) / 1000)
                            merged_burst_vol_sum = merged_burst_dic['merged_burst_volume']
                            merged_burst_tim_sum = (
                                (merged_burst_dic['t_stop'] - merged_burst_dic['t_start']) / 1000)
                            if (threshold_tim is not None) and (
                                    threshold_vol is not None):
                                if (merged_burst_vol_sum < threshold_vol) or (
                                        merged_burst_tim_sum < threshold_tim):
                                    merged_burst_vol_sum = 0.0
                                    merged_burst_tim_sum = 0.0
                                    merged_burst_cc = []
                            merged_burst_dic_sum[burst_new_state['t_stop']] = {
                                't_start': merged_burst_dic['t_start'],
                                't_stop': merged_burst_dic['t_stop'],
                                'merged_burst_vol_sum': merged_burst_vol_sum,
                                'merged_burst_tim_sum': merged_burst_tim_sum,
                                'merged_burst_vol_sum_last_slot': merged_burst_vol_sum_last_slot,
                                'merged_burst_tim_sum_last_slot': merged_burst_tim_sum_last_slot,
                                'last_slot_volume': merged_burst_dic['last_slot_volume'],
                                'last_slot_duration': merged_burst_dic['last_slot_duration'],
                            }
                            # print("merged_burst_tim_sum is :{}".format(merged_burst_tim_sum), file=f)
                            if len(merged_burst_cc) >= 1:
                                item_t_stop_timestamp_max = max(
                                    merged_burst_cc, key=lambda item: item['t_stop'])
                                # print("item_t_stop_timestamp_max is :{}".format(item_t_stop_timestamp_max), file=f)
                                for item in merged_burst_cc:
                                    # if item['t_stop'] ==
                                    # item_t_stop_timestamp_max['t_stop']:
                                    if item['t_stop'] == item_t_stop_timestamp_max['t_stop']:
                                        # cc_volume = item['cc_volume'] - item['last_slot_volume']
                                        # cc_duration = item['cc_duration'] - item['last_slot_duration']
                                        cc_volume = item['cc_volume']
                                        cc_duration = item['cc_duration']
                                    else:
                                        cc_volume = item['cc_volume']
                                        cc_duration = item['cc_duration']
                                    # if cc_volume != 0:
                                    all_burst_cc[cc_index] = {'t_start': item['t_start'],
                                                              't_stop': item['t_stop'],
                                                              'burst_id': item['burst_id'],
                                                              'pci': item['pci'],
                                                              'cc_volume': cc_volume,
                                                              'cc_duration': cc_duration,
                                                              'last_slot_volume': item['last_slot_volume'],
                                                              'last_slot_duration': item['last_slot_duration'],
                                                              'cc': item['cc']}
                                    cc_index = cc_index + 1
                    merged_burst_cc = []
        # print("all_burst_cc is :{}".format(all_burst_cc), file=f)
        all_merged_burst_vol_sum = 0.0
        all_merged_burst_tim_sum = 0.0
        all_merged_burst_vol_sum_last_slot = 0.0
        all_merged_burst_tim_sum_last_slot = 0.0
        time_gap_list = []
        t_stop_list = []
        time_gap = 0.0
        merged_burst_before = {}
        merged_burst_tim_list = list(merged_burst_dic_sum.keys())
        merged_burst_tim_list.sort()
        max_tim = max(merged_burst_tim_list)
        merged_burst_max = merged_burst_dic_sum[max_tim]
        for key in merged_burst_tim_list:
            per_merged_burst = merged_burst_dic_sum[key]
            # if key1 == 4 or key1 == 7:
            # print("per_merged_burst:{}".format(per_merged_burst), file=f)
            if per_merged_burst['merged_burst_vol_sum'] != 0:
                # print("merged_burst_before len:{}".format(len(merged_burst_before)), file=f)
                if len(merged_burst_before) == 0:
                    merged_burst_before = per_merged_burst
                elif len(merged_burst_before) != 0:
                    time_gap = (
                        per_merged_burst['t_start'] - merged_burst_before['t_stop']) / 1000
                    time_gap_list.append(time_gap)
                    # print("time_gap is:{}".format(time_gap), file=f)
                    if time_gap > 1:
                        merged_burst_before['merged_burst_vol_sum'] = merged_burst_before['merged_burst_vol_sum'] - \
                            merged_burst_before['last_slot_volume']
                        merged_burst_before['merged_burst_tim_sum'] = merged_burst_before['merged_burst_tim_sum'] - \
                            merged_burst_before['last_slot_duration']
                        t_stop_list.append(merged_burst_before['t_stop'])
                    if per_merged_burst['t_stop'] == merged_burst_max['t_stop']:
                        per_merged_burst['merged_burst_vol_sum'] = per_merged_burst['merged_burst_vol_sum'] - \
                            per_merged_burst['last_slot_volume']
                        per_merged_burst['merged_burst_tim_sum'] = per_merged_burst['merged_burst_tim_sum'] - \
                            per_merged_burst['last_slot_duration']
                        merged_burst_before['merged_burst_vol_sum'] = merged_burst_before['merged_burst_vol_sum'] + \
                            per_merged_burst['merged_burst_vol_sum']
                        merged_burst_before['merged_burst_tim_sum'] = merged_burst_before['merged_burst_tim_sum'] + \
                            per_merged_burst['merged_burst_tim_sum']
                        t_stop_list.append(per_merged_burst['t_stop'])
                    all_merged_burst_vol_sum += merged_burst_before['merged_burst_vol_sum']
                    all_merged_burst_tim_sum += merged_burst_before['merged_burst_tim_sum']
                    merged_burst_before = per_merged_burst
                all_merged_burst_vol_sum_last_slot += per_merged_burst['merged_burst_vol_sum_last_slot']
                all_merged_burst_tim_sum_last_slot += per_merged_burst['merged_burst_tim_sum_last_slot']

            # print("merged_burst_time_gap_list:{}".format(time_gap_list), file=f)

        per_cc_data_before = {}
        all_burst_cc_tim_list = list(all_burst_cc.keys())
        all_burst_cc_tim_list.sort()
        cc_max_tim = max(all_burst_cc_tim_list)
        cc_burst_max = all_burst_cc[cc_max_tim]
        for key in all_burst_cc_tim_list:
            per_cc_data = all_burst_cc[key]
            if per_cc_data != 0 and per_cc_data['cc_volume'] != 0:
                if per_cc_data['t_stop'] in t_stop_list:
                    per_cc_data['cc_volume'] = per_cc_data['cc_volume'] - \
                        per_cc_data['last_slot_volume']
                    per_cc_data['cc_duration'] = per_cc_data['cc_duration'] - \
                        per_cc_data['last_slot_duration'] * 1000
                total_burst_duration_cc[per_cc_data['cc']
                                        ] += ((per_cc_data['cc_duration']) / 1000)
                total_burst_volume_cc[per_cc_data['cc']
                                      ] += per_cc_data['cc_volume']
            # this is no scenario
        # print("total_burst_duration_cc is :{} ".format(total_burst_duration_cc))
        RNTI_RLC_CC_counter[key1] = {
            'RNTI_RLC_CC_counter_VOL': total_burst_volume_cc,
            'RNTI_RLC_CC_counter_TIME': total_burst_duration_cc,
            'RNTI_RLC_Free_Time_Sum': free_time_sum / 1000,
            'RNTI_RLC_merged_burst_VOL': all_merged_burst_vol_sum,
            'RNTI_RLC_merged_burst_TIME': all_merged_burst_tim_sum,
            'RNTI_RLC_merged_burst_VOL_last_slot': all_merged_burst_vol_sum_last_slot,
            'RNTI_RLC_merged_burst_TIME_last_slot': all_merged_burst_tim_sum_last_slot,
            'ChannelId': key1
        }
    # print("Free time :{}".format(free_time_sum/1000), file=f)
    return RNTI_RLC_CC_counter


def get_burst_amount_and_time_per_cc(
        csv_file_path, cell_info, ca_info, threshold_tim=0, threshold_vol=0):
    install_and_import_numpy
    import numpy as np
    total_duration_cc_all_DRB = {}
    total_volume_cc_all_DRB = {}
    cell_type = {}
    cell_bw = {}
    DL_MAC_SDU_UE_TPUT_dic_rnti = {}
    DL_MAC_SDU_UE_TPUT_list = []
    pcell_cc_all_counter_dic = {}
    rnti_pcell_counter_dic = {}
    Cell_RLC_Counter_dic = {}
    Cell_Mac_Counter_dic = {}
    RNTI_RLC_CC_counter_dic = {}
    rnti_counter_dic = {}
    output_dir = os.path.dirname(csv_file_path)
    output_file_name = "0_check_debug_log.txt"
    output_file = os.path.join(output_dir, output_file_name)
    try:
        os.remove(output_file)
    except OSError:
        pass
    f = open(output_file, 'a')
    print("\n\n***get_RLC_value_from_L2LO_ttitrace_log for FR1***", file=f)
    install_and_import_pandas()
    import pandas as pd
    # log_file = os.path.join(log_dir, 'ttitrace_streaming', 'MacPduMuxReq.csv')
    df = pd.read_csv(csv_file_path)
    # column_data = (np.int64(df['days']) * 24 * 60 * 60 * 1000 * 1000 +
    #              np.int64(df['hours']) * 60 * 60 * 1000 * 1000 +
    #              np.int64(df['minutes']) * 60 * 1000 * 1000 +
    #              np.int64(df['seconds']) * 1000 * 1000 +
    #              np.int64(round(df['microSeconds']/1000))*1000)
    column_data = (np.int64(df['days']) * 24 * 60 * 60 * 1000 * 1000 +
                   np.int64(df['hours']) * 60 * 60 * 1000 * 1000 +
                   np.int64(df['minutes']) * 60 * 1000 * 1000 +
                   np.int64(df['seconds']) * 1000 * 1000 +
                   np.int64(df['microSeconds']))
    df['timestamp'] = column_data
    df_col_all = df.loc[:, column_name_list]
    # print("df is:{}".format(df_col_all), file=f)
    for key in cell_info:
        cell_type[key] = cell_info[key]['type']
        cell_bw[key] = cell_info[key]['BW']
    # df_col_all = df_col_all[(df_col_all['requestType'] == 'EBUILDREQUEST') & (df_col_all['sduNum'] > 1)
    #                  & (df_col_all['burstId'] != '65535')]
    df_col_all = df_col_all[(df_col_all['requestType']
                             == 'EBUILDREQUEST') & (df_col_all['sduNum'] > 1)]

    ue_cells = list(set(df_col_all["physCellId"].tolist()))
    # rnti_list = list(set(df_col_all["rnti"].tolist()))
    rnti_list = list(ca_info.keys())
    pcell_list = []
    for rnti in rnti_list:
        if ca_info[rnti]['pcell'] not in pcell_list:
            pcell_list.append(ca_info[rnti]['pcell'])
    # print("pcell_list is:{}".format(pcell_list))
    for pcell in pcell_list:
        rnti_pcell_counter_dic[pcell] = []
        pcell_cc_all_counter_dic[pcell] = []
    merged_bursts_action_all = {}
    DL_RLC_PDU_UE_TPUT_rnti = {}
    for rnti in rnti_list:
        filter_with_basic = df_col_all[(df_col_all['rnti'] == rnti)]
        # print("filter_with_basic:{}".format(filter_with_basic))
        empty_a = filter_with_basic['burstId'].isna().all()
        # print("empty_a:{}".format(type(empty_a)))
        if len(filter_with_basic) == 0 or empty_a:
            print("rnti data is not valid:{}".format(rnti), file=f)
            continue  # skip data only one row
        else:
            ca_info_rnti = ca_info[int(rnti)]
            # print("ca_info_rnti:{}".format(ca_info_rnti), file=f)
            # burst_with_action, rnti_counter, DL_MAC_SDU_UE_TPUT_dic\
            #    = get_duration_and_merged_volume_for_all_bursts(filter_with_basic, cell_type, ue_cells,
            # rnti, ca_info_rnti, cell_bw, f, threshold_tim, threshold_vol)
            burst_with_action, rnti_counter, DL_MAC_SDU_UE_TPUT_dic = get_time_and_vol_for_all_bursts_multi_bears(
                filter_with_basic, cell_type, ue_cells, rnti, ca_info_rnti, cell_bw, f, threshold_tim, threshold_vol)
            # print("DL_MAC_SDU_UE_TPUT_dic {}".format(DL_MAC_SDU_UE_TPUT_dic), file=f)
            # print("rnti_counter", rnti_counter, file=f)
            merged_bursts_action_all[rnti] = burst_with_action
            DL_MAC_SDU_UE_TPUT_dic_rnti[rnti] = DL_MAC_SDU_UE_TPUT_dic
            rnti_counter_dic[rnti] = rnti_counter
            rnti_last_slot = {'rnti_last_slot_duration': rnti_counter['rnti_last_slot_duration'],
                              'rnti_last_slot_volume': rnti_counter['rnti_last_slot_volume']}
            RNTI_RLC_CC_counter = calculate_cc_counters(
                burst_with_action, ue_cells, rnti_last_slot, f, threshold_tim, threshold_vol)
            # print("RNTI_RLC_CC_counter:{}".format(RNTI_RLC_CC_counter), file=f)
            RNTI_RLC_Free_Time_Sum = 0.0
            RNTI_RLC_merged_burst_VOL_all_DRB = 0.0
            for key in RNTI_RLC_CC_counter:
                RNTI_RLC_CC_counter[key]['pcell'] = ca_info_rnti['pcell']
                RNTI_RLC_CC_counter[key]['rnti'] = rnti
                RLC_TIM_PER_RNTI_DRB = {}
                RLC_VOL_PER_RNTI_DRB = {}
                for i in range(1, int(len(ue_cells) + 1)):
                    RLC_TIM_PER_RNTI_DRB[i] = 0.0
                    RLC_VOL_PER_RNTI_DRB[i] = 0.0
                # print("DRB {} RNTI_RLC_CC_counter:{}".format(key, RNTI_RLC_CC_counter[key]), file=f)
                RNTI_RLC_merged_burst_VOL_all_DRB += RNTI_RLC_CC_counter[key]['RNTI_RLC_merged_burst_VOL']
                RNTI_RLC_CC_counter_VOL_DRB = RNTI_RLC_CC_counter[key]['RNTI_RLC_CC_counter_VOL']
                RNTI_RLC_CC_counter_TIM_DRB = RNTI_RLC_CC_counter[key]['RNTI_RLC_CC_counter_TIME']
                for cc in RNTI_RLC_CC_counter_VOL_DRB.keys():
                    RLC_VOL_PER_RNTI_DRB[cc] += RNTI_RLC_CC_counter_VOL_DRB[cc]
                    RLC_TIM_PER_RNTI_DRB[cc] += RNTI_RLC_CC_counter_TIM_DRB[cc]
                RLC_VOL_PER_RNTI_DRB_SUM_CC = 0.0
                RLC_TIM_PER_RNTI_DRB_SUM_CC = 0.0
                for cc in RLC_VOL_PER_RNTI_DRB.keys():
                    RLC_VOL_PER_RNTI_DRB_SUM_CC += RLC_VOL_PER_RNTI_DRB[cc]
                    RLC_TIM_PER_RNTI_DRB_SUM_CC += RLC_TIM_PER_RNTI_DRB[cc]
                print("RNTI %s DRB %s RLC_VOL_PER_RNTI_DRB_SUM_CC is: %s" %
                      (rnti, key, RLC_VOL_PER_RNTI_DRB_SUM_CC), file=f)
                print("RNTI %s DRB %s RLC_TIM_PER_RNTI_DRB_SUM_CC is: %s" %
                      (rnti, key, RLC_TIM_PER_RNTI_DRB_SUM_CC), file=f)
                print(
                    "RNTI %s DRB %s RLC_VOL_PER_RNTI_DRB_MERGED is: %s" %
                    (rnti, key, RNTI_RLC_CC_counter[key]['RNTI_RLC_merged_burst_VOL']), file=f)
                print(
                    "RNTI %s DRB %s RLC_TIM_PER_RNTI_DRB_MERGED is: %s" %
                    (rnti, key, RNTI_RLC_CC_counter[key]['RNTI_RLC_merged_burst_TIME']), file=f)
            print("RNTI %s RNTI_RLC_merged_burst_VOL_all_DRB is: %s" %
                  (rnti, RNTI_RLC_merged_burst_VOL_all_DRB), file=f)
            RNTI_RLC_CC_counter_dic[rnti] = RNTI_RLC_CC_counter
            DL_RLC_PDU_TIME_UE_TPUT = (
                rnti_counter['DL_RLC_PDU_time'] -
                RNTI_RLC_Free_Time_Sum)
            rnti_counter['DL_RLC_PDU_TIME_UE_TPUT'] = DL_RLC_PDU_TIME_UE_TPUT
            # print("RNTI %s (Tm-Ts)DL_RLC_PDU_TIME_UE_TPUT is: %s ms" % (rnti, DL_RLC_PDU_TIME_UE_TPUT), file=f)
            print("RNTI %s (Vm-Vs)DL_RLC_PDU_VOL_UE_TPUT is: %s" % (rnti, rnti_counter['DL_RLC_PDU_VOL_UE_TPUT']),
                  file=f)
    for rnti in RNTI_RLC_CC_counter_dic.keys():
        RNTI_RLC_CC_counter = RNTI_RLC_CC_counter_dic[rnti]
        rnti_counter = rnti_counter_dic[rnti]
        pcell = ca_info[rnti]['pcell']
        pcell_cc_all_counter = {}
        for key1 in RNTI_RLC_CC_counter.keys():
            pcell_cc_all_counter.setdefault(
                key1, []).append(
                RNTI_RLC_CC_counter[key1])
        if rnti_counter['pcell'] == pcell:
            rnti_pcell_counter_dic[pcell].append(rnti_counter)
        if rnti_counter['pcell'] == pcell:
            pcell_cc_all_counter_dic[pcell].append(pcell_cc_all_counter)

            # DL_MAC_SDU_UE_TPUT_counter[cell].append(DL_MAC_SDU_UE_TPUT_dic[cell])
    print("pcell_cc_all_counter_dic:{}".format(
        pcell_cc_all_counter_dic), file=f)
    Cell_RLC_Counter_cell_dic = {}
    DL_RLC_PDU_VOL_UE_TPUT_all_DRB_All_pcell = 0.0
    DL_RLC_PDU_VOL_UE_TPUT_CC_all_pcell = 0.0
    DL_RLC_All_Burst_All_pcell = 0.0
    for pcell in rnti_pcell_counter_dic.keys():
        for i in range(1, int(len(ue_cells) + 1)):
            total_duration_cc_all_DRB[i] = 0.0
            total_volume_cc_all_DRB[i] = 0.0
            # get RLC merged bursted counter
        item = rnti_pcell_counter_dic[pcell]
        DL_RLC_PDU_TIM_UE_TPUT_all_DRB_Per_pcell = 0.0
        DL_RLC_PDU_VOL_UE_TPUT_all_DRB_Per_pcell = 0.0
        DL_RLC_PDU_TIM_UE_TPUT_all_DRB_Per_pcell_last_slot = 0.0
        DL_RLC_PDU_VOL_UE_TPUT_all_DRB_Per_pcell_last_slot = 0.0
        DL_RLC_PDU_UE_TPUT_DENOM_FR1_sum_DRB = 0.0
        DL_RLC_PDU_VOL_UE_TPUT_CC_Per_pcell = 0.0
        DL_RLC_PDU_TIM_UE_TPUT_CC_Per_pcell = 0.0
        for value in item:
            DL_RLC_All_Burst_All_pcell += value['DL_RLC_PDU_VOL_UE_TPUT']
            DL_RLC_PDU_UE_TPUT_DENOM_FR1_sum_DRB += value['DL_RLC_UE_TPUT_DENOM_FR1']
        print("pcell %s DL_RLC_PDU_UE_TPUT_DENOM_FR1_sum: %s" %
              (pcell, DL_RLC_PDU_UE_TPUT_DENOM_FR1_sum_DRB), file=f)
        item1 = pcell_cc_all_counter_dic[pcell]
        DL_RLC_PDU_UE_TPUT_DRB = {}
        channelid_list = []
        for value1 in item1:
            for channelid in value1.keys():
                if channelid not in channelid_list:
                    channelid_list.append(channelid)
        for DRB_ID in channelid_list:
            DL_RLC_PDU_TIME_UE_TPUT_sum_merged_DRB = 0.0
            DL_RLC_PDU_VOL_UE_TPUT_sum_merged_DRB = 0.0
            for value1 in item1:
                for channelid in value1.keys():
                    if channelid == DRB_ID:
                        item2_list = value1[channelid]
                        for item2 in item2_list:
                            print("item2:{}".format(item2), file=f)
                            DL_RLC_PDU_TIME_UE_TPUT_sum_merged_DRB += item2['RNTI_RLC_merged_burst_TIME']
                            DL_RLC_PDU_VOL_UE_TPUT_sum_merged_DRB += item2['RNTI_RLC_merged_burst_VOL']
                            DL_RLC_PDU_TIM_UE_TPUT_all_DRB_Per_pcell += item2['RNTI_RLC_merged_burst_TIME']
                            DL_RLC_PDU_VOL_UE_TPUT_all_DRB_Per_pcell += item2['RNTI_RLC_merged_burst_VOL']
                            DL_RLC_PDU_TIM_UE_TPUT_all_DRB_Per_pcell_last_slot += item2[
                                'RNTI_RLC_merged_burst_TIME_last_slot']
                            DL_RLC_PDU_VOL_UE_TPUT_all_DRB_Per_pcell_last_slot += item2[
                                'RNTI_RLC_merged_burst_VOL_last_slot']
                            DL_RLC_PDU_VOL_UE_TPUT_all_DRB_All_pcell += item2['RNTI_RLC_merged_burst_VOL']
                            item_rnti_time = item2['RNTI_RLC_CC_counter_TIME']
                            item_rnti_vol = item2['RNTI_RLC_CC_counter_VOL']
                            for cc in item_rnti_time.keys():
                                total_duration_cc_all_DRB[cc] += item_rnti_time[cc]
                                total_volume_cc_all_DRB[cc] += item_rnti_vol[cc]
            DL_RLC_PDU_UE_TPUT_DRB[DRB_ID] = {'VOL_DRB': DL_RLC_PDU_VOL_UE_TPUT_sum_merged_DRB,
                                              'TIM_DRB': DL_RLC_PDU_TIME_UE_TPUT_sum_merged_DRB}
            print("pcell %s DRB %s DL_RLC_PDU_TIME_UE_TPUT_sum_merged(Tm-Ts): %s ms" % (
                pcell, item2['ChannelId'], DL_RLC_PDU_TIME_UE_TPUT_sum_merged_DRB), file=f)
            print("pcell %s DRB %s DL_RLC_PDU_VOL_UE_TPUT_sum_merged(Vm-Vs): %s" % (
                pcell, item2['ChannelId'], DL_RLC_PDU_VOL_UE_TPUT_sum_merged_DRB), file=f)
        for cc in total_duration_cc_all_DRB.keys():
            DL_RLC_PDU_TIM_UE_TPUT_CC_Per_pcell += total_duration_cc_all_DRB[cc]
            DL_RLC_PDU_VOL_UE_TPUT_CC_Per_pcell += total_volume_cc_all_DRB[cc]
            DL_RLC_PDU_VOL_UE_TPUT_CC_all_pcell += total_volume_cc_all_DRB[cc]
        print(
            "pcell %s all DRB DL_RLC_PDU_TIME_UE_TPUT_CC_SUM(ta+(tg-ts)+tb): %s" %
            (pcell, DL_RLC_PDU_TIM_UE_TPUT_CC_Per_pcell), file=f)
        print(
            "pcell %s all DRB DL_RLC_PDU_VOL_UE_TPUT_CC_SUM(va+(vg-Vs)+vb): %s" %
            (pcell, DL_RLC_PDU_VOL_UE_TPUT_CC_Per_pcell), file=f)
        print(
            "pcell %s all DRB DL_RLC_PDU_TIME_UE_TPUT_sum_merged(Tm-Ts) %s" %
            (pcell, DL_RLC_PDU_TIM_UE_TPUT_all_DRB_Per_pcell), file=f)
        print(
            "pcell %s all DRB DL_RLC_PDU_VOL_UE_TPUT_sum_merged(Vm-Vs): %s" %
            (pcell, DL_RLC_PDU_VOL_UE_TPUT_all_DRB_Per_pcell), file=f)
        print(
            "pcell %s all DRB DL_RLC_PDU_TIME_UE_TPUT_sum_merged_last_slot(Tm-Ts) %s" %
            (pcell, DL_RLC_PDU_TIM_UE_TPUT_all_DRB_Per_pcell_last_slot), file=f)
        print(
            "pcell %s all DRB DL_RLC_PDU_VOL_UE_TPUT_sum_merged_last_slot(Vm-Vs): %s" %
            (pcell, DL_RLC_PDU_VOL_UE_TPUT_all_DRB_Per_pcell_last_slot), file=f)
        print("pcell %s DL_RLC_TIM_UE_TPUT_FR1_SA_1CC: %s" %
              (pcell, total_duration_cc_all_DRB[1]), file=f)
        print("pcell %s DL_RLC_VOL_UE_TPUT_FR1_SA_1CC: %s" %
              (pcell, total_volume_cc_all_DRB[1]), file=f)
        Cell_RLC_Counter_cell_dic[pcell] = \
            {'DL_RLC_TIM_UE_TPUT_FR1_SA_CC': total_duration_cc_all_DRB,
             'DL_RLC_VOL_UE_TPUT_FR1_SA_CC': total_volume_cc_all_DRB,
             'DL_RLC_PDU_TIME_UE_TPUT_sum_CC': DL_RLC_PDU_TIM_UE_TPUT_CC_Per_pcell,
             'DL_RLC_PDU_VOL_UE_TPUT_sum_CC': DL_RLC_PDU_VOL_UE_TPUT_CC_Per_pcell,
             'DL_RLC_PDU_TIME_UE_TPUT_sum_merged': DL_RLC_PDU_TIM_UE_TPUT_all_DRB_Per_pcell,
             'DL_RLC_PDU_VOL_UE_TPUT_sum_merged': DL_RLC_PDU_VOL_UE_TPUT_all_DRB_Per_pcell,
             'DL_RLC_PDU_UE_TPUT_DENOM_FR1_sum': DL_RLC_PDU_UE_TPUT_DENOM_FR1_sum_DRB,
             'RLC_UE_TPUT_DRB': DL_RLC_PDU_UE_TPUT_DRB}
    Cell_RLC_Counter_dic = Cell_RLC_Counter_cell_dic
    DL_MAC_VOL_sum_all_for_debug_rlc = 0.0
    for cell in ue_cells:
        DL_MAC_SDU_TIME_UE_TPUT_sum = 0.0
        DL_MAC_SDU_VOL_UE_TPUT_sum = 0.0
        DL_MAC_SDU_TIME_UE_TPUT_Timestamp_sum = 0.0
        DL_MAC_SDU_UE_TPUT_counter = {}
        for rnti in DL_MAC_SDU_UE_TPUT_dic_rnti.keys():
            DL_MAC_SDU_UE_TPUT_dic = DL_MAC_SDU_UE_TPUT_dic_rnti[rnti]
            for channelid in DL_MAC_SDU_UE_TPUT_dic.keys():
                DL_MAC_SDU_UE_TPUT_channel = DL_MAC_SDU_UE_TPUT_dic[channelid]
                if cell in DL_MAC_SDU_UE_TPUT_channel.keys():
                    DL_MAC_SDU_UE_TPUT_counter.setdefault(
                        cell, []).append(
                        DL_MAC_SDU_UE_TPUT_channel[cell])
        # print("DL_MAC_SDU_UE_TPUT_counter:", DL_MAC_SDU_UE_TPUT_counter, file=f)
        for key in DL_MAC_SDU_UE_TPUT_counter.keys():
            item = DL_MAC_SDU_UE_TPUT_counter[key]
            for key1 in item:
                DL_MAC_SDU_TIME_UE_TPUT_sum += key1['DL_MAC_SDU_TIME_UE_TPUT']
                DL_MAC_SDU_VOL_UE_TPUT_sum += key1['DL_MAC_SDU_VOL_UE_TPUT']
                DL_MAC_VOL_sum_all_for_debug_rlc += key1['DL_MAC_SDU_VOL_UE_TPUT']
        print("cell %s DL_MAC_SDU_TIME_UE_TPUT_sum: %s" %
              (key, DL_MAC_SDU_TIME_UE_TPUT_sum), file=f)
        print("cell %s DL_MAC_SDU_VOL_UE_TPUT_sum: %s" %
              (key, DL_MAC_SDU_VOL_UE_TPUT_sum), file=f)
        Cell_Mac_Counter_dic[cell] = {'DL_MAC_SDU_TIME_UE_TPUT_sum': DL_MAC_SDU_TIME_UE_TPUT_sum,
                                      'DL_MAC_SDU_VOL_UE_TPUT_sum': DL_MAC_SDU_VOL_UE_TPUT_sum}
    print("DL_MAC_VOL_sum_all_for_debug_rlc:",
          DL_MAC_VOL_sum_all_for_debug_rlc, file=f)
    print("DL_RLC_All_Burst_All_pcell For Debug:",
          DL_RLC_All_Burst_All_pcell, file=f)
    print("DL_RLC_PDU_VOL_UE_TPUT_merged_all_pcell(Vm-Vs):",
          DL_RLC_PDU_VOL_UE_TPUT_all_DRB_Per_pcell, file=f)
    print("DL_RLC_PDU_VOL_UE_TPUT_CC_all_pcell(va + (vg-Vs) + vb):",
          DL_RLC_PDU_VOL_UE_TPUT_CC_all_pcell, file=f)
    print("Cell_Mac_Counter_dic: {}", Cell_Mac_Counter_dic, file=f)
    print("Cell_RLC_Counter_dic: {}", Cell_RLC_Counter_dic, file=f)
    f.close()
    return Cell_RLC_Counter_dic, Cell_Mac_Counter_dic


def add_timestamp_to_csv(file_path):
    install_and_import_numpy
    install_and_import_pandas
    import numpy as np
    import pandas as pd
    df = pd.read_csv(file_path)
    column_data = (np.int64(df['days']) * 24 * 60 * 60 * 1000 * 1000 +
                   np.int64(df['hours']) * 60 * 60 * 1000 * 1000 +
                   np.int64(df['minutes']) * 60 * 1000 * 1000 +
                   np.int64(df['seconds']) * 1000 * 1000 +
                   np.int64(df['microSeconds']))
    df['timestamp'] = column_data
    df.to_csv(file_path, index=False)


def get_rnti_and_ca_from_csv(Emil_file_path, cell_info):
    install_and_import_pandas
    import pandas as pd
    df = pd.read_csv(Emil_file_path)
    df_col_all = df.loc[:, Emil_column_name_list]
    # print("df is:{}".format(df_col_all))
    # strings_to_check = ['F1AP-PDU : successfulOutcome', 'UEContextModificationResponse']
    # pattern = '|'.join(strings_to_check)
    df_data = df_col_all[(df_col_all['Message body'].str.contains(
        'IgNBCAUeContextSetupRequest'))]
    df_data_none_CA = df_col_all[(
        df_col_all['Message body'].str.contains('InitialULRRCMessageTransfer'))]
    # print("df_data_none_CA is:{}".format(df_data_none_CA))
    # filtered_dic_sort = sorted(df_data, key=lambda x: x['timestamp'], reverse=False)
    message_list = list(set(df_data["Time"].tolist()))
    message_list_none_CA = list(set(df_data_none_CA["Time"].tolist()))
    # print("message_list_none_CA is:{}".format(len(message_list_none_CA)))
    # waitForStartLine, waitForEndLine = True, False
    ue_ca_info_dict = {}
    ue_none_ca_info_dict = {}
    rnti_re = re.compile('C-RNTI : (\\d+)')
    pcell_pci_re = re.compile(
        'NRCGI : {\\s[\\s\\S]+?nRCellIdentity\\s[\\s\\S]+?\\((\\d+)\\)')
    scell_pci_re = re.compile(
        'sCell-ID {\\s[\\s\\S]+?nRCellIdentity\\s[\\s\\S]+?\\((\\d+)\\)')
    ul_scell_pci_re = re.compile(
        'physcellid (\\d+)[\\s\\S]+?uplinkconfigcommon')
    if len(message_list_none_CA) >= 1:
        for message in message_list_none_CA:
            filter_with_basic = df_data_none_CA[(
                df_data_none_CA['Time'] == message)]
            message_series = filter_with_basic['Message body']
            message_len = len(message_series)
            # print("message_list_none_CA is:{}".format(message_len))
            # message_string = message_series[0]
            pcell_pci_list = pcell_pci_re.findall(
                message_series.iloc[0], re.IGNORECASE)
            # print("pcell_pci_re is:{}".format(pcell_pci_list))
            rnti_list = rnti_re.findall(message_series.iloc[0], re.IGNORECASE)
            # print("rnti_re is:{}".format(rnti_list))
            # ul_scell_pci_list = ul_scell_pci_re.findall(message, re.IGNORECASE)
            if rnti_list and pcell_pci_list:
                rnti = int(rnti_list[0])
                pcell_pci = int(pcell_pci_list[0])
                ue_none_ca_info_dict[rnti] = {'pcell': pcell_pci,
                                              'dl_scell': [],
                                              'DL_CA_UE': False}
    if len(message_list) >= 1:
        for message in message_list:
            filter_with_basic = df_data[(df_data['Time'] == message)]
            message_series = filter_with_basic['Message body']
            message_len = len(message_series)
            # message_string = message_series[0]
            pcell_pci_list = pcell_pci_re.findall(
                message_series.iloc[0], re.IGNORECASE)
            print("pcell_pci_re is:{}".format(pcell_pci_list))
            scell_pci_list = scell_pci_re.findall(
                message_series.iloc[0], re.IGNORECASE)
            print("scell_pci_re is:{}".format(scell_pci_list))
            rnti_list = rnti_re.findall(message_series.iloc[0], re.IGNORECASE)
            print("rnti_re is:{}".format(rnti_list))
            # ul_scell_pci_list = ul_scell_pci_re.findall(message, re.IGNORECASE)
            if rnti_list and pcell_pci_list:
                rnti = int(rnti_list[0])
                pcell_pci = int(pcell_pci_list[0])
                ue_ca_info_dict[rnti] = {'pcell': pcell_pci,
                                         'dl_scell': [],
                                         'DL_CA_UE': ''}
                for scell_pci in scell_pci_list:
                    if scell_pci not in ue_ca_info_dict[rnti]['dl_scell']:
                        ue_ca_info_dict[rnti]['dl_scell'].append(
                            int(scell_pci))
                # if len(ul_scell_pci_list) > 0:
                #     del(ul_scell_pci_list[0])
                # for scell_pci in ul_scell_pci_list:
                        #   if not scell_pci in ue_ca_info_dict[rnti]['ul_scell']:
            #      ue_ca_info_dict[rnti]['ul_scell'].append(int(scell_pci))
            if ue_ca_info_dict:
                for rnti, cainfo_dcit in ue_ca_info_dict.items():
                    cainfo_dcit['DL_CA_UE'] = True if len(
                        cainfo_dcit['dl_scell']) > 0 else False
    rnti_CA_LIST = ue_ca_info_dict.keys()
    print("rnti_CA_LIST is:{}".format(rnti_CA_LIST))
    for rnti in ue_none_ca_info_dict:
        if rnti not in rnti_CA_LIST:
            ue_ca_info_dict[rnti] = ue_none_ca_info_dict[rnti]
    for key in ue_ca_info_dict:
        pcell_id = ue_ca_info_dict[key]['pcell']
        scell_id = ue_ca_info_dict[key]['dl_scell']
        for key1 in cell_info:
            if cell_info[key1]['NRcellID'] == pcell_id:
                ue_ca_info_dict[key]['pcell'] = key1
            elif cell_info[key1]['NRcellID'] in scell_id:
                PCI = cell_info[key1]['NRcellID']
                index = (ue_ca_info_dict[key]['dl_scell']).index(PCI)
                print("PCI index is :{}".format(index))
                ue_ca_info_dict[key]['dl_scell'][index] = key1
    print("ue_ca_info_dict is:{}".format(ue_ca_info_dict))
    return ue_ca_info_dict


def merge_csv_list_of_dicts(file_path, file_name, log_year=datetime.now().year,
                            log_month=datetime.now().month, log_day=datetime.now().day,):
    install_and_import_pandas()
    import pandas as pd
    regex_pattern = rf"**/*{file_name}"
    # csv_files = glob.glob("%s/*.csv" % file_path, recursive=True)
    # csv_files = glob.glob(os.path.join(file_path, '**/*.csv'), recursive=True)
    csv_files = glob.glob(
        os.path.join(
            file_path,
            regex_pattern),
        recursive=True)
    print("csv_files is :{}".format(csv_files))
    dfs = [pd.read_csv(file, on_bad_lines='warn', low_memory=False)
           for file in csv_files]
    merged_df = pd.concat(dfs, ignore_index=True)
    current_time = datetime.now()
    filename_merged = 'merged_files'
    new_filename = f"{filename_merged}_{current_time}.csv"
    # merged_df.sort_values(by=['timestamp'], ascending=True, inplace=False)
    merged_df.to_csv(os.path.join(file_path, new_filename), index=False)
    return os.path.join(file_path, new_filename)


def calculate_waiting_time_for_log_capturing_or_log_generation(
        reporting_interval, cur_timestamp):
    reporting_interval = int(reporting_interval)
    # cur_timestamp = get_timestamp_from_gnb(connection=connection)
    logging.info("cur_timestamp is {}".format(cur_timestamp))
    cur_min = cur_timestamp.minute
    cur_sec = cur_timestamp.second
    wait_time = (reporting_interval - (cur_min % reporting_interval))
    logging.info("wait_time {}".format(wait_time))
    wait_time_sec = (reporting_interval - (cur_min %
                     reporting_interval)) * 60 - cur_sec
    timestamp_after_wait = (cur_timestamp + timedelta(minutes=wait_time) -
                            timedelta(minutes=reporting_interval)).strftime("%Y-%m-%d %H:%M")
    dict_time_info = {"wait_time": wait_time, "wait_time_sec": wait_time_sec,
                      "log_generator_timestamp": timestamp_after_wait,
                      "cur_timestamp": cur_timestamp}
    return dict_time_info


def get_timestamp_from_gnb(connection="ASIK Master"):
    cmd_get_timestamp = 'date "+%Y-%m-%d %H:%M:%S"'
    cur_timestamp_str = ssh.execute(
        command=cmd_get_timestamp,
        connection=connection).strip()
    logging.debug(
        "Execute command: {}, output: {}".format(
            cmd_get_timestamp,
            cur_timestamp_str))
    cur_timestamp = datetime.strptime(cur_timestamp_str, '%Y-%m-%d %H:%M:%S')
    return cur_timestamp
