# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Zhang wen chao
:contact:
:history:
1. 2021-6-25 create
"""

import re
import logging
# from robot.libraries.XML import XML
from .localxml import XML as LOCALXML
xml = LOCALXML()

try:
    import xml.etree.cElementTree as ET
except ImportError:
    import xml.etree.ElementTree as ET


def get_elements_values_from_xml(xml_path, parameter):
    values = xml.get_elements_texts(source=xml_path, xpath='.//p[@name="{}"]'.format(parameter))
    return values


def get_element_value_from_xml(xml_path, mo_dist_name, parameter):
    value = xml.get_element_text(source=xml_path, xpath='.//managedObject[@distName="{}"]/p[@name="{}"]'
                                 .format(mo_dist_name, parameter))
    return value


def check_element_exist_from_xml(xml_path, mo_dist_name, parameter):
    try:
        temp_element = xml.get_element_text(source=xml_path,
                                            xpath='.//managedObject[@distName="{}"]/p[@name="{}"]'
                                            .format(mo_dist_name, parameter))
    finally:
        pass
    if len(temp_element) != 0:
        return True
    else:
        return False


def check_elements_exist_from_xml(xml_path, parameter):
    try:
        temp_elements = xml.get_elements(source=xml_path, xpath='.//p[@name="{}"]'.format(parameter))
    finally:
        pass
    if len(temp_elements) != 0:
        return True
    else:
        return False


def check_mo_element_exist_from_xml(xml_path, mo, parameter):
    if xml.get_element_count(source=xml_path,
                             xpath='.//managedObject[@distName="{}"]/p[@name="{}"]'.format(mo, parameter)) != 0:
        return True
    else:
        return False


def check_mo_list_exist_from_xml(xml_path, mo, parameter):
    if xml.get_element_count(source=xml_path,
                             xpath='.//managedObject[@distName="{}"]/list[@name="{}"]'.format(mo, parameter)) != 0:
        return True
    else:
        return False


def modify_element_value_from_xml(xml_path, parameter, value, mo_dist_name=None):
    parse_file = xml.parse_xml(xml_path)
    value = str(value)
    if mo_dist_name is not None:
        ob = xml.get_element(source=parse_file, xpath='.//managedObject[@distName="{}"]'.format(mo_dist_name))
        xml.set_element_text(source=ob, text=value, xpath='.//p[@name="{}"]'.format(parameter))
    else:
        xml.set_elements_text(source=parse_file, text=value, xpath='.//p[@name="{}"]'.format(parameter))
    xml.save_xml(source=parse_file, path=xml_path)


def get_mo_list(xml_path):
    tree = ET.ElementTree(file=xml_path)
    mo_list = []
    for elem in tree.iter():
        dic_temp = elem.attrib
        for i in dic_temp.keys():
            if i == 'distName':
                mo_list.append(dic_temp['distName'])
    return mo_list


def get_version(xml_path):
    tree = ET.ElementTree(file=xml_path)
    for elem in tree.iter():
        dic_temp = elem.attrib
        for i in dic_temp.keys():
            if i == 'distName' and len(dic_temp.values()) == 4:
                if re.search(r'com.nokia.srbts.nrbts:', dic_temp.values()[3]):
                    return dic_temp.values()[2]
            break


def get_dist_from_class(xml_path, class_name):
    tree = ET.ElementTree(file=xml_path)
    mo_list = []
    for elem in tree.iter():
        dic_temp = elem.attrib
        for i in dic_temp.keys():
            if i == 'class':
                if dic_temp['class'] == 'com.nokia.srbts.nrbts:{}'.format(class_name):
                    mo_list.append(dic_temp['distName'])
                elif dic_temp['class'] == 'com.nokia.srbts:{}'.format(class_name):
                    mo_list.append(dic_temp['distName'])
    return mo_list


def get_mo_via_element_and_value(xml_path, parameter, value):
    mo_list = get_mo_list(xml_path)
    target_values = {}
    keys = []
    for mo in mo_list:
        try:
            target_value = get_element_value_from_xml(xml_path=xml_path, mo_dist_name=mo, parameter=parameter)
            target_values[mo] = target_value
        finally:
            pass
    for key, text in target_values.iteritems():
        if text == value:
            keys.append(key)
    return keys


def del_mo_from_xml(xml_path, del_mo):
    mo_list = get_mo_list(xml_path)
    if del_mo in mo_list:
        logging.info(del_mo)
        parse_file = xml.parse_xml(xml_path)
        xml.remove_element(source=parse_file, xpath='.//managedObject[@distName="{}"]'.format(del_mo),
                           remove_tail=True)
        xml.save_xml(source=parse_file, path=xml_path)
    else:
        logging.info("xml file not exist this del mo !")


def del_element_from_xml(xml_path, mo, parameter):
    if check_element_exist_from_xml(xml_path, mo, parameter) is True:
        parse_file = xml.parse_xml(xml_path)
        xml.remove_element(source=parse_file, xpath='.//managedObject[@distName="{}"]//p[@name="{}"]'
                           .format(mo, parameter))
        xml.save_xml(source=parse_file, path=xml_path)
    else:
        logging.info("xml file not exist this del parameter !")


def del_list_from_xml(xml_path, mo, parameter):
    if check_mo_list_exist_from_xml(xml_path, mo, parameter) is True:
        parse_file = xml.parse_xml(xml_path)
        xml.remove_element(source=parse_file, xpath='.//managedObject[@distName="{}"]//list[@name="{}"]'
                           .format(mo, parameter))
        xml.save_xml(source=parse_file, path=xml_path)
    else:
        logging.info("xml file not exist this del list !")


def del_elements_from_xml(xml_path, parameter):
    if check_elements_exist_from_xml(xml_path, parameter) is True:
        parse_file = xml.parse_xml(xml_path)
        xml.remove_elements(source=parse_file, xpath='.//p[@name="{}"]'.format(parameter))
        xml.save_xml(source=parse_file, path=xml_path)
    else:
        logging.info("xml file not exist this del parameter !")


def add_element_from_xml(xml_path, mo, parameter, value):
    if check_mo_element_exist_from_xml(xml_path, mo, parameter) is not True:
        parse_file = xml.parse_xml(xml_path)
        ob = xml.get_element(source=parse_file, xpath='.//managedObject[@distName="{}"]'.format(mo))
        element = '<p name="{}">{}</p>'.format(parameter, value)
        logging.info(element)
        xml.add_element(source=ob, element=element, index=0)
        xml.save_xml(source=parse_file, path=xml_path)
    else:
        modify_element_value_from_xml(xml_path, parameter, value, mo_dist_name=mo)


def get_cell_numid_list_from_scfc(xml_path):
    mo_list = get_mo_list(xml_path)
    id_list = []
    pattern = 'NRCELL-\\d+'
    for mo in mo_list:
        item = re.search(pattern, mo)
        if item is not None:
            id_num = re.search(r'\d+', item.group())
            id_list.append(id_num.group())
    id_lists = list(set(id_list))
    return id_lists


def get_mrbts_id_from_scfc(xml_path):
    mo_list = get_mo_list(xml_path)
    pattern = 'MRBTS-\\d+'
    id_index = ''
    for mo in mo_list:
        item = re.search(pattern, mo)
        if item is not None:
            id_index = re.search(r'\d+', item.group())
            break
    return id_index.group()


def get_nrbts_id_from_scfc(xml_path):
    mo_list = get_mo_list(xml_path)
    pattern = 'MRBTS-\\d+/NRBTS-\\d+'
    id_index = ''
    for mo in mo_list:
        item = re.search(pattern, mo)
        if item is not None:
            id_index = re.findall(r'NRBTS-(\d+)', item.group())
            break
    return id_index[0]


def pretty_format(xml_path):
    tree = ET.parse(xml_path)
    root = tree.getroot()
    _indent(elem=root, level=1)
    tree.write(xml_path)


def _indent(elem, level=0, hor='\t', ver='\n'):
    i = ver + level * hor
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + hor
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            _indent(elem, level + 1, hor, ver)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i


def del_eles_from_xml(xml_path, mo):
    parse_file = xml.parse_xml(xml_path)
    xml.remove_elements(source=parse_file, xpath='.//managedObject[@distName="{}"]'
                        .format(mo))
    xml.save_xml(source=parse_file, path=xml_path)

# if __name__ == "__main__":
#    del_elements_from_xml('test.xml', 'lteToNrFrameShift')
