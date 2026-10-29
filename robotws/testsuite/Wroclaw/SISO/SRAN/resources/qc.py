"""
:copyright: Nokia Solutions And Networks
:author: michal.szajkowski@nokia.com
:maintainer: None
"""

import json
import re
from robot.api import logger
import os


def in_case_of_failure_just_return_first_arg(f):
    def func(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except Exception as e:
            print(e)
            return args[0]
    return func


@in_case_of_failure_just_return_first_arg
def set_correct_test_instance_based_on_qc_file(test_name, sw, executed_file_path):
    qc_filename = get_qc_filename(executed_file_path)
    with open(qc_filename) as qc_data:
        qc_data = json.load(qc_data)
        qc_release_regex = get_matching_sw_regex(qc_data, sw)
        qc_list = find_lists_in_dict(qc_data[qc_release_regex])
        for tc in qc_list:
            if test_name in tc:
                return re.sub(r'(\[[^\]\[]*[a-z|A-Z|\_][^\]\[]*\])', '', tc, count=1)
        logger.info("Test name and instance not found in .qc file!!!", also_console=True)
        return test_name


def get_qc_filename(executed_file_path):
    qc_file_path = '/'.join(executed_file_path.split('/')[0:-1])
    executed_filename = executed_file_path.split('/')[-1].split('.')[0]
    logger.debug("Looking for .qc file in path: " + qc_file_path)
    for file in os.listdir(qc_file_path):
        if file.endswith(".qc") and executed_filename == file.split('.')[0]:
            logger.info("Reading TCs from: " + file)
            return qc_file_path + '/' + file
    for file in os.listdir(qc_file_path):
        if file.endswith(".qc"):
            logger.info("Reading TCs from: " + file)
            return qc_file_path + '/' + file
    logger.warn(".qc file not found!!!")
    raise KeyError(".qc file not found!!!")


def find_lists_in_dict(qc_release_dict):
    test_cases = []
    for key in qc_release_dict:
        if key.startswith('Root'):
            for test_set in qc_release_dict[key]:
                test_cases = test_cases + qc_release_dict[key][test_set]
    logger.debug("Test cases read from .qc file: " + str(test_cases))
    return test_cases


def get_matching_sw_regex(qc_data, sw):
    for key in qc_data:
        match = re.search(key, sw)
        if match:
            return key
    logger.warn("SW not matching any regex in .qc file!!!")
    raise KeyError("SW not matching any regex in .qc file!!!")
