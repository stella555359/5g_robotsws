# -*- coding: utf-8 -*

"""
:copyright: Nokia Networks
:author: Christophe SAMSON
:contact: christophe.samson@nokia.com
:maintainer:
:contact:
"""

import time
from decimal import *
import re
import os
import glob
import io
import subprocess
import csv
import math
import logging
import json
import xmltodict
import os.path
import sys
from bs4 import BeautifulSoup
import ast
import six
import datetime
from netaddr import valid_ipv4, valid_ipv6
import zipfile
import xml.etree.ElementTree as ETree
from pathlib import Path
import struct
import socket
import pathlib

# for testing purpose
# from testsuite.Paris.resources.SWENG.python.StringTool import datedConsole, printLineWithTitle
# import testsuite.Paris.resources.SWENG.python.StringTool
# End of for testing purpose
# comment below line for unitary test
# import StringTool
from testsuite.Paris.resources.SWENG.python import StringTool

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn
from robot.api.deco import keyword

from robot.api import logger
from taf.config.scf import scf
from taf.transport.ssh import ssh

logging.basicConfig(filename='log_l2_template.log', level='DEBUG')

# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

PREFIX_DISPLAY = "    "
logLevel = "INFO"
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()


def logException(functionNameStr, e, silent=False):
    rbi.log("%s(): Exception = <%s>" % (functionNameStr, str(e)), "TRACE")
    if not silent:
        rbi.log_to_console("  %s: exception happened (see log.html)" % functionNameStr)


def log_begin_end_func_name(fn):
    def inner(*args, **kwargs):
        if "--dryrun" not in sys.argv:
            logging.info("============================== Begin Function {0}".format(fn.__name__))
        func_return = fn(*args, **kwargs)
        if "--dryrun" not in sys.argv:
            logging.info("============================== End Function {0}".format(fn.__name__))
        return func_return
    return inner


def log_begin_end_func_name_v1(fn):
    def inner(*args, **kwargs):
        logging.info("============================== Begin Function {0}".format(fn.__name__))
        func_return = fn(*args, **kwargs)
        logging.info("============================== End Function {0}".format(fn.__name__))
        return func_return
    return inner


def logger_func(fn):
    def inner(*args, **kwargs):
        func_return = fn(*args, **kwargs)
        if "--dryrun" not in sys.argv:
            logging.debug("\n\tMethod: {0},  \n\t\tPositional Arguments: {1},  \n\t\tKeyword Arguments: {2},\
                           \n\tReturns: {3}".format(fn.__name__, args, kwargs, func_return))
        return func_return
    return inner


def log_info(functionNameStr, message=None, silent=False):
    logging.info("%s" % functionNameStr)
    logging.info("%s" % message)
    if not silent and message:
        rbi.log_to_console("\n" + GREEN + "  %s " % functionNameStr + RESET + "")
        rbi.log_to_console("\n" + GREEN + "  %s " % message + RESET + "")


def reform_coam_sw_version(version):
    """reform SW Version from COAM GNB to QC required form:
    from 5G19_FSMK_0000_018351_001507 to 5G_0.18351.1507
    from 5G19B_FDD_GNB_0008_001840_000327 to 5G19B_0.1840.327
    from SBTS21B_ENB_0000_210310_000024 to SBTS21B_ENB_0000_210310_000024
    from SBTS21B_ENB_9999_210310_000024 to SBTS00_ENB_9999_210310_000024
    from vDUCNF22R2_0.300.3624 to vDUCNF22R2_0_300_3624"""
    version = version.replace(".", "_")
    subversions = version.split('_')
    if version.startswith('5G'):
        version = strip_version(subversions[-3:])
        if version[0] == '0':
            result = '_'.join(['5G', version])
        else:
            result = '_'.join([subversions[0], version])
    elif version.startswith('SBTS'):
        if subversions[2].startswith('9'):
            subversions[0] = 'SBTS00'
        result = '_'.join(subversions)
    elif version.startswith('vDU'):
        if subversions[2].startswith('9'):
            subversions[0] = 'SBTS00'
        result = '_'.join(subversions)
    return result


def strip_version(version):
    """remove 0 from sw version"""
    for i in range(len(version)):
        if version[i].lstrip('0') == '':
            version[i] = '0'
        else:
            version[i] = version[i].lstrip('0')
    return '.'.join(version)


def get_short_release(release='SBTS00'):
    release_short = release.split("SBTS")[-1]
    release_short = "trunk" if release_short == "00" else release_short
    return release_short


def get_feature_paramters_from_scf(scf_path, feature_params, distname, listname=None, index=0):
    feature_params_dict = {}
    scfObj = scf()
    scfObj.load_scf(file_path=scf_path)
    for param in feature_params:
        if listname:
            param_value = scfObj.get_value_from_scf(dist_name=distname, list_name=listname, index=index, p_name=param)
        else:
            param_value = scfObj.get_value_from_scf(dist_name=distname, p_name=param)
        param_value = param_value if param_value not in ['True', 'False'] else param_value.lower()
        param_value = 'infinity' if param_value == 'inf' else param_value
        feature_params_dict[param] = param_value
    return feature_params_dict


def get_higher_value_from_dict(dict):
    higher_value = max(dict, key=dict.get)
    print("Highest value from dictionary:", higher_value)
    return higher_value


def getHeaderLine_63(name, value):
    return "{}{:63}={}".format(PREFIX_DISPLAY, name, value)


def getHeaderLine_63_2(name, value, value1):
    return "{}{:63}={} {}".format(PREFIX_DISPLAY, name, value, value1)


def getHeaderLine_13(name, value):
    return "{}{:13}={}".format(PREFIX_DISPLAY, name, value)


def toformatline(varname, name, val):
    return getHeaderLine_63("CFG:{}.{}".format(varname, name), val)


def toformatline2(varname, name, val1, val2):
    return getHeaderLine_63("CFG:{}.{}.{}".format(varname, name), val1, val2)


def toformatline_basic(varname, name, val):
    return getHeaderLine_63("{}.{}".format(varname, name), val)


def display_dictionnary_parameters_of_the_TestCase_v1(test_dictParam, title='TestCase'):
    title_printed = "Display parameters dictionnary of the " + title
    StringTool.printLineWithTitle(title_printed)
    for item in test_dictParam:
        # print('item='+item)
        # print('test_dictParam='+test_dictParam[item])
        StringTool.datedConsole(toformatline('TestCase Configuration', item, test_dictParam[item]))
    StringTool.printLineWithTitle("-")


def display_dictionnary_parameters_of_the_TestCase(test_dictParam, title='TestCase'):
    def display_dict(d, indent=0):
        for key, value in d.items():
            if isinstance(value, dict):
                StringTool.datedConsole(toformatline(' ' * indent + 'TestCase Configuration', key, ''))
                display_dict(value, indent + 4)
            else:
                StringTool.datedConsole(toformatline(' ' * indent + 'TestCase Configuration', key, value))

    title_printed = "Display parameters dictionary of the " + title
    StringTool.printLineWithTitle(title_printed)
    display_dict(test_dictParam)
    StringTool.printLineWithTitle("-")


def display_dictionnary_parameters_of_the_TestCase_old(test_dictParam):
    StringTool.printLineWithTitle("Display parameters dictionnary of the TestCase")
    for item in test_dictParam:
        # print('item='+item)
        # print('test_dictParam='+test_dictParam[item])
        StringTool.datedConsole(toformatline('TestCase Configuration', item, test_dictParam[item]))
    StringTool.printLineWithTitle("-")


def display_dictionnary_parameters_CAPTURE_of_the_TestCase(test_dictParam):
    StringTool.printLineWithTitle("Display parameters dictionnary CAPTURE of the TestCase")
    for item in test_dictParam:
        # print('item='+item)
        # print('test_dictParam='+test_dictParam[item])
        StringTool.datedConsole(toformatline('TestCase CAPTURE Configuration', item, test_dictParam[item]))
    StringTool.printLineWithTitle("-")


def display_dictionnary_parameters(test_dictParam, msg=""):
    StringTool.printLineWithTitle("Display parameters dictionnary")
    for item in test_dictParam:
        # print('item='+item)
        # print('test_dictParam='+test_dictParam[item])
        StringTool.datedConsole(toformatline('TestCase Configuration', item, test_dictParam[item]))
    StringTool.printLineWithTitle("-")


def display_dictionnary_parameters_w_name(test_dictParam, name='Display parameters dictionnary', msg=""):
    StringTool.printLineWithTitle(name)
    for item in test_dictParam:
        # print('item='+item)
        # print('test_dictParam='+test_dictParam[item])
        StringTool.datedConsole(toformatline('TestCase Configuration', item, test_dictParam[item]))
    StringTool.printLineWithTitle("-")


def display_list_parameters_w_name(test_listParam, name='Display parameters list', msg="Display parameters list"):
    StringTool.printLineWithTitle(msg)
    count = len(test_listParam)
    for item in test_listParam:
        # print('item='+item)
        # print('test_listParam='+test_listParam[item])
        StringTool.datedConsole(StringTool.getHeaderLine(name, item))
    StringTool.printLineWithTitle("-")


def display_list_parameters(test_listParam, msg=""):
    StringTool.printLineWithTitle("Display parameters list")
    for item in test_listParam:
        # print('item='+item)
        # print('test_listParam='+test_listParam[item])
        StringTool.datedConsole(toformatline2('TestCase Configuration', item[0], item[1], item[2]))
    StringTool.printLineWithTitle("-")


# get MRBTSID NRBTSID NRCELLID from scf
def get_mrbtsid_from_scf(file_path):
    p = re.compile(r'MRBTS-(\d*)/NRBTS-(\d*)/NRCELL-(\d*)')
    f = open(file_path)
    tex = f.read()
    f.close
    m = p.search(tex)
    print(m.group())
    mrbtsid = m.group(1)
    nrbtsid = m.group(2)
    nrcellid = m.group(3)
    return mrbtsid, nrbtsid, nrcellid


def get_divisor(unit):
    divisor = {'kbps': 1e3,
               'mbps': 1e6,
               'gbps': 1e9}
    return divisor[unit.lower()]


def sort_by_date_time(file_path):
    return os.path.getmtime(file_path)


@log_begin_end_func_name
def get_latest_pm_file(pm_files_path):
    """ This function takes the PM_Files Path and returns the latest PM XML file. """
    assert os.path.isdir(pm_files_path), f"PM Folder not present in directory: {pm_files_path}"

    pm_files = glob.glob(os.path.join(pm_files_path, '*.xml'))

    if not pm_files:
        raise AssertionError(f'No PM xml found in {pm_files_path}')

    try:
        latest_file = sorted(pm_files, key=sort_by_date_time)[-1]
        return latest_file
    except IndexError:
        return ""


@log_begin_end_func_name
def zip_files(folder_path, zip_file_name, match_string="*", nbr_file_to_zip=0):
    try:
        os.chdir(folder_path)
        list_of_files = sorted(glob.glob(match_string))
        logging.info("Number of files to zip: %s" % len(list_of_files))

        if len(list_of_files) > nbr_file_to_zip:
            with zipfile.ZipFile(zip_file_name, 'w') as zipf:
                for file in list_of_files:
                    zipf.write(file)
                    os.remove(file)
            logging.info("Created zip file: %s" % zip_file_name)
        else:
            logging.info("No files matched the pattern: %s" % match_string)
    except Exception as e:
        logging.error("zip_files: %s" % str(e))


def unzip_gnb_pm_counters_file(zip_file_path):
    # Pattern to match the filename
    file_pattern = r'PM\.BTS-1\.\d{8}\.\d{6}\.ANY\.xml'
    # Destination directory
    destination_dir = './extracted_files/'
    list_files = []

    # Create a ZipFile object
    with zipfile.ZipFile(zip_file_path, 'r') as zip_ref:
        # Find the file that matches the pattern
        matched_files = [name for name in zip_ref.namelist() if re.match(file_pattern, name)]

        if matched_files:
            # Extract the matched file
            for file_to_extract in matched_files:
                zip_ref.extract(file_to_extract, destination_dir)
                print(f'File {file_to_extract} extracted to {destination_dir}')
                list_files.append(destination_dir + "/" + file_to_extract)
        else:
            print('No matching file found in the ZIP archive')
    return list_files


@log_begin_end_func_name
def check_value(counter_value, value):
    if ((type(value) is list) and (int(value[0]) <= counter_value <= int(value[1]))) or (counter_value == value):
        return True
    else:
        return False


def _opt_eval(val):
    if not isinstance(val, six.string_types):
        return val
    return ast.literal_eval(val.strip())


@log_begin_end_func_name
def _opt_int_or_list(val):
    if val is None or isinstance(val, int) or isinstance(val, list):
        return val
    e_val = _opt_eval(val)
    if isinstance(e_val, list):
        return e_val
    return int(e_val)


@log_begin_end_func_name
def assert_enable():
    """Enable asserts"""
    global assert_enable
    assert_enable = True
    BuiltIn().log(f"assert_enable = {assert_enable}", level="INFO")


@log_begin_end_func_name
def assert_disable():
    """Disable asserts"""
    global assert_enable
    assert_enable = False
    BuiltIn().log(f"assert_enable = {assert_enable}", level="INFO")


@log_begin_end_func_name
def _assert(condition, message, can_fail=False):
    if not can_fail:
        if not condition:
            assert condition, message
    else:
        if not condition:
            BuiltIn().run_keyword("Log", message, 'WARN')
    if assert_enable:
        assert condition, message


@log_begin_end_func_name
def test_assert(condition, message, can_fail=False):
    if not can_fail:
        if not condition:
            assert condition, message
    else:
        if not condition:
            BuiltIn().run_keyword("Log", message, 'WARN')
    if assert_enable:
        assert condition, message


@log_begin_end_func_name
def verify_that_rtpm_counter_value_is_equal_to(object_name, counter_id, value):
    """
    :return: Checks if counter value collected with RTPM is equal to expected value
    :param object_name: Name of object, e.g. CELL-1
    :param counter_id: Counter ID., e.g. M8006C256
    :param value: Expected counter value - numeric or list of [min,max]

    +--------------------------------------------+---------------------+----------------------+-------------+
    |                                               Example                                                 |
    +============================================+=====================+======================+=============+
    | Verify that rtpm counter value is equal to | object_name=CELL-1 | counter_id=M8006C262 | value=2     |
    +--------------------------------------------+---------------------+----------------------+-------------+
    | Verify that rtpm counter value is equal to | object_name=CELL-1 | counter_id=M8006C262 | value=[1,3] |
    +--------------------------------------------+---------------------+----------------------+-------------+
    """
    value = _opt_int_or_list(value)

    counter_value = None
    counter_value = int(get_counter_value(cell_dist_name=object_name, counterId=counter_id))
    text = "DBG: verify_that_rtpm_counter_value_is_equal_to: counterId = %s desired_nrcell_id = %s pm_val=%s"
    logging.info(text % (counter_id, object_name, counter_value))
    _assert(check_value(counter_value, value),
            "Counter: {} value: {} is not as expected value: {}.".format(counter_id, counter_value, value),
            can_fail=True)


def read_dictionary_from_json(file_path):
    """ Returns a dictionary read from .json
        Args:
            file_path (str): full path to the .json file
        Returns:
            str: python dictionary
    """
    dictionary = {}
    try:
        with open(file_path) as json_file:
            dictionary = json.load(json_file)
    except Exception as e:
        logging.warn("read_dictionary_from_json: %s" % str(e))
    return dictionary


# function to add to JSON
def write_dictionary_to_json(dir_path, dictionary, filename='pm_counter.json'):
    json_path = dir_path + '/' + filename
    with open(json_path, 'w') as fp:
        json.dump(dictionary, fp, sort_keys=True, indent=4)


def add_dictionary_to_json(dir_path, key, dictionary, filename='data.json', sort_keys=True):
    json_path = dir_path + '/' + filename
    with open(json_path, 'r+') as file:
        # First we load existing data into a dict.
        file_data = json.load(file)
        # Join new_data with file_data inside emp_details
        file_data[key] = dictionary
        # Sets file's current position at offset.
        file.seek(0)
        # convert back to json.
        json.dump(file_data, file, sort_keys=sort_keys, indent=4)


def write_list_of_dictionary_to_json(dir_path, dictionary, filename='pm_counter.json'):
    json_path = dir_path + '/' + filename
    file_data = []
    with open(json_path, 'w') as fp:
        # Join new_data with file_data inside emp_details
        file_data.append(dictionary)
        # Sets file's current position at offset.
        fp.seek(0)
        json.dump(file_data, fp, sort_keys=True, indent=4)


# function to add to JSON
def add_list_of_dictionary_to_json(dir_path, dictionary, filename='data.json'):
    json_path = dir_path + '/' + filename
    with open(json_path, 'r+') as file:
        # First we load existing data into a dict.
        file_data = json.load(file)
        # Join new_data with file_data inside emp_details
        file_data.append(dictionary)
        # Sets file's current position at offset.
        file.seek(0)
        # convert back to json.
        json.dump(file_data, file, sort_keys=True, indent=4)


def load_json(filename_w_path='data.json'):
    with open(filename_w_path) as var_json:
        root_vars = json.load(var_json)
    return root_vars


def strip_headers(source_file, target_file):
    """
    Strips tshark header from given pdml file.
    """
    try:
        line_counter = 0
        with open(source_file, 'rb') as in_file, open(target_file, 'wb') as out_file:
            while True:
                if "xml version" in str(in_file.readline()):
                    break
                if line_counter > 100:
                    BuiltIn().log("ERR: Error with PDML format")
                    return None
                line_counter += 1
            out_file.writelines(in_file.readlines())
        os.chmod(target_file, 0o666)
    except IOError as e:
        BuiltIn().log("File %s not found" % source_file, "ERROR")
        BuiltIn().log(str(e), "ERROR")
        return None
    return


def ContainInList(element, Thelist):
    """
    Check if an element is present in Thelist.
    return string False or True
    """
    print("element:{}\ntype:{}".format(element, type(element)))
    print("Thelist:{}\ntype:{}".format(Thelist, type(Thelist)))
    return str(element in Thelist)


def check_if_sw_already_exists(path):
    exists = os.path.exists(path)
    return exists


def modify_suci_for_ue(old_suci, plmn):
    """
    Update PLMN in SUCI.
    :param old_suci: SUCI code
    :param plmn: e.g. 510:93
    :return: new SUCI code
    """
    mcc, mnc = plmn.split(":")
    old_suci_len = len(old_suci)
    old_suci = old_suci.split(":", 3)
    new_suci = "0:{}:{}:{}".format(mcc, mnc, old_suci[-1])
    if old_suci_len > len(new_suci):
        for i in range(0, old_suci_len - len(new_suci)):
            new_suci = new_suci + "0"
    elif old_suci_len < len(new_suci):
        for i in range(0, len(new_suci) - old_suci_len):
            new_suci = new_suci[0:-1]
    return new_suci


def obtain_new_suci(ue_id, suci_extract='0:311:489:0000:0:0:021645400'):
    split_suci = re.compile((r"^(\d{1,3}\:\d{1,3}\:\d{1,3}\:\d{1,4}\:\d{1,3}\:\d{1,3}\:)(\d+)$"))
    split_values = split_suci.match(suci_extract).groups()
    return split_values[0] + str((int(split_values[1]))+(int(ue_id)-1)).zfill(9)


def generate_list_of_ue_ids(start_ue_id, number_of_ues):
    list_ue_ids = list(range(int(start_ue_id), int(start_ue_id) + int(number_of_ues), 1))
    return list_ue_ids


def obtain_new_ip(ue_id, wts_extract='4.7.254.208'):
    extract_octets = re.compile(r"^(\d{1,3}\.\d{1,3}\.\d{1,3}\.)(\d{1,3})$")
    octets = extract_octets.match(wts_extract).groups()
    """first 3 octets concatenated with the last octet + ue_id
    This increments IP address by 1 for each UE
    Note: supported only till last octet reaches 255. Will be enhanced this in future"""
    return octets[0] + str((int(octets[1]))+int(ue_id-1))


def return_basename(file):
    return os.path.basename(file)


def return_path(file):
    return os.path.dirname(file)


def verify_csi_rs_and_rim_rs_are_not_send_on_the_same_slot(pattern_csirs='DlData_CsiRsSendReq',
                                                           pattern_rimrs='DlData_RimRsSendReq'):
    # [PRIVATE] :
    resultDir = BuiltIn().run_keyword("Get Testcase Log Directory")
    # => for testing purpose
    # resultDir = "/home/ute/csamson"
    filePathName = resultDir + "/msg_dldata_rimrssendreq_pcap.csv"
    BuiltIn().log("verify_csi_rs_and_rim_rs_are_not_send_on_the_same_slot(CB0011028): filePathName = %s" %
                  filePathName, logLevel)
    tcResult = "failed"
    rimrs_slot_sfn_pairs = set()
    csirs_slot_sfn_pairs = set()
    try:
        if os.path.isfile(filePathName):
            text = "verify_csi_rs_and_rim_rs_are_not_send_on_the_same_slot(CB0011028): file OK = %s "
            BuiltIn().log(text % filePathName)
            with open(filePathName, "r") as csvFile:
                lineNumber = 0
                text = "verify_csi_rs_and_rim_rs_are_not_send_on_the_same_slot(CB0011028): open file OK = %s "
                BuiltIn().log(text % filePathName)
                for line in csvFile:
                    lineNumber += 1
                    text = "verify_csi_rs_and_rim_rs_are_not_send_on_the_same_slot(CB0011028): line content = %s %s"
                    # BuiltIn().log(text % (line, lineNumber))
                    pattern_to_find = pattern_rimrs + ";"
                    if pattern_to_find in line:
                        text = "line content = %s lineNumber = %s pattern_to_find = %s"
                        BuiltIn().log(text % (line, lineNumber, pattern_to_find))
                        string_split = line.split(';')
                        info = string_split[0]
                        slot_num = int(string_split[1])
                        sfn_num = int(string_split[2])
                        rimrs_slot_sfn_pairs.add((slot_num, sfn_num))
                    pattern_to_find = pattern_csirs + ";"
                    if pattern_to_find in line:
                        text = "line content = %s lineNumber = %s pattern_to_find = %s"
                        # BuiltIn().log(text % (line, lineNumber, pattern_to_find))
                        string_split = line.split(';')
                        info = string_split[0]
                        slot_num = int(string_split[1])
                        sfn_num = int(string_split[2])
                        csirs_slot_sfn_pairs.add((slot_num, sfn_num))
                if len(rimrs_slot_sfn_pairs) == 0:
                    raise Exception('Check failed, RIMRS not present in traces '
                                    'rimrs_slot_sfn_pairs {}'.format(rimrs_slot_sfn_pairs))
                text = "rimrs_slot_sfn_pairs = %s"
                BuiltIn().log(text % rimrs_slot_sfn_pairs)
                common_pairs = rimrs_slot_sfn_pairs & csirs_slot_sfn_pairs
                if common_pairs:
                    raise Exception('Check failed, RIMRS and CSIRS should not occur in the same slot and SFN: '
                                    'slot/sfn pairs {}'.format(common_pairs))
                else:
                    print('Check passed, RIMRS and CSIRS do not occur in the same slot and SFN.')
                    tcResult = "passed"
    except Exception as e:
        logException("verify_csi_rs_and_rim_rs_are_not_send_on_the_same_slot", e)
    return tcResult


def get_rimrs_num_and_start_prbs_v1(pattern_rimrs):
    start_prb = []
    num_prb = []
    resultDir = BuiltIn().run_keyword("Get Testcase Log Directory")
    # => for testing purpose
    # resultDir = "/home/ute/csamson"
    filePathName = resultDir + "/msg_dldata_rimrssendreq_pcap.csv"
    BuiltIn().log("get_rimrs_num_and_start_prbs(CB0011028): filePathName = %s" %
                  filePathName, logLevel)
    try:
        if os.path.isfile(filePathName):
            text = "get_rimrs_num_and_start_prbs(CB0011028): file OK = %s "
            BuiltIn().log(text % filePathName)
            with open(filePathName, "r") as csvFile:
                lineNumber = 0
                text = "get_rimrs_num_and_start_prbs(CB0011028): open file OK = %s "
                BuiltIn().log(text % filePathName)
                for line in csvFile:
                    lineNumber += 1
                    text = "get_rimrs_num_and_start_prbs(CB0011028): line content = %s %s"
                    BuiltIn().log(text % (line, lineNumber))
                    pattern_to_find = pattern_rimrs + ";"
                    if pattern_to_find in line:
                        text = "line content = %s lineNumber = %s pattern_to_find = %s"
                        BuiltIn().log(text % (line, lineNumber, pattern_to_find))
                        string_split = line.split(';')
                        info = string_split[0]
                        startPrb = int(string_split[4])
                        numOfPrb = int(string_split[5])
                        start_prb.append(int(startPrb))
                        num_prb.append(int(numOfPrb))
    except Exception as e:
        logException("get_rimrs_num_and_start_prbs", e)
    return zip(start_prb, num_prb)


def verify_rimrs_num_and_start_prbs_v1(pattern_rimrs):
    expected_values = [(0, 48)]
    tcResult = "failed"
    actual_values = list(get_rimrs_num_and_start_prbs_v1(pattern_rimrs))
    if all(actual == expected for actual, expected in zip(actual_values, expected_values)):
        print("Check passed, StartRBforRS: \n1.startPrb: 0, numOfPrb: 48")
        tcResult = "passed"
    else:
        raise Exception("Check failed, incorrect StartRBforRS")
    return tcResult


def get_rimrs_num_and_start_prbs(pattern_rimrs, subcellId):
    start_prb = []
    num_prb = []
    resultDir = BuiltIn().run_keyword("Get Testcase Log Directory")
    # => for testing purpose
    # resultDir = "/home/ute/csamson"
    filePathName = resultDir + "/msg_dldata_rimrssendreq_pcap.csv"
    BuiltIn().log("get_rimrs_num_and_start_prbs(CB0011028): filePathName = %s" %
                  filePathName, logLevel)
    try:
        if os.path.isfile(filePathName):
            text = "get_rimrs_num_and_start_prbs(CB0011028): file OK = %s "
            BuiltIn().log(text % filePathName)
            with open(filePathName, "r") as csvFile:
                lineNumber = 0
                text = "get_rimrs_num_and_start_prbs(CB0011028): open file OK = %s "
                BuiltIn().log(text % filePathName)
                for line in csvFile:
                    lineNumber += 1
                    text = "get_rimrs_num_and_start_prbs(CB0011028): line content = %s %s"
                    # BuiltIn().log(text % (line, lineNumber))
                    pattern_to_find = pattern_rimrs + ";"
                    if pattern_to_find in line:
                        text = "line content = %s lineNumber = %s pattern_to_find = %s"
                        # BuiltIn().log(text % (line, lineNumber, pattern_to_find))
                        string_split = line.split(';')
                        info = string_split[0]
                        subCell = int(string_split[3])
                        startPrb = int(string_split[4])
                        numOfPrb = int(string_split[5])
                        if subCell == int(subcellId):
                            start_prb.append(int(startPrb))
                            num_prb.append(int(numOfPrb))
    except Exception as e:
        logException("get_rimrs_num_and_start_prbs", e)
    text = "get_rimrs_num_and_start_prbs(CB0011028): num_prb = %s"
    BuiltIn().log(text % num_prb)
    return zip(start_prb, num_prb)


def verify_rimrs_num_and_start_prbs(pattern_rimrs, subcellId, expected_values_startPrb, expected_values_numOfPrb):
    # expected_values = [(0, 48)]
    expected_values = [(int(expected_values_startPrb), int(expected_values_numOfPrb))]
    tcResult = "failed"
    actual_values = list(get_rimrs_num_and_start_prbs(pattern_rimrs, subcellId))
    if len(expected_values_startPrb) == 0:
        raise Exception("Check failed, expected_values_startPrb list empty")
        tcResult = "failed"
    if all(actual == expected for actual, expected in zip(actual_values, expected_values)):
        text = "Check passed, StartRBforRS: \n1.startPrb: %s, numOfPrb: %s"
        # print("Check passed, StartRBforRS: \n1.startPrb: 0, numOfPrb: 48")
        print(text % (expected_values_startPrb, expected_values_numOfPrb))
        tcResult = "passed"
    else:
        raise Exception("Check failed, incorrect StartRBforRS")
    return tcResult


def verify_fdsched_nbrprb_not_exceed_dlallocatedpooledresourcesdata_numalloccellprbDl(physcellid):
    tcResult = "passed"
    resultDir = BuiltIn().run_keyword("Get Testcase Log Directory")
    # => for testing purpose
    # resultDir = "/home/ute/csamson/TRACES"
    filePathName = resultDir + "/dl_df_for_manual_analysis_all_subcells_FdSched.csv"
    BuiltIn().log("fdsched_nbrprb_not_exceed_numalloccellprbDl: filePathName = %s" %
                  filePathName, logLevel)
    try:
        if os.path.isfile(filePathName):
            text = "fdsched_nbrprb_not_exceed_numalloccellprbDl: file OK = %s "
            BuiltIn().log(text % filePathName)
            with open(filePathName, "r") as csvFile:
                lineNumber = 0
                text = "fdsched_nbrprb_not_exceed_numalloccellprbDl: open file OK = %s "
                BuiltIn().log(text % filePathName)
                for line in csvFile:
                    lineNumber += 1
                    text = "fdsched_nbrprb_not_exceed_numalloccellprbDl: line content = %s %s"
                    # BuiltIn().log(text % (line, lineNumber))
                    if lineNumber == 1:
                        continue
                    string_split = line.split(';')
                    info = string_split[0]
                    physCellId_e = int(string_split[6])
                    text = "physCellId_e = %s %s"
                    # BuiltIn().log(text % (physCellId_e, lineNumber))
                    string_split = line.split(';')
                    dlAllocatedPooledResourcesData_numAllocCellPrbDl = int(string_split[7])
                    dlFdSchedData_numOfPrb = int(string_split[9])
                    if physCellId_e == int(physcellid):
                        if dlAllocatedPooledResourcesData_numAllocCellPrbDl != 0:
                            numAllocCellPrbDl_to_check = dlAllocatedPooledResourcesData_numAllocCellPrbDl
                            text = "numAllocCellPrbDl_to_check= %s"
                            BuiltIn().log(text % numAllocCellPrbDl_to_check)
                        else:
                            numAllocCellPrbDl_to_check = 0
                        if numAllocCellPrbDl_to_check != 0 and dlFdSchedData_numOfPrb > numAllocCellPrbDl_to_check:
                            tcResult = "failed"
                            text = "incorrect dlFdSchedData_numOfPrb = %s numAllocCellPrbDl_to_check=%s lineNumber=%s"
                            BuiltIn().log(text % (dlFdSchedData_numOfPrb, numAllocCellPrbDl_to_check, lineNumber))
                            raise Exception("Check failed, incorrect dlFdSchedData_numOfPrb")
    except Exception as e:
        logException("verify_fdsched_nbrprb_not_exceed_dlallocatedpooledresourcesdata_numalloccellprbDl", e)
    return tcResult


def find_column_number(CsvName="",
                       Column_name="numberOfPrbRimRs"):
    column_number = 0
    lineNumber = 0
    resultDir = BuiltIn().get_variable_value('${sherpa_output_path}') + "/tcpdump/"
    # => for testing purpose
    # resultDir = "/home/ute/csamson/TRACES/"
    filePathName = resultDir + CsvName
    BuiltIn().log("find_column_number: filePathName = %s" %
                  filePathName, logLevel)
    try:
        if os.path.isfile(filePathName):
            text = "find_column_number: file OK = %s "
            BuiltIn().log(text % filePathName)
            with open(filePathName, "r") as csvFile:
                text = "find_column_number: open file OK = %s "
                BuiltIn().log(text % filePathName)
                for line in csvFile:
                    lineNumber += 1
                    # first line is with column name !!!
                    string_split = line.split(';')
                    for column_name in string_split:
                        if column_name == Column_name:
                            break
                        column_number += 1
                    if lineNumber == 1:
                        break
    except Exception as e:
        logException("find_column_number", e)
    text = "find_column_number(CB011028): column name = %s => column_number = %s"
    BuiltIn().log(text % (Column_name, column_number))
    return column_number


def get_rimrs_num_min_prbs(CsvName="",
                           NRCellid='0x4001'):
    tcResult = "passed"
    # Column_name_RIMRS = 'numberOfPrbRimRs' => Column 19
    # Column_name_CellId = 'NRCellid' => Column 11
    # Column_name_NumMinPrbAlloc = 'NumMinPrbAlloc'  => Column 12
    num_min_prb = []
    num_min_prb_no_rim_rs = []
    resultDir = BuiltIn().get_variable_value('${sherpa_output_path}') + "/tcpdump/"
    # => for testing purpose
    # resultDir = "/home/ute/csamson/TRACES/"
    filePathName = resultDir + CsvName
    BuiltIn().log("get_rimrs_num_min_prbs: filePathName = %s" %
                  filePathName, logLevel)
    Column_number_CellId = find_column_number(CsvName=CsvName, Column_name="NRCellid")
    Column_number_NumMinPrbAlloc = find_column_number(CsvName=CsvName, Column_name="NumMinPrbAlloc")
    Column_number_RIMRS = find_column_number(CsvName=CsvName, Column_name="numberOfPrbRimRs")
    BuiltIn().log("Column_name_CellId = NRCellid => Column_number_CellId = %s " %
                  Column_number_CellId, logLevel)
    BuiltIn().log("Column_name_CellId = NumMinPrbAlloc => Column_number_CellId = %s " %
                  Column_number_NumMinPrbAlloc, logLevel)
    BuiltIn().log("Column_name_CellId = numberOfPrbRimRs => Column_number_CellId = %s " %
                  Column_number_RIMRS, logLevel)
    try:
        if os.path.isfile(filePathName):
            text = "get_rimrs_num_min_prbs: file OK = %s "
            BuiltIn().log(text % filePathName)
            with open(filePathName, "r") as csvFile:
                lineNumber = 0
                text = "get_rimrs_num_min_prbs: open file OK = %s "
                BuiltIn().log(text % filePathName)
                for line in csvFile:
                    lineNumber += 1
                    text = "get_rimrs_num_min_prbs: line content = %s %s"
                    # BuiltIn().log(text % (line, lineNumber))
                    if lineNumber == 1:
                        continue
                    string_split = line.split(';')
                    info = string_split[0]
                    NRCellid_e = string_split[Column_number_CellId]
                    NumMinPrbAlloc_e = int(string_split[Column_number_NumMinPrbAlloc])
                    numberOfPrbRimRs_e = string_split[Column_number_RIMRS]
                    text = "NRCellid_e = %s %s"
                    # BuiltIn().log(text % (NRCellid_e, lineNumber))
                    if NRCellid_e == NRCellid:
                        if numberOfPrbRimRs_e != 'No RIM-RS':
                            num_min_prb.append(int(NumMinPrbAlloc_e))
                            # text = "numAllocCellPrbDl_to_check= %s"
                            # BuiltIn().log(text % numAllocCellPrbDl_to_check)
                        else:
                            num_min_prb_no_rim_rs.append(int(NumMinPrbAlloc_e))
    except Exception as e:
        logException("get_rimrs_num_min_prbs", e)
    text = "get_rimrs_num_min_prbs(CB011028): num_min_prb = %s"
    BuiltIn().log(text % num_min_prb)
    return num_min_prb, num_min_prb_no_rim_rs


def verify_numminprb_for_cellid_where_rim_rs_is_present_in_csv_File(CsvName="",
                                                                    NRCellid='0x4001',
                                                                    expected_values_rim_rs=48,
                                                                    expected_values_no_rim_rs=48):
    expected_values = int(expected_values_rim_rs)
    expected_values_num_min_prb_no_rim_rs = int(expected_values_no_rim_rs)
    tcResult = "failed"
    actual_values, actual_values_num_min_prb_no_rim_rs = list(get_rimrs_num_min_prbs(CsvName, NRCellid))
    BuiltIn().log("actual_values = %s expected_values = %s" % (actual_values, expected_values))
    if len(list([expected_values])) == 0 or len(actual_values) == 0:
        tcResult = "failed"
        raise Exception("Check numMinOfPrb rimrs slot failed, expected_values or actual_values list empty")
    if all(actual == expected_values for actual in actual_values):
        text = "Check passed, numminprb rimrs slot expected_values: %s actual_values: %s Cell %s"
        BuiltIn().log(text % (expected_values, actual_values, NRCellid))
        tcResult = "passed"
    else:
        tcResult = "failed"
        text = "Check failed, expected_values: %s actual_values: %s"
        BuiltIn().log(text % (expected_values, actual_values))
        raise Exception("Check failed, incorrect NUMMINPRBALLOC rimrs slot")
    if all(actual == expected_values_num_min_prb_no_rim_rs for actual in actual_values_num_min_prb_no_rim_rs):
        text = "Check passed, numminprb no rimrs slot expected_values: %s actual_values: %s Cell %s"
        BuiltIn().log(text % (expected_values_num_min_prb_no_rim_rs, actual_values_num_min_prb_no_rim_rs,
                              NRCellid))
        tcResult = "passed"
    else:
        tcResult = "failed"
        text = "Check failed, expected_values num_min_prb_no_rim_rs: %s actual_values num_min_prb_no_rim_rs: %s"
        BuiltIn().log(text % (expected_values_num_min_prb_no_rim_rs, actual_values_num_min_prb_no_rim_rs))
        raise Exception("Check failed, incorrect NUMMINPRBALLOC no rimrs slot")
    return tcResult


def return_python_version():
    pythonVersion = str(sys.version).replace("\n", " ")
    return pythonVersion


def return_python_interpreter_path():
    pythonVersion = str(sys.executable).replace("\n", " ")
    return pythonVersion


def return_python_virtualenv_path():
    pythonVersion = str(sys.prefix).replace("\n", " ")
    return pythonVersion


def get_specified_column_from_csv_file(filename, linename):
    """This creates a keyword named "Read a column from CSV File"

    This keyword takes 2 arguments, which are a path to a .csv file and list name. It
    returns a list of column and remove empty string.
    """
    with io.open(filename, 'rt', encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        row_dict = dict()
        for row in reader:
            if row[linename] != '':
                row_dict.setdefault(linename, []).append(row[linename])
        print(row_dict)
    return row_dict


def get_specified_column_from_csv_file_for_rnti(filename, linename, pattern='rnti'):
    """This creates a keyword named "Read a column from CSV File"

    This keyword takes 2 arguments, which are a path to a .csv file and list name. It
    returns a list of column and remove empty string.
    """
    with io.open(filename, 'rt', encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        row_dict = dict()
        for row in reader:
            if row[pattern] != '0' and row[pattern] != '65535' and row[linename] != '':
                row_dict.setdefault(row[pattern], []).append(row[linename])
        print(row_dict)
    return row_dict


def get_rnti_from_csv_file(filename, pattern='rnti', exclude_first_samples=True):
    """This creates a keyword named "get_rnti_from_csv_file"

    This keyword takes 1 argument, which are a path to a .csv file. It
    returns a list of rnti.
    """
    with io.open(filename, 'rt', encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile,  delimiter=';')
        # logging.info("get_rnti_from_csv_file: reader = %s" % (reader))
        # for row in reader:
        #     logging.info("get_rnti_from_csv_file: row = %s" % row)
        column = [row[pattern] for row in reader]
        column_rnti = set(column)
        if '0' in column_rnti:
            column_rnti.remove('0')
        if '65535' in column_rnti:
            column_rnti.remove('65535')
    for i in column_rnti.copy():
        count_result = column.count(i)
        if count_result < 20 and exclude_first_samples:
            column_rnti.remove(i)
    return list(column_rnti)


def get_cell_from_csv_file(filename, pattern='cell'):
    """This creates a keyword named "get_cell_from_csv_file"

    This keyword takes 1 argument, which are a path to a .csv file. It
    returns a list of rnti.
    """
    with io.open(filename, 'rt', encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile,  delimiter=';')
        # logging.info("get_cell_from_csv_file: reader = %s" % (reader))
        # for row in reader:
        #     logging.info("get_cell_from_csv_file: row = %s" % row)
        column = [row[pattern] for row in reader]
        column_rnti = set(column)
        # logging.info("get_cell_from_csv_file: column_rnti = %s" % column_rnti)
    return list(column_rnti)


def val_to_bool(val):
    try:
        return re.sub(r'\$|\{|\}', '', str(val).lower().strip()) == "true"
    except Exception:
        return False


def file_exists(file):
    logger.info("Checking if file exists : {} : Result is {}".format(file, os.path.isfile(file)), also_console=True)
    return os.path.isfile(file)


def all_equal(lst):
    return not lst or [lst[0]]*len(lst) == lst


# using regex
def filter_non_printable(string):
    string_f = re.sub("[^A-Z_a-z0-9]", "", string.lower().strip())
    return string_f


def filter_non_printable_and_remove_head(string):
    result = []
    for c in string:
        result.append(c)
    ws_last = False
    for c in string:
        if ws_last:
            result.append(c)
        if c == ']':
            result = []
            ws_last = True
    string_f = ''.join(result).replace(' ', '_')
    string_f = re.sub("[^A-Z_a-z0-9]", "", string_f.strip())
    return string_f


def convert_xml_2_json(xml_path, json_outpath=None):
    xml_file = open(xml_path, 'r')
    xml_str = xml_file.read()
    json_dict = xmltodict.parse(xml_str)
    with open(json_outpath, 'w') as f:
        json.dump(json_dict, f)
    return json_dict


def get_pdcch_profiles(scf_xml_path, distName, json_outpath):
    pdcch_resources = []
    with open(scf_xml_path, 'r') as xml_file:
        xml_tree = BeautifulSoup(xml_file, 'xml')
        # logger.info("xml_tree : {}".format(xml_tree), also_console=True)
        # for child in xml_tree.descendants:
        #    if child.name:
        #        print(child.name)
        pdcch_resources = xml_tree.find_all('managedObject',
                                            attrs={'distName': distName})
        if not pdcch_resources:
            return
        # logger.info("pdcch_resources : {}".format(pdcch_resources[0]), also_console=True)
        json_dict = xmltodict.parse(str(pdcch_resources[0]))
        with open(json_outpath, 'w') as f:
            json.dump(json_dict, f, indent=2, separators=(". ", " = "))


def verify_nr_stats_traffic(avg_data_rate, trf_rate, ue_id, direction):
    if trf_rate * 0.8 < avg_data_rate < trf_rate * 1.2:
        logging.info('UeId{} Avg {} data traffic rate occurred as expected - equals to {} '.format(ue_id,
                                                                                                   direction,
                                                                                                   avg_data_rate))
    else:
        raise AssertionError('UeId{} Unexpected {} avg data traffic rate - equals to {} '.format(ue_id,
                                                                                                 direction,
                                                                                                 avg_data_rate))


def return_rbgsize_pdsch(chBW=273, ConfigType=1):
    config_1 = {2: [1, 36], 4: [37, 72], 8: [73, 144], 16: [145, 275]}
    config_2 = {4: [1, 36], 8: [37, 72], 16: [73, 275]}
    # chBW_int = int(chBW)
    # ConfigType_int = int(ConfigType)
    rbgsize = 0
    if ConfigType == 1:
        for key in config_1:
            if config_1[key][0] <= chBW <= config_1[key][1]:
                rbgsize = key
    elif ConfigType == 2:
        for key in config_2:
            if config_2[key][0] <= chBW <= config_2[key][1]:
                rbgsize = key
    latest_rbgsize = chBW % rbgsize
    return rbgsize, latest_rbgsize


def cal_num_of_rgb(chBW, ConfigType):
    config_1 = {2: [1, 36], 4: [37, 72], 8: [73, 144], 16: [145, 275]}
    config_2 = {4: [1, 36], 8: [37, 72], 16: [73, 275]}
    # chBW_int = int(chBW)
    # ConfigType_int = int(ConfigType)
    rbgsize = 0
    if ConfigType == 1:
        for key in config_1:
            if config_1[key][0] <= chBW <= config_1[key][1]:
                rbgsize = key
    elif ConfigType == 2:
        for key in config_2:
            if config_2[key][0] <= chBW <= config_2[key][1]:
                rbgsize = key
    rat0bitmap = [rbgsize for i in range(chBW//rbgsize)]
    rat0bitmap.append(chBW % rbgsize)
    rat0bitmap_full = rat0bitmap
    msg = '=====> Full NbrRBG'
    # logging.info('=====> Full NbrRBG = {}'.format(len(rat0bitmap_full)))
    return rat0bitmap_full


def binary_ratObitmap_from_pcap(num, length=8):
    return "{:032b}".format(num)[:length]


def binary_ratObitmap_from_ttiTraces(num, length=8):
    return "{:018b}".format(num)[:length]


def check_rgbs_set(rat0bitmap, chbw_prb, filetype='pcap', w_debug=False):
    if w_debug:
        logging.info("Finding rbgs for rat0bitmap={} ==> chbw_prb={}".format(rat0bitmap, chbw_prb))
    rbg_size, latest_rbgsize = return_rbgsize_pdsch(chBW=chbw_prb)
    num_rbgs = int(chbw_prb / rbg_size)
    if chbw_prb % rbg_size != 0:
        num_rbgs += 1
    if w_debug:
        logging.info("num_rbgs = {}".format(num_rbgs))
    rbg_ids = []
    cnt = 0
    bit = pow(2, (num_rbgs - 1))
    if filetype == 'pcap':
        rat0bitmap_b = binary_ratObitmap_from_pcap(rat0bitmap, num_rbgs)
    else:
        rat0bitmap_b = binary_ratObitmap_from_ttiTraces(rat0bitmap, num_rbgs)
    # logging.info("rat0bitmap_b = {} and len = {}".format(rat0bitmap_b, len(rat0bitmap_b)))
    rat0bitmap_int = int(rat0bitmap_b, 2)
    for i in range(0, num_rbgs):
        if bit & rat0bitmap_int:
            rbg_ids.append(cnt)
        cnt += 1
        # logging.info("bit = {} cnt = {} rat0bitmap_b = {}".format(str(bin(bit)), cnt, bin(rat0bitmap_int)))
        rat0bitmap_int <<= 1
    logging.info("Allocated rbgs Id {} from rgb bitmap".format(rbg_ids))
    return rbg_ids


def check_rgbs_set_PS_bwp_15rbg(rat0bitmap, chbw_prb):
    logging.info("Finding rbgs for rat0bitmap={} ==> chbw_prb={}".format(rat0bitmap, chbw_prb))
    rbg_size, latest_rbgsize = return_rbgsize_pdsch(chBW=chbw_prb)
    num_rbgs = int(chbw_prb / rbg_size)
    if chbw_prb % rbg_size != 0:
        num_rbgs += 2
    logging.info("num_rbgs = {}".format(num_rbgs))
    rbg_ids = []
    cnt = 0
    bit = pow(2, (num_rbgs - 1))
    rat0bitmap_b = binary_ratObitmap_from_pcap(rat0bitmap, num_rbgs)
    logging.info("rat0bitmap_b = {} and len = {}".format(rat0bitmap_b, len(rat0bitmap_b)))
    rat0bitmap_int = int(rat0bitmap_b, 2)
    for i in range(0, num_rbgs):
        if bit & rat0bitmap_int:
            rbg_ids.append(cnt)
        cnt += 1
        # logging.info("bit = {} cnt = {} rat0bitmap_b = {}".format(str(bin(bit)), cnt, bin(rat0bitmap_int)))
        rat0bitmap_int <<= 1
    logging.info("Allocated rbgs Id {} from rgb bitmap".format(rbg_ids))
    return rbg_ids


def FnGetNrCellCounter(countersData, MRBTS, NRBTS, NRCELL, Meas, counterList, measPeriod):
    """
       Extracts NR cell counters from the provided countersData.
        use of :
        ${countersData}  coam.get_counters_info  connection=coam_admin  timeout=3min   dist_name=BTS/${mrbts}/${nrbts}
       :param countersData: A dictionary containing counters data.
       :param MRBTS: MRBTS identifier (MRBTS-1 for ex).
       :param NRBTS: NRBTS identifier (NRBTS-1 for ex).
       :param NRCELL: List of NRCELL identifiers.
       :param Meas: Measurement type (e.g., NCELA for ex).
       :param counterList: List of counter identifiers.
       :param measPeriod: Measurement TimeStamp
       :return: A dictionary with NR cell IDs as keys and counter values as values.
    """
    extract = {}
    for cellId in NRCELL:
        nrCellId = "NRCELL-" + str(cellId)
        extract[nrCellId] = {}
        for counterId in counterList:
            extract[nrCellId][counterId] = countersData['BTS'][MRBTS][NRBTS][nrCellId][Meas][counterId][measPeriod]
    return extract


@log_begin_end_func_name
def fetch_rnti_from(egate_output_str):
    """
    This function takes a string containing something like 'crnti: 18350 = 0x47AE' and
    returns just '18350'.
    """
    rnti_intemediate_str = re.findall(r'\(crnti:.*\)', egate_output_str)
    rnti_final_str = re.findall(r'\d+', rnti_intemediate_str[0]) if rnti_intemediate_str else []
    return rnti_final_str[0] if rnti_final_str else '0'


@log_begin_end_func_name
def fetch_rnti_nsa_from(egate_output_str):
    """
    This function takes a string containing something like 'newUE-Identity 14198,' and
    returns just '14198'.
    """
    rnti_intemediate_str = re.findall(r'newUE-Identity.*,', egate_output_str)
    rnti_final_str = re.findall(r'\d+', rnti_intemediate_str[0]) if rnti_intemediate_str else []
    return rnti_final_str[0] if rnti_final_str else '0'


def get_reservation_details():
    with open('/opt/ute/reservation.context.json', 'r') as json_file:
        json_content = json.load(json_file)
    return json_content


def get_phy_cell_ids(cell_info):
    cell_info = [cell for cell in cell_info['cells']['nr']]
    cell_mapping = {}
    pattern_cell_id = re.compile(r'NRCELL-(\d+)')
    for item in cell_info:
        cell_id_obj = pattern_cell_id.search(
            item.get('id').get('configuration'))
        cell_id = cell_id_obj.groups()[0]
        cell_mapping["NRCELL-"+cell_id] = item.get('physicalCellId')
    return cell_mapping


def get_current_time():
    return datetime.datetime.now()


def get_elapsed_time(start_time, end_time):
    return (end_time - start_time).total_seconds()


@log_begin_end_func_name
def identify_pm_counter_index_offset(defined_pm_interval, elapsed_time_in_interval):
    exp = re.findall(r'\d+', defined_pm_interval)
    try:
        interval_in_sec = int(exp[0])*60
    except IndexError:
        logging.error("Verify if PM Counter interval is defined correctly | Expected format <>min")
    factor = int(elapsed_time_in_interval / interval_in_sec)
    return factor


@log_begin_end_func_name
def post_process_pmc_indices(collector_dict, dir_path, max_scenario_pm_index):  # scenarios, pm_index, pm_offset
    pm_offset_per_scenario = {}
    default_pm_index_per_scenario = {}
    scenarios = list(collector_dict.keys())
    for scenario_id in range(0, len(collector_dict)):
        try:
            default_pm_index = (max_scenario_pm_index - 1) - (collector_dict[scenarios[scenario_id]]['pm_index'])
            default_pm_index_per_scenario[default_pm_index] = scenario_id
            print(default_pm_index_per_scenario)
        except KeyError:
            logging.warn("PM Offset not calculated for scenario : %s " % scenarios[scenario_id])
    pm_offset_per_scenario[scenarios[default_pm_index_per_scenario[0]]] = 0
    for scenario_index in range(1, max_scenario_pm_index):
        total_offset = 0
        for offset in range(scenario_index):
            total_offset += collector_dict[scenarios[default_pm_index_per_scenario[offset]]]['pm_offset']
        pm_offset_per_scenario[scenarios[default_pm_index_per_scenario[scenario_index]]] = scenario_index \
            + total_offset
    write_dictionary_to_json(dir_path, pm_offset_per_scenario, filename='pm_counter_offsets.json')


@log_begin_end_func_name
def get_pmc_index(scenario, pm_offset_path):
    """ Returns the PM Counter Index, last executed scenario has index 0.
    For e.g. 2nd scenario in the test configuration has index total num of scenarios - index of 2nd scenario
    The Index is then adjusted by the calculated offset"""
    try:
        with open(pm_offset_path) as json_file:
            pm_offsets = json.load(json_file)
        return pm_offsets[scenario]
    except KeyError:
        logging.error("Invalid Scenario Name")
        return 0
    except FileNotFoundError:
        logging.error("pm_counter_offsets file not found")
        return 0


def get_nidd_file_name_path():
    """
    Returns the full path to the NIDD file of PM Counters stored in the Repository.
    """
    nidd_file_name_path = "/tmp/NIDD.xml"
    try:  # to construct NIDD file and save it to /tmp
        nidd_dir = os.path.abspath(os.path.join(
            os.path.dirname(__file__), '..', 'NIDD'))
        os.chdir(nidd_dir)
        os.system("cat Counters*.xml > %s" % nidd_file_name_path)
    except Exception as e:
        pass
    return nidd_file_name_path


############################################################
#   testline procedure
############################################################


def get_sysinfo(connection, capu_id=None):
    """
    Get the sysinfo lines filtered with ID_00_MODULE_ID_ for later determination of
    the type of the system module
    :param connection: The alias of the ssh connection
    :param capu_id: The id of the capacity unit. If None, the sysinfo of the main unit is fetched.
    """
    if capu_id is not None:
        command = 'echo "timeout 0.1 sysinfo | grep ID_00_MODULE_ID_" | bsh {}:0'.format(
            capu_id+1)
    else:
        command = 'timeout 1 sysinfo | grep ID_00_MODULE_ID_'
    result = ssh().execute(command=command, connection=connection, timeout='60 s')
    return result


def identify_module(connection, capu_id=None):
    """
    Identify the module type (ASIB, ASIL, ASOE, ...)
    :param connection: The alias or connection object of the taf.config.ssh connection
    :param capu_id: The id of the capacity unit. If None, the module tpye of the main unit is identified.
    """
    sysinfo_extract = get_sysinfo(connection, capu_id)
    pattern = re.compile(r'ID_00_MODULE_ID_\[(\d)\]=.(A[BS][IO][BEHKLMNOP])')
    matches = pattern.search(sysinfo_extract)
    print(f"sysinfo_extract: {sysinfo_extract}")

    try:
        if matches:
            modules_detected = matches.groups()[1]
            return modules_detected
    except AttributeError:
        pass

    logging.warning("identify_module: Unable to identify system module")


def extract_ip(text):
    lines = text.splitlines()
    pattern = re.compile(r'(inet\s|inet\saddr:)(\d+\.\d+\.\d+\.\d+)')
    for line in lines:
        matches = (pattern.search(line))
        try:
            ip = matches.groups()[-1]
            return ip
        except AttributeError:
            pass


def is_realenb(obj):
    return isinstance(obj, RealEnb)


def identify_node_id(output):
    """return nodeid from output of ps -ef | grep CCS_RT"""
    pattern = re.compile(r'nid=(\S{3,})')
    if pattern.search(output):
        return str(int(pattern.search(output).groups()[0], 16))
    pattern = re.compile(r'-n\s(\S{3, })')
    return str(int(pattern.search(output).groups()[0], 16))


def is_valid_ipv4(ip_address):
    return valid_ipv4(ip_address)


def is_valid_ipv6(ip_address):
    return valid_ipv6(ip_address)


def is_valid_ip(ip_address):
    return (valid_ipv4(ip_address) or valid_ipv6(ip_address))


def should_be_valid_ip(ip_address):
    assert is_valid_ip(ip_address), "Error, this isn't a valid IP address: {!r} !".format(ip_address)


def get_directory(file_path):
    """ Returns a path without a fie name
        Args:
            file_path (str): full path to any file
        Returns:
            str: a path without a file name
    """
    split_path = file_path.split('/')
    return "/".join(split_path[:-1])


def get_file_path(relative_path, absolute_path=''):
    if absolute_path:
        absolute_path_to_file = absolute_path
    else:
        print(f"I am here : {os.path.dirname(__file__)}")
        combined_paths = os.path.dirname(__file__) + relative_path
        absolute_path_to_file = str(os.path.abspath(combined_paths))
        print(f"absolute_path_to_file : {absolute_path_to_file}")
    return absolute_path_to_file


def get_distNames_from_scf(regex, scf_content):
    logging.debug(
        "============================== Begin get_distNames_from_scf()")
    distNames = re.findall(regex, scf_content)
    distNames = list(set(distNames))
    logging.debug(
        "============================== End get_distNames_from_scf()")
    return distNames


def extract_session_from_egateconsole(egateconsoleextract):
    """
    Analyzing this kind of trace:
    [session
    :param egateconsoleextract:
    :return:  cmd
    """
    # cmd = re.findall(r"*.[session .(\d*).].(.*)", egateconsoleextract)
    cmd = re.findall(r"]:.(.*)", egateconsoleextract)
    print(cmd)
    return cmd


def get_all_parameters_from_bearer_stats_output(output, mode="legacy"):
    ue_dict = {}
    output_array = output.splitlines()
    for line_content in output_array:
        line_content = line_content.encode().decode('unicode_escape')
        if "UE" in line_content:
            current_ue_id = re.search(
                pattern="UE [0-9]{0,3}", string=line_content).group().replace(" ", "_")
            current_direction = re.search(pattern="[U,D]L L3 stats",
                                          string=line_content).group().replace(" L3 stats", "")
            ue_dict.setdefault(current_ue_id, {"UL": {}, "DL": {}})
            ue_dict.setdefault(
                "timestamp", datetime.datetime.utcnow().strftime("%d.%m.%Y %H:%M:%S.%f"))
        characters_to_exclude = ["-", "=", "Parameter", "UE"]
        if all(char not in line_content for char in characters_to_exclude):
            data_object = re.split(r'\s(?=\d)', line_content)
            if len(data_object) == 2:
                # remove the data in Brackets.
                data_object[1] = re.sub(
                    r"\([^()]*\)|\[[^\[\]]*\]", "", data_object[1])
                parameter_name, parameter_value = data_object[0].rstrip(
                ), data_object[1].rstrip()
                parameter_name = parameter_name.encode(
                ).decode().replace("[K", "")
                parameter_name = " ".join(re.findall(
                    r"\w+", parameter_name)).rstrip()
                try:
                    ue_dict[current_ue_id][current_direction].update(
                        {parameter_name: int(parameter_value)})
                except ValueError:
                    ue_dict[current_ue_id][current_direction].update(
                        {parameter_name: parameter_value})

    if len(ue_dict) == 0:
        return "No Data Found In Output"
    if mode == "legacy" or mode == "only_average":
        ue_dict_legacy = {}
        for ue_name, ue_content in ue_dict.items():
            if ue_name == "timestamp":
                continue
            ue_dict_legacy.update({ue_name:
                                   {"UL": {
                                    "Average_Throughput": ue_content["UL"]["Average data rate"],
                                    "Current_Throughput": ue_content["UL"]["Last data rate"]},
                                    "DL": {
                                    "Average_Throughput": ue_content["DL"]["Average data rate"],
                                    "Current_Throughput": ue_content["DL"]["Last data rate"]}}})
            ue_dict_legacy.update({"timestamp": ue_dict["timestamp"]})
            if mode == "only_average":
                del ue_dict_legacy[ue_name][current_direction]["Current_Throughput"]
        return ue_dict_legacy
    return ue_dict


def extract_domain_from_rad(rad_id):
    if isinstance(rad_id, int):
        rad_id = hex(rad_id)
    # in the first 2 hex symbols is the domain
    return (str(rad_id))[0:4]


def calculate_ratio_bits_1(sequence):
    total_bits = len(sequence.replace('-', ''))
    total_bits_1 = sequence.count('1')
    ratio = total_bits_1 / total_bits if total_bits != 0 else 0
    return ratio


@log_begin_end_func_name
def get_values_from_targetbd(targetbd_path, radio_name='AHEGHA'):
    tree_targetbd = ETree.parse(targetbd_path)
    logging.info("tree_targetbd = %s" % tree_targetbd)
    root_targetbd = tree_targetbd.getroot()
    logging.info("root_targetbd = %s" % root_targetbd)
    target_bd_values = {}

    desired_element = root_targetbd.find('.//hwResource[@resourceBuildKey="LTX_%s"]' % radio_name)
    logging.info("desired_element = %s" % desired_element)
    target_bd_values['resourceSWVersion'] = desired_element.attrib['resourceSWVersion']
    for grandchild in desired_element:
        if grandchild.tag == 'swFileKey':
            target_bd_values['swFileKey'] = grandchild.text.replace("LTX_%s_" % radio_name, "")
    logging.info("target_bd_values = %s" % target_bd_values)
    return (target_bd_values['resourceSWVersion'], target_bd_values['swFileKey'])


def check_if_json_is_for_test(json_path):
    with open(json_path, 'r') as json_file:
        try:
            json_object = json.load(json_file)
        except json.decoder.JSONDecodeError:
            return False
        try:
            if "test_description" in json_object.keys():
                return True
        except AttributeError:
            logging.info("%s is not a test file", json_file)
            return False


def get_test_json_file_paths(directory):
    test_files = []
    for path in walk(Path(directory)):
        if '.json' in path.name:
            if check_if_json_is_for_test(path):
                test_files.append(path.as_posix())
    return test_files


def walk(path):
    for p in Path(path).iterdir():
        if p.is_dir():
            yield from walk(p)
            continue
        yield p.resolve()


def isL1swLonerIft(sort_release='STBS00'):
    regex = r"^SBTS25R[2-9]|SBTS00$"
    match = re.match(regex, sort_release)
    if match:
        L1swLonerIft = True
    else:
        L1swLonerIft = False
    print(f"l1l2ItfVersion: {L1swLonerIft}")
    return L1swLonerIft


def increment_ip(ip, factor):
    """Author : """
    int_ip = int(struct.unpack('!I', socket.inet_aton(str(ip)))[0])
    new_ip = socket.inet_ntoa(struct.pack('!I', int_ip+int(factor)))
    return new_ip


def get_local_current_time():
    """
    return: the current time
    """
    return time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())


def log_to_console_with_time_prefix(log, level="INFO", color=""):
    current_time = get_local_current_time()
    if len(color) == 0:
        if level.lower() == 'info':
            rbi.log("[ INFO ] %s  %s" % (current_time, log), console="yes")
        else:
            rbi.log("%s  %s" % (current_time, log), level=level)
    else:
        if color == "yellow" and level.lower() == 'info':
            rbi.log("[ \033[0;33;40mINFO\033[0m ] %s %s" % (current_time, log), console="yes")
        else:
            rbi.log("%s  %s" % (current_time, log), level=level)


def extract_dll1sp_from_COAM(cellinfo, sp):
    #  subCellList=['Subcell-0 (DL)', 'Subcell-0 (UL)', 'Subcell-3 (DL)', 'Subcell-3 (UL)','
    #                                                    ' 'Subcell-4 (DL)', 'Subcell-5 (DL)']
    # sp = []
    for element in cellinfo:
        print(element)
        cid2sp = re.findall(r"Subcell-(\d*) \(DL\)", element)
        print(cid2sp)
        if cid2sp:
            sp.append(int(cid2sp[0]))
            sp.sort()
    return sp


def extract_ull1sp_from_COAM(cellinfo, sp):
    #  subCellList=['Subcell-0 (DL)', 'Subcell-0 (UL)', 'Subcell-3 (DL)', 'Subcell-3 (UL)','
    #                                                    ' 'Subcell-4 (DL)', 'Subcell-5 (DL)']
    # sp = []
    for element in cellinfo:
        print(element)
        cid2sp = re.findall(r"Subcell-(\d*) \(UL\)", element)
        print(cid2sp)
        if cid2sp:
            sp.append(int(cid2sp[0]))
            sp.sort()
    return sp


@keyword("Get Topology from Reservation Context File")
def get_topo_from_reservation_file(file_path='/opt/ute/reservation.context.json'):
    """
    Extracts topology and variant information from a reservation JSON file.

    Args:
        file_path (str): Path to the reservation file. Defaults to '/opt/ute/reservation.context.json'.

    Returns:
        tuple: A tuple containing topo_element and variant_element.

    Raises:
        FileNotFoundError: If the reservation file does not exist.
        ValueError: If the required data is missing or invalid.
    """

    # Default file path
    if file_path is None:
        file_path = '/opt/ute/reservation.context.json'

    # Check if the file exists
    if not os.path.exists(file_path):
        logging.error(f"Reservation file '{file_path}' not found. Please check your configuration.")
        raise FileNotFoundError(f"Reservation file '{file_path}' not found.")

    try:
        # Load the JSON file
        with open(file_path, 'r') as file:
            data = json.load(file)
        # Validate and extract CM_TOPOLOGY_NAME and CM_TAGS
        cm_topology_name = data.get("CM_TOPOLOGY_NAME")
        cm_tags = data.get("CM_TAGS", [])
        if not cm_topology_name or len(cm_topology_name) == 0:
            logging.error(f"Invalid or missing 'CM_TOPOLOGY_NAME' in '{file_path}'. Please check your configuration.")
            raise ValueError(f"Invalid or missing 'CM_TOPOLOGY_NAME' in '{file_path}'.")
        if not cm_tags or len(cm_tags) == 0:
            logging.error(f"Invalid or missing 'CM_TAGS' in '{file_path}'. Please check your configuration.")
            raise ValueError(f"Invalid or missing 'CM_TAGS' in '{file_path}'.")
        topo_element = cm_topology_name
        variant_element = None
        for tag in cm_tags:
            if isinstance(tag, str) and tag.startswith("VARIANT"):
                variant_element = tag
        print(f"topo_element = {topo_element}")
        print(f"variant_element = {variant_element}")
        # Validate extracted elements
        if topo_element.startswith("CLOUD") and variant_element.startswith("VARIANT"):
            logging.info(f"Topology '{topo_element}' and variant '{variant_element}' found.")
        else:
            logging.error(f"Invalid topology or variant in '{file_path}'. Please check your configuration.")
            raise ValueError(f"Invalid topology or variant in '{file_path}'.")
    except json.JSONDecodeError as e:
        logging.error(f"Failed to parse JSON from '{file_path}': {e}")
        raise ValueError(f"Failed to parse JSON from '{file_path}': {e}")
    return topo_element, variant_element


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)

    egate_output_str = ""
    fetch_rnti_nsa_from(egate_output_str)

    rbg_ids = check_rgbs_set(rat0bitmap=260046848, chbw_prb=273)
    logging.info("rbg_ids = {}".format(rbg_ids))
    if not rbg_ids:
        logging.error("Allocated rbgs Id from rgb bitmap should not be empty!!!")
    rbg_ids = check_rgbs_set(rat0bitmap=131072, chbw_prb=106)
    logging.info("rbg_ids = {}".format(rbg_ids))
    if not rbg_ids:
        logging.error("Allocated rbgs Id from rgb bitmap should not be empty!!!")
    rbg_ids = check_rgbs_set_PS_bwp_15rbg(rat0bitmap=131072, chbw_prb=106)
    logging.info("rbg_ids = {}".format(rbg_ids))
    if not rbg_ids:
        logging.error("Allocated rbgs Id from rgb bitmap should not be empty!!!")
    rbg_ids = check_rgbs_set(rat0bitmap=2147483648, chbw_prb=106)
    logging.info("rbg_ids = {}".format(rbg_ids))
    if not rbg_ids:
        logging.error("Allocated rbgs Id from rgb bitmap should not be empty")

    # LATEST_FILE_ = '/home/ute/csamson/TRACES/PM/PM.BTS-1.20231125.115000.ANY.xml'
    # BuiltIn().set_test_variable("${LATEST_FILE}", LATEST_FILE_)
    # get_pdu_volume_low_rlc_by_cell_and_qos()

    scf_xml_path = '/home/ute/csamson/TRACES/SCF/SCF_used_for_9915_Tests.xml'
    get_pdcch_profiles(scf_xml_path, distName='MRBTS-1/NRBTS-1/BWP_PROFILE-67',
                       json_outpath='/home/ute/csamson/TRACES/SCF/cell2-BWP_PROFILE-67-bwp-dedicated.json')
    get_pdcch_profiles(scf_xml_path, distName='MRBTS-1/NRBTS-1/BWP_PROFILE-67/PDCCH-1',
                       json_outpath='/home/ute/csamson/TRACES/SCF/cell2-BWP_PROFILE-67-PDCCH-1.json')
    get_pdcch_profiles(scf_xml_path, distName='MRBTS-1/NRBTS-1/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_COMMON-1',
                       json_outpath='/home/ute/csamson/TRACES/SCF/Cell2-BWP_PROFILE-67-searchSpaceCommon.json')
    get_pdcch_profiles(scf_xml_path, distName='MRBTS-1/NRBTS-1/BWP_PROFILE-67/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
                       json_outpath='/home/ute/csamson/TRACES/SCF/Cell2-BWP_PROFILE-67-PDCCH-1_CONFIG_DEDICATED.json')
    get_pdcch_profiles(scf_xml_path, distName='MRBTS-1/NRBTS-1/BWP_PROFILE-67/PDSCH-1',
                       json_outpath='/home/ute/csamson/TRACES/SCF/Cell2-BWP_PROFILE-67-PDSCH-1.json')
    get_pdcch_profiles(scf_xml_path, distName='MRBTS-1/NRBTS-1/BWP_PROFILE-67/PDSCH-1',
                       json_outpath='/home/ute/csamson/TRACES/SCF/Cell2-BWP_PROFILE-67-PDSCH-1.json')

    get_pdcch_profiles(scf_xml_path, distName='MRBTS-1/NRBTS-1/BWP_PROFILE-6',
                       json_outpath='/home/ute/csamson/TRACES/SCF/cell2-BWP_PROFILE-6-bwp-initial.json')
    get_pdcch_profiles(scf_xml_path, distName='MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1',
                       json_outpath='/home/ute/csamson/TRACES/SCF/cell2-BWP_PROFILE-6-PDCCH-1.json')
    get_pdcch_profiles(scf_xml_path, distName='MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_COMMON-1',
                       json_outpath='/home/ute/csamson/TRACES/SCF/Cell2-BWP_PROFILE-6-searchSpaceCommon.json')
    get_pdcch_profiles(scf_xml_path, distName='MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
                       json_outpath='/home/ute/csamson/TRACES/SCF/Cell2-BWP_PROFILE-6-PDCCH-1_CONFIG_DEDICATED.json')
    get_pdcch_profiles(scf_xml_path, distName='MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDSCH-1',
                       json_outpath='/home/ute/csamson/TRACES/SCF/Cell2-BWP_PROFILE-6-PDSCH-1.json')
    get_pdcch_profiles(scf_xml_path, distName='MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDSCH-1',
                       json_outpath='/home/ute/csamson/TRACES/SCF/Cell2-BWP_PROFILE-6-PDSCH-1.json')

    filename = '/home/ute/csamson/TRACES/pcapprocessed_UL_Fragmentation_itf_l2_ps_cell_CellSetupReq_CPRT.csv'
    list_cell = get_cell_from_csv_file(filename=filename, pattern='itf_l2_ps_cell_CellSetupReq_t.physCellId')
    linename = 'itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartSr1Prb'
    longPucchStartSr1Prb =\
        get_specified_column_from_csv_file_for_rnti(filename=filename,
                                                    linename=linename,
                                                    pattern='itf_l2_ps_cell_CellSetupReq_t.physCellId')
    linename = 'itf_l2_ps_cell_ResourceRegionsForPrbFragmentation.longPucchStartSr2Prb'
    longPucchStartSr2Prb =\
        get_specified_column_from_csv_file_for_rnti(filename=filename,
                                                    linename=linename,
                                                    pattern='itf_l2_ps_cell_CellSetupReq_t.physCellId')
    logging.info("get_cell_from_csv_file: list_cell = %s" % (list_cell))

    filename = '/home/ute/csamson/TRACES/dl_dataframe_for_manual_analysis_prblanking_cell1.csv'
    list_rnti = get_rnti_from_csv_file(filename=filename)
    logging.info("get_rnti_from_csv_file: list_rnti = %s" % (list_rnti))
    dlFdSchedData_startPrb = get_specified_column_from_csv_file_for_rnti(filename=filename,
                                                                         linename='dlFdSchedData.startPrb')
    logging.info("get_rnti_from_csv_file: dlFdSchedData_startPrb = %s" % (dlFdSchedData_startPrb))
    dlFdSchedData_numOfPrb = get_specified_column_from_csv_file_for_rnti(filename=filename,
                                                                         linename='dlFdSchedData.numOfPrb')
    logging.info("get_rnti_from_csv_file: dlFdSchedData_numOfPrb = %s" % (dlFdSchedData_numOfPrb))
    first_prb_non_blanking = 16
    end_prb_non_blanking = 273
    for rnti in list_rnti:
        startPrb = dlFdSchedData_startPrb[rnti][1:]
        logging.info("%s startPrb = %s" % (rnti, startPrb))
        numOfPrb = dlFdSchedData_numOfPrb[rnti][1:]
        logging.info("%s numOfPrb = %s" % (rnti, numOfPrb))
        all_startPrb_by_rnti = len(startPrb)
        logging.info("=====> Checking for rnti %s " % rnti)
        for i in range(all_startPrb_by_rnti):
            if int(float(dlFdSchedData_startPrb[rnti][i])) < int(first_prb_non_blanking):
                raise Exception('Check failed, startPrb for rnti {} < first_prb_non_blanking {}'
                                .format(rnti, all_startPrb_by_rnti))
            end_prb = int(float(dlFdSchedData_startPrb[rnti][i])) + int(float(dlFdSchedData_numOfPrb[rnti][i]))
            if end_prb > int(end_prb_non_blanking):
                raise Exception('Check failed, end_prb {} for rnti {} < end_prb_non_blanking {}'
                                .format(end_prb, rnti, end_prb_non_blanking))

    find_column_number(CsvName='Dl_PrbPoolingAllocationReport_45_.csv', Column_name="NRCellid")
    find_column_number(CsvName='Dl_PrbPoolingAllocationReport_45_.csv', Column_name="NumMinPrbAlloc")
    find_column_number(CsvName='Dl_PrbPoolingAllocationReport_45_.csv', Column_name="numberOfPrbRimRs")
    verify_numminprb_for_cellid_where_rim_rs_is_present_in_csv_File(CsvName='Dl_PrbPoolingAllocationReport_45_.csv',
                                                                    NRCellid='0x4002',
                                                                    expected_values_rim_rs=96,
                                                                    expected_values_no_rim_rs=48)
    verify_numminprb_for_cellid_where_rim_rs_is_present_in_csv_File(CsvName='Dl_PrbPoolingAllocationReport_45_.csv',
                                                                    NRCellid='0x4003',
                                                                    expected_values_rim_rs=48,
                                                                    expected_values_no_rim_rs=48)

    test_listParam = [{'sfn': '906', 'gbrPrbDemand': [0, 0, 0], 'nonGbrPrbDemand': [0, 0, 0]},
                      {'sfn': '906', 'gbrPrbDemand': [0, 0, 0], 'nonGbrPrbDemand': [0, 0, 0]},
                      {'sfn': '906', 'gbrPrbDemand': [0, 0, 0], 'nonGbrPrbDemand': [0, 0, 0]},
                      {'sfn': '911', 'gbrPrbDemand': [0, 0, 0], 'nonGbrPrbDemand': [0, 0, 0]},
                      {'sfn': '911', 'gbrPrbDemand': [0, 0, 0], 'nonGbrPrbDemand': [0, 0, 0]},
                      {'sfn': '911', 'gbrPrbDemand': [0, 0, 0], 'nonGbrPrbDemand': [0, 0, 0]}]
    # display_list_parameters_w_name(test_listParam)
    dictParam = {
        "w_Basic_Call_to_Setup_Wtsemu": True,
        "w_enable_sherpa_Traces": True,
        "w_check_8940_using_sherpa": False,
        "w_GetTtiTrace": True,
        "w_convert_TtiPcap_to_excelCsv": False,
        "w_GetL1L2Bip": False,
        "w_generic_capture": True,
        "w_CaptureCORE": False,
        "w_CaptureL1L2": False,
        "w_CaptureCPRT": True,
        "w_ue_detach": False,
        "w_GetBtsLog": True,
        "w_DISPLAY_ue_stats_nr_15min": False,
    }
    CAPTURE = {
        "GetTtiTraceTime": "1s",
        "Getl1l2TraceTime": "1s",
        "GetSherpaTraceTime": "1s",
        "GetTtiTraceNumOfEvent": 5000,
    }
    dict_settings_ue_1 = {
        "originalCell": 1,
        "DL_throughput": 150,
        "DL_throughput_GBR": 10,
        "UL_throughput": 0,
        "packet_size": 1350
    }
    dict_settings_ue_2 = {
        "originalCell": 2,
        "DL_throughput": 150,
        "DL_throughput_GBR": 10,
        "UL_throughput": 0,
        "packet_size": 1350
    }
    dict_settings_ue_3 = {
        "originalCell": 3,
        "DL_throughput": 150,
        "DL_throughput_GBR": 10,
        "UL_throughput": 0,
        "packet_size": 1350
    }
    dict_settings_ue_4 = {
        "originalCell": 1,
        "DL_throughput": 150,
        "DL_throughput_GBR": 10,
        "UL_throughput": 0,
        "packet_size": 1350
    }
    dict_settings_ue_5 = {
        "originalCell": 2,
        "DL_throughput": 150,
        "DL_throughput_GBR": 10,
        "UL_throughput": 0,
        "packet_size": 1350
    }
    dict_settings_ue_6 = {
        "originalCell": 3,
        "DL_throughput": 150,
        "DL_throughput_GBR": 10,
        "UL_throughput": 0,
        "packet_size": 1350
    }
    dict_settings_all_ues = [dict_settings_ue_1, dict_settings_ue_2, dict_settings_ue_3, dict_settings_ue_4,
                             dict_settings_ue_5, dict_settings_ue_6]
    dictVendorCustomTest = {
        "bbHwVariant": 'ABIO',
        "maxNumScheUePdschL1Pool": None,
        "maxNumScheUePdschL1Sp": None,
        "maxNumLayerPrbL1Sp": 1200,
        "maxNumStreamPrbL1Sp": 1200,
        "maxNumWbStreamPrbL1Sp": 600,
        "ul_maxNumLayerPrbL1Sp_csSize32": None,
        "ul_maxNumStreamPrbL1Sp_csSize32": None,
        "ul_maxNumWbStreamPrbL1Sp_csSize32": None,
        "ul_maxNumLayerPrbL1Sp_csSize64": None,
        "ul_maxNumStreamPrbL1Sp_csSize64": None,
        "ul_maxNumWbStreamPrbL1Sp_csSize64": None,
    }
    dictExpectedValues = {
        "expected_avg_total_prbs_spool1": 546,
        "expected_avg_total_prbs_spool2": 78,
        "expected_avg_total_prbsstream_spool1": 2100,
        "expected_avg_total_prbsstream_spool2": 310
    }
    dictTestParam = {
        "dictParam": dictParam,
        "CAPTURE": CAPTURE,
        "dict_settings_all_ues": dict_settings_all_ues,
        "VENDOR_CUSTOM": dictVendorCustomTest,
        "ExpectedValues": dictExpectedValues
    }
    dictTestParamTest2 = {
        "dictParam": dictParam,
        "CAPTURE": CAPTURE,
        "dict_settings_all_ues": dict_settings_all_ues,
        "VENDOR_CUSTOM": dictVendorCustomTest,
        "ExpectedValues": dictExpectedValues
    }

    # PRV_CB008940_L_3_Interworking_when_both_NRBTS_actSpatialStreamPooling_and_NRBTS_actBbPoolTddFr1_are_enabled
    dict_test =\
        dict(
            CB008940_L_3_Interworking_when_both_actSpatialStreamPooling_and_actBbPoolTddFr1_enabled=dictTestParam)
    # write_list_of_dictionary_to_json('/home/ute/csamson/TRACES', dict_test, 'data_tests.json')
    # first create the json file
    write_dictionary_to_json('/home/ute/csamson/TRACES', dict_test, 'data_tests.json')
    dict_test = dict(
        CB008940_L_1_Interaction_with_CB008238_Micro_DTX_optimized_scheduler_for_FR1_PRB_pooling=dictTestParamTest2)
    # add_list_of_dictionary_to_json('/home/ute/csamson/TRACES', dict_test, 'data_tests.json')
    add_dictionary_to_json('/home/ute/csamson/TRACES',
                           'CB008940_L_1_Interaction_with_CB008238_Micro_DTX_optimized_scheduler_for_FR1_PRB_pooling',
                           dictTestParamTest2, 'data_tests.json')
    add_dictionary_to_json('/home/ute/csamson/TRACES',
                           'PRV_CB008940_L_4_Interaction_with_CB010359_PA_warm_up_for_adequate_PDSCH_EVM',
                           dictTestParamTest2, 'data_tests.json')
    # Opening JSON file
    with open('/home/ute/csamson/TRACES/data_tests.json') as json_file:
        data = json.load(json_file)

        # Print the type of data variable
        print("Type:", type(data))

        # Print the data of dictionary
        print("\nTEST1:",
              data["PRV_CB008940_L_4_Interaction_with_CB010359_PA_warm_up_for_adequate_PDSCH_EVM"])
        print("\nTEST2:",
              data["CB008940_L_1_Interaction_with_CB008238_Micro_DTX_optimized_scheduler_for_FR1_PRB_pooling"])
        dictTestParamTest1_FINAL =\
            data["CB008940_L_1_Interaction_with_CB008238_Micro_DTX_optimized_scheduler_for_FR1_PRB_pooling"]
        print('dictTestParamTest1_FINAL:', dictTestParamTest1_FINAL)
