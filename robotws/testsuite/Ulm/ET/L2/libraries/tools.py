# ====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd68
# Team: 'SqdGp68'
# Email: 'I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging
import re
import datetime
import json
import os
import glob
import pathlib
# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# ET or Feature Specific Libraries:
from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name


# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

rbi = BuiltIn()
scfObj = rbi.get_library_instance("scf")


# ====================================================================================================[120 characters]
#   Helper Functions
# ====================================================================================================[120 characters]

def total_tx_count(counter_dict):
    return sum(counter_dict.values())


@log_begin_end_func_name
def identify_traffic_profile(test_description, scenario):
    """ Returns uldl if the scenario triggers both UL and DL throughput, returns dl if the scenario has
    ONLY DL Throughput and returns ul if the scenario has ONLY UL throughput"""
    keys = test_description[scenario].keys()
    if 'throughput_per_ue_dl' in keys and 'throughput_per_ue_ul' in keys:
        return "uldl"
    elif 'throughput_per_ue_dl' in keys:
        return "dl"
    elif 'throughput_per_ue_ul' in keys:
        return "ul"


@log_begin_end_func_name
def get_pmc_index(scenario, pmc_scenario_dict: dict, ts_log_dir: str):
    """ Returns the PM Counter Index, last executed scenario has index 0.
    For e.g. 2nd scenario in the test configuration has index total num of scenarios - index of 2nd scenario
    The Index is then adjusted by the calculated offset"""
    logging.info('scenario: %s', scenario)
    pmc_timestamps = pmc_scenario_dict[scenario]["timestamps"]
    logging.info('timestamps: %s', pmc_timestamps)
    log_dir = pathlib.Path(ts_log_dir)
    pmc_file = log_dir / pathlib.Path('PMC/gnb_pm_counters/pmCounters.csv')
    with open(pmc_file, 'r', encoding='utf-8') as csv_file:
        header_line = csv_file.readlines()[0]
    headers = header_line.split(';')
    pmc_index = []
    for index, header in enumerate(headers):
        if any(ts in header for ts in pmc_timestamps):
            logging.info('found timestamp in pmcounter.csv: %s', index)
            pmc_index.append(index)
    if pmc_index:
        total_timestamps = len(headers) - 4
        logging.info('total number of timestamps in file: %s', total_timestamps)
        pmc_index = total_timestamps - min(pmc_index) + 1
        return pmc_index
    logging.error('index could not be identified. please check if pmc is active.')
    return None


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
        return None
    factor = int(elapsed_time_in_interval / interval_in_sec)
    return factor


def write_dictionary_to_json(dir_path, dictionary, filename='pm_counter_offsets.json'):
    json_path = dir_path + '/' + filename
    with open(json_path, 'w') as fp:
        json.dump(dictionary, fp, sort_keys=True, indent=4)


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


def get_directory(file_path):
    """ Returns a path without a fie name
        Args:
            file_path (str): full path to any file
        Returns:
            str: a path without a file name
    """
    split_path = file_path.split('/')
    return "/".join(split_path[:-1])


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
    write_dictionary_to_json(dir_path, pm_offset_per_scenario)


def set_element(dist_name, p_name, value):
    if scfObj.is_object_in_scf(dist_name) and scfObj.is_element_in_object(dist_name, p_name):
        scfObj.modify_scf_element(value, dist_name=dist_name, p_name=p_name)
    else:
        scfObj.add_element_to_scf(dist_name, p_name, value)


def set_object(class_name, dist_name, version):
    if not scfObj.is_object_in_scf(dist_name):
        scfObj.add_object_to_scf(class_name, dist_name, version)


def set_list(dist_name, list_name):
    if scfObj.is_list_in_object(dist_name=dist_name, list_name=list_name):
        scfObj.remove_list_from_scf(dist_name=dist_name, list_name=list_name)
    scfObj.add_list_to_scf(dist_name=dist_name, list_name=list_name)


def unique(list_ip):
    return list(set(list_ip))


@log_begin_end_func_name
def zip_files(folder_path, zip_file_name, match_string="*"):
    try:
        os.chdir(folder_path)
        list_of_files = sorted(glob.glob(match_string))
        logging.info("len(list_of_files) = %s" % len(list_of_files))
        if len(list_of_files) > 0:
            os.system("zip -m %s %s >/dev/null 2>&1" % (zip_file_name, match_string))
    except Exception as e:
        logging.warn("zip_files: %s" % str(e))


@log_begin_end_func_name
def align_bwp_profiles_in_scf(scf_file_name_path, bwp_profiles_replace_dict):
    """
    :scf_file_name_path: is a full path to the original SCF
    :bwp_profiles_replace_dict: is a dictionary of {'from': 'to'}, e.g. {'1': '4', '20': '44'} <-- Feature Specific!!!
    :output: a full path to a modified SCF
    """
    if not os.path.isfile(scf_file_name_path):
        logging.warn("Input SCF file doesn't exist, please check : %s " % scf_file_name_path)
        return scf_file_name_path
    if not bwp_profiles_replace_dict:
        logging.warn("BWP Profile Replace Dictionary is emtpy, please check")
        return scf_file_name_path
    try:
        with open(scf_file_name_path, "r") as scf_file:
            data = scf_file.read()
            for profile_from in bwp_profiles_replace_dict.keys():
                profile_to = bwp_profiles_replace_dict[profile_from]
                data = data.replace("/BWP_PROFILE-%s/" % profile_from, "/BWP_PROFILE-%s/" % profile_to)
                data = data.replace("/BWP_PROFILE-%s<" % profile_from, "/BWP_PROFILE-%s<" % profile_to)
                data = data.replace("/BWP_PROFILE-%s\"" % profile_from, "/BWP_PROFILE-%s\"" % profile_to)
        new_scf_file_name_path = scf_file_name_path + ".aligned.xml"
        with open(new_scf_file_name_path, "w") as new_scf_file:
            new_scf_file.write(data)
    except Exception as e:
        logging.warn("%s(): Exception = <%s>" % ("align_bwp_profiles_in_scf", str(e)))
        return None
    return new_scf_file_name_path


@log_begin_end_func_name
def fetch_rnti_from(egate_output_str):
    """
    This function takes a string containing something like 'crnti: 18350 = 0x47AE' and
    returns just '18350'.
    """
    rnti_intemediate_str = re.findall(r'\(crnti:.*\)', egate_output_str)
    rnti_final_str = re.findall(r'\d+', rnti_intemediate_str[0]) if rnti_intemediate_str else []
    return rnti_final_str[0] if rnti_final_str else '0'


def get_reservation_details():
    with open('/opt/ute/reservation.context.json', 'r') as json_file:
        json_content = json.load(json_file)
    return json_content
