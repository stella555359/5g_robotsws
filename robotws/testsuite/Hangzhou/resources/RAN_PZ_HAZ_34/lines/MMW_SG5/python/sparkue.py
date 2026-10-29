# -*- coding: utf-8 -*
from robot.libraries.BuiltIn import BuiltIn
import logging
import csv


def Change_DL_TP(ue_config, dl_list, ue_list):
    counter = len(ue_list)
    print(counter)
    for i in range(len(ue_list)):
        ue_config['MultiUECFG'][ue_list[i]]['dl']['target_throughput'] = str(dl_list[i]) + 'MKbits/sec'
    print(ue_config)
    return ue_config


def Change_UL_TP(ue_config, ul_list, ue_list):
    counter = len(ue_list)
    print(counter)
    for i in range(len(ue_list)):
        ue_config['MultiUECFG'][ue_list[i]]['ul']['target_throughput'] = str(ul_list[i]) + 'MKbits/sec'
    print(ue_config)
    return ue_config


def Change_ue_index_for_call(ue_config, ue_ids):
    ue_config['MultiUECFG']['ue_index_for_call'] = ue_ids
    print(ue_config)
    return ue_config


def Check_Mulite_UE_TP_And_Bler(if_ul, if_dl, actual_value, expect_ul_bler, expect_dl_bler,
                                expect_ul_tp, expect_dl_tp):
    ue_id = 0
    ul_ue_count = 0
    dl_ue_count = 0
    for single_ue_actual_value in actual_value:
        ue_id = ue_id + 1
        dl_bler = single_ue_actual_value['DL_bler'][0]
        ul_bler = single_ue_actual_value['UL_bler'][0]
        dl_tp = single_ue_actual_value['DL_tp'][0]
        ul_tp = single_ue_actual_value['UL_tp'][0]
        if if_ul:
            logging.info("UE-{} UL TP {}Mbits/sec".format(ue_id, ul_tp))
        if if_ul and ul_tp > 1:
            ul_ue_count = ul_ue_count + 1
            if ul_bler > expect_ul_bler:
                logging.info("UE-{} UL bler {} is more than expect value {}".format(ue_id, ul_bler, expect_ul_bler))
                return False
            if ul_tp < expect_ul_tp:
                logging.info("UE-{} UL TP {} is less than expect value {}".format(ue_id, ul_tp, expect_ul_tp))
                return False
        if if_dl:
            logging.info("UE-{} DL TP {}Mbits/sec".format(ue_id, dl_tp))
        if if_dl and dl_tp > 1:
            dl_ue_count = dl_ue_count + 1
            if dl_bler > expect_dl_bler:
                logging.info("UE-{} DL bler {} is more than expect value {}".format(ue_id, dl_bler, expect_dl_bler))
                return False
            if dl_tp < expect_dl_tp:
                logging.info("UE-{} DL TP {} is less than expect value {}".format(ue_id, dl_tp, expect_dl_tp))
                return False
    if if_ul:
        print("ul ue count is {}", ul_ue_count)
        if ul_ue_count < 1:
            logging.info("All UE has no UL tp")
            return False
    if if_dl:
        print("dl ue count is {}", dl_ue_count)
        if dl_ue_count < 1:
            logging.info("All UE has no DL tp")
            return False
    return True


def Calculate_average_max_min(input_list, list_length):
    sum_value = 0
    convert_list_tmp = [float(i) for i in input_list if i != '']
    if len(convert_list_tmp) == 0:
        convert_list = [0]
    else:
        convert_list = list(reversed(convert_list_tmp))[0:list_length]
    for j in convert_list:
        sum_value = sum_value + float(j)
    average_value = sum_value/len(convert_list)
    max_vlaue = max(convert_list)
    min_value = min(convert_list)
    value_list = [average_value, max_vlaue, min_value, len(convert_list)]
    return value_list


def Get_UE_TP_Bler_From_spark_log(file_path, list_length, row_list):
    DL_tp = []
    UL_tp = []
    DL_bler = []
    UL_bler = []
    with open(file_path, 'r', encoding='gbk') as csvfile:
        data = csv.DictReader(csvfile)
        for row in data:
            DL_tp.append(row[row_list[0]])
            UL_tp.append(row[row_list[1]])
            DL_bler.append(row[row_list[2]])
            UL_bler.append(row[row_list[3]])
    message_dict = {
        'DL_tp': Calculate_average_max_min(DL_tp, list_length),
        'UL_tp': Calculate_average_max_min(UL_tp, list_length),
        'DL_bler': Calculate_average_max_min(DL_bler, list_length),
        'UL_bler': Calculate_average_max_min(UL_bler, list_length)}
    return message_dict


def get_ue_infor_from_ipconfig(ipconfig_output_path):
    with open(ipconfig_output_path, "r", encoding="GBK") as fr:
        ipconfig_lines = fr.readlines()
    ue_ips = {}
    ue_name = ""
    ue_ip = ""
    old_list = []
    for ipconfig_line in ipconfig_lines:
        if "UE0" in ipconfig_line:
            # spilt to UE01..UE02
            ue_name = ipconfig_line[-6:-2]
            ue_ip = ""
            old_list.append(ue_name)
            print(old_list)
        elif "UE" in ipconfig_line:
            # spilt to UE1..UE2
            ue_name = ipconfig_line[-5:-2]
            ue_ip = ""
            old_list.append(ue_name)
            print(old_list)
        if "IPv4" in ipconfig_line and ue_name != "":
            ue_ip = ipconfig_line.split(": ")[1][:-1]
            print(ue_ip)
            print(ue_name)
        if ue_name != "" and ue_ip.startswith("10.108.251"):
            ue_ips[ue_name] = ue_ip
            while ue_name in old_list:
                old_list.remove(ue_name)
    print(old_list)
    unattach_list = list(dict.fromkeys(old_list))
    return ue_ips, unattach_list
