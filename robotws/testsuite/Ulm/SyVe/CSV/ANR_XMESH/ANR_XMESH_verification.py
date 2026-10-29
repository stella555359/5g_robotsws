# =====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Verification
# Team: 'CSV'
# Email: ''
# -----------------------------------------------------------------------------------------------------[120 characters]

import logging
import os
import json
import tarfile
from pathlib import Path

import pandas as pd

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# TAF & UTE Libraries:
from taf.config.scf import scf
import taf.ul.hanging_resources as resources

# CSV or Feature Specific Libraries:
from testsuite.Ulm.resources.Common.syslog_parser.syslog_parser import (
    find_errors_and_warnings_in_logfile_and_write_them_into_resultfile)
from testsuite.Ulm.SyVe.CSV.libraries.common_tools import log_begin_end_func_name
from testsuite.Ulm.SyVe.CSV.libraries.verification_tools import get_pmcounters_values, logException


# =====================================================================================================[120 characters]
#   Global Variables
# =====================================================================================================[120 characters]

rbi = BuiltIn()


# =====================================================================================================[120 characters]
#   Keywords
# =====================================================================================================[120 characters]

@log_begin_end_func_name
def check_scf_files(test_scope="XN"):  # XN | X2NSA | X2
    are_SCFs_correct = False
    tolerance = 3
    expected = 50 if test_scope == "XN" else 200
    ts_log_dir = rbi.get_variable_value("${ts_log_dir}")
    logging.info("ts_log_dir = %s" % ts_log_dir)
    scf_obj = scf()
    try:
        # ---------------------------------------------------------------------------------------------[120 characters]
        scf_file_path = os.path.join(ts_log_dir, "SCFC_before_ANR_XMESH.xml")
        logging.info("scf_file_path = %s" % scf_file_path)
        scf_obj.load_scf(scf_file_path)
        SCFC_before_ANR_XMESH = {'scf_file_path': scf_file_path}
        SCFC_before_ANR_XMESH['anr_xmesh_info'] = get_anr_xmesh_info(scf_obj.get_all_dist_names_by_pattern("*"))
        # ---------------------------------------------------------------------------------------------[120 characters]
        scf_file_path = os.path.join(ts_log_dir, "SCFC_during_ANR_XMESH.xml")
        logging.info("scf_file_path = %s" % scf_file_path)
        scf_obj.load_scf(scf_file_path)
        SCFC_during_ANR_XMESH = {'scf_file_path': scf_file_path}
        SCFC_during_ANR_XMESH['anr_xmesh_info'] = get_anr_xmesh_info(scf_obj.get_all_dist_names_by_pattern("*"))
        # ---------------------------------------------------------------------------------------------[120 characters]
        scf_file_path = os.path.join(ts_log_dir, "SCFC_after_ANR_XMESH.xml")
        logging.info("scf_file_path = %s" % scf_file_path)
        scf_obj.load_scf(scf_file_path)
        SCFC_after_ANR_XMESH = {'scf_file_path': scf_file_path}
        SCFC_after_ANR_XMESH['anr_xmesh_info'] = get_anr_xmesh_info(scf_obj.get_all_dist_names_by_pattern("*"))
        # ---------------------------------------------------------------------------------------------[120 characters]
        logging.info("Compare SCF files:")
        logging.info(SCFC_before_ANR_XMESH['scf_file_path'])
        print_anr_xmesh_info(SCFC_before_ANR_XMESH['anr_xmesh_info'])
        logging.info(SCFC_after_ANR_XMESH['scf_file_path'])
        print_anr_xmesh_info(SCFC_after_ANR_XMESH['anr_xmesh_info'])
        result = diff_dicts_of_lists(SCFC_before_ANR_XMESH['anr_xmesh_info'], SCFC_after_ANR_XMESH['anr_xmesh_info'])
        logging.info("result['lengths_of_added'] = %s" % result['lengths_of_added'])
        logging.info("result['lengths_of_removed'] = %s" % result['lengths_of_removed'])
        logging.info("[IMPORTANT] expected = %s" % (expected))
        logging.info("[IMPORTANT] tolerance = %s" % (tolerance))
        all_are_added = all(abs(item - expected) <= tolerance for item in result['lengths_of_added'])
        none_is_removed = set(result['lengths_of_removed']) == {0}
        are_SCFs_correct = all_are_added and none_is_removed
        # ---------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("check_scf_files", e)
    logging.info("are_SCFs_correct = %s" % are_SCFs_correct)
    rbi.should_be_true(are_SCFs_correct)


def get_anr_xmesh_info(list_of_all_dist_names):
    out_dict = {}
    try:
        out_dict['LTEENB'] = [item for item in list_of_all_dist_names if 'LTEENB' in item]
        out_dict['NRX2LINK_TRUST'] = [item for item in list_of_all_dist_names if 'NRX2LINK_TRUST' in item]
        out_dict['SECPOL'] = [item for item in list_of_all_dist_names if 'SECPOL' in item]
        out_dict['IKEP'] = [item for item in list_of_all_dist_names if ('IKEP' in item and 'IKEP_' not in item)]
        out_dict['IPSECP'] = [item for item in list_of_all_dist_names if 'IPSECP' in item]
        out_dict['NRADJGNB'] = [item for item in list_of_all_dist_names if 'NRADJGNB' in item]
        out_dict['NRADJNRCELL'] = [item for item in list_of_all_dist_names if 'NRADJNRCELL' in item]
        out_dict['XNLINK'] = [item for item in list_of_all_dist_names if 'XNLINK' in item]
    except Exception as e:
        logException("get_anr_xmesh_info", e)
    print_anr_xmesh_info(out_dict)
    return out_dict


def print_anr_xmesh_info(in_dict):
    info_string = ""
    for key, value in in_dict.items():
        info_string = info_string + f"\t{key}: {len(value)} \n"
    else:
        logging.info(info_string)


def diff_dicts_of_lists(d1, d2):
    all_keys = set(d1) | set(d2)
    diff = {'lengths_of_added': [], 'lengths_of_removed': []}
    for key in all_keys:
        list1 = set(d1.get(key, []))
        list2 = set(d2.get(key, []))
        added = list(list2 - list1)
        removed = list(list1 - list2)
        anr_xmesh_specific_logging(added, key)
        anr_xmesh_specific_logging(removed, key)
        if added or removed:
            diff[key] = {
                'added': sorted(added),
                'removed': sorted(removed)
            }
            diff['lengths_of_added'].append(len(added))
            diff['lengths_of_removed'].append(len(removed))
        else:
            logging.info(f"{key}: lists are equal!")
    return diff


def anr_xmesh_specific_logging(a_list, list_name):
    result_string = f'{list_name}:\n'
    if not a_list:
        return
    a_list.sort(key=lambda x: int(''.join(filter(str.isdigit, x))))
    result_string += '\n'.join(f'\t{i+1}. {item}' for i, item in enumerate(a_list))
    result_string += f'\nTotal elements: {len(a_list)}'
    logging.info(result_string)


def check_lists_len(lists, desired_length):
    return all(len(lst) == desired_length for lst in lists)


@log_begin_end_func_name
def check_ipsec_status(test_scope="XN"):  # XN | X2NSA | X2
    is_IPSec_Status_correct = False
    tolerance = 3
    expected = 50 if test_scope == "XN" else 200
    ts_log_dir = rbi.get_variable_value("${ts_log_dir}")
    logging.info("ts_log_dir = %s" % ts_log_dir)
    ipsec2_filepath = os.path.join(ts_log_dir, "IPSEC_during_ANR_XMESH.txt")
    try:
        with open(ipsec2_filepath, "r") as ipsec_status_file:
            content = ipsec_status_file.read()
            number_of_established = content.count('ESTABLISHED')
            number_of_installed = content.count('NSTALLED, TUNNEL')
            logging.info("number_of_established = %s <---> expected = %s" % (number_of_established, expected))
            logging.info("number_of_installed = %s <---> expected = %s" % (number_of_installed, expected))
            logging.info("[IMPORTANT] tolerance = %s" % (tolerance))
            cp1 = abs(number_of_established - expected) <= tolerance
            cp2 = abs(number_of_installed - expected) <= tolerance
        is_IPSec_Status_correct = all([cp1, cp2])
    except Exception as e:
        logException("check_ipsec_status", e)
    logging.info("is_IPSec_Status_correct = %s" % is_IPSec_Status_correct)
    rbi.should_be_true(is_IPSec_Status_correct)


@log_begin_end_func_name
def check_pm_counters(test_scope="XN", number_of_measurementperiods=1):  # XN | X2NSA | X2
    are_PMCs_correct = False
    tolerance = 3
    expected_gNBs = 50
    expected_eNBs = 200
    pmc_csv_filepath = os.path.join(rbi.get_variable_value("${pm_counters_dir}"), "pmCounters.csv")
    logging.info("pmc_csv_filepath = %s" % pmc_csv_filepath)
    try:
        piid_dict = {"M55126C00005": "Num. of successful XN SETUP procedures",
                     "M55126C00035": "Num. of outgoing XN SETUP request sent to remote gNB",
                     "M55147C01001": "Num. of neighbor relations added by ANR for NRCELL",
                     "M55125C07502": "NG based Intra-freq HO prep att onsource cell",
                     "M55125C07512": "Successful NG based HO prep att onsource cell",
                     "M55125C07514": "NG based Intra-freq HO exec att onsource cell",
                     "M55125C07523": "Successful NG-based intra-frequency HO execution attempts onsource cell"}
        reported_dict_gNBs = get_pmcounters_values(pmc_csv_filepath,
                                                   pmcounters_list=piid_dict.keys(),
                                                   number_of_columns=number_of_measurementperiods)
        cp1 = all(abs(value - expected_gNBs) <= tolerance
                  for value in reported_dict_gNBs.values()) if test_scope == "XN" else True
        logging.info("expected_gNBs = %s" % expected_gNBs)
        print_keys_with_values(reported_dict_gNBs, piid_dict)
        logging.info("[IMPORTANT] test_scope = %s" % (test_scope))
        logging.info("[IMPORTANT] expected_gNBs = %s (only if test_scope is 'XN', otherwise 0)" % (expected_gNBs))
        logging.info("[IMPORTANT] tolerance = %s" % (tolerance))
        logging.info("Check Point #1 (gNBs): legacy PM Counters %s --------------\n" % ("PASSED" if cp1 else "FAILED"))
        # ---------------------------------------------------------------------------------------------[120 characters]
        piid_dict = {"M55110C00002": "Num. of SCTP shutdown detected on X2 link by SCTP layer",
                     "M55110C00003": "Num. of incoming EN-DC X2 SETUP request received from LTE eNB",
                     "M55110C00004": "Num. of EN-DC X2 SETUP response sent to LTE eNB",
                     "M55110C00009": "Num. of X2 RESET request received from LTE eNB",
                     "M55110C00010": "Num. of X2 RESET response sent to LTE eNB"}
        reported_dict_eNBs = get_pmcounters_values(pmc_csv_filepath,
                                                   pmcounters_list=piid_dict.keys(),
                                                   number_of_columns=number_of_measurementperiods)
        cp2 = all(abs(value - expected_eNBs) <= tolerance
                  for value in reported_dict_eNBs.values()) if test_scope == "X2NSA" else True
        logging.info("expected_eNBs = %s" % expected_eNBs)
        print_keys_with_values(reported_dict_eNBs, piid_dict)
        logging.info("[IMPORTANT] test_scope = %s" % (test_scope))
        logging.info("[IMPORTANT] expected_eNBs = %s (only if test_scope is 'X2NSA', otherwise 0)" % (expected_eNBs))
        logging.info("[IMPORTANT] tolerance = %s" % (tolerance))
        logging.info("Check Point #2 (eNBs): legacy PM Counters %s --------------\n" % ("PASSED" if cp2 else "FAILED"))
        # ---------------------------------------------------------------------------------------------[120 characters]
        piid_dict = {"M51330C3": "received Packet Match Bypass Pol",
                     "M51330C7": "sent Packet Bypass Pol"}
        reported_dict = get_pmcounters_values(pmc_csv_filepath,
                                              pmcounters_list=piid_dict.keys(),
                                              number_of_columns=number_of_measurementperiods)
        cp3 = all(value > 0 for value in reported_dict.values())
        print_keys_with_values(reported_dict, piid_dict)
        logging.info("Check Point #3: non-zero IPSEC Counters %s ----------------\n" % ("PASSED" if cp3 else "FAILED"))
        # ---------------------------------------------------------------------------------------------[120 characters]
        piid_dict = {"M51330C0": "sent Packet Match Disc Pol",
                     "M51330C6": "sent Packet Match Def Pol",
                     "M51330C1": "ipsec Sa Not Found",
                     "M51330C8": "failed SA Establishments",
                     "M51330C5": "recv Unprot Packet Match Prot Pol",
                     "M51330C2": "received Packet Match Def Pol",
                     "M51330C4": "received Packet Match Disc Pol"}
        reported_dict = get_pmcounters_values(pmc_csv_filepath,
                                              pmcounters_list=piid_dict.keys(),
                                              number_of_columns=number_of_measurementperiods)
        cp4 = True  # all(value == 0 for value in reported_dict.values())
        print_keys_with_values(reported_dict, piid_dict)
        logging.info("Check Point #4 (not used): zero IPSEC Counters %s ---------\n" % ("PASSED" if cp4 else "FAILED"))
    except Exception as e:
        logException("check_pm_counters", e)
    are_PMCs_correct = all([cp1, cp2, cp3, cp4])
    logging.info("are_PMCs_correct = %s" % are_PMCs_correct)
    rbi.should_be_true(are_PMCs_correct)


def print_keys_with_values(dict1, dict2):
    lines = []
    for key in dict1:
        first_part = f"{key}: {dict1[key]}"
        lines.append(f"'{first_part:<30}{dict2[key]}'")
    logging.info("\n".join(lines))


@log_begin_end_func_name
def check_syslogs():
    are_syslogs_correct = False
    number_of_findings = 0
    errors_to_find = ["overload"]
    path_to_syslog_tgz = rbi.get_variable_value("${path_to_syslog_tgz}")
    logging.info("path_to_syslog_tgz = %s" % path_to_syslog_tgz)
    try:
        unpack_tgz_to_current_directory(path_to_syslog_tgz)
        syslogs_folder_path, tgz_filename = os.path.split(path_to_syslog_tgz)
        folder_path = Path(syslogs_folder_path)
        for filepath in folder_path.glob("*.LOG"):
            if filepath.is_file():
                find_errors_and_warnings_in_logfile_and_write_them_into_resultfile(filepath)
        for filepath in folder_path.glob("*.ERRORS"):
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                for substring in errors_to_find:
                    if substring in content:
                        logging.info(f"Error: '{substring}' found in '{filepath}'")
                        number_of_findings = number_of_findings + 1
        remove_files_by_pattern(syslogs_folder_path, partial_name="SYSLOG", extension="LOG")
    except Exception as e:
        logException("check_syslogs", e)
    are_syslogs_correct = not number_of_findings
    logging.info("are_syslogs_correct = %s" % are_syslogs_correct)
    rbi.should_be_true(are_syslogs_correct)


@log_begin_end_func_name
def unpack_tgz_to_current_directory(tgz_file_path):
    if not os.path.exists(tgz_file_path):
        logging.warning(f"Error: Archive file not found at '{tgz_file_path}'")
        return
    try:
        with tarfile.open(tgz_file_path, "r:gz") as tar:
            tgz_folder_path, tgz_filename = os.path.split(tgz_file_path)
            logging.info(f"Extracting all contents from '{tgz_filename}' to '{tgz_folder_path}'")
            tar.extractall(path=tgz_folder_path)
            logging.info("Extraction complete.")
    except tarfile.ReadError:
        logging.warning(f"Error: Could not read archive '{tgz_file_path}'. It might be corrupted or not valid file.")
    except Exception as e:
        logging.warning(f"An unexpected error occurred: {e}")


@log_begin_end_func_name
def remove_files_by_pattern(directory_path, partial_name, extension, dry_run=False):
    if not os.path.isdir(directory_path):
        logging.warning(f"Error: Directory '{directory_path}' not found.")
        return []
    processed_files = []
    logging.info(f"Searching in: {directory_path}")
    logging.info(f"Looking for files containing '{partial_name}' and ending with '{extension}'")
    logging.info("-" * 50)
    for filename in os.listdir(directory_path):
        full_path = os.path.join(directory_path, filename)
        if os.path.isfile(full_path):
            if partial_name in filename and filename.endswith(extension):
                processed_files.append(full_path)
                if dry_run:
                    logging.info(f"[DRY RUN] Would delete: {full_path}")
                else:
                    try:
                        os.remove(full_path)
                        logging.info(f"Deleted: {full_path}")
                    except OSError as e:
                        logging.warning(f"Error deleting {full_path}: {e}")
    logging.info("-" * 50)
    if not processed_files:
        logging.warning("No matching files found.")
    elif dry_run:
        logging.warning(f"Dry run complete. {len(processed_files)} file(s) would have been deleted.")
    else:
        logging.info(f"Deletion complete. {len(processed_files)} file(s) were deleted.")
    return processed_files


@log_begin_end_func_name
def check_backhaul_traces(test_scope="XN"):  # XN | X2NSA | X2):
    are_backhaul_traces_correct = False
    expected = 50 if test_scope == "XN" else 200
    tolerance = 3
    path_to_backhaul_tabs = rbi.get_variable_value("${path_to_backhaul_tabs}")
    logging.info("path_to_backhaul_tabs = %s" % path_to_backhaul_tabs)
    try:
        with open(path_to_backhaul_tabs, "r") as f:
            lines = f.readlines()
            message_patterns_to_verify = []
            if test_scope == "XN":
                message_patterns_to_verify = [['XnAP', 'XnSetupRequest'],
                                              ['NGAP', 'HandoverRequired'],
                                              ['NGAP', 'HandoverCommand']]
            elif test_scope == "X2NSA":
                message_patterns_to_verify = [['X2AP', 'ResetResponse'],
                                              ['X2AP', 'ENDCX2SetupResponse'],
                                              ['ISAKMP', 'IKE_SA_INIT MID=00 Initiator Request'],
                                              ['ISAKMP', 'IKE_SA_INIT MID=00 Responder Response'],
                                              ['ISAKMP', 'IKE_AUTH MID=01 Initiator Request'],
                                              ['ISAKMP', 'IKE_AUTH MID=01 Responder Response']]
            else:
                logging.warning(f"Unknown test_scope '{test_scope}'. No specific message patterns will be verified.")
            results = []
            for pattern_list in message_patterns_to_verify:
                reported_count = sum(
                    1
                    for line in lines
                    if all(pattern.lower() in line.lower() for pattern in pattern_list)
                )
                logging.info(f"Reported: {reported_count} | Expected: {expected} | Patterns: {pattern_list}")
                results.append(abs(reported_count - expected) <= tolerance)
            logging.info("[IMPORTANT] tolerance = %s" % (tolerance))
        are_backhaul_traces_correct = all(results)
    except Exception as e:
        logException("check_backhaul_traces", e)
    logging.info("are_backhaul_traces_correct = %s" % are_backhaul_traces_correct)
    rbi.should_be_true(are_backhaul_traces_correct)


@log_begin_end_func_name
def check_resources():
    are_resources_unchanged = False
    results = []
    resource_stats_dir = rbi.get_variable_value("${resource_stats_dir}")
    logging.info("resource_stats_dir = %s" % resource_stats_dir)
    try:
        resources_obj = resources.hanging_resources()
        logging.info("reading file:\t"+resource_stats_dir+"/before_scenario.json")
        with open(resource_stats_dir+"/before_scenario.json") as file:
            resources_before = json.load(file)
        logging.info("reading file:\t"+resource_stats_dir+"/after_scenario.json")
        with open(resource_stats_dir+"/after_scenario.json") as file:
            resources_after = json.load(file)
        try:
            resources_obj.configure_default_excluding_resource_paths(add="//cooling")
            diff = resources_obj.resources_should_be_equal(resources_before, resources_after, exclude=None)
        except Exception as e:
            diff = e
        logging.info("diff = %s" % diff)
        are_resources_unchanged = diff is None
    except Exception as e:
        logException("check_resources", e)
    logging.info("are_resources_unchanged = %s" % are_resources_unchanged)
    rbi.should_be_true(are_resources_unchanged)


@log_begin_end_func_name
def check_ttitraces():
    are_ttitraces_correct = False
    ts_log_dir = rbi.get_variable_value("${ts_log_dir}")
    logging.info("ts_log_dir = %s" % ts_log_dir)
    try:
        pass
    except Exception as e:
        logException("check_ttitraces", e)
    logging.info("are_ttitraces_correct = %s" % are_ttitraces_correct)
    rbi.should_be_true(are_ttitraces_correct)
