# -*- coding: utf-8 -*-

from collections import Counter
import re
import os


def file_replace(filepath):
    file = open(filepath, "r")
    oringinal_content = file.read()
    content = re.sub(r'Ranges\s*\[.*\]', 'Ranges []', oringinal_content)
    file_after = open(filepath, "w")
    file_after.write(content)
    file_final = file_after.name
    file.close()
    return file_final


def get_str_appeared_times_in_file(str, filepath):
    file = open(filepath, "r")
    content = file.read()
    times = content.count(str)
    file.close()
    return times


def get_array_appeared_times_in_file(args):
    times = Counter(args)
    return times


def get_values_for_temp_voltage(item, filepath):
    file = open(filepath, "r")
    lines = file.readlines()
    file.close()
    length = len(lines)
    for i in range(length):
        if lines[i].startswith(item):
            range_content = lines[i + 4][19:].lstrip(" ").rstrip("<")
            itemType = lines[i]
            itemID = lines[i + 1]
            pattern = r"([-\d\S]+)\s*"
            result = re.findall(pattern=pattern, string=range_content)
            result_range = ['<'] + result
            values = lines[i + 5].replace("Values:", "").lstrip(" ")
            result_value = re.findall(pattern=pattern, string=values)
            list_range = result_range
            list_value = result_value
            dict_item = dict(zip(list_range, list_value))
            print(dict_item)
            val = dict_item["<"]
            if val != '0':
                print(itemType + itemID + "error! the value under range '<0' should be 0, actual value is: " + val)
                raise Exception("value error")


def get_values_for_cpu_memory(item, filepath):
    file = open(filepath, "r")
    lines = file.readlines()
    file.close()
    length = len(lines)
    for i in range(length):
        if lines[i].startswith(item):
            range_content = lines[i + 7][19:].lstrip(" ").rstrip("<")
            itemType = lines[i]
            itemID = lines[i + 1]
            pattern = r"([\d\S]+)\s*"
            result = re.findall(pattern=pattern, string=range_content)
            result_range = ['<'] + result
            values = lines[i + 8].replace("Values:", "").lstrip(" ")
            result_value = re.findall(pattern=pattern, string=values)
            list_range = result_range
            list_value = result_value
            dict_item = dict(zip(list_range, list_value))
            print(dict_item)
            val = dict_item["<"]
            if val != '0':
                print(itemType + itemID + "error! the value under range of '<0' should be 0, actual value is: " + val)
                raise Exception("value error")


def get_values_for_signal(item, filepath):
    file = open(filepath, "r")
    lines = file.readlines()
    file.close()
    length = len(lines)
    for i in range(length):
        if lines[i].startswith(item):
            range_content = lines[i + 5][19:].lstrip(" ").rstrip("<")
            pattern = r"([-\d\S]+)\s*"
            result = re.findall(pattern=pattern, string=range_content)
            result_range = ['<'] + result
            values = lines[i + 6].replace("Values:", "").lstrip(" ")
            result_value = re.findall(pattern=pattern, string=values)
            list_range = result_range
            print(list_range)
            list_value = result_value
            print(list_value)
            dict_item = dict(zip(list_range, list_value))
            print(dict_item)


def duplicate_removal_list(str):
    res = str.replace("['", '')
    res1 = res.replace("']", '')
    res2 = res1.replace("(", '')
    res3 = res2.replace(")\\n", ' ')
    result_list = res3.split(' ')
    dup_list = set(result_list)
    dup_list.remove('')
    list_removal = list(dup_list)
    return list_removal


def get_events(item, filepath):
    file = open(filepath, "r")
    lines = file.readlines()
    file.close()
    length = len(lines)
    for i in range(length):
        if lines[i].startswith(item):
            content = lines[i+2][16:].lstrip(" ").rstrip("\n")
            list1 = content.split(" ")
    return list1


def get_events_bbox5(filepath):
    with open("new_BBOX5.txt", "a+") as fp:
        if os.path.getsize("new_BBOX5.txt") != 0:
            fp.truncate(0)
    fp.close()
    with open(filepath, 'r') as f:
        line = f.readline()
        while line:
            line = f.readline()
            if line == '\n':
                break
            with open("new_BBOX5.txt", "a+") as fp:
                fp.writelines(line)
            fp.close()
    f.close()
    with open("new_BBOX5.txt", "r") as fp:
        lines = fp.readlines()
        del lines[0:2]
    fp.close()
    with open("new_BBOX5.txt", "a+") as fp:
        if os.path.getsize("new_BBOX5.txt") != 0:
            fp.truncate(0)
    fp.close()
    with open("new_BBOX5.txt", "w") as fp:
        fp.writelines(lines)
    fp.close()
    event = []
    with open("new_BBOX5.txt", "r") as fp:
        ls = fp.readlines()
        for li in ls:
            event.append(li.split(',')[0])
    # print(event)
    return event


def get_resets_info(item, filepath):
    file = open(filepath, "r")
    lines = file.readlines()
    file.close()
    length = len(lines)
    for i in range(length):
        if lines[i].startswith(item):
            content = lines[i+2:i+4]
            print(content)
    return content


def list_comparison(list1, list2):
    result = [x for x in list1 if x in list2]
    return result
