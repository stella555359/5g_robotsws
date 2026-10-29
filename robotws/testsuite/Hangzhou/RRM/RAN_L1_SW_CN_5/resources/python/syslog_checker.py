#! /usr/bin/env python
# -*- coding: utf-8 -*-

import re


def Get_ERR_and_WRN_counter(error_string):
    """
    Count the number of ERR and WRN occurrences in the error_string.

    :param error_string: A string containing error and warning messages.
    :return: A tuple containing the count of ERR and WRN occurrences.
    """
    print('{} L1SW-RT ERR is found'.format(error_string.count('ERR L1SW-RT')))
    print('{} L1SW-RT WRN is found'.format(error_string.count('WRN L1SW-RT')))
    return error_string.count('ERR L1SW-RT'), error_string.count('WRN L1SW-RT')


def Get_ERR_and_WRN_info(error_string, white_list):
    """
    Process the error_string and filter out messages based on the white_list.
    Create ignore_err_wrn_dict, where the key is an item from the white_list,
    and the value is a tuple consisting of the length of ignore_err_wrn_list
    and the first element of ignore_err_wrn_list.

    :param error_string: A string containing error and warning messages.
    :param white_list: A list of keywords to filter out from the error_string.
    :return: ignore_err_wrn_dict and final_err_wrn_list
    """
    if error_string is None:
        return {}, []  # If error_string is None, return an empty dictionary and list

    # Split error_string into a list of lines
    err_wrn_list = [line for line in error_string.splitlines() if line]  # Remove empty lines

    # Initialize the ignore dictionary and the final list
    ignore_err_wrn_dict = {}
    final_err_wrn_list = []

    # Iterate through the white_list to build ignore_err_wrn_dict
    for item in white_list:
        # Find all lines in err_wrn_list that match the current item in white_list
        ignore_err_wrn_list = [err_wrn for err_wrn in err_wrn_list if re.search(r'{}'.format(item), err_wrn)]
        if ignore_err_wrn_list:
            # Use the item as the key, and (length, first element) as the value
            ignore_err_wrn_dict[item] = (len(ignore_err_wrn_list), ignore_err_wrn_list[0])

    # Build final_err_wrn_list by excluding all lines that match any item in white_list
    final_err_wrn_list = [
        err_wrn for err_wrn in err_wrn_list if all(not re.search(r'{}'.format(item), err_wrn) for item in white_list)
    ]

    return ignore_err_wrn_dict, final_err_wrn_list


if __name__ == '__main__':
    pass
