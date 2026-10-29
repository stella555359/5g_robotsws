# -*- coding: UTF-8 -*-
"""
:created on:2023/10/25
:update on:
:version:1.0
:author: Gao Lei
:contact: l3i.4.gao@nokia-sbell.com
:desc: CB009235
"""

from Reorder_CSV import *
import ast

front_col_list_CB009235_dl = [
    'rnti',
    'dlTdSchedSubcellData.resReqClassPrio',
    'dlTdSchedSubcellData.resReqClassSubPrio',
    'dlPreTdBlockUeData.cs2BlockUeList',
    'dlLoadControlData.csListInfo.cs2ListMaxSize',
    'dlTdSchedSubcellData.cs2Size',
    'dlTdSchedSubcellData.maxNumPdschPerSlot',
    'dlLoadControlData.csListInfo.numOfUesInPreSchedCandSet',
    'dlLoadControlData.csListInfo.rrmMaxNumUesFdmOlc',
    'dlLoadControlData.fdSchedInfo[0].numToBeScheduledUes',
    'dlLoadControlData.fdSchedInfo[0].scheduledUes',
    'dlFdSchedData.ackNack',
    'dlFdSchedData.muPdschPowerOffset',
    'dlFdSchedData.muStatus',
    'dlFdSchedData.numOfLayers',
    'dlFdSchedData.numOfPrb',
    'dlFdSchedData.startPrb',
    'dlFdSchedData.rat0Bitmap',
    'dlFdSchedData.antPort',
    'dlFdSchedData.subcellId',
    'dlFdSchedData.numCdmGroupNoData',
    'dlFdSchedData.rrmDlUsedMcs',
    'dlFdSchedData.K1',
    'dlFdSchedData.dlHarqProcessIndex',
    'dlFdSchedData.txNumber',
    'dlFdSchedData.rrmtotalDrbBufferedBytes',
    'dlFdSchedData.remainingBytesPerBearerInFdEoBuffer[4]',
    'dlFdSchedData.streamConfig.patternId1',
    'dlFdSchedData.streamConfig.patternId2',
    'dlFdSchedData.streamConfig.streamIndex1',
    'dlFdSchedData.streamConfig.streamIndex2',
    'dlFdSchedData.streamConfig.streamIndex3',
    'dlFdSchedData.streamConfig.streamIndex4'
]


def reorder_csv_CB009235_2(filename):
    """
    order csv file by column
    :param filename: csv file name absolute path
    :return:
    """
    reorder_csv(filename, front_col_list_CB009235_dl)


def check_DeprioritizedTraffic_gbr_20_not_scheduled(file_name, filter_rnti_list):
    """
    check shuduled UE per lost have highest priority
    :param file_name:csv file name absolute path
    :param filter_rnti_list: no mueligible UE rnti list,such as:['59759', '26071']
    :return:
    """
    with open(file_name, 'r') as csv_file:
        list_reader = list(csv.DictReader(csv_file))
        find_rnti = False
        find_count = 0
        tmp_slot = -1
        tmp_slot_list = []
        err_count = 0
        filter_count_per_slot = 0
        block_list_per_slot = []
        block_list_Ue_Num_exp = 0
        scheduled_ue_num = 0
        for row_line in list_reader:
            rnti = int(row_line['rnti'])
            ack = row_line['dlFdSchedData.ackNack']
            priority = row_line['dlTdSchedSubcellData.resReqClassPrio']
            slot = row_line['slot']
            rrmMaxNumUesFdmOlc = row_line['dlLoadControlData.csListInfo.rrmMaxNumUesFdmOlc']
            if (rnti and priority) or (rnti == 0 and rrmMaxNumUesFdmOlc):
                if rnti and priority:
                    if slot != tmp_slot:
                        if find_rnti:
                            cs2_size = int(float(row_line['dlTdSchedSubcellData.cs2Size']))
                            to_be_scheduled_size = cs2_size - len(block_list_per_slot)
                            if to_be_scheduled_size <= scheduled_ue_num:
                                continue
                            sorted_list = sorted(tmp_slot_list, key=lambda x: (
                                float(x['dlTdSchedSubcellData.resReqClassPrio']),
                                float(x['dlTdSchedSubcellData.resReqClassSubPrio'])),
                                                 reverse=True)
                            for i in range(0, filter_count_per_slot):
                                if len(block_list_per_slot) > 0:
                                    if sorted_list[i]['rnti'] in block_list_per_slot:
                                        continue
                                if sorted_list[i]['rnti'] not in filter_rnti_list:
                                    get_slot = sorted_list[i]['slot']
                                    tmp_rnti = sorted_list[i]['rnti']
                                    tmp_sfn = sorted_list[i]['sfn']
                                    print("Check fail sfn=", tmp_sfn, "slot=", get_slot, "rnti=", tmp_rnti,
                                          "no mueligble UE no have more high priority")
                                    # print('sorted_list=', sorted_list)
                                    err_count += 1
                        tmp_slot_list.clear()
                        find_rnti = False
                    filter_count_per_slot = 0

                    for item_rnti in filter_rnti_list:
                        if rnti == int(item_rnti) and ack:
                            find_rnti = True
                            find_count += 1
                            filter_count_per_slot += 1
                            break
                    tmp_slot = slot
                    tmp_slot_list.append(row_line)

                if rnti == 0 and rrmMaxNumUesFdmOlc:
                    if slot != tmp_slot:
                        block_list_per_slot.clear()
                        tmp_scheduled_ues = row_line['dlLoadControlData.fdSchedInfo[0].scheduledUes']
                        # print("tmp=", tmp)
                        if tmp_scheduled_ues:
                            scheduled_ue_num = int(float(row_line['dlLoadControlData.fdSchedInfo[0].scheduledUes']))
                        block_list = row_line['dlPreTdBlockUeData.cs2BlockUeList']
                        if block_list:
                            block_list_Ue_Num_exp = _get_other_block_except_9235_ue_Num(ast.literal_eval(block_list))

        if find_count == 0:
            print("Check fail, can not find rnti=", filter_rnti_list)
            raise Exception('input rnti is not right')
        else:
            if err_count == 0:
                print("Check pass")
            elif err_count >= 1:
                print("Check fail")
                raise Exception('Check fail')


def _delete_no_need_key_in_dict_2(src_dict, need_key_list):
    """
    delete no need key in dict
    :param src_dict:
    :param need_key_list:
    :return:
    """
    keys_list = list(src_dict.keys())
    for key in keys_list:
        if key not in need_key_list:
            src_dict.pop(key)


def _get_block_ue_list_2(block_list):
    rnti_list = []
    for tmp_item in block_list:
        rnti = tmp_item['rnti']
        rnti_list.append(rnti)

    return rnti_list


def _get_other_block_except_9235_ue_Num_2(block_list):
    block_reson_9235e = 0
    #    rnti_list = []
    for tmp_item_r in block_list:
        if tmp_item_r['reason'] != 'CS2_CORRCHECKBLOCK' and tmp_item_r['reason'] != 'CS2_NONMUELIGIBLEBLOCK':
            block_reson_9235e += 1
    #           rnti = tmp_item_r['rnti']
    #           rnti_list.append(rnti)
    return block_reson_9235e


# [{'rnti': 36008, 'reason': 'CS2_CORRCHECKBLOCK'}, {'rnti': 26808, 'reason': 'CS2_CORRCHECKBLOCK'},
# {'rnti': 60496, 'reason': 'CS2_CORRCHECKBLOCK'}, {'rnti': 28648, 'reason': 'CS2_CORRCHECKBLOCK'},
# {'rnti': 30488, 'reason': 'CS2_CORRCHECKBLOCK'}]


def check_ue_scheduled_2(file_name, filter_rnti):
    """
    check ue scheduled, if no scheduled, raise exception
    :param file_name: csv file name absolute path
    :param filter_rnti:
    :return:
    """
    with open(file_name, 'r') as csv_file:
        list_reader = list(csv.DictReader(csv_file))
        scheduled_count = 0
        filter_rnti = int(filter_rnti)
        for row_line in list_reader:
            rnti = int(row_line['rnti'])
            slot = row_line['slot']
            ack = row_line['dlFdSchedData.ackNack']
            if rnti == filter_rnti and ack:
                scheduled_count += 1
                print("rnti=", filter_rnti, "schedule slot:", slot)
        if scheduled_count > 0:
            print("rnti=", filter_rnti, "scheduled times:", scheduled_count)
        else:
            print("no scheduled")
            raise Exception('Check fail')


def check_ue_scheduled_times_2(file_name):
    """
    check uE scheduled times
    :param file_name:
    :return:csv file name absolute path
    """
    with open(file_name, 'r') as csv_file:
        list_reader = list(csv.DictReader(csv_file))
        rnti_dict = {}
        for row_line in list_reader:
            rnti = int(row_line['rnti'])
            # slot = row_line['slot']
            ack = row_line['dlFdSchedData.ackNack']
            if rnti and ack:
                if rnti in rnti_dict:
                    rnti_dict[rnti] += 1
                else:
                    rnti_dict[rnti] = 1
    for key, value in rnti_dict.items():
        print("rnti:", key, "scheduled times:", value)


# if __name__ == "__main__":
#    file_name = "C:/5G/logs/py_debug/tti_dl_Order5.csv"
#    check_DeprioritizedTraffic_gbr_20_not_scheduled(file_name, ['4160', '56816'])
