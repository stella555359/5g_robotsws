# Created by shuihe
# Maintianed by shuihe
import csv
import math
import ast
import decimal
from decimal import Decimal


def decimal_to_bitmap(decimal_value):
    bitmap = bin(decimal_value)[2:]  # 去除前缀'0b'并保存到变量binary中
    if len(bitmap) < 18:
        # if bit num is less than 18, add "0" at the left bits to make bit num 18
        bitmap = '0'*(18 - len(bitmap))+bitmap
    return bitmap


def get_free_rbg_num(bitmap_list01):
    free_rbg_num01 = 0
    for i in range(17):  # free rbg  does not include the last poor RBG
        mu_ue_num = 0
        for j in range(len(bitmap_list01)):
            if list(bitmap_list01[j])[i] == '0':
                mu_ue_num += 1
        if mu_ue_num == len(bitmap_list01):
            free_rbg_num01 += 1
    return free_rbg_num01


def cal_power_offset(bitmap_list02, occupied_rbg_num02_65535, free_rbg_num02):
    total_rbg_num = 0
    mu_rgb_num = 0
    # power_offset_9235 = 0
    # power_offset_legacy = 0
    # print(bitmap_list02)
    # print(occupied_rbg_num02_65535)
    # print(free_rbg_num02)
    for i in range(18):
        mu_ue_num = 0
        for j in range(len(bitmap_list02)):
            if list(bitmap_list02[j])[i] == '1':  # list(bitmap_list[j]) is used to transform string into list
                total_rbg_num += 1
                mu_ue_num += 1
        if mu_ue_num > 0:
            mu_rgb_num += 1
    # print(total_rbg_num, mu_rgb_num)
    # print(mu_rgb_num/total_rbg_num)
    # print(math.log(mu_rgb_num/total_rbg_num, 10))
    a = math.log((mu_rgb_num - occupied_rbg_num02_65535 + free_rbg_num02)/total_rbg_num, 10)
    b = math.log(mu_rgb_num/total_rbg_num, 10)
    # power_offset_9235 = min(1, int(round(math.log((mu_rgb_num - occupied_rbg_num02_65535 +
    #                                                free_rbg_num02)/total_rbg_num, 10), 2)*100))
    # power_offset_legacy = min(1, int(round(math.log(mu_rgb_num/total_rbg_num, 10),
    #                                        2)*100))
    # print(a, '%'*10)
    # print(b, '%'*10)
    # print(int(round(a, 2)*100))
    # print(int(round(Decimal(a), 2)*100))
    # print(int(round(math.log(mu_rgb_num/total_rbg_num, 10), 2)*100))
    power_offset_9235 = min(0, int(round(Decimal(a), 2)*100))
    power_offset_legacy = int(round(Decimal(b), 2)*100)
    return power_offset_9235, power_offset_legacy, total_rbg_num, mu_rgb_num


def cal_65535_rbg(csv_filename):
    with open(csv_filename) as csvfile:
        # csv.DictReader(csvfile): read csv as a list of dict
        list_reader = list(csv.DictReader(csvfile))
        occupied_rbg_num = 0
        for i_row in list_reader:
            if i_row['rnti'] == '65535':
                st_prb_65535 = int(i_row['dlPagingOrSibSchedData.startPrb'])
                prb_num_65535 = int(i_row['dlPagingOrSibSchedData.numOfPrb'])
                occupied_rbg_num = math.ceil((((st_prb_65535 % 16) + prb_num_65535) / 16))
        return occupied_rbg_num


def check_power_boosting(csv_filename):
    # global bitmap_list, occupied_rbg_num_65535, free_rbg_num
    # occupied_rbg_num_65535 = 0
    # free_rbg_num = 0
    # bitmap_list = []
    # power_offset_tti = 0
    pass_num = 0
    failure_num = 0
    with open(csv_filename) as csvfile:
        # csv.DictReader(csvfile): read csv as a list of dict
        list_reader = list(csv.DictReader(csvfile))
        init_mu_slot = 0
        st_check_index = 1
        end_check_index = 0
        a = 0
        b = 0
        # check_num = 0
        for i in range(st_check_index, len(list_reader)):
            check_num = i
            for i_row in list_reader[st_check_index - 1:]:
                # if i_row['dlFdSchedData.muStatus'] == 'MUPAIR':
                if i_row['dlFdSchedData.rat0Bitmap']:
                    init_mu_slot = i_row['slot']
                    st_check_index = list_reader.index(i_row)
                    # print('start:', st_check_index)
                    a += 1
                    break
            for i_row in list_reader[st_check_index:]:
                # print(i_row['dlFdSchedData.muStatus'])
                # print(i_row['slot'])
                # print(init_mu_slot)
                if i_row['slot'] != init_mu_slot:
                    end_check_index = list_reader.index(i_row)
                    # print('end:', end_check_index)
                    b += 1
                    break
            bitmap_list = []
            bitmap_list_including_nonmu = []
            occupied_rbg_num_65535 = 0
            free_rbg_num = 0
            power_offset_tti = 0
            mupair_num = 0
            for i_row in list_reader[st_check_index:end_check_index]:
                # pass
                if i_row['rnti'] == '65535':
                    # print(i_row['rnti'])
                    st_prb_65535 = int(float(i_row['dlPagingOrSibSchedData.startPrb']))
                    prb_num_65535 = int(float(i_row['dlPagingOrSibSchedData.numOfPrb']))
                    occupied_rbg_num_65535 = math.ceil(((prb_num_65535 - (16 - st_prb_65535 % 16)) / 16)) + 1
                    # print(st_prb_65535)
                    # print(prb_num_65535)
                    # print(occupied_rbg_num_65535, '*'*10)
                # calculate 65535 occupies rbg
                if i_row['dlFdSchedData.rat0Bitmap']:
                    bitmap_list_including_nonmu.append(decimal_to_bitmap
                                                       (int(float((i_row['dlFdSchedData.rat0Bitmap'])))))
                if i_row['dlFdSchedData.muStatus'] == 'MUPAIR':
                    # bin_bitmap = decimal_to_bitmap(int(float((i_row['dlFdSchedData.rat0Bitmap']))))
                    # print(i_row['dlFdSchedData.rat0Bitmap'])
                    bitmap_list.append(decimal_to_bitmap(int(float((i_row['dlFdSchedData.rat0Bitmap'])))))
                    # power_offset_tti = int(float(i_row['dlFdSchedData.muPdschPowerOffset']))
                # get bin bitmap list and power_offset_tti which is power_offset read from TTI
                free_rbg_num = get_free_rbg_num(bitmap_list_including_nonmu)
                # print('free rbg:', free_rbg_num)
                # print('65535 occupied rbg:', occupied_rbg_num_65535)
                # get free rbg number
                if i_row['dlFdSchedData.muStatus'] == 'MUPAIR':
                    mupair_num += 1
                    power_offset_tti = int(float(i_row['dlFdSchedData.muPdschPowerOffset']))
            if mupair_num > 0:
                power_offset = cal_power_offset(bitmap_list, occupied_rbg_num_65535, free_rbg_num)
                # print('power_offset_9235: ', power_offset[0])
                # print('power_offset_legacy: ', power_offset[1])
                # print('power_offset_tti: ', power_offset_tti, 'which is read from tti trace')
                if power_offset_tti == power_offset[0]:
                    pass_num += 1
                    # print('pass number:', pass_num)
                    pass
                else:
                    failure_num += 1
                    print('failure num:', failure_num)
                    print('failure_st_row:', st_check_index + 2,
                          '\nfailure_end_row:', end_check_index+1,
                          '\nbitmap_list:           ', bitmap_list,
                          '\nbitmap_list_with_nonmu:', bitmap_list_including_nonmu,
                          '\nfree_rbg:', free_rbg_num,
                          '\n65535_occupy_rbg:', occupied_rbg_num_65535,
                          '\ntotal_used_rbg:', power_offset[2],
                          '\nmu_rbg_num:', power_offset[3],
                          '\npower_offset_9235:', power_offset[0],
                          '\npower_offset_legacy:', power_offset[1],
                          '\npower_offset_tti: ', power_offset_tti, 'which is read from tti trace',
                          '\ncheck_num: ', check_num,
                          '\n', '-'*100)

                    # print('failure', '_' * 50)
                #     raise Exception('Fail')
            # print(a, b)
            if a != b:
                break
            st_check_index = end_check_index + 1
            # print(st_check_index)
    if failure_num > 1:
        raise Exception('Fail')
    else:
        print('pass_num:', pass_num,
              '\nfailure_num:', failure_num)


# list01 = ['111111100011111000', '100000000000000000', '011111100011111111', '111111100011111111']
# print(list(list01[0]))
# a = cal_power_offset(list01)
# print(a)
# check_power_boosting('target_dl.csv')
