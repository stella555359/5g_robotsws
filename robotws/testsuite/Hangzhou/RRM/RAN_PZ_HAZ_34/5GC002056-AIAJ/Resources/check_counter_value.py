# -*- coding: utf-8 -*-
"""
Author: Ren Biyao
Contacts: biyao.ren@nokia-sbell.com
"""


def check_counter_with_expected_value(expected_counter_with_value,
                                      given_counter_dict,
                                      cell_id=1):
    """
    :param expected_counter_with_value: dict_type eg:  eg {{u'M55112C05001': '1',
                                         u'M55112C05002': '1'}}
    :param given_counter_dict : eg {'1': {u'M55112C05001': '0',
                                         u'M55112C05002': '0',
                                         u'M55118C02008': '0',
                                         u'M55118C02010': '0',
                                         u'M55118C02012': '0'},
                                    '2': {u'M55118C02001': '0',
                                         u'M55118C02006': '0',
                                         u'M55118C02008': '0',
                                         u'M55118C02010': '1',
                                         u'M55118C02012': '0'}}
    :param cell_id :
    """
    check_pass_flag = 0
    check_fail_counter = []
    for cur_counter in expected_counter_with_value.keys():
        cur_counter = str(cur_counter)
        cell_id = str(cell_id)
        act_value_of_counter = given_counter_dict[cell_id][cur_counter]
        expected_value_of_counter = expected_counter_with_value[cur_counter]
        if int(act_value_of_counter) >= int(expected_value_of_counter):
            check_pass_flag = check_pass_flag + 1
        else:
            check_fail_counter.append(cur_counter)
    if check_pass_flag == len(expected_counter_with_value):
        pass
    else:
        raise Exception("Counter check fails! Failed counter: {}". format(check_fail_counter))
