import logging
import xml.etree.ElementTree as ET
import json
import ute_wtssim
import time
import re
import importlib

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# ET or Feature Specific Libraries:
import pandas as pd

from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
e_profile = importlib.import_module(
    "testsuite.Ulm.ET.CB013392.CB013392-E.configurations.CB013392_E_profile")

# =====================================================================================================[120 characters]
#   Global Variables
# =====================================================================================================[120 characters]
RED = '\033[31m'
RESET = '\033[0m'
rbi = BuiltIn()
egate_object = None
# =====================================================================================================[120 characters]
#   Keywords
# =====================================================================================================[120 characters]


@log_begin_end_func_name
def initialize_egate():
    global egate_object
    egate_object = ute_wtssim.ute_wtssim()
    egate_object.setup_egate(egate_port=10000, alias="python_egate")


@log_begin_end_func_name
def get_values_from_targetbd(targetbd_path, radio_name='AHEGHA'):
    tree_targetbd = ET.parse(targetbd_path)
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


@log_begin_end_func_name
def load_pmc_dataframe():
    pmc_csv_file = rbi.get_variable_value("${pm_counters_dir}") + "pmCounters.csv"
    df = pd.read_csv(pmc_csv_file, sep=";")
    # df = df.reset_index(drop=True)

    return df


# =====================================================================================================[120 characters]
@log_begin_end_func_name
def load_tput_dict():
    pm_counters_dir = rbi.get_variable_value("${pm_counters_dir}")
    tput_file_path = pm_counters_dir + "pmc_average_tp_per_scenario_per_cell.json"

    with open(tput_file_path, 'r') as f:
        tput_dict = json.load(f)

    return tput_dict


def load_json_file_and_return_dict(json_path):
    with open(json_path, 'r') as json_file:
        return json.load(json_file)


def log_exception(functionNameStr, e, silent=False):
    logging.info("%s(): Exception = <%s>" % (functionNameStr, str(e)))
    if not silent:
        rbi.log_to_console("" + RED + "  %s: exception happend (see log.html)" % functionNameStr + RESET + "")


# =====================================================================================================[120 characters]
def get_scell_switch_variables_for_b5(scenario_name):
    if scenario_name in ['scenario_1', 'scenario_2']:
        print('returning Variables for scell swap between cell 7 and 5')
        return (3, 54, 10)
    if scenario_name == 'scenario_3':
        print('returning Variables for scell swap between cell 2 and 1')
        return (1, 51, 8)


@log_begin_end_func_name
def register_multiple_ue_with_amf(ue_list):
    try:
        for ue_id in ue_list:
            #  Set amf to send RFSP index same as NRMEASPR_MA_SA-n to UE as precondition
            egate_object.execute_egate_command(
                cmd=f'amf_ue_ics_param id=1 indexToRFSP={e_profile.RFSP_UE_MEASPR[ue_id]}', alias="python_egate")
            # Register UE
            egate_object.execute_egate_command_and_wait_for_data(
                cmd=f'ue_register id={ue_id} nwslice=1', alias="python_egate",
                pass_regexp="Registered state.")

            egate_object.execute_egate_command(
                cmd=f'set_pdu_param ue={ue_id} pdu=2 trf_type=internal log_traffic_stats=off', alias="python_egate")

            # Setup PDU
            _ = egate_object.execute_egate_command_and_wait_for_data(
                alias="python_egate",
                cmd=f"ue_pdu_session_setup pdu=2 ue={ue_id} nwslice=1 gw=2",
                pass_regexp="PDU SESSION ID-2 setup/reestablishment complete")

    except Exception as e:
        log_exception("register_ue_collect_rrc", e)


@log_begin_end_func_name
def register_ue_collect_rrc(ue_id=1, pdu=2, gw=2):
    try:
        egate_log_path = rbi.get_variable_value("${ts_log_dir}") + "/registration_egate_output.txt"
        ue_meas_profile_path = rbi.get_variable_value("${ts_log_dir}") + "/registration_meas_profile.txt"

        # Register UE
        egate_object.execute_egate_command_and_wait_for_data(
            cmd="ue_register id=%d nwslice=1" % ue_id, alias="python_egate",
            pass_regexp="Registered state.")
        time.sleep(1)
        egate_object.execute_egate_command(
            cmd=f"set_pdu_param ue={ue_id} pdu={pdu} trf_type=internal log_traffic_stats=off", alias="python_egate")

        # Setup PDU
        pdu_setup_text = egate_object.execute_egate_command_and_wait_for_data(
            alias="python_egate",
            cmd=f"ue_pdu_session_setup pdu={pdu} ue={ue_id} nwslice=1 gw={gw}",
            pass_regexp=f"PDU SESSION ID-{pdu} setup/reestablishment complete")
        with open(egate_log_path, 'w') as write_to_file:
            write_to_file.write(pdu_setup_text)

        # get final meas profile configuration values
        get_ue_meas_disp(ue_meas_profile_path, ue_id, "AFTER UE REGISTRATION")
    except Exception as e:
        log_exception("register_ue_collect_rrc", e)


@log_begin_end_func_name
def trigger_ho_kpi(ue_id=1, a2_meas_id="1", a3_meas_id="5"):
    # This keyword expects the HO from Cell#12 to Cell#11 only, in other words
    # 1) from EXT_ENB-2.11 to EXT_ENB-2.1
    # 2) from PCI#60 to PCI#50
    # 3) from Cell#11 to Cell#1
    phycell_id = "50"
    rrc_A2_msg = "rrcReconfigurationComplete"
    rrc_A3_msg = r"Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.1 performed"
    try:
        #  Trigger A2
        _ = egate_object.execute_egate_command_and_wait_for_data(
            cmd=f'ue_measurement_send_nr id={ue_id} meas_id={a2_meas_id} event=A2 rs_type=ssb srsrp_nr=5',
            alias="python_egate", pass_regexp=rrc_A2_msg)
        time.sleep(0.2)
        log_ue_meas_disp(ue_id, "AFTER A2 REPORT")
        # Trigger A3
        _ = egate_object.execute_egate_command_and_wait_for_data(
            cmd=f'ue_measurement_send_nr id={ue_id} meas_id={a3_meas_id} '
                f'event=A3 srsrp_nr=50 phycell_id={phycell_id} nrsrp_nr=65',
            alias="python_egate", pass_regexp=rrc_A3_msg)
        time.sleep(0.2)
        log_ue_meas_disp(ue_id, "AFTER UE HANDOVER")
    except Exception as e:
        log_exception("trigger_ho_kpi", e)


@log_begin_end_func_name
def get_ue_meas_disp_kpi(ue_list):
    try:
        for ue_id in ue_list:
            ue_meas_profile_path = rbi.get_variable_value("${ts_log_dir}") + f'/ue_meas_profile_{ue_id}.txt'
            get_ue_meas_disp(ue_meas_profile_path, ue_id, ue_id)
    except Exception as e:
        log_exception("get_ue_meas_disp_kpi", e)


# =====================================================================================================[120 characters]
@log_begin_end_func_name
def trigger_ho(ue_id=1, a2_meas_id="1", a3_meas_id="5", phycell_id="60", scenario="SA", from_cell="12", to_cell="11"):
    # This keyword expects the HO from Cell#12 to Cell#11 only, in other words
    # 1) from EXT_ENB-2.12 to EXT_ENB-2.11
    # 2) from PCI#61 to PCI#60
    # 3) from Cell#12 to Cell#11

    if scenario == "SA":
        rrc_A2_msg = "rrcReconfigurationComplete"
        rrc_A3_msg = f"Intra-eNB handover from EXT_ENB-2.{from_cell} to EXT_ENB-2.{to_cell} performed"
    elif scenario == "KPI":
        phycell_id = "50"
        rrc_A2_msg = "rrcReconfigurationComplete"
        rrc_A3_msg = r"Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.1 performed"
    else:
        # for NSA
        rrc_A2_msg = "rrcConnectionReconfigurationComplete"
        rrc_A3_msg = r"\(eNB 2 cell 11\) reported successful RA"

    try:
        ue_meas_profile_path = rbi.get_variable_value("${ts_log_dir}") + "/registration_meas_profile.txt"
        egate_log_path = rbi.get_variable_value("${ts_log_dir}") + "/registration_egate_output.txt"

        #  Trigger A2
        a2_event_response = egate_object.execute_egate_command_and_wait_for_data(
            cmd=f'ue_measurement_send_nr id={ue_id} meas_id={a2_meas_id} event=A2 rs_type=ssb srsrp_nr=5',
            alias="python_egate", pass_regexp=rrc_A2_msg)
        time.sleep(1)
        log_ue_meas_disp(ue_id, "AFTER A2 REPORT")

        # Trigger A3
        a3_event_response = egate_object.execute_egate_command_and_wait_for_data(
            cmd=f'ue_measurement_send_nr id={ue_id} meas_id={a3_meas_id} '
                f'event=A3 srsrp_nr=50 phycell_id={phycell_id} nrsrp_nr=65',
            alias="python_egate", pass_regexp=rrc_A3_msg)
        time.sleep(1)
        with open(egate_log_path, 'w') as write_to_file:
            write_to_file.write(a3_event_response)
        get_ue_meas_disp(ue_meas_profile_path, ue_id, "AFTER UE HANDOVER")
    except Exception as e:
        log_exception("trigger_ho", e)


@log_begin_end_func_name
def trigger_a1_fdd_scell_addition(ue_id=1, meas_id=5, threshold=100):
    try:
        a1_log_path = rbi.get_variable_value("${ts_log_dir}") + "/a1_fdd_scell_addition_egate_output.txt"
        scell_log_path = rbi.get_variable_value("${ts_log_dir}") + "/a1_fdd_scell_addition_meas_profile.txt"

        #  Trigger A1 and save data
        a1_event_response = egate_object.execute_egate_command_and_wait_for_data(
            cmd=f"ue_measurement_send_nr id={ue_id} meas_id={meas_id} event=A1 srsrp_nr={threshold}",
            alias="python_egate", pass_regexp=r"rrcReconfigurationComplete")
        with open(a1_log_path, 'w') as write_to_file:
            write_to_file.write(a1_event_response)
        time.sleep(1)
        get_ue_meas_disp(scell_log_path, ue_id, "AFTER A1 FDD SCELL ADDITION")
    except Exception as e:
        log_exception("trigger_a1_fdd_scell_addition", e)


@log_begin_end_func_name
def trigger_a2_scell_release(ue_id=1, scell_idx=2):
    try:
        a2_log_path = rbi.get_variable_value("${ts_log_dir}") + "/a2_fdd_scell_release_egate_output.txt"
        scell_log_path = rbi.get_variable_value("${ts_log_dir}") + "/a2_fdd_scell_release_meas_profile.txt"

        #  Trigger A2
        a2_event_response = egate_object.execute_egate_command_and_wait_for_data(
            cmd=f"ue_measurement_send_nr id={ue_id} meas_id=6 event=A2 rs_type=ssb scell={scell_idx} scell_rsrp=5",
            alias="python_egate", pass_regexp=r"rrcReconfigurationComplete")
        with open(a2_log_path, 'w') as write_to_file:
            write_to_file.write(a2_event_response)
        time.sleep(1)
        get_ue_meas_disp(scell_log_path, ue_id, "AFTER A2 SCELL RELEASE")
    except Exception as e:
        log_exception("trigger_a2_scell_release", e)


def trigger_a1_tdd_scell_addition(ue_id=1, meas_id=6, threshold=120):
    try:
        a1_log_path = rbi.get_variable_value("${ts_log_dir}") + "/a1_tdd_scell_addition_egate_output.txt"
        tdd_scell_log_path = rbi.get_variable_value("${ts_log_dir}") + "/a1_tdd_scell_addition_meas_profile.txt"

        # Trigger A1 to add TDD n78 SCell
        # srsp_nr=120 > a1ThresholdSCellAddSsbRsrpTDD of PCell(110)
        a1_event_response = egate_object.execute_egate_command_and_wait_for_data(
            cmd=f"ue_measurement_send_nr id={ue_id} meas_id={meas_id} event=A1 srsrp_nr={threshold}",
            alias="python_egate", pass_regexp=r"rrcReconfigurationComplete")
        with open(a1_log_path, 'w') as write_to_file:
            write_to_file.write(a1_event_response)
        time.sleep(1)
        get_ue_meas_disp(tdd_scell_log_path, ue_id, "AFTER A1 TDD SCELL ADDITION")
    except Exception as e:
        log_exception("trigger_a1_tdd_scell_addition", e)


@log_begin_end_func_name
def get_ue_meas_disp(meas_disp_log_path=None, ue_id=1, log_identifier=" "):
    try:
        if meas_disp_log_path is None:
            meas_disp_log_path = rbi.get_variable_value("${ts_log_dir}") + "/registration_meas_profile.txt"
        ue_meas_txt = log_ue_meas_disp(ue_id, log_identifier)
        with open(meas_disp_log_path, 'w') as write_to_file:
            write_to_file.write(ue_meas_txt)
    except Exception as e:
        log_exception("get_ue_meas_disp", e)


@log_begin_end_func_name
def log_ue_meas_disp(ue_id=1, log_identifier=" "):
    ue_meas_txt = egate_object.execute_egate_command_and_wait_for_data(
        alias="python_egate",
        cmd=f'ue_meas_disp id={ue_id}',
        pass_regexp=f'UE{ue_id} NR MEASUREMENT IDENTITIES:')
    rbi.log_to_console(f'\n\n\nMEASUREMENT REPORT {log_identifier}\n\n {ue_meas_txt}')
    return ue_meas_txt


@log_begin_end_func_name
def get_message(line_start, content):
    message_lines = []
    for line_no, line in enumerate(content[line_start+1:]):
        if line != '\n':
            message_lines.append(line.strip())
        if '}' in line:
            break
    without_brackets = message_lines[1:-1]
    message_dict = {}
    pattern_value = re.compile(r"(\w+),?$")
    for line in without_brackets:
        value = re.findall(pattern_value, line)[0]
        key = line.replace(value, '').replace(':', '').replace(',', '').strip()
        message_dict.update({key: value})
    return message_dict


# =====================================================================================================[120 characters]
def find_string_in_file(file_path, search_string):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    if search_string in content:
        logging.info(f'String ({search_string}) found in file {file_path}')
        return True
    else:
        logging.error(f'String ({search_string}) not found in file {file_path}')
        return False
