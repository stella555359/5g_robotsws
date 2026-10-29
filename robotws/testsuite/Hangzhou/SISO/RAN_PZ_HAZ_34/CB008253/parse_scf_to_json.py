# -*- coding: utf-8 -*-
# @Time    : 2022/9/26 13:34
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : parse_scf_to_json.py
# @Software: PyCharm
import xml.dom.minidom as XmlDocument
import json


def generate_ru_delta_json_from_scf(scf, target_managed_objects, delta_json_file):
    # 加载xml文件到内存中
    doc = XmlDocument.parse(scf)
    # 获取managedObject节点信息
    managedObjects = doc.getElementsByTagName('managedObject')
    all_parameters = []
    # 循环遍历managedObjects节点
    for managedObject in managedObjects:
        single_parameter = {}
        parameters = []
        # distName是包含在tag信息中的属性<managedObject distName="MRBTS-2004">，所以使用attributes获取
        dist_name = managedObject.attributes['distName'].value
        # 根据tag名，从managedObject中获取所有的tag=p的节点列表
        p_tag_list = managedObject.getElementsByTagName('p')
        for p_tag in p_tag_list:
            try:
                parameter = {}
                parameter_name = p_tag.attributes['name'].value
                value = p_tag.firstChild.data
                parameter["parameterName"] = parameter_name
                try:
                    int_value = int(value)
                    parameter["value"] = int_value
                    # special parameter : nrofHARQProcessesForPDSCH
                    if parameter["parameterName"] == "nrofHARQProcessesForPDSCH":
                        parameter["value"] = value
                except Exception as e:
                    parameter["value"] = value
                parameter["operation"] = "update"
                if "managedObject" in str(p_tag.parentNode):
                    parameters.append(parameter)
            except Exception as e:
                pass
        # 根据tag名，从managedObject中获取所有的tag=list的节点列表
        list_tag_list = managedObject.getElementsByTagName('list')
        if list_tag_list:
            for list_tag in list_tag_list:
                list_name = list_tag.attributes['name'].value
                list_parameters = {}
                list_value = []
                # 根据tag名，从tag=list中获取所有的tag=item的节点列表
                item_tag_list = list_tag.getElementsByTagName('item')
                if item_tag_list:
                    for item_tag in item_tag_list:
                        p_tag_item_tag_list = item_tag.getElementsByTagName('p')
                        sub_parameter = {}
                        for p_tag in p_tag_item_tag_list:
                            try:
                                parameter_name = p_tag.attributes['name'].value
                                value = p_tag.firstChild.data
                                try:
                                    int_value = int(value)
                                    sub_parameter[parameter_name] = int_value
                                except Exception as e:
                                    sub_parameter[parameter_name] = value
                            except Exception as e:
                                pass
                        list_value.append(sub_parameter)
                else:
                    sub_p_tag_list = list_tag.getElementsByTagName('p')
                    for sub_p_tag in sub_p_tag_list:
                        value = sub_p_tag.firstChild.data
                        list_value.append(value)
                list_parameters["parameterName"] = list_name
                list_parameters["value"] = list_value
                list_parameters["operation"] = "update"
                parameters.append(list_parameters)
        single_parameter["distName"] = dist_name
        if "/NRDU-" in dist_name or "/SYNC-" in dist_name:
            single_parameter["operation"] = "update"
        elif dist_name == "MRBTS-1978/NRBTS-1980/NRCELLGRP-2" and "1978_CREATE_RU2_DELTA.json" in delta_json_file:
            single_parameter["operation"] = "update"
        else:
            single_parameter["operation"] = "create"
        single_parameter["parameters"] = parameters
        if dist_name in target_managed_objects:
            all_parameters.append(single_parameter)

    all_parameters_str = str(all_parameters)
    all_parameters_str = all_parameters_str.replace("\'false\'", "false")
    all_parameters_str = all_parameters_str.replace("\'true\'", "true")
    all_parameters_str = all_parameters_str.replace("\'", "\"")
    with open(delta_json_file, "w") as fw:
        json.dump(json.loads(all_parameters_str), fw, ensure_ascii=False, indent=2)


def generate_ru_delta_json(scf, bts_id, cur_dir):
    with open(cur_dir + "//objects_config.json", encoding="utf-8") as fr:
        objects_config = json.load(fr)
    if bts_id == 2004:
        generate_ru_delta_json_from_scf(scf, objects_config["target_managedObjects_RU2_2004"],
                                        cur_dir + "//2004_CREATE_RU2_DELTA.json")
        generate_ru_delta_json_from_scf(scf, objects_config["target_managedObjects_RU3_2004"],
                                        cur_dir + "//2004_CREATE_RU3_DELTA.json")
        generate_ru_delta_json_from_scf(scf, objects_config["target_managedObjects_RU5_2004"],
                                        cur_dir + "//2004_CREATE_RU5_DELTA.json")
        generate_ru_delta_json_from_scf(scf, objects_config["target_managedObjects_BB2_2004"],
                                        cur_dir + "//2004_CREATE_BB2_DELTA.json")
        generate_ru_delta_json_from_scf(scf, objects_config["target_managedObjects_BB3_2004"],
                                        cur_dir + "//2004_CREATE_BB3_DELTA.json")
    elif bts_id == 1978:
        generate_ru_delta_json_from_scf(scf, objects_config["target_managedObjects_RU2_1978"],
                                        cur_dir + "//1978_CREATE_RU2_DELTA.json")
        generate_ru_delta_json_from_scf(scf, objects_config["target_managedObjects_RU3_1978"],
                                        cur_dir + "//1978_CREATE_RU3_DELTA.json")
    else:
        pass
