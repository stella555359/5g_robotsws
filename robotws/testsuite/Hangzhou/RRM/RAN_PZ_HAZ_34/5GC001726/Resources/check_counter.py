# -*- coding: utf-8 -*-
"""
Author: Ren Biyao
Contacts: biyao.ren@nokia-sbell.com
Description: Verify tput from GNB log

"""
import logging
from collections import Counter
import pprint


def check_one_expected_counter_works_for_each_cell(expect_counter_id,
                                                   expect_counter_value,
                                                   cell_id,
                                                   cell_counters_dict,
                                                   num_cells_with_expected_counter_work):
    """
    Author: Ren Biyao
    :param expect_counter_id:
    :param expect_counter_value: list_type, eg ['299', '300', '301]
    :param cell_id: list_type, eg ['1', '2', '3', '4']
    :param cell_counters_dict: eg {'1': {u'M55118C02001': '0',
                                         u'M55118C02006': '0',
                                         u'M55118C02008': '0',
                                         u'M55118C02010': '0',
                                         u'M55118C02012': '0'},
                                    '2': {u'M55118C02001': '0',
                                         u'M55118C02006': '0',
                                         u'M55118C02008': '0',
                                         u'M55118C02010': '1',
                                         u'M55118C02012': '0'}}
    :param num_cells_with_expected_counter_work:
    :return:
    """
    list_check_status_all_cells = []
    for cur_cell_id in cell_id:
        cur_cell_id = str(cur_cell_id)
        expect_counter_id = str(expect_counter_id)
        act_value_of_expected_counter = cell_counters_dict[cur_cell_id][expect_counter_id]
        list_check_result_once = []
        for cur_expect_value in expect_counter_value:
            cur_check_result = 0 if int(act_value_of_expected_counter) == int(cur_expect_value) else 1
            # cur_check_result = cmp(int(act_value_of_expected_counter), int(cur_expect_value))
            list_check_result_once.append(cur_check_result)
        check_result_status_once = Counter(list_check_result_once)

        if int(check_result_status_once[0]) == int(1):
            final_check_result = True
        else:
            final_check_result = False
        list_check_status_all_cells.append(final_check_result)

    check_status_all_cells = Counter(list_check_status_all_cells)
    act_number = int(check_status_all_cells[True])
    if int(act_number) == int(num_cells_with_expected_counter_work):
        pass
    else:
        raise Exception("the actual number of counter {} which works correctly on diffetent cells is {}, "
                        "which does not match the expected cell number {}."
                        "". format(expect_counter_id, act_number, num_cells_with_expected_counter_work))


def check_several_counters_remian_idle_for_each_cell(list_all_interested_counter_ids,
                                                     expect_work_counter_id,
                                                     cell_id,
                                                     cell_counters_dict):
    """
    :param list_all_interested_counter_ids:
    :param expect_work_counter_id:
    :param cell_id: list_type, eg ['1', '2', '3', '4']
    :param cell_counters_dict: eg {'1': {u'M55118C02001': '0',
                                         u'M55118C02006': '0',
                                         u'M55118C02008': '0',
                                         u'M55118C02010': '0',
                                         u'M55118C02012': '0'},
                                    '2': {u'M55118C02001': '0',
                                         u'M55118C02006': '0',
                                         u'M55118C02008': '0',
                                         u'M55118C02010': '1',
                                         u'M55118C02012': '0'}}
    :return:
    """

    dict_all_cell_with_check_status = {}
    list_all_interested_counter_ids.remove(str(expect_work_counter_id))
    num_expect_counter = len(list_all_interested_counter_ids)
    for cur_cell_id in cell_id:
        cur_cell_id = str(cur_cell_id)
        list_expect_counter_value = []
        for cur_counter_id in list_all_interested_counter_ids:
            cur_counter_id = str(cur_counter_id)
            act_value_of_cur_expect_counter = cell_counters_dict[cur_cell_id][cur_counter_id]
            if type(act_value_of_cur_expect_counter) is int:
                act_value_of_cur_expect_counter = str(act_value_of_cur_expect_counter)
            list_expect_counter_value.append(act_value_of_cur_expect_counter)

        check_result_status_once = Counter(list_expect_counter_value)
        if int(check_result_status_once['0']) == num_expect_counter:
            dict_all_cell_with_check_status[cur_cell_id] = True
        else:
            dict_all_cell_with_check_status[cur_cell_id] = False
            logging.debug("the current cell is {}, its counter {} does "
                          "not remain idle". format(cur_cell_id, cur_counter_id))
    check_status = list(set(dict_all_cell_with_check_status.values()))
    pprint.pprint(check_status)
    if len(check_status) != 1:
        raise Exception("Not all counters remain idle!")
    elif check_status[0] is False:
        raise Exception("All counters do not remain idle!")


def check_the_sum_of_counter_as_given(cell_id,
                                      cell_counters_dict):
    """
    Description: If case SCell Status changes but there is only one UE,
                 the SUM of M55316C03000…M55316C03007 should be the same as M55316C01003.
                 accord with “sCellActivationMethod = bufferBased”
    :param cell_id: int_type
    :param cell_counters_dict: eg {'1': {u'M55118C02001': '0',
                                         u'M55118C02006': '0',
                                         u'M55118C02008': '0',
                                         u'M55118C02010': '0',
                                         u'M55118C02012': '0'},
                                    '2': {u'M55118C02001': '0',
                                         u'M55118C02006': '0',
                                         u'M55118C02008': '0',
                                         u'M55118C02010': '1',
                                         u'M55118C02012': '0'}}
    :return:
    """
    sum_counter_value = 0
    list_expect_counter_to_check = ['M55316C03000', 'M55316C03001', 'M55316C03002',
                                    'M55316C03003', 'M55316C03004', 'M55316C03005',
                                    'M55316C03006', 'M55316C03007']
    cell_id = str(cell_id)
    value_of_M55316C01003 = cell_counters_dict[cell_id]['M55316C01003']
    for cur_counter in list_expect_counter_to_check:
        cur_value_of_expected_counter = cell_counters_dict[cell_id][cur_counter]
        cur_value_of_expected_counter = int(cur_value_of_expected_counter)

        sum_counter_value = sum_counter_value + cur_value_of_expected_counter
    if int(value_of_M55316C01003) == int(sum_counter_value):
        pass
    else:
        raise Exception("the SUM of M55316C03000…M55316C03007 is not equal with M55316C01003.")
