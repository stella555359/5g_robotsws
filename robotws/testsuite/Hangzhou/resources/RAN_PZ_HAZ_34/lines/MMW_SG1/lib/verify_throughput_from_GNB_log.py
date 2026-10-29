# -*- coding: utf-8 -*-
"""
Author: Ding Binmei
Contacts: binmei.ding@nokia-sbell.com
Description: Verify tput from GNB log

"""
import logging
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.check_average_throughput as check_tput


def verify_tput_is_maintained_for_cells(tput_file, exp_min_tput, list_nrCellIdentity=None, direction=None):
    """
    Author: Ding Binmei
    Description: Verify that tput is maintained for input cells
    :param tput_file: file_paths on cluster returned from start_tput_log_capturing
                      Format like bellow: /XXX/XXX/Tput_UL_L2LO_20191126110505.txt
    :param exp_min_tput: the min tput value should reach
    :param list_nrCellIdentity: only the input nrCellIndentitys will be verified.
           If none, then all the cells in log will be verified
           Example input: [16385, 16386, 16387, 16388]
    :param direction: Available values are: None, ul, dl
                      if tput_file format is not the same format as above, then direction value must be ul/dl
    :return:
    """
    direction = check_tput.get_direction_by_file_name(tput_file=tput_file, direction=direction)
    tput_info_for_cells = check_tput.get_tput_info_for_l2lo(tput_file=tput_file, direction=direction)
    logging.debug("detail_tput_info: {},\n nrCellIdentity:{}".format(tput_info_for_cells,
                                                                     tput_info_for_cells.keys()))
    if list_nrCellIdentity is None:
        list_nrCellIdentity = tput_info_for_cells.keys()
        print("Input list_nrCellIdentity is None, will verify for all cells")
    list_nrCellIdentitys_with_tput_not_maintained = []
    for nrCellIdentity in list_nrCellIdentity:
        nrCellIdentity = int(nrCellIdentity)
        if nrCellIdentity in tput_info_for_cells.keys():
            list_tput_info_per_cell = tput_info_for_cells[nrCellIdentity]["detail_tput_info"]
            list_tput_info_per_cell.sort()
            if list_tput_info_per_cell[0] < float(exp_min_tput):
                logging.error("Minimum tput value: {} < exp_min_tput: {}".format(
                    list_tput_info_per_cell[0], exp_min_tput))
                list_nrCellIdentitys_with_tput_not_maintained.append(nrCellIdentity)
        else:
            raise Exception("Fail to verify {} tput for nrCellIdentity:{}, as nrCellIdentity"
                            " not found from log.".format(direction, nrCellIdentity))
    if list_nrCellIdentitys_with_tput_not_maintained:
        raise Exception("{} throughput are not maintained for bellow nrCellIdentity: {}".format(
            direction, list_nrCellIdentitys_with_tput_not_maintained))
    else:
        print("{} throughput are maintained for input cells".format(direction))


def get_nrCellIdentity_with_tput_exists(tput_file, direction=None):
    """
    Author: Ding Binmei
    Description: Get nrCellIdentitys which tput does exist
    :param tput_file: file_paths on cluster returned from start_tput_log_capturing
                      Format like bellow: /XXX/XXX/Tput_UL_L2LO_20191126110505.txt
    :param direction: Available values are: None, ul, dl
                      if tput_file format is not the same format as above, then direction value must be ul/dl
    :return:
    """
    direction = check_tput.get_direction_by_file_name(tput_file=tput_file, direction=direction)
    tput_info_for_cells = check_tput.get_tput_info_for_l2lo(tput_file=tput_file, direction=direction)
    list_nrCellIdentity_with_tput = []
    for nrCellIdentity in tput_info_for_cells.keys():
        average_tput = tput_info_for_cells[nrCellIdentity]['average_tput']
        if average_tput > 0:
            list_nrCellIdentity_with_tput.append(nrCellIdentity)
    return list_nrCellIdentity_with_tput


def verify_cell_transmission_is_over_expected_num_of_cells(tput_file, expected_cell_num, direction=None):
    """
    Author: Ding Binmei
    Description: Verify cell transmission is over expected number of cells as expected, can support for ul/dl
    :param tput_file: file_paths on cluster returned from start_tput_log_capturing
                      Format like bellow: /XXX/XXX/Tput_UL_L2LO_20191126110505.txt
    :param expected_cell_num: can be a number 3,
           or a string like 3,4: it means 3 or 4 number of cells are used for ul/dl transmission
    :param direction: Available values are: None, ul, dl
                      if tput_file format is not the same format as above, then direction value must be ul/dl
    :return:
    """
    act_cell_num = len(get_nrCellIdentity_with_tput_exists(tput_file=tput_file, direction=direction))
    if str(expected_cell_num).find(',') != -1:
        list_exp_cell_num = expected_cell_num.split(',')
        if str(act_cell_num) in list_exp_cell_num:
            print("act_cell_num:{} is in range of expected cell nums: {}".format(
                act_cell_num, expected_cell_num))
        else:
            raise Exception("act_cell_num:{} is not in range of expected cell num: {}".format(
                act_cell_num, expected_cell_num))
    else:
        assert act_cell_num == int(expected_cell_num), "act_cell_num:{}!=expected_cell_num:{}".format(
            act_cell_num, expected_cell_num)


def get_peak_tput_all_cells(tput_file, list_cell, nr_cell_id_mapping):
    """
    Author: Wang Yixiang
    :param tput_file: file_paths on cluster returned from start_tput_log_capturing
                      Format like bellow: /XXX/XXX/Tput_UL_L2LO_20191126110505.txt
    :param list_cell: [1,2,3,4,5]
    :param nr_cell_id_mapping:
    Example:        {cell_index1:
                         {cell_group_id:'0', nrCellIdentity: nrCellIdentity1, physicalCellId: physicalCellId1},
                    cell_index2:
                         {cell_group_id:'0', nrCellIdentity: nrCellIdentity2, physicalCellId: physicalCellId2}}

                    {1: {b'cell_group_id': 0, b'nrCellIdentity': 16385, b'physicalCellId': 71},
                     2: {b'cell_group_id': 0, b'nrCellIdentity': 16386, b'physicalCellId': 72}}
    :return:tput of all cells
    """
    sum = 0.0
    direction = check_tput.get_direction_by_file_name(tput_file=tput_file)
    dict_tput_for_cells = check_tput.get_tput_info_for_l2lo(tput_file=tput_file, direction=direction)
    for cell in list_cell:
        cell = int(cell)
        nrCellIdentity = nr_cell_id_mapping[cell]['nrCellIdentity']
        if dict_tput_for_cells.get(nrCellIdentity, None) is None:
            raise Exception("No throughput of cell id:{} in journal or aasyslog log".format(cell))
        sum = sum + dict_tput_for_cells[nrCellIdentity]['average_tput']

    return sum


def get_details_of_peak_tput_all_cells(tput_file, list_cell, nr_cell_id_mapping):
    """
    Author: Ren Biyao
    This keyword is to get details of peak tput, such as, average of peak tput, all tput info
    :param tput_file: file_paths on cluster returned from start_tput_log_capturing
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
    avg_peak_tput = 0.0
    detail_peak_tput_info = {}
    list_detail_tput_info_number = []
    for cell in list_cell:
        cell = int(cell)
        nrCellIdentity = nr_cell_id_mapping[cell]['nrCellIdentity']
        avg_peak_tput = avg_peak_tput + dict_tput_for_cells[int(nrCellIdentity)]['average_tput']
        list_detail_tput_info_number.append(len(dict_tput_for_cells[int(nrCellIdentity)]['detail_tput_info']))
        detail_peak_tput_info[int(nrCellIdentity)] = dict_tput_for_cells[int(nrCellIdentity)]['detail_tput_info']
    useful_detail_tput_info_number = min(list_detail_tput_info_number)
    detail_peak_tput_info_sum = [0]*useful_detail_tput_info_number
    for cell in list_cell:
        cell = int(cell)
        nrCellIdentity = nr_cell_id_mapping[cell]['nrCellIdentity']
        list_detail_peak_tput_info = detail_peak_tput_info[int(nrCellIdentity)]
        detail_peak_tput_info_sum = [detail_peak_tput_info_sum[i] + list_detail_peak_tput_info[i]
                                     for i in range(0, useful_detail_tput_info_number)]
    max_peak_tput = max(detail_peak_tput_info_sum)
    min_peak_tput = min(detail_peak_tput_info_sum)
    return (avg_peak_tput, max_peak_tput, min_peak_tput, detail_peak_tput_info)


def get_details_of_tput_all_cells(tput_file, list_cell, nr_cell_id_mapping):
    """
    Author: Wang Yixiang
    This keyword is to get details of peak tput, such as, average of peak tput, all tput info
    :param tput_file: file_paths on cluster returned from start_tput_log_capturing
                      Format like bellow: /XXX/XXX/Tput_UL_L2LO_20191126110505.txt
    :param list_cell: [1,2,3,4,5]
    :param nr_cell_id_mapping:
    :return:
    {'dl_tput_peak_all_cells_min': 89.566,
          '1': {'dl_avg_tput': 103.04780000000001,
              'dl_tput_details': [116.451, 120.412, 115.662, 109.714, 82.356, 103.911, 89.314, 114.29, 97.102,
                                 109.153, 108.14, 86.631, 90.829, 85.114, 116.638],
              'dl_max_tput': 120.412},
          '2': {'dl_avg_tput': 103.04780000000001,
              'dl_tput_details': [116.451, 120.412, 115.662, 109.714, 82.356, 103.911, 89.314, 114.29, 97.102,
                                  109.153, 108.14, 86.631, 90.829, 85.114, 116.638],
              'dl_max_tput': 120.412},
      'dl_tput_peak_all_cells_avg': 128.305,
      'dl_tput_peak_all_cells_max': 216.094}

    avg_peak_tput: average peak tput in given period
            max_peak_tput: the max value of peak tput in given period
            min_peak_tput: the min value of peak tput in given period
            detail_peak_tput_info: the peak tput for every moment
            Note: the return value must be in order.
    """
    direction = check_tput.get_direction_by_file_name(tput_file=tput_file)
    dict_tput_for_cells = check_tput.get_tput_info_for_l2lo(tput_file=tput_file, direction=direction)

    dict_tput_for_cells_refactor = {}
    avg_peak_tput = 0.0
    detail_peak_tput_info = {}
    list_detail_tput_info_number = []
    for cell in list_cell:
        cell = int(cell)
        nrCellIdentity = nr_cell_id_mapping[cell]['nrCellIdentity']
        avg_peak_tput = avg_peak_tput + dict_tput_for_cells[int(nrCellIdentity)]['average_tput']
        list_detail_tput_info_number.append(len(dict_tput_for_cells[int(nrCellIdentity)]['detail_tput_info']))
        detail_peak_tput_info[int(nrCellIdentity)] = dict_tput_for_cells[int(nrCellIdentity)]['detail_tput_info']
    useful_detail_tput_info_number = min(list_detail_tput_info_number)
    detail_peak_tput_info_sum = [0]*useful_detail_tput_info_number
    for cell in list_cell:
        cell = int(cell)
        nrCellIdentity = nr_cell_id_mapping[cell]['nrCellIdentity']
        list_detail_peak_tput_info = detail_peak_tput_info[int(nrCellIdentity)]
        detail_peak_tput_info_sum = [detail_peak_tput_info_sum[i] + list_detail_peak_tput_info[i]
                                     for i in range(0, useful_detail_tput_info_number)]
    max_peak_tput = max(detail_peak_tput_info_sum)
    min_peak_tput = min(detail_peak_tput_info_sum)

    for cell in list_cell:
        dict_tput_for_one_cell = {}
        cell = int(cell)
        if cell not in nr_cell_id_mapping.keys():
            raise Exception("cell id not exist in cell_mapping, please check")
        nr_cell_identity = nr_cell_id_mapping[int(cell)]['nrCellIdentity']

        cell_tput_list = dict_tput_for_cells[nr_cell_identity]['detail_tput_info']
        avg_tput = dict_tput_for_cells[nr_cell_identity]['average_tput']
        max_tput = max(cell_tput_list)
        min_tput = min(cell_tput_list)
        dict_tput_for_one_cell['%s_avg_tput' % direction] = avg_tput
        dict_tput_for_one_cell['%s_max_tput' % direction] = max_tput
        dict_tput_for_one_cell['%s_min_tput' % direction] = min_tput
        dict_tput_for_one_cell['%s_tput_details' % direction] = cell_tput_list
        dict_tput_for_cells_refactor[str(cell)] = dict_tput_for_one_cell

    dict_tput_for_cells_refactor['%s_tput_peak_all_cells_avg' % direction] = avg_peak_tput
    dict_tput_for_cells_refactor['%s_tput_peak_all_cells_max' % direction] = max_peak_tput
    dict_tput_for_cells_refactor['%s_tput_peak_all_cells_min' % direction] = min_peak_tput

    return dict_tput_for_cells_refactor


def combine_dictionary_py(dict1, dict2, sub_dict_key_list):
    """
    Author: Wang Yixiang
    combine two dictionary together
    d1 = {"a": 1, "b": {"b1": 1}, "c": {"c1": 1}}
    d2 = {"a": 1, "b": {"b2": 2}}
    combine_dictionary_py(d1, d2, ["b","c"])
    return:
    {'a': 1, 'c': {'c1': 1}, 'b': {'b1': 1, 'b2': 2}}
    """
    combine_dict = {}

    for sub_dict_key in sub_dict_key_list:
        sub_dict = {}
        if sub_dict_key in dict1.keys():
            sub_dict.update(dict1[sub_dict_key])
        if sub_dict_key in dict2.keys():
            sub_dict.update(dict2[sub_dict_key])
        combine_dict.update(dict1)
        combine_dict.update(dict2)
        combine_dict[sub_dict_key].update(sub_dict)
    return combine_dict


# if __name__ == '__main__':
#     d1 = {"a": 1, "b": {"b1": 1}, "c": {"c1": 1}}
#     d2 = {"a": 1, "b": {"b2": 2}}
#     print combine_dictionary_py(d1, d2, ["b","c"])
#     tput_file = 'Tput_DL_L2LO_20210318095500.txt'
#     list_cell = ['1', '2']
#     nr_cell_id_mapping = {1: {b'cell_group_id': 0, b'nrCellIdentity': 9025, b'physicalCellId': 252},
#                           2: {b'cell_group_id': 1, b'nrCellIdentity': 9026, b'physicalCellId': 253}}
#     print get_details_of_tput_all_cells(tput_file, list_cell, nr_cell_id_mapping)
