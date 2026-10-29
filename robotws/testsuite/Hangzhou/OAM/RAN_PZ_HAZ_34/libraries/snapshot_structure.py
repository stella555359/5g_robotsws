"""
Author: JingMin He
Contacts: jingmin.he@nokia-sbell.com
Description: Keywords are used to get snapshot structure by snapshot_file_list.txt

"""

import os
import re
# import csv


def get_snapshot_file_orgnization(file_folder):
    snapshot_file = os.path.join(file_folder, "snapshot_file_list.txt")
    file_tree = {}
    with open(snapshot_file, "r") as snapshot_files:
        file_structure = snapshot_files.read().split("\n\n")
        for file in file_structure:
            if file.count(".zip") > 0:
                zip_info = re.split(":.*\n", file)
                file_tree[zip_info[0]] = []
                file_list = zip_info[1].splitlines()
                for file_name in file_list:
                    file_tree[zip_info[0]].append(file_name.strip())
            else:
                file_tree[file] = None
    return file_tree


def get_file_from_snapshot_by_key(key_name, snapshot_structure):
    for key, value in snapshot_structure.items():
        if key.count(".zip") > 0:
            for name in value:
                if name.count(key_name) > 0:
                    return key, name
        else:
            if key.count(key_name) > 0:
                return file_folder, key
