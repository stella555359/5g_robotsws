# -*- coding: utf-8 -*-

import yaml
import os
import logging


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
    logging.warning('path is % s' % path)
    with open(file_path) as values_file:
        values = yaml.load(values_file)
        values[key].update(new_content)
    with open(file_path, 'w') as new_file:
        # yaml.safe_dump(data, file(filename,'w'), encoding='utf-8', allow_unicode=True)
        yaml.safe_dump(values, new_file, encoding='utf-8', allow_unicode=True)


def yaml_modify_content(file_path, key, modify_content, child_key=None):
    with open(file_path) as values_file:
        values = yaml.load(values_file)
        print(values[key])
        if child_key is not None:
            values[key][child_key] = modify_content
        else:
            values[key] = modify_content
    with open(file_path, 'w') as new_file:
        yaml.safe_dump(values, new_file, encoding='utf-8', allow_unicode=True)
