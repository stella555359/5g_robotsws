import os
import xml.etree.ElementTree as ET
import re
from xml.etree.ElementTree import parse
from lxml import etree
import lxml.etree as tree_str


def xml_file_read(file_name):
    try:
        tree = ET.parse(file_name)
        root = tree.getroot()
        return tree, root
    except Exception as e:
        print("exception during opening of the file".format(file_name))


def _process_key(key):
    string = None
    index = None
    if '[' in key:
        r = re.search("(\\.*\\/*\\w+)\\[(\\d+)\\]", key)
        if r:
            string = r.group(1)
            index = r.group(2)
    else:
        r = re.search("(\\.*\\/*\\w+)", key)
        if r:
            string = r.group(1)
    return string, index


def replace_value(file_name, entries, parser=None, file_data=None):
    try:
        if file_data is None or root is None:
            parser, file_data = xml_file_read(file_name)
        for key, replace_str in entries.items():
            exact_key, index = _process_key(key)
            change_string = './/'+exact_key
            tree_entries = file_data.findall('.//'+exact_key)
            if index is not None:
                replace_text = tree_entries[int(index)].text
                tree_entries[int(index)].text = tree_entries[int(index)].text.replace(replace_text, replace_str)
            else:
                for entries in tree_entries:
                    entries.text = entries.text.replace(entries.text, replace_str)

            parser.write(file_name)
    except Exception as e:
        print("exception during search of variables".format(e))


def delete_list(file_name, entries):
    try:
        for key, data in entries.items():
            info = re.split('/', key)
            parent = info[0]
            lst = int(info[1])
            doc = etree.parse(file_name)
            for elem in doc.findall('.//'+parent):
                entry = elem[lst]
                parent = entry.getparent()
                parent.remove(entry)
            with open(file_name, "wb") as f:
                f.write(etree.tostring(doc))
    except Exception as e:
        print("exception during deletion of entries".format(e))


def add_data(file_name, entries):
    try:
        for key, data in entries.items():
            print(key, data)
            info = re.split('/', key)
            parent = info[0]
            lst = int(info[1])
            item = info[2]
            etree = tree_str.parse(file_name)
            elem = etree.findall('.//'+item)
            print(elem)
            xml_node = elem[lst]
            item = tree_str.SubElement(xml_node, parent)
            key_value = re.split('/', data)
            print(key_value)
            for keys in key_value:
                param_val = re.split(':', keys)
                tree_str.SubElement(item, param_val[0]).text = param_val[1]
            # item.insert(1, item[-1])
            with open(file_name, "wb") as f:
                f.write(tree_str.tostring(etree))
    except Exception as e:
        print("exception during data addition of entries".format(e))
