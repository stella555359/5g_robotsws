# -*- coding: UTF-8 -*-
# author : zhangwenchao
# version: 1.0

from rt_parse_ttitrace import rt_ttitrace_convert_dict
import logging
import os
import re


def _dl_thoughput(filename, crnti):
    dict = rt_ttitrace_convert_dict(filename, 'ETtiTraceDlParUe_trNumCW1==New_trans',
                                    'ETtiTraceDlParUe_crnti=={}'.format(crnti))
    sum1 = 0
    for key in dict['ETtiTraceDlParUe_tbsCw1'].keys():
        sum1 += int(dict['ETtiTraceDlParUe_tbsCw1'][key])*8
    listed = dict['Time'].values()
    end_time = _convert_time(listed[-1])
    start_time = _convert_time(listed[0])
    gap_time1 = end_time - start_time
    dict = rt_ttitrace_convert_dict(filename, 'ETtiTraceDlParUe_trNumCW2==New_trans',
                                    'ETtiTraceDlParUe_crnti=={}'.format(crnti))
    sum2 = 0
    for key in dict['ETtiTraceDlParUe_tbsCw2'].keys():
        sum2 += int(dict['ETtiTraceDlParUe_tbsCw2'][key]) * 8
    listed = dict['Time'].values()
    if len(listed) > 0:
        end_time = _convert_time(listed[-1])
        start_time = _convert_time(listed[0])
        gap_time2 = end_time - start_time
        if gap_time1 >= gap_time2:
            thoughput1 = (sum1 * 1000) / gap_time1
            thoughput2 = (sum2 * 1000) / gap_time1
            thoughput = thoughput1+thoughput2
            return thoughput
        else:
            thoughput1 = (sum1 * 1000) / gap_time2
            thoughput2 = (sum2 * 1000) / gap_time2
            thoughput = thoughput1 + thoughput2
            return thoughput
    else:
        thoughput1 = (sum1 * 1000) / gap_time1
        thoughput = thoughput1
        return thoughput


def _get_dl_crnti_list(filename):
    crnti_list = []
    dict = rt_ttitrace_convert_dict(filename)
    listed = dict['ETtiTraceDlParUe_crnti'].values()
    listed = list(set(listed))
    for element in listed:
        if len(element) > 1:
            crnti_list.append(element)
    return crnti_list


def _get_ul_crnti_list(filename):
    crnti_list = []
    dict = rt_ttitrace_convert_dict(filename)
    listed = dict['ETtiTraceUlParUe_crnti'].values()
    listed = list(set(listed))
    for element in listed:
        if len(element) > 1:
            crnti_list.append(element)
    return crnti_list


def _ul_thoughput(filename, crnti):
    dict = rt_ttitrace_convert_dict(filename, 'ETtiTraceUlParUe_trNumCw1==New_trans',
                                    'ETtiTraceUlParUe_crnti=={}'.format(crnti))
    sum = 0
    for key in dict['ETtiTraceUlParUe_trNumCw1'].keys():
        sum += int(dict['ETtiTraceUlParUe_tbsCw1'][key])*8
    listed = dict['Time'].values()
    end_time = _convert_time(listed[-1])
    start_time = _convert_time(listed[0])
    gap_time = end_time-start_time
    thoughput = (sum * 1000) / gap_time
    return thoughput


def _convert_time(timed):
    timed = timed.split(':')
    if timed[0] == '00':
        return int(timed[3])+(int(timed[2])+int(timed[1])*60+24*3600)*1000
    else:
        return int(timed[3])+(int(timed[2])+int(timed[1])*60+int(timed[0])*3600)*1000


def _convert_ueid_to_crnti(filename, ueid):
    dicted = rt_ttitrace_convert_dict(filename)
    if 'ETtiTraceDlParUe_ueIndex' in dicted.keys():
        dict1 = rt_ttitrace_convert_dict(filename, 'ETtiTraceDlParUe_ueIndex=={}'.format(ueid))
        crnti = list(set(dict1['ETtiTraceDlParUe_crnti'].values()))
        if len(crnti):
            return crnti[0]
        else:
            return None
    elif 'ETtiTraceUlParUe_ueIndex' in dicted.keys():
        dict1 = rt_ttitrace_convert_dict(filename, 'ETtiTraceUlParUe_ueIndex=={}'.format(ueid))
        crnti = list(set(dict1['ETtiTraceUlParUe_crnti'].values()))
        if len(crnti):
            return crnti[0]
        else:
            return None


def get_cell_throughput_ave_from_ttitrace(filename, direction='dl', crc_head='1'):
    sum_trhoughput = 0
    if direction.upper() == 'DL':
        for crnti in _get_dl_crnti_list(filename):
            sum_trhoughput += _dl_thoughput(filename, crnti)
        return sum_trhoughput*float(crc_head)
    elif direction.upper() == 'UL':
        for crnti in _get_ul_crnti_list(filename):
            sum_trhoughput += _ul_thoughput(filename, crnti)
        return sum_trhoughput*float(crc_head)


def get_ue_throughput_ave_from_ttitrace(filename, ue_id, direction='dl', crc_head='1'):
    if direction.upper() == 'DL':
        crnti = _convert_ueid_to_crnti(filename, ueid=ue_id)
        logging.info('CRNTI is {}'.format(crnti))
        ue_throughput = _dl_thoughput(filename, crnti)
        return ue_throughput*float(crc_head)
    elif direction.upper() == 'UL':
        crnti = _convert_ueid_to_crnti(filename, ueid=ue_id)
        logging.info('CRNTI is {}'.format(crnti))
        ue_throughput = _ul_thoughput(filename, crnti)
        return ue_throughput * float(crc_head)


def _get_filename_via_filepath(filepath, cell, direction):
    from getcellmapping import RT2_get_cell_core_id
    direction = direction.upper()
    core = RT2_get_cell_core_id(cell, direction)
    filenames = os.listdir(filepath)
    for filename in filenames:
        if filename[-3:] == 'csv':
            filename = filename.strip()
            pattern = re.compile(core, re.I)
            if re.findall(pattern, filename):
                return os.path.join(filepath, filename)


def get_ue_id_from_btslog(filename):
    id_list = []
    with open(filename, 'r') as f:
        for line in f:
            keyword = re.findall('crnti=\\d+\\,ueIndex=(\\d+)\\,.+doaH_M10', line)
            # keyword = re.findall('calcAoAWrap\,ueIndex=(\d+)\,crnti=\d+\,doaH_M10', line)
            if keyword:
                id_list.append(keyword[0])
    return id_list[-1]


def get_ue_throughput_ave_for_cell(filepath, cell, ue_id, direction):
    filename = _get_filename_via_filepath(filepath, cell, direction)
    throughput = get_ue_throughput_ave_from_ttitrace(filename, ue_id, direction)
    return throughput


def get_cell_throughput_ave_for_cell(filepath, cell, direction):
    filename = _get_filename_via_filepath(filepath, cell, direction)
    throughput = get_cell_throughput_ave_from_ttitrace(filename, direction)
    return throughput


if __name__ == "__main__":
    # get_cell_throughput_ave_from_ttitrace(filename, direction)
    # get_ue_throughput_ave_from_ttitrace(filename, ue_id, direction)
    pass
