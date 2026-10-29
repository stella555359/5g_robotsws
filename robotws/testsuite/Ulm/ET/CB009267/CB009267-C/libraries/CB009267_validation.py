# ====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd68 for CB011006 Feature
# Team: 'SqdGp68'
# Email: 'I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

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
                                                           get_pm_counters,
                                                           prepare_for_pm_counter_testing,
                                                           finalise_pm_counter_testing)
from testsuite.Ulm.ET.resources.tti_analysis.dtx import get_dtx_stats
from testsuite.Ulm.ET.resources.tti_analysis.helper_functions import display_df_as_html

from testsuite.Ulm.ET.resources.tti_analysis.plot_prballocation_per_subcell import plot_prb_allocation_per_subcell
from testsuite.Ulm.ET.resources.tti_analysis.load_metric_analysis import (run_load_based_prb_pooling_analysis,
                                                                          check_total_pooled_prbs)
from testsuite.Ulm.ET.CB008246.libraries.ttitrace_analysis import (plot_df_with_scatter, plot_graph_hr_vs_br)

# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()


# ====================================================================================================[120 characters]
#   Validation Functions
# ====================================================================================================[120 characters]

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
        common = [{'p_name': 'actCarAgPmCount', 'value': 'true', 'dist_name': nrbts}]
        specific = []
        if subfeature == "SA FR1 <--- EXAMPLE":
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
        expected_scf_list = common + specific
        logging.info("expected_scf_list = %s" % json.dumps(expected_scf_list, indent=4))
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("verify_SCF_Paramaters", e)
    logging.info("is_SCF_correct = %s" % is_SCF_correct)
    rbi.should_be_true(is_SCF_correct)


@log_begin_end_func_name
def verify_ttitraces(direction='ul', subfeature="", details=""):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # subfeature - any test helping to destinguish verification
    # details - any test helping to identify the details
    # -------------------------------------------------------------------------------------------------[120 characters]
    are_ttitraces_correct = []
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        # ---------------------------------------------------------------------------------------------[120 characters]
        if direction == 'ul':
            path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_ul_pkl}")
            Fb = 'ulLaDeltaSinr.crcFb'
            rrmPauseUeScheduling = 'ulLaDeltaSinr.rrmPauseUeInUlScheduling'
        else:
            path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_dl_pkl}")
            Fb = 'dlLaDeltaCqiArray.harqFb'
            rrmPauseUeScheduling = 'dlLaDeltaCqiArray.rrmPauseUeInDlScheduling'
        # ---------------------------------------------------------------------------------------------[120 characters]
        df = get_df_from_pkl(path_to_ttitrace_pkl, direction=direction)
        logging.info("df = \n%s" % (df))
        plot_graph_hr_vs_br(path_to_ttitrace_pkl, direction)
        plot_for(df, rrmPauseUeScheduling)
        plot_for(df, Fb)

        if subfeature == "PM_1851_FR1" or subfeature == "PM_1755_FR1":
            are_ttitraces_correct.append(validate_scell_deactivation_due_to_overheating(
                path_to_ttitrace_pkl, subfeature))

        # ---------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_ttitraces", e)
    logging.info("are_ttitraces_correct=%s" % are_ttitraces_correct)
    rbi.should_be_true(all(are_ttitraces_correct))


@log_begin_end_func_name
def validate_scell_deactivation_due_to_overheating(path_to_pickle, subfeature):
    try:
        df = pd.read_pickle(path_to_pickle)
        df_filtered = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId',
                          'dlRemoteSCellOHDeactivationData.maxNumberOfActiveSCellsDl',
                          'dlRemoteSCellOHDeactivationData.numActiveRemoteSCells',
                          'dlRemoteSCellOHDeactivationData.maxNumberOfActiveSCellsUl',
                          'dlRemoteSCellOHDeactivationData.numActiveRemoteSCellsUl',
                          'dlRemoteSCellOHDeactivationData.currentSCellMask',
                          'dlRemoteSCellOHDeactivationData.decisionMask',
                          'dlRemoteSCellOHDeactivationData.legacyOhMask',
                          'dlRemoteSCellOHDeactivationData.rlqMask']].dropna(
                              subset=['dlRemoteSCellOHDeactivationData.decisionMask'])
        logging.info("df_filtered=")
        display_df_as_html(df_filtered)
        verdicts = []
        verdicts.append(
            (df_filtered['dlRemoteSCellOHDeactivationData.maxNumberOfActiveSCellsDl'] == 0).all())
        verdicts.append(
            (df_filtered['dlRemoteSCellOHDeactivationData.maxNumberOfActiveSCellsUl'] == 0).all())
        verdicts.append(
            (df_filtered['dlRemoteSCellOHDeactivationData.numActiveRemoteSCells'] == 1).all())
        verdicts.append(
            (df_filtered['dlRemoteSCellOHDeactivationData.numActiveRemoteSCellsUl'] == 1).all())
        verdicts.append((
            df_filtered['dlRemoteSCellOHDeactivationData.currentSCellMask'] == 2).all())  # current cellMask=0x2=0010
        verdicts.append((
            df_filtered['dlRemoteSCellOHDeactivationData.decisionMask'] == 2).all())  # decisionMask=0x2=0010
        if (subfeature == "PM_1851_FR1"):
            verdicts.append((
                df_filtered['dlRemoteSCellOHDeactivationData.legacyOhMask'] == 2).all())  # legacyOhMask=0x2=0010
        else:
            verdicts.append((
                df_filtered['dlRemoteSCellOHDeactivationData.legacyOhMask'] == 0).all())  # legacyOhMask=0x2=0010
        logging.info("verdicts=%s" % verdicts)
    except Exception as e:
        logException("validate_scell_deactivation_due_to_overheating", e)
    return all(verdicts)


@log_begin_end_func_name
def log_Tput(*args):
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
        logException("log_Tput", e)


@log_begin_end_func_name
def log_Tput_CA_2cells(tput_string, ca_mode, criteria="equal"):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # tput_string = "pcell:scell:dir1:tput1:dir2:tput2", e.g. "3:1:dl:500:ul:200"
    # ca_mode = "dlOnly" or "dlAndUl"
    # -------------------------------------------------------------------------------------------------[120 characters]
    scenario = rbi.get_variable_value("${scenario}")
    pm_counters_dir = rbi.get_variable_value("${pm_counters_dir}")
    is_tput_correct = False
    logging.info("tput_string = %s" % str(tput_string))
    logging.info("ca_mode = %s" % str(ca_mode))
    logging.info("criteria = %s" % str(criteria))
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
                    if criteria == "minimal":
                        verdicts.append(int(reported_tput_dl_both) > int(expected_tput_dl))
                    else:
                        verdicts.append(int(abs(reported_tput_dl_both-expected_tput_dl)*100/expected_tput_dl) <= 5)
                    # ---------------------------------------------------------------------------------[120 characters]
                    reported_tput_ul_pcell = int(round(tput_dict[dist_name_pcell]['throughput_ul']))
                    reported_tput_ul_scell = int(round(tput_dict[dist_name_scell]['throughput_ul']))
                    reported_tput_ul_both = reported_tput_ul_pcell + reported_tput_ul_scell
                    logging.info("reported_tput_ul_both = %s" % (reported_tput_ul_both))
                    expected_tput_ul = ca_set["ul"]
                    if criteria == "minimal":
                        verdicts.append(int(reported_tput_ul_both) > int(expected_tput_ul))
                    else:
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
        logException("log_Tput_CA_2cells", e)


@log_begin_end_func_name
def log_Tput_CA_4cells(tput_string, ca_mode, criteria="equal"):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # tput_string = "pcell:scell1:scell2:scell3:dir1:tput1:dir2:tput2", e.g. "4:1:2:3:dl:500:ul:200"
    # ca_mode = "dlOnly" or "dlAndUl"
    # -------------------------------------------------------------------------------------------------[120 characters]
    scenario = rbi.get_variable_value("${scenario}")
    pm_counters_dir = rbi.get_variable_value("${pm_counters_dir}")
    is_tput_correct = False
    logging.info("tput_string = %s" % str(tput_string))
    logging.info("ca_mode = %s" % str(ca_mode))
    logging.info("criteria = %s" % str(criteria))
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
                    if criteria == "minimal":
                        verdicts.append(int(reported_tput_dl_all) > int(expected_tput_dl))
                    else:
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
                    if criteria == "minimal":
                        verdicts.append(int(reported_tput_ul_all) > int(expected_tput_ul))
                    else:
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
        logException("log_Tput_CA_4cells", e)


@log_begin_end_func_name
def verify_DTX_Statistics(direction='ul'):
    is_DTX_ok = False
    if direction == 'ul':
        path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_ul_pkl}")
    else:
        path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_dl_pkl}")
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
    path_to_ttitrace_ul_pkl = rbi.get_variable_value("${path_to_ttitrace_ul_pkl}")
    try:
        excluded_samples = 1000
        plot_prb_allocation_per_subcell(path_to_ttitrace_ul_pkl)
        plot_prb_allocation_per_subcell(path_to_ttitrace_ul_pkl, excluded_samples)
        subcell_high = subcell_expecting_higher_prb_allocation
        is_ttitrace_correct = run_load_based_prb_pooling_analysis(path_to_ttitrace_ul_pkl,
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
def verify_TTITraces_for_loadbase_with_equal_tput(expected_total_prbs=409):
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct = False
    path_to_ttitrace_ul_pkl = rbi.get_variable_value("${path_to_ttitrace_ul_pkl}")
    try:
        excluded_samples = 1000
        plot_prb_allocation_per_subcell(path_to_ttitrace_ul_pkl)
        plot_prb_allocation_per_subcell(path_to_ttitrace_ul_pkl, excluded_samples)
        list_of_pooled_subcells = [0, 2]
        list_of_non_pooled_subcells = [1]
        is_ttitrace_correct = check_total_pooled_prbs(path_to_ttitrace_ul_pkl,
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
    scenario = rbi.get_variable_value("${scenario}")
    logging.info('scenario: %s', scenario)
    pmc_timestamps = rbi.get_variable_value("${PMC_SCENARIO_DICT}")[scenario]["timestamps"]
    pmc_timestamp = pmc_timestamps[:1]
    logging.info('timestamp: %s', pmc_timestamp)
    with open(pmc_file, 'r', encoding='utf-8') as csv_file:
        header_line = csv_file.readlines()[0]
    headers = header_line.split(';')
    csv_column = None
    for index, header in enumerate(headers):
        if any(ts in header for ts in pmc_timestamp):
            logging.info('found timestamp in pmcounter.csv: %s', index)
            csv_column = index
    nrbts_str = rbi.get_variable_value("${nrbts_str}")[0]
    path_to_ttitrace_dl_pkl = rbi.get_variable_value("${path_to_ttitrace_dl_pkl}")
    path_to_ttitrace_ul_pkl = rbi.get_variable_value("${path_to_ttitrace_ul_pkl}")
    column = csv_column
    logging.info("pmc_file = %s" % pmc_file)
    are_pmcs_correct = None
    sw_build = rbi.get_variable_value("${sw_build}")
    logging.info("sw_build = %s" % sw_build)
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        if "PM_1772" in subfeature and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            # -----------------------------------------------------------------------------------------[120 characters]
            legacy_piid_list = ["M55316C03000",  # P(S)Cell UEs with 0 activated SCell in DL
                                "M55316C04000"]  # P(S)Cell UEs with 0 activated SCells in UL
            reported_values = get_pm_counters(pmc_file, column, cell, legacy_piid_list)
            expected_pmcs = {"M55316C15030": reported_values["M55316C03000"],  # PSCELL_UE_0_ACT_SCELL_DL_SA
                             "M55316C15038": reported_values["M55316C04000"]}  # PSCELL_UE_0_ACT_SCELL_UL_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs,
                                               verification_type="verify_is_lower"))
            is_any_nonzero_for_0_ACT = any(value != 0 for key, value in expected_pmcs.items())
            logging.info("is_any_nonzero_for_0_ACT = %s" % is_any_nonzero_for_0_ACT)
            # -----------------------------------------------------------------------------------------[120 characters]
            legacy_piid_list = ["M55316C03001",  # P(S)Cell UEs with 1..7 activated SCell in DL
                                "M55316C03002",  # 2
                                "M55316C03003",  # 3
                                "M55316C03004",  # 4
                                "M55316C03005",  # 5
                                "M55316C03006",  # 6
                                "M55316C03007",  # 7
                                "M55316C04001",  # P(S)Cell UEs with 1..3 activated SCells in UL
                                "M55316C04002",  # 2
                                "M55316C04003"]  # 3
            reported_values = get_pm_counters(pmc_file, column, cell, legacy_piid_list)
            expected_pmcs = {"M55316C15031": reported_values["M55316C03001"],  # PSCELL_UE_[1..7]_ACT_SCELL_DL_SA
                             "M55316C15032": reported_values["M55316C03002"],  # 2
                             "M55316C15033": reported_values["M55316C03003"],  # 3
                             "M55316C15034": reported_values["M55316C03004"],  # 4
                             "M55316C15035": reported_values["M55316C03005"],  # 5
                             "M55316C15036": reported_values["M55316C03006"],  # 6
                             "M55316C15037": reported_values["M55316C03007"],  # 7
                             "M55316C15039": reported_values["M55316C04001"],  # PSCELL_UE_[1..3]_ACT_SCELL_UL_SA
                             "M55316C15040": reported_values["M55316C04002"],  # 2
                             "M55316C15041": reported_values["M55316C04003"]}  # 3
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            is_any_nonzero = any(value != 0 for key, value in expected_pmcs.items())
            logging.info("is_any_nonzero = %s" % is_any_nonzero)
            # --- UPD0001 -----------------------------------------------------------------------------[120 characters]
            if '25R1' in sw_build or '23R4' in sw_build:
                logging.info("IMPORTANT: UPD0001 is not supported by this SW Release")
                is_any_nonzero_upd = True
            else:
                cell = cells_under_test["scell"]
                legacy_piid_list = ["M55316C09000"]  # Num of successful SCell activations
                reported_values = get_pm_counters(pmc_file, column, cell, legacy_piid_list)
                expected_pmcs = {"M55316C15075": reported_values["M55316C09000"],  # Num of Succ DL SCell Act for SA
                                 "M55316C15076": reported_values["M55316C09000"]}  # Num of Succ UL SCell Act for SA
                verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
                is_any_nonzero_upd = any(value != 0 for key, value in expected_pmcs.items())
            logging.info("is_any_nonzero_upd = %s" % is_any_nonzero_upd)
            # -----------------------------------------------------------------------------------------[120 characters]
            conditions_met = is_any_nonzero and is_any_nonzero_for_0_ACT and is_any_nonzero_upd
            are_pmcs_correct = all(verdicts) if conditions_met else False
            # -----------------------------------------------------------------------------------------[120 characters]
        if "PM_1777" in subfeature and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            # -----------------------------------------------------------------------------------------[120 characters]
            legacy_piid_list = ["M55316C03000",  # P(S)Cell UEs with 0 activated SCell in DL
                                "M55316C04000"]  # P(S)Cell UEs with 0 activated SCells in UL
            reported_values = get_pm_counters(pmc_file, column, cell, legacy_piid_list)
            expected_pmcs = {"M55316C15063": reported_values["M55316C03000"],  # PSCELL_UE_0_ACT_SCELL_DL_NSA
                             "M55316C15071": reported_values["M55316C04000"]}  # PSCELL_UE_0_ACT_SCELL_UL_NSA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs,
                                               verification_type="verify_is_lower"))
            # -----------------------------------------------------------------------------------------[120 characters]
            legacy_piid_list = ["M55316C03001",  # P(S)Cell UEs with 1..7 activated SCell in DL
                                "M55316C03002",  # 2
                                "M55316C03003",  # 3
                                "M55316C03004",  # 4
                                "M55316C03005",  # 5
                                "M55316C03006",  # 6
                                "M55316C03007",  # 7
                                "M55316C04001",  # P(S)Cell UEs with 1..3 activated SCells in UL
                                "M55316C04002",  # 2
                                "M55316C04003"]  # 3
            reported_values = get_pm_counters(pmc_file, column, cell, legacy_piid_list)
            expected_pmcs = {"M55316C15064": reported_values["M55316C03001"],  # PSCELL_UE_[1..7]_ACT_SCELL_DL_NSA
                             "M55316C15065": reported_values["M55316C03002"],  # 2
                             "M55316C15066": reported_values["M55316C03003"],  # 3
                             "M55316C15067": reported_values["M55316C03004"],  # 4
                             "M55316C15068": reported_values["M55316C03005"],  # 5
                             "M55316C15069": reported_values["M55316C03006"],  # 6
                             "M55316C15070": reported_values["M55316C03007"],  # 7
                             "M55316C15072": reported_values["M55316C04001"],  # PSCELL_UE_[1..3]_ACT_SCELL_UL_NSA
                             "M55316C15073": reported_values["M55316C04002"],  # 2
                             "M55316C15074": reported_values["M55316C04003"]}  # 3
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            is_any_nonzero = any(value != 0 for key, value in expected_pmcs.items())
            logging.info("is_any_nonzero = %s" % is_any_nonzero)
            # --- UPD0001 -----------------------------------------------------------------------------[120 characters]
            if '25R1' in sw_build or '23R4' in sw_build:
                logging.info("IMPORTANT: UPD0001 is not supported by this SW Release")
                is_any_nonzero_upd = True
            else:
                cell = cells_under_test["scell"]
                legacy_piid_list = ["M55316C09000"]  # Num of successful SCell activations
                reported_values = get_pm_counters(pmc_file, column, cell, legacy_piid_list)
                if "FR1" in subfeature:
                    expected_pmcs = {"M55316C15077": reported_values["M55316C09000"]}  # Num of Succ DL SCell Act (NSA)
                else:  # FR2 support DL and UL CA for NSA UEs
                    expected_pmcs = {"M55316C15077": reported_values["M55316C09000"],  # Num of Succ DL SCell Act (NSA)
                                     "M55316C15078": reported_values["M55316C09000"]}  # Num of Succ UL SCell Act (NSA)
                verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
                is_any_nonzero_upd = any(value != 0 for key, value in expected_pmcs.items())
            logging.info("is_any_nonzero_upd = %s" % is_any_nonzero_upd)
            # -----------------------------------------------------------------------------------------[120 characters]
            conditions_met = is_any_nonzero and is_any_nonzero_upd
            are_pmcs_correct = all(verdicts) if conditions_met else False
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1744_FR1_tdd_pcell" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15010": 0,  # SCELL_UL_SUSPEND_UEOVHT_SA
                             "M55316C15011": 0}  # SCELL_DL_SUSPEND_UEOVHT_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell"]
            expected_pmcs = {"M55316C15010": 1,
                             "M55316C15011": 1}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1744_FR1_fdd_pcell" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15010": 0,
                             "M55316C15011": 0}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell"]
            expected_pmcs = {"M55316C15010": 2,
                             "M55316C15011": 2}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if (subfeature == "PM_1077") and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["scell"]
            legacy_piid_list = ["M55316C09004",  # Num of SCell UL scheduled suspending due to slot aggregation
                                "M55316C09005"]  # SCell deactivations due to SAG
            reported_values = get_pm_counters(pmc_file, column, cell, legacy_piid_list)
            expected_pmcs = {"M55316C15004": reported_values["M55316C09004"],  # SCELL_UL_SUSPEND_SAG_SA
                             "M55316C15018": reported_values["M55316C09005"]}  # SCELL_DL_DEACT_SAG_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_expected_piids_nonzero = expected_pmcs["M55316C15018"] != 0
            are_pmcs_correct = all(verdicts) if are_expected_piids_nonzero else False
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1823_FR2" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell), "scell1": int(scell1),
                                 "scell2": int(scell2), "scell3": int(scell3)}
                                for cells, pcell, scell1, scell2, scell3 in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            # SCell recovery should only be visible on PCell
            expected_pmcs = {"M55316C15016": 2}  # SCELL_SUSP_RECOV_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell1"]
            expected_pmcs = {"M55316C15016": 0}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell2"]
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell3"]
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1824_FR2" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell), "scell1": int(scell1),
                                 "scell2": int(scell2), "scell3": int(scell3),
                                 "scell4": int(scell4), "scell5": int(scell5)}
                                for cells, pcell, scell1, scell2, scell3, scell4, scell5 in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            number_of_UEOVHT_susp_in_all_scells = 0
            number_of_UEOVHT_susp_in_all_scells += \
                verify_PM_1824_and_1826_dlAndUl_SCELLs(
                    pmc_file, column, cells_under_test["scell1"], verdicts, subfeature)
            number_of_UEOVHT_susp_in_all_scells += \
                verify_PM_1824_and_1826_dlAndUl_SCELLs(
                    pmc_file, column, cells_under_test["scell2"], verdicts, subfeature)
            number_of_UEOVHT_susp_in_all_scells += \
                verify_PM_1824_and_1826_dlAndUl_SCELLs(
                    pmc_file, column, cells_under_test["scell3"], verdicts, subfeature)
            number_of_UEOVHT_susp_in_all_scells += \
                verify_PM_1824_dlOnly_SCELLs(pmc_file, column, cells_under_test["scell4"], verdicts)
            number_of_UEOVHT_susp_in_all_scells += \
                verify_PM_1824_dlOnly_SCELLs(pmc_file, column, cells_under_test["scell5"], verdicts,
                                             scell_activation_expected=False)
            verify_PM_1824_and_1826_PCELL(pmc_file, column, cells_under_test["pcell"],
                                          number_of_UEOVHT_susp_in_all_scells, verdicts, subfeature)
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1826_FR2" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell), "scell1": int(scell1),
                                 "scell2": int(scell2), "scell3": int(scell3)}
                                for cells, pcell, scell1, scell2, scell3 in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            number_of_UEOVHT_susp_in_all_scells = 0
            number_of_UEOVHT_susp_in_all_scells += \
                verify_PM_1824_and_1826_dlAndUl_SCELLs(
                    pmc_file, column, cells_under_test["scell1"], verdicts, subfeature,
                    scell_activation_expected=False)
            number_of_UEOVHT_susp_in_all_scells += \
                verify_PM_1824_and_1826_dlAndUl_SCELLs(
                    pmc_file, column, cells_under_test["scell2"], verdicts, subfeature)
            number_of_UEOVHT_susp_in_all_scells += \
                verify_PM_1824_and_1826_dlAndUl_SCELLs(
                    pmc_file, column, cells_under_test["scell3"], verdicts, subfeature,
                    scell_activation_expected=False)
            verify_PM_1824_and_1826_PCELL(pmc_file, column, cells_under_test["pcell"],
                                          number_of_UEOVHT_susp_in_all_scells, verdicts, subfeature)
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1754_FR2" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell), "scell1": int(scell1),
                                 "scell2": int(scell2), "scell3": int(scell3),
                                 "scell4": int(scell4), "scell5": int(scell5)}
                                for cells, pcell, scell1, scell2, scell3, scell4, scell5 in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))

            df_dl = pd.read_pickle(path_to_ttitrace_dl_pkl)
            df_ul = pd.read_pickle(path_to_ttitrace_ul_pkl)
            dlCurrentCellActiveMask = 'dlSCellActivationData.currentCellActiveMask'
            dlRlqDeactMask = 'dlSCellActivationData.dlRlqDeactMask'
            dlCheckCount = 'dlSCellActivationData.checkCount'
            dlLatestResult = 'dlSCellActivationData.latestResult'
            dlDecisionCellMask = 'dlSCellActivationData.decisionCellMask'

            df_dl = df_dl[['timeStamp', 'rnti', 'sfn', 'slot', 'lcrId', dlCurrentCellActiveMask, dlRlqDeactMask,
                           dlCheckCount, dlLatestResult, dlDecisionCellMask]].dropna(subset=[dlCurrentCellActiveMask])
            df_dl_checkCount_3 = df_dl[df_dl[dlCheckCount] == 3]
            df_dl_checkCount_3_SCELL_deact = \
                df_dl_checkCount_3[(df_dl_checkCount_3[dlLatestResult] == 'BUFFERBASEDDEACTIVATE') |
                                   (df_dl_checkCount_3[dlLatestResult] == 'RLQBASEDDEACTIVATE') |
                                   (df_dl_checkCount_3[dlLatestResult] == 'ACTIVATE')]
            rbi.log("df_dl_checkCount_3_SCELL_deact:")
            display_df_as_html(df_dl_checkCount_3_SCELL_deact)

            ulCurrentCellActiveMask = 'ulSCellActivationData.currentUlCellActiveMask'
            ulRlqDeactMask = 'ulSCellActivationData.ulRlqDeactMask'
            ulCheckCount = 'ulSCellActivationData.checkCount'
            ulLatestResult = 'ulSCellActivationData.ulLatestResult'
            ulProposalCellMask = 'ulSCellActivationData.ulProposalMask'

            df_ul = df_ul[['timeStamp', 'rnti', 'sfn', 'slot', 'lcrId', ulCurrentCellActiveMask, ulRlqDeactMask,
                           ulCheckCount, ulLatestResult, ulProposalCellMask]].dropna(subset=[ulProposalCellMask])
            df_ul_checkCount_3 = df_ul[df_ul[ulCheckCount] == 3]
            df_ul_checkCount_3_SCELL_deact = \
                df_ul_checkCount_3[(df_ul_checkCount_3[ulLatestResult] == 'BUFFERBASEDDEACTIVATE') |
                                   (df_ul_checkCount_3[ulLatestResult] == 'RLQBASEDDEACTIVATE') |
                                   (df_ul_checkCount_3[ulLatestResult] == 'ACTIVATE')]
            rbi.log("df_ul_checkCount_3_SCELL_deact:")
            display_df_as_html(df_ul_checkCount_3_SCELL_deact)

            verdicts = []
            verify_PM_1754_PCELL(pmc_file, column, cells_under_test["pcell"], verdicts)
            verify_PM_1754_dlAndUl_SCELLs(pmc_file, column, cells_under_test["scell1"], verdicts,
                                          df_dl_checkCount_3_SCELL_deact, dlLatestResult, dlDecisionCellMask,
                                          df_ul_checkCount_3_SCELL_deact, ulLatestResult, ulProposalCellMask)
            verify_PM_1754_dlAndUl_SCELLs(pmc_file, column, cells_under_test["scell2"], verdicts,
                                          df_dl_checkCount_3_SCELL_deact, dlLatestResult, dlDecisionCellMask,
                                          df_ul_checkCount_3_SCELL_deact, ulLatestResult, ulProposalCellMask)
            verify_PM_1754_dlAndUl_SCELLs(pmc_file, column, cells_under_test["scell3"], verdicts,
                                          df_dl_checkCount_3_SCELL_deact, dlLatestResult, dlDecisionCellMask,
                                          df_ul_checkCount_3_SCELL_deact, ulLatestResult, ulProposalCellMask)
            verify_PM_1754_dlOnly_SCELLs(pmc_file, column, cells_under_test["scell4"], verdicts,
                                         df_dl_checkCount_3_SCELL_deact, dlLatestResult, dlDecisionCellMask,
                                         df_ul_checkCount_3_SCELL_deact, ulLatestResult, ulProposalCellMask)
            verify_PM_1754_dlOnly_SCELLs(pmc_file, column, cells_under_test["scell5"], verdicts,
                                         df_dl_checkCount_3_SCELL_deact, dlLatestResult, dlDecisionCellMask,
                                         df_ul_checkCount_3_SCELL_deact, ulLatestResult, ulProposalCellMask)
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1744_FR2" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell), "scell1": int(scell1),
                                 "scell2": int(scell2), "scell3": int(scell3)}
                                for cells, pcell, scell1, scell2, scell3 in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15010": 0,  # SCELL_UL_SUSPEND_UEOVHT_SA
                             "M55316C15011": 0}  # SCELL_DL_SUSPEND_UEOVHT_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell1"]
            expected_pmcs = {"M55316C15010": 1,
                             "M55316C15011": 1}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell2"]
            expected_pmcs = {"M55316C15010": 0,
                             "M55316C15011": 0}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell3"]
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1746_FR1_tdd_pcell" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15045": 0,  # SCELL_UL_SUSPEND_UEOVHT_NSA
                             "M55316C15046": 0}  # SCELL_DL_SUSPEND_UEOVHT_NSA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell"]
            expected_pmcs = {"M55316C15045": 0,     # UL CA not possible in NSA FR1
                             "M55316C15046": 1}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            # -----------------------------------------------------------------------------------------[120 characters]
            are_pmcs_correct = all(verdicts)
        if subfeature == "PM_1746_FR1_fdd_pcell" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15045": 0,  # SCELL_UL_SUSPEND_UEOVHT_NSA
                             "M55316C15046": 0}  # SCELL_DL_SUSPEND_UEOVHT_NSA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell"]
            expected_pmcs = {"M55316C15045": 0,     # UL CA not possible in NSA FR1
                             "M55316C15046": 2}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1825_FR2" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell), "scell1": int(scell1),
                                 "scell2": int(scell2), "scell3": int(scell3)}
                                for cells, pcell, scell1, scell2, scell3 in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            # SCell recovery should only be visible on PCell
            expected_pmcs = {"M55316C15051": 2}  # SCELL_SUSP_RECOV_NSA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell1"]
            expected_pmcs = {"M55316C15051": 0}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell2"]
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell3"]
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1746_FR2" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell), "scell1": int(scell1),
                                 "scell2": int(scell2), "scell3": int(scell3)}
                                for cells, pcell, scell1, scell2, scell3 in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15045": 0,  # SCELL_UL_SUSPEND_UEOVHT_NSA
                             "M55316C15046": 0}  # SCELL_DL_SUSPEND_UEOVHT_NSA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell1"]
            expected_pmcs = {"M55316C15045": 1,
                             "M55316C15046": 1}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell2"]
            expected_pmcs = {"M55316C15045": 0,
                             "M55316C15046": 0}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell3"]
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if (subfeature == "PM_1816" or subfeature == "PM_1815") and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" %
                         json.dumps(cells_under_test, indent=4))
            verdicts = []

            cell = cells_under_test["scell"]
            SCELL_UL_SUSPEND_NFD_expected = get_expected_value_of_suspension_due_to_NFD(
                path_to_ttitrace_ul_pkl, cell, verdicts)
            if subfeature == "PM_1816":
                expected_pmcs = {"M55316C15015": SCELL_UL_SUSPEND_NFD_expected,  # SCELL_UL_SUSPEND_NFD_SA - FR1 only
                                 "M55316C15014": 0,  # PCELL_UL_SUSPEND_NFD_SA - FR1 only
                                 "M55316C15049": 0,  # PSCELL_UL_SUSPEND_NFD_NSA - FR1 only
                                 "M55316C15051": 0,  # SCELL_SUSP_RECOV_NSA - FR1&FR2 both
                                 "M55316C15016": 0}  # SCELL_SUSP_RECOV_SA - FR1&FR2 both

            verdicts.append(verify_pm_counters(
                pmc_file, column, cell, expected_pmcs, threshold_percent=0))

            cell = cells_under_test["pcell"]
            PCELL_UL_SUSPEND_NFD_expected = get_expected_value_of_suspension_due_to_NFD(
                path_to_ttitrace_ul_pkl, cell, verdicts)
            if subfeature == "PM_1816":
                expected_pmcs = {"M55316C15014": PCELL_UL_SUSPEND_NFD_expected,  # PCELL_UL_SUSPEND_NFD_SA - FR1 only
                                 "M55316C15015": 0,  # SCELL_UL_SUSPEND_NFD_SA - FR1 only
                                 "M55316C15049": 0,  # PSCELL_UL_SUSPEND_NFD_NSA - FR1 only
                                 "M55316C15051": 0,  # SCELL_SUSP_RECOV_NSA - FR1&FR2 both
                                 "M55316C15016": SCELL_UL_SUSPEND_NFD_expected}  # SCELL_SUSP_RECOV_SA - FR1&FR2 both
            else:
                expected_pmcs = {"M55316C15049": PCELL_UL_SUSPEND_NFD_expected}

            verdicts.append(verify_pm_counters(
                pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1755_FR1_tdd_pcell" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15027": 0,  # SCELL_UL_DEACT_SCELLOVHT_SA
                             "M55316C15028": 0,  # SCELL_DL_DEACT_SCELLOVHT_SA
                             "M55316C15025": 0,  # SCELL_UL_DEACT_UEOVHT_SA
                             "M55316C15026": 0}  # SCELL_DL_DEACT_UEOVHT_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell"]
            expected_pmcs = {"M55316C15027": 0,  # SCELL_UL_DEACT_SCELLOVHT_SA
                             "M55316C15028": 0,  # SCELL_DL_DEACT_SCELLOVHT_SA
                             "M55316C15025": 2,  # SCELL_UL_DEACT_UEOVHT_SA
                             "M55316C15026": 2}  # SCELL_DL_DEACT_UEOVHT_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            verify_legacy_OAI_pmc(pmc_file, column, cells_under_test, verdicts)
            are_pmcs_correct = all(verdicts)
        if subfeature == "PM_1755_FR1_fdd_pcell" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15027": 0,  # SCELL_UL_DEACT_SCELLOVHT_SA
                             "M55316C15028": 0,  # SCELL_DL_DEACT_SCELLOVHT_SA
                             "M55316C15025": 0,  # SCELL_UL_DEACT_UEOVHT_SA
                             "M55316C15026": 0}  # SCELL_DL_DEACT_UEOVHT_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell"]
            expected_pmcs = {"M55316C15027": 0,  # SCELL_UL_DEACT_SCELLOVHT_SA
                             "M55316C15028": 0,  # SCELL_DL_DEACT_SCELLOVHT_SA
                             "M55316C15025": 2,  # SCELL_UL_DEACT_UEOVHT_SA
                             "M55316C15026": 2}  # SCELL_DL_DEACT_UEOVHT_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            verify_legacy_OAI_pmc(pmc_file, column, cells_under_test, verdicts)
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1760_FR1_tdd_pcell" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15059": 0,  # SCELL_UL_DEACT_UEOVHT_NSA
                             "M55316C15060": 0}  # SCELL_DL_DEACT_UEOVHT_NSA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell"]
            expected_pmcs = {"M55316C15059": 1,
                             "M55316C15060": 1}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts)
        if subfeature == "PM_1760_FR1_fdd_pcell" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15059": 0,
                             "M55316C15060": 0}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell"]
            expected_pmcs = {"M55316C15059": 1,
                             "M55316C15060": 1}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1851_FR1_tdd_pcell" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15027": 0,  # SCELL_UL_DEACT_SCELLOVHT_SA
                             "M55316C15028": 0,  # SCELL_DL_DEACT_SCELLOVHT_SA
                             "M55316C15025": 0,  # SCELL_UL_DEACT_UEOVHT_SA
                             "M55316C15026": 0,  # SCELL_DL_DEACT_UEOVHT_SA
                             "M55316C15010": 0,  # SCELL_UL_SUSPEND_UEOVHT_SA
                             "M55316C15011": 0}  # SCELL_DL_SUSPEND_UEOVHT_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell"]
            expected_pmcs = {"M55316C15027": 2,  # SCELL_UL_DEACT_SCELLOVHT_SA
                             "M55316C15028": 2,  # SCELL_DL_DEACT_SCELLOVHT_SA
                             "M55316C15025": 2,  # SCELL_UL_DEACT_UEOVHT_SA
                             "M55316C15026": 2,  # SCELL_DL_DEACT_UEOVHT_SA
                             "M55316C15010": 2,  # SCELL_UL_SUSPEND_UEOVHT_SA
                             "M55316C15011": 2}  # SCELL_DL_SUSPEND_UEOVHT_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            verify_legacy_OAI_pmc(pmc_file, column, cells_under_test, verdicts)
            are_pmcs_correct = all(verdicts)
        if subfeature == "PM_1851_FR1_fdd_pcell" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15027": 0,  # SCELL_UL_DEACT_SCELLOVHT_SA
                             "M55316C15028": 0,  # SCELL_DL_DEACT_SCELLOVHT_SA
                             "M55316C15025": 0,  # SCELL_UL_DEACT_UEOVHT_SA
                             "M55316C15026": 0,  # SCELL_DL_DEACT_UEOVHT_SA
                             "M55316C15010": 0,  # SCELL_UL_SUSPEND_UEOVHT_SA
                             "M55316C15011": 0}  # SCELL_DL_SUSPEND_UEOVHT_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell"]
            expected_pmcs = {"M55316C15027": 2,  # SCELL_UL_DEACT_SCELLOVHT_SA
                             "M55316C15028": 2,  # SCELL_DL_DEACT_SCELLOVHT_SA
                             "M55316C15025": 2,  # SCELL_UL_DEACT_UEOVHT_SA
                             "M55316C15026": 2,  # SCELL_DL_DEACT_UEOVHT_SA
                             "M55316C15010": 2,  # SCELL_UL_SUSPEND_UEOVHT_SA
                             "M55316C15011": 2}  # SCELL_DL_SUSPEND_UEOVHT_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            verify_legacy_OAI_pmc(pmc_file, column, cells_under_test, verdicts)
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1851_FR2" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell), "scell1": int(scell1),
                                 "scell2": int(scell2), "scell3": int(scell3)}
                                for cells, pcell, scell1, scell2, scell3 in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15027": 0,  # SCELL_UL_SUSPEND_UEOVHT_NSA
                             "M55316C15028": 0}  # SCELL_DL_SUSPEND_UEOVHT_NSA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell1"]
            expected_pmcs = {"M55316C15027": 1,
                             "M55316C15028": 1}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell2"]
            expected_pmcs = {"M55316C15027": 0,
                             "M55316C15028": 0}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell3"]
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1853_FR1_tdd_pcell" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15061": 0,  # SCELL_UL_DEACT_SCELLOVHT_NSA
                             "M55316C15062": 0}  # SCELL_DL_DEACT_SCELLOVHT_NSA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell"]
            expected_pmcs = {"M55316C15061": 1,
                             "M55316C15062": 1}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts)
        if subfeature == "PM_1853_FR1_fdd_pcell" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15061": 0,
                             "M55316C15062": 0}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell"]
            expected_pmcs = {"M55316C15061": 1,
                             "M55316C15062": 1}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1853_FR2" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell), "scell1": int(scell1),
                                 "scell2": int(scell2), "scell3": int(scell3)}
                                for cells, pcell, scell1, scell2, scell3 in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15061": 0,  # SCELL_UL_DEACT_SCELLOVHT_NSA
                             "M55316C15062": 0}  # SCELL_DL_DEACT_SCELLOVHT_NSA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell1"]
            expected_pmcs = {"M55316C15061": 1,
                             "M55316C15062": 1}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell2"]
            expected_pmcs = {"M55316C15061": 0,
                             "M55316C15062": 0}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell3"]
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1813" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15012": 1,  # PCELL_UL_SUSPEND_LOWTXPWR_SA
                             "M55316C15013": 0}  # SCELL_UL_SUSPEND_LOWTXPWR_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell"]
            expected_pmcs = {"M55316C15012": 0,
                             "M55316C15013": 1}
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts)
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1855" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            legacy_piid_list = ["M55316C03001",  # P(S)Cell UEs with 1..7 activated SCells in DL
                                "M55316C03002",  # 2
                                "M55316C03003",  # 3
                                "M55316C03004",  # 4
                                "M55316C03005",  # 5
                                "M55316C03006",  # 6
                                "M55316C03007",  # 7
                                "M55316C04001",  # P(S)Cell UEs with 1..3 activated SCells in UL
                                "M55316C04002",  # 2
                                "M55316C04003"]  # 3
            reported_values = get_pm_counters(pmc_file, column, cell, legacy_piid_list)
            expected_pmcs = {"M55316C15031": reported_values["M55316C03001"],  # PSCELL_UE_[1..7]_ACT_SCELL_DL_SA
                             "M55316C15032": reported_values["M55316C03002"],  # 2
                             "M55316C15033": reported_values["M55316C03003"],  # 3
                             "M55316C15034": reported_values["M55316C03004"],  # 4
                             "M55316C15035": reported_values["M55316C03005"],  # 5
                             "M55316C15036": reported_values["M55316C03006"],  # 6
                             "M55316C15037": reported_values["M55316C03007"],  # 7
                             "M55316C15039": reported_values["M55316C04001"],  # PSCELL_UE_[1..3]_ACT_SCELL_UL_SA
                             "M55316C15040": reported_values["M55316C04002"],  # 2
                             "M55316C15041": reported_values["M55316C04003"],  # 3
                             "M55316C09000": 0,  # SCELL_ACTIVATIONS
                             "M55316C09001": 0,  # SCELL_DEACT_BUFFER_STATUS
                             "M55316C15021": 0,  # SCELL_UL_DEACT_LOWBUFFER_SA
                             "M55316C15022": 0}  # SCELL_DL_DEACT_LOWBUFFER_SA
            piids_to_exclude = {'M55316C15030', 'M55316C15038'}
            is_any_nonzero = any(value != 0 for key, value in expected_pmcs.items() if key not in piids_to_exclude)
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell"]
            expected_pmcs = {"M55316C09000": 2,  # SCELL_ACTIVATIONS
                             "M55316C09001": 2,  # SCELL_DEACT_BUFFER_STATUS
                             "M55316C15019": 2,  # SCELL_UL_DEACT_DEACTMR_SA
                             "M55316C15020": 2,  # SCELL_DL_DEACT_DEACTMR_SA
                             "M55316C15021": 0,  # SCELL_UL_DEACT_LOWBUFFER_SA, changed 2->0 because of 04363915's EDA
                             "M55316C15022": 0}  # SCELL_DL_DEACT_LOWBUFFER_SA, changed 2->0 because of 04363915's EDA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            # EDA for 04363915:
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15019": 0,  # SCELL_UL_DEACT_DEACTMR_SA
                             "M55316C15020": 0,  # SCELL_DL_DEACT_DEACTMR_SA
                             "M55316C15021": 0,  # SCELL_UL_DEACT_LOWBUFFER_SA
                             "M55316C15022": 0}  # SCELL_DL_DEACT_LOWBUFFER_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts) if is_any_nonzero else False
            # -----------------------------------------------------------------------------------------[120 characters]
        if subfeature == "PM_1857" and details and ":" in details:
            cells_under_test = [{"pcell": int(pcell),
                                 "scell": int(scell)}
                                for cells, pcell, scell in [details.split(':')]][0]
            logging.info("cells_under_test = %s" % json.dumps(cells_under_test, indent=4))
            verdicts = []
            cell = cells_under_test["pcell"]
            legacy_piid_list = ["M55316C03001",  # P(S)Cell UEs with 1..7 activated SCells in DL
                                "M55316C03002",  # 2
                                "M55316C03003",  # 3
                                "M55316C03004",  # 4
                                "M55316C03005",  # 5
                                "M55316C03006",  # 6
                                "M55316C03007",  # 7
                                "M55316C04001",  # P(S)Cell UEs with 1..3 activated SCells in UL
                                "M55316C04002",  # 2
                                "M55316C04003"]  # 3
            reported_values = get_pm_counters(pmc_file, column, cell, legacy_piid_list)
            expected_pmcs = {"M55316C15064": reported_values["M55316C03001"],  # PSCELL_UE_[1..7]_ACT_SCELL_DL_NSA
                             "M55316C15065": reported_values["M55316C03002"],  # 2
                             "M55316C15066": reported_values["M55316C03003"],  # 3
                             "M55316C15067": reported_values["M55316C03004"],  # 4
                             "M55316C15068": reported_values["M55316C03005"],  # 5
                             "M55316C15069": reported_values["M55316C03006"],  # 6
                             "M55316C15070": reported_values["M55316C03007"],  # 7
                             "M55316C15071": reported_values["M55316C04001"],  # PSCELL_UE_[1..3]_ACT_SCELL_UL_NSA
                             "M55316C15072": reported_values["M55316C04002"],  # 2
                             "M55316C15073": reported_values["M55316C04003"],  # 3
                             "M55316C09000": 0,  # SCELL_ACTIVATIONS
                             "M55316C09001": 0,  # SCELL_DEACT_BUFFER_STATUS
                             "M55316C15054": 0,  # SCELL_DL_DEACT_DEACTMR_NSA
                             "M55316C15055": 0,  # SCELL_UL_DEACT_LOWBUFFER_NSA
                             "M55316C15056": 0,  # SCELL_DL_DEACT_LOWBUFFER_NSA
                             "M55316C15019": 0,  # SCELL_UL_DEACT_DEACTMR_SA
                             "M55316C15020": 0,  # SCELL_DL_DEACT_DEACTMR_SA
                             "M55316C15021": 0,  # SCELL_UL_DEACT_LOWBUFFER_SA
                             "M55316C15022": 0}  # SCELL_DL_DEACT_LOWBUFFER_SA
            piids_to_exclude = {'M55316C15030', 'M55316C15038'}
            is_any_nonzero = any(value != 0 for key, value in expected_pmcs.items() if key not in piids_to_exclude)
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            cell = cells_under_test["scell"]
            legacy_piid_list = ["M55316C09000"]  # SCELL_ACTIVATIONS
            reported_values = get_pm_counters(pmc_file, column, cell, legacy_piid_list)
            expected_pmcs = {"M55316C09001": reported_values["M55316C09000"],  # SCELL_DEACT_BUFFER_STATUS
                             "M55316C15054": reported_values["M55316C09000"],  # SCELL_DL_DEACT_DEACTMR_NSA
                             "M55316C15055": 0,  # SCELL_UL_DEACT_LOWBUFFER_NSA
                             "M55316C15056": 0,  # SCELL_DL_DEACT_LOWBUFFER_NSA, changed to 0 because of 04363915's EDA
                             "M55316C15019": 0,  # SCELL_UL_DEACT_DEACTMR_SA, for EDA for 04363915
                             "M55316C15020": 0,  # SCELL_DL_DEACT_DEACTMR_SA, for EDA for 04363915
                             "M55316C15021": 0,  # SCELL_UL_DEACT_LOWBUFFER_SA, for EDA for 04363915
                             "M55316C15022": 0}  # SCELL_DL_DEACT_LOWBUFFER_SA, for EDA for 04363915
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            # EDA for 04363915:
            cell = cells_under_test["pcell"]
            expected_pmcs = {"M55316C15019": 0,  # SCELL_UL_DEACT_DEACTMR_SA
                             "M55316C15020": 0,  # SCELL_DL_DEACT_DEACTMR_SA
                             "M55316C15021": 0,  # SCELL_UL_DEACT_LOWBUFFER_SA
                             "M55316C15022": 0}  # SCELL_DL_DEACT_LOWBUFFER_SA
            verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))
            are_pmcs_correct = all(verdicts) if is_any_nonzero else False
            # -----------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_pmc", e)
    if are_pmcs_correct is None:
        are_pmcs_correct = False
    logging.info("are_pmcs_correct = %s" % are_pmcs_correct)
    rbi.should_be_true(are_pmcs_correct)


# ====================================================================================================[120 characters]
#   Private Functions
# ====================================================================================================[120 characters]

@log_begin_end_func_name
def get_df_from_pkl(path_to_pickle, direction):
    ackNack = 'dlHarqRxDataArray.ackNack' if direction == 'dl' else 'ulHarqRxData.crcResult'
    txNumber = '{}FdSchedData.txNumber'.format(direction)
    mcsTable = '{}FdSchedData.mcsTable'.format(direction)
    laMode = '{}FdSchedData.laMode'.format(direction)
    sw_build = rbi.get_variable_value("${sw_build}")
    logging.info("sw_build = %s" % sw_build)
    if direction == 'dl':
        targetBLER = 'dlFdSchedAdditionalData.targetBLER'
    elif any(x in sw_build for x in ['SBTS25R3', 'SBTS26R1']):
        targetBLER = 'ulFdSchedData.targetBLER'
    else:
        targetBLER = 'ulFdSchedAdditionalData.targetBLER'
    usedMcs = '{}FdSchedData.rrm{}UsedMcs'.format(direction, direction.capitalize())
    proposedMcs = '{}FdSchedData.rrm{}ProposedMcs'.format(direction, direction.capitalize())
    dtx = 'dlHarqRxDataArray.dtx' if direction == 'dl' else 'ulHarqRxData.dtx'
    # ------------------------------------------------------------------------------------------------[120 characters]
    crcFb = 'ulLaDeltaSinr.crcFb'
    rrmDeltaSinr = 'ulLaDeltaSinr.rrmDeltaSinr'
    targetBlerType = 'ulLaDeltaSinr.targetBlerType'
    ulUsedMcs = 'ulLaDeltaSinr.ulUsedMcs'
    rrmPauseUeInUlScheduling = 'ulLaDeltaSinr.rrmPauseUeInUlScheduling'
    # ------------------------------------------------------------------------------------------------[120 characters]
    rrmPauseUeInDlScheduling = 'dlLaDeltaCqiArray.rrmPauseUeInDlScheduling'
    harqFb = 'dlLaDeltaCqiArray.harqFb'
    # ------------------------------------------------------------------------------------------------[120 characters]
    df = pd.read_pickle(path_to_pickle)
    if direction == 'dl':
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', ackNack, txNumber, mcsTable, dtx,
                 laMode, targetBLER, usedMcs, proposedMcs, rrmPauseUeInDlScheduling, harqFb]]
    else:
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', ackNack, txNumber, mcsTable, dtx,
                 laMode, targetBLER, usedMcs, proposedMcs, rrmPauseUeInUlScheduling, crcFb]]
    return df


@log_begin_end_func_name
def plot_for(df, yaxis_column):
    try:
        df_optimized = df[['timeStamp', 'rnti', 'lcrId', yaxis_column]]
        df_filtered = df_optimized.loc[df_optimized[yaxis_column].notna()]
        logging.info("df_filtered = %s" % df_filtered)
        plot_df_with_scatter(df=df_filtered,
                             yaxis_column=yaxis_column,
                             base_location=os.path.dirname(rbi.get_variable_value("${path_to_ttitrace_pkl}")),
                             postfix="CB009267",
                             xaxis_column="timeStamp",
                             title=yaxis_column,
                             group_by='rnti')
    except Exception as e:
        logException("plot_for", e)


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


@log_begin_end_func_name
def get_expected_value_of_suspension_due_to_NFD(path_to_tti_trace_pkl, cell, verdicts):
    df = pd.read_pickle(path_to_tti_trace_pkl)
    rrm_delta_cqi_sinr_rrmPauseUeInUlScheduling = 'ulLaDeltaSinr.rrmPauseUeInUlScheduling'

    df = df[['timeStamp', 'rnti', 'sfn', 'slot', 'lcrId',
             rrm_delta_cqi_sinr_rrmPauseUeInUlScheduling]].dropna(
                 subset=[rrm_delta_cqi_sinr_rrmPauseUeInUlScheduling])
    df_per_lcrId_filtered = df[df['lcrId'] == int(cell)]

    num_of_suspensions_per_cell = 0
    for rnti, df_per_lcrId_per_rnti_filtered in df_per_lcrId_filtered.groupby('rnti'):
        df_per_lcrId_per_rnti_filtered['Value_Difference'] = \
            df_per_lcrId_per_rnti_filtered[rrm_delta_cqi_sinr_rrmPauseUeInUlScheduling] - \
            df_per_lcrId_per_rnti_filtered[rrm_delta_cqi_sinr_rrmPauseUeInUlScheduling].shift(
                1)
        df_per_lcrId_per_rnti_filtered.to_csv("{}/df_per_lcrId_{}_per_rnti_{}_filtered.csv".format(
            os.path.dirname(path_to_tti_trace_pkl), cell, rnti))

        rbi.log(
            "df_per_lcrId_{}_per_rnti_{}_filtered:".format(cell, rnti))
        display_df_as_html(df_per_lcrId_per_rnti_filtered.head(10))
        df_suspension_happened = df_per_lcrId_per_rnti_filtered[
            df_per_lcrId_per_rnti_filtered['Value_Difference'] == 1]
        num_of_suspensions_per_cell += len(df_suspension_happened)

        if len(df_suspension_happened) != 0:
            rbi.log(
                "UE suspension happened for rnti: {} on lcrId: {}".format(rnti, cell))
            rbi.log(
                "df_suspension_happened_per_lcrId_{}_per_rnti_{}:".format(cell, rnti))
            display_df_as_html(df_suspension_happened)
        else:
            verdicts.append(False)
            rbi.log(
                "UE suspension did NOT happen for rnti: {} on lcrId: {}".format(rnti, cell), 'ERROR')

    rbi.log(
        "UE suspensions happened per cell{} = {}".format(cell, num_of_suspensions_per_cell))
    return num_of_suspensions_per_cell


@log_begin_end_func_name
def verify_legacy_OAI_pmc(pmc_csv_file, column, cells_under_test, verdicts):
    cell = cells_under_test["pcell"]
    piids_and_expected_values = {"M55118C07501": 4,  # nbr of overall OAI reports received from UE
                                 "M55118C07503": 2,  # nbr of OAI reports requesting 0 SCell to be active
                                 "M55118C07504": 2,  # nbr of OAI reports requesting 1 SCell to be active
                                 "M55118C07505": 0,  # nbr of OAI reports requesting 2 SCells to be active
                                 "M55118C07506": 0,  # nbr of OAI reports requesting 3 SCells to be active
                                 "M55118C07511": 0}  # nbr of OAI reports requesting 4 SCells to be active
    verdicts.append(verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, threshold_percent=0))
    cell = cells_under_test["scell"]
    piids_and_expected_values = {"M55118C07501": 0,  # nbr of overall OAI reports received from UE
                                 "M55118C07503": 0,  # nbr of OAI reports requesting 0 SCell to be active
                                 "M55118C07504": 0,  # nbr of OAI reports requesting 1 SCell to be active
                                 "M55118C07505": 0,  # nbr of OAI reports requesting 2 SCells to be active
                                 "M55118C07506": 0,  # nbr of OAI reports requesting 3 SCells to be active
                                 "M55118C07511": 0}  # nbr of OAI reports requesting 4 SCells to be active
    verdicts.append(verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, threshold_percent=0))


@log_begin_end_func_name
def verify_PM_1824_and_1826_dlAndUl_SCELLs(pmc_file, column, cell, verdicts, subfeature,
                                           scell_activation_expected=True):
    expected_pmcs_lower_than = {"M55316C15011": 1,  # SCELL_DL_SUSPEND_UEOVHT_SA   ->  updated on SCELL
                                "M55316C15010": 1,  # SCELL_UL_SUSPEND_UEOVHT_SA   ->  updated on SCELL
                                "M55316C15046": 1,  # SCELL_DL_SUSPEND_UEOVHT_NSA  ->  updated on SCELL
                                "M55316C15045": 1}  # SCELL_UL_SUSPEND_UEOVHT_NSA  ->  updated on SCELL
    verdicts.append(verify_pm_counters(pmc_file, column, cell,
                    expected_pmcs_lower_than, verification_type="verify_is_lower"))

    if scell_activation_expected:
        expected_pmcs_greater_than = {"M55316C09000": 1}  # SCELL_ACTIVATIONS            ->  updated on SCELL
        verdicts.append(verify_pm_counters(pmc_file, column, cell,
                        expected_pmcs_greater_than, verification_type="verify_is_greater"))

    legacy_piid_list = ["M55316C15010",  # SCELL_UL_SUSPEND_UEOVHT_SA   ->  updated on SCELL
                        "M55316C15011",  # SCELL_DL_SUSPEND_UEOVHT_SA   ->  updated on SCELL
                        "M55316C15046",  # SCELL_DL_SUSPEND_UEOVHT_NSA  ->  updated on SCELL
                        "M55316C15045",  # SCELL_UL_SUSPEND_UEOVHT_NSA  ->  updated on SCELL
                        "M55316C09000",  # SCELL_ACTIVATIONS            ->  updated on SCELL
                        "M55316C09001"]  # SCELL_DEACT_BUFFER_STATUS    ->  updated on SCELL
    reported_values = get_pm_counters(pmc_file, column, cell, legacy_piid_list)

    if subfeature == "PM_1824_FR2":
        SCELL_UL_DEACT_LOWBUFFER_counter_expected_to_be_pegged = "M55316C15021"  # SCELL_UL_DEACT_LOWBUFFER_SA
        SCELL_DL_DEACT_LOWBUFFER_counter_expected_to_be_pegged = "M55316C15022"  # SCELL_DL_DEACT_LOWBUFFER_SA
        SCELL_UL_DEACT_LOWBUFFER_counter_expected_to_be_zero = "M55316C15055"  # SCELL_UL_DEACT_LOWBUFFER_NSA
        SCELL_DL_DEACT_LOWBUFFER_counter_expected_to_be_zero = "M55316C15056"  # SCELL_DL_DEACT_LOWBUFFER_NSA
        SCELL_UL_SUSPEND_UEOVHT_counter_expected_to_be_pegged = "M55316C15010"  # SCELL_UL_SUSPEND_UEOVHT_SA
        SCELL_DL_SUSPEND_UEOVHT_counter_expected_to_be_pegged = "M55316C15011"  # SCELL_DL_SUSPEND_UEOVHT_SA
        SCELL_UL_SUSPEND_UEOVHT_counter_expected_to_be_zero = "M55316C15045"  # SCELL_UL_SUSPEND_UEOVHT_NSA
        SCELL_DL_SUSPEND_UEOVHT_counter_expected_to_be_zero = "M55316C15046"  # SCELL_dL_SUSPEND_UEOVHT_NSA
    else:
        SCELL_UL_DEACT_LOWBUFFER_counter_expected_to_be_zero = "M55316C15021"  # SCELL_UL_DEACT_LOWBUFFER_SA
        SCELL_DL_DEACT_LOWBUFFER_counter_expected_to_be_zero = "M55316C15022"  # SCELL_DL_DEACT_LOWBUFFER_SA
        SCELL_UL_DEACT_LOWBUFFER_counter_expected_to_be_pegged = "M55316C15055"  # SCELL_UL_DEACT_LOWBUFFER_NSA
        SCELL_DL_DEACT_LOWBUFFER_counter_expected_to_be_pegged = "M55316C15056"  # SCELL_DL_DEACT_LOWBUFFER_NSA
        SCELL_UL_SUSPEND_UEOVHT_counter_expected_to_be_pegged = "M55316C15045"  # SCELL_UL_SUSPEND_UEOVHT_NSA
        SCELL_DL_SUSPEND_UEOVHT_counter_expected_to_be_pegged = "M55316C15046"  # SCELL_DL_SUSPEND_UEOVHT_NSA
        SCELL_UL_SUSPEND_UEOVHT_counter_expected_to_be_zero = "M55316C15010"  # SCELL_UL_SUSPEND_UEOVHT_SA
        SCELL_DL_SUSPEND_UEOVHT_counter_expected_to_be_zero = "M55316C15011"  # SCELL_dL_SUSPEND_UEOVHT_SA

    expected_pmcs = {"M55316C15017": 0,  # SCELL_SUSP_DEACT_REL_SA      ->  updated on PCELL
                     "M55316C15052": 0,  # SCELL_SUSP_DEACT_REL_NSA     ->  updated on PCELL
                     "M55316C09001": reported_values["M55316C09000"],  # SCELL_DEACT_BUFFER_STATUS
                     SCELL_UL_DEACT_LOWBUFFER_counter_expected_to_be_pegged: reported_values["M55316C09001"],
                     SCELL_DL_DEACT_LOWBUFFER_counter_expected_to_be_pegged: reported_values["M55316C09001"],
                     SCELL_UL_DEACT_LOWBUFFER_counter_expected_to_be_zero: 0,
                     SCELL_DL_DEACT_LOWBUFFER_counter_expected_to_be_zero: 0,
                     SCELL_UL_SUSPEND_UEOVHT_counter_expected_to_be_zero: 0,
                     SCELL_DL_SUSPEND_UEOVHT_counter_expected_to_be_zero: 0}
    verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))

    if reported_values["M55316C15010"] != reported_values["M55316C15011"]:
        rbi.log(
            "SCELL_UL_SUSPEND_UEOVHT_SA: {} is not equal to SCELL_DL_SUSPEND_UEOVHT_SA: {} in dlAndUl SCELL".format(
                reported_values["M55316C15010"], reported_values["M55316C15011"]), 'ERROR')
        verdicts.append(False)

    if reported_values["M55316C15045"] != reported_values["M55316C15046"]:
        rbi.log(
            "SCELL_UL_SUSPEND_UEOVHT_NSA: {} is not equal to SCELL_DL_SUSPEND_UEOVHT_NSA: {} in dlAndUl SCELL".format(
                reported_values["M55316C15045"], reported_values["M55316C15046"]), 'ERROR')
        verdicts.append(False)

    if reported_values["M55316C09001"] > 0:  # i.e. SCELL_DEACT_BUFFER_STATUS > 0
        return reported_values[SCELL_UL_SUSPEND_UEOVHT_counter_expected_to_be_pegged] + \
            reported_values[SCELL_DL_SUSPEND_UEOVHT_counter_expected_to_be_pegged]
    else:
        return 0


@log_begin_end_func_name
def verify_PM_1824_dlOnly_SCELLs(pmc_file, column, cell, verdicts, scell_activation_expected=True):
    expected_pmcs_lower_than = {"M55316C15011": 1,  # SCELL_DL_SUSPEND_UEOVHT_SA   ->  updated on SCELL
                                "M55316C15010": 1,  # SCELL_UL_SUSPEND_UEOVHT_SA   ->  updated on SCELL
                                "M55316C15046": 0,  # SCELL_DL_SUSPEND_UEOVHT_NSA  ->  updated on SCELL
                                "M55316C15045": 0}  # SCELL_UL_SUSPEND_UEOVHT_NSA  ->  updated on SCELL
    verdicts.append(verify_pm_counters(pmc_file, column, cell,
                    expected_pmcs_lower_than, verification_type="verify_is_lower"))

    if scell_activation_expected:
        expected_pmcs_greater_than = {"M55316C09000": 1}  # SCELL_ACTIVATIONS            ->  updated on SCELL
        verdicts.append(verify_pm_counters(pmc_file, column, cell,
                                           expected_pmcs_greater_than, verification_type="verify_is_greater"))

    legacy_piid_list = ["M55316C15011",  # SCELL_DL_SUSPEND_UEOVHT_SA   ->  updated on SCELL
                        "M55316C09000",  # SCELL_ACTIVATIONS            ->  updated on SCELL
                        "M55316C09001"]  # SCELL_DEACT_BUFFER_STATUS    ->  updated on SCELL
    reported_values = get_pm_counters(pmc_file, column, cell, legacy_piid_list)

    expected_pmcs = {"M55316C15017": 0,  # SCELL_SUSP_DEACT_REL_SA      ->  updated on PCELL
                     "M55316C15052": 0,  # SCELL_SUSP_DEACT_REL_NSA     ->  updated on PCELL
                     "M55316C15010": 0,  # SCELL_UL_SUSPEND_UEOVHT_SA   ->  updated on SCELL
                     "M55316C15021": 0,  # SCELL_UL_DEACT_LOWBUFFER_SA  ->  updated on SCELL
                     "M55316C15055": 0,  # SCELL_UL_DEACT_LOWBUFFER_NSA  ->  updated on SCELL
                     "M55316C15056": 0,  # SCELL_DL_DEACT_LOWBUFFER_NSA  ->  updated on SCELL
                     "M55316C09001": reported_values["M55316C09000"],  # SCELL_DEACT_BUFFER_STATUS
                     "M55316C15022": reported_values["M55316C09001"]}  # SCELL_DL_DEACT_LOWBUFFER_SA
    verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))

    if reported_values["M55316C09001"] > 0:  # i.e. SCELL_DEACT_BUFFER_STATUS > 0
        return reported_values["M55316C15011"]
    else:
        return 0


@log_begin_end_func_name
def verify_PM_1824_and_1826_PCELL(pmc_file, column, cell, number_of_UEOVHT_susp_in_all_scells, verdicts, subfeature):
    if subfeature == "PM_1824_FR2":
        SCELL_SUSP_DEACT_REL_counter_expected_to_be_pegged = "M55316C15017"  # SCELL_SUSP_DEACT_REL_SA
        SCELL_SUSP_DEACT_REL_counter_expected_to_be_zero = "M55316C15052"  # SCELL_SUSP_DEACT_REL_NSA
    else:
        SCELL_SUSP_DEACT_REL_counter_expected_to_be_pegged = "M55316C15052"  # SCELL_SUSP_DEACT_REL_SA
        SCELL_SUSP_DEACT_REL_counter_expected_to_be_zero = "M55316C15017"  # SCELL_SUSP_DEACT_REL_NSA

    expected_pmcs_greater_than = {SCELL_SUSP_DEACT_REL_counter_expected_to_be_pegged: 0}
    verdicts.append(verify_pm_counters(pmc_file, column, cell,
                    expected_pmcs_greater_than, verification_type="verify_is_greater"))

    expected_pmcs = {"M55316C15010": 0,  # SCELL_UL_SUSPEND_UEOVHT_SA   ->  updated on SCELL
                     "M55316C15011": 0,  # SCELL_DL_SUSPEND_UEOVHT_SA   ->  updated on SCELL
                     "M55316C15021": 0,  # SCELL_UL_DEACT_LOWBUFFER_SA  ->  updated on SCELL
                     "M55316C15022": 0,  # SCELL_DL_DEACT_LOWBUFFER_SA  ->  updated on SCELL
                     SCELL_SUSP_DEACT_REL_counter_expected_to_be_pegged: number_of_UEOVHT_susp_in_all_scells,
                     SCELL_SUSP_DEACT_REL_counter_expected_to_be_zero: 0,
                     "M55316C15045": 0,  # SCELL_UL_SUSPEND_UEOVHT_NSA   ->  updated on SCELL
                     "M55316C15046": 0,  # SCELL_DL_SUSPEND_UEOVHT_NSA   ->  updated on SCELL
                     "M55316C15055": 0,  # SCELL_UL_DEACT_LOWBUFFER_NSA  ->  updated on SCELL
                     "M55316C15056": 0,  # SCELL_DL_DEACT_LOWBUFFER_NSA  ->  updated on SCELL
                     "M55316C09001": 0}  # SCELL_DEACT_BUFFER_STATUS    ->  updated on SCELL
    verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))


@log_begin_end_func_name
def verify_PM_1754_PCELL(pmc_file, column, cell, verdicts):
    expected_pmcs = {"M55316C15023": 0,  # SCELL_UL_DEACT_RLQ_SA        ->  updated on SCELL
                     "M55316C15024": 0}  # SCELL_DL_DEACT_RLQ_SA        ->  updated on SCELL
    verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))


@log_begin_end_func_name
def verify_PM_1754_dlAndUl_SCELLs(pmc_file, column, cell, verdicts, df_dl_checkCount_3_SCELL_deact, dlLatestResult,
                                  dlDecisionCellMask, df_ul_checkCount_3_SCELL_deact, ulLatestResult,
                                  ulProposalCellMask):
    RLQ_based_deacts_dl = get_expected_value_of_RLQ_based_deactivations(
        df_dl_checkCount_3_SCELL_deact, cell, verdicts, dlLatestResult, dlDecisionCellMask)
    Buff_based_deacts_dl = get_expected_value_of_Buff_based_deactivations(
        df_dl_checkCount_3_SCELL_deact, cell, dlLatestResult, dlDecisionCellMask)
    # get_expected_value_of_RLQ_based_deactivations(
    #    df_ul_checkCount_3_SCELL_deact, cell, verdicts, ulLatestResult, ulProposalCellMask)
    # get_expected_value_of_Buff_based_deactivations(
    #    df_ul_checkCount_3_SCELL_deact, cell, ulLatestResult, ulProposalCellMask)

    expected_pmcs = {"M55316C09000": RLQ_based_deacts_dl + Buff_based_deacts_dl,  # SCELL_ACTIVATIONS
                     "M55316C15023": RLQ_based_deacts_dl,  # SCELL_UL_DEACT_RLQ_SA
                     "M55316C15024": RLQ_based_deacts_dl,  # SCELL_DL_DEACT_RLQ_SA
                     "M55316C09002": RLQ_based_deacts_dl,  # SCELL_DEACT_CHANNEL_STATE
                     "M55316C09001": Buff_based_deacts_dl,  # SCELL_DEACT_BUFFER_STATUS
                     "M55316C15021": Buff_based_deacts_dl,  # SCELL_UL_DEACT_LOWBUFFER_SA
                     "M55316C15022": Buff_based_deacts_dl}  # SCELL_DL_DEACT_LOWBUFFER_SA
    verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))


@log_begin_end_func_name
def verify_PM_1754_dlOnly_SCELLs(pmc_file, column, cell, verdicts, df_dl_checkCount_3_SCELL_deact, dlLatestResult,
                                 dlDecisionCellMask, df_ul_checkCount_3_SCELL_deact, ulLatestResult,
                                 ulProposalCellMask):
    RLQ_based_deacts_dl = get_expected_value_of_RLQ_based_deactivations(
        df_dl_checkCount_3_SCELL_deact, cell, verdicts, dlLatestResult, dlDecisionCellMask)
    Buff_based_deacts_dl = get_expected_value_of_Buff_based_deactivations(
        df_dl_checkCount_3_SCELL_deact, cell, dlLatestResult, dlDecisionCellMask)
    # get_expected_value_of_RLQ_based_deactivations(
    #    df_ul_checkCount_3_SCELL_deact, cell, verdicts, ulLatestResult, ulProposalCellMask)
    # get_expected_value_of_Buff_based_deactivations(
    #    df_ul_checkCount_3_SCELL_deact, cell, ulLatestResult, ulProposalCellMask)

    expected_pmcs = {"M55316C09000": RLQ_based_deacts_dl + Buff_based_deacts_dl,  # SCELL_ACTIVATIONS
                     "M55316C15023": 0,  # SCELL_UL_DEACT_RLQ_SA
                     "M55316C15024": RLQ_based_deacts_dl,  # SCELL_DL_DEACT_RLQ_SA
                     "M55316C09002": RLQ_based_deacts_dl,  # SCELL_DEACT_CHANNEL_STATE
                     "M55316C09001": Buff_based_deacts_dl,  # SCELL_DEACT_BUFFER_STATUS
                     "M55316C15021": 0,  # SCELL_UL_DEACT_LOWBUFFER_SA
                     "M55316C15022": Buff_based_deacts_dl}  # SCELL_DL_DEACT_LOWBUFFER_SA
    verdicts.append(verify_pm_counters(pmc_file, column, cell, expected_pmcs, threshold_percent=0))


@log_begin_end_func_name
def get_expected_value_of_RLQ_based_deactivations(df_checkCount_3_SCELL_deact, cell, verdicts, latestResult,
                                                  decisionOrProposalCellMask):
    df_RLQ_based_deact = df_checkCount_3_SCELL_deact[df_checkCount_3_SCELL_deact[latestResult]
                                                     == 'RLQBASEDDEACTIVATE']
    if len(df_RLQ_based_deact) == 0:
        rbi.log("There is no event of RLQBASEDDEACTIVATE in dataframe", 'WARN')
        verdicts.append(False)
        return 0

    df_RLQ_based_deact['RLQ_based_deact_bit_value'] = df_RLQ_based_deact.apply(
        lambda row: apply_get_bit_value(row, cell, decisionOrProposalCellMask), axis=1)
    rbi.log("df_RLQ_based_deact for cell({}):".format(cell))
    display_df_as_html(df_RLQ_based_deact)
    return df_RLQ_based_deact['RLQ_based_deact_bit_value'].sum()


@log_begin_end_func_name
def get_expected_value_of_Buff_based_deactivations(df_checkCount_3_SCELL_deact, cell, latestResult,
                                                   decisionOrProposalCellMask):
    df_Buff_based_deact = df_checkCount_3_SCELL_deact[df_checkCount_3_SCELL_deact[latestResult]
                                                      == 'BUFFERBASEDDEACTIVATE']
    if len(df_Buff_based_deact) == 0:
        rbi.log("There is no event of BUFFERBASEDDEACTIVATE in dataframe", 'WARN')
        return 0

    df_Buff_based_deact['Buff_based_deact_bit_value'] = df_Buff_based_deact.apply(
        lambda row: apply_get_bit_value(row, cell, decisionOrProposalCellMask), axis=1)
    rbi.log("df_Buff_based_deact for cell({}):".format(cell))
    display_df_as_html(df_Buff_based_deact)
    return df_Buff_based_deact['Buff_based_deact_bit_value'].sum()


@log_begin_end_func_name
def apply_get_bit_value(row, bit_position, decisionOrProposalCellMask):
    return get_bit_value(row[decisionOrProposalCellMask], bit_position)


@log_begin_end_func_name
def get_bit_value(decimal_number, bit_position):
    # Right shift the number by 'bit_position' bits
    shifted_number = int(decimal_number) >> (int(bit_position) - 1)

    # Apply bitwise AND with 1 to get the value of the least significant bit
    bit_value = shifted_number & 1

    return bit_value
