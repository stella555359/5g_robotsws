# -*- coding: UTF-8 -*-
# author : zhangwenchao
# version: 1.0

import glob
import pandas as pd
import os
import sys
import logging
import re

pd.set_option('display.max_columns', 1000)
pd.set_option('display.width', 1000)
pd.set_option('display.max_colwidth', 1000)
pd.set_option('display.unicode.ambiguous_as_wide', True)
pd.set_option('display.unicode.east_asian_width', True)
pd.set_option('precision', 2)
pd.set_option('colheader_justify', 'middle')
pd.set_option('mode.chained_assignment', None)


def get_ttitrace_file(file_path):
    lists = glob.glob('{}'.format(os.path.join(file_path, '*.csv')))
    return lists


def _crnti(merge_data):
    crnti_list = []
    if 'ETtiTraceDlParUe_crnti' in merge_data.head(0):
        for element in merge_data['ETtiTraceDlParUe_crnti'].unique():
            if len(element) > 1:
                crnti_list.append(element)
    else:
        for element in merge_data['ETtiTraceUlParUe_crnti'].unique():
            if len(element) > 1:
                crnti_list.append(element)
    return sorted(crnti_list)


def _ueIndex(merge_data):
    child_dict = {}
    if 'ETtiTraceDlParUe_crnti' in merge_data.head(0):
        for element in merge_data['ETtiTraceDlParUe_crnti'].unique():
            if len(element) > 1:
                value = merge_data['ETtiTraceDlParUe_ueIndex'][(merge_data['ETtiTraceDlParUe_crnti'] == element)] \
                    .unique()
                child_dict[element] = value[0]
    else:
        for element in merge_data['ETtiTraceUlParUe_crnti'].unique():
            if len(element) > 1:
                value1 = merge_data.loc[(merge_data['ETtiTraceUlParUe_crnti'] == element),
                                        'ETtiTraceUlParUe_ueIndex'].unique()
                child_dict[element] = value1[0]
    return child_dict


def _thoughput(merge_data):
    child_dict = {}
    cell_throughput = 0
    if 'ETtiTraceDlParUe_crnti' in merge_data.head(0):
        for element in merge_data['ETtiTraceDlParUe_crnti'].unique():
            if len(element) > 1:
                value1 = merge_data.loc[(merge_data['ETtiTraceDlParUe_crnti'] == element) & (
                    merge_data['ETtiTraceDlParUe_trNumCW1'] == 'New_trans'),
                    'ETtiTraceDlParUe_tbsCw1'].astype(int).sum()
                timed1 = merge_data.loc[(merge_data['ETtiTraceDlParUe_crnti'] == element)
                                        & (merge_data['ETtiTraceDlParUe_trNumCW1'] == 'New_trans'), 'Time']
                value2 = merge_data.loc[(merge_data['ETtiTraceDlParUe_crnti'] == element)
                                        & (merge_data['ETtiTraceDlParUe_trNumCW2'] == 'New_trans'),
                                        'ETtiTraceDlParUe_tbsCw2'].astype(int).sum()
                timed2 = merge_data.loc[(merge_data['ETtiTraceDlParUe_crnti'] == element)
                                        & (merge_data['ETtiTraceDlParUe_trNumCW2'] == 'New_trans'), 'Time']
                gap_time1 = (_convert_time(timed1.tolist()[-1]) - _convert_time(timed1.tolist()[0]))
                if value2 != 0:
                    gap_time2 = (_convert_time(timed2.tolist()[-1]) - _convert_time(timed2.tolist()[0]))
                else:
                    gap_time2 = 0
                gap_time = gap_time1 if gap_time1 > gap_time2 else gap_time2
                throughput = ((value1 * 1000) + (value2 * 1000)) * 8 / gap_time
                # print(element, value1, value2, gap_time1, timed1.tolist()[-1], _convert_time(timed1.tolist()[0]),
                # _convert_time(timed1.tolist()[-1]), gap_time2)
                cell_throughput += throughput
                child_dict[element] = throughput
            child_dict['cell_throughput'] = cell_throughput
    else:
        for element in merge_data['ETtiTraceUlParUe_crnti'].unique():
            if len(element) > 1:
                value1 = merge_data.loc[(merge_data['ETtiTraceUlParUe_crnti'] == element) & (
                    merge_data['ETtiTraceUlParUe_trNumCw1'] == 'New_trans'), 'ETtiTraceUlParUe_tbsCw1'].astype(
                    int).sum()
                timed1 = merge_data.loc[(merge_data['ETtiTraceUlParUe_crnti'] == element) & (
                                        merge_data['ETtiTraceUlParUe_trNumCw1'] == 'New_trans'), 'Time']
                gap_time1 = (_convert_time(timed1.tolist()[-1]) - _convert_time(timed1.tolist()[0]))
                gap_time = gap_time1
                throughput = ((value1 * 1000)) * 8 / gap_time
                cell_throughput += throughput
                child_dict[element] = throughput
            child_dict['cell_throughput'] = cell_throughput
    return child_dict


def _numberOfPrbAlloc(merge_data):
    df = {}
    if 'ETtiTraceDlParUe_crnti' in merge_data.head(0):
        for element in merge_data['ETtiTraceDlParUe_crnti'].unique():
            if len(element) > 1:
                crnti_df = {}
                value = merge_data.loc[(merge_data['ETtiTraceDlParUe_crnti'] == element) & (
                                       merge_data['ETtiTraceDlParUe_numberOfPrbAlloc'] != '-'),
                                       'ETtiTraceDlParUe_numberOfPrbAlloc']
                crnti_df['min'] = '%d' % value.astype(float).min()
                crnti_df['max'] = '%d' % value.astype(float).max()
                crnti_df['average'] = '%0.2f' % value.astype(float).mean()
                df[element] = crnti_df
    else:
        for element in merge_data['ETtiTraceUlParUe_crnti'].unique():
            if len(element) > 1:
                crnti_df = {}
                value = merge_data.loc[(merge_data['ETtiTraceUlParUe_crnti'] == element) & (
                                       merge_data['ETtiTraceUlParUe_numberofPrbAlloc'] != '-'),
                                       'ETtiTraceUlParUe_numberofPrbAlloc']
                crnti_df['min'] = '%d' % value.astype(float).min()
                crnti_df['max'] = '%d' % value.astype(float).max()
                crnti_df['average'] = '%0.2f' % value.astype(float).mean()
                df[element] = crnti_df
    return df


def _mcsIndexCw1(merge_data):
    df = {}
    if 'ETtiTraceDlParUe_crnti' in merge_data.head(0):
        for element in merge_data['ETtiTraceDlParUe_crnti'].unique():
            if len(element) > 1:
                crnti_df = {}
                value = merge_data.loc[
                    (merge_data['ETtiTraceDlParUe_crnti'] == element)
                    & (merge_data['ETtiTraceDlParUe_mcsIndexCw1'] != '-')
                    & (merge_data['ETtiTraceDlParUe_mcsIndexCw1'] != '29')
                    & (merge_data['ETtiTraceDlParUe_mcsIndexCw1'] != '30')
                    & (merge_data['ETtiTraceDlParUe_mcsIndexCw1'] != '31'), 'ETtiTraceDlParUe_mcsIndexCw1']
                crnti_df['min'] = '%0.0f' % value.astype(float).min()
                crnti_df['max'] = '%0.0f' % value.astype(float).max()
                crnti_df['average'] = '%0.0f' % value.astype(float).mean()
                df[element] = crnti_df
    else:
        for element in merge_data['ETtiTraceUlParUe_crnti'].unique():
            if len(element) > 1:
                crnti_df = {}
                value = merge_data.loc[
                    (merge_data['ETtiTraceUlParUe_crnti'] == element)
                    & (merge_data['ETtiTraceUlParUe_mcsIndexCw1'] != '-')
                    & (merge_data['ETtiTraceUlParUe_mcsIndexCw1'] != '29')
                    & (merge_data['ETtiTraceUlParUe_mcsIndexCw1'] != '30')
                    & (merge_data['ETtiTraceUlParUe_mcsIndexCw1'] != '31'), 'ETtiTraceUlParUe_mcsIndexCw1']
                crnti_df['min'] = '%0.0f' % value.astype(float).min()
                crnti_df['max'] = '%0.0f' % value.astype(float).max()
                crnti_df['average'] = '%0.0f' % value.astype(float).mean()
                df[element] = crnti_df
    return df


def _mcsIndexCw2(merge_data):
    df = {}
    if 'ETtiTraceDlParUe_crnti' in merge_data.head(0):
        for element in merge_data['ETtiTraceDlParUe_crnti'].unique():
            if len(element) > 1:
                crnti_df = {}
                value = merge_data.loc[
                    (merge_data['ETtiTraceDlParUe_crnti'] == element)
                    & (merge_data['ETtiTraceDlParUe_mcsIndexCw2'] != '-')
                    & (merge_data['ETtiTraceDlParUe_mcsIndexCw2'] != '29')
                    & (merge_data['ETtiTraceDlParUe_mcsIndexCw2'] != '30')
                    & (merge_data['ETtiTraceDlParUe_mcsIndexCw2'] != '31'), 'ETtiTraceDlParUe_mcsIndexCw2']
                crnti_df['min'] = '%0.0f' % value.astype(float).min()
                crnti_df['max'] = '%0.0f' % value.astype(float).max()
                crnti_df['average'] = '%0.0f' % value.astype(float).mean()
                df[element] = crnti_df
    else:
        for element in merge_data['ETtiTraceUlParUe_crnti'].unique():
            if len(element) > 1:
                crnti_df = {}
                crnti_df['min'] = ''
                crnti_df['max'] = ''
                crnti_df['average'] = ''
                df[element] = crnti_df
    return df


def _dataInDrb1(merge_data):
    df = {}
    if 'ETtiTraceDlParUe_crnti' in merge_data.head(0):
        for element in merge_data['ETtiTraceDlParUe_crnti'].unique():
            if len(element) > 1:
                crnti_df = {}
                value = merge_data.loc[
                    (merge_data['ETtiTraceDlParUe_crnti'] == element)
                    & (merge_data['ETtiTraceDlParUe_dataInDrb1'] != '-'), 'ETtiTraceDlParUe_dataInDrb1']
                crnti_df['min'] = '%d' % value.astype(float).min()
                crnti_df['max'] = '%d' % value.astype(float).max()
                crnti_df['average'] = '%d' % value.astype(float).mean()
                if len(crnti_df['min']) < 2:
                    logging.info("crnti {} min buffer is {} !".format(element, crnti_df['min']))
                df[element] = crnti_df
    else:
        for element in merge_data['ETtiTraceUlParUe_crnti'].unique():
            if len(element) > 1:
                crnti_df = {}
                value = merge_data.loc[(merge_data['ETtiTraceUlParUe_crnti'] == element) & (
                                       merge_data['ETtiTraceUlParUe_bitsInLcg3'] != '-'), 'ETtiTraceUlParUe_bitsInLcg3']
                crnti_df['min'] = '%d' % value.astype(float).min()
                crnti_df['max'] = '%d' % value.astype(float).max()
                crnti_df['average'] = '%d' % value.astype(float).mean()
                df[element] = crnti_df
    return df


def _convert_time(timed):
    timed = timed.split(':')
    if timed[0] == '00':
        return int(timed[3]) + (int(timed[2]) + int(timed[1]) * 60 + 24 * 3600) * 1000
    else:
        return int(timed[3]) + (int(timed[2]) + int(timed[1]) * 60 + int(timed[0]) * 3600) * 1000


def _ackNackDtxCw1(merge_data):
    crnti_df = {}
    if 'ETtiTraceDlParUe_crnti' in merge_data.head(0):
        for element in merge_data['ETtiTraceDlParUe_crnti'].unique():
            total_num = 0
            total_ack = 0
            if len(element) > 1:
                value1 = merge_data.loc[(merge_data['ETtiTraceDlParUe_crnti'] == element)
                                        & (merge_data['EHarqParDl_ackNackDtxCw1'] != '-'), 'EHarqParDl_ackNackDtxCw1'] \
                                        .count()
                if value1 != 0:
                    total_num += value1
                    value3 = merge_data.loc[(merge_data['ETtiTraceDlParUe_crnti'] == element)
                                            & (merge_data['EHarqParDl_ackNackDtxCw1'] == 'ACK'),
                                            'EHarqParDl_ackNackDtxCw1'].count()
                    total_ack += value3
                    bler = round((1-float(total_ack)/float(total_num)), 4)
                    crnti_df[element] = '%0.2f%%' % (bler*100)
                else:
                    crnti_df[element] = '-'
    else:
        for element in merge_data['ETtiTraceUlParUe_crnti'].unique():
            total_num = 0
            total_ack = 0
            if len(element) > 1:
                value1 = merge_data.loc[(merge_data['ETtiTraceUlParUe_crnti'] == element)
                                        & (merge_data['EHarqParUl_ackNackDtxCw1'] != '-'),
                                        'EHarqParUl_ackNackDtxCw1'].count()
                if value1 != 0:
                    total_num += value1
                    value3 = merge_data.loc[(merge_data['ETtiTraceUlParUe_crnti'] == element) & (
                                            merge_data['EHarqParUl_ackNackDtxCw1'] == 'ACK'),
                                            'EHarqParUl_ackNackDtxCw1'].count()
                    total_ack += value3
                    bler = round((1 - float(total_ack) / float(total_num)), 4)
                    crnti_df[element] = '%0.2f%%' % (bler*100)
                else:
                    crnti_df[element] = '-'
    return crnti_df


def _ackNackDtxCw2(merge_data):
    crnti_df = {}
    if 'ETtiTraceDlParUe_crnti' in merge_data.head(0):
        for element in merge_data['ETtiTraceDlParUe_crnti'].unique():
            total_num = 0
            total_ack = 0
            if len(element) > 1:
                value1 = merge_data.loc[(merge_data['ETtiTraceDlParUe_crnti'] == element)
                                        & (merge_data['EHarqParDl_ackNackDtxCw2'] != '-'),
                                        'EHarqParDl_ackNackDtxCw2'].count()
                total_num += value1
                value3 = merge_data.loc[(merge_data['ETtiTraceDlParUe_crnti'] == element)
                                        & (merge_data['EHarqParDl_ackNackDtxCw2'] == 'ACK'),
                                        'EHarqParDl_ackNackDtxCw2'].count()
                total_ack += value3
                if total_num != 0:
                    bler = round((1-float(total_ack)/float(total_num)), 4)
                    crnti_df[element] = '%0.2f%%' % (bler*100)
                else:
                    crnti_df[element] = ''
    else:
        for element in merge_data['ETtiTraceUlParUe_crnti'].unique():
            if len(element) > 1:
                crnti_df[element] = ''
    return crnti_df


def _get_pair_rate(merge_data):
    total = merge_data[merge_data['ETtiTraceDlParUe_muStatus'] != '-']['ETtiTraceDlParUe_muStatus'].count()
    pair_num = merge_data[merge_data['ETtiTraceDlParUe_muStatus'] == 'Pair']['ETtiTraceDlParUe_muStatus'].count()
    pair_rate = round((float(pair_num)/float(total)), 4)
    return pair_rate


def _td_fd_ue_num(merge_data, row=5):
    if 'ETtiTraceDlParUe_crnti' in merge_data.head(0):
        merge_data['ETtiTraceDlParCell_numUesTdEnd'] = merge_data['ETtiTraceDlParCell_numUesTdEnd'].astype('int')
        merge_data['ETtiTraceDlParCell_numUesFd'] = merge_data['ETtiTraceDlParCell_numUesFd'].astype('int')
        crnti_list = merge_data['ETtiTraceDlParUe_crnti'].unique()
        data = merge_data[merge_data['ETtiTraceDlParUe_crnti'].isin(crnti_list)]
        data['tdfd_diff'] = data['ETtiTraceDlParCell_numUesTdEnd']-data['ETtiTraceDlParCell_numUesFd']
        df = data[data['tdfd_diff'] != 0][['Time', 'ETtiTraceDlParCell_sfn', 'ETtiTraceDlParCell_esfn',
                                           'ETtiTraceDlParCell_numUesTdEnd', 'ETtiTraceDlParCell_numUesFd']]
        if df.shape[0] > 0:
            print('='*71+'td fd diff'+'='*71)
            print(df.reset_index(drop=True).head(row))
            print('='*152)
        else:
            pass


def _cellid(merge_data):
    if 'ETtiTraceDlParCell_cellId' in merge_data.head(0):
        cell_id_list = merge_data.loc[
            ((merge_data['ETtiTraceDlParCell_cellId'] != '-') & (merge_data['ETtiTraceDlParCell_cellId'] != '0')),
            'ETtiTraceDlParCell_cellId'].unique()
    else:
        cell_id_list = merge_data.loc[
            ((merge_data['ETtiTraceUlParCell_cellId'] != '-') & (merge_data['ETtiTraceUlParCell_cellId'] != '0')),
            'ETtiTraceUlParCell_cellId'].unique()
    if len(cell_id_list):
        return cell_id_list[0]
    else:
        return None


def _tm_mode(merge_data):
    tm_dict = {}
    rate_max = 0
    if 'ETtiTraceDlParUe_transScheme' in merge_data.head(0):
        tm_types = merge_data['ETtiTraceDlParUe_transScheme'].unique()
        total = merge_data.loc[(merge_data['ETtiTraceDlParUe_transScheme'] != '-'),
                               'ETtiTraceDlParUe_transScheme'].count()
        if total > 0:
            for tm_type in tm_types:
                tm_count = merge_data.loc[(merge_data['ETtiTraceDlParUe_transScheme'] == tm_type),
                                          'ETtiTraceDlParUe_transScheme'].count()
                rate = round(float(tm_count)/float(total), 4)
                tm_dict[rate] = tm_type
                if rate > rate_max:
                    rate_max = rate
            return 'TM mode:%s, rate:%0.2f%%.' % (tm_dict[rate_max], rate_max*100)
    else:
        return ''


def _ProactiveAssignment(merge_data):
    proactive_by_crnti_dict = {}
    if 'ETtiTraceUlParUe_rrmScheduleTag' in merge_data.head(0):
        crntis = merge_data[merge_data['ETtiTraceUlParUe_crnti'] != '-']['ETtiTraceUlParUe_crnti'].unique()
        for crnti in crntis:
            proavtive_period = merge_data[(merge_data['ETtiTraceUlParUe_crnti'] == crnti) &
                                          (merge_data['ETtiTraceUlParUe_rrmScheduleTag'] == 'ProactiveAssignment')]
            proavtive_period['Time'] = proavtive_period['Time'].\
                apply(lambda x: int(x.split(':')[0])*3600*1000 + int(x.split(':')[1])*60*1000 +
                      int(x.split(':')[2])*1000 + int(x.split(':')[3]))
            proavtive_period['timedelta'] = proavtive_period['Time']-proavtive_period['Time'].shift(1)
            proavtive_period['timedelta'] = proavtive_period['timedelta'].fillna(0).astype(int)
            proactive_by_crnti_dict[crnti] = proavtive_period['timedelta'].values.tolist()
        logging.info("proactive by crnti:{}".format(proactive_by_crnti_dict))
        return proactive_by_crnti_dict
    else:
        logging.info("ttitrace file is not UL")


def get_max_proactive_period(file_name):
    """
    Args:
        file_name:
    Returns:
        1.only ue return max value;
        2.multi ue return average value per ue max
    """
    merge_data = read_csv(file_name)
    max_proactive_period = []
    datas = _ProactiveAssignment(merge_data)
    for crnti in datas.keys():
        max_proactive_period.append(max(datas[crnti]))
    if len(max_proactive_period) == 1:
        return max_proactive_period[0]
    else:
        import numpy as np
        return np.mean(max_proactive_period)


def read_csv(file_name):
    merge_data = pd.read_csv(file_name, header=1, na_filter=False, low_memory=False, dtype='str',
                             error_bad_lines=False, warn_bad_lines=False)
    return merge_data


def tract_key_value_from_ttitrace(file_path):
    file_list = get_ttitrace_file(file_path)
    for file_name in file_list:
        data = read_csv(file_name)
        length = int((152-len(file_name.split(os.sep)[-1])-len('cell-{}'.format(_cellid(data))))/2)
        print('='*length+'cell-{}'.format(_cellid(data))+file_name.split(os.sep)[-1]+'='*length)
        # ueIndex=_ueIndex(data)
        througput = _thoughput(data)
        numberOfPrbAlloc = _numberOfPrbAlloc(data)
        mcsIndexCw1 = _mcsIndexCw1(data)
        mcsIndexCw2 = _mcsIndexCw2(data)
        dataInDrb1 = _dataInDrb1(data)
        ackNackDtxCw1 = _ackNackDtxCw1(data)
        ackNackDtxCw2 = _ackNackDtxCw2(data)
        pd.set_option('display.max_columns', 1000)
        pd.set_option('display.max_rows', 1000)
        pd.set_option('display.width', 1000)
        if len(_crnti(data)) > 0:
            df = pd.DataFrame(columns=('crnti', 'Tput', 'Prb_min', 'Prb_max', 'Prb_ave',
                                       'mcs1_min', 'mcs1_max', 'mcs1_ave',
                                       'mcs2_min', 'mcs2_max', 'mcs2_ave',
                                       'buffer_min', 'buffer_max', 'buffer_ave',
                                       'bler1(%)', 'bler2(%)'))
            for i, crnti in enumerate(_crnti(data), start=1):
                if len(ackNackDtxCw2) > 0:
                    df.loc[i] = [crnti, througput[crnti], numberOfPrbAlloc[crnti]['min'],
                                 numberOfPrbAlloc[crnti]['max'], numberOfPrbAlloc[crnti]['average'],
                                 mcsIndexCw1[crnti]['min'], mcsIndexCw1[crnti]['max'], mcsIndexCw1[crnti]['average'],
                                 mcsIndexCw2[crnti]['min'], mcsIndexCw2[crnti]['max'], mcsIndexCw2[crnti]['average'],
                                 dataInDrb1[crnti]['min'], dataInDrb1[crnti]['max'], dataInDrb1[crnti]['average'],
                                 ackNackDtxCw1[crnti], ackNackDtxCw2[crnti]]
                else:
                    df.loc[i] = [crnti, througput[crnti], numberOfPrbAlloc[crnti]['min'],
                                 numberOfPrbAlloc[crnti]['max'], numberOfPrbAlloc[crnti]['average'],
                                 mcsIndexCw1[crnti]['min'], mcsIndexCw1[crnti]['max'], mcsIndexCw1[crnti]['average'],
                                 mcsIndexCw2[crnti]['min'], mcsIndexCw2[crnti]['max'], mcsIndexCw2[crnti]['average'],
                                 dataInDrb1[crnti]['min'], dataInDrb1[crnti]['max'], dataInDrb1[crnti]['average'],
                                 ackNackDtxCw1[crnti], 'nan']
            print(df)
        import locale
        locale.setlocale(locale.LC_ALL, '')
        print('cell throughput:{}.{}'.format(locale.format("%d", througput.get('cell_throughput'), 1),
                                             _tm_mode(data)))
        print('=' * 152)
        # _td_fd_ue_num(data)


def get_pairrate_from_ttitrace(filename):
    data = read_csv(filename)
    pair_rate = _get_pair_rate(data)
    return pair_rate


def ttitrace_count_by_filter_and_condition(file_path, filename, filter, filter_item, condition, condition_type='int'):
    total_counter = 0
    pattern = re.compile(filename)
    file_list = get_ttitrace_file(file_path)
    for file in file_list:
        real_name = re.findall(pattern, file)
        if real_name:
            file_path = os.path.join(file_path, file)
            data = read_csv(file_path)
            for item in filter_item:
                temp_data = data[data[filter] == '{}'.format(item)]
                if '>=' in condition:
                    str = condition.split('>=')
                    temp_data[str[0]] = temp_data[str[0]].astype('int')
                    counter = temp_data[str[0]][temp_data[str[0]] >= int(str[1])].count()
                elif '>' in condition:
                    str = condition.split('>')
                    temp_data[str[0]] = temp_data[str[0]].astype('int')
                    counter = temp_data[str[0]][temp_data[str[0]] > int(str[1])].count()
                elif '==' in condition:
                    str = condition.split('==')
                    if condition_type == 'int':
                        temp_data[str[0]] = temp_data[str[0]].astype('int')
                        counter = temp_data[str[0]][temp_data[str[0]] == int(str[1])].count()
                    elif condition_type == 'str':
                        temp_data[str[0]] = temp_data[str[0]]
                        counter = temp_data[str[0]][temp_data[str[0]] == str[1]].count()
                elif '<=' in condition:
                    str = condition.split('<=')
                    temp_data[str[0]] = temp_data[str[0]].astype('int')
                    counter = temp_data[str[0]][temp_data[str[0]] <= int(str[1])].count()
                elif '<' in condition:
                    str = condition.split('<')
                    temp_data[str[0]] = temp_data[str[0]].astype('int')
                    counter = temp_data[str[0]][temp_data[str[0]] < int(str[1])].count()
                elif '!=' in condition:
                    str = condition.split('!=')
                    if condition_type == 'int':
                        temp_data[str[0]] = temp_data[str[0]].astype('int')
                        counter = temp_data[str[0]][temp_data[str[0]] != int(str[1])].count()
                    elif condition_type == 'str':
                        temp_data[str[0]] = temp_data[str[0]]
                        counter = temp_data[str[0]][temp_data[str[0]] != str[1]].count()
                else:
                    counter = 0
                total_counter = total_counter + counter
    return total_counter


def _multi_ttitrace_merge(file_path, cell_id_list, column_name, direct):
    file_list = get_ttitrace_file(file_path)
    new_file_list = []
    time_list = []
    for file_name in file_list:
        data = read_csv(file_name)
        if direct == 'dl':
            if 'ETtiTraceDlParCell_cellId' in data.head(0):
                cellid = data['ETtiTraceDlParCell_cellId'].unique()[0]
                if cellid in cell_id_list.split(','):
                    new_file_list.append(file_name)
        else:
            if 'ETtiTraceUlParCell_cellId' in data.head(0):
                cellid = data['ETtiTraceUlParCell_cellId'].unique()[0]
                if cellid in cell_id_list.split(','):
                    new_file_list.append(file_name)
    for new_file in new_file_list:
        new_data = read_csv(new_file)
        time_list = time_list+new_data['Time'].tolist()
    df = None
    for index, new_file in enumerate(new_file_list, start=1):
        temp_data = read_csv(new_file)
        if direct == 'dl':
            _df = temp_data[['Time', column_name]]
        else:
            _df = temp_data[['Time', column_name]][((temp_data['ETtiTraceUlParCell_esfn'] != '-') &
                                                    (temp_data['ETtiTraceUlParCell_esfn'] != '0'))]
        col = ['Time', '{}_{}'.format(column_name, index)]
        _df.columns = col
        if df is None:
            df = _df
        else:
            df = pd.merge(df, _df, how="outer")
    df = df.fillna(65535)
    if len(cell_id_list.split(',')) > 1:
        df['sum'] = df.iloc[:, 1:].astype(int).apply(lambda x: x.sum(), axis=1)
        return df
    else:
        df['sum'] = df.apply(lambda x: x[1], axis=1)
        return df


def multi_ttitrace_merge(file_path, cell_id_list, column_name, direct='dl', total_check_rate=0.8):
    data = _multi_ttitrace_merge(file_path, cell_id_list, column_name, direct)
    value_list = data['sum'].tolist()
    check_line = int(len(value_list)*total_check_rate)
    return list(set(value_list[:check_line]))


if __name__ == "__main__":
    # tract_key_value_from_ttitrace(sys.argv[1])
    # ttitrace_count_by_filter_and_condition(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5], sys.argv[6])
    # get_pairrate_from_ttitrace(sys.argv[1])
    print(multi_ttitrace_merge(sys.argv[1], sys.argv[2], sys.argv[3]))
    pass
