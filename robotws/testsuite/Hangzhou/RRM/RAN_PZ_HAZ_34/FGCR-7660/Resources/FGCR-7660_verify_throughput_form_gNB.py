# -*- coding: utf-8 -*-
"""
Author: Fang ludan
Contacts: ludan.fang@nokia-sbell.com
Description: Verify tput from GNB log

"""


import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.check_average_throughput as check_tput


def get_details_of_peak_tput_each_cells(tput_file, list_cell, nr_cell_id_mapping):
    """
    Author: Fang ludan
    This keyword is to get details of peak tput
    :param tput_file: file_paths on cluster returned from start_tput_log_capturingimport
                      Format like bellow: /XXX/XXX/Tput_UL_L2LO_20191126110505.txt
    :param list_cell: [1,2,3,4,5]
    :param nr_cell_id_mapping:
    :return:avg_peak_tput: average peak tput in given period
            max_peak_tput: the max value of peak tput in given period
            min_peak_tput: the min value of peak tput in given period
            detail_peak_tput_info: the peak tput for every moment
            Note: the return value must be in order.
    """
    direction = check_tput.get_direction_by_file_name(tput_file=tput_file)
    dict_tput_for_cells = check_tput.get_tput_info_for_l2lo(tput_file=tput_file, direction=direction)
    avg_peak_tput_info = []
    for cell in list_cell:
        cell = int(cell)
        nrCellIdentity = nr_cell_id_mapping[cell]['nrCellIdentity']
        avg_peak_tput_info.append(dict_tput_for_cells[int(nrCellIdentity)]['average_tput'])
    return (avg_peak_tput_info)
