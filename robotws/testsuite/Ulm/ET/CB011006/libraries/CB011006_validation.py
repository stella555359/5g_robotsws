# =====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd68 for CB011006 Feature
# Team: 'SqdGp68'
# Email: 'I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com'
# -----------------------------------------------------------------------------------------------------[120 characters]

import logging
import os
import json

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# TAF & UTE Libraries:
from taf.config.scf import scf

# ET or Feature Specific Libraries:
import pandas as pd

from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.resources.SQD68.pmc_analysis import (verify_pm_counters,
                                                           prepare_for_pm_counter_testing,
                                                           finalise_pm_counter_testing)
from testsuite.Ulm.ET.L2.libraries.syslogs_analysis import check_no_fatality_error_in_syslogs
from testsuite.Ulm.ET.resources.tti_analysis.cellsetup_req_parser import extract_l1subpool_cell_relation
from testsuite.Ulm.ET.resources.tti_analysis.dtx import get_dtx_stats
from testsuite.Ulm.ET.resources.tti_analysis.plot_prballocation_per_subcell import plot_prb_allocation_per_subcell
from testsuite.Ulm.ET.resources.tti_analysis.load_metric_analysis import (run_load_based_prb_pooling_analysis,
                                                                          check_total_pooled_prbs)

# =====================================================================================================[120 characters]
#   Global Variables
# =====================================================================================================[120 characters]

RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()


# =====================================================================================================[120 characters]
#   Validation Functions
# =====================================================================================================[120 characters]

@log_begin_end_func_name
def verify_SCF_Parameters(subfeature="", cell=""):
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${path_to_scf_xml}")
    nrbts = rbi.get_variable_value("${nrbts_str}")[0]
    nrcell = nrbts + "/NRCELL-%s" % cell
    nrcell_fdd = nrbts + "/NRCELL-%s/NRCELL_FDD-1" % cell
    nrdu = nrbts + "/NRDU-1"
    nrrel = nrcell + "/NRREL-1"
    try:
        common = [{'p_name': 'chBwDl', 'value': '50MHz', 'dist_name': nrcell_fdd},
                  {'p_name': 'chBwUl', 'value': '50MHz', 'dist_name': nrcell_fdd}]
        specific = []
        if subfeature == "A":
            rmod = "MRBTS-1/EQM-1/APEQM-1/RMOD-%s" % cell
            bwp_initial = "MRBTS-1/NRBTS-1/BWP_PROFILE-4"
            bwp_dedicated = "MRBTS-1/NRBTS-1/BWP_PROFILE-33"
            specific = [{'p_name': 'actDl256Qam', 'value': 'true', 'dist_name': nrcell},
                        {'p_name': 'actUl256Qam', 'value': 'true', 'dist_name': nrcell},
                        {'p_name': 'pucchModeSelect', 'value': 'longPucch', 'dist_name': nrcell},
                        {'p_name': 'cRbSizeDl', 'value': 'n270', 'dist_name': bwp_initial},
                        {'p_name': 'cRbStartDl', 'value': 'crb0', 'dist_name': bwp_initial},
                        {'p_name': 'cRbSizeUl', 'value': 'sameAsDl', 'dist_name': bwp_initial},
                        {'p_name': 'cRbStartUl', 'value': 'sameAsDl', 'dist_name': bwp_initial},
                        {'p_name': 'cRbSizeDl', 'value': 'n270', 'dist_name': bwp_dedicated},
                        {'p_name': 'cRbStartDl', 'value': 'crb0', 'dist_name': bwp_dedicated},
                        {'p_name': 'cRbSizeUl', 'value': 'sameAsDl', 'dist_name': bwp_dedicated},
                        {'p_name': 'cRbStartUl', 'value': 'sameAsDl', 'dist_name': bwp_dedicated},
                        {'p_name': 'legacyWideCarrierMode', 'value': 'false', 'dist_name': rmod}]
        if subfeature == "B03":
            bwp_initial = "MRBTS-1/NRBTS-1/BWP_PROFILE-4"
            bwp_dedicated_1 = "MRBTS-1/NRBTS-1/BWP_PROFILE-33"
            bwp_dedicated_2 = "MRBTS-1/NRBTS-1/BWP_PROFILE-34"
            specific = [{'p_name': 'actMultipleDedicatedBWPs', 'value': 'true', 'dist_name': nrbts},
                        {'p_name': 'actDl256Qam', 'value': 'true', 'dist_name': nrcell},
                        {'p_name': 'actUl256Qam', 'value': 'true', 'dist_name': nrcell},
                        {'p_name': 'pucchModeSelect', 'value': 'longPucch', 'dist_name': nrcell},
                        {'p_name': 'cRbSizeDl', 'value': 'n106', 'dist_name': bwp_initial},
                        {'p_name': 'cRbStartDl', 'value': 'crb0', 'dist_name': bwp_initial},
                        {'p_name': 'cRbSizeUl', 'value': 'sameAsDl', 'dist_name': bwp_initial},
                        {'p_name': 'cRbStartUl', 'value': 'sameAsDl', 'dist_name': bwp_initial},
                        {'p_name': 'cRbSizeDl', 'value': 'n270', 'dist_name': bwp_dedicated_1},
                        {'p_name': 'cRbStartDl', 'value': 'crb0', 'dist_name': bwp_dedicated_1},
                        {'p_name': 'cRbSizeUl', 'value': 'sameAsDl', 'dist_name': bwp_dedicated_1},
                        {'p_name': 'cRbStartUl', 'value': 'sameAsDl', 'dist_name': bwp_dedicated_1},
                        {'p_name': 'cRbSizeDl', 'value': 'n106', 'dist_name': bwp_dedicated_2},
                        {'p_name': 'cRbStartDl', 'value': 'crb0', 'dist_name': bwp_dedicated_2},
                        {'p_name': 'cRbSizeUl', 'value': 'sameAsDl', 'dist_name': bwp_dedicated_2},
                        {'p_name': 'cRbStartUl', 'value': 'sameAsDl', 'dist_name': bwp_dedicated_2}]
        if subfeature == "B09" or subfeature == "B10":
            specific = [{'p_name': 'actBeamforming', 'value': 'false', 'dist_name': nrcell},
                        {'p_name': 'pMaxNROwnCell', 'value': '20', 'dist_name': nrcell},
                        {'p_name': 'pucchModeSelect', 'value': 'longPucch', 'dist_name': nrcell},
                        {'p_name': 'actCDrx', 'value': 'false', 'dist_name': nrcell},
                        {'p_name': 'actUlClosedLoopPwrCtrl', 'value': 'disabled', 'dist_name': nrcell},
                        {'p_name': 'lteNrDssMode', 'value': 'none', 'dist_name': nrcell},
                        {'p_name': 'actEnhMultipleDedicatedBWPs', 'value': 'false', 'dist_name': nrcell},
                        {'p_name': 'actPowerSavingBWP', 'value': 'false', 'dist_name': nrcell},
                        {'p_name': 'timingAdvanceOffset', 'value': 'n25600', 'dist_name': nrcell},
                        {'p_name': 'actK1Opt', 'value': 'intra-gNB', 'dist_name': nrcell},
                        {'p_name': 'sCellAdditionMethod', 'value': 'blind', 'dist_name': nrrel},
                        {'p_name': 'sCellOperationalMode', 'value': 'dlAndUl', 'dist_name': nrrel},
                        {'p_name': 'flexibleCAMode', 'value': 'NumberCellAmount', 'dist_name': nrdu},
                        {'p_name': 'dlToUlContributionRatio', 'value': '50', 'dist_name': nrdu},
                        {'p_name': 'actFdmScheduling', 'value': 'true', 'dist_name': nrbts},
                        {'p_name': 'actMultipleDedicatedBWPs', 'value': 'false', 'dist_name': nrbts},
                        {'p_name': 'actLteNrDss', 'value': 'false', 'dist_name': nrbts}]
        if subfeature == "B09" or (subfeature == "B13" and cell == "2"):
            common = [x for x in common if 'chBwDl' not in x.values()]
            common = [x for x in common if 'chBwUl' not in x.values()]
        if subfeature == "B13" and cell == "1":
            specific = [{'p_name': 'cellDepType', 'value': 'SA', 'dist_name': nrcell},
                        {'p_name': 'actCDrx', 'value': 'false', 'dist_name': nrcell},
                        {'p_name': 'nrDcAllowed', 'value': 'true', 'dist_name': nrrel},
                        {'p_name': 'actCarrierAggregationFr2SA', 'value': 'false', 'dist_name': nrbts},
                        {'p_name': 'freqBandIndicatorNR', 'value': '7', 'dist_name': nrcell}]
        if subfeature == "B13" and cell == "2":
            specific = [{'p_name': 'cellDepType', 'value': 'NR-DC-SN', 'dist_name': nrcell},
                        {'p_name': 'freqBandIndicatorNR', 'value': '258', 'dist_name': nrcell}]
        if subfeature == "B15":
            bwp_initial = "MRBTS-1/NRBTS-1/BWP_PROFILE-4"
            bwp_dedicated = "MRBTS-1/NRBTS-1/BWP_PROFILE-33"
            specific = [{'p_name': 'actPRBBlanking', 'value': 'true', 'dist_name': nrcell},
                        {'p_name': 'nbrOfBlankedPRBsLowEdgeDL', 'value': '12', 'dist_name': nrcell},
                        {'p_name': 'nbrOfBlankedPRBsLowEdgeUL', 'value': '12', 'dist_name': nrcell},
                        {'p_name': 'nbrOfBlankedPRBsHighEdgeDL', 'value': '15', 'dist_name': nrcell},
                        {'p_name': 'nbrOfBlankedPRBsHighEdgeUL', 'value': '15', 'dist_name': nrcell},
                        {'p_name': 'pucchModeSelect', 'value': 'longPucch', 'dist_name': nrcell},
                        {'p_name': 'cRbSizeDl', 'value': 'n243', 'dist_name': bwp_initial},
                        {'p_name': 'cRbStartDl', 'value': 'crb12', 'dist_name': bwp_initial},
                        {'p_name': 'cRbSizeUl', 'value': 'n243', 'dist_name': bwp_initial},
                        {'p_name': 'cRbStartUl', 'value': 'crb12', 'dist_name': bwp_initial},
                        {'p_name': 'cRbSizeDl', 'value': 'n270', 'dist_name': bwp_dedicated},
                        {'p_name': 'cRbStartDl', 'value': 'crb0', 'dist_name': bwp_dedicated},
                        {'p_name': 'cRbSizeUl', 'value': 'sameAsDl', 'dist_name': bwp_dedicated},
                        {'p_name': 'cRbStartUl', 'value': 'sameAsDl', 'dist_name': bwp_dedicated}]
        if subfeature == "B16" and cell == "3":
            bwp_initial = "MRBTS-1/NRBTS-1/BWP_PROFILE-4"
            bwp_dedicated = "MRBTS-1/NRBTS-1/BWP_PROFILE-33"
            specific = [{'p_name': 'actPRBBlanking', 'value': 'true', 'dist_name': nrcell},
                        {'p_name': 'nbrOfBlankedPRBsLowEdgeDL', 'value': '0', 'dist_name': nrcell},
                        {'p_name': 'nbrOfBlankedPRBsLowEdgeUL', 'value': '27', 'dist_name': nrcell},
                        {'p_name': 'nbrOfBlankedPRBsHighEdgeDL', 'value': '0', 'dist_name': nrcell},
                        {'p_name': 'nbrOfBlankedPRBsHighEdgeUL', 'value': '0', 'dist_name': nrcell},
                        {'p_name': 'pucchModeSelect', 'value': 'longPucch', 'dist_name': nrcell},
                        {'p_name': 'cRbSizeDl', 'value': 'n270', 'dist_name': bwp_initial},
                        {'p_name': 'cRbSizeUl', 'value': 'n243', 'dist_name': bwp_initial},
                        {'p_name': 'cRbStartUl', 'value': 'crb27', 'dist_name': bwp_initial},
                        {'p_name': 'cRbSizeDl', 'value': 'n270', 'dist_name': bwp_dedicated},
                        {'p_name': 'cRbSizeUl', 'value': 'sameAsDl', 'dist_name': bwp_dedicated}]
        if subfeature == "B16" and cell == "4":
            bwp_initial = "MRBTS-1/NRBTS-1/BWP_PROFILE-5"
            bwp_dedicated = "MRBTS-1/NRBTS-1/BWP_PROFILE-33"
            specific = [{'p_name': 'actPRBBlanking', 'value': 'false', 'dist_name': nrcell},
                        {'p_name': 'pucchModeSelect', 'value': 'longPucch', 'dist_name': nrcell},
                        {'p_name': 'cRbSizeDl', 'value': 'n270', 'dist_name': bwp_initial},
                        {'p_name': 'cRbSizeUl', 'value': 'sameAsDl', 'dist_name': bwp_initial}]
        if subfeature == "B19":
            bwp_initial = "MRBTS-1/NRBTS-1/BWP_PROFILE-4"
            bwp_dedicated_1 = "MRBTS-1/NRBTS-1/BWP_PROFILE-33"
            bwp_dedicated_2 = "MRBTS-1/NRBTS-1/BWP_PROFILE-34"
            bwp_dedicated_3 = "MRBTS-1/NRBTS-1/BWP_PROFILE-35"
            specific = [{'p_name': 'actMultipleDedicatedBWPs', 'value': 'true', 'dist_name': nrbts},
                        {'p_name': 'actPowerSavingBWP', 'value': 'true', 'dist_name': nrcell},
                        {'p_name': 'actPRBBlanking', 'value': 'false', 'dist_name': nrcell},
                        {'p_name': 'actLteNrDss', 'value': 'false', 'dist_name': nrbts},
                        {'p_name': 'actDl256Qam', 'value': 'true', 'dist_name': nrcell},
                        {'p_name': 'actUl256Qam', 'value': 'true', 'dist_name': nrcell},
                        {'p_name': 'pucchModeSelect', 'value': 'longPucch', 'dist_name': nrcell},
                        {'p_name': 'cRbSizeDl', 'value': 'n52', 'dist_name': bwp_initial},
                        {'p_name': 'cRbSizeDl', 'value': 'n270', 'dist_name': bwp_dedicated_1},
                        {'p_name': 'cRbSizeDl', 'value': 'n52', 'dist_name': bwp_dedicated_2},
                        {'p_name': 'cRbSizeDl', 'value': 'n106', 'dist_name': bwp_dedicated_3}]
        expected_scf_list = common + specific
        logging.info("expected_scf_list = %s" % json.dumps(expected_scf_list, indent=4))
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("verify_SCF_Paramaters", e)
    logging.info("is_SCF_correct = %s" % is_SCF_correct)
    rbi.should_be_true(is_SCF_correct)


@log_begin_end_func_name
def verify_CellSetup_SysCom_Traces(on_hw_string=""):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # - new CSM should get activated and the L1 subpool type should become asymmetrical
    # - one L1 subpool must have 2 cells in which UL PRB pooling takes place
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_SysCom_correct = False
    path_to_syscom_pdml = rbi.get_variable_value("${path_to_syscom_pdml}")
    if on_hw_string == "on mixed Cell setup":
        expected_phycell_ul_subcell = {50: 1, 51: 0, 52: 0}
        expected_l1_subcell_pool_lcr_id = {0: [2, 3], 1: [1]}
    else:
        expected_phycell_ul_subcell = {50: 0, 51: 1, 52: 0}
        expected_l1_subcell_pool_lcr_id = {0: [1, 3], 1: [2]}
    try:
        l1_subcell_pool_lcr_id, phycell_ul_subcell = extract_l1subpool_cell_relation(path_to_syscom_pdml)
        is_SysCom_correct = ((expected_phycell_ul_subcell == phycell_ul_subcell) and
                             (expected_l1_subcell_pool_lcr_id == l1_subcell_pool_lcr_id))
        logging.info("phycell_ul_subcell = %s" % (phycell_ul_subcell))
        logging.info("l1_subcell_pool_lcr_id = %s" % (l1_subcell_pool_lcr_id))
    except Exception as e:
        logException("verify_CellSetup_SysCom_Traces", e)
    rbi.should_be_true(is_SysCom_correct)


@log_begin_end_func_name
def verify_Tput(*args):
    scenario = rbi.get_variable_value("${scenario}")
    pm_counters_dir = rbi.get_variable_value("${pm_counters_dir}")
    is_tput_correct = False
    try:
        expected_tput_dict = {int(cell): {dir_1: int(tput_1), dir_2: int(tput_2)}
                              for cell, dir_1, tput_1, dir_2, tput_2 in (element.split(':') for element in args)}
        logging.info("expected_tput_dict = %s" % json.dumps(expected_tput_dict, indent=4))
        logging.info("scenario = %s" % (scenario))
        logging.info("pm_counters_dir = %s" % (pm_counters_dir))
        file_path = pm_counters_dir + "/pmc_average_tp_per_scenario_per_cell.json"
        if os.path.isfile(file_path):
            logging.info("TPut .json file exists: %s" % file_path)
            with open(file_path, 'r') as f:
                tput_dict = json.load(f)[scenario]
                logging.info("tput_dict = %s" % json.dumps(tput_dict, indent=4))
                verdicts = []
                for cell in expected_tput_dict.keys():
                    reported_tput_dl = int(round(tput_dict['MRBTS-1/NRBTS-1/NRCELL-%s' % cell]['throughput_dl']))
                    expected_tput_dl = expected_tput_dict[cell]["dl"]
                    verdicts.append(int(abs(reported_tput_dl-expected_tput_dl)*100/expected_tput_dl) <= 5)
                    reported_tput_ul = int(round(tput_dict['MRBTS-1/NRBTS-1/NRCELL-%s' % cell]['throughput_ul']))
                    expected_tput_ul = expected_tput_dict[cell]["ul"]
                    verdicts.append(int(abs(reported_tput_ul-expected_tput_ul)*100/expected_tput_ul) <= 5)
                logging.info("verdicts = %s" % verdicts)
            if verdicts:
                is_tput_correct = all(verdicts)
        else:
            logging.info("TPut .json file does NOT exists: %s" % file_path)
    except Exception as e:
        logException("verify_Tput", e)
    rbi.should_be_true(is_tput_correct)


@log_begin_end_func_name
def verify_minimal_Tput(*args):
    scenario = rbi.get_variable_value("${scenario}")
    pm_counters_dir = rbi.get_variable_value("${pm_counters_dir}")
    is_tput_correct = False
    try:
        expected_tput_dict = {int(cell): {dir_1: int(tput_1), dir_2: int(tput_2)}
                              for cell, dir_1, tput_1, dir_2, tput_2 in (element.split(':') for element in args)}
        logging.info("expected_tput_dict = %s" % json.dumps(expected_tput_dict, indent=4))
        logging.info("scenario = %s" % (scenario))
        logging.info("pm_counters_dir = %s" % (pm_counters_dir))
        file_path = pm_counters_dir + "/pmc_average_tp_per_scenario_per_cell.json"
        if os.path.isfile(file_path):
            logging.info("TPut .json file exists: %s" % file_path)
            with open(file_path, 'r') as f:
                tput_dict = json.load(f)[scenario]
                logging.info("tput_dict = %s" % json.dumps(tput_dict, indent=4))
                verdicts = []
                for cell in expected_tput_dict.keys():
                    reported_tput_dl = int(round(tput_dict['MRBTS-1/NRBTS-1/NRCELL-%s' % cell]['throughput_dl']))
                    expected_tput_dl = expected_tput_dict[cell]["dl"]
                    verdicts.append(int(reported_tput_dl) > int(expected_tput_dl))
                    reported_tput_ul = int(round(tput_dict['MRBTS-1/NRBTS-1/NRCELL-%s' % cell]['throughput_ul']))
                    expected_tput_ul = expected_tput_dict[cell]["ul"]
                    verdicts.append(int(reported_tput_ul) > int(expected_tput_ul))
                logging.info("verdicts = %s" % verdicts)
            if verdicts:
                is_tput_correct = all(verdicts)
        else:
            logging.info("TPut .json file does NOT exists: %s" % file_path)
    except Exception as e:
        logException("verify_minimal_Tput", e)
    rbi.should_be_true(is_tput_correct)


@log_begin_end_func_name
def verify_Tput_CA_2cells(tput_string, ca_mode):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # tput_string = "pcell:scell:dir1:tput1:dir2:tput2", e.g. "3:1:dl:500:ul:200"
    # ca_mode = "dlOnly" or "dlAndUl"
    # -------------------------------------------------------------------------------------------------[120 characters]
    scenario = rbi.get_variable_value("${scenario}")
    pm_counters_dir = rbi.get_variable_value("${pm_counters_dir}")
    is_tput_correct = False
    logging.info("tput_string = %s" % str(tput_string))
    logging.info("ca_mode = %s" % str(ca_mode))
    try:
        expected_tput_list = [{"pcell": pcell, "scell": scell, dir1: int(tput1), dir2: int(tput2)}
                              for pcell, scell, dir1, tput1, dir2, tput2 in [tput_string.split(':')]]
        logging.info("expected_tput_list = %s" % json.dumps(expected_tput_list, indent=4))
        logging.info("scenario = %s" % (scenario))
        logging.info("pm_counters_dir = %s" % (pm_counters_dir))
        file_path = pm_counters_dir + "/pmc_average_tp_per_scenario_per_cell.json"
        if os.path.isfile(file_path):
            logging.info("TPut .json file exists: %s" % file_path)
            with open(file_path, 'r') as f:
                tput_dict = json.load(f)[scenario]
                logging.info("tput_dict = %s" % json.dumps(tput_dict, indent=4))
                verdicts = []
                for ca_set in expected_tput_list:
                    dist_name_pcell = "MRBTS-1/NRBTS-1/NRCELL-%s" % ca_set["pcell"]
                    dist_name_scell = "MRBTS-1/NRBTS-1/NRCELL-%s" % ca_set["scell"]
                    # ---------------------------------------------------------------------------------[120 characters]
                    reported_tput_dl_pcell = int(round(tput_dict[dist_name_pcell]['throughput_dl']))
                    reported_tput_dl_scell = int(round(tput_dict[dist_name_scell]['throughput_dl']))
                    reported_tput_dl_both = reported_tput_dl_pcell + reported_tput_dl_scell
                    logging.info("reported_tput_dl_both = %s" % (reported_tput_dl_both))
                    expected_tput_dl = ca_set["dl"]
                    verdicts.append(int(abs(reported_tput_dl_both-expected_tput_dl)*100/expected_tput_dl) <= 5)
                    # ---------------------------------------------------------------------------------[120 characters]
                    reported_tput_ul_pcell = int(round(tput_dict[dist_name_pcell]['throughput_ul']))
                    reported_tput_ul_scell = int(round(tput_dict[dist_name_scell]['throughput_ul']))
                    reported_tput_ul_both = reported_tput_ul_pcell + reported_tput_ul_scell
                    logging.info("reported_tput_ul_both = %s" % (reported_tput_ul_both))
                    expected_tput_ul = ca_set["ul"]
                    verdicts.append(int(abs(reported_tput_ul_both-expected_tput_ul)*100/expected_tput_ul) <= 5)
                    # ---------------------------------------------------------------------------------[120 characters]
                    verdicts.append(reported_tput_dl_scell > 0)  # <--- check that SCell TPut is NOT zero
                    # ---------------------------------------------------------------------------------[120 characters]
                    if ca_mode == "dlAndUl":
                        verdicts.append(reported_tput_ul_scell > 0)  # <--- check that SCell TPut is NOT zero
                logging.info("verdicts = %s" % verdicts)
            if verdicts:
                is_tput_correct = all(verdicts)
        else:
            logging.info("TPut .json file does NOT exists: %s" % file_path)
    except Exception as e:
        logException("verify_Tput_CA_2cells", e)
    rbi.should_be_true(is_tput_correct)


@log_begin_end_func_name
def verify_Tput_CA_4cells(tput_string, ca_mode):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # tput_string = "pcell:scell1:scell2:scell3:dir1:tput1:dir2:tput2", e.g. "4:1:2:3:dl:500:ul:200"
    # ca_mode = "dlOnly" or "dlAndUl"
    # -------------------------------------------------------------------------------------------------[120 characters]
    scenario = rbi.get_variable_value("${scenario}")
    pm_counters_dir = rbi.get_variable_value("${pm_counters_dir}")
    is_tput_correct = False
    logging.info("tput_string = %s" % str(tput_string))
    logging.info("ca_mode = %s" % str(ca_mode))
    try:
        expected_tput_list = [{"pcell": pcell,
                               "scell1": scell1, "scell2": scell2, "scell3": scell3,
                               dir1: int(tput1), dir2: int(tput2)}
                              for pcell, scell1, scell2, scell3, dir1, tput1, dir2, tput2 in [tput_string.split(':')]]
        logging.info("expected_tput_list = %s" % json.dumps(expected_tput_list, indent=4))
        logging.info("scenario = %s" % (scenario))
        logging.info("pm_counters_dir = %s" % (pm_counters_dir))
        file_path = pm_counters_dir + "/pmc_average_tp_per_scenario_per_cell.json"
        if os.path.isfile(file_path):
            logging.info("TPut .json file exists: %s" % file_path)
            with open(file_path, 'r') as f:
                tput_dict = json.load(f)[scenario]
                logging.info("tput_dict = %s" % json.dumps(tput_dict, indent=4))
                verdicts = []
                for ca_set in expected_tput_list:
                    dist_name_pcell = "MRBTS-1/NRBTS-1/NRCELL-%s" % ca_set["pcell"]
                    dist_name_scell1 = "MRBTS-1/NRBTS-1/NRCELL-%s" % ca_set["scell1"]
                    dist_name_scell2 = "MRBTS-1/NRBTS-1/NRCELL-%s" % ca_set["scell2"]
                    dist_name_scell3 = "MRBTS-1/NRBTS-1/NRCELL-%s" % ca_set["scell3"]
                    # ---------------------------------------------------------------------------------[120 characters]
                    reported_tput_dl_pcell = int(round(tput_dict[dist_name_pcell]['throughput_dl']))
                    reported_tput_dl_scell1 = int(round(tput_dict[dist_name_scell1]['throughput_dl']))
                    reported_tput_dl_scell2 = int(round(tput_dict[dist_name_scell2]['throughput_dl']))
                    reported_tput_dl_scell3 = int(round(tput_dict[dist_name_scell3]['throughput_dl']))
                    reported_tput_dl_all = (reported_tput_dl_pcell + reported_tput_dl_scell1 +
                                            reported_tput_dl_scell2 + reported_tput_dl_scell3)
                    logging.info("reported_tput_dl_all = %s" % (reported_tput_dl_all))
                    expected_tput_dl = ca_set["dl"]
                    verdicts.append(int(abs(reported_tput_dl_all-expected_tput_dl)*100/expected_tput_dl) <= 5)
                    # ---------------------------------------------------------------------------------[120 characters]
                    reported_tput_ul_pcell = int(round(tput_dict[dist_name_pcell]['throughput_ul']))
                    reported_tput_ul_scell1 = int(round(tput_dict[dist_name_scell1]['throughput_ul']))
                    reported_tput_ul_scell2 = int(round(tput_dict[dist_name_scell2]['throughput_ul']))
                    reported_tput_ul_scell3 = int(round(tput_dict[dist_name_scell3]['throughput_ul']))
                    reported_tput_ul_all = (reported_tput_ul_pcell + reported_tput_ul_scell1 +
                                            reported_tput_ul_scell2 + reported_tput_ul_scell3)
                    logging.info("reported_tput_ul_all = %s" % (reported_tput_ul_all))
                    expected_tput_ul = ca_set["ul"]
                    verdicts.append(int(abs(reported_tput_ul_all-expected_tput_ul)*100/expected_tput_ul) <= 5)
                    # ---------------------------------------------------------------------------------[120 characters]
                    verdicts.append(reported_tput_dl_scell1 > 0)  # <--- check that SCell-1 TPut is NOT zero
                    verdicts.append(reported_tput_dl_scell2 > 0)  # <--- check that SCell-2 TPut is NOT zero
                    verdicts.append(reported_tput_dl_scell3 > 0)  # <--- check that SCell-3 TPut is NOT zero
                    # ---------------------------------------------------------------------------------[120 characters]
                    if ca_mode == "dlAndUl":
                        verdicts.append(reported_tput_ul_scell1 > 0)  # <--- check that SCell-1 TPut is NOT zero
                        verdicts.append(reported_tput_ul_scell2 > 0)  # <--- check that SCell-2 TPut is NOT zero
                        verdicts.append(reported_tput_ul_scell3 > 0)  # <--- check that SCell-3 TPut is NOT zero
                logging.info("verdicts = %s" % verdicts)
            if verdicts:
                is_tput_correct = all(verdicts)
        else:
            logging.info("TPut .json file does NOT exists: %s" % file_path)
    except Exception as e:
        logException("verify_Tput_CA_4cells", e)
    rbi.should_be_true(is_tput_correct)


@log_begin_end_func_name
def verify_DTX_Statistics(direction='ul'):
    is_DTX_ok = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = get_df_from_pkl(path_to_ttitrace_pkl, direction=direction)
    logging.info("df = \n%s" % (df))
    try:
        output_df = get_dtx_stats(df, by='lcrId', return_dtx_df=False, direction=direction)
        logging.info("output_df = \n%s" % (output_df))
        average_nondtx_percentage = output_df[('Percentage', 'NON_DTX')].mean()
        logging.info("average_nondtx_percentage = %s" % average_nondtx_percentage)
        is_DTX_ok = not average_nondtx_percentage < 99.0
    except Exception as e:
        logException("verify_DTX_Statistics", e)
    rbi.should_be_true(is_DTX_ok)


@log_begin_end_func_name
def verify_TTITraces_for_loadbase(expected_total_prbs=352, subcell_expecting_higher_prb_allocation=0):
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    try:
        excluded_samples = 1000
        plot_prb_allocation_per_subcell(path_to_ttitrace_pkl)
        plot_prb_allocation_per_subcell(path_to_ttitrace_pkl, excluded_samples)
        subcell_high = subcell_expecting_higher_prb_allocation
        is_TTITrace_correct = run_load_based_prb_pooling_analysis(path_to_ttitrace_pkl,
                                                                  subcell_expecting_higher_prb_allocation=subcell_high,
                                                                  list_of_pooled_subcells=[0, 2],
                                                                  list_of_non_pooled_subcells=[1],
                                                                  exclude_samples_for_analysis=excluded_samples,
                                                                  expected_total_prbs=int(expected_total_prbs))
        logging.info("is_TTITrace_correct = %s" % (is_TTITrace_correct))
    except Exception as e:
        logException("verify_TTITraces_for_loadbase", e)
    rbi.should_be_true(is_TTITrace_correct)


@log_begin_end_func_name
def verify_TTITraces_for_loadbase_with_equal_tput(expected_total_prbs=409, on_hw_string=""):
    # Supported Arguments: on_hw_string = None | "on ABIP"
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    path_to_syscom_pdml = rbi.get_variable_value("${path_to_syscom_pdml}")
    try:
        excluded_samples = 1000
        plot_prb_allocation_per_subcell(path_to_ttitrace_pkl)
        plot_prb_allocation_per_subcell(path_to_ttitrace_pkl, excluded_samples)
        list_of_pooled_subcells = [0, 4] if on_hw_string == "on ABIP" else [0, 2]
        list_of_non_pooled_subcells = [2] if on_hw_string == "on ABIP" else [1]
        is_TTITrace_correct = check_total_pooled_prbs(path_to_ttitrace_pkl,
                                                      list_of_pooled_subcells=list_of_pooled_subcells,
                                                      list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                      exclude_samples_for_analysis=excluded_samples,
                                                      expected_total_prbs=int(expected_total_prbs),
                                                      expected_compliance_percentage=95)
        logging.info("is_TTITrace_correct = %s" % (is_TTITrace_correct))
    except Exception as e:
        logException("verify_TTITraces_for_loadbase", e)
    rbi.should_be_true(is_TTITrace_correct)


@log_begin_end_func_name
def verify_pmc(subfeature="", details=""):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # subfeature - any test helping to destinguish verification
    # details - any test helping to identify the details
    # -------------------------------------------------------------------------------------------------[120 characters]
    logging.info("subfeature = %s" % subfeature)
    logging.info("details = %s" % details)
    pmc_file = rbi.get_variable_value("${pm_counters_dir}") + "/pmCounters.csv"
    pmc_index = rbi.get_variable_value("${pmc_index}")
    nrbts_str = rbi.get_variable_value("${nrbts_str}")[0]
    column = -(pmc_index+3)
    logging.info("pmc_file = %s" % pmc_file)
    logging.info("column = %s" % column)
    are_pmcs_correct = None
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        if subfeature == "4CC" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell1": int(scell1),
                                 "scell2": int(scell2),
                                 "scell3": int(scell3),
                                 "num_of_ues": int(num_of_ues)}
                                for cells, pcell, scell1, scell2, scell3, ues, num_of_ues in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55138C03001": cells_under_test["num_of_ues"],  # GNB_SCELL_3_ADMI_REQ_SA
                             "M55138C03002": cells_under_test["num_of_ues"],  # GNB_SCELL_3_ADMI_SUCC_SA
                             "M55139C03001": cells_under_test["num_of_ues"],  # GNB_DU_SCELL_3_ADMI_REQ_SA
                             "M55139C03002": cells_under_test["num_of_ues"],  # GNB_DU_SCELL_3_ADMI_SUCC_SA
                             "M55118C09503": cells_under_test["num_of_ues"],  # RRC_RECONF_ADD3DLSCELL_ATT_SA
                             "M55118C09502": cells_under_test["num_of_ues"]}  # RRC_RECONF_ADD3DLSCELL_SUCC_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            # -----------------------------------------------------------------------------------------[120 characters]
            expected_pmcs = {"M55316C09000": cells_under_test["num_of_ues"]}  # SCell activations
            for cell_id in range(1, 4):
                cell = cells_under_test["scell%s" % cell_id]
                verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts)
    except Exception as e:
        logException("verify_pmc", e)
    if are_pmcs_correct is None:
        are_pmcs_correct = False
    logging.info("are_pmcs_correct = %s" % are_pmcs_correct)
    rbi.should_be_true(are_pmcs_correct)


# =====================================================================================================[120 characters]
#   Private Functions
# =====================================================================================================[120 characters]

@log_begin_end_func_name
def get_df_from_pkl(path_to_pickle, direction):
    sw_build = rbi.get_variable_value("${sw_build}")
    logging.info("sw_build = %s" % sw_build)
    ackNack = 'dlHarqRxDataArray.ackNack' if direction == 'dl' else 'ulHarqRxData.crcResult'
    txNumber = '{}FdSchedData.txNumber'.format(direction)
    mcsTable = '{}FdSchedData.mcsTable'.format(direction)
    laMode = '{}FdSchedData.laMode'.format(direction)
    if direction == 'dl':
        targetBLER = 'dlFdSchedAdditionalData.targetBLER'
    elif any(x in sw_build for x in ['SBTS25R3', 'SBTS26R1']):
        targetBLER = 'ulFdSchedData.targetBLER'
    else:
        targetBLER = 'ulFdSchedAdditionalData.targetBLER'
    usedMcs = '{}FdSchedData.rrm{}UsedMcs'.format(direction, direction.capitalize())
    proposedMcs = '{}FdSchedData.rrm{}ProposedMcs'.format(direction, direction.capitalize())
    dtx = 'dlHarqRxDataArray.dtx' if direction == 'dl' else 'ulHarqRxData.dtx'
    prb = '???' if direction == 'dl' else 'ulTdSchedSubcellData.numAllocCellPrbUl'
    # -------------------------------------------------------------------------------------------------[120 characters]
    df = pd.read_pickle(path_to_pickle)
    if direction == 'dl':
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', ackNack, txNumber, mcsTable, dtx,
                 laMode, targetBLER, usedMcs, proposedMcs]]
    else:
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', ackNack, txNumber, mcsTable, dtx,
                 laMode, targetBLER, usedMcs, proposedMcs, prb]]
    return df


@log_begin_end_func_name
def verifyParametersInScf(verifyScfList, scfFilePath):
    isPassed = True
    scfObj = scf()
    for parameter in verifyScfList:
        returnedValue = 0
        try:
            scfObj.load_scf(scfFilePath)
            returnedValue = get_scf_value(scfObj, parameter["p_name"], parameter["dist_name"])
            aResult = (returnedValue == parameter["value"])
        except Exception as e:
            logException("verifyParametersInScf", e, silent=True)
            aResult = "SCF is NOT available"
            isPassed = False
        else:
            isPassed = (isPassed and aResult)
        logging.info(30*"-" + "> %s == %s (%s)" % (parameter["value"], returnedValue, aResult))
    return isPassed


def get_scf_value(scfObj, pName, distName):
    outString = ""
    logging.info("get_scf_value(): pName = %s" % (pName))
    logging.info("get_scf_value(): outString = %s" % (outString))
    try:
        outString = scfObj.get_value_from_scf(p_name=pName, dist_name=distName)
        outString = "true" if outString == "True" else outString
        outString = "false" if outString == "False" else outString
        logging.info("get_scf_value(): '%s' = '%s' (SCF)" % (pName, outString))
    except Exception as e:
        logException("get_scf_value", e)
    return outString


@log_begin_end_func_name
def logException(functionNameStr, e, silent=False):
    logging.info("%s(): Exception = <%s>" % (functionNameStr, str(e)))
    if not silent:
        rbi.log_to_console("\n" + RED + "  %s: exception happend (see log.html)" % functionNameStr + RESET + "")
