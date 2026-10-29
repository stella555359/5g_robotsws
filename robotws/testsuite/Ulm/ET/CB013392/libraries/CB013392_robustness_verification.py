import logging
import json
import importlib

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# ET or Feature Specific Libraries:
from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.CB013392.libraries.CB013392_robustness_tools import log_exception
from testsuite.Ulm.ET.CB013392.libraries.CB013392_robustness_verif_tools import (
    verify_parameters_in_scf,
    fill_meas_profile_df,
    prepare_meas_profile_result_df
)

import numpy as np
import pandas as pd

mp_profile = importlib.import_module("testsuite.Ulm.ET.CB013392.configurations.robustness_profile")


# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]
rbi = BuiltIn()


# ====================================================================================================[120 characters]
#   Verification Functions
# ====================================================================================================[120 characters]
@log_begin_end_func_name
def verify_scf_parameters(cell):
    is_scf_correct = False
    specific = []
    path_to_scf_xml = rbi.get_variable_value("${PATH_TO_SCF_XML}")
    nrbts = rbi.get_variable_value("${NRBTS_STR}")[0]
    nrcell = nrbts + f"/NRCELL-{cell}"
    meas_ma_sa_1 = nrbts + "/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1"
    meas_ma_sa_2 = nrbts + "/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2"
    meas_ma_nsa_1 = nrbts + "/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-1"
    meas_ma_nsa_2 = nrbts + "/NRMEAS_PROFILE-1/NRMEASPR_MA_NSA-2"
    nrrel = nrbts + f"/NRCELL-{cell}/NRREL-1"   # NRREL to FDD Cell-8

    try:
        common = [{'p_name': 'cellDepType', 'value': 'SA+NSA', 'dist_name': nrcell},
                  {'p_name': 'actMeasurementProfile', 'value': 'SA+NSA', 'dist_name': nrbts},
                  {'p_name': 'actMeasurementProfReselForCA', 'value': 'pcInSaUlAndDlCaSupported', 'dist_name': nrbts},
                  {'p_name': 'uePowerClass', 'value': 'ue-PowerClass2', 'dist_name': meas_ma_sa_1},
                  {'p_name': 'uePowerClass', 'value': 'ue-PowerClass3', 'dist_name': meas_ma_sa_2},
                  {'p_name': 'nrMeasPrIafDN', 'value': 'NRMEASPR_IAF-1', 'dist_name': meas_ma_sa_1},
                  {'p_name': 'nrMeasPrIafDN', 'value': 'NRMEASPR_IAF-2', 'dist_name': meas_ma_sa_2},
                  {'p_name': 'uePowerClass', 'value': 'ue-PowerClass2', 'dist_name': meas_ma_nsa_1},
                  {'p_name': 'uePowerClass', 'value': 'ue-PowerClass3', 'dist_name': meas_ma_nsa_2},
                  {'p_name': 'nrMeasPrIafDN', 'value': 'NRMEASPR_IAF-1', 'dist_name': meas_ma_nsa_1},
                  {'p_name': 'nrMeasPrIafDN', 'value': 'NRMEASPR_IAF-2', 'dist_name': meas_ma_nsa_2}
                  ]
        if cell == "3":
            specific = [{'p_name': 'sCellAdditionMethod', 'value': 'covBasedA1', 'dist_name': nrrel},
                        {'p_name': 'sCellOperationalMode', 'value': 'dlAndUl', 'dist_name': nrrel},
                        {'p_name': 'sCellActivationMethod', 'value': 'blind', 'dist_name': nrbts},
                        {'p_name': 'sCellDeactivationTimerGNB', 'value': 'infinity', 'dist_name': nrcell}]

        expected_scf_list = common + specific
        logging.info(f"expected_scf_list = {json.dumps(expected_scf_list, indent=4)}")
        is_scf_correct = verify_parameters_in_scf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        log_exception("verify_SCF_Paramaters", e)
    logging.info(f"is_scf_correct = {is_scf_correct}")
    rbi.should_be_true(is_scf_correct)


# ====================================================================================================[120 characters]
@log_begin_end_func_name
def verify_meas_profile_of_NSA_HO_UEs():
    ts_log_dir = rbi.get_variable_value("${TS_LOG_DIR}") + "/meas_reports"
    nsa_ues = rbi.get_variable_value("${NSA_HO_UES}")
    is_mp_correct_after_ho = False

    try:
        for ue in nsa_ues:
            # after A3 for NSA handover
            result_df_after_ho = pd.DataFrame()
            result_df_after_ho = prepare_meas_profile_result_df(result_df_after_ho, "NSA")
            actual_meas_profile = f"{ts_log_dir}/nsa_handover_mp_ue{ue}.txt"    # from ue_meas_disp
            expected_meas_profile = mp_profile.IAF_2_HO
            # Fills dataframe with actual and expected values and then compares them
            result_df_after_ho = fill_meas_profile_df(result_df_after_ho, actual_meas_profile, expected_meas_profile)
            logging.info(f"Event measurement values after NSA handover for UE{ue}: ")
            logging.info(result_df_after_ho)
            is_mp_correct_after_ho = all(result_df_after_ho['verdict'].values)
            logging.info(f"Is meas profile correct for UE{ue} after addition: {is_mp_correct_after_ho}")

    except Exception as e:
        log_exception("verify_meas_profile of NSA HA UEs", e)

    rbi.should_be_true(is_mp_correct_after_ho)


# ====================================================================================================[120 characters]
@log_begin_end_func_name
def verify_meas_profile_of_CA_UEs():
    ts_log_dir = rbi.get_variable_value("${TS_LOG_DIR}") + "/meas_reports"
    sa_ca_ues = rbi.get_variable_value("${SA_CA_UES}")
    all_mps_correct = False

    try:
        for ue in sa_ca_ues:
            # after A1 triggered FDD SCell addition
            result_df_after_add = pd.DataFrame()
            result_df_after_add = prepare_meas_profile_result_df(result_df_after_add, "SA")
            actual_meas_profile = f"{ts_log_dir}/a1_fdd_scell_addition_mp_ue{ue}.txt"    # from ue_meas_disp
            expected_meas_profile = mp_profile.IAF_2_CA
            # Fills dataframe with actual and expected values and then compares them
            result_df_after_add = fill_meas_profile_df(result_df_after_add, actual_meas_profile, expected_meas_profile)
            logging.info(f"Event measurement values after FDD SCell addition for UE{ue}: ")
            logging.info(result_df_after_add)
            is_mp_correct_after_addition = all(result_df_after_add['verdict'].values)
            logging.info(f"Is meas profile correct for UE{ue} after addition: {is_mp_correct_after_addition}")

            # after A2 triggered FDD SCell release
            result_df_after_rel = pd.DataFrame()
            result_df_after_rel = prepare_meas_profile_result_df(result_df_after_rel, "SA")
            actual_meas_profile = f"{ts_log_dir}/a2_fdd_scell_release_mp_ue{ue}.txt"    # from ue_meas_disp
            expected_meas_profile = mp_profile.IAF_1_CA
            # Fills dataframe with actual and expected values and then compares them
            result_df_after_rel = fill_meas_profile_df(result_df_after_rel, actual_meas_profile, expected_meas_profile)
            logging.info(f"Event measurement values after FDD SCell release for UE{ue}: ")
            logging.info(result_df_after_rel)
            is_mp_correct_after_release = all(result_df_after_rel['verdict'].values)
            logging.info(f"Is meas profile correct for UE{ue} after release: {is_mp_correct_after_release}")

        # overall verification
        all_mps_correct = is_mp_correct_after_addition and is_mp_correct_after_release

    except Exception as e:
        log_exception("verify_meas_profile of CA UEs", e)

    rbi.should_be_true(all_mps_correct)
