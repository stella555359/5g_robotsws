import logging
import json
import os
import importlib

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# ET or Feature Specific Libraries:
from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.CB013392.libraries.CB013392_tools import log_exception
from testsuite.Ulm.ET.CB013392.libraries.CB013392_verif_tools import (verifyParametersInScf,
                                                                      prepare_meas_profile_result_df,
                                                                      fill_meas_profile_df)

import numpy as np
import pandas as pd

a_profile = importlib.import_module(
    "testsuite.Ulm.ET.CB013392.CB013392-A.configurations.CB013392_A_profile")
e_profile = importlib.import_module(
    "testsuite.Ulm.ET.CB013392.CB013392-E.configurations.CB013392_E_profile")


# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]
rbi = BuiltIn()


# ====================================================================================================[120 characters]
#   Verification Functions
# ====================================================================================================[120 characters]
@log_begin_end_func_name
def verify_SCF_Parameters(testcase="", cell="", rel="2"):
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${PATH_TO_SCF_XML}")
    nrbts = rbi.get_variable_value("${NRBTS_STR}")[0]
    nrcell = nrbts + f"/NRCELL-{cell}"
    fdd_nrcell = nrbts + "/NRCELL-2"
    meas_ma_1 = nrbts + "/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1"
    meas_ma_2 = nrbts + "/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2"
    nrrel = nrbts + f"/NRCELL-{cell}/NRREL-{rel}"   # NRREL to FDD SCell

    try:
        common = [{'p_name': 'cellDepType', 'value': 'SA+NSA', 'dist_name': nrcell},
                  {'p_name': 'actMeasurementProfile', 'value': 'SA+NSA', 'dist_name': nrbts},
                  {'p_name': 'actMeasurementProfReselForCA', 'value': 'pcInSaUlCaSupported', 'dist_name': nrbts},
                  {'p_name': 'uePowerClass', 'value': 'ue-PowerClass2', 'dist_name': meas_ma_1},
                  {'p_name': 'uePowerClass', 'value': 'ue-PowerClass3', 'dist_name': meas_ma_2},
                  {'p_name': 'nrMeasPrIafDN', 'value': 'NRMEASPR_IAF-1', 'dist_name': meas_ma_1},
                  {'p_name': 'nrMeasPrIafDN', 'value': 'NRMEASPR_IAF-2', 'dist_name': meas_ma_2}
                  ]
        specific = []
        if testcase == "B1":
            specific = [{'p_name': 'sCellAdditionMethod', 'value': 'blind', 'dist_name': nrrel},
                        {'p_name': 'sCellOperationalMode', 'value': 'dlAndUl', 'dist_name': nrrel},
                        {'p_name': 'sCellActivationMethod', 'value': 'blind', 'dist_name': nrbts},
                        {'p_name': 'sCellDeactivationTimerGNB', 'value': 'infinity', 'dist_name': nrcell}]
        if testcase == "B2":
            fdd_scell_nrcell = nrbts + "/NRCELL-8"
            specific = [{'p_name': 'sCellAdditionMethod', 'value': 'covBasedA1', 'dist_name': nrrel},
                        {'p_name': 'sCellOperationalMode', 'value': 'dlAndUl', 'dist_name': nrrel},
                        {'p_name': 'sCellActivationMethod', 'value': 'blind', 'dist_name': nrbts},
                        {'p_name': 'sCellDeactivationTimerGNB', 'value': 'infinity', 'dist_name': nrcell},
                        {'p_name': 'pMaxNROwnCell', 'value': '29', 'dist_name': nrcell},
                        {'p_name': 'pMaxNROwnCell', 'value': '26', 'dist_name': fdd_scell_nrcell}]
        if testcase == "B3":
            fdd_scell_nrrel = nrbts + f"/NRCELL-{cell}/NRREL-1"
            tdd_scell_nrrel = nrbts + f"/NRCELL-{cell}/NRREL-2"   # REL to TDD SCell
            fdd_scell_nrcell = nrbts + f"/NRCELL-8"
            specific = [{'p_name': 'sCellAdditionMethod', 'value': 'covBasedA1', 'dist_name': tdd_scell_nrrel},
                        {'p_name': 'sCellOperationalMode', 'value': 'dlOnly', 'dist_name': tdd_scell_nrrel},
                        {'p_name': 'sCellAdditionMethod', 'value': 'covBasedA1', 'dist_name': fdd_scell_nrrel},
                        {'p_name': 'sCellOperationalMode', 'value': 'dlAndUl', 'dist_name': fdd_scell_nrrel},
                        {'p_name': 'sCellActivationMethod', 'value': 'blind', 'dist_name': nrbts},
                        {'p_name': 'sCellDeactivationTimerGNB', 'value': 'infinity', 'dist_name': nrcell},
                        {'p_name': 'pMaxNROwnCell', 'value': '29', 'dist_name': nrcell},
                        {'p_name': 'pMaxNROwnCell', 'value': '26', 'dist_name': fdd_scell_nrcell}]
        if testcase == "B5":
            fdd_nrcell = nrbts + "/NRCELL-8"
            specific = [{'p_name': 'sCellAdditionMethod', 'value': 'covBasedA1', 'dist_name': nrrel},
                        {'p_name': 'sCellOperationalMode', 'value': 'dlAndUl', 'dist_name': nrrel},
                        {'p_name': 'sCellActivationMethod', 'value': 'blind', 'dist_name': nrbts},
                        {'p_name': 'sCellDeactivationTimerGNB', 'value': 'infinity', 'dist_name': nrcell},
                        {'p_name': 'a2MeasSCellRelEnabled', 'value': 'rsrp', 'dist_name': nrcell},
                        {'p_name': 'a2MeasSCellRelEnabled', 'value': 'rsrp', 'dist_name': fdd_nrcell}]
        if testcase == "B6":
            specific = [{'p_name': 'pMaxNROwnCell', 'value': '23', 'dist_name': nrcell}]

        expected_scf_list = common + specific
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
        result_df = prepare_meas_profile_result_df(result_df, 'b1')
        # For A B1, get actual meas profile from ue_meas_disp EGATE command, so us_id as param is used
        ue_meas_disp_path = rbi.get_variable_value("${PATH_TO_REG_MP}")
        expected_meas = a_profile.B1_IAF_2
        # For ue_meas_disp based verification (is_from_rrc=False), no json created, so event_json_path is None
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
def verify_meas_profile_b2():
    is_meas_profile_correct = False
    result_df = pd.DataFrame()
    try:
        result_df = prepare_meas_profile_result_df(result_df, 'b2')
        ue_meas_disp_path = rbi.get_variable_value("${PATH_TO_A1_FDD_SCELL_ADD_MP}")
        expected_meas = a_profile.B2_IAF_2
        # TBD For ue_meas_disp based verification (is_from_rrc=False), no json created, so event_json_path is None
        result_df = fill_meas_profile_df(result_df, ue_meas_disp_path, expected_meas)
        logging.info(" Event measurement values: ")
        logging.info(result_df)
        is_meas_profile_correct = all(result_df['verdict'].values)

        logging.info("is_meas_profile_correct = %s" % is_meas_profile_correct)
    except Exception as e:
        log_exception("verify_meas_profile", e)
    rbi.should_be_true(is_meas_profile_correct)


# ====================================================================================================[120 characters]
def verify_meas_profile_b3():
    is_meas_profile_correct = False
    result_df = pd.DataFrame()
    try:
        result_df = prepare_meas_profile_result_df(result_df, 'b3')
        # Get actual meas profile after A1 triggered for FDD SCell using ue_meas_disp EGATE command
        fdd_ue_meas_disp_path = rbi.get_variable_value("${PATH_TO_A1_FDD_SCELL_ADD_MP}")
        result_df = fill_meas_profile_df(result_df, fdd_ue_meas_disp_path, a_profile.B3_IAF_2)
        logging.info(" Event measurement values after FDD SCell addition: ")
        logging.info(result_df)
        is_fdd_meas_profile_correct = all(result_df['verdict'].values)
        logging.info("is_meas_profile_correct_after_FDD_scell = %s" % is_fdd_meas_profile_correct)

        # Get actual meas profile after A1 triggered for TDD SCell using ue_meas_disp EGATE command
        tdd_ue_meas_disp_path = rbi.get_variable_value("${PATH_TO_A1_TDD_SCELL_ADD_MP}")
        # clear values in result df
        result_df.loc[:, 'actual_value'] = np.nan
        result_df.loc[:, 'expected_value'] = np.nan
        # For ue_meas_disp based verification (is_from_rrc=False), no json created, so event_json_path is None
        result_df = fill_meas_profile_df(result_df, tdd_ue_meas_disp_path, a_profile.B3_IAF_1)
        logging.info(" Event measurement values after TDD SCell addition: ")
        logging.info(result_df)
        is_tdd_meas_profile_correct = all(result_df['verdict'].values)
        logging.info("is_meas_profile_correct_after_TDD_scell = %s" % is_tdd_meas_profile_correct)
        is_meas_profile_correct = is_fdd_meas_profile_correct and is_tdd_meas_profile_correct

    except Exception as e:
        log_exception("verify_meas_profile", e)
    rbi.should_be_true(is_meas_profile_correct)


# ====================================================================================================[120 characters]
def verify_meas_profile_b3_robustness():
    is_meas_profile_correct = False
    result_df = pd.DataFrame()
    try:
        result_df = prepare_meas_profile_result_df(result_df, 'b3')
        # Get actual meas profile after A1 triggered for FDD SCell using ue_meas_disp EGATE command
        fdd_ue_meas_disp_path = rbi.get_variable_value("${PATH_TO_A1_FDD_SCELL_ADD_MP}")
        result_df = fill_meas_profile_df(result_df, fdd_ue_meas_disp_path, a_profile.B3_IAF_1)
        logging.info(" Event measurement values after FDD SCell addition: ")
        logging.info(result_df)
        is_fdd_meas_profile_correct = all(result_df['verdict'].values)
        logging.info("is_meas_profile_correct_after_FDD_scell = %s" % is_fdd_meas_profile_correct)

        # Get actual meas profile after A1 triggered for TDD SCell using ue_meas_disp EGATE command
        tdd_ue_meas_disp_path = rbi.get_variable_value("${PATH_TO_A1_TDD_SCELL_ADD_MP}")
        # clear values in result df
        result_df.loc[:, 'actual_value'] = np.nan
        result_df.loc[:, 'expected_value'] = np.nan
        # For ue_meas_disp based verification (is_from_rrc=False), no json created, so event_json_path is None
        result_df = fill_meas_profile_df(result_df, tdd_ue_meas_disp_path, a_profile.B3_IAF_2)
        logging.info(" Event measurement values after TDD SCell addition: ")
        logging.info(result_df)
        is_tdd_meas_profile_correct = all(result_df['verdict'].values)
        logging.info("is_meas_profile_correct_after_TDD_scell = %s" % is_tdd_meas_profile_correct)
        is_meas_profile_correct = is_fdd_meas_profile_correct and is_tdd_meas_profile_correct

    except Exception as e:
        log_exception("verify_meas_profile", e)
    rbi.should_be_true(is_meas_profile_correct)


# ====================================================================================================[120 characters]
@log_begin_end_func_name
def verify_meas_profile_b5():
    is_mp_correct = False
    result_df = pd.DataFrame()
    result_df_after_rel = pd.DataFrame()
    try:
        result_df = prepare_meas_profile_result_df(result_df, 'b5')
        result_df_after_rel = prepare_meas_profile_result_df(result_df_after_rel, 'a_b5')

        # Get actual meas profile after A1 triggered for FDD SCell addition using ue_meas_disp EGATE command
        ue_meas_disp_path = rbi.get_variable_value("${PATH_TO_A1_FDD_SCELL_ADD_MP}")
        # For ue_meas_disp based verification (is_from_rrc=False), no json created, so event_json_path is None
        result_df_after_rel = fill_meas_profile_df(result_df_after_rel, ue_meas_disp_path, a_profile.B2_IAF_2)
        logging.info("Event measurement values after FDD SCell addition: ")
        logging.info(result_df_after_rel)
        is_mp_correct_after_addition = all(result_df_after_rel['verdict'].values)
        logging.info("is_mp_correct_after_addition = %s" % is_mp_correct_after_addition)

        # Get actual meas profile after A2 triggered for FDD SCell release using ue_meas_disp EGATE command
        ue_meas_disp_path = rbi.get_variable_value("${PATH_TO_A2_FDD_SCELL_REL_MP}")
        # For ue_meas_disp based verification (is_from_rrc=False), no json created, so event_json_path is None
        result_df = fill_meas_profile_df(result_df, ue_meas_disp_path, a_profile.B2_IAF_1)
        logging.info("Event measurement values after FDD SCell release: ")
        logging.info(result_df)
        is_mp_correct_after_release = all(result_df['verdict'].values)
        logging.info("is_mp_correct_after_release = %s" % is_mp_correct_after_release)

        # overall verification
        is_mp_correct = is_mp_correct_after_addition and is_mp_correct_after_release
        logging.info("is_mp_correct = %s" % is_mp_correct)
    except Exception as e:
        log_exception("verify_meas_profile", e)
    rbi.should_be_true(is_mp_correct)


# ====================================================================================================[120 characters]
@log_begin_end_func_name
def verify_meas_profile_b6():
    is_meas_profile_correct = False
    result_df = pd.DataFrame()
    try:
        result_df = prepare_meas_profile_result_df(result_df, 'b6')
        # For A B1, get actual meas profile from ue_meas_disp EGATE command, so us_id as param is used
        ue_meas_disp_path = rbi.get_variable_value("${PATH_TO_REG_MP}")
        expected_meas = a_profile.B2_IAF_2
        # For ue_meas_disp based verification (is_from_rrc=False), no json created, so event_json_path is None
        result_df = fill_meas_profile_df(result_df, ue_meas_disp_path, expected_meas)
        logging.info(" Event measurement values: ")
        logging.info(result_df)
        is_meas_profile_correct = all(result_df['verdict'].values)

        logging.info("is_meas_profile_correct = %s" % is_meas_profile_correct)
    except Exception as e:
        log_exception("verify_meas_profile", e)
    rbi.should_be_true(is_meas_profile_correct)


@log_begin_end_func_name
def verify_meas_profile_e_b1_multiple_ue():
    is_meas_profile_correct = False
    result_df = pd.DataFrame()
    try:
        result_df = prepare_meas_profile_result_df(result_df, 'b1')
        # For HS B1, get actual meas profile from ue_meas_disp EGATE command, so us_id as param is used
        ts_log_path = rbi.get_variable_value("${ts_log_dir}")
        verification_result_list = list()
        ue_list = e_profile.get_pc1_ue()
        for ue_id in ue_list:
            ue_meas_disp_path = os.path.join(ts_log_path, f'ue_meas_profile_{ue_id}.txt')
            # For ue_meas_disp based verification (is_from_rrc=False), no json created, so event_json_path is None
            result_df = fill_meas_profile_df(result_df, ue_meas_disp_path, a_profile.B1_IAF_1)
            logging.info(f' Event measurement values for UE-{ue_id}: ')
            logging.info(result_df)
            verification_result_list.append(all(result_df['verdict'].values))

        ue_list = e_profile.get_ue_to_be_ho()
        for ue_id in ue_list:
            ue_meas_disp_path = os.path.join(ts_log_path, f'ue_meas_profile_{ue_id}.txt')
            # For ue_meas_disp based verification (is_from_rrc=False), no json created, so event_json_path is None
            result_df = fill_meas_profile_df(result_df, ue_meas_disp_path, a_profile.B1_IAF_2)
            logging.info(f' Event measurement values for UE-{ue_id}: ')
            logging.info(result_df)
            verification_result_list.append(all(result_df['verdict'].values))

        ue_list = e_profile.get_pc3_ue()
        for ue_id in ue_list:
            ue_meas_disp_path = os.path.join(ts_log_path, f'ue_meas_profile_{ue_id}.txt')
            # For ue_meas_disp based verification (is_from_rrc=False), no json created, so event_json_path is None
            result_df = fill_meas_profile_df(result_df, ue_meas_disp_path, e_profile.E1_IAF_3)
            logging.info(f' Event measurement values for UE-{ue_id}: ')
            logging.info(result_df)
            verification_result_list.append(all(result_df['verdict'].values))

        logging.info("verification_result_list = %s" % verification_result_list)
        is_meas_profile_correct = all(verification_result_list)
        logging.info("is_meas_profile_correct = %s" % is_meas_profile_correct)
    except Exception as e:
        log_exception("verify_meas_profile", e)
    logging.info("non_attached_ues_list")
    logging.info(rbi.get_variable_value("${non_attached_ues_list}"))
    rbi.should_be_true(is_meas_profile_correct)
