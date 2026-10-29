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
import subprocess
import csv
import math
import logging
import json
import os.path
import sys

# for testing purpose
# from testsuite.Paris.resources.SWENG.python.StringTool import datedConsole, printLineWithTitle
# import testsuite.Paris.resources.SWENG.python.StringTool
# End of for testing purpose
# comment below line for unitary test
import StringTool

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

from robot.api import logger
from taf.config.scf import scf

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


def get_feature_paramters_from_scf(scf_path, feature_params, distname, listname=None):
    feature_params_dict = {}
    scfObj = scf()
    scfObj.load_scf(file_path=scf_path)
    for param in feature_params:
        if listname:
            param_value = scfObj.get_value_from_scf(dist_name=distname, list_name=listname, p_name=param)
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


def toformatline(varname, name, val):
    return getHeaderLine_63("CFG:{}.{}".format(varname, name), val)


def toformatline2(varname, name, val1, val2):
    return getHeaderLine_63("CFG:{}.{}.{}".format(varname, name), val1, val2)


def toformatline_basic(varname, name, val):
    return getHeaderLine_63("{}.{}".format(varname, name), val)


def display_dictionnary_parameters_of_the_TestCase(test_dictParam):
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


def compute_cell_throughput(pm_value, traffic_duration_sec, unit='mbps'):
    if pm_value:
        """Convert Bytes to bits"""
        pm_value_in_bits = pm_value * 8
        pm_value_in_desired_units = pm_value_in_bits / get_divisor(unit)
        average_throughput_for_pm_interval = pm_value_in_desired_units / traffic_duration_sec
        return average_throughput_for_pm_interval
    else:
        logging.info("Throughput in given PM interval is 0")
        return 0


def get_pdu_volume_low_rlc_by_cell_and_qos(cell_dist_name='MRBTS-1/NRBTS-1/NRCELL-1'):
    total_pdu_volume = {}
    latest_file = BuiltIn().get_variable_value('${LATEST_FILE}')
    desired_nrcell_id = cell_dist_name.split('/')[-1].split('-')[-1]
    #   StringTool.datedConsole(toformatline('TestCase Configuration :', 'desired_nrcell_id', desired_nrcell_id))
    BuiltIn().import_resource('testsuite/Paris/resources/SWENG/robot/Counters.robot')
    total_pdu_volume["dl"] =\
        int(BuiltIn().run_keyword("Retrieve Latest Single Counter Value From Pm File with CellID",
                                  latest_file, 'M55310C01006', desired_nrcell_id))
    total_pdu_volume["ul"] =\
        int(BuiltIn().run_keyword("Retrieve Latest Single Counter Value From Pm File with CellID",
                                  latest_file, 'M55310C03006', desired_nrcell_id))
    return total_pdu_volume


def get_average_throughput(traffic_duration_sec,
                           unit='Mbps', cell_dist_name='MRBTS-1/NRBTS-1/NRCELL-1'):
    throughput = {}
    throughput_volume = get_pdu_volume_low_rlc_by_cell_and_qos(cell_dist_name)
    dl_throughput = compute_cell_throughput(pm_value=throughput_volume['dl'],
                                            traffic_duration_sec=traffic_duration_sec,
                                            unit=unit)
    ul_throughput = compute_cell_throughput(pm_value=throughput_volume['ul'],
                                            traffic_duration_sec=traffic_duration_sec,
                                            unit=unit)
    print("Observed Average Cell Throughput : \nDL: {} {}\nUL: {} {}".format(dl_throughput, unit,
                                                                             ul_throughput, unit))
    throughput['throughput_ul'] = ul_throughput
    throughput['throughput_dl'] = dl_throughput
    throughput['unit_dl'] = unit
    throughput['unit_ul'] = unit
    return throughput


def get_average_cell_throughput_for_interval(traffic_duration_sec,
                                             cell_dist_name='MRBTS-1/NRBTS-1/NRCELL-1',
                                             unit='Mbps'):
    return (get_average_throughput(traffic_duration_sec=traffic_duration_sec,
                                   cell_dist_name=cell_dist_name,
                                   unit=unit))


def get_counter_value(cell_dist_name='MRBTS-1/NRBTS-1/NRCELL-1', counterId='M55310C01006'):
    latest_file = BuiltIn().get_variable_value('${LATEST_FILE}')
    desired_nrcell_id = cell_dist_name.split('/')[-1].split('-')[-1]
    #   StringTool.datedConsole(toformatline('TestCase Configuration :', 'desired_nrcell_id', desired_nrcell_id))
    BuiltIn().import_resource('testsuite/Paris/resources/SWENG/robot/Counters.robot')
    counter_value =\
        int(BuiltIn().run_keyword("Retrieve Latest Single Counter Value From Pm File with CellID",
                                  latest_file, counterId, desired_nrcell_id))
    return counter_value


# function to add to JSON
def write_dictionary_to_json(dir_path, dictionary, filename='pm_counter.json'):
    json_path = dir_path + '/' + filename
    with open(json_path, 'w') as fp:
        json.dump(dictionary, fp, sort_keys=True, indent=4)


def add_dictionary_to_json(dir_path, key, dictionary, filename='data.json'):
    json_path = dir_path + '/' + filename
    with open(json_path, 'r+') as file:
        # First we load existing data into a dict.
        file_data = json.load(file)
        # Join new_data with file_data inside emp_details
        file_data[key] = dictionary
        # Sets file's current position at offset.
        file.seek(0)
        # convert back to json.
        json.dump(file_data, file, sort_keys=True, indent=4)


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


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
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
