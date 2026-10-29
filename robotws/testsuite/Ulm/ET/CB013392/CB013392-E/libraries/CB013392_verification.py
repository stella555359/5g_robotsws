import logging
import json
import importlib

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# ET or Feature Specific Libraries:
from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.CB013392.libraries.CB013392_tools import *
from testsuite.Ulm.ET.CB013392.libraries.CB013392_verif_tools import *

import numpy as np
import pandas as pd

a_profile = importlib.import_module(
    "testsuite.Ulm.ET.CB013392.CB013392-A.configurations.CB013392_A_profile")


# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]
rbi = BuiltIn()


# ====================================================================================================[120 characters]
#   Verification Functions
# ====================================================================================================[120 characters]
@log_begin_end_func_name
def verify_SCF_Parameters(testcase="", cell="11"):
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${path_to_scf_xml}")
    nrbts = rbi.get_variable_value("${nrbts_str}")[0]
    nrcell = nrbts + f"/NRCELL-{cell}"
    fdd_nrcell = nrbts + "/NRCELL-2"
    meas_ma_1 = nrbts + "/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-1"
    meas_ma_2 = nrbts + "/NRMEAS_PROFILE-1/NRMEASPR_MA_SA-2"
    fdd_scell_nrrel = nrbts + f"/NRCELL-{cell}/NRREL-2"  # NRREL to FDD SCell

    try:
        common = [{'p_name': 'cellDepType', 'value': 'SA+NSA', 'dist_name': nrcell},
                  {'p_name': 'actMeasurementProfile', 'value': 'SA+NSA', 'dist_name': nrbts},
                  {'p_name': 'actMeasurementProfReselForCA', 'value': 'pcInSaUlAndDlCaSupported', 'dist_name': nrbts},
                  {'p_name': 'uePowerClass', 'value': 'ue-PowerClass2', 'dist_name': meas_ma_1},
                  {'p_name': 'uePowerClass', 'value': 'ue-PowerClass3', 'dist_name': meas_ma_2},
                  {'p_name': 'nrMeasPrIafDN', 'value': 'NRMEASPR_IAF-1', 'dist_name': meas_ma_1},
                  {'p_name': 'nrMeasPrIafDN', 'value': 'NRMEASPR_IAF-2', 'dist_name': meas_ma_2}
                  ]
        specific = []
        if testcase == "B1":
            specific = [{'p_name': 'sCellAdditionMethod', 'value': 'blind', 'dist_name': fdd_scell_nrrel},
                        {'p_name': 'sCellOperationalMode', 'value': 'dlOnly', 'dist_name': fdd_scell_nrrel},
                        {'p_name': 'sCellActivationMethod', 'value': 'blind', 'dist_name': nrbts},
                        {'p_name': 'sCellDeactivationTimerGNB', 'value': 'infinity', 'dist_name': nrcell}]
        expected_scf_list = common + specific
        logging.info(f"expected_scf_list = {json.dumps(expected_scf_list, indent=4)}")
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        log_exception("verify_SCF_Paramaters", e)
    logging.info(f"is_SCF_correct = {is_SCF_correct}")
    rbi.should_be_true(is_SCF_correct)
