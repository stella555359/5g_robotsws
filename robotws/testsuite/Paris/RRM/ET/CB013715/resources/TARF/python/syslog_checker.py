#! /user/bin/enn python
# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author:
:contact:
:maintainer:
:contact:
"""


def Get_ERR_and_WRN_counter(error_string):
    print('{} L1SW-RT ERR is found'.format(error_string.count('ERR L1SW-RT')))
    print('{} L1SW-RT WRN is found'.format(error_string.count('WRN L1SW-RT')))
    return error_string.count('ERR L1SW-RT'), error_string.count('WRN L1SW-RT')


def Get_ERR_and_WRN_info(error_string, white_list):
    if error_string is None:
        return True

    ignore_err_wrn_dict = {}
    err_wrn_list = [line for line in error_string.splitlines() if line]  # Remove empty strings

    for item in white_list:
        ignore_err_wrn_list = [err_wrn for err_wrn in err_wrn_list if item in err_wrn]
        if ignore_err_wrn_list:
            ignore_err_wrn_dict[item] = ignore_err_wrn_list
        else:
            pass
        # Pop items containing the white_list item
        err_wrn_list = [err_wrn for err_wrn in err_wrn_list if item not in err_wrn]
    err_wrn_list = err_wrn_list if err_wrn_list else list()
    return ignore_err_wrn_dict, err_wrn_list


if __name__ == '__main__':
    pass
