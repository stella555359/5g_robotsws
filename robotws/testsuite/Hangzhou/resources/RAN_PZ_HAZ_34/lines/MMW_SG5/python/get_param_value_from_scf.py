# -*- coding: utf-8 -*-
# @Time    : 2023/9/14 20:56
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : get_param_value_from_scf.py
# @Software: PyCharm
import xml.dom.minidom as XmlDocument


def get_param_value_from_scf(scf, dist=None, abbreviation=None):
    doc = XmlDocument.parse(scf)
    managedObjects = doc.getElementsByTagName('managedObject')
    json_scf = {}
    for managedObject in managedObjects:
        dist_name = managedObject.attributes['distName'].value
        json_scf[dist_name] = {}
        p_tag_list = managedObject.getElementsByTagName('p')
        for p_tag in p_tag_list:
            try:
                parameter_name = p_tag.attributes['name'].value
                value = p_tag.firstChild.data
                json_scf[dist_name][parameter_name] = value
            except Exception as e:
                pass
        list_tag_list = managedObject.getElementsByTagName('list')
        if list_tag_list:
            for list_tag in list_tag_list:
                list_name = list_tag.attributes['name'].value
                list_value = []
                item_tag_list = list_tag.getElementsByTagName('item')
                if item_tag_list:
                    for item_tag in item_tag_list:
                        p_tag_item_tag_list = item_tag.getElementsByTagName('p')
                        item_dict = {}
                        for p_tag in p_tag_item_tag_list:
                            try:
                                parameter_name = p_tag.attributes['name'].value
                                value = p_tag.firstChild.data
                                item_dict[parameter_name] = value
                            except Exception as e:
                                pass
                        list_value.append(item_dict)
                else:
                    sub_p_tag_list = list_tag.getElementsByTagName('p')
                    for sub_p_tag in sub_p_tag_list:
                        value = sub_p_tag.firstChild.data
                        list_value.append(value)
                json_scf[dist_name][list_name] = list_value

    if dist and abbreviation:
        return json_scf[dist][abbreviation]
    else:
        return json_scf
