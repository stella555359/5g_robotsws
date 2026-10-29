import csv
import os
import re
from taf.analyzer.pdml import PdmlReader
from lxml import etree as ET


def Get_packet_info(file_path, field_name):
    field_value_list = []
    with open(file_path, 'rb') as file_obj:
        for entry in PdmlReader(file_obj=file_obj):
            if field_name in entry.packet:
                value = entry.packet[field_name].show
                field_value_list.append(value)
    file_obj.close()
    return field_value_list


def Get_all_packey_Xpath_Keys(file_path):
    with open(file_path, 'rb') as file_obj:
        for entry in PdmlReader(file_obj=file_obj):
            key_list = entry.packet.keys()
            path_list = entry.packet.paths()
            num = len(entry.packet.keys())
            for i in range(0, num):
                print(key_list[i])
                print(path_list[i])
    file_obj.close()
    return key_list, path_list


def Add_Filed_name_And_value_To_dict(field_name_list, field_value_list, result_dict, get_all_value=False):
    for i in field_name_list:
        index = field_name_list.index(i)
        if get_all_value:
            if i not in result_dict.keys():
                result_dict[i] = [field_value_list[index]]
            else:
                result_dict[i].append(field_value_list[index])
        else:
            if i not in result_dict.keys():
                result_dict[i] = field_value_list[index]
    return result_dict


def Merge_Two_Dictionaries(Dictionary1, Dictionary2):
    merge_dict = {}
    if bool(Dictionary1):
        for key in Dictionary1.keys():
            merge_dict[key] = Dictionary1[key]
    if bool(Dictionary2):
        for key in Dictionary2.keys():
            merge_dict[key] = Dictionary2[key]
    return merge_dict


def Check_Dictionary_Value_As_expect(actual_dict, expect_dict):
    result_dict = {}
    for key in expect_dict.keys():
        if isinstance(actual_dict[key], list):
            if list(set(actual_dict[key])) == [(expect_dict[key])]:
                result_dict[key] = True
            else:
                result_dict[key] = False
        else:
            if actual_dict[key] == expect_dict[key]:
                result_dict[key] = True
            else:
                result_dict[key] = False
    result_value = result_dict.values()
    return result_dict, result_value


def Extract_Pdlm_Message(filename, get_all_value=False):
    field_result_dict = {}
    with open(filename, 'rb') as file_obj:
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if "DlData_PdschGrantL1sw.i1Codebook4AntPorts_item" in root:
                PdschGrantL1sw_key_list = ['i1Codebook4AntPorts_item[1]', 'i1Codebook4AntPorts_item[2]',
                                           'i1Codebook4AntPorts_item[3]']
                i1Codebook4AntPorts_0 = ((root.xpath("icom_5g//nr_l1dl_l2ps//dldata_pdschsendreql1sw//"
                                                     "nr_l1dl_l2ps_dldata_pdschsendreql1sw_t//_//"
                                                     "nr_l1dl_l2ps_dldata_pdschgrantl1sw//_[1]//"
                                                     "DlData_PdschGrantL1sw.i1Codebook4AntPorts_item[1]")[0].show))
                i1Codebook4AntPorts_1 = ((root.xpath("icom_5g//nr_l1dl_l2ps//dldata_pdschsendreql1sw//"
                                                     "nr_l1dl_l2ps_dldata_pdschsendreql1sw_t//_//"
                                                     "nr_l1dl_l2ps_dldata_pdschgrantl1sw//_[1]//"
                                                     "DlData_PdschGrantL1sw.i1Codebook4AntPorts_item[2]")[0].show))
                i1Codebook4AntPorts_2 = ((root.xpath("icom_5g//nr_l1dl_l2ps//dldata_pdschsendreql1sw//"
                                                     "nr_l1dl_l2ps_dldata_pdschsendreql1sw_t//_//"
                                                     "nr_l1dl_l2ps_dldata_pdschgrantl1sw//_[1]//"
                                                     "DlData_PdschGrantL1sw.i1Codebook4AntPorts_item[3]")[0].show))
                result = [i1Codebook4AntPorts_0, i1Codebook4AntPorts_1, i1Codebook4AntPorts_2]
                field_result_dict = Add_Filed_name_And_value_To_dict(field_name_list=PdschGrantL1sw_key_list,
                                                                     field_value_list=result,
                                                                     result_dict=field_result_dict,
                                                                     get_all_value=get_all_value)

            if "DlData_CsiRsResourceL1sw_t" in root:
                key_list = ['antennaStream', 'numCeAxCIndex', 'enhTransScheme']
                antennaStream = ((root.xpath("icom_5g//nr_l1dl_l2ps//dldata_csirssendreql1sw//"
                                             "nr_l1dl_l2ps_dldata_csirssendreql1sw_t//_//"
                                             "nr_l1dl_l2ps_dldata_csirsresourcel1sw_t[1]//"
                                             "DlData_CsiRsResourceL1sw_t.antennaStream")[0].show))
                numCeAxCIndex = ((root.xpath("icom_5g//nr_l1dl_l2ps//dldata_csirssendreql1sw//"
                                             "nr_l1dl_l2ps_dldata_csirssendreql1sw_t//_//"
                                             "nr_l1dl_l2ps_dldata_csirsresourcel1sw_t[1]"
                                             "/DlData_CsiRsResourceL1sw_t.numCeAxCIndex")[0].show))
                enhTransScheme = ((root.xpath("icom_5g//nr_l1dl_l2ps//dldata_csirssendreql1sw//"
                                              "nr_l1dl_l2ps_dldata_csirssendreql1sw_t//_//"
                                              "nr_l1dl_l2ps_dldata_csirsresourcel1sw_t[1]//"
                                              "DlData_CsiRsResourceL1sw_t.enhTransScheme")[0].show))
                result = [antennaStream, numCeAxCIndex, enhTransScheme]
                field_result_dict = Add_Filed_name_And_value_To_dict(field_name_list=key_list,
                                                                     field_value_list=result,
                                                                     result_dict=field_result_dict,
                                                                     get_all_value=get_all_value)
    file_obj.close()
    return field_result_dict


def Compara_Counter_Dict(befor_counter_dict, after_counter_dict):
    counter_diff_dict = {}
    for counter_id in after_counter_dict.keys():
        after_counter_value = after_counter_dict[counter_id]
        befor_counter_value = befor_counter_dict[counter_id]
        list_len = len(after_counter_value)
        diff_list = []
        for i in range(0, list_len):
            diff = [int(j['value']) for j in after_counter_value[i] if j not in befor_counter_value[i]]
            diff_list.append(diff)
            counter_diff_dict[counter_id] = diff_list
    print(counter_diff_dict)
    return counter_diff_dict


def Check_counter_value_should_greater_than_zero(counter_value_dict):
    result_dict = {}
    keys_list = counter_value_dict.keys()
    for key in keys_list:
        tmp_value_list = []
        counter_value_list = counter_value_dict[key]
        for counter_value in counter_value_list:
            tmp_value = []
            for i in counter_value:
                if i > 0:
                    tmp_value.append(True)
                else:
                    tmp_value.append(False)
            if True in tmp_value:
                tmp_value_list.append(True)
            else:
                tmp_value_list.append(False)
        result_dict[key] = tmp_value_list
    print(result_dict)
    return result_dict


def Check_Tcpdump_Contain_field(field_value, file_path):
    with open(file_path, 'r') as file_obj:
        file_content = [line.strip(' ').strip('\n') for line in file_obj.readlines()]
    file_obj.close()
    if field_value in file_content:
        return True
    else:
        return False
