# -*- coding: UTF-8 -*-
"""
:created on:2023/10/25
:update on:
:version:1.0
:author: Li Changyan
:contact: changyan.li@nokia-sbell.com.cn
:desc: CB009235
"""
import math

from Reorder_CSV import *
import ast

front_col_list_CB009235_dl = [
    'rnti',
    'dlTdSchedSubcellData.resReqClassPrio',
    'dlTdSchedSubcellData.resReqClassSubPrio',
    'dlFdSchedData.requiredPrbForMuAwareTdSch',
    'dlMuAwareTdSchInfo.muAwareCorrMappingTable',
    'dlMuAwareTdSchInfo.corrCheckBlockUeListAfterStep1',
    'dlMuAwareTdSchInfo.nonCorrCheckUeListAfterStep1',
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
    'dlFdSchedData.startPrb',
    'dlFdSchedData.numOfPrb',
    'dlFdSchedData.rat0Bitmap',
    'dlFdSchedData.antPort',
    'dlFdSchedData.subcellId',
    'dlFdSchedData.numCdmGroupNoData',
    'dlFdSchedData.rrmDlUsedMcs',
    'dlFdSchedData.K1',
    'dlFdSchedData.dlHarqProcessIndex',
    'dlFdSchedData.txNumber',
    'dlFdSchedData.scheduledBytesPerBearer[4]',
    'dlFdSchedData.remainingBytesPerBearerInFdEoBuffer[4]',
    'dlFdSchedData.macCe.brrsBeamChange',
    'dlFdSchedData.macCe.hasCridlFdSchedData.macCe.hasCri',
    'dlFdSchedData.macCe.hasSCellActDeact',
    'dlFdSchedData.macCe.numTciStateInd',
    'dlFdSchedData.macCe.sCellActDeact',
    'dlFdSchedData.macCe.sCellActDeact4Byte',
    'dlFdSchedData.macCe.tac',
    'dlFdSchedData.streamConfig.patternId1',
    'dlFdSchedData.streamConfig.patternId2',
    'dlFdSchedData.streamConfig.streamIndex1',
    'dlFdSchedData.streamConfig.streamIndex2',
    'dlFdSchedData.streamConfig.streamIndex3',
    'dlFdSchedData.streamConfig.streamIndex4'

]


def reorder_csv_CB009235(filename):
    """
    order csv file by column
    :param filename: csv file name absolute path
    :return:
    """
    reorder_csv(filename, front_col_list_CB009235_dl)


def check_scheduled_ue_whether_have_highest_priority(file_name, filter_rnti_list):
    """
    check scheduled non-mueligible UE per lost have highest priority
    :param file_name:csv file name absolute path
    :param filter_rnti_list: non-mueligible UE rnti list,such as:['59759', '26071']
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
        cs2_block_list_per_slot = []
        scheduled_ue_num = 0
        for row_line in list_reader:
            rnti = int(row_line['rnti'])
            ack = row_line['dlFdSchedData.ackNack']
            priority = row_line['dlTdSchedSubcellData.resReqClassPrio']
            slot = row_line['slot']
            if (rnti and priority) or (rnti == 0):
                if rnti and priority:
                    if slot != tmp_slot:
                        if find_rnti:
                            cs2_size = int(float(row_line['dlTdSchedSubcellData.cs2Size']))
                            to_be_scheduled_size = cs2_size - len(cs2_block_list_per_slot)
                            if to_be_scheduled_size <= scheduled_ue_num:
                                continue
                            sorted_list = sorted(tmp_slot_list, key=lambda x: (
                                float(x['dlTdSchedSubcellData.resReqClassPrio']),
                                float(x['dlTdSchedSubcellData.resReqClassSubPrio'])),
                                                 reverse=True)
                            for i in range(0, filter_count_per_slot):
                                if len(cs2_block_list_per_slot) > 0:
                                    if sorted_list[i]['rnti'] in cs2_block_list_per_slot:
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

                else:
                    if slot != tmp_slot:
                        cs2_block_list_per_slot.clear()
                        tmp_scheduled_ues = row_line['dlLoadControlData.fdSchedInfo[0].scheduledUes']
                        # print("tmp=", tmp)
                        if tmp_scheduled_ues:
                            scheduled_ue_num = int(float(row_line['dlLoadControlData.fdSchedInfo[0].scheduledUes']))
                        block_list = row_line['dlPreTdBlockUeData.cs2BlockUeList']
                        if block_list:
                            cs2_block_list_per_slot = _get_block_ue_rnti_list(ast.literal_eval(block_list))

        if find_count == 0:
            print("Check fail, can not find rnti=", filter_rnti_list)
            raise Exception('input rnti is not right')
        else:
            if err_count == 0:
                print("Check pass")
            elif err_count >= 1:
                print("Check fail")
                raise Exception('Check fail')


def check_9235_ue_list_in_per_slot(file_name, corr_threshold=0.1, prb_threshold=0.1, all_prb=273):
    """
    check 9235 ue in corrCheckBlockUeListAfterStep1 and nonCorrCheckUeListAfterStep1 is correct
    :param file_name:csv file name absolute path
    :param corr_threshold: dlMuMimoCorrThd
    :param prb_threshold: dlMuAwarePrbRatio
    :param all_prb: all prb
    :return:
    """
    corr_threshold = math.pow(corr_threshold, 2)
    prb_threshold = all_prb * prb_threshold
    with open(file_name, 'r') as csv_file:
        list_reader = list(csv.DictReader(csv_file))
        tmp_slot = -1
        tmp_slot_list = []
        scheduled_ue_num = 0
        meet_rnti_0 = False
        to_be_scheduled_list = []
        for row_line in list_reader:
            rnti = int(row_line['rnti'])
            ack = row_line['dlFdSchedData.ackNack']
            priority = row_line['dlTdSchedSubcellData.resReqClassPrio']
            slot = row_line['slot']

            if rnti and not meet_rnti_0:
                continue

            if slot == tmp_slot:
                if priority:
                    tmp_slot_list.append(row_line)
                if row_line['dlTdSchedSubcellData.cs2Size']:
                    cs2_size = int(float(row_line['dlTdSchedSubcellData.cs2Size']))
            else:
                if len(tmp_slot_list) > 0:
                    to_be_scheduled_size = cs2_size - len(cs2_block_list)
                    if to_be_scheduled_size <= scheduled_ue_num:
                        meet_rnti_0 = False
                        tmp_slot_list.clear()
                        tmp_slot = slot
                        continue
                    sorted_list = sorted(tmp_slot_list, key=lambda x: (
                        float(x['dlTdSchedSubcellData.resReqClassPrio']),
                        float(x['dlTdSchedSubcellData.resReqClassSubPrio'])),
                                         reverse=True)
                    # print("slot={}, _check_block_list_non_corr_list".format(slot))
                    _check_block_list_non_corr_list(sorted_list, corr_table, prb_threshold, cs2_block_list, block_list,
                                                    non_corr_list, corr_threshold, scheduled_ue_num)
                    tmp_slot_list.clear()
                corr_table = row_line['dlMuAwareTdSchInfo.muAwareCorrMappingTable']
                if rnti == 0 and corr_table:
                    meet_rnti_0 = True
                    if row_line['dlLoadControlData.fdSchedInfo[0].scheduledUes']:
                        scheduled_ue_num = int(float(row_line['dlLoadControlData.fdSchedInfo[0].scheduledUes']))
                    corr_table = row_line['dlMuAwareTdSchInfo.muAwareCorrMappingTable']
                    if corr_table:
                        corr_table = ast.literal_eval(corr_table)
                    block_list = row_line['dlMuAwareTdSchInfo.corrCheckBlockUeListAfterStep1']
                    if block_list:
                        block_list = ast.literal_eval(block_list)
                    non_corr_list = row_line['dlMuAwareTdSchInfo.nonCorrCheckUeListAfterStep1']
                    if non_corr_list:
                        non_corr_list = ast.literal_eval(non_corr_list)
                        # print("slot={} non_corr_list".format(slot))
                    cs2_block_list = row_line['dlPreTdBlockUeData.cs2BlockUeList']
                    if cs2_block_list:
                        cs2_block_list = ast.literal_eval(cs2_block_list)
                    to_be_scheduled_list.clear()
            tmp_slot = slot

    print("check pass")


def _check_block_list_non_corr_list(per_slot_ue_list, corr_table, prb_threshold, cs2_block_list, src_block_list,
                                    src_non_corr_list, corr_threshold, scheduled_ue_num):
    """

    :param per_slot_ue_list: ue data list in per slot
    :param corr_table:
    :param prb_threshold:
    :param cs2_block_list:
    :param src_block_list:
    :param src_non_corr_list:
    :param corr_threshold:
    :param scheduled_ue_num:
    :return:
    """
    block_list = []
    non_corr_list = []
    to_be_scheduled_list = []
    err_block_count = 0
    err_non_corr_count = 0
    tmp_scheduled_list = []
    slot = 1
    sum_required_prb = 0
    for index, ue_data in enumerate(per_slot_ue_list):
        ack = ue_data['dlFdSchedData.ackNack']
        mu_status = ue_data['dlFdSchedData.muStatus']
        tx_num = ue_data['dlFdSchedData.txNumber']
        # tx_num = int(tx_num.replace('.0', ''))
        if ue_data['dlFdSchedData.requiredPrbForMuAwareTdSch']:
            required_prb = int(float(ue_data['dlFdSchedData.requiredPrbForMuAwareTdSch']))
        else:
            required_prb = 0
        rnti = int(ue_data['rnti'])
        slot = ue_data['slot']
        sfn = ue_data['sfn']
        if len(to_be_scheduled_list) >= scheduled_ue_num:
            break
        if not ack:
            corr_check = _check_correlation(rnti, to_be_scheduled_list, corr_table, corr_threshold)
            if not corr_check:
                block_list.append(rnti)
                continue
            block_type = _get_ue_block_type_in_cs2_block_list(rnti, cs2_block_list)
            if _check_ue_whether_in_cs2_block_list(rnti, cs2_block_list):
                if block_type == 'CS2_NONMUELIGIBLEBLOCK':
                    non_corr_list.append(rnti)
                elif block_type == 'CS2_CORRCHECKBLOCK':
                    block_list.append(rnti)
                else:
                    if block_type:
                        print("rnti={},blcok reason={}".format(rnti, block_type))
                continue
            else:
                # print("slot={},rnti={}, not in cs2blocklist, please check buffer".format(slot, rnti))
                continue
        else:
            if sum_required_prb > prb_threshold and tx_num == '1':
                if mu_status == 'NOMUELIGIBLE_SRSBEAMINVALID':
                    non_corr_list.append(rnti)
                else:
                    corr_check = _check_correlation(rnti, to_be_scheduled_list, corr_table, corr_threshold)
                    if corr_check:
                        to_be_scheduled_list.append(rnti)
                        if len(block_list) > 0:
                            tmp_scheduled_list = _check_block_list_ue_corr(rnti, block_list, corr_table,
                                                                           corr_threshold)  # check blocklist
                            to_be_scheduled_list.extend(tmp_scheduled_list)
                            _remove_sub_list_from_list(block_list, tmp_scheduled_list)
                    else:
                        block_list.append(rnti)
            else:
                if mu_status == 'NOMUELIGIBLE_SRSBEAMINVALID':
                    tmp_scheduled_list.append(rnti)
                else:
                    to_be_scheduled_list.append(rnti)
        sum_required_prb += required_prb

    if sorted(src_block_list) != sorted(block_list):
        print("sfn={},slot={},src_block_list={},block_list={}, block_list data is abnormal".format(sfn, slot,
                                                                                                   src_block_list,
                                                                                                   block_list))
        err_block_count += 1
    if sorted(src_non_corr_list) != sorted(non_corr_list):
        print("sfn={},slot={},src_non_corr_list={},non_corr_list={},non_corr_list is abnormal".format(sfn, slot,
                                                                                                      src_non_corr_list,
                                                                                                      non_corr_list))
        err_non_corr_count += 1

    if err_block_count > 0:
        raise Exception('Check block_list fail')

    if err_non_corr_count > 0:
        raise Exception('Check non_corr_list fail')


def _check_block_list_ue_corr(block_list, to_be_scheduled_list, corr_table, corr_threshold):
    """
    check correlation in block_list
    :param block_list:
    :param to_be_scheduled_list:
    :param corr_table:
    :param corr_threshold:
    :return: UE list for checking pass
    """
    if not isinstance(block_list, list):
        block_list = [block_list]
    remove_list = []
    for ue_rnti in block_list:
        corr_check = _check_correlation(ue_rnti, to_be_scheduled_list, corr_table, corr_threshold)
        if corr_check:
            remove_list.append(ue_rnti)
            to_be_scheduled_list.append(ue_rnti)
    return remove_list


def _remove_sub_list_from_list(src_list, sub_list):
    """
    remove sublist from source list
    :param src_list:
    :param sub_list:
    :return:
    """
    for item in sub_list:
        src_list.remove(item)


def _check_ue_whether_in_cs2_block_list(rnti, cs2_block_list):
    """
    check ue in cs2blocklist
    :param rnti:
    :param cs2_block_list:dlPreTdBlockUeData.cs2BlockUeList
    :return:
    """
    for ue_data in cs2_block_list:
        if int(ue_data['rnti']) == rnti:
            return True

    return False


def _get_ue_block_type_in_cs2_block_list(rnti, cs2_block_list):
    """
    get ue block type in cs2blocklist
    :param rnti:
    :param cs2_block_list:dlPreTdBlockUeData.cs2BlockUeList
    :return:
    """
    for ue_data in cs2_block_list:
        if int(ue_data['rnti']) == rnti:
            return ue_data['reason']

    return None


def _check_correlation(rnti, to_be_schedule_list, corr_table, corr_threshold):
    """
    check correlation
    :param rnti:
    :param to_be_schedule_list: tobescheduledList
    :param corr_table:dlMuAwareTdSchInfo.muAwareCorrMappingTable
    :param corr_threshold:
    :return:
    """
    if not len(to_be_schedule_list):
        return True
    sum_corr = 0
    no_corr_num = 0
    for ue_rnti in reversed(to_be_schedule_list):
        corr = _get_correlation_from_table(rnti, ue_rnti, corr_table)
        if corr != -1:
            sum_corr += corr * corr
        else:
            no_corr_num += 1
            # print("wrn:can not find correlation ue:{} and {}".format(rnti, ue_rnti))
            continue

    corr_all = sum_corr / (len(to_be_schedule_list) + 1 - no_corr_num)
    if corr_all < corr_threshold:
        return True

    return False


def _get_correlation_from_table(rnti, ue_rnti, corr_table):
    """
    get correlation from table
    :param rnti:
    :param ue_rnti:
    :param corr_table: dlMuAwareTdSchInfo.muAwareCorrMappingTable
    :return:correlation between rnti and ue_rnti
    """
    rnti_list = [rnti, ue_rnti]
    for item in corr_table:
        if item['rnti1'] in rnti_list and item['rnti2'] in rnti_list:
            return item['correlation']

    return -1


def _delete_no_need_key_in_dict(src_dict, no_need_list):
    """
    delete no need key in dict
    :param src_dict:source dict
    :param no_need_list:no need list data
    :return:
    """
    keys_list = list(src_dict.keys())
    for key in keys_list:
        if key not in no_need_list:
            src_dict.pop(key)


def _get_block_ue_rnti_list(block_list):
    """
    get rnti list from cs2blocklist
    :param block_list: format such as: [{'rnti': 54085, 'reason': 'CS2_PDCCHBLOCK'}]
    :return: rnti list
    """
    rnti_list = []
    for tmp_item in block_list:
        rnti = tmp_item['rnti']
        rnti_list.append(rnti)

    return rnti_list


def check_ue_if_scheduled(file_name, filter_rnti):
    """
    check ue whether scheduled, if no scheduled, raise exception
    :param file_name: csv file name absolute path
    :param filter_rnti:  UE rnti
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
            print("rnti=", filter_rnti, "no scheduled")
            raise Exception('Check fail')


def get_ue_scheduled_times(file_name):
    """
    get all UEs scheduled times
    :param file_name:csv file name absolute path
    :return: dictionary list, dictionary: key:rnti, value:scheduled times
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
    return rnti_dict


def check_ue_in_block_list_non_corr_check_list_be_scheduled(file_name):
    """
    check ue in blocklist and noncorrchecklist can be scheduled
    :param file_name: csv file name absolute path
    :return:
    """
    with open(file_name, 'r') as csv_file:
        list_reader = list(csv.DictReader(csv_file))
        tmp_slot = -1
        row_line_list = []
        meet_rnti_0 = False
        block_ue_scheduled = False
        block_ue_scheduled_num = 0
        non_corr_ue_scheduled = False
        non_corr_ue_scheduled_num = 0
        for row_line in list_reader:
            rnti = int(row_line['rnti'])
            ack = row_line['dlFdSchedData.ackNack']
            priority = row_line['dlTdSchedSubcellData.resReqClassPrio']
            slot = row_line['slot']

            if rnti and not meet_rnti_0:
                continue

            if block_ue_scheduled and non_corr_ue_scheduled:
                break

            if slot == tmp_slot:
                if priority and ack:
                    row_line_list.append(row_line)
            else:
                if len(row_line_list) > 0:
                    rnti_list = _get_rnti_list_from_row_line_list(row_line_list)
                    block_ue_scheduled = _check_sub_list_in_source_list(block_list, rnti_list)
                    if block_ue_scheduled:
                        block_ue_scheduled_num += 1
                    non_corr_ue_scheduled = _check_sub_list_in_source_list(non_corr_list, rnti_list)
                    if non_corr_ue_scheduled:
                        non_corr_ue_scheduled_num += 1
                    row_line_list.clear()

                corr_table = row_line['dlMuAwareTdSchInfo.muAwareCorrMappingTable']
                if rnti == 0 and corr_table:
                    meet_rnti_0 = True
                    block_list = row_line['dlMuAwareTdSchInfo.corrCheckBlockUeListAfterStep1']
                    if block_list:
                        block_list = ast.literal_eval(block_list)
                    non_corr_list = row_line['dlMuAwareTdSchInfo.nonCorrCheckUeListAfterStep1']
                    if non_corr_list:
                        non_corr_list = ast.literal_eval(non_corr_list)

            tmp_slot = slot

    if block_ue_scheduled and non_corr_ue_scheduled:
        print("check pass")
        print("block_ue_scheduled_num:", block_ue_scheduled_num, "non_corr_ue_scheduled_num:",
              non_corr_ue_scheduled_num)
    elif not block_ue_scheduled:
        raise Exception("block_ue_list not be scheduled")
    else:
        raise Exception("non_corr_ue_list not be scheduled")


def _get_rnti_list_from_row_line_list(src_list):
    """
    :param src_list: row data list in ttitrace excel csvg
    :return: rnti list
    """

    rnti_list = []
    for ue_data in src_list:
        rnti_list.append(int(ue_data['rnti']))

    return rnti_list


def _check_sub_list_in_source_list(sub_list, src_list):
    """
    Check if there are items in the sub list in the source list
    :param sub_list: sublist
    :param src_list: source list
    :return: true or false
    """
    check_in = False
    for item in sub_list:
        if item in src_list:
            check_in = True
            break
    return check_in


def check_uncheck_ue_in_cs2list_add_into_non_corr_check_list_and_scheduled(file_name):
    """
    check uncheck ue in cs2list added into im noncorrchecklist, and can be scheduled
    :param file_name: excel file
    """
    with open(file_name, 'r') as csv_file:
        list_reader = list(csv.DictReader(csv_file))
        tmp_slot = -1
        tmp_slot_list = []
        meet_rnti_0 = False
        uncheck_ue_cs2list_scheduled = False
        uncheck_ue_cs2list_scheduled_num = 0
        for row_line in list_reader:
            rnti = int(row_line['rnti'])
            ack = row_line['dlFdSchedData.ackNack']
            priority = row_line['dlTdSchedSubcellData.resReqClassPrio']
            slot = row_line['slot']
            sfn = row_line['sfn']
            if rnti and not meet_rnti_0:
                continue

            if slot == tmp_slot:
                if priority and ack:
                    tmp_slot_list.append(row_line)
            else:
                if len(tmp_slot_list) > 0:
                    sorted_list = sorted(tmp_slot_list, key=lambda x: (
                        float(x['dlTdSchedSubcellData.resReqClassPrio']),
                        float(x['dlTdSchedSubcellData.resReqClassSubPrio'])),
                                         reverse=True)
                    # if len(sorted_list) > len(block_list):
                    rnti_list = _get_rnti_list_from_row_line_list(sorted_list)
                    for index, item in enumerate(rnti_list):
                        if len(block_list) > 0 and item == block_list[-1] and index != (len(rnti_list) - 1):
                            uncheck_ue_cs2list_scheduled_num += 1
                            uncheck_ue_cs2list_scheduled = True
                            print("the last block list ue be scheduled, sfn：", sfn, "slot:", tmp_slot, "rnti:", item,
                                  "rntillist:", rnti_list)
                            break
                    tmp_slot_list.clear()

                corr_table = row_line['dlMuAwareTdSchInfo.muAwareCorrMappingTable']
                if rnti == 0 and corr_table:
                    meet_rnti_0 = True
                    block_list = row_line['dlMuAwareTdSchInfo.corrCheckBlockUeListAfterStep1']
                    if block_list:
                        block_list = ast.literal_eval(block_list)

            tmp_slot = slot

    if uncheck_ue_cs2list_scheduled:
        print("check pass")
        print("uncheck_ue_cs2list_scheduled_num:", uncheck_ue_cs2list_scheduled_num)
    else:
        raise Exception("uncheck ue in cs2list not be scheduled")


def check_retx_ue_not_in_blocklist_and_noncorrelation_list(file_name):
    """
    check shuduled UE per lost have highest priority
    :param file_name:csv file name absolute path
    :param filter_rnti_list: no mueligible UE rnti list,such as:['59759', '26071']
    :return:
    """
    with open(file_name, 'r') as csv_file:
        list_reader = list(csv.DictReader(csv_file))
        err_count = 0
        block_list = []
        non_corr_list = []
        for row_line in list_reader:
            rnti = row_line['rnti']
            slot = row_line['slot']
            sfn = row_line['sfn']
            if rnti == '0':
                block_list = row_line['dlMuAwareTdSchInfo.corrCheckBlockUeListAfterStep1']
                if block_list:
                    block_list = ast.literal_eval(block_list)
                non_corr_list = row_line['dlMuAwareTdSchInfo.nonCorrCheckUeListAfterStep1']
                if non_corr_list:
                    non_corr_list = ast.literal_eval(non_corr_list)
            else:
                tx_num = row_line['dlFdSchedData.txNumber']
                tx_num = tx_num.replace('.0', '')
                ack = row_line['dlFdSchedData.ackNack']
                if tx_num:
                    tx_num = int(tx_num)
                    if tx_num == 2 or tx_num == 3 or tx_num == 4:
                        if (rnti in block_list) or (rnti in non_corr_list):
                            err_count += 1
                            print("Check fail sfn=", sfn, "slot=", slot, "rnti=", rnti)

        if err_count == 0:
            print("Check pass")
        elif err_count >= 1:
            print("Check fail")
            raise Exception('Check fail')
