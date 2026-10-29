# -*- coding: UTF-8 -*-
"""
:created on:2023/7/31
:update on:
:version:1.0
:author: Li Changyan
:contact: changyan.li@nokia-sbell.com.cn
:desc: CB008322 get patternId from ttitrace log
"""

import csv
import math


def get_rrm_max_BWVs(ch_bw_prb, sub_band_size, max_rank=4):
    """
    get maximum number of BWVs:rrmMaxBWVs = roundup (bandwidth/bfSubbandSize+1)*maxRank,
    5G_UP_ALG_20830
    :param ch_bw_prb: chbw  int
    :param sub_band_size: subbandsize  int
    :param max_rank: fix 4
    : return maximum number of BWVs
    """
    rrw_max_bwv = (math.ceil(ch_bw_prb / sub_band_size) + 1) * max_rank
    return rrw_max_bwv


def get_ue_ping_stream_config_pattern_id1_in_tti(start_pattern_id, ch_bw_prb, sub_band_size, ue_num=1):
    """
    get ue ping dlFdSchedData.streamConfig.patternId1 in ttitrace log
    :param start_pattern_id:0x580556 rdStartPatternId set value
    :param ch_bw_prb： chbw int
    :param sub_band_size: subbandsize int
    :param ue_num：which num UE  int
    : return patternid
    """
    rrw_max_bwv = get_rrm_max_BWVs(ch_bw_prb, sub_band_size)
    pattern_id = start_pattern_id + rrw_max_bwv * 2 * (ue_num - 1)

    return pattern_id


def get_ue_pong_stream_config_pattern_id1_in_tti(start_pattern_id, ch_bw_prb, sub_band_size, ue_num=1):
    """
    get ue pong dlFdSchedData.streamConfig.patternId1 in ttitrace log
    :param start_pattern_id:0x580556 rdStartPatternId set value
    :param ch_bw_prb; chbw int
    :param sub_band_size: subbandsize int
    :param ue_num：which num UE int
    : return patternid
    """
    rrw_max_bwv = get_rrm_max_BWVs(ch_bw_prb, sub_band_size)
    pattern_id = start_pattern_id + rrw_max_bwv * (2 * ue_num - 1)

    return pattern_id


def get_ue_ping_stream_config_pattern_id2_in_tti(start_pattern_id, ch_bw_prb, sub_band_size, rank, ue_num=1):
    """
    get ue ping dlFdSchedData.streamConfig.patternId2 in ttitrace log
    :param start_pattern_id: 0x580556 rdStartPatternId set value
    :param ch_bw_prb: chbw int
    :param sub_band_size: subbandsize int
    :param rank: rank int
    :param ue_num：which num UE int
    : return patternid
    """
    if rank < 1 or rank > 4:
        raise Exception("Rank is invalid")
    rrw_max_bwv = get_rrm_max_BWVs(ch_bw_prb, sub_band_size)
    pattern_id = start_pattern_id + rrw_max_bwv * (2 * ue_num - 1) - 8
    pattern_id_list = []
    for i in range(0, 4):
        tmp_pattern_id = pattern_id + i
        pattern_id_list.append(tmp_pattern_id)

    return pattern_id_list[rank - 1]


def get_ue_pong_stream_config_pattern_id2_in_tti(start_pattern_id, ch_bw_prb, sub_band_size, rank, ue_num=1):
    """
    get ue pong dlFdSchedData.streamConfig.patternId2 in ttitrace log
    :param start_pattern_id;
    :param ch_bw_prb：chbw int
    :param sub_band_size: subbandsize int
    :param ue_num：which num UE int
    : return patternid
     + rrmMaxBWVs*(2* maxNumUeSrs-1)
    """
    if rank < 1 or rank > 4:
        raise Exception("Rank is invalid")
    rrw_max_bwv = get_rrm_max_BWVs(ch_bw_prb, sub_band_size)
    pattern_id = start_pattern_id + rrw_max_bwv * (2 * ue_num) - 8
    pattern_id_list = []
    for i in range(0, 4):
        tmp_pattern_id = pattern_id + i
        pattern_id_list.append(tmp_pattern_id)

    return pattern_id_list[rank - 1]


def get_ue_ping_csi_pattern_id_array(start_pattern_id, ch_bw_prb, sub_band_size, ue_num=1, array_len=4):
    """
    get maximum number of BWVs: patternId[i] = startPatternId + rrmMaxBWVs – 4 + i
    CB008322-33605
    :param start_pattern_id: 0x580556 rdStartPatternId set value
    :param ch_bw_prb: chbw
    :param sub_band_size: subbandsize
    :param rrw_max_bwv: maximum number of BWVs
    :param ue_num: which num UE
    :param array_len:  default 4
    : return csi pattern id list
    """
    pattern_id_list = []
    start_pattern_id = int(start_pattern_id)
    ch_bw_prb = int(ch_bw_prb)
    sub_band_size = int(sub_band_size)
    ue_num = int(ue_num)
    rrw_max_bwv = get_rrm_max_BWVs(ch_bw_prb, sub_band_size)
    for array_index in range(0, array_len):
        pattern_id = int(start_pattern_id + rrw_max_bwv * (2 * ue_num - 1) - 4 + array_index)
        pattern_id_list.append(pattern_id)
    return pattern_id_list


def get_ue_pong_csi_pattern_id_array(start_pattern_id, ch_bw_prb, sub_band_size, ue_num=1, array_len=4):
    """
    get maximum number of BWVs: patternId[i] = startPatternId + rrmMaxBWVs – 4 + i
    CB008322-33605
    :param start_pattern_id: 0x580556 rdStartPatternId set value
    :param ch_bw_prb: chbw
    :param sub_band_size: subband size
    :param ue_num: which num UE
    :param array_len:  default 4
    : return csi pattern id list
    """
    pattern_id_list = []
    start_pattern_id = int(start_pattern_id)
    ch_bw_prb = int(ch_bw_prb)
    sub_band_size = int(sub_band_size)
    ue_num = int(ue_num)
    rrw_max_bwv = get_rrm_max_BWVs(ch_bw_prb, sub_band_size)
    for array_index in range(0, array_len):
        pattern_id = int(start_pattern_id + rrw_max_bwv * (2 * ue_num) - 4 + array_index)
        pattern_id_list.append(pattern_id)
    return pattern_id_list


def check_max_2_UEs_weight_calculated_per_each_SRS_symbol(file_name):
    """
     CB008322 L1 max 2 UEs weight can be calculated per each SRS symbol, the initial value shall be 2.
     :param file_name: csv file name absolute path
     :return None
     :raises Fail when check fail
    """
    with open(file_name, 'r') as csv_file:
        list_reader = list(csv.DictReader(csv_file))
        max_count = 0
        for row_line in list_reader:
            operation = row_line['UlData_srsBwvReportRequest_t.operation']
            tmp_count = str(operation).count('6')
            if tmp_count > max_count:
                max_count = tmp_count

        if max_count > 2:
            print("more than 2 UEs weight can be calculated per each SRS symbol")
            raise Exception('Fail')
        else:
            print("pass")


def check_csirs_pattern_id_for_ue_specific_csirs(file_name, filter_rnti, ch_bw_prb, sub_band_size):
    """
    check csiRsSchedData.patternId for ue specific csirs
     :param file_name: csv file name absolute path
     :param rnti_list:rnti list
     :param ch_bw_prb: chbw
     :param sub_band_size: subband size
     :return None
     :raises Fail when check fail
    """
    with open(file_name, 'r') as csv_file:
        list_reader = list(csv.DictReader(csv_file))
        err_count = 0
        pattern_id1 = None
        pattern_id2 = None
        find_rnti = False
        filter_rnti = int(filter_rnti)
        ch_bw_prb = int(ch_bw_prb)
        sub_band_size = int(sub_band_size)
        for row_line in list_reader:
            rnti = row_line['rnti']
            if int(rnti) == filter_rnti:
                find_rnti = True
                if row_line['dlFdSchedData.streamConfig.patternId1'] != '' and\
                        row_line['dlFdSchedData.streamConfig.patternId2'] != '':
                    pattern_id1 = row_line['dlFdSchedData.streamConfig.patternId1']
                    pattern_id2 = row_line['dlFdSchedData.streamConfig.patternId2']
                    pattern_id1 = remove_not_need_char(pattern_id1, '.0')
                    pattern_id2 = remove_not_need_char(pattern_id2, '.0')
                if row_line['csiRsSchedData.patternId1'] != '' and row_line["rnti"] != '':
                    if pattern_id1 is None and pattern_id2 is None:
                        continue
                    if row_line['dlFdSchedData.beamType'] == 'SUBBAND':
                        print("pattern_id1:", pattern_id1)
                        csi_pattern_ping_list = get_ue_ping_csi_pattern_id_array(pattern_id1, ch_bw_prb, sub_band_size)
                        csi_pattern_pong_list = get_ue_pong_csi_pattern_id_array(pattern_id1, ch_bw_prb, sub_band_size)
                        for idx, id in enumerate(csi_pattern_ping_list):
                            csi_str = 'csiRsSchedData.patternId' + str(idx + 1)
                            tmp_csi_list = [id, csi_pattern_pong_list[idx]]
                            csi_pattern_get = row_line[csi_str]
                            csi_pattern_get = remove_not_need_char(csi_pattern_get, '.0')
                            print("tmp_csi_list:", tmp_csi_list, "csi_pattern_get:", csi_pattern_get)
                            if int(csi_pattern_get) in tmp_csi_list:
                                continue
                            else:
                                err_count = err_count + 1
                                sfn = row_line['sfn']
                                slot = row_line['slot']
                                print("sfn:", sfn, "slot:", slot, "pattern_id1:", pattern_id1, "csi_patternId:",
                                      csi_pattern_get)
                    elif row_line['dlFdSchedData.beamType'] == 'DFTNONTAPERING':
                        csi_pattern1 = row_line['csiRsSchedData.patternId1']
                        csi_pattern2 = row_line['csiRsSchedData.patternId2']
                        csi_pattern3 = row_line['csiRsSchedData.patternId3']
                        csi_pattern4 = row_line['csiRsSchedData.patternId4']
                        csi_pattern1 = remove_not_need_char(csi_pattern1, '.0')
                        csi_pattern2 = remove_not_need_char(csi_pattern2, '.0')
                        csi_pattern3 = remove_not_need_char(csi_pattern3, '.0')
                        csi_pattern4 = remove_not_need_char(csi_pattern4, '.0')
                        if csi_pattern1 == pattern_id1 and csi_pattern2 == pattern_id1 and \
                                csi_pattern3 == pattern_id2 and csi_pattern4 == pattern_id2:
                            continue
                        else:
                            sfn = row_line['sfn']
                            slot = row_line['slot']
                            print("sfn:", sfn, "slot:", slot, "pattern_id1:", pattern_id1, "pattern_id2:", pattern_id2)
                            err_count = err_count + 1

        if err_count >= 1:
            print("more than 1 sfn csi rs patternId not right")
            raise Exception('check csi rs patternid for ue specific csirs Fail')
        elif find_rnti:
            print("pass")
        else:
            print("can not find rnti:", filter_rnti)
            raise Exception('input rnti is not right')


def remove_not_need_char(str_src, str_sub):
    """
    remove str_sub not need from str_src
    :param str_src:
    :param str_sub:
    :return:
    """
    str_src = str_src.replace(str_sub, '')
    return str_src


def check_csi_pattern_id_equal_pdsch_pattern_id_for_dft(file_name, filter_rnti):
    """
    check csiRsSchedData.patternId when beamtype=DFT
     :param file_name: csv file name absolute path
     :param rnti_list:rnti list
     :return None
     :raises Fail when check fail
    """
    with open(file_name, 'r') as csv_file:
        list_reader = list(csv.DictReader(csv_file))
        err_count = 0
        pattern_id1 = None
        pattern_id2 = None
        find_rnti = False
        filter_rnti = int(filter_rnti)
        for row_line in list_reader:
            rnti = int(row_line['rnti'])
            if rnti == filter_rnti:
                find_rnti = True
                if row_line['dlFdSchedData.streamConfig.patternId1'] != '' and \
                        row_line['dlFdSchedData.streamConfig.patternId2'] != '':
                    pattern_id1 = row_line['dlFdSchedData.streamConfig.patternId1']
                    pattern_id2 = row_line['dlFdSchedData.streamConfig.patternId2']

                if row_line['csiRsSchedData.patternId1'] != '':
                    if pattern_id1 is None and pattern_id2 is None:
                        continue
                    if row_line['csiRsSchedData.patternId1'] == pattern_id1 and \
                            row_line['csiRsSchedData.patternId2'] == pattern_id1 and \
                            row_line['csiRsSchedData.patternId3'] == pattern_id2 and \
                            row_line['csiRsSchedData.patternId4'] == pattern_id2:
                        continue
                    else:
                        sfn = row_line['sfn']
                        slot = row_line['slot']
                        print("sfn:", sfn, "slot:", slot, "pattern_id1:", pattern_id1, "pattern_id2:", pattern_id2)
                        err_count = err_count + 1

        if err_count >= 1:
            print("more than 1 sfn csi rs patternId not right")
            raise Exception('check patternid Fail')
        elif find_rnti:
            print("pass")
        else:
            print("can not find rnti:", filter_rnti)
            raise Exception('input rnti is not right')


def check_srsreceivereq_bfSubbandId_item(file_name, item_index, min_value, max_value):
    """
    check whether is right the value of UlData_srsBwvReportRequest_t.bfSubbandId_item in uldata_srsreceivereq
    :param file_name:csv file name(absolute path)
    :param item_index:the index of bfSubbandId_item, range 0-1
    :param min_value:expect the min value
    :param max_value: expect the max value
    :return:
    """
    with open(file_name, 'r') as csv_file:
        list_reader = list(csv.DictReader(csv_file))
        err_count = 0
        item_index = int(item_index)
        min_value = int(min_value)
        max_value = int(max_value)
        for row_line in list_reader:
            if row_line['UlData_srsBwvReportRequest_t.bfSubbandId_item'] != '':
                str_ids = row_line['UlData_srsBwvReportRequest_t.bfSubbandId_item']
                tmp_list = list(str_ids.split(","))
                for idx, str_id in enumerate(tmp_list):
                    id_value = int(str_id)
                    tmp = idx % (item_index + 2)
                    print("tmp", tmp)
                    if idx % (item_index + 2) == 0:
                        if min_value <= id_value <= max_value:
                            continue
                        else:
                            err_count = err_count + 1
                            rnti = row_line['3gpp.rnti']
                            sfn = row_line['3gpp.sfn']
                            slot = row_line['3gpp.slot']
                            print("sfn:", sfn, "slot:", slot, "rnti:", rnti, "bfSubbandId_item:", tmp_list)

        if err_count >= 1:
            print("more than 1 sfn csi rs patternId not right")
            raise Exception('check subbandid_item Fail')
        else:
            print("pass")

# if __name__ == "__main__":
#     # file_name = "C:/N-20S1PF2R85NG-Data/changyli/Desktop/ttitrace/230906/2/bip_srsreceivereq.csv"
#     # check_srsreceivereq_bfSubbandId_item(file_name, 0, 0, 30)
#
#     # file_name = "C:/N-20S1PF2R85NG-Data/changyli/Desktop/ttitrace/230915/2/tti_5UE_dl.csv"
#     # check_csirs_pattern_id_for_ue_specific_csirs(file_name, '27757', 217, 32)
#     #
#     # # aa = 1234.0
#     # # bb = int(1234.0)
#     # # print(bb)
#     # tmp_list = [2131, 2163]
#     if 2131 in tmp_list:
#         print("aa")
#     else:
#         print("bb")
