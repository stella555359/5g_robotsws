#!-*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Xiang Liang
:contact: liang.xiang@nokia-sbell.com
"""
from .global_config import *
from robot.api import logger
import time


def check_pcmd_value(dict_real_cnpq, list_real_m_tertiary, list_real_all_record, need_to_check_pcmd_array):
    """
    Get  PCMD value and compare
    """
    # print("CNPQ and Tertiary_N=", dict_real_cnpq, list_real_m_tertiary)
    list_tmp = [INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID, INVALID]
    list_result = []
    index_offset = 0
    cursion_flag = False
    # get the value from list record based on dict_calculate #
    print("PCMD check num=%d" % len(need_to_check_pcmd_array))
    for j in range(len(need_to_check_pcmd_array)):
        list_tmp[KEYWORD] = need_to_check_pcmd_array[j][KEYWORD]
        list_tmp[INDEX] = need_to_check_pcmd_array[j][INDEX]
        list_tmp[FIELD_AREA] = need_to_check_pcmd_array[j][FIELD_AREA]
        list_tmp[DELTA] = need_to_check_pcmd_array[j][DELTA]
        list_tmp[TARGET_VALUE] = need_to_check_pcmd_array[j][TARGET_VALUE]
        list_tmp[LOWER_LIMIT] = need_to_check_pcmd_array[j][LOWER_LIMIT]
        list_tmp[UPPER_LIMIT] = need_to_check_pcmd_array[j][UPPER_LIMIT]
        # ===start to get the real value from the record=====#
        if need_to_check_pcmd_array[j][KEYWORD] == PRIMARY:
            list_tmp[REAL_VALUE] = list_real_all_record[need_to_check_pcmd_array[j][INDEX] - 1]
            print("Primary test value:", list_tmp[REAL_VALUE])
        elif need_to_check_pcmd_array[j][KEYWORD] == SECONDARY:
            if int(need_to_check_pcmd_array[j][FIELD_AREA]) == RECURSION and int(dict_real_cnpq['sec_records']) > 1:
                index_offset = PRIMARY_LEN - 1
                for t in range(int(dict_real_cnpq['sec_records'])):
                    print("2: index=", index_offset, "t=", t)
                    if t > 0:  # >0 means start trying the 2nd or more secondary IE
                        index_offset += int(list_real_m_tertiary[t - 1]) * TERTIARY_LEN + SECONDARY_LEN
                        print("3: index=", index_offset, "t=", t, "num of Ter=",
                              int(list_real_m_tertiary[t - 1]))
                    print("!!!real index=", index_offset + need_to_check_pcmd_array[j][INDEX])
                    list_tmp[REAL_VALUE] = list_real_all_record[index_offset + need_to_check_pcmd_array[j][INDEX]]
                    print(("In secondary recursion process,t=", t, "test_value=", int(list_tmp[REAL_VALUE]),
                           "target_value=", need_to_check_pcmd_array[j][TARGET_VALUE]))
                    if int(list_tmp[REAL_VALUE]) == need_to_check_pcmd_array[j][TARGET_VALUE]:
                        print("Secondary PCMD match!")
                        print("It is the", t + 1, "SECONDARY IE")
                        cursion_flag = True
                        break
                if cursion_flag:
                    cursion_flag = False
                    list_tmp[CHECK_RESULT] = PASS
                else:
                    list_tmp[CHECK_RESULT] = FAIL
            elif int(need_to_check_pcmd_array[j][FIELD_AREA]) == RECURSION \
                    and int(dict_real_cnpq['sec_records']) <= 1:
                print("The secondary Num=", int(dict_real_cnpq['sec_records']), "no recursion happened!")
                list_tmp[REAL_VALUE] = -1
                list_tmp[CHECK_RESULT] = FAIL
            else:
                list_tmp[REAL_VALUE] = list_real_all_record[
                    PRIMARY_LEN + need_to_check_pcmd_array[j][INDEX] - 1 + (1 - 1) * TERTIARY_LEN]
            print("Secondary test value:", list_tmp[REAL_VALUE])
        elif need_to_check_pcmd_array[j][KEYWORD] == TERTIARY:
            if int(need_to_check_pcmd_array[j][FIELD_AREA]) == RECURSION and int(dict_real_cnpq['sec_records']) >= 1:
                index_offset = PRIMARY_LEN - 1  # ready to start from PRIMARY IE
                print("Tertiary index=", index_offset, "sec num=", int(dict_real_cnpq['sec_records']))
                for i in range(int(dict_real_cnpq['sec_records'])):
                    index_offset += SECONDARY_LEN  # ready to start from new SECONDARY IE
                    print("Secondary start=", index_offset, "i=", i, "int(list_real_m_tertiary[i])=",
                          int(list_real_m_tertiary[i]))
                    for t in range(int(list_real_m_tertiary[i])):  # check tertiary on the secondary IE
                        list_tmp[REAL_VALUE] = list_real_all_record[index_offset + need_to_check_pcmd_array[j][INDEX]]
                        print("In tertiary recursion process,t=", t, "test_value=", int(list_tmp[REAL_VALUE]))
                        if int(list_tmp[REAL_VALUE]) == need_to_check_pcmd_array[j][TARGET_VALUE]:
                            cursion_flag = True  # get the correct value,exit tertiary for loop
                            print("It is the", i + 1, "SECONDARY IE;", "the", t + 1, "TERTIARY IE")
                            index_offset += TERTIARY_LEN
                            break
                        index_offset += TERTIARY_LEN  # move to the next tertiary
                    if cursion_flag:
                        break  # exit secondary for loop

                if cursion_flag:
                    cursion_flag = False
                    list_tmp[CHECK_RESULT] = PASS
                else:
                    list_tmp[CHECK_RESULT] = FAIL
            elif int(need_to_check_pcmd_array[j][FIELD_AREA]) == QCI_NONNULL and int(
                    dict_real_cnpq['sec_records']) >= 1:
                index_offset = PRIMARY_LEN - 1
                print("QCI_NONNULL:", "Tertiary index=", index_offset, "sec num=",
                      int(dict_real_cnpq['sec_records']))
                for i in range(int(dict_real_cnpq['sec_records'])):
                    index_offset += SECONDARY_LEN  # ready to start from new SECONDARY IE
                    print("Secondary start=", index_offset, "i=", i, "int(list_real_m_tertiary[i])=",
                          int(list_real_m_tertiary[i]))
                    for t in range(int(list_real_m_tertiary[i])):  # check tertiary on the secondary IE
                        list_tmp[REAL_VALUE] = list_real_all_record[index_offset + need_to_check_pcmd_array[j][INDEX]]
                        print("In tertiary QCI_NONNULL process,t=", t, "QCI=",
                              need_to_check_pcmd_array[j][DELTA])
                        if int(list_tmp[REAL_VALUE]) != "" and int(list_real_all_record[index_offset + 1]) == \
                                need_to_check_pcmd_array[j][DELTA]:
                            cursion_flag = True  # get the correct value,exit tertiary for loop
                            print("It is the", i + 1, "SECONDARY IE;", "the", t + 1, "TERTIARY IE")
                            index_offset += TERTIARY_LEN
                            break
                        index_offset += TERTIARY_LEN  # move to the next tertiary
                    if cursion_flag:
                        break  # exit secondary for loop
                if cursion_flag:
                    cursion_flag = False
                    list_tmp[CHECK_RESULT] = PASS
                else:
                    list_tmp[CHECK_RESULT] = FAIL
            elif int(need_to_check_pcmd_array[j][FIELD_AREA]) == QCI_CPLANE \
                    and int(dict_real_cnpq['sec_records']) >= 1:
                index_offset = PRIMARY_LEN - 1
                print("QCI_CPLANE:", "Tertiary index=", index_offset, "sec num=",
                      int(dict_real_cnpq['sec_records']))
                for i in range(int(dict_real_cnpq['sec_records'])):
                    index_offset += SECONDARY_LEN  # ready to start from new SECONDARY IE
                    print("Secondary start=", index_offset, "i=", i, "int(list_real_m_tertiary[i])=",
                          int(list_real_m_tertiary[i]))
                    for t in range(int(list_real_m_tertiary[i])):  # check tertiary on the secondary IE
                        list_tmp[REAL_VALUE] = list_real_all_record[index_offset + need_to_check_pcmd_array[j][INDEX]]
                        print("In tertiary QCI_CPLANE process,t=", t, "QCI=",
                              need_to_check_pcmd_array[j][DELTA])
                        if int(list_tmp[REAL_VALUE]) == need_to_check_pcmd_array[j][TARGET_VALUE] and int(
                                list_real_all_record[index_offset + 1]) == need_to_check_pcmd_array[j][DELTA]:
                            cursion_flag = True  # get the correct value,exit tertiary for loop
                            print("It is the", i + 1, "SECONDARY IE;", "the", t + 1, "TERTIARY IE")
                            index_offset += TERTIARY_LEN
                            break
                        index_offset += TERTIARY_LEN  # move to the next tertiary
                    if cursion_flag:
                        break  # exit secondary for loop
                if cursion_flag:
                    cursion_flag = False
                    list_tmp[CHECK_RESULT] = PASS
                else:
                    list_tmp[CHECK_RESULT] = FAIL
            elif int(dict_real_cnpq['sec_records']) == 1:
                list_tmp[REAL_VALUE] = list_real_all_record[
                    PRIMARY_LEN + SECONDARY_LEN + need_to_check_pcmd_array[j][INDEX] - 1]
            else:
                print(
                    "the first Tertiary IE on the second SECONDARY for example,not completed solution")
                list_tmp[REAL_VALUE] = list_real_all_record[
                    PRIMARY_LEN + SECONDARY_LEN * 1 + int(list_real_m_tertiary[0]) * TERTIARY_LEN +
                    need_to_check_pcmd_array[j][INDEX] - 1]
            print("Tertiary test value:", list_tmp[REAL_VALUE])
        # MR record
        elif need_to_check_pcmd_array[j][KEYWORD] == CELLMRPT:
            for t in range(int(dict_real_cnpq['sec_records'])):
                index_offset += SECONDARY_LEN + int(list_real_m_tertiary[t]) * TERTIARY_LEN
            list_tmp[REAL_VALUE] = list_real_all_record[
                PRIMARY_LEN + need_to_check_pcmd_array[j][INDEX] + index_offset - 2 + (
                        1 - 1) * CELLMRPT_LEN]
            print("CellMrpt test value:", list_tmp[REAL_VALUE])
        # CA record
        elif need_to_check_pcmd_array[j][KEYWORD] == CARPT:
            # print "CARPT test value get"
            # print "dict_real_cnpq['cell_meas'] = %s" % (dict_real_cnpq['cell_meas'])
            for t in range(int(dict_real_cnpq['sec_records'])):
                index_offset += SECONDARY_LEN + int(list_real_m_tertiary[t]) * TERTIARY_LEN
            if int(dict_real_cnpq['cell_meas']) > 0:
                if int(need_to_check_pcmd_array[j][INDEX]) == 1:
                    str_tmp = list_real_all_record[PRIMARY_LEN + index_offset - 1]
                    # print "CARPT test value get in and found MR, MR number is = %s" % str_tmp
                    numberOfMR = int(str_tmp[1:])
                index_offset += numberOfMR * CELLMRPT_LEN  # if there is MR, the offset need to add to the MR len
                # print "CARPT test value offset is = %s" % index_offset
                list_tmp[REAL_VALUE] = list_real_all_record[
                    PRIMARY_LEN + need_to_check_pcmd_array[j][INDEX] + index_offset - 4 + (
                            1 - 1) * CARPT_LEN]
            else:
                list_tmp[REAL_VALUE] = list_real_all_record[
                    PRIMARY_LEN + need_to_check_pcmd_array[j][INDEX] + index_offset - 1 + (1 - 1) * CARPT_LEN]

            print("CArpt test value:", list_tmp[REAL_VALUE])
        # RRC Failure record
        elif need_to_check_pcmd_array[j][KEYWORD] == RRCFAILURERPT:
            if int(dict_real_cnpq['rrc_failure']) == 1:
                print("Only one RRCFailure report!")
                str_tmp = list_real_all_record[
                    -2 + need_to_check_pcmd_array[j][INDEX] - 1]  # the last RRCFailure starts from index -2
                if int(need_to_check_pcmd_array[j][INDEX]) == 1:
                    list_tmp[REAL_VALUE] = str_tmp[1:]
                elif int(need_to_check_pcmd_array[j][INDEX]) == 2:
                    list_tmp[REAL_VALUE] = str_tmp[:-2]
                else:
                    print("The index=", need_to_check_pcmd_array[j][INDEX], "not support in RRCFailure report now!")
                    return None
            elif int(dict_real_cnpq['rrc_failure']) == -1:
                print("Error: No RRCFailure exists!")
                return None
            else:
                print("More than one RRCFailure reports, no handling now~")
                return None
            print("RRCFail test value:", list_tmp[REAL_VALUE])
        # sgnbrequest record
        elif need_to_check_pcmd_array[j][KEYWORD] == SGNBREQ:
            d = [d for d in list_real_all_record if 'F' in d]
            sgnb_count_index = list_real_all_record.index(d[0])
            dict_real_cnpq['sgnb_req'] = list_real_all_record[sgnb_count_index + 1]
            if int(dict_real_cnpq['sgnb_req']) >= 1:
                print("Sgnb req report is available! Number:", dict_real_cnpq['sgnb_req'])
                list_tmp[REAL_VALUE] = list_real_all_record[
                    sgnb_count_index + FSM_LEN - 1 + need_to_check_pcmd_array[j][INDEX]]
                print("Sgnb test value:", list_tmp[REAL_VALUE])
            elif int(dict_real_cnpq['sgnb_req']) == -1:
                print("Error: No Sgnb req report exists!")
                return None
            else:
                print("not valid Sgnb req number value", dict_real_cnpq['sgnb_req'])
                return None
            # print("gNB ID in sgnb test value:", list_real_all_record[sgnb_count_index+FSM_LEN])
        elif need_to_check_pcmd_array[j][KEYWORD] == CU:
            d = [d for d in list_real_all_record if 'C' in d]
            cu_count_index = list_real_all_record.index(d[0])
            dict_real_cnpq['cu'] = list_real_all_record[cu_count_index + 1]
            if int(dict_real_cnpq['cu']) >= 1:
                print("CU header report is available! Number:", dict_real_cnpq['cu'])
                list_tmp[REAL_VALUE] = list_real_all_record[
                    cu_count_index + CU_HEAD_LEN - 1 + need_to_check_pcmd_array[j][INDEX]]
                print("CU test value:", list_tmp[REAL_VALUE])
            elif int(dict_real_cnpq['cu']) == -1:
                print("Error: No CU report exists!")
                return None
            else:
                print("not valid CU number value", dict_real_cnpq['cu'])
                return None
        elif need_to_check_pcmd_array[j][KEYWORD] == DU:
            d = [d for d in list_real_all_record if 'D' in d]
            du_count_index = list_real_all_record.index(d[0])
            dict_real_cnpq['du'] = list_real_all_record[du_count_index + 1]
            if int(dict_real_cnpq['du']) >= 1:
                print("DU header report is available! Number:", dict_real_cnpq['du'])
                list_tmp[REAL_VALUE] = list_real_all_record[
                    du_count_index + DU_HEAD_LEN - 1 + need_to_check_pcmd_array[j][INDEX]]
                print("DU test value:", list_tmp[REAL_VALUE])
            elif int(dict_real_cnpq['du']) == -1:
                print("Error: No DU report exists!")
                return None
            else:
                print("not valid DU number value", dict_real_cnpq['du'])
                return None
        else:
            print('Error: index=', j, 'Keyword=', need_to_check_pcmd_array[j][KEYWORD], 'is not correct!')
            return None
        index_offset = 0
        if list_tmp[REAL_VALUE] == "":
            print("The test value is empty for this target PCMD check:", need_to_check_pcmd_array[j])
            list_tmp[CHECK_RESULT] = FAIL
        else:
            if int(list_tmp[FIELD_AREA]) == NONNULL:
                print("The target is NON-NULL check,PCMD match!")
                list_tmp[CHECK_RESULT] = PASS
            elif int(list_tmp[FIELD_AREA]) == TIME:
                time_minute = int(timestamp_to_string(list_tmp[REAL_VALUE]))
                time_target = int(need_to_check_pcmd_array[j][TARGET_VALUE])
                if need_to_check_pcmd_array[j][DELTA] == 0:
                    if time_minute >= time_target:
                        list_tmp[CHECK_RESULT] = PASS
                        print("The TIME check,PCMD match!")
                    else:
                        list_tmp[CHECK_RESULT] = FAIL
                        print("The TIME check,PCMD not match!")
                else:
                    if time_minute <= time_target:
                        list_tmp[CHECK_RESULT] = PASS
                        print("The TIME check,PCMD match!")
                    else:
                        list_tmp[CHECK_RESULT] = FAIL
                        print("The TIME check,PCMD not match!")
                list_tmp[REAL_VALUE] = str(list_tmp[REAL_VALUE]) + '_' + str(time_minute)
            elif int(list_tmp[FIELD_AREA]) == RECURSION or int(list_tmp[FIELD_AREA]) == QCI_NONNULL:
                # if recursion/QCI_NONNULL, have get the real value,check result before, add it to the result directly
                if list_tmp[CHECK_RESULT] == PASS:
                    print("PCMD match!")
                else:
                    print("PCMD not match")
            else:
                if ':' in list_tmp[REAL_VALUE]:
                    cell_id = int(list_tmp[REAL_VALUE].split(':')[-1], 16)
                    enb_id = str(cell_id / 256)
                    enb_cell_id = str(cell_id % 256)
                    if cell_id == need_to_check_pcmd_array[j][TARGET_VALUE]:
                        print("PCMD cell id match!")
                        list_tmp[CHECK_RESULT] = PASS
                    else:
                        list_tmp[CHECK_RESULT] = FAIL
                        print("PCMD cell id not match!")
                    list_tmp[REAL_VALUE] = str(list_tmp[REAL_VALUE]) + '_enb' + enb_id + '_' + enb_cell_id
                else:
                    if ((int(list_tmp[REAL_VALUE]) >= (
                            need_to_check_pcmd_array[j][TARGET_VALUE] - need_to_check_pcmd_array[j][TARGET_VALUE] *
                            need_to_check_pcmd_array[j][DELTA] / 100))
                            and (int(list_tmp[REAL_VALUE]) <= (need_to_check_pcmd_array[j][TARGET_VALUE] +
                                                               need_to_check_pcmd_array[j][TARGET_VALUE] *
                                                               need_to_check_pcmd_array[j][DELTA] / 100))):
                        print("PCMD match!")
                        list_tmp[CHECK_RESULT] = PASS
                    else:
                        print(("PCMD not match! test_value=%d,target_value=%d,delta=%d" % (
                            int(list_tmp[REAL_VALUE]), need_to_check_pcmd_array[j][TARGET_VALUE],
                            need_to_check_pcmd_array[j][DELTA])))
                        list_tmp[CHECK_RESULT] = FAIL
        list_tmp = check_field_limit(list_tmp)
        # ====add it to the result=========##
        print("====================")
        list_add = list_tmp[:]
        list_result.append(list_add)
        for m in range(len(list_tmp)):
            list_tmp[m] = INVALID
    return list_result


def compare_pcmd(input_pcmd_array_raw, input_record):
    ca_logic_res = True
    dict_record = {'cell_meas': '-1', 'sec_records': '-1', 'ca_records': '-1', 'rrc_failure': '-1', 'sgnb_req': '-1',
                   'cu': '-1', 'cu_bearer': '-1', 'cu_ca': '-1', 'cu_meas': '-1', 'du': '-1', 'du_bearer': '-1',
                   'du_ca': '-1', 'du_beam': '-1'}
    list_tertiary = []
    input_pcmd_array = []
    input_record = input_record.replace('[', ';')
    record_list = input_record.split(';')
    print("input pcmd record", record_list)
    # ===get the value from the value list and fill them into the dict========##
    if record_list[CELLMRPT_POS] != "" and int(record_list[CELLMRPT_POS]) > 0:
        dict_record['cell_meas'] = record_list[CELLMRPT_POS]  # fix position index=127
    else:
        print("No Cell Mearsurement Reports exist!")
    # Tracy    if record_list[SECONDARY_POS]!="" and int(record_list[SECONDARY_POS])>0:
    if record_list[SECONDARY_POS] != "" and int(record_list[SECONDARY_POS]) > 0:
        dict_record['sec_records'] = record_list[SECONDARY_POS]
        if int(record_list[SECONDARY_POS]) == 1:
            if record_list[PRIMARY_LEN + TERTIARY_POS_IN_SEC - 1] != "" and int(
                    record_list[PRIMARY_LEN + TERTIARY_POS_IN_SEC - 1]) > 0:
                list_tertiary.append(int(record_list[PRIMARY_LEN + TERTIARY_POS_IN_SEC - 1]))
                print("list)tertiary", list_tertiary)
            elif record_list[PRIMARY_LEN + TERTIARY_POS_IN_SEC - 1] == "" or int(
                    record_list[PRIMARY_LEN + TERTIARY_POS_IN_SEC - 1]) == 0:
                list_tertiary.append(0)
                print("No Tertiary exist in the first Secondary IE,append 0 for tertiary!")
            else:
                print("Error:unexpected value of Tertiary value=", record_list[PRIMARY_LEN + TERTIARY_POS_IN_SEC - 1])
        elif int(record_list[SECONDARY_POS]) > 1:
            print("secondary num=", record_list[SECONDARY_POS])
            last_end_pos = PRIMARY_LEN - 1
            for i in range(int(record_list[SECONDARY_POS])):
                if record_list[last_end_pos + TERTIARY_POS_IN_SEC] != "" and int(
                        record_list[last_end_pos + TERTIARY_POS_IN_SEC]) > 0:
                    list_tertiary.append(int(record_list[last_end_pos + TERTIARY_POS_IN_SEC]))
                elif int(record_list[last_end_pos + TERTIARY_POS_IN_SEC]) == 0:
                    list_tertiary.append(0)  # This secondary has none tertiary IE.
                else:
                    print("Error:unexpected V of Tertiary value=", record_list[last_end_pos + TERTIARY_POS_IN_SEC])
                last_end_pos += SECONDARY_LEN + int(list_tertiary[i]) * TERTIARY_LEN  # update the last end pos
        else:
            print("Error secondary num=", record_list[SECONDARY_POS])
            return False
        if len(list_tertiary) != int(record_list[SECONDARY_POS]):
            print(("Error:The tertiary length=%d is not equal to the secondary number=%d" % (
                len(list_tertiary), int(record_list[SECONDARY_POS]))))
            return False
    else:
        print("No Secondary Elements exist!")
    if record_list[CARPT_POS] != "" and int(record_list[CARPT_POS]) > 0:
        dict_record['ca_records'] = record_list[CARPT_POS]
    elif int(record_list[CARPT_POS]) == 0:
        dict_record['ca_records'] = record_list[CARPT_POS]
        print("No CarrierAggregation Reports exist!")
    else:
        print("Invalid CarrierAggregation Reports exist!")
    if record_list[RRCFAIL_POS] != "" and int(record_list[RRCFAIL_POS]) > 0:
        dict_record['rrc_failure'] = record_list[RRCFAIL_POS]
    else:
        print("No RRC Setup Fail Reports exist!")

    # ===transfer the input str to Num&Variant========##
    for i in range(len(input_pcmd_array_raw)):
        input_pcmd_array.append([] * 7)
        input_pcmd_array[i].append(eval(input_pcmd_array_raw[i][KEYWORD]))
        input_pcmd_array[i].append(int(input_pcmd_array_raw[i][INDEX]))
        input_pcmd_array[i].append(eval(input_pcmd_array_raw[i][FIELD_AREA]))
        input_pcmd_array[i].append(int(input_pcmd_array_raw[i][DELTA]))
        input_pcmd_array[i].append(int(input_pcmd_array_raw[i][TARGET_VALUE]))
        if len(input_pcmd_array_raw[i]) >= LOWER_LIMIT + 1:
            input_pcmd_array[i].append(input_pcmd_array_raw[i][LOWER_LIMIT])
        else:
            input_pcmd_array[i].append('')
        if len(input_pcmd_array_raw[i]) >= UPPER_LIMIT + 1:
            input_pcmd_array[i].append(input_pcmd_array_raw[i][UPPER_LIMIT])
        else:
            input_pcmd_array[i].append('')
        print("test: %s" % input_pcmd_array[i])
    # ========check the pcmd and return the check result==============##
    list_pcmd_res = check_pcmd_value(dict_record, list_tertiary, record_list, input_pcmd_array)
    if record_list[CARPT_POS] != "" and int(record_list[CARPT_POS]) > 0:
        ca_logic_res = check_ca_logic(list_pcmd_res)
    if list_pcmd_res is None:
        return False
    fail_flag = False
    for n in range(len(list_pcmd_res)):
        if list_pcmd_res[n][CHECK_RESULT] == FAIL:
            fail_flag = True
    if fail_flag or ca_logic_res is False:
        print("Case Failed!!! Output:", list_pcmd_res)
        return False
    else:
        print("Case Successful!!! Output:", list_pcmd_res)
        return True


def check_field_limit(field_value):
    print("limit check berfore: %s" % field_value)
    if field_value[REAL_VALUE] == "":
        print("the field value is empty")
    elif field_value[LOWER_LIMIT] == "" and field_value[UPPER_LIMIT] == "":
        print("the field no need check lower limit and upper limit")
    elif field_value[LOWER_LIMIT] == "":
        if int(field_value[REAL_VALUE]) < int(field_value[UPPER_LIMIT]):
            field_value[CHECK_RESULT] = FAIL
        print("the field no need check lower limit")
    elif field_value[UPPER_LIMIT] == "":
        if int(field_value[REAL_VALUE]) > int(field_value[LOWER_LIMIT]):
            field_value[CHECK_RESULT] = FAIL
        print("the field no need check upper limit")
    elif int(field_value[REAL_VALUE]) < int(field_value[LOWER_LIMIT]) or int(field_value[REAL_VALUE]) > int(
            field_value[UPPER_LIMIT]):
        print("REAL_VALUE: %s" % field_value[REAL_VALUE])
        print("LOWER_LIMIT:%s" % field_value[LOWER_LIMIT])
        print("UPPER_LIMIT:%s" % field_value[UPPER_LIMIT])
        field_value[CHECK_RESULT] = FAIL
    print("limit check result:  %s" % field_value)
    return field_value


def check_ca_logic(pcmd_result_array):
    print("CA logic check start!")
    ca_config = 0
    ca_deconfig = 0
    ca_active = 0
    ca_deactive = 0
    ca_active_failure = 0
    ca_config_duration = 0
    ca_active_duration = 0
    deconfig_cause1 = 0
    deconfig_cause2 = 0
    deconfig_cause3 = 0
    deconfig_cause4 = 0
    deactive_cause1 = 0
    deactive_cause2 = 0
    check_result = True
    for i in pcmd_result_array:
        if i[KEYWORD] == CARPT:
            if i[INDEX] == 2:
                ca_config = int(i[REAL_VALUE])
            elif i[INDEX] == 3:
                ca_deconfig = int(i[REAL_VALUE])
            elif i[INDEX] == 4:
                ca_config_duration = int(i[REAL_VALUE])
            elif i[INDEX] == 5:
                ca_active = int(i[REAL_VALUE])
            elif i[INDEX] == 6:
                if i[REAL_VALUE] == "":
                    i[REAL_VALUE] = 0
                ca_deactive = int(i[REAL_VALUE])
            elif i[INDEX] == 7:
                if i[REAL_VALUE] == "":
                    i[REAL_VALUE] = 0
                ca_active_failure = int(i[REAL_VALUE])
            elif i[INDEX] == 8:
                ca_active_duration = int(i[REAL_VALUE])
            elif i[INDEX] == 22:
                deconfig_cause1 = int(i[REAL_VALUE])
            elif i[INDEX] == 23:
                deconfig_cause2 = int(i[REAL_VALUE])
            elif i[INDEX] == 25:
                deconfig_cause3 = int(i[REAL_VALUE])
            elif i[INDEX] == 29:
                deconfig_cause4 = int(i[REAL_VALUE])
            elif i[INDEX] == 26:
                deactive_cause1 = int(i[REAL_VALUE])
            elif i[INDEX] == 27:
                deactive_cause2 = int(i[REAL_VALUE])
    if ca_config < ca_deconfig:
        print("ERROR:  CAconf(2) and CAdeconf(3) mismatched.")
        check_result = False
    if ca_active < (ca_deactive + ca_active_failure):
        print("ERROR: CAactive(5) and CAdeactive(6)+CAactiveFailure(7) mismatched.")
        check_result = False
    if ca_config < ca_active:
        print("ERROR: CAconf(2) and CAactive(5) mismatched.")
        check_result = False
    if ca_config_duration < ca_active_duration:
        print("ERROR: CAconfDuration(4) and CAactiveDuration(8) mismatched.")
        check_result = False
    if check_result:
        print("INFO: CA logic check passed!")
    num_deconfcause1_cont = (deconfig_cause1 & 0xff) + ((deconfig_cause1 >> 8) & 0xff) + (
            (deconfig_cause1 >> 16) & 0xff) + ((deconfig_cause1 >> 24) & 0xff)
    num_deconfcause2_cont = (deconfig_cause2 & 0xff) + ((deconfig_cause2 >> 8) & 0xff) + (
            (deconfig_cause2 >> 16) & 0xff) + ((deconfig_cause2 >> 24) & 0xff)
    num_deconfcause3_cont = (deconfig_cause3 & 0xff) + ((deconfig_cause3 >> 8) & 0xff) + (
            (deconfig_cause3 >> 16) & 0xff) + ((deconfig_cause3 >> 24) & 0xff)
    num_deconfcause4_cont = (deconfig_cause4 & 0xff) + ((deconfig_cause4 >> 8) & 0xff) + (
            (deconfig_cause4 >> 16) & 0xff) + ((deconfig_cause4 >> 24) & 0xff)
    num_deconf_count = num_deconfcause1_cont + num_deconfcause2_cont + num_deconfcause3_cont + num_deconfcause4_cont
    num_deactcause1_count = (deactive_cause1 & 0xff) + ((deactive_cause1 >> 8) & 0xff) + (
            (deactive_cause1 >> 16) & 0xff) + ((deactive_cause1 >> 24) & 0xff)
    num_deactcause2_count = (deactive_cause2 & 0xff) + ((deactive_cause2 >> 8) & 0xff) + (
            (deactive_cause2 >> 16) & 0xff) + ((deactive_cause2 >> 24) & 0xff)
    num_deact_count = num_deactcause1_count + num_deactcause2_count
    if num_deconf_count != ca_deconfig:
        print("ERROR: ca_deconfig and deconf_cause times mismatched. cause times:", num_deconf_count)
    if num_deact_count != ca_deactive:
        print("ERROR: ca_deactive and deact_cause times mismatched. cause times:", num_deact_count)
    return check_result


def change_unicode(change_list):
    for j in range(len(change_list)):
        for i in range(len(change_list[0])):
            try:
                change_list[j][i] = change_list[j][i].encode("utf-8", )
            except IndexError:
                change_list[j].append('')
    print("unicoded change check list: %s" % change_list)
    return change_list


def timestamp_to_string(timestamp):
    now = time.time()
    midnight = float(now - (now % 86400) + time.timezone + 28800)
    timestamp = float(timestamp) / 1000
    time_local = time.localtime(midnight + timestamp)
    record_time = time.strftime("%Y%m%d%H%M", time_local)
    return record_time
