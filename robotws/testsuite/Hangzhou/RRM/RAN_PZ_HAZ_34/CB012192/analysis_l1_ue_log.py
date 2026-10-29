# -*- coding: utf-8 -*-
# @Time    : 2025/1/21 13:39
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : analysis_l1_ue_log.py
# @Software: PyCharm
import xml.etree.ElementTree as ET
import json


def one_message_to_json(xml_string):
    # Parse the XML content
    root = ET.fromstring(xml_string)

    # Function to convert XML tree to a dictionary
    def xml_to_dict(element):
        node = {}
        if element.text and element.text.strip():
            node['text'] = element.text.strip()
        for child in element:
            child_dict = xml_to_dict(child)
            if child.tag not in node:
                node[child.tag] = child_dict
            else:
                if not isinstance(node[child.tag], list):
                    node[child.tag] = [node[child.tag]]
                node[child.tag].append(child_dict)
        return node

    # Convert the XML tree to a dictionary
    xml_dict = xml_to_dict(root)

    return xml_dict


def parse_ue_xml_log_via_one_message(file_path, target_one_message="NR Rach Attempt Information"):
    # Open and read the XML file content
    with open(file_path, 'r', encoding='utf-8') as file:
        xml_content = file.read()

    # Parse the XML content
    root = ET.fromstring(xml_content)
    match_results = []

    for one_message in root.findall(".//OneMessage"):
        if one_message.get("Name") == target_one_message:
            match_results.append(ET.tostring(one_message, encoding="unicode"))

    return match_results


def get_ue_beam_id_and_rach_result(ue_xml_log_path, beam_result):
    nr_rach_attempt_messages = parse_ue_xml_log_via_one_message(ue_xml_log_path)
    for msg in nr_rach_attempt_messages:
        msg = one_message_to_json(msg)
        tx_beam_id = msg["message"]["NR-Rach-Attempt"]["NR-Rach-Attempt-Cell1"]["TxBeamID"]["text"]
        rach_result = msg["message"]["NR-Rach-Attempt"]["NR-Rach-Attempt-Cell1"]["RachResult"]["text"]
        if not beam_result:
            beam_result = dict()
        if tx_beam_id not in beam_result:
            beam_result[tx_beam_id] = dict()
        if rach_result not in beam_result[tx_beam_id]:
            beam_result[tx_beam_id][rach_result] = 0
        beam_result[tx_beam_id][rach_result] += 1
    return beam_result


if __name__ == '__main__':
    beam_result = {
        "0": {
            "SUCCESS(0)": 0,
            "fail": 0
        },
        "1": {
            "SUCCESS(0)": 0,
            "fail": 0
        },
        "2": {
            "SUCCESS(0)": 0,
            "fail": 0
        },
        "3": {
            "SUCCESS(0)": 0,
            "fail": 0
        },
        "4": {
            "SUCCESS(0)": 0,
            "fail": 0
        },
        "5": {
            "SUCCESS(0)": 0,
            "fail": 0
        }
    }
    get_ue_beam_id_and_rach_result('C:\\workspace\\TA\\CB012192\\ta_log_l1.xml', beam_result)
