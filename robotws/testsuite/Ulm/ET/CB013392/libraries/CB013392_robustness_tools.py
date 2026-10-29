import logging
import time
import os
import ute_wtssim

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# ET or Feature Specific Libraries:
from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name

# =====================================================================================================[120 characters]
#   Global Variables
# =====================================================================================================[120 characters]
import pandas as pd

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


def log_exception(function_name_str, e, silent=False):
    logging.info("%s(): Exception = <%s>" % (function_name_str, str(e)))
    if not silent:
        rbi.log_to_console("" + RED + "  %s: exception happend (see log.html)" % function_name_str + RESET + "")


# =====================================================================================================[120 characters]
@log_begin_end_func_name
def trigger_a1_fdd_scell_addition_and_hos():
    try:
        egate_checks = rbi.get_variable_value("${ENABLE_EGATE_CMD_CHECKS}")
        rbi.log_to_console(f'\n\nENABLE_EGATE_CMD_CHECKS is set to {egate_checks}\n')
        # Ensure the directory exists before writing to the file
        log_dir = rbi.get_variable_value("${TS_LOG_DIR}") + "/meas_reports"
        os.makedirs(log_dir, exist_ok=True)
        ca_ues_list = rbi.get_variable_value("${SA_CA_UES}")
        sa_ca_ues = ','.join(map(str, ca_ues_list))   # does for example: list [1,2,3] to string "1,2,3"
        ho_ues_list = rbi.get_variable_value("${SA_HO_UES}")
        sa_ho_ues = ','.join(map(str, ho_ues_list))
        nsa_ues_list = rbi.get_variable_value("${NSA_HO_UES}")
        nsa_ho_ues = ','.join(map(str, nsa_ues_list))

        #  Trigger A2 for HO preparation of SA UEs
        egate_object.execute_egate_command(
            cmd=f'ue_measurement_send_nr id={sa_ho_ues} meas_id=1 event=A2 rs_type=ssb srsrp_nr=5',
            alias="python_egate")
        time.sleep(1)
        for ue in ho_ues_list:
            log_ue_meas_disp(ue, "SA UEs AFTER A2 REPORT")

        #  Configure meas gap and trigger A2 for HO preparation of NSA UEs
        egate_object.execute_egate_command(
            cmd=f'ue_enb_param id={nsa_ho_ues} \
                measurement_gap=gp0:0 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered',
            alias='python_egate')
        time.sleep(1)

        egate_object.execute_egate_command(
            cmd=f'ue_measurement_send_nr id={nsa_ho_ues} meas_id=3 event=A2 rs_type=ssb srsrp_nr=5',
            alias='python_egate')
        time.sleep(1)
        for ue in nsa_ues_list:
            log_ue_meas_disp(ue, "NSA UEs AFTER A2 REPORT")

        if egate_checks is False:
            # Trigger A3 for SA handover start
            egate_object.execute_egate_command(
                cmd=f'ue_measurement_send_nr id={sa_ho_ues} meas_id=7 event=A3 srsrp_nr=50 phycell_id=54 nrsrp_nr=65',
                alias="python_egate")

            # Trigger A1 for SA SCell addition
            egate_object.execute_egate_command(
                cmd=f"ue_measurement_send_nr id={sa_ca_ues} meas_id=5 event=A1 srsrp_nr=100",
                alias="python_egate")

            # Trigger A3 for NSA handover start
            egate_object.execute_egate_command(
                cmd=f'ue_measurement_send_nr id={nsa_ho_ues} meas_id=8 event=A3 srsrp_nr=50 phycell_id=54 nrsrp_nr=65',
                alias="python_egate")
        else:
            # Trigger A3 for SA handover start and save egate output
            a3_event_response = egate_object.execute_egate_command_and_wait_for_data(
                cmd=f'ue_measurement_send_nr id={sa_ho_ues} meas_id=7 event=A3 srsrp_nr=50 phycell_id=54 nrsrp_nr=65',
                pass_regexp=r"Intra-eNB handover from EXT_ENB-2.7 to EXT_ENB-2.4 performed",
                alias="python_egate")
            ho_egate_log_path = log_dir + "/sa_handover_egate_output.txt"
            with open(ho_egate_log_path, 'w') as write_to_file:
                write_to_file.write(a3_event_response)  # logs will be saved after regexp confirmation from first UE
            time.sleep(1)

            # Trigger A1 for SA SCell addition and save egate output
            a1_egate_log_path = egate_object.execute_egate_command_and_wait_for_data(
                cmd=f"ue_measurement_send_nr id={sa_ca_ues} meas_id=5 event=A1 srsrp_nr=100",
                pass_regexp=r"SCellIndex 1 activated successfully at airphone",
                alias="python_egate")
            a1_log_path = log_dir + "/a1_fdd_scell_addition_egate_output.txt"
            with open(a1_log_path, 'w') as write_to_file:
                write_to_file.write(a1_egate_log_path)  # logs will be saved after regexp confirmation from first UE
            time.sleep(1)

            # Trigger A3 for NSA handover start and save egate output
            a3_event_response = egate_object.execute_egate_command_and_wait_for_data(
                cmd=f'ue_measurement_send_nr id={nsa_ho_ues} meas_id=8 event=A3 srsrp_nr=50 phycell_id=54 nrsrp_nr=65',
                pass_regexp=r"\(eNB 2 cell 4\) reported successful RA",
                alias="python_egate")
            ho_egate_log_path = log_dir + "/nsa_handover_egate_output.txt"
            with open(ho_egate_log_path, 'w') as write_to_file:
                write_to_file.write(a3_event_response)  # logs will be saved after regexp confirmation from first UE

        time.sleep(3)  # wait for all UEs

        # save meas ID output for each UE used for SA CA
        for ue in ca_ues_list:
            scell_log_path = log_dir + f"/a1_fdd_scell_addition_mp_ue{ue}.txt"
            get_ue_meas_disp(scell_log_path, ue, "AFTER SA A1 FDD SCELL ADDITION")

        # save meas ID output for each UE used for SA HO
        for ue in ho_ues_list:
            sa_ho_log_path = log_dir + f"/sa_handover_mp_ue{ue}.txt"
            get_ue_meas_disp(sa_ho_log_path, ue, "AFTER SA HANDOVER")

        # save meas ID output for each UE used for NSA HO
        for ue in nsa_ues_list:
            nsa_ho_log_path = log_dir + f"/nsa_handover_mp_ue{ue}.txt"
            get_ue_meas_disp(nsa_ho_log_path, ue, "AFTER NSA HANDOVER")

    except Exception as e:
        log_exception("trigger_a1_fdd_scell_addition_and_hos", e)


# =====================================================================================================[120 characters]
@log_begin_end_func_name
def trigger_a2_scell_release():
    try:
        egate_checks = rbi.get_variable_value("${ENABLE_EGATE_CMD_CHECKS}")
        sa_ca_ues = ','.join(map(str, rbi.get_variable_value("${SA_CA_UES}")))   # e.g. list [1,2,3] to string "1,2,3"
        log_dir = rbi.get_variable_value("${TS_LOG_DIR}") + "/meas_reports"

        if egate_checks is False:
            #  Trigger A2 for SCell release
            a2_event_response = egate_object.execute_egate_command(
                cmd=f"ue_measurement_send_nr id={sa_ca_ues} meas_id=6 event=A2 rs_type=ssb scell=1",
                alias="python_egate")
        else:
            #  Trigger A2 for SCell release and save egate output
            a2_event_response = egate_object.execute_egate_command_and_wait_for_data(
                cmd=f"ue_measurement_send_nr id={sa_ca_ues} meas_id=6 event=A2 rs_type=ssb scell=1",
                pass_regexp=r"<CONTEXT USER_MODIFY> \[UeId:0, BwpId:1, pcid:53, scellIdx:0\]",
                alias="python_egate")
            # save egate output
            a2_log_path = log_dir + "/a2_fdd_scell_release_egate_output.txt"
            with open(a2_log_path, 'w') as write_to_file:
                write_to_file.write(a2_event_response)   # logs will be saved only for the first UE

        time.sleep(3)  # wait for all UEs

        # save meas ID output for each UE used for CA
        for ue in rbi.get_variable_value("${SA_CA_UES}"):
            scell_log_path = log_dir + f"/a2_fdd_scell_release_mp_ue{ue}.txt"
            get_ue_meas_disp(scell_log_path, ue, "AFTER A2 SCELL RELEASE")

    except Exception as e:
        log_exception("trigger_a2_scell_release", e)


# =====================================================================================================[120 characters]
@log_begin_end_func_name
def get_ue_meas_disp(meas_disp_log_path, ue_id, log_identifier):
    try:
        ue_meas_txt = log_ue_meas_disp(ue_id, log_identifier)
        with open(meas_disp_log_path, 'w') as write_to_file:
            write_to_file.write(ue_meas_txt)
    except Exception as e:
        log_exception("get_ue_meas_disp", e)


# =====================================================================================================[120 characters]
@log_begin_end_func_name
def log_ue_meas_disp(ue_id, log_identifier):
    ue_meas_txt = egate_object.execute_egate_command_and_wait_for_data(
        alias="python_egate",
        cmd=f'ue_meas_disp id={ue_id}',
        pass_regexp=f'UE{ue_id} NR MEASUREMENT IDENTITIES:')
    rbi.log_to_console(f'\n\n\nMEASUREMENT REPORT {log_identifier}\n\n {ue_meas_txt}')
    return ue_meas_txt
