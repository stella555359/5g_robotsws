import logging
import json
import importlib

import numpy as np
import pandas as pd

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# ET or Feature Specific Libraries:
from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.CB013392.libraries.CB013392_verif_tools import (verifyParametersInScf,
                                                                      prepare_meas_profile_result_df,
                                                                      fill_meas_profile_df)
from testsuite.Ulm.ET.CB013392.libraries.CB013392_tools import log_exception

c_profile = importlib.import_module(
    "testsuite.Ulm.ET.CB013392.CB013392-C.configurations.CB013392_C_profile")

c_profile_AEQE = importlib.import_module(
    "testsuite.Ulm.ET.CB013392.CB013392-C.configurations.CB013392_C_profile_AEQE")

# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]
rbi = BuiltIn()
RED = '\033[31m'
RESET = '\033[0m'


# ====================================================================================================[120 characters]
#   Verification Functions
# ====================================================================================================[120 characters]
@log_begin_end_func_name
def verify_SCF_Parameters(testcase="", cell="11"):
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${PATH_TO_SCF_XML}")
    nrbts = rbi.get_variable_value("${NRBTS_STR}")[0]
    nrcell = nrbts + f"/NRCELL-{cell}"
    meas_ma_1 = nrbts + "/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1"
    meas_ma_2 = nrbts + "/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2"
    hoif_2 = nrbts + "/NRCELL-4/NRHOIF-2"
    try:
        common = [{'p_name': 'cellDepType', 'value': 'SA+NSA', 'dist_name': nrcell},
                  {'p_name': 'actMeasurementProfile', 'value': 'SA+NSA', 'dist_name': nrbts},
                  {'p_name': 'uePowerClass', 'value': 'ue-PowerClass2', 'dist_name': meas_ma_1},
                  {'p_name': 'uePowerClass', 'value': 'ue-PowerClass3', 'dist_name': meas_ma_2},
                  {'p_name': 'nrMeasPrIafDN', 'value': 'NRMEASPR_IAF-1', 'dist_name': meas_ma_1},
                  {'p_name': 'nrMeasPrIafDN', 'value': 'NRMEASPR_IAF-2', 'dist_name': meas_ma_2},
                  {'p_name': 'actMeasProfPowerCoordNSA', 'value': 'activated', 'dist_name': nrbts}
                  ]
        specific = []
        if testcase == "B8_TC01":
            nrmeasspr_iaf_1 = nrbts + "/NRMEAS_PROFILE-1/NRMEASPR_IAF-1"
            nrmeasspr_iaf_2 = nrbts + "/NRMEAS_PROFILE-1/NRMEASPR_IAF-2"
            specific = [{'p_name': 'nrMeasPrIafDN', 'value': nrmeasspr_iaf_1, 'dist_name': meas_ma_1},
                        {'p_name': 'nrMeasPrIafDN', 'value': nrmeasspr_iaf_2, 'dist_name': meas_ma_2}]
        if testcase == "B10_TC01":
            specific = [{'p_name': 'actHigherPrioFreqHo', 'value': 'NSA', 'dist_name': nrbts},
                        {'p_name': 'a4MeasHigherPrioFreqEnabled', 'value': 'rsrp', 'dist_name': hoif_2},
                        {'p_name': 'a4RetryTimer', 'value': '5', 'dist_name': nrcell}]
        if testcase == "B10_TC02":
            specific = [{'p_name': 'actHigherPrioFreqHo', 'value': 'NSA', 'dist_name': nrbts},
                        {'p_name': 'a4MeasHigherPrioFreqEnabled', 'value': 'rsrp', 'dist_name': hoif_2},
                        {'p_name': 'actA1HoPrefNRLayer', 'value': 'NSA', 'dist_name': nrbts}]
        logging.info(f"common = {json.dumps(common, indent=4)}")
        logging.info(f"specific = {json.dumps(specific, indent=4)}")
        expected_scf_dict = {f"{d['p_name']}_{d['dist_name']}": d for d in common}
        logging.info(f"expected_scf_dict = {json.dumps(expected_scf_dict, indent=4)}")
        expected_scf_dict.update({f"{d['p_name']}_{d['dist_name']}": d for d in specific})
        logging.info(f"expected_scf_dict = {json.dumps(expected_scf_dict, indent=4)}")
        expected_scf_list = list(expected_scf_dict.values())
        logging.info(f"expected_scf_list = {json.dumps(expected_scf_list, indent=4)}")
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        log_exception("verify_SCF_Paramaters", e)
    logging.info(f"is_SCF_correct = {is_SCF_correct}")
    rbi.should_be_true(is_SCF_correct)


# ====================================================================================================[120 characters]
@log_begin_end_func_name
def verify_meas_profile_b1():
    is_meas_profile_correct = False
    result_df = pd.DataFrame()
    try:
        result_df = prepare_meas_profile_result_df(result_df, 'c_b1')
        # For C B1, get actual meas profile from ue_meas_disp EGATE command, so us_id as param is used
        ue_meas_disp_path = rbi.get_variable_value("${path_to_reg_mp}")
        expected_meas = c_profile.B1_IAF_2

        # ue_meas_disp based verification
        result_df = fill_meas_profile_df(result_df, ue_meas_disp_path, expected_meas)
        logging.info(" Event measurement values: ")
        logging.info(result_df)
        is_meas_profile_correct = all(result_df['verdict'].values)

        logging.info("is_meas_profile_correct = %s" % is_meas_profile_correct)
    except Exception as e:
        log_exception("verify_meas_profile", e)
    rbi.should_be_true(is_meas_profile_correct)


# ====================================================================================================[120 characters]
@log_begin_end_func_name
def verify_meas_profile_b4():
    is_meas_profile_correct = False
    result_df = pd.DataFrame()
    try:
        # C_B4 uses the same measurement profile as C_B1
        result_df = prepare_meas_profile_result_df(result_df, 'c_b1')

        # get actual meas profile from ue_meas_disp EGATE command
        ts_log_dir = rbi.get_variable_value("${ts_log_dir}")
        path_to_mp = ts_log_dir + r"/meas_disp_after_HO.txt"

        # expected meas profile values
        expected_meas = c_profile.B1_IAF_2

        # ue_meas_disp based verification
        result_df = fill_meas_profile_df(result_df, path_to_mp, expected_meas)
        logging.info(" Event measurement values: ")
        logging.info(result_df)
        is_meas_profile_correct = all(result_df['verdict'].values)

        logging.info("is_meas_profile_correct = %s" % is_meas_profile_correct)
    except Exception as e:
        log_exception("verify_meas_profile", e)
    rbi.should_be_true(is_meas_profile_correct)


# ====================================================================================================[120 characters]
@log_begin_end_func_name
def verify_meas_profile_b7():
    is_meas_profile_correct = False
    result_df = pd.DataFrame()
    try:
        result_df = prepare_meas_profile_result_df(result_df, 'c_b7')

        # get actual meas profile from ue_meas_disp EGATE command
        ts_log_dir = rbi.get_variable_value("${ts_log_dir}")
        path_to_mp = ts_log_dir + r"/meas_disp_after_HO.txt"

        # expected meas profile values
        expected_meas = c_profile.B7_IAF_2

        # ue_meas_disp based verification
        result_df = fill_meas_profile_df(result_df, path_to_mp, expected_meas)
        logging.info(" Event measurement values: ")
        logging.info(result_df)
        is_meas_profile_correct = all(result_df['verdict'].values)

        logging.info("is_meas_profile_correct = %s" % is_meas_profile_correct)
    except Exception as e:
        log_exception("verify_meas_profile", e)
    rbi.should_be_true(is_meas_profile_correct)


# ====================================================================================================[120 characters]
@log_begin_end_func_name
def verify_meas_profile_b8():
    is_meas_profile_correct = False
    result_df = pd.DataFrame()
    try:
        result_df = prepare_meas_profile_result_df(result_df, 'c_b8')
        logging.info(result_df)
        ts_log_dir = rbi.get_variable_value("${ts_log_dir}")
        expected_meas = c_profile_AEQE.C_B8_IAF_2
        result_df = fill_meas_profile_df(result_df, ts_log_dir + r"/meas_disp_after_a2.txt", expected_meas)
        logging.info(" Event measurement values: ")
        logging.info(result_df)
        result_df = fill_meas_profile_df(result_df, ts_log_dir + r"/meas_disp_after_a1.txt", expected_meas)
        logging.info(" Event measurement values: ")
        logging.info(result_df)
        is_meas_profile_correct = all(result_df['verdict'].values)
        logging.info("is_meas_profile_correct = %s" % is_meas_profile_correct)
    except Exception as e:
        log_exception("verify_meas_profile", e)
    rbi.should_be_true(is_meas_profile_correct)


# ====================================================================================================[120 characters]
@log_begin_end_func_name
def verify_meas_profile_b10():
    is_meas_profile_correct = False
    result_df = pd.DataFrame()
    try:
        result_df = prepare_meas_profile_result_df(result_df, 'c_b10')

        # For C B10, get actual meas profile from ue_meas_disp EGATE command
        ts_log_dir = rbi.get_variable_value("${ts_log_dir}")
        path_to_mp = ts_log_dir + r"/meas_disp_with_A4.txt"

        # expected meas profile values
        expected_meas = c_profile.IEF_1

        # ue_meas_disp based verification
        result_df = fill_meas_profile_df(result_df, path_to_mp, expected_meas)
        logging.info(" Event measurement values: ")
        logging.info(result_df)
        is_meas_profile_correct = all(result_df['verdict'].values)

        logging.info("is_meas_profile_correct = %s" % is_meas_profile_correct)
    except Exception as e:
        log_exception("verify_meas_profile", e)
    rbi.should_be_true(is_meas_profile_correct)


if __name__ == '__main__':
    with open('/home/ute/logs/CB008127_MN_B01_Freq_band_change_NSA/2024-04-29T13-40-21-F/'
              'CB008127_MN_B01_Freq_band_change_NSA/SBTS00_ENB_9999_240428_000008/'
              '20240429_134046/Logs/scenario_1_attach.json', 'r',
              encoding='utf-8') as actual_results:
        results = json.load(actual_results)
    config_path = 'testsuite/Ulm/ET/CB008127/CB008127-HS-MN-MS/configurations/' \
                  'CB008127_MN/CB008127_MN_B01_profile.json'
    # detailed_result, overall = check_if_measurement_reports_are_set_correctly_json(results, config_path)
