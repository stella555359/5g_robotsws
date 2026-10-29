"""Documentation: Common python KWs"""

import collections
import os
import taf.selenium.gnb.oam.coam.classical


def Replace_line_in_file(file, search_str, replace_str):
    reading_file = open(file, "r")
    new_file_content = ""
    for line in reading_file:
        stripped_line = line.strip()
        new_line = stripped_line.replace(search_str, replace_str)
        new_file_content += new_line + "\n"

    reading_file.close()
    writing_file = open(file, "w")
    writing_file.write(new_file_content)
    writing_file.close()


def lock_SFP_QSFP_LANEs(hw_name, object_name, lane_id_list):
    url = "https://192.168.255.129/"
    coam = taf.selenium.gnb.oam.coam.classical.classical()
    user = 'Nemuadmin'
    pwd = 'nemuuser'
    coam.enable_virtual_display(width=1920, height=1280)
    coam.login(url, user, pwd, browser='Firefox')
    coam.disable_message_box()
    if coam.start_up_view_window_exists():
        coam.close_start_up_view_window()

    [lane_id_list] if isinstance(lane_id_list, str) else lane_id_list
    a_list = []

    for lane_id in lane_id_list:
        line_name = "LANE-" + lane_id
        coam.lock_lane_from_sfp(hw_name, object_name, line_name)
        concat = "value" + "-" + "lane_id"
        a_list.append(concat)
    coam.disable_virtual_display()


def unlock_SFP_QSFP_LANEs(hw_name, object_name, lane_id_list):
    url = "https://192.168.255.129/"
    coam = taf.selenium.gnb.oam.coam.classical.classical()
    user = 'Nemuadmin'
    pwd = 'nemuuser'
    coam.enable_virtual_display(width=1920, height=1280)
    coam.login(url, user, pwd, browser='Firefox')
    coam.disable_message_box()
    if coam.start_up_view_window_exists():
        coam.close_start_up_view_window()
    [lane_id_list] if isinstance(lane_id_list, str) else lane_id_list
    a_list = []
    for lane_id in lane_id_list:
        line_name = "LANE-" + lane_id
        coam.unlock_lane_from_sfp(hw_name, object_name, line_name)
        concat = "value" + "-" + "lane_id"
        a_list.append(concat)
    coam.disable_virtual_display()


def Get_List_Of_Ports_From_BTSinfo(dataList):
    if isinstance(dataList, dict):
        print("is dict")
        a_list = []
        for k1, v1 in dataList.iteritems():
            if k1 == "basebandModules":
                for dic in v1:
                    for k2, v2 in dic.iteritems():
                        if k2 == "ports":
                            for dic in v2:
                                a_list.append(dic)
    return a_list


def file_exists(file):
    return os.path.isfile(file)
