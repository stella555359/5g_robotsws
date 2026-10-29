# -*- coding: utf-8 -*-
# @Time    : 2023/7/25 11:18
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : gen_delta_base_2scf.py
# @Software: PyCharm
import xml.dom.minidom as XmlDocument
import json
from get_param_value_from_scf import get_param_value_from_scf
import xmltodict


def _analysis_p_tag(p_object, obj_param):
    if isinstance(p_object, dict):
        obj_param[p_object["@name"]] = p_object["#text"]
    elif isinstance(p_object, list):
        p_list = []
        for p in p_object:
            if "@name" in p:
                obj_param[p["@name"]] = p["#text"]
            else:
                p_list.append(p)
        if len(p_list) != 0:
            return p_list
    elif isinstance(p_object, str):
        obj_param = [p_object]
    return obj_param


def _analysis_list_tag(list_object, obj_param):
    if "item" in list_object:
        obj_param[list_object["@name"]] = []
        if isinstance(list_object["item"], dict):
            p_param = _analysis_p_tag(list_object["item"]["p"], {})
            obj_param[list_object["@name"]].append(p_param)
        elif isinstance(list_object["item"], list):
            for item in list_object["item"]:
                p_param = _analysis_p_tag(item["p"], {})
                obj_param[list_object["@name"]].append(p_param)
    else:
        p_param = _analysis_p_tag(list_object["p"], {})
        obj_param[list_object["@name"]] = p_param


def parse_scf_to_json(scf):
    with open(scf, "r") as fr:
        doc = xmltodict.parse(fr.read())

    objects = doc["raml"]["cmData"]["managedObject"]
    delta_json = {}
    for object in objects:
        obj_param = {}
        if "p" in object:
            _analysis_p_tag(object["p"], obj_param)
        if "list" in object:
            if isinstance(object["list"], dict):
                _analysis_list_tag(object["list"], obj_param)
            elif isinstance(object["list"], list):
                for obj in object["list"]:
                    _analysis_list_tag(obj, obj_param)
        delta_json[object["@distName"]] = obj_param

    with open(scf.replace(".xml", "json"), "w") as fw:
        json.dump(delta_json, fw, indent=4)
    return delta_json


def modify_delta_json(delta1, modify, delta2):
    with open(delta1, "r") as fr:
        list1 = json.loads(fr.read())
    with open(modify, "r") as fr:
        list2 = json.loads(fr.read())
    for json1 in list1:
        for json2 in list2:
            if json1["distName"] == json2["distName"]:
                print(json1["distName"])
                print(json2["distName"])
                json1["operation"] = json2["operation"]
                json1["parameters"] = json2["parameters"]
                print(json1)
                print(json2)
    with open(delta2, "w") as fw:
        json.dump(list1, fw, indent=4)


def generate_delete_json_from_2_old_scf(old_scf1, old_scf2, delete_json="scf1_to_scf2.json"):
    json_scf1 = parse_scf_to_json(old_scf1)
    json_scf2 = parse_scf_to_json(old_scf2)
    dist_names1 = json_scf1.keys()
    dist_names2 = json_scf2.keys()
    scf1_to_scf2_json = []
    for dist_name in dist_names1:
        if dist_name not in dist_names2:
            delete_param = dict()
            delete_param["distName"] = dist_name
            delete_param["operation"] = "delete"
            delete_param["parameters"] = []
            scf1_to_scf2_json.append(delete_param)
        elif json_scf1[dist_name] != json_scf2[dist_name]:
            param2 = dict()
            param2["distName"] = dist_name
            param2["operation"] = "update"
            sub_param2s = []
            for i in json_scf2[dist_name].keys():
                if i not in json_scf1[dist_name] or json_scf1[dist_name][i] != json_scf2[dist_name][i]:
                    sub_param2 = dict()
                    sub_param2["parameterName"] = i
                    sub_param2["value"] = json_scf2[dist_name][i]
                    sub_param2["operation"] = "update"
                    sub_param2s.append(sub_param2)
            for i in json_scf1[dist_name].keys():
                if i not in json_scf2[dist_name]:
                    sub_param2 = dict()
                    sub_param2["parameterName"] = i
                    sub_param2["value"] = []
                    sub_param2["operation"] = "delete"
                    sub_param2s.append(sub_param2)
            param2["parameters"] = sub_param2s
            scf1_to_scf2_json.append(param2)
    # for dist_name in dist_names2:
    #     if dist_name not in dist_names1:
    #         add_param = dict()
    #         delete_param["distName"] = dist_name
    #         delete_param["operation"] = "delete"
    #         delete_param["parameters"] = []
    #         scf1_to_scf2_json.append(delete_param)
    with open(delete_json, "w") as f:
        json.dump(scf1_to_scf2_json, f, indent=4)


def generate_add_json_base_delete_json_and_cur_scf(cur_scf, delete_json="scf1_to_scf2.json",
                                                   add_json="scf2_to_scf1.json"):
    with open(delete_json, "r") as fr:
        delete_distnames = json.loads(fr.read())
    add_distnames = {}
    update_params = []
    for distname in delete_distnames:
        if distname["operation"] == "delete":
            add_distnames[distname["distName"]] = "create"
        elif distname["operation"] == "update":
            # add_distnames[distname["distName"]] = "update"
            update_params.append(distname)
        elif distname["operation"] == "create":
            add_distnames[distname["distName"]] = "delete"
    generate_delta_json_from_scf(cur_scf, add_distnames, add_json, update_params)


def generate_delta_jsons_from_3_scf(cur_scf, old_scf1, old_scf2, scf1_to_scf2_json_file="scf1_to_scf2.json",
                                    scf2_to_scf1_json_file="scf2_to_scf1.json"):
    generate_delete_json_from_2_old_scf(old_scf1, old_scf2, scf1_to_scf2_json_file)
    generate_add_json_base_delete_json_and_cur_scf(cur_scf, scf1_to_scf2_json_file, scf2_to_scf1_json_file)


def generate_delta_json_from_scf(scf, target_managed_objects, delta_json_file, update_params):
    # process the update params first
    for update_param in update_params:
        true_parameters = []
        for parameter in update_param["parameters"]:
            param = dict()
            param["parameterName"] = parameter["parameterName"]
            param["value"] = get_param_value_from_scf(scf, update_param["distName"], parameter["parameterName"])
            param["operation"] = parameter["operation"]
            true_parameters.append(param)
        update_param["parameters"] = true_parameters

    doc = XmlDocument.parse(scf)
    managedObjects = doc.getElementsByTagName('managedObject')
    all_parameters = update_params.copy()
    for managedObject in managedObjects:
        single_parameter = {}
        parameters = []
        dist_name = managedObject.attributes['distName'].value
        p_tag_list = managedObject.getElementsByTagName('p')
        for p_tag in p_tag_list:
            try:
                parameter = {}
                parameter_name = p_tag.attributes['name'].value
                value = p_tag.firstChild.data
                parameter["parameterName"] = parameter_name
                parameter["value"] = str(value)
                parameter["operation"] = "update"
                if "managedObject" in str(p_tag.parentNode):
                    parameters.append(parameter)
            except Exception as e:
                pass
        list_tag_list = managedObject.getElementsByTagName('list')
        if list_tag_list:
            for list_tag in list_tag_list:
                list_name = list_tag.attributes['name'].value
                list_parameters = {}
                list_value = []
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
                                    int_value = str(value)
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
        else:
            single_parameter["operation"] = "create"
        single_parameter["parameters"] = parameters
        if dist_name in target_managed_objects:
            single_parameter["operation"] = target_managed_objects[dist_name]
            if single_parameter["operation"] == "delete":
                single_parameter["parameters"] = []
            all_parameters.append(single_parameter)

    all_parameters_str = str(all_parameters)
    all_parameters_str = all_parameters_str.replace("\'false\'", "false")
    all_parameters_str = all_parameters_str.replace("\'true\'", "true")
    all_parameters_str = all_parameters_str.replace("\'", "\"")
    with open(delta_json_file, "w") as fw:
        json.dump(json.loads(all_parameters_str), fw, ensure_ascii=False, indent=2)
        # json.dump(all_parameters_str, fw, indent=4)


if __name__ == "__main__":
    # generate_delta_jsons_from_3_scf("cur_scf.xml", "scf1.xml", "scf2.xml",
    #                                 "scf1_to_scf2.json", "scf2_to_scf1.json")
    # generate_delta_jsons_from_3_scf("COMMON_SCF.xml",
    #                                 "NO_RU3456_SCF.xml",
    #                                 "NO_RU356_SCF.xml",
    #                                 "scf1_to_scf211.json", "scf2_to_scf111.json")
    pass
