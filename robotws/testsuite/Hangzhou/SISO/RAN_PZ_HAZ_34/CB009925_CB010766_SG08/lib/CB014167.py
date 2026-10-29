# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: qingjun quan
:contact: qingjun.quan@nokia-sbell.com
"""
from datetime import datetime
import xml.etree.ElementTree as ET


def get_reset_result_content_from_file(file):
    with open(file, "r", newline="", encoding="utf-8") as f:
        result = f.read()
        get_BBOX5_content = result.split("---")
        #        print(get_BBOX5_content)
        for item in get_BBOX5_content:
            if "Item type: resets" in item:
                reset_str = item.replace("\n", ",").strip(",").replace("+00:00", "")
                print(reset_str)
                reset_list = reset_str.split(",")
                post_dict_content = {
                    kv.split(":")[0]: kv.split(": ")[1] for kv in reset_list
                }
        reset_reason_item_number = sum(["Reason" in key for key in post_dict_content])
        reset_ISTI_item_number = sum(["ISTI" in key for key in post_dict_content])
        # print(reset_reason_item_number)
        # print(reset_ISTI_item_number)
        # print(post_dict_content)
        return reset_reason_item_number, reset_ISTI_item_number, post_dict_content


def get_ISTI_and_timestamp_count_from_file(file):
    resets_list = [f"Reset[{t}] ISTI" for t in range(1)]
    post_list = [f"POST[{t}] ISTI" for t in range(1)]
    with open(file, "r", newline="", encoding="utf-8") as f:
        Time_ISTI_check_list = []
        lines = f.readlines()
        lines_number = len(lines)
        for i in range(lines_number):
            line_content = lines[i].strip()
            if "Last save ISTI:" in line_content:
                ISTI_value = float(line_content.split(":")[1])
                if ISTI_value > 0:
                    ISTI_status = True
                else:
                    ISTI_status = False
                    print(f"{i+1}th row {line_content} is wrong")
                Time_ISTI_check_list.append(ISTI_status)
            if "] write ISTI:" in line_content:
                ISTI_value = float(line_content.split(":")[1])
                if ISTI_value > 0:
                    ISTI_status = True
                else:
                    ISTI_status = False
                    print(f"{i+1}th row {line_content} is wrong")
                Time_ISTI_check_list.append(ISTI_status)
            if "Last write ISTI:" in line_content:
                if lines[i - 2].strip().split(": ")[0] == "Last write":
                    time_value = datetime.strptime(
                        lines[i - 2].strip().split(": ")[1], "%Y-%m-%dT%H:%M:%S%z"
                    )
                    compare_start_time = datetime.strptime(
                        "2025-05-21T00:00:00+00:00", "%Y-%m-%dT%H:%M:%S%z"
                    )
                    if time_value > compare_start_time:
                        ISTI_value = float(line_content.split(":")[1])
                        if ISTI_value > 0:
                            ISTI_status = True
                        else:
                            ISTI_status = False
                            print(f"{i+1}th row {line_content} is wrong")
                        Time_ISTI_check_list.append(ISTI_status)
            if "Last write ISTI:" in line_content:
                if lines[i - 1].strip().split(": ")[0] == "Last write":
                    if lines[i - 1].strip().split(": ")[0] == "Last write":
                        time_value = datetime.strptime(
                            lines[i - 1].strip().split(": ")[1], "%Y-%m-%dT%H:%M:%S%z"
                        )
                    compare_start_time = datetime.strptime(
                        "2025-05-21T00:00:00+00:00", "%Y-%m-%dT%H:%M:%S%z"
                    )
                    if time_value > compare_start_time:
                        ISTI_value = float(line_content.split(":")[1])
                        if ISTI_value > 0:
                            ISTI_status = True
                        else:
                            ISTI_status = False
                            print(f"{i+1}th row {line_content} is wrong")
                        Time_ISTI_check_list.append(ISTI_status)
            if "] ISTI time:" in line_content:
                if "] write" in lines[i - 1].strip().split(": ")[0]:
                    time_value = datetime.strptime(
                        lines[i - 1].strip().split(": ")[1], "%Y-%m-%dT%H:%M:%S%z"
                    )
                    compare_start_time = datetime.strptime(
                        "2025-05-21T00:00:00+00:00", "%Y-%m-%dT%H:%M:%S%z"
                    )
                    if time_value > compare_start_time:
                        ISTI_value = float(line_content.split(":")[1])
                        if ISTI_value > 0:
                            ISTI_status = True
                        else:
                            ISTI_status = False
                            print(f"{i+1}th row {line_content} is wrong")
                        Time_ISTI_check_list.append(ISTI_status)
            if "Item type: Isti" in line_content:
                ISTI_value = float(lines[i + 2].strip().split(":")[1])
                if ISTI_value > 0:
                    ISTI_status = True
                else:
                    ISTI_status = False
                    print(f"{i+1}th row {line_content} is wrong")
                Time_ISTI_check_list.append(ISTI_status)
            if "] ISTI:" in line_content:
                reset_post_number = line_content.split(":")[0]
                if reset_post_number in resets_list:
                    ISTI_value = float(line_content.split(":")[1])
                    if ISTI_value > 0:
                        ISTI_status = True
                    else:
                        ISTI_status = False
                        print(f"{i+1}th row {line_content} is wrong")
                    Time_ISTI_check_list.append(ISTI_status)
                if reset_post_number in post_list:
                    ISTI_value = float(line_content.split(":")[1])
                    if ISTI_value > 0:
                        ISTI_status = True
                    else:
                        ISTI_status = False
                        print(f"{i+1}th row {line_content} is wrong")
                    Time_ISTI_check_list.append(ISTI_status)
        if False in Time_ISTI_check_list:
            Time_ISTI_check_result = False
        else:
            Time_ISTI_check_result = True
        return Time_ISTI_check_result


def get_all_sfp_info_from_BBOX5(file, sfp_name_list):
    with open(file, "r", newline="", encoding="utf-8") as f:
        result = f.read()
        sfp_data_check = []
        get_BBOX5_content = result.split("---")
        #        print(get_BBOX5_content)
        all_sfps_info_list_BBOX5 = []
        all_sfps_info_list_sort_BBOX5 = []
        for item in get_BBOX5_content:
            if "Item type: SFP_info" in item:
                # print(item)
                sfp_str = item.strip("\n").replace("\n", "<>")
                # print(sfp_str)
                sfp_list = sfp_str.split("<>")[:18]
                # print(sfp_list)
                sfp_dict_content = {
                    kv.split(": ")[0]: kv.split(": ")[1] for kv in sfp_list
                }
                if sfp_dict_content["Item id"] in sfp_name_list:
                    all_sfps_info_list_BBOX5.append(sfp_dict_content)
        sfp_num_bbox5 = len(all_sfps_info_list_BBOX5)
        sfp_num_coam = len(sfp_name_list)
        for i in range(sfp_num_coam):
            for j in range(sfp_num_bbox5):
                if sfp_name_list[i] == all_sfps_info_list_BBOX5[j]["Item id"]:
                    all_sfps_info_list_sort_BBOX5.append(all_sfps_info_list_BBOX5[j])
        for i in range(sfp_num_coam):
            if "SFP_info[1] write" in all_sfps_info_list_sort_BBOX5[i]:
                print(all_sfps_info_list_sort_BBOX5[i]["SFP_info[1] write"])
                if (
                    all_sfps_info_list_sort_BBOX5[i]["SFP_info[0] Vendor"]
                    == all_sfps_info_list_sort_BBOX5[i]["SFP_info[1] Vendor"]
                ):
                    sfp_data_check_result = True
                else:
                    sfp_data_check_result = False
                    print(
                        f"{all_sfps_info_list_sort_BBOX5[i]['Item id']} Vendor of \
                        SFP_info[0] and SFP_info[1] is different"
                    )
                sfp_data_check.append(sfp_data_check_result)
                if (
                    all_sfps_info_list_sort_BBOX5[i]["SFP_info[0] Part no"]
                    == all_sfps_info_list_sort_BBOX5[i]["SFP_info[1] Part no"]
                ):
                    sfp_data_check_result = True
                else:
                    sfp_data_check_result = False
                    print(
                        f"{all_sfps_info_list_sort_BBOX5[i]['Item id']} Part no of \
                        SFP_info[0] and SFP_info[1] is different"
                    )
                sfp_data_check.append(sfp_data_check_result)
                if (
                    all_sfps_info_list_sort_BBOX5[i]["SFP_info[0] SN"]
                    == all_sfps_info_list_sort_BBOX5[i]["SFP_info[1] SN"]
                ):
                    sfp_data_check_result = True
                else:
                    sfp_data_check_result = False
                    print(
                        f"{all_sfps_info_list_sort_BBOX5[i]['Item id']} SN of \
                        SFP_info[0] and SFP_info[1] is different"
                    )
                sfp_data_check.append(sfp_data_check_result)
                if (
                    all_sfps_info_list_sort_BBOX5[i]["SFP_info[0] Speed"]
                    == all_sfps_info_list_sort_BBOX5[i]["SFP_info[1] Speed"]
                ):
                    sfp_data_check_result = True
                else:
                    sfp_data_check_result = False
                    print(
                        f"{all_sfps_info_list_sort_BBOX5[i]['Item id']} Speed of \
                        SFP_info[0] and SFP_info[1] is different"
                    )
                sfp_data_check.append(sfp_data_check_result)
                if (
                    all_sfps_info_list_sort_BBOX5[i]["SFP_info[0] Registers"]
                    == all_sfps_info_list_sort_BBOX5[i]["SFP_info[1] Registers"]
                ):
                    sfp_data_check_result = True
                else:
                    sfp_data_check_result = False
                    print(
                        f"{all_sfps_info_list_sort_BBOX5[i]['Item id']} Registers of \
                        SFP_info[0] and SFP_info[1] is different"
                    )
                sfp_data_check.append(sfp_data_check_result)
        print(sfp_data_check)
        if False in sfp_data_check:
            sfp_check_result = True
        else:
            sfp_check_result = False
        print(sfp_check_result)
        return all_sfps_info_list_sort_BBOX5, sfp_check_result


def get_all_carriers_info_from_BBOX5(file):
    with open(file, "r", newline="", encoding="utf-8") as f:
        tx_carrier_array_list_BBOX5 = []
        rx_carrier_array_list_BBOX5 = []
        result = f.read()
        get_BBOX5_content = result.split("---")
        rx_carrier_dict_content_BBOX5 = {}
        tx_carrier_dict_content_BBOX5 = {}
        for item in get_BBOX5_content:
            if "Item type: carriers" in item:
                if "Item id: RX" in item:
                    carrier_str = item.strip("\n").replace("\n", "<>")
                    carrier_list = carrier_str.split("<>")
                    for kv in carrier_list:
                        rx_carrier_dict_content_BBOX5[kv.split(": ")[0]] = kv.split(
                            ": "
                        )[1]
                        if "antenna" in kv:
                            rx_carrier_array_list_BBOX5.append(kv.split(": ")[1])
                if "Item id: TX" in item:
                    carrier_str = item.strip("\n").replace("\n", "<>")
                    carrier_list = carrier_str.split("<>")
                    for kv in carrier_list:
                        tx_carrier_dict_content_BBOX5[kv.split(": ")[0]] = kv.split(
                            ": "
                        )[1]
                        if "antenna" in kv:
                            tx_carrier_array_list_BBOX5.append(kv.split(": ")[1])
        # print(tx_carrier_dict_content_BBOX5)
        # print(rx_carrier_dict_content_BBOX5)
        return (
            tx_carrier_array_list_BBOX5,
            tx_carrier_dict_content_BBOX5,
            rx_carrier_array_list_BBOX5,
            rx_carrier_dict_content_BBOX5,
        )


def soap_carriers_index_align_with_BBOX5(
    tx_carriers_list, tx_array, rx_carriers_list, rx_arrary
):
    tx_array_len = len(tx_array)
    tx_carriers_list_len = len(tx_carriers_list)
    rx_arrary_len = len(rx_arrary)
    rx_carriers_list_len = len(rx_carriers_list)
    tx_carriers_align_BBOX5 = []
    rx_carriers_align_BBOX5 = []
    for i in range(tx_array_len):
        for j in range(tx_carriers_list_len):
            if tx_array[i] == tx_carriers_list[j]["array"]:
                tx_carriers_align_BBOX5.append(tx_carriers_list[j])
    for i in range(rx_arrary_len):
        for j in range(rx_carriers_list_len):
            if rx_arrary[i] == rx_carriers_list[j]["array"]:
                rx_carriers_align_BBOX5.append(rx_carriers_list[j])
    print(tx_carriers_align_BBOX5)
    print(rx_carriers_align_BBOX5)
    return tx_carriers_align_BBOX5, rx_carriers_align_BBOX5
