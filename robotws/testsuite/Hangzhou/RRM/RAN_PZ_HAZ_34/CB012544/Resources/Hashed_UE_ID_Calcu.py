# -*- coding:utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jun
:contact: jun.8.chen@nokia-sbell.com
:maintainer: Chen Jun
:contact: jun.8.chen@nokia-sbell.com
"""
import math

Y1_hex = 0xC704DD7B
Denominator = 0x104C11DB7
all_1_dec = 4294967295
TeDRX_CN_mapping = {
    "0": 0.25,
    "1": 0.5,
    "2": 1,
    "3": 2
}
Time_Window_mapping = {
    "0": 1.28,
    "1": 2.56,
    "2": 3.84,
    "3": 5.12,
    "4": 6.4,
    "5": 7.68,
    "6": 8.96,
    "7": 10.24,
    "8": 11.52,
    "9": 12.8,
    "10": 14.08,
    "11": 15.36,
    "12": 16.64,
    "13": 17.92,
    "14": 19.0,
    "15": 20.48,
    "16": 21.76,
    "17": 23.04,
    "18": 24.32,
    "19": 25.6,
    "20": 26.88,
    "21": 28.16,
    "22": 29.44,
    "23": 30.72,
    "24": 32,
    "25": 33.28,
    "26": 34.56,
    "27": 35.84,
    "28": 37.12,
    "29": 38.4,
    "30": 39.68,
    "31": 40.96
}
eDRX_mapping = {
    "0": 2.56,
    "1": 5.12,
    "2": 10.24,
    "3": 20.48,
    "4": 40.96,
    "5": 81.92,
    "6": 163.84,
    "7": 327.68,
    "8": 655.36,
    "9": 1310.72,
    "10": 2621.44,
    "11": 5242.88,
    "12": 10485.76
}


def calcu_value_of_hashed_id(tmsi):
    """
    :param: tmsi.
    :return: hashed_id
    """
    num = 32
    i = 1
    tmsi = int(tmsi)
    for x in range(1, 33):
        tmsi = tmsi << i
        tmsi = tmsi ^ Denominator
        Y2_bin = bin(tmsi)[2:]
        num = num - i
        if num == 0:
            break
        length = len(Y2_bin)
        i = 33 - length
        if i > num and num > 0:
            tmsi = tmsi << num
            Y2_bin = bin(tmsi)[2:]
            break

    Y2_bin_length = len(Y2_bin)
    right_move_length = 32 - Y2_bin_length
    for x in range(0, right_move_length):
        Y2_bin = str(0) + str(Y2_bin)
    Y2_dec = int(str(Y2_bin), 2)

    Y1Y2_hex = Y2_dec ^ Y1_hex

    result = Y1Y2_hex ^ all_1_dec
    result = bin(result)[2:]

    result_length = len(result)
    right_move_length = 32 - result_length
    for x in range(0, right_move_length):
        result = str(0) + str(result)

    result = result[:13]
    result_dec = int(str(result), 2)
    return result_dec


def get_sfn_num(Hashed_ID, eDRX_Cycle, Time_Window):
    """
    :param: Hashed_ID.
    :return: sfn, len, end, TeDRX_CN
    """
    TeDRX_CN = TeDRX_CN_mapping[eDRX_Cycle]
    ieDRX_CN_tmp = math.floor(int(Hashed_ID) / int(TeDRX_CN))
    ieDRX_CN = math.fmod(ieDRX_CN_tmp, 8)
    sfn = 128 * ieDRX_CN
    sfn = int(sfn)
    length_tmp = Time_Window_mapping[Time_Window]
    length = 100 * length_tmp
    length = int(length)
    end = math.fmod((int(sfn) + int(length) - 1), 1024)
    end = int(end)
    return TeDRX_CN, sfn, length, end


def get_ueid_tConfigToUse_for_idle(sTMSI, nR_paging_eDRX_Cycle_value, PagingDRX_value, drxDefaultPaging_value):
    """
    :param: sTMSI.
    :return: ueid, tConfigToUse
    """
    ueid = math.fmod(int(sTMSI), 4096)
    ueid = int(ueid)
    nR_paging_eDRX_Cycle_value = int(nR_paging_eDRX_Cycle_value)
    if nR_paging_eDRX_Cycle_value >= 3:
        if PagingDRX_value == 0:
            tConfigToUse = int(drxDefaultPaging_value)
        else:
            tConfigToUse = min(int(PagingDRX_value), int(drxDefaultPaging_value))
    elif nR_paging_eDRX_Cycle_value <= 2:
        eDRX = eDRX_mapping[nR_paging_eDRX_Cycle_value]
        tConfigToUse = int(eDRX) * 100
    else:
        raise Exception("nR_paging_eDRX_Cycle_value {} is not avaiable".format(nR_paging_eDRX_Cycle_value))
    return ueid, tConfigToUse


def get_ueid_tConfigToUse_for_inactive(sTMSI, nR_paging_eDRX_Cycle_value, eDrx_RAN,
                                       eDRX_Cycle_number, drxDefaultPaging_value):
    """
    :param: sTMSI.
    :return: ueid, tConfigToUse
    """
    ueid = math.fmod(int(sTMSI), 4096)
    ueid = int(ueid)
    nR_paging_eDRX_Cycle_value = int(nR_paging_eDRX_Cycle_value)
    if nR_paging_eDRX_Cycle_value >= 3:
        tConfigToUse = min(int(eDrx_RAN), int(drxDefaultPaging_value))
        OutPTW_tConfigToUse = int(eDrx_RAN)
    elif nR_paging_eDRX_Cycle_value <= 2:
        tConfigToUse = min(int(eDrx_RAN), int(eDRX_Cycle_number))
    else:
        raise Exception("nR_paging_eDRX_Cycle_value {} is not avaiable".format(nR_paging_eDRX_Cycle_value))
    return ueid, tConfigToUse, OutPTW_tConfigToUse
