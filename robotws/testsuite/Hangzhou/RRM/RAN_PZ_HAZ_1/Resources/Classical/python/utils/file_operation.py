# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: winnie.he
:contact: winnie.he@nokia.com
created: 2023-05-17
"""
import os
import yaml
import json
from robot.libraries.BuiltIn import BuiltIn
# for file opeation


def get_content_from_yml(file_path):
    yml_content = {}
    file_path = file_path.replace("~/", "/home/ute/")
    if os.path.isfile(file_path):
        with open(file_path) as f:
            yml_content = yaml.load(stream=f, Loader=yaml.FullLoader)
    return yml_content


def get_all_files_in_dictionary(dir_path, filter=None):
    f_path = []
    for root, dirs, files in os.walk(dir_path):
        for file in files:
            if filter and filter not in file:
                continue
            f_path.append(os.path.join(root, file))
    return f_path


def get_content_from_json(file_path):
    json_content = {}
    if os.path.isfile(file_path):
        with open(file_path) as f:
            json_content = json.load(f)
    return json_content


def replace_string_in_file(file_path, findstring, replacement):
    with open(file_path, 'r') as file:
        filedata = file.read()
    if findstring[0] == "'":
        findstring = findstring[1:-1]
    if findstring[-1] == "'":
        findstring = findstring[:-1]
    if replacement[0] == "'":
        replacement = replacement[1:-1]
    if replacement[-1] == "'":
        replacement = replacement[:-1]
    print(f"Replace string {findstring} {replacement} {filedata.index(findstring)}")
    filedata = filedata.replace(findstring, replacement)
    with open(file_path, 'w') as file:
        file.write(filedata)
