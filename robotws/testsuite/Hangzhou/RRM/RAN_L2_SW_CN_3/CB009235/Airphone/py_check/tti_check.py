# Created by shuihe
# Maintianed by shuihe
import csv
import math
import ast


def check_block_ue_list_num(csv_filename, num=11,
                            str_index='dlMuAwareTdSchInfo.corrCheckBlockUeListAfterStep1'):
    with open(csv_filename) as csvfile:
        # csv.DictReader(csvfile): read csv as a list of dict
        list_reader = list(csv.DictReader(csvfile))
        pass_num = 0
        fail_num = 0
        for i_row in list_reader:
            # print(len(i_line['ulFdSchedData.ueData.reScaledCorrAvgSinrAtb']))
            if i_row[str_index]:
                a = ast.literal_eval(i_row[str_index])
                # print(type(a))
                # print(a)
                if len(a) == num:
                    pass_num += 1
                    pass
                    # print("pass_num:", pass_num)
                else:
                    fail_num += 1
                    b = list_reader.index(i_row) + 2
                    print("error_row:", b)
        print("pass_num:", pass_num)
        print("fail_num:", fail_num)
        if fail_num > 10:  # perhaps ue block happens on several slots
            raise Exception('Fail')
        else:
            print('Pass')


def check_block_ue_list_more_than_0(csv_filename, str_index='dlMuAwareTdSchInfo.corrCheckBlockUeListAfterStep1'):
    with open(csv_filename) as csvfile:
        # csv.DictReader(csvfile): read csv as a list of dict
        list_reader = list(csv.DictReader(csvfile))
        num_list = []
        for i_row in list_reader:
            # print(len(i_line['ulFdSchedData.ueData.reScaledCorrAvgSinrAtb']))
            if i_row[str_index] != '' and i_row[str_index] != '[]':
                a = ast.literal_eval(i_row[str_index])
                # print(type(a))
                # print(a)
                num_list.append(len(a))
        print("block_ue_num_list:", num_list)
        if len(num_list) == 0:
            raise Exception('Fail')
        else:
            print('Pass')


# get_average('tti_ul.csv')
# get_average('tti_ul.csv', 'ulLaDeltaSinr.ulUsedMcs')
# get_average('tti_ul.csv', 'ulFdSchedData.numOfPrb')
# get_average('tti_ul.csv', 'ulFdSchedData.tbSize')
# get_average('tti_ul.csv', 'ulFdSchedData.reScaledCorrAvgSinrAllocPrb')
# check_not_delta_sinr_calculated('28.csv')
# check_block_ue_list_more_than_0('tti_dl013_Order.csv')
