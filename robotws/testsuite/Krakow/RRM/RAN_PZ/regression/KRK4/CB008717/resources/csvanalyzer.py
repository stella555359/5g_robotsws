# Copied from testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/python/csvanalyzer.py
# author/email  : Jian.1.Chen / jian.1.chen@nokia-sbell.com
import csv
import xml.etree.ElementTree as ET


def get_the_special_item_value(file_path, special_item="3gpp.slot", sort_time=False):
    with open(file_path, 'r') as csv_file:
        reader = list(csv.reader(csv_file))
        new_reader = sorted(reader[1:], key=lambda x: float(x[1]))
        new_reader.insert(0, reader[0])

    item_column = 0
    for item in new_reader[0]:
        if item == special_item:
            break
        item_column += 1

    special_item_value_list = []
    for item in new_reader[1:]:
        if item[item_column]:
            special_item_value_list.append(item[item_column])

    if not sort_time:
        special_item_value_list = list(set(special_item_value_list))
        list.sort(special_item_value_list)

    return special_item_value_list


def get_the_special_item_value_count(file_path, special_item="3gpp.slot", special_item_value=4, sort_time=False):
    with open(file_path, 'r') as csv_file:
        reader = list(csv.reader(csv_file))
        new_reader = sorted(reader[1:], key=lambda x: x[1])
        new_reader.insert(0, reader[0])

    item_column = 0
    for item in new_reader[0]:
        if item == special_item:
            break
        item_column += 1

    count = 0
    for item in new_reader[1:]:
        if item[item_column] == str(special_item_value):
            count += 1

    return count


def get_counter_value_from_rdbts(xml_file, dist_name, counter_name):
    tree = ET.parse(xml_file)
    root = tree.getroot()

    counter_value = 0
    for elem in root.iter():
        if elem.tag == "DN":
            dn = elem.text
        if elem.tag == "NE-WBTS_1.0" and dn == dist_name:
            for i in elem.iter():
                if i.tag == counter_name:
                    counter_value += int(i.text)
                    # counters.append(i.text)
                    print(i.text)
    return counter_value
