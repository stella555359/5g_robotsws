# -*- coding: utf-8 -*-

import yaml
import os
import logging
import re
import time
import json
import SSHLibrary
from robot.api import logger
from taf.transport.ssh import ssh
from collections import OrderedDict
from string import Template
import sys


ssh = ssh()
content1 = None
content2 = None


def yaml_add_new_content(file_path, new_content, key):
    """This keyword is used to add new content into yaml file.

    *AUTHOR* xiaoyu-mavis.mei@nokia-sbell.com
    | Input Parameters | Man. | Description |
    | file_path | Yes |  the yaml file path |
    | new_content | Yes |  the content which need to be add into yaml |
    | key | Yes |  the location which new content will be added |

    *RETURN VALUE*
    None

    Example
         &{new_content} =	BuiltIn.Create Dictionary	pullPolicy=always
        | yaml add new content |  ${yaml_file_path}  | ${new_content} | ${key} |
    """
    path = os.getcwd()
    logging.warning("path is % s" % path)
    with open(file_path) as values_file:
        values = yaml.load(values_file)
        values[key].update(new_content)
    with open(file_path, "w") as new_file:
        # yaml.safe_dump(data, file(filename,'w'), encoding='utf-8', allow_unicode=True)
        yaml.safe_dump(values, new_file, encoding="utf-8", allow_unicode=True)


def yaml_modify_content(file_path, key, modify_content, child_key=None):
    with open(file_path) as values_file:
        values = yaml.load(values_file, Loader=yaml.FullLoader)
        print(values[key])
        if child_key is not None:
            values[key][child_key] = modify_content
        else:
            values[key] = modify_content
    with open(file_path, "w") as new_file:
        yaml.safe_dump(values, new_file, encoding="utf-8", allow_unicode=True)


def dicMeg(dic1, dic2):
    for i in dic2:
        if i in dic1:
            if type(dic1[i]) is dict and type(dic2[i]) is dict:
                dicMeg(dic1[i], dic2[i])
            else:
                dic1[i] = dic2[i]
        else:
            dic1[i] = dic2[i]
    return dic1


def update_yaml_file(template_file, new_yaml):
    with open(template_file) as f:
        content1 = yaml.load(f, Loader=yaml.FullLoader)
        print("***template_file is {}".format(content1))
    with open(new_yaml) as f:
        content2 = yaml.load(f, Loader=yaml.FullLoader)
        print("***new_yaml is {}".format(content2))
        dicMeg(content2, content1)
        print("***content2 is {}".format(content2))

    with open(new_yaml, "w") as nf:
        yaml.dump(content2, nf, default_flow_style=False, sort_keys=False)
    return content2
