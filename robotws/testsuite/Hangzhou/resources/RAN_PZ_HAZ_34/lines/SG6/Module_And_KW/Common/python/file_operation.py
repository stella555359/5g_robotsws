# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: winnie.he
:contact: winnie.he@nokia.com
created: 2023-05-17
"""
import os
import yaml

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
