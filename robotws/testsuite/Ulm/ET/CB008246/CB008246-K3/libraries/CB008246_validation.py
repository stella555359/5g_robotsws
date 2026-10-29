# =====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd68 for CB008246 Feature
# Team: 'SqdGp68'
# Email: 'I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com'
# -----------------------------------------------------------------------------------------------------[120 characters]

import logging
import os
from tabulate import tabulate

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
from testsuite.Ulm.ET.CB008246.libraries.ttitrace_analysis import (get_expected_new_pmc_values,
                                                                   plot_df_with_scatter)
from testsuite.Ulm.ET.L2.libraries.syslogs_analysis import check_no_fatality_error_in_syslogs


# =====================================================================================================[120 characters]
#   Global Variables
# =====================================================================================================[120 characters]

RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()
pmResultFile = None


# =====================================================================================================[120 characters]
#   Keywords
# =====================================================================================================[120 characters]

@log_begin_end_func_name
def verify_qc_test_case(tc_name):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Generic keyword which makes the common preparation and calls the Test Case specific Validation
    # -------------------------------------------------------------------------------------------------[120 characters]
    rbi.log_to_console(BOLD + "\n Verify QC Test Case(s) of CB008246: " + RESET + "~" * 102 + "")
    # rbi.log_to_console(("  "+tc_name[:80]+"   ").ljust(133), no_newline=True)
    tc_verdict = False
    ts_log_dir = rbi.get_variable_value("${ts_log_dir}")
    path_to_syslog_tgz = rbi.get_variable_value("${path_to_syslog_tgz}")
    pmc_csv_file = rbi.get_variable_value("${pm_counters_dir}") + "/pmCounters.csv"
    pmc_index = rbi.get_variable_value("${pmc_index}")
    nrbts_str = rbi.get_variable_value("${nrbts_str}")[0]
    scenario_name = rbi.get_variable_value("${scenario}")
    rntis_for_ue_group = rbi.run_keyword("get_rntis_for_ue_group", scenario_name)
    logging.info("rntis_for_ue_group = %s" % rntis_for_ue_group)
    global sw_build
    sw_build = rbi.get_variable_value("${sw_build}")
    logging.info("sw_build = %s" % sw_build)
    PCell = 3  # <-- Primary serving cell for Carrier Aggregation
    SCell = 11  # <-- Secondary serving cell for Carrier Aggregation
    column = -(pmc_index+3)
    logging.info("tc_name = %s" % tc_name)
    logging.info("ts_log_dir = %s" % ts_log_dir)
    logging.info("pmc_csv_file = %s" % pmc_csv_file)
    logging.info("PCell = %s" % PCell)
    logging.info("SCell = %s" % SCell)
    logging.info("column = %s" % column)
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    ullaBlerTargetHR_1 = round(int(rbi.get_variable_value("${ullaBlerTargetHR_1}")) * 0.001, 7)
    ullaBlerTargetHR_2 = round(int(rbi.get_variable_value("${ullaBlerTargetHR_2}")) * 0.001, 7)
    logging.info("ullaBlerTargetHR_1 = %s" % ullaBlerTargetHR_1)
    logging.info("ullaBlerTargetHR_2 = %s" % ullaBlerTargetHR_2)
    # --- Plot some usefull Charts: -------------------------------------------------------------------[120 characters]
    plot_for_DL(path_to_ttitrace_pkl, tc_name)
    plot_for_UL(path_to_ttitrace_pkl, tc_name)
    # --- Test Case Specific Part: --------------------------------------------------------------------[120 characters]
    check_points = [verify_SCF_Paramaters(PCell)]  # <--- Common Checkpoint
    check_points.append(verify_SCF_Paramaters(SCell))
    if "CB008246_K_TC03_HR_IWK_CA_UL_SA_2CC_FDDTDD_HRDRB_after_SCell_Addition" == tc_name:
        check_points.append(verify_legacy_pmc_pusch_hrla(pmc_csv_file, column, PCell, tc_name, path_to_ttitrace_pkl,
                                                         ullaBlerTargetHR_1, ullaBlerTargetHR_2))
        check_points.append(verify_legacy_pmc_pusch_hrla(pmc_csv_file, column, SCell, tc_name, path_to_ttitrace_pkl,
                                                         ullaBlerTargetHR_1, ullaBlerTargetHR_2))
        check_points.append(verify_new_pmc_pusch_hrla(pmc_csv_file, column, PCell, tc_name, path_to_ttitrace_pkl,
                                                      ullaBlerTargetHR_1, ullaBlerTargetHR_2))
        check_points.append(verify_new_pmc_pusch_hrla(pmc_csv_file, column, SCell, tc_name, path_to_ttitrace_pkl,
                                                      ullaBlerTargetHR_1, ullaBlerTargetHR_2))
        check_points.append(verify_maxmcs_based_on_tti(path_to_ttitrace_pkl, PCell, 'HIGHRELIABILITY', max_mcs=25))
        check_points.append(verify_maxmcs_based_on_tti(path_to_ttitrace_pkl, SCell, 'HIGHRELIABILITY', max_mcs=25))
        check_points.append(verify_HR_BR_switch_in_UL(SCell, path_to_ttitrace_pkl))
        check_points.append(verify_profile_existing_QAM64LOWSE(PCell, tc_name, path_to_ttitrace_pkl,
                                                               ullaBlerTargetHR_1, ullaBlerTargetHR_2))
        check_points.append(verify_profile_existing_QAM64LOWSE(SCell, tc_name, path_to_ttitrace_pkl,
                                                               ullaBlerTargetHR_1, ullaBlerTargetHR_2))
        # ---------------------------------------------------------------------------------------------[120 characters]
    if "CB008246_K_TC04_HR_IWK_CA_UL_SA_2CC_FDDTDD_SCell_Addition_after_HRDRB" == tc_name:
        check_points.append(verify_legacy_pmc_pusch_hrla(pmc_csv_file, column, PCell, tc_name, path_to_ttitrace_pkl,
                                                         ullaBlerTargetHR_1, ullaBlerTargetHR_2))
        check_points.append(verify_legacy_pmc_pusch_hrla(pmc_csv_file, column, SCell, tc_name, path_to_ttitrace_pkl,
                                                         ullaBlerTargetHR_1, ullaBlerTargetHR_2))
        check_points.append(verify_new_pmc_pusch_hrla(pmc_csv_file, column, PCell, tc_name, path_to_ttitrace_pkl,
                                                      ullaBlerTargetHR_1, ullaBlerTargetHR_2))
        check_points.append(verify_new_pmc_pusch_hrla(pmc_csv_file, column, SCell, tc_name, path_to_ttitrace_pkl,
                                                      ullaBlerTargetHR_1, ullaBlerTargetHR_2))
        check_points.append(verify_maxmcs_based_on_legacy_pmc(pmc_csv_file, column, PCell, tc_name, max_mcs=25))
        check_points.append(verify_maxmcs_based_on_legacy_pmc(pmc_csv_file, column, SCell, tc_name, max_mcs=25))
        check_points.append(verify_HR_existing_QAM64LOWSE(PCell, tc_name, path_to_ttitrace_pkl,
                                                          ullaBlerTargetHR_1, ullaBlerTargetHR_2))
        check_points.append(verify_HR_existing_QAM64LOWSE(SCell, tc_name, path_to_ttitrace_pkl,
                                                          ullaBlerTargetHR_1, ullaBlerTargetHR_2))
        # ---------------------------------------------------------------------------------------------[120 characters]
    if "CB008246_K_TC07_HR_IWK_CA_UL_SA_DFT-s-OFDM" == tc_name:
        check_points.append(verify_SCF_Paramaters_TC07(PCell))
        check_points.append(verify_SCF_Paramaters_TC07(SCell))
        check_points.append(verify_DFT_s_OFDM_switch_in_UL(SCell, path_to_ttitrace_pkl))
        # ---------------------------------------------------------------------------------------------[120 characters]
    if "CB008246_K_TC09_HR_IWK_CA_UL_ACSI_enabled" == tc_name:
        check_points.append(verify_SCF_Paramaters_TC09(PCell))
        check_points.append(verify_SCF_Paramaters_TC09(SCell))
        check_points.append(verify_ACSI_reports_in_UL(PCell, path_to_ttitrace_pkl))
        # ---------------------------------------------------------------------------------------------[120 characters]
    check_points.append(check_no_fatality_error_in_syslogs(path_to_syslog_tgz))  # <--- Common Checkpoint
    # -------------------------------------------------------------------------------------------------[120 characters]
    logging.info("check_points = %s" % check_points)
    tc_verdict = all(check_points)
    logging.info("verify_qc_test_case: tc_verdict = %s" % tc_verdict)
    rbi.set_test_variable("${TEST NAME}", tc_name)  # IMPORTANT: allows "Robot-TC-Name != QC-TC-Name" case
    rbi.should_be_true(tc_verdict)  # IMPORTANT: keep this line the LAST one


# =====================================================================================================[120 characters]
#   Validation Functions
# =====================================================================================================[120 characters]

@log_begin_end_func_name
def verify_SCF_Paramaters(cell):
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${path_to_scf_xml}")
    distname_nrbts = rbi.get_variable_value("${nrbts_str}")[0]
    distname_nrcell = distname_nrbts + "/NRCELL-%s" % cell
    try:
        expected_scf_list = [{'p_name': 'actMultiDrbNSA', 'value': 'true', 'dist_name': distname_nrbts},
                             {'p_name': 'actLAForHiReliab', 'value': 'true', 'dist_name': distname_nrcell},
                             {'p_name': 'actDlMuMimo', 'value': 'false', 'dist_name': distname_nrcell},
                             {'p_name': 'actUlMuMimo', 'value': 'false', 'dist_name': distname_nrcell},
                             {'p_name': 'actCDrx', 'value': 'false', 'dist_name': distname_nrcell},
                             {'p_name': 'actVoNR', 'value': 'false', 'dist_name': distname_nrcell},
                             {'p_name': 'actAdaptiveReTxResMcs', 'value': 'false', 'dist_name': distname_nrcell}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("verify_SCF_Paramaters", e)
    logging.info("is_SCF_correct = %s" % is_SCF_correct)
    return is_SCF_correct


@log_begin_end_func_name
def verify_SCF_Paramaters_TC07(cell):
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${path_to_scf_xml}")
    distname_nrbts = rbi.get_variable_value("${nrbts_str}")[0]
    distname_nrcell = distname_nrbts + "/NRCELL-%s" % cell
    try:
        expected_scf_list = [{'p_name': 'actUlDftSOfdm', 'value': 'true', 'dist_name': distname_nrcell},
                             {'p_name': 'actDl256Qam', 'value': 'true', 'dist_name': distname_nrcell},
                             {'p_name': 'actUl256Qam', 'value': 'true', 'dist_name': distname_nrcell}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("verify_SCF_Paramaters_TC07", e)
    logging.info("is_SCF_correct = %s" % is_SCF_correct)
    return is_SCF_correct


@log_begin_end_func_name
def verify_SCF_Paramaters_TC09(cell):
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${path_to_scf_xml}")
    distname_nrbts = rbi.get_variable_value("${nrbts_str}")[0]
    distname_nrcell = distname_nrbts + "/NRCELL-%s" % cell
    try:
        expected_scf_list = [{'p_name': 'actAperCsi', 'value': 'true', 'dist_name': distname_nrcell}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("verify_SCF_Paramaters_TC09", e)
    logging.info("is_SCF_correct = %s" % is_SCF_correct)
    return is_SCF_correct


@log_begin_end_func_name
def verify_legacy_pmc_pusch_hrla(pmc_csv_file, column, cell, tc_name, path_to_ttitrace_pkl,
                                 ullaBlerTargetHR_1, ullaBlerTargetHR_2):
    are_pmcs_correct = False
    skip_second_profile = (ullaBlerTargetHR_1 == ullaBlerTargetHR_2)
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        pmcs_under_test = get_expected_new_pmc_values(path_to_ttitrace_pkl,
                                                      dir="ul",
                                                      subfeature="E",  # <--- UL over QAM64LOWSE
                                                      cell=cell,
                                                      max_dl_harq_tx=5,  # <--- maxDlHarqTx from scf.xml
                                                      max_ul_harq_tx=5,  # <--- maxUlHarqTx from scf.xml
                                                      targetBlerPrf1=ullaBlerTargetHR_1,
                                                      targetBlerPrf2=ullaBlerTargetHR_2)
        if skip_second_profile:
            piids_and_expected_values = {"M55367C00001": int(pmcs_under_test["M55367C00001"]),
                                         "M55367C00002": int(pmcs_under_test["M55367C00002"]),
                                         "M55367C00003": 0,  # <--- Profile2
                                         "M55367C00004": 0,  # <--- Profile2
                                         "M55367C00005": int(pmcs_under_test["M55367C00005"]),
                                         "M55367C00007": 0}  # <--- Profile2
        else:
            piids_and_expected_values = {"M55367C00001": int(pmcs_under_test["M55367C00001"]),
                                         "M55367C00002": int(pmcs_under_test["M55367C00002"]),
                                         "M55367C00003": int(pmcs_under_test["M55367C00003"]),
                                         "M55367C00004": int(pmcs_under_test["M55367C00004"]),
                                         "M55367C00005": int(pmcs_under_test["M55367C00005"]),
                                         "M55367C00007": int(pmcs_under_test["M55367C00007"])}
        are_pmcs_correct = verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, tc_name,
                                              threshold_percent=2)
    except Exception as e:
        logException("verify_legacy_pmc_pusch_hrla", e)
    logging.info("are_pmcs_correct = %s" % are_pmcs_correct)
    return are_pmcs_correct


@log_begin_end_func_name
def verify_new_pmc_pusch_hrla(pmc_csv_file, column, cell, tc_name, path_to_ttitrace_pkl,
                              ullaBlerTargetHR_1, ullaBlerTargetHR_2):
    are_pmcs_correct = False
    skip_second_profile = (ullaBlerTargetHR_1 == ullaBlerTargetHR_2)
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        pmcs_under_test = get_expected_new_pmc_values(path_to_ttitrace_pkl,
                                                      dir="ul",
                                                      subfeature="I",  # <--- UL over QAM64
                                                      cell=cell,
                                                      max_dl_harq_tx=5,  # <--- maxDlHarqTx from scf.xml
                                                      max_ul_harq_tx=5,  # <--- maxUlHarqTx from scf.xml
                                                      targetBlerPrf1=ullaBlerTargetHR_1,
                                                      targetBlerPrf2=ullaBlerTargetHR_2)
        # [IMPORTANT] M55367C00001..M55367C00012 are just key names for TTITraces and NOT real PM Counters
        # [IMPORTANT] M55302C00029..M55302C00040 are real PM Counters
        if skip_second_profile:
            piids_and_expected_values = {"M55302C00029": int(pmcs_under_test["M55367C00001"]),
                                         "M55302C00030": int(pmcs_under_test["M55367C00002"]),
                                         "M55302C00031": 0,  # <--- Profile2
                                         "M55302C00032": 0,  # <--- Profile2
                                         "M55302C00033": int(pmcs_under_test["M55367C00009"]),
                                         "M55302C00034": int(pmcs_under_test["M55367C00010"]),
                                         "M55302C00035": int(pmcs_under_test["M55367C00011"]),
                                         "M55302C00036": int(pmcs_under_test["M55367C00012"]),
                                         "M55302C00037": int(pmcs_under_test["M55367C00005"]),
                                         "M55302C00038": int(pmcs_under_test["M55367C00006"]),
                                         "M55302C00039": 0,  # <--- Profile2
                                         "M55302C00040": 0}  # <--- Profile2
        else:
            piids_and_expected_values = {"M55302C00029": int(pmcs_under_test["M55367C00001"]),
                                         "M55302C00030": int(pmcs_under_test["M55367C00002"]),
                                         "M55302C00031": int(pmcs_under_test["M55367C00003"]),
                                         "M55302C00032": int(pmcs_under_test["M55367C00004"]),
                                         "M55302C00033": int(pmcs_under_test["M55367C00009"]),
                                         "M55302C00034": int(pmcs_under_test["M55367C00010"]),
                                         "M55302C00035": int(pmcs_under_test["M55367C00011"]),
                                         "M55302C00036": int(pmcs_under_test["M55367C00012"]),
                                         "M55302C00037": int(pmcs_under_test["M55367C00005"]),
                                         "M55302C00038": int(pmcs_under_test["M55367C00006"]),
                                         "M55302C00039": int(pmcs_under_test["M55367C00007"]),
                                         "M55302C00040": int(pmcs_under_test["M55367C00008"])}
        are_pmcs_correct = verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, tc_name,
                                              threshold_percent=3)
    except Exception as e:
        logException("verify_new_pmc_pusch_hrla", e)
    logging.info("are_pmcs_correct = %s" % are_pmcs_correct)
    return are_pmcs_correct


@log_begin_end_func_name
def verify_maxmcs_based_on_legacy_pmc(pmc_csv_file, column, cell, tc_name, max_mcs):
    is_maxmc_correct = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        piids_and_expected_values = {}
        for mcs in range(max_mcs+1, 29):
            piids_and_expected_values["M55367C010%s" % mcs] = 0
        logging.info("piids_and_expected_values = %s" % piids_and_expected_values)
        is_maxmc_correct = verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, tc_name,
                                              threshold_percent=1)
    except Exception as e:
        logException("verify_maxmcs_based_on_legacy_pmc", e)
    logging.info("is_maxmc_correct = %s" % is_maxmc_correct)
    return is_maxmc_correct


@log_begin_end_func_name
def verify_maxmcs_based_on_tti(path_to_ttitrace_pkl, cell, lamode, max_mcs):
    is_maxmc_correct = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    path_to_ttitrace_pkl = os.path.dirname(path_to_ttitrace_pkl) + "/ttitrace_streaming_ulharq.pkl"
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='ul')
        A = 'lcrId'
        B = 'ulFdSchedData.rrmUlUsedMcs'
        C = 'ulFdSchedData.laMode'
        df_notna = df.loc[df[C].notna()]
        df_filtered = df_notna[[A, B, C]]
        logging.info("df_filtered = \n%s" % df_filtered)
        df_filtered_lcrid = df_filtered.loc[df_filtered[A] == cell]
        df_filtered_lcrid_lamode = df_filtered_lcrid.loc[df_filtered_lcrid[C] == lamode]
        df_optimized = df_filtered_lcrid_lamode[[B]]
        logging.info("df_optimized = \n%s" % df_optimized)
        is_maxmc_correct = not (df_optimized[B] > max_mcs).any()
    except Exception as e:
        logException("verify_maxmcs_based_on_tti", e)
    logging.info("is_maxmc_correct = %s" % is_maxmc_correct)
    return is_maxmc_correct


@log_begin_end_func_name
def verify_maxmcs_based_on_new_pmc(pmc_csv_file, column, cell, tc_name, max_mcs):
    is_maxmc_correct = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        piids_and_expected_values = {}
        for mcs in range(max_mcs+1, 29):
            piids_and_expected_values["M55302C000%s" % mcs] = 0
        logging.info("piids_and_expected_values = %s" % piids_and_expected_values)
        is_maxmc_correct = verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, tc_name,
                                              threshold_percent=1)
    except Exception as e:
        logException("verify_maxmcs_based_on_new_pmc", e)
    logging.info("is_maxmc_correct = %s" % is_maxmc_correct)
    return is_maxmc_correct


@log_begin_end_func_name
def verify_maxmcs_based_on_ttitraces(path_to_ttitrace_pkl, dir, cell, max_mcs):
    is_maxmc_correct = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir=dir)
        timestamp = 'timeStamp'
        lcrId = 'lcrId'
        laMode = '{}FdSchedData.laMode'.format(dir)
        usedMcs = '{}FdSchedData.rrm{}UsedMcs'.format(dir, dir.capitalize())
        proposedMcs = '{}FdSchedData.rrm{}ProposedMcs'.format(dir, dir.capitalize())
        dciFormat = '{}FdSchedData.dciFormat'.format(dir)
        mcsTable = '{}FdSchedData.mcsTable'.format(dir)
        df_optimized = df[[timestamp, lcrId, laMode, usedMcs, proposedMcs, dciFormat, mcsTable]]
        df_filtered = df_optimized.loc[df_optimized[lcrId] == cell]
        df_filtered = df_filtered.loc[df_filtered[laMode] == 'HIGHRELIABILITY']
        df_filtered = df_filtered.loc[~df_filtered[dciFormat].str.contains('MSG|INVALID|FORCE')]
        logging.info("df_filtered = %s" % df_filtered)
        df_with_highermcs = df_filtered.loc[df_filtered[usedMcs] > max_mcs]
        logging.info("df_with_highermcs = %s" % df_with_highermcs)
        is_maxmc_correct = df_with_highermcs.empty
    except Exception as e:
        logException("verify_maxmcs_based_on_ttitraces", e)
    logging.info("is_maxmc_correct = %s" % is_maxmc_correct)
    return is_maxmc_correct


@log_begin_end_func_name
def verify_profile_switch_QAM64LOWSE(cell, tc_name, path_to_ttitrace_pkl, ullaBlerTargetHR_1, ullaBlerTargetHR_2,
                                     ratio):
    do_profiles_switch_correctly = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        pmcs_under_test = get_expected_new_pmc_values(path_to_ttitrace_pkl,
                                                      dir="ul",
                                                      subfeature="E",  # <--- UL over QAM64LOWSE
                                                      cell=cell,
                                                      max_dl_harq_tx=5,  # <--- maxDlHarqTx from scf.xml
                                                      max_ul_harq_tx=5,  # <--- maxUlHarqTx from scf.xml
                                                      targetBlerPrf1=ullaBlerTargetHR_1,
                                                      targetBlerPrf2=ullaBlerTargetHR_2)
        # [IMPORTANT] M55367C00001 and M55367C00003 are just key names for TTITraces and NOT real PM Counters
        deviation = abs(int(pmcs_under_test["M55367C00001"])/int(pmcs_under_test["M55367C00003"]) - ratio)
        logging.info("deviation = %s" % deviation)
        allowed_deviation = (10 / 100) * ratio
        logging.info("allowed_deviation = %s" % allowed_deviation)
        do_profiles_switch_correctly = deviation < allowed_deviation
    except Exception as e:
        logException("verify_profile_switch_QAM64LOWSE", e)
    logging.info("do_profiles_switch_correctly = %s" % do_profiles_switch_correctly)
    return do_profiles_switch_correctly


@log_begin_end_func_name
def verify_profile_existing_QAM64LOWSE(cell, tc_name, path_to_ttitrace_pkl, ullaBlerTargetHR_1, ullaBlerTargetHR_2):
    are_both_profiles_existing = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        pmcs_under_test = get_expected_new_pmc_values(path_to_ttitrace_pkl,
                                                      dir="ul",
                                                      subfeature="E",  # <--- UL over QAM64LOWSE
                                                      cell=cell,
                                                      max_dl_harq_tx=5,  # <--- maxDlHarqTx from scf.xml
                                                      max_ul_harq_tx=5,  # <--- maxUlHarqTx from scf.xml
                                                      targetBlerPrf1=ullaBlerTargetHR_1,
                                                      targetBlerPrf2=ullaBlerTargetHR_2)
        # [IMPORTANT] M55367C00001 and M55367C00003 are just key names for TTITraces and NOT real PM Counters
        profile1 = int(pmcs_under_test["M55367C00001"])
        profile2 = int(pmcs_under_test["M55367C00003"])
        logging.info("Number of TXs on profile1 = %s" % profile1)
        logging.info("Number of TXs on profile2 = %s" % profile2)
        are_both_profiles_existing = (profile1 > 0) and (profile2 > 0)
    except Exception as e:
        logException("verify_profile_existing_QAM64LOWSE", e)
    logging.info("are_both_profiles_existing = %s" % are_both_profiles_existing)
    return are_both_profiles_existing


@log_begin_end_func_name
def verify_HR_existing_QAM64LOWSE(cell, tc_name, path_to_ttitrace_pkl, ullaBlerTargetHR_1, ullaBlerTargetHR_2):
    are_both_profiles_existing = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        pmcs_under_test = get_expected_new_pmc_values(path_to_ttitrace_pkl,
                                                      dir="ul",
                                                      subfeature="E",  # <--- UL over QAM64LOWSE
                                                      cell=cell,
                                                      max_dl_harq_tx=5,  # <--- maxDlHarqTx from scf.xml
                                                      max_ul_harq_tx=5,  # <--- maxUlHarqTx from scf.xml
                                                      targetBlerPrf1=ullaBlerTargetHR_1,
                                                      targetBlerPrf2=ullaBlerTargetHR_2)
        # [IMPORTANT] M55367C00001 and M55367C00003 are just key names for TTITraces and NOT real PM Counters
        profile1 = int(pmcs_under_test["M55367C00001"])
        profile2 = int(pmcs_under_test["M55367C00003"])
        logging.info("Number of TXs on profile1 = %s" % profile1)
        logging.info("Number of TXs on profile2 = %s" % profile2)
        are_both_profiles_existing = (profile1 > 0) or (profile2 > 0)
    except Exception as e:
        logException("verify_profile_existing_QAM64LOWSE", e)
    logging.info("are_both_profiles_existing = %s" % are_both_profiles_existing)
    return are_both_profiles_existing


@log_begin_end_func_name
def verify_profile_switch_QAM64(cell, tc_name, path_to_ttitrace_pkl, ullaBlerTargetHR_1, ullaBlerTargetHR_2, ratio):
    do_profiles_switch_correctly = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        pmcs_under_test = get_expected_new_pmc_values(path_to_ttitrace_pkl,
                                                      dir="ul",
                                                      subfeature="I",  # <--- UL over QAM64
                                                      cell=cell,
                                                      max_dl_harq_tx=5,  # <--- maxDlHarqTx from scf.xml
                                                      max_ul_harq_tx=5,  # <--- maxUlHarqTx from scf.xml
                                                      targetBlerPrf1=ullaBlerTargetHR_1,
                                                      targetBlerPrf2=ullaBlerTargetHR_2)
        # [IMPORTANT] M55367C00001 and M55367C00003 are just key names for TTITraces and NOT real PM Counters
        deviation = abs(int(pmcs_under_test["M55367C00001"])/int(pmcs_under_test["M55367C00003"]) - ratio)
        logging.info("deviation = %s" % deviation)
        allowed_deviation = (10 / 100) * ratio
        logging.info("allowed_deviation = %s" % allowed_deviation)
        do_profiles_switch_correctly = deviation < allowed_deviation
    except Exception as e:
        logException("verify_profile_switch_QAM64", e)
    logging.info("do_profiles_switch_correctly = %s" % do_profiles_switch_correctly)
    return do_profiles_switch_correctly


@log_begin_end_func_name
def verify_profile_existing_QAM64(cell, tc_name, path_to_ttitrace_pkl, ullaBlerTargetHR_1, ullaBlerTargetHR_2):
    are_both_profiles_existing = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        pmcs_under_test = get_expected_new_pmc_values(path_to_ttitrace_pkl,
                                                      dir="ul",
                                                      subfeature="I",  # <--- UL over QAM64
                                                      cell=cell,
                                                      max_dl_harq_tx=5,  # <--- maxDlHarqTx from scf.xml
                                                      max_ul_harq_tx=5,  # <--- maxUlHarqTx from scf.xml
                                                      targetBlerPrf1=ullaBlerTargetHR_1,
                                                      targetBlerPrf2=ullaBlerTargetHR_2)
        # [IMPORTANT] M55367C00001 and M55367C00003 are just key names for TTITraces and NOT real PM Counters
        profile1 = int(pmcs_under_test["M55367C00001"])
        profile2 = int(pmcs_under_test["M55367C00003"])
        logging.info("Number of TXs on profile1 = %s" % profile1)
        logging.info("Number of TXs on profile2 = %s" % profile2)
        are_both_profiles_existing = (profile1 > 0) and (profile2 > 0)
    except Exception as e:
        logException("verify_profile_existing_QAM64", e)
    logging.info("are_both_profiles_existing = %s" % are_both_profiles_existing)
    return are_both_profiles_existing


@log_begin_end_func_name
def verify_nack_flood_in_DL(path_to_ttitrace_pkl):
    does_nackflood_cause_fallback = False
    is_there_nackflood_on_hr = False
    is_there_recovery = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    path_to_ttitrace_pkl = os.path.dirname(path_to_ttitrace_pkl) + "/ttitrace_streaming_dlharq.pkl"
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='dl')
        column_name_1 = 'timeStamp'
        column_name_2 = 'dlLaSwitchBetweenHrAndBr.event'
        column_name_3 = 'dlLaSwitchBetweenHrAndBr.laMode'
        column_name_4 = 'dlLaSwitchBetweenHrAndBr.pdschMetric.ratio'
        df_filtered = df.loc[df[column_name_2].notna()]
        df_optimized = df_filtered[[column_name_1, column_name_2, column_name_3, column_name_4]]
        logging.info("df_optimized = \n%s" % df_optimized)
        dllaswitch_list = df_optimized.to_csv(index=False, header=False).splitlines()
        logging.info("dllaswitch_list = \n%s" % '\n'.join(dllaswitch_list))
        # ---------------------------------------------------------------------------------------------[120 characters]
        is_there_nackflood_on_hr = any('DLNACKFLOOD,HIGHRELIABILITY' in elem for elem in dllaswitch_list)
        does_nackflood_cause_fallback = any('DLNACKFLOOD,BASICRELIABILITY' in elem for elem in dllaswitch_list)
        is_there_recovery = any('DLHRBLERRECOVERPERIODTIMER,HIGHRELIABILITY' in elem for elem in dllaswitch_list)
    except Exception as e:
        logException("verify_nack_flood", e)
    logging.info("is_there_nackflood_on_hr = %s" % is_there_nackflood_on_hr)
    logging.info("does_nackflood_cause_fallback = %s" % does_nackflood_cause_fallback)
    logging.info("is_there_recovery = %s" % is_there_recovery)
    return is_there_nackflood_on_hr and does_nackflood_cause_fallback and is_there_recovery


@log_begin_end_func_name
def verify_HR_BR_switch_in_UL(cell, path_to_ttitrace_pkl):
    is_HR_BR_switch_in_UL = False
    does_HR_BR_switch = False
    is_ULHRBLEROUTAGE_on_hr = False
    is_there_recovery = False
    nbr_HR_BR_outage = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    path_to_ttitrace_pkl = os.path.dirname(path_to_ttitrace_pkl) + "/ttitrace_streaming_ulharq.pkl"
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='ul')
        timestamp = 'timeStamp'
        event = 'ulLaSwitchBetweenHrAndBr.event'
        lcrId = 'lcrId'
        laMode = 'ulLaSwitchBetweenHrAndBr.laMode'
        puschMetricRatio = 'ulLaSwitchBetweenHrAndBr.puschMetric.ratio'
        df_filtered = df.loc[df[event].notna()]
        df_filtered = df_filtered.loc[df_filtered[lcrId] == cell]
        df_optimized = df_filtered[[event, laMode]]
        logging.info("df_optimized = \n%s" % df_optimized)
        ullaswitch_list = df_optimized.to_csv(index=False, header=False).splitlines()
        logging.info("ullaswitch_list = \n%s" % '\n'.join(ullaswitch_list))
        # ---------------------------------------------------------------------------------------------[120 characters]
        is_ULHRBLEROUTAGE_on_hr = any('ULHRBLEROUTAGEPERIODTIMER,HIGHRELIABILITY' in elem for elem in ullaswitch_list)
        does_HR_BR_switch = any('ULHRBLEROUTAGEPERIODTIMER,BASICRELIABILITY' in elem for elem in ullaswitch_list)
        is_there_recovery = any('ULHRBLERRECOVERPERIODTIMER,HIGHRELIABILITY' in elem for elem in ullaswitch_list)
        nbr_HR_BR_outage = ullaswitch_list.count('ULHRBLEROUTAGEPERIODTIMER,BASICRELIABILITY')
        nbr_HR_BR_recover = ullaswitch_list.count('ULHRBLERRECOVERPERIODTIMER,HIGHRELIABILITY')
        nbr_HR_BR_switch = (nbr_HR_BR_outage == 1 and nbr_HR_BR_recover == 1)
    except Exception as e:
        logException("verify_HR_BR_switch", e)
    logging.info("is_ULHRBLEROUTAGE_on_hr = %s" % is_ULHRBLEROUTAGE_on_hr)
    logging.info("does_HR_BR_switch = %s" % does_HR_BR_switch)
    logging.info("is_there_recovery = %s" % is_there_recovery)
    logging.info("nbr_HR_BR_outage = %s" % nbr_HR_BR_outage)
    logging.info("nbr_HR_BR_recover = %s" % nbr_HR_BR_recover)
    is_HR_BR_switch_in_UL = is_ULHRBLEROUTAGE_on_hr and does_HR_BR_switch and is_there_recovery and nbr_HR_BR_switch
    logging.info("is_HR_BR_switch_in_UL = %s" % is_HR_BR_switch_in_UL)
    return is_HR_BR_switch_in_UL


@log_begin_end_func_name
def verify_HR_BR_switch_in_DL(path_to_ttitrace_pkl):
    does_HR_BR_switch = False
    is_DLHRBLEROUTAGE_on_hr = False
    is_there_recovery = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    path_to_ttitrace_pkl = os.path.dirname(path_to_ttitrace_pkl) + "/ttitrace_streaming_dlharq.pkl"
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='dl')
        column_name_1 = 'timeStamp'
        column_name_2 = 'dlLaSwitchBetweenHrAndBr.event'
        column_name_3 = 'dlLaSwitchBetweenHrAndBr.laMode'
        column_name_4 = 'dlLaSwitchBetweenHrAndBr.pdschMetric.ratio'
        df_filtered = df.loc[df[column_name_2].notna()]
        df_optimized = df_filtered[[column_name_1, column_name_2, column_name_3, column_name_4]]
        logging.info("df_optimized = \n%s" % df_optimized)
        dllaswitch_list = df_optimized.to_csv(index=False, header=False).splitlines()
        logging.info("dllaswitch_list = \n%s" % '\n'.join(dllaswitch_list))
        # ---------------------------------------------------------------------------------------------[120 characters]
        is_DLHRBLEROUTAGE_on_hr = any('DLHRBLEROUTAGEPERIODTIMER,HIGHRELIABILITY' in elem for elem in dllaswitch_list)
        does_HR_BR_switch = any('DLHRBLEROUTAGEPERIODTIMER,BASICRELIABILITY' in elem for elem in dllaswitch_list)
        is_there_recovery = any('DLHRBLERRECOVERPERIODTIMER,HIGHRELIABILITY' in elem for elem in dllaswitch_list)
    except Exception as e:
        logException("verify_HR_BR_switch", e)
    logging.info("is_DLHRBLEROUTAGE_on_hr = %s" % is_DLHRBLEROUTAGE_on_hr)
    logging.info("does_HR_BR_switch = %s" % does_HR_BR_switch)
    logging.info("is_there_recovery = %s" % is_there_recovery)
    return is_DLHRBLEROUTAGE_on_hr and does_HR_BR_switch and is_there_recovery


@log_begin_end_func_name
def verify_nack_flood_in_UL(path_to_ttitrace_pkl):
    does_nackflood_cause_fallback = False
    is_there_nackflood_on_hr = False
    is_there_recovery = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='ul')
        column_name_1 = 'timeStamp'
        column_name_2 = 'ulLaSwitchBetweenHrAndBr.event'
        column_name_3 = 'ulLaSwitchBetweenHrAndBr.laMode'
        column_name_4 = 'ulLaSwitchBetweenHrAndBr.puschMetric.ratio'
        df_filtered = df.loc[df[column_name_2].notna()]
        df_optimized = df_filtered[[column_name_1, column_name_2, column_name_3, column_name_4]]
        logging.info("df_optimized = \n%s" % df_optimized)
        dllaswitch_list = df_optimized.to_csv(index=False, header=False).splitlines()
        logging.info("dllaswitch_list = \n%s" % '\n'.join(dllaswitch_list))
        # ---------------------------------------------------------------------------------------------[120 characters]
        is_there_nackflood_on_hr = any('ULNACKFLOOD,HIGHRELIABILITY' in elem for elem in dllaswitch_list)
        does_nackflood_cause_fallback = any('ULNACKFLOOD,BASICRELIABILITY' in elem for elem in dllaswitch_list)
        is_there_recovery = any('ULHRBLERRECOVERPERIODTIMER,HIGHRELIABILITY' in elem for elem in dllaswitch_list)
    except Exception as e:
        logException("verify_nack_flood_in_UL", e)
    logging.info("is_there_nackflood_on_hr = %s" % is_there_nackflood_on_hr)
    logging.info("does_nackflood_cause_fallback = %s" % does_nackflood_cause_fallback)
    logging.info("is_there_recovery = %s" % is_there_recovery)
    return is_there_nackflood_on_hr and does_nackflood_cause_fallback and is_there_recovery


@log_begin_end_func_name
def plot_for_DL(path_to_ttitrace_pkl, tc_name):
    global sw_build
    targetBLER = 'dlFdSchedAdditionalData.targetBLER'
    try:
        path_to_ttitrace_pkl = os.path.dirname(path_to_ttitrace_pkl) + "/ttitrace_streaming_dlharq.pkl"
        # ---------------------------------------------------------------------------------------------[120 characters]
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='dl')
        plot_df_with_scatter(df=df,
                             yaxis_column='dlFdSchedData.laMode',
                             base_location=os.path.dirname(path_to_ttitrace_pkl),
                             postfix="UL",
                             xaxis_column="timeStamp",
                             title=tc_name,
                             group_by='rnti',
                             second_yaxis_col='dlFdSchedData.ackNack',
                             third_yaxis_col=targetBLER,
                             fourth_yaxis_col='dlFdSchedData.txNumber')
        plot_df_with_scatter(df=df,
                             yaxis_column='dlFdSchedData.rrmDlUsedMcs',
                             base_location=os.path.dirname(path_to_ttitrace_pkl),
                             postfix="DL_Mcs",
                             xaxis_column="timeStamp",
                             title=tc_name,
                             second_yaxis_col='dlFdSchedData.rrmDlProposedMcs',
                             group_by='rnti')
    except Exception as e:
        logException("plot_for_DL", e)


@log_begin_end_func_name
def plot_for_UL(path_to_ttitrace_pkl, tc_name):
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='ul')

        plot_df_with_scatter(df=df,
                             yaxis_column='ulFdSchedData.laMode',
                             base_location=os.path.dirname(path_to_ttitrace_pkl),
                             postfix="UL",
                             xaxis_column="timeStamp",
                             title=tc_name,
                             group_by='rnti',
                             second_yaxis_col='ulHarqRxData.crcResult',
                             third_yaxis_col='ulFdSchedAdditionalData.targetBLER',
                             fourth_yaxis_col='ulFdSchedData.txNumber')
        plot_df_with_scatter(df=df,
                             yaxis_column='ulFdSchedData.rrmUlUsedMcs',
                             base_location=os.path.dirname(path_to_ttitrace_pkl),
                             postfix="UL_Mcs",
                             xaxis_column="timeStamp",
                             title=tc_name,
                             second_yaxis_col='ulFdSchedData.rrmUlProposedMcs',
                             third_yaxis_col='ulFdSchedData.sampledWideBandTbs',
                             group_by='rnti')
    except Exception as e:
        logException("plot_for_UL", e)


@log_begin_end_func_name
def verify_rrmDeltaSinr_in_UL(path_to_ttitrace_pkl):
    my_list = []
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='ul')
        timestamp = 'timeStamp'
        rnti = 'rnti'
        physCellId = 'physCellId'
        isDeltaSinrCalculated = 'ulLaDeltaSinr.isDeltaSinrCalculated'
        crcFb = 'ulLaDeltaSinr.crcFb'
        rrmDeltaSinr = 'ulLaDeltaSinr.rrmDeltaSinr'
        targetBlerType = 'ulLaDeltaSinr.targetBlerType'
        ulUsedMcs = 'ulLaDeltaSinr.ulUsedMcs'
        df_filtered = df.loc[df[rrmDeltaSinr].notna()]
        df_filtered_selected = df_filtered[[rnti, physCellId, isDeltaSinrCalculated, crcFb, rrmDeltaSinr,
                                            targetBlerType, ulUsedMcs]]
        df_optimized = df_filtered_selected.groupby('physCellId').get_group(50)
        logging.info("df_optimized = \n%s" % df_optimized)
        df_optimized_rnti = df_optimized.groupby('rnti')
        for group_name, group_data in df_optimized_rnti:
            group_data = group_data.loc[group_data[isDeltaSinrCalculated] == 1]
            first_HR_index = (group_data[targetBlerType] == 'HIGHRELIABLE').idxmax()
            group_filtred = group_data.iloc[first_HR_index:-1]
            group_filtred[crcFb] = group_filtred[crcFb].replace({'OK': 0.0202, 'NOK': -2})
            group_filtred['Value_Difference'] = group_filtred[rrmDeltaSinr] - group_filtred[rrmDeltaSinr].shift(1)
            df_rrmDeltaSinr = group_filtred.dropna()
            df_rrmDeltaSinr['Value_Difference'] = df_rrmDeltaSinr['Value_Difference'].round(4)
            df_rrmDeltaSinr[crcFb] = df_rrmDeltaSinr[crcFb].round(4)
            df_rrmDeltaSinr_filtred = df_rrmDeltaSinr.query("Value_Difference != 0.0202 and Value_Difference != -2")
            logging.info("df_rrmDeltaSinr_filtred = \n%s" % df_rrmDeltaSinr_filtred)
            if (df_rrmDeltaSinr_filtred[ulUsedMcs] == 25).all():
                # Remove rows from df1 based on matching rows in df2
                merged_df = df_rrmDeltaSinr_filtred.merge(df_rrmDeltaSinr, how='left', indicator=True)
                result_df = merged_df[merged_df['_merge'] != 'both'].drop('_merge', axis=1)
                are_equal = result_df[crcFb].equals(result_df['Value_Difference'])
            else:
                are_equal = df_rrmDeltaSinr[crcFb].equals(df_rrmDeltaSinr['Value_Difference'])
            my_list.append(are_equal)
    except Exception as e:
        logException("verify_rrmDeltaSinr_in_UL", e)
    logging.info("my_list = %s" % my_list)
    return all(my_list)


@log_begin_end_func_name
def verify_ACSI_reports_in_UL(cell, path_to_ttitrace_pkl):
    are_there_acsi_reports_on_hr = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    path_to_ttitrace_pkl = os.path.dirname(path_to_ttitrace_pkl) + "/ttitrace_streaming_ulharq.pkl"
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='ul')
        df = merge_ulFdSchedData_and_csiSrReportData(df).copy()
        timestamp = 'timeStamp'
        lcrId = 'lcrId_y'  # - there are two columns after merge of 'ulFdSchedData' and 'csiSrReportData'
        laMode = 'ulFdSchedData.laMode'
        reportType = 'csiSrReportData.reportType'
        ueType = 'ulFdSchedData.ueType'
        df_filtered = df.loc[df[reportType].notna()]
        df_filtered = df_filtered.loc[df_filtered[lcrId] == cell]
        df_optimized = df_filtered[[lcrId, reportType, laMode, ueType]]
        logging.info("df_optimized = \n%s" % df_optimized)
        ullaswitch_list = df_optimized.to_csv(index=False, header=False).splitlines()
        logging.info("ullaswitch_list = \n%s" % '\n'.join(ullaswitch_list))
        # ---------------------------------------------------------------------------------------------[120 characters]
        are_there_acsi_reports_on_hr = any('APERIODIC_CSI,HIGHRELIABILITY' in elem for elem in ullaswitch_list)
    except Exception as e:
        logException("verify_ACSI_reports_in_UL", e)
    logging.info("are_there_acsi_reports_on_hr = %s" % are_there_acsi_reports_on_hr)
    return are_there_acsi_reports_on_hr


@log_begin_end_func_name
def verify_DFT_s_OFDM_switch_in_UL(cell, path_to_ttitrace_pkl):
    is_there_DFT_s_OFDM_switch = False
    is_there_BR_to_HR_switch = False
    is_highMCS_recovered = False
    # -------------------------------------------------------------------------------------------------[120 characters]
    path_to_ttitrace_pkl = os.path.dirname(path_to_ttitrace_pkl) + "/ttitrace_streaming_ulharq.pkl"
    # -------------------------------------------------------------------------------------------------[120 characters]
    try:

        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='ul')

        timestamp = 'timeStamp'
        lcrId = 'lcrId'
        laMode = 'ulFdSchedData.laMode'
        puschTPstate = 'ulFdSchedData.puschTPstate'
        tpHystCounter = 'ulFdSchedData.tpHystCounter'
        ueType = 'ulFdSchedData.ueType'
        mcsTable = 'ulFdSchedData.mcsTable'
        ulFdSchedData = 'ulFdSchedData.dciFormat'
        rrmUlUsedMcs = 'ulFdSchedData.rrmUlUsedMcs'
        df_filtered = df.loc[df[puschTPstate].notna()]
        df_filtered = df_filtered.loc[df_filtered[lcrId] == cell]
        df_filtered = df_filtered.loc[df_filtered[ulFdSchedData] != 'INVALID']
        df_filtered[puschTPstate] = df_filtered[puschTPstate].astype(str)

        df_optimized = df_filtered[[lcrId, puschTPstate, laMode, ueType, mcsTable, tpHystCounter,
                                    'ulFdSchedData.rrmAvgSinrTpSwitch', ulFdSchedData, rrmUlUsedMcs]]
        logging.info("df_optimized = \n%s" % df_optimized)
        ullaswitch_list = df_optimized.to_csv(index=False, header=False).splitlines()
        # ---------------------------------------------------------------------------------------------[120 characters]
        header = df_optimized.columns.tolist()
        header = [s.replace('ulFdSchedData.', '').strip() for s in header]
        list_to_print = df_optimized.values.tolist()
        logging.info("ONLY an EVERY 20th row: \n")
        logging.info(tabulate(list_to_print[::20], headers=header, tablefmt='grid'))
        # --- "EDA for 03769319" Verification: --------------------------------------------------------[120 characters]
        grouped_dfs_dict = {name: group for name, group in df_optimized.groupby([puschTPstate, laMode, mcsTable])}
        logging.info(grouped_dfs_dict.keys())
        df_EDA = grouped_dfs_dict[('DISABLED', 'HIGHRELIABILITY', 'QAM64LOWSE')]
        logging.info(df_EDA)
        last_rrmUlUsedMcs_values = df_EDA[rrmUlUsedMcs].tail(10)
        logging.info("last_rrmUlUsedMcs_values = %s" % last_rrmUlUsedMcs_values)
        average_of_last_rrmUlUsedMcs_values = last_rrmUlUsedMcs_values.mean()
        logging.info("average_of_last_rrmUlUsedMcs_values = %s" % average_of_last_rrmUlUsedMcs_values)
        is_highMCS_recovered = average_of_last_rrmUlUsedMcs_values > 18
        # ---------------------------------------------------------------------------------------------[120 characters]
        is_there_DFT_s_OFDM_switch = \
            (any(',ENABLED,BASICRELIABILITY,SCELL,QAM64TRANSFORMPRECODER,' in elem for elem in ullaswitch_list))
        is_there_BR_to_HR_switch = \
            (any(',DISABLED,HIGHRELIABILITY,SCELL,QAM64LOWSE,' in elem for elem in ullaswitch_list))
    except Exception as e:
        logException("verify_DFT_s_OFDM_switch_in_UL", e)
    logging.info("is_there_DFT_s_OFDM_switch = %s" % is_there_DFT_s_OFDM_switch)
    logging.info("is_there_BR_to_HR_switch = %s" % is_there_BR_to_HR_switch)
    logging.info("is_highMCS_recovered = %s" % is_highMCS_recovered)
    return is_there_DFT_s_OFDM_switch and is_there_BR_to_HR_switch and is_highMCS_recovered


# =====================================================================================================[120 characters]
#   Private Functions
# =====================================================================================================[120 characters]

@log_begin_end_func_name
def merge_ulFdSchedData_and_csiSrReportData(df):
    """ This function alignes 'ulFdSchedData' and 'csiSrReportData' columns based on
        similar 'time', 'sfn', ..., 'rnti' values """
    # -------------------------------------------------------------------------------------------------[120 characters]
    fdSchedData_df = df.loc[:, df.columns.str.startswith(
        ('ulFdSchedData', 'timeStamp', 'sfn', 'slot', 'rnti', 'lcrId'))].copy()
    fdSchedData_df = fdSchedData_df.dropna(subset=['ulFdSchedData.txNumber'])
    fdSchedData_df['hour'] = pd.to_datetime(fdSchedData_df['timeStamp']).dt.hour
    fdSchedData_df['minute'] = pd.to_datetime(fdSchedData_df['timeStamp']).dt.minute
    fdSchedData_df['second'] = pd.to_datetime(fdSchedData_df['timeStamp']).dt.second
    fdSchedData_df['time_sfn_slot_rnti_lcrId'] = fdSchedData_df[['hour', 'minute', 'second', 'sfn', 'slot',
                                                                 'rnti', 'lcrId']].astype(str).agg('-'.join, axis=1)
    logging.info("fdSchedData_df (%s) = \n%s" % (len(fdSchedData_df), fdSchedData_df))
    # -------------------------------------------------------------------------------------------------[120 characters]
    csiSrReportData_df = df.loc[:, df.columns.str.startswith(
        ('csiSrReportData', 'timeStamp', 'sfn', 'slot', 'rnti', 'lcrId'))].copy()
    csiSrReportData_df = csiSrReportData_df.dropna(subset=['csiSrReportData.reportType'])
    csiSrReportData_df['hour'] = pd.to_datetime(csiSrReportData_df['timeStamp']).dt.hour
    csiSrReportData_df['minute'] = pd.to_datetime(csiSrReportData_df['timeStamp']).dt.minute
    csiSrReportData_df['second'] = pd.to_datetime(csiSrReportData_df['timeStamp']).dt.second
    csiSrReportData_df['time_sfn_slot_rnti_lcrId'] = csiSrReportData_df[['hour', 'minute', 'second',
                                                                         'sfn', 'slot', 'rnti',
                                                                         'lcrId']].astype(str).agg('-'.join, axis=1)
    logging.info("csiSrReportData_df (%s) = \n%s" % (len(csiSrReportData_df), csiSrReportData_df))
    # -------------------------------------------------------------------------------------------------[120 characters]
    merged_df = pd.merge(fdSchedData_df, csiSrReportData_df, how="left", on='time_sfn_slot_rnti_lcrId').dropna()
    logging.info("merged_df (%s) = \n%s" % (len(merged_df), merged_df))
    return merged_df


@log_begin_end_func_name
def get_df_from_pkl(path_to_pickle, dir):
    global sw_build
    ackNack = 'dlFdSchedData.ackNack'
    crcResult = 'ulHarqRxData.crcResult'
    txNumber = '{}FdSchedData.txNumber'.format(dir)
    mcsTable = '{}FdSchedData.mcsTable'.format(dir)
    laMode = '{}FdSchedData.laMode'.format(dir)
    if dir == 'ul':
        targetBLER = 'ulFdSchedAdditionalData.targetBLER'
    else:
        targetBLER = 'dlFdSchedAdditionalData.targetBLER'
    sampledWideBandTbs = 'ulFdSchedData.sampledWideBandTbs'
    rrmAvgSinrTpSwitch = 'ulFdSchedData.rrmAvgSinrTpSwitch'
    usedMcs = '{}FdSchedData.rrm{}UsedMcs'.format(dir, dir.capitalize())
    proposedMcs = '{}FdSchedData.rrm{}ProposedMcs'.format(dir, dir.capitalize())
    dlLaSwitchEvent = 'dlLaSwitchBetweenHrAndBr.event'
    dlLaSwitchLaMode = 'dlLaSwitchBetweenHrAndBr.laMode'
    dlLaSwitchRatio = 'dlLaSwitchBetweenHrAndBr.pdschMetric.ratio'
    ulLaSwitchEvent = 'ulLaSwitchBetweenHrAndBr.event'
    ulLaSwitchLaMode = 'ulLaSwitchBetweenHrAndBr.laMode'
    ulLaSwitchRatio = 'ulLaSwitchBetweenHrAndBr.puschMetric.ratio'
    isDeltaSinrCalculated = 'ulLaDeltaSinr.isDeltaSinrCalculated'
    crcFb = 'ulLaDeltaSinr.crcFb'
    rrmDeltaSinr = 'ulLaDeltaSinr.rrmDeltaSinr'
    targetBlerType = 'ulLaDeltaSinr.targetBlerType'
    ulUsedMcs = 'ulLaDeltaSinr.ulUsedMcs'
    puschTPstate = 'ulFdSchedData.puschTPstate'
    tpHystCounter = 'ulFdSchedData.tpHystCounter'
    ueType = 'ulFdSchedData.ueType'
    reportType = 'csiSrReportData.reportType'
    dciFormat = '{}FdSchedData.dciFormat'.format(dir)
    # -------------------------------------------------------------------------------------------------[120 characters]
    df = pd.read_pickle(path_to_pickle)
    if dir == 'dl':
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', ackNack, txNumber, mcsTable,
                 laMode, targetBLER, usedMcs, dlLaSwitchEvent, dlLaSwitchLaMode, dlLaSwitchRatio, proposedMcs,
                 dciFormat]]
    else:
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', crcResult, txNumber, mcsTable,
                 laMode, targetBLER, usedMcs, sampledWideBandTbs, ulLaSwitchEvent, ulLaSwitchLaMode,
                 ulLaSwitchRatio, proposedMcs, isDeltaSinrCalculated, crcFb, rrmDeltaSinr, targetBlerType,
                 ulUsedMcs, puschTPstate, tpHystCounter, rrmAvgSinrTpSwitch, reportType, ueType, dciFormat]]
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
