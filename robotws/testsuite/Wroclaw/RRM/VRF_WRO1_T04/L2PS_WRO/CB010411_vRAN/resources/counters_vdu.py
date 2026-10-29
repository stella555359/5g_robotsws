import os
import xml.etree.ElementTree as ET
from robot.libraries.BuiltIn import BuiltIn


def find_counter_in_dir(counter_id, value, dir_path, local_moid):
    correct_counters = []
    for file in os.listdir(dir_path):
        if file.endswith(".xml"):
            tree = ET.parse(dir_path + file)
            root = tree.getroot()

            for child in root[0][0][0]:
                if child.text == 'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1':
                    for child in root[0][0][1]:
                        if child.tag == counter_id and child.text == value:
                            correct_counters.append(child.text)
    if len(correct_counters) == 0:
        BuiltIn().fail("There is no counter")
    elif len(correct_counters) > 1:
        BuiltIn().fail("There is more than 1 value of this counter")


def find_counter_in_dir_and_verify_if_its_bigger_than_given_value(counter_id, value, dir_path, local_moid):
    correct_counters = []
    for file in os.listdir(dir_path):
        if file.endswith(".xml"):
            tree = ET.parse(os.path.join(dir_path, file))
            root = tree.getroot()

            for child in root[0][0][0]:
                if child.text == 'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1':
                    for child in root[0][0][1]:
                        if child.tag == counter_id and float(child.text) > float(value):
                            correct_counters.append(child.text)
    if len(correct_counters) == 0:
        BuiltIn().fail("There is no counter greater than the specified value")
    elif len(correct_counters) > 1:
        BuiltIn().fail("There is more than 1 counter with a value greater than the specified value")
