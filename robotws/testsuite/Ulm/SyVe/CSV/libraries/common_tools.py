import os
import sys
import zipfile
import logging
import time
import select
import re
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn


rbi = BuiltIn()


def log_begin_end_func_name(fn):
    def inner(*args, **kwargs):
        if "--dryrun" not in sys.argv:
            logging.info("============================== Begin Function {0}".format(fn.__name__))
        func_return = fn(*args, **kwargs)
        if "--dryrun" not in sys.argv:
            logging.info("============================== End Function {0}".format(fn.__name__))
        return func_return
    return inner


@log_begin_end_func_name
def find_actual_average_tput(taf_ue_output_string):
    # taf_ue_output should contain "Actual average tput=17416.13 [kbits/sec]" part
    string_for_regex_search = taf_ue_output_string if taf_ue_output_string is not None else ''
    match = re.search(r"Actual average tput=(\d+\.\d+) \[(.*)\]", string_for_regex_search)
    kpi_dict = {}
    if match:
        tput_value = int(float(match.group(1)))
        tput_units = match.group(2)
        kpi_dict = {'target': tput_value,
                    'name': 'throughput',
                    'visible_to_db': 'Yes',
                    'value': tput_value,
                    'type': 'int',
                    'description': '',
                    'category': 'Customer',
                    'unit': tput_units}
    return kpi_dict


@log_begin_end_func_name
def zip_older_pm_files_to_save_conversion_time(directory, keep_recent=10, zip_name="archived_PM_files.zip",
                                               file_name_filter=""):
    def extract_timestamp(file_name):  # "PM.BTS-xxxxxxx.YYYYMMDD.HHMMSS.ANY.xml" -> "YYYYMMDDHHMMSS"
        timestamp = file_name.split('.')[2] + file_name.split('.')[3]
        return timestamp
    all_files = sorted(
        [(f, extract_timestamp(f))
         for f in os.listdir(directory)
         if os.path.isfile(os.path.join(directory, f)) and f.startswith('PM.BTS') and f.endswith('.xml')],
        key=lambda x: x[1], reverse=True  # Sort by timestamp in ascending order (oldest first)
    )
    try:
        if file_name_filter:
            all_files = [file for file in all_files if file_name_filter in file[0]]
        files_to_zip = [f for f, _ in all_files[int(keep_recent):]]
        if not files_to_zip:
            logging.info("No files to archive.")
            return
        with zipfile.ZipFile(os.path.join(directory, zip_name), 'w', zipfile.ZIP_DEFLATED) as zipf:
            for file_name in files_to_zip:
                file_path = os.path.join(directory, file_name)
                zipf.write(file_path, os.path.basename(file_path))
                os.remove(file_path)
    except Exception as e:
        logging.warning(f"An unexpected error occurred: {e}")


@log_begin_end_func_name
def wait_until_next_measurement(period_minutes="5min", info_string="wait_until_next_measurement"):
    period_minutes = int(re.match(r"(\d+)", period_minutes).group(1))
    now = datetime.now()
    seconds_past = (now.minute * 60 + now.second) % (period_minutes * 60)
    seconds_to_wait = (period_minutes * 60) - seconds_past if seconds_past != 0 else 0
    wait_time = timedelta(seconds=seconds_to_wait, microseconds=-now.microsecond)
    rbi.log_to_console(f"{info_string} ({now}):")
    rbi.log_to_console(f"Waiting for {wait_time} to the next {period_minutes} measurement period...")
    rbi.log_to_console("IMPORTANT: Press ENTER to stop waiting for the next MP and continue at any time!")
    target_time = now + wait_time  # Time when the next measurement period starts
    while now.timestamp() < target_time.timestamp():
        rlist, _, _ = select.select([sys.stdin], [], [], 1)
        if rlist:
            input_line = sys.stdin.readline().strip()  # Read and remove any trailing newline/whitespace
            if input_line == "":  # If ENTER is pressed
                rbi.log_to_console(f"WARNING: Waiting has been stopped by the user ({now})")
                return
        time.sleep(.1)  # Sleep for a short time to avoid using too much CPU
        now = datetime.now()
    rbi.log_to_console(f"Measurement period for {period_minutes} minutes has started ({now})")


@log_begin_end_func_name
def get_first_cell_id_for_external_gnb(file_path):
    gnb_id_external = None
    cell_ids = []
    try:
        with open(file_path, 'r') as f:
            lines = f.readlines()
        # First pass: Find the ID of 'set_gnb type=external'
        for line in lines:
            if "set_gnb" in line and "type=external" in line:
                match = re.search(r"id=(\d+)", line)
                if match:
                    gnb_id_external = match.group(1)
                    break  # Found the gnb_id, no need to search further in this pass
        if gnb_id_external is None:
            logging.warning(f"Error: 'set_gnb type=external' not found in {file_path}")
            return None
        # Second pass: Find cell IDs associated with the found gnb_id_external
        for line in lines:
            if "set_cell" in line:
                # Regex to capture both cell ID and gnb ID from set_cell line
                match_cell = re.search(r"id=(\d+)\s+gnb=(\d+)", line)
                if match_cell:
                    cell_id = match_cell.group(1)
                    gnb_ref_id = match_cell.group(2)
                    if gnb_ref_id == gnb_id_external:
                        cell_ids.append(cell_id)
        if cell_ids:
            return cell_ids[0]
        else:
            logging.warning(f"No 'set_cell' found for gnb ID '{gnb_id_external}' in {file_path}")
    except FileNotFoundError:
        logging.warning(f"Error: File not found at {file_path}")
    except Exception as e:
        logging.warning(f"An unexpected error occurred: {e}")
    return "1"


@log_begin_end_func_name
def get_values_from_targetbd(targetbd_path, radio_name='AHEGHA'):
    try:
        root = ET.parse(targetbd_path)
        for hw_resource in root.findall(".//hwResource"):
            resource_build_key = hw_resource.get("resourceBuildKey")
            if resource_build_key and radio_name in resource_build_key:
                resource_sw_version = hw_resource.get("resourceSWVersion")
                sw_file_key_element = hw_resource.find("swFileKey")
                sw_file_key = sw_file_key_element.text if sw_file_key_element is not None else None
                resource_build_key = hw_resource.get("resourceBuildKey")
                sw_file_key = sw_file_key.replace("%s_" % resource_build_key, "")
                return resource_sw_version, sw_file_key
        return None, None
    except ET.ParseError as e:
        logging.warning(f"Error parsing XML: {e}")
        return None, None
    except Exception as e:
        logging.warning(f"An unexpected error occurred: {e}")
        return None, None


@log_begin_end_func_name
def get_default_apn_of_ue_from_tl_config(ue_alias, apn_type='DEFAULT'):
    tl = rbi.get_variable_value('${tl}')

    # find ue
    matching_ue = [(ue_idx, ue_obj) for ue_idx, ue_obj in enumerate(tl.ues) if ue_alias in ue_obj.capabilities]
    num_ues_found = len(matching_ue)

    if num_ues_found == 1:
        # apnName is stored in list of pdn objects of type PDNTafUeAndroidDetails
        found_apn = matching_ue[0][1].pdns[0].apnName
        logging.info(f"The name of the default apn of {ue_alias} with index {matching_ue[0][0]} is {found_apn}.")
    else:
        found_apn = None
        rbi.fail(f"Could not find unique UE in TL configuration that has string '{ue_alias}' defined in UE " +
                 f"capabilities. Found {num_ues_found} instead.\n" +
                 f"Please check TL config for support of UE/IMSI-specific apn values!")

    return found_apn
