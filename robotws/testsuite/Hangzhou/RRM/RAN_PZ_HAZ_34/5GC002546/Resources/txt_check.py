import collections
import re
from xml.etree.ElementTree import parse
from collections import Counter
# from ctypes import *


def txt_check_output(output):
    '''
    file_path:bip loge :/home/ute/tcpdumpL2L1_filtering_off.pdml
    Documentation:git beamID list form bip log
    return:The number of occurrences of of Beam ID ,is a dict [0:1,1:2,2:3]
    '''
    # cellID_line_min = 0
    # cellID_line_max = 0
    # FDD_or_not = 0
    crntiOverlappingPoolId = []
    crntiNonOverlappingPoolIds = []
    crntiNonOverlappingPoolId_true = []
    crntiOverlappingPoolId_true = []
    all_result = []
    FDD_or_notlist, list_line, list_s = the_line_of_cellID(output)
    result_overlapping = 'false'
    result_nonoverlapping = 'false'
    result_FDD_255 = 'false'
    result_nonoverlapping_1 = 'false'
    result_nonoverlapping_2 = 'false'
    for index in range(len(list_line)):
        if index + 1 < len(list_line):
            cellID_line_min = list_line[index]
            FDD_or_not = FDD_or_notlist[index]
            index_max = index + 1
            cellID_line_max = list_line[index_max]
            check_all_value = get_every_poolID(list_s, cellID_line_min, cellID_line_max)
            crntiOverlappingPoolId = check_all_value['crntiOverlappingPoolId']
            crntiNonOverlappingPoolIds = check_all_value['crntiNonOverlappingPoolIds']
            crntiOverlappingPoolId_true = check_all_value['crntiOverlappingPoolId_true']
            crntiNonOverlappingPoolId_true = check_all_value['crntiNonOverlappingPoolId_true']
            if FDD_or_not == '0':
                result_overlapping = int(crntiOverlappingPoolId) == int(crntiOverlappingPoolId_true) == 255
                result_nonoverlapping_1 = int(crntiNonOverlappingPoolIds[0]) == \
                    int(crntiNonOverlappingPoolId_true.split(',')[0]) <= 71
                result_nonoverlapping_2 = int(crntiNonOverlappingPoolIds[1]) == \
                    int(crntiNonOverlappingPoolId_true.split(',')[1]) <= 71
                all_result.append(result_overlapping)
                all_result.append(result_nonoverlapping_1)
                all_result.append(result_nonoverlapping_2)
            else:
                result_overlapping = int(crntiOverlappingPoolId) == int(crntiOverlappingPoolId_true) <= 5
                result_nonoverlapping_1 = int(crntiNonOverlappingPoolIds[0]) == \
                    int(crntiNonOverlappingPoolId_true.split(',')[0]) <= 71
                result_nonoverlapping_2 = '255' == crntiNonOverlappingPoolId_true.split(',')[1]
                result_FDD_255 = crntiNonOverlappingPoolIds[1] == ''
                all_result.append(result_overlapping)
                all_result.append(result_nonoverlapping_1)
                all_result.append(result_nonoverlapping_2)
                all_result.append(result_FDD_255)
    all_result = list(set(all_result))
    return all_result


def the_line_of_cellID(output):
    FDD_or_notlist = []
    list_line = []
    list_s = output.split('\n')
    for i, item in enumerate(list_s):
        if item.find('Trying to allocate crnti pool for cell') != -1:
            list_line.append(i)
            FDD_or_notlist.append(item.split('be Fdd Cell: ')[1].split(',')[0])
    list_line.append(len(list_s))
    return FDD_or_notlist, list_line, list_s


def get_every_poolID(list_s, cellID_line_min, cellID_line_max):
    crntiOverlappingPoolId = []
    crntiNonOverlappingPoolIds = []
    crntiNonOverlappingPoolId_true = []
    crntiOverlappingPoolId_true = []
    check_all_value = {}
    for i, item in enumerate(list_s):
        if i > cellID_line_min and i < cellID_line_max and len(check_all_value.keys()) < 4:
            if item.find('Allocate the following crntiOverlappingPoolId') != -1:
                crntiOverlappingPoolId = item.split('Allocate the following crntiOverlappingPoolId: ')[1].split(',')[0]
                crntiNonOverlappingPoolIds = item.split('crntiNonOverlappingPoolIds: ')[1].split(', ', 3)[0:2]
                check_all_value['crntiOverlappingPoolId'] = crntiOverlappingPoolId
                check_all_value['crntiNonOverlappingPoolIds'] = crntiNonOverlappingPoolIds
            elif item.find('crntiNonOverlappingPoolId"') != -1:
                crntiNonOverlappingPoolId_true = item.split('crntiNonOverlappingPoolId":[')[1].split(']')[0]
                check_all_value['crntiNonOverlappingPoolId_true'] = crntiNonOverlappingPoolId_true
                if item.find('"crntiOverlappingPoolId":') != -1:
                    crntiOverlappingPoolId_true = item.split('crntiOverlappingPoolId":')[1].split('}')[0]
                    check_all_value['crntiOverlappingPoolId_true'] = crntiOverlappingPoolId_true
            elif item.find('"crntiOverlappingPoolId"') != -1:
                crntiOverlappingPoolId_true = item.split('crntiOverlappingPoolId":')[1].split('}')[0]
                check_all_value['crntiOverlappingPoolId_true'] = crntiOverlappingPoolId_true
            elif item.find('CellSetupReq_t: gPoolId"') != -1:
                crntiOverlappingPoolId_true = item.split('CellSetupReq_t: gPoolId":')[1].split('}')[0]
                check_all_value['crntiOverlappingPoolId_true'] = crntiOverlappingPoolId_true
        elif len(check_all_value.keys()) >= 4:
            break
    return check_all_value


def check_crnti_pool_id(output):
    '''
    Documentation: check each cell's crnti pool id if configed crnti pool id equal to actual crnti pool id
    Author: catherine.cheng@nokia-sbell.com
    output: logs from snapshot with debug log enabled
    return: cellid_list, isFDD_list, crntiOverlappingPoolId_list, crntiNonOverlappingPoolId_list
    '''
    cellid_list = []
    isFDD_list = []
    crntiOverlapPoolId_list = []
    crntiNonOverlapPoolId_list = []
    replace = r"########"
    # replace all \n to ########
    temp = re.sub("\n", replace, output)
    pattern_split = r'L2Ps_CellSetupResp - OK'
    pattern_replace = r'########.*?Sent to L2PS itf::l2::ps::cell::CellSetupReq_t: '
    pattern_isFddCell = r'Trying to allocate crnti pool for cell: (\d+), be Fdd Cell: (\d),'
    pattern_config_crnti_fdd = r'Allocate the following crntiOverlappingPoolId: (\d+), ' \
                               r'crntiNonOverlappingPoolIds: (\d+),'
    pattern_config_crnti_notfdd = r'Allocate the following crntiOverlappingPoolId: (\d+), ' \
                                  r'crntiNonOverlappingPoolIds: (\d+, \d+),'
    pattern_actual_crnti_fdd = r'{"crntiNonOverlappingPoolId":\[(\d+).*\]?,"crntiOverlappingStart":\d+,' \
                               r'"crntiOverlappingPoolId":(\d+)}?'
    pattern_actual_crnti_notfdd = r'{"crntiNonOverlappingPoolId":\[(\d+,\d+).*\]?,"crntiOverlappingStart":\d+,' \
                                  r'"crntiOverlappingPoolId":(\d+)}?'
    # find all L2Ps_CellSetupResp - OK
    split_log_list = re.split(pattern_split, temp)
    count = 0
    for log in split_log_list:
        if log != "" and count < len(split_log_list)-1:
            # find all cell id and isFDD cell
            matches = re.search(pattern_isFddCell, log)
            if matches is None:
                continue
            cellid = matches.group(1)
            isFDD = matches.group(2)
            # join all CellSetupReq_t message together to avoid poolid in defferent lines
            # and remove duplicate Sent to L2PS itf::l2::ps::cell::CellSetupReq_t
            new_log = re.sub(pattern_replace, "", log)
            if isFDD == "1":
                overlapPoolId_config, nonOverlapPoolId_config = get_crntiPoolID(
                                                                    pattern_config_crnti_fdd, log, 1, 2)
                overlapPoolId_actual, nonOverlapPoolId_actual = get_crntiPoolID(
                                                                    pattern_actual_crnti_fdd, new_log, 2, 1)
            else:
                overlapPoolId_config, nonOverlapPoolId_config = get_crntiPoolID(
                                                                    pattern_config_crnti_notfdd, log, 1, 2)
                overlapPoolId_actual, nonOverlapPoolId_actual = get_crntiPoolID(
                                                                    pattern_actual_crnti_notfdd, new_log, 2, 1)

            assert overlapPoolId_config.replace(" ", "") == overlapPoolId_actual.replace(" ", "") \
                   and nonOverlapPoolId_config.replace(" ", "") == nonOverlapPoolId_actual.replace(" ", ""), \
                   "[crnti poll check]: cell" + cellid + " is FDD cell? " + isFDD \
                   + ", crntipoll is not equal!! overlapPoolId_config is: " + overlapPoolId_config \
                   + ", overlapPoolId_actual is : " + overlapPoolId_actual + " ,nonOverlapPoolId_config is: " \
                   + nonOverlapPoolId_config + " ,nonOverlapPoolId_actual is: " + nonOverlapPoolId_actual

            cellid_list.append(cellid)
            isFDD_list.append(isFDD)
            crntiNonOverlapPoolId_list.append(nonOverlapPoolId_actual)
            crntiOverlapPoolId_list.append(overlapPoolId_actual)
            count += 1

    assert crntiOverlapPoolId_list != [], "[crnti poll check]: crntiOverlapPoolId_list is null!!"
    assert crntiNonOverlapPoolId_list != [], "[crnti poll check]: crntiNonOverlapPoolId_list is null!!"

    return crntiOverlapPoolId_list, crntiNonOverlapPoolId_list


def get_crntiPoolID(pattern, output, overlap_group_id, nonOverlap_group_id):
    '''
    Documentation: get_crntiPoolID from log
    Author: catherine.cheng@nokia-sbell.com
    pattern: regex pattern
    output: logs from snapshot with debug log enabled
    overlap_group_id: overlap_group_id
    nonOverlap_group_id: nonOverlap_group_id
    return: overlapPoolId, nonOverlapPoolId
    '''
    matches = re.search(pattern, output)
    assert matches is not None, "[crnti poll check]: no crnti pool id found!!"
    overlapPoolId = matches.group(overlap_group_id)
    nonOverlapPoolId = matches.group(nonOverlap_group_id)

    return overlapPoolId, nonOverlapPoolId
