# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Jiangjing Lin
:contact: jiangjli@nokia-sbell.com
"""
from lxml import etree


def find_soap_message_zip(snapshot_file_path):
    file = open(snapshot_file_path, "r")
    lines = file.readlines()
    length = len(lines)
    for i in range(length):
        if 'SOAPMessageTraceCFG.xml' in lines[i]:
            break
    for j in range(0, i):
        index = i - j
        if '.zip:' in lines[index]:
            break
    return lines[index].strip().strip(":")


def getDistName(lines, index_end):
    for j in range(0, index_end):
        index = index_end - j
        if "<managedObject" in lines[index]:
            break
    distName = lines[index].split("distName=\"")[1].split("\"")[0]
    return distName


def getValueFromXML(paraName, soap_path, distname_match):
    file = open(soap_path, "r")
    lines = file.readlines()
    result = []
    for i in range(len(lines)):
        if paraName in lines[i]:
            if '<newValue/>' in lines[i+1]:
                value = ''
            else:
                value = lines[i+1].split(">")[1].split("<")[0]
            distname = getDistName(lines, i)
            if distname_match == distname:
                result.append(value)
    return result


def format_file_to_xml(filepath):
    parser = etree.XMLParser(remove_blank_text=True)
    tree = etree.parse(filepath, parser)
    tree.write(filepath, pretty_print=True, xml_declaration=True, encoding='UTF-8')
