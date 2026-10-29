# ====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd68 for CB008246 Feature
# Team: 'SqdGp68'
# Email: 'I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging
import os

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# TAF & UTE Libraries:
from taf.config.scf import scf

# ET or Feature Specific Libraries:
import numpy as np
import pandas as pd

from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.resources.SQD68.pmc_analysis import (verify_pm_counters,
                                                           prepare_for_pm_counter_testing,
                                                           finalise_pm_counter_testing)
from testsuite.Ulm.ET.CB008246.libraries.ttitrace_analysis import (get_expected_pdsch_hrla,
                                                                   get_expected_new_pmc_values,
                                                                   plot_df_with_scatter)
from testsuite.Ulm.ET.L2.libraries.syslogs_analysis import check_no_fatality_error_in_syslogs


# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()
pmResultFile = None


# ====================================================================================================[120 characters]
#   Keywords
# ====================================================================================================[120 characters]

@log_begin_end_func_name
def verify_qc_test_case(tc_name):
    # ------------------------------------------------------------------------------------------------[120 characters]
    # Generic keyword which makes the common preparation and calls the Test Case specific Validation
    # ------------------------------------------------------------------------------------------------[120 characters]
    rbi.log_to_console(BOLD + "\n Verify QC Test Case(s) of CB008246: " + RESET + "~" * 102 + "")
    # rbi.log_to_console(("  "+tc_name[:80]+"   ").ljust(133), no_newline=True)
    tc_verdict = False
    ts_log_dir = rbi.get_variable_value("${ts_log_dir}")
    path_to_syslog_tgz = rbi.get_variable_value("${path_to_syslog_tgz}")
    pmc_csv_file = rbi.get_variable_value("${pm_counters_dir}") + "/pmCounters.csv"
    pmc_index = rbi.get_variable_value("${pmc_index}")
    nrbts_str = rbi.get_variable_value("${nrbts_str}")[0]
    global sw_build
    sw_build = rbi.get_variable_value("${sw_build}")
    logging.info("sw_build = %s" % sw_build)
    nrcell_id = rbi.get_variable_value("${NRCELL_ID}")
    logging.info("nrcell_id = %s" % nrcell_id)
    cell = 1 + int(nrcell_id)
    column = -(pmc_index+3)
    logging.info("tc_name = %s" % tc_name)
    logging.info("ts_log_dir = %s" % ts_log_dir)
    logging.info("pmc_csv_file = %s" % pmc_csv_file)
    logging.info("cell = %s" % cell)
    logging.info("column = %s" % column)
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    dllaBlerTargetHR_1 = round(int(rbi.get_variable_value("${dllaBlerTargetHR_1}")) * 0.001, 7)
    dllaBlerTargetHR_2 = round(int(rbi.get_variable_value("${dllaBlerTargetHR_2}")) * 0.001, 7)
    logging.info("dllaBlerTargetHR_1 = %s" % dllaBlerTargetHR_1)
    logging.info("dllaBlerTargetHR_2 = %s" % dllaBlerTargetHR_2)
    # --- Plot some usefull Charts: ------------------------------------------------------------------[120 characters]
    plot_for_DL(path_to_ttitrace_pkl, tc_name)
    # --- Test Case Specific Part: -------------------------------------------------------------------[120 characters]
    check_points = [verify_SCF_Paramaters(cell)]  # <--- Common Checkpoint
    if "CB008246_G_TC01_HrDrbPdsch_SA_multiDRB_nonGBR_MultiUE" == tc_name:
        check_points.append(verify_legacy_pmc_pdsch_hrla(pmc_csv_file, column, cell, tc_name, path_to_ttitrace_pkl,
                                                         dllaBlerTargetHR_1, dllaBlerTargetHR_2))
        check_points.append(verify_maxmcs_based_on_ttitraces(path_to_ttitrace_pkl, dir='dl', max_mcs=20))
        # --------------------------------------------------------------------------------------------[120 characters]
    if "CB008246_G_TC02_HrDrbPdsch_SA_multiDRB_nonGBR_FDD" == tc_name:
        check_points.append(verify_legacy_pmc_pdsch_hrla(pmc_csv_file, column, cell, tc_name, path_to_ttitrace_pkl,
                                                         dllaBlerTargetHR_1, dllaBlerTargetHR_2))
        check_points.append(verify_maxmcs_based_on_legacy_pmc(pmc_csv_file, column, cell, tc_name, max_mcs=25))
        # --------------------------------------------------------------------------------------------[120 characters]
    if "CB008246_G_TC03_HrDrbPdsch_SA_multiDRB_nonGBR_OnlineModify_multiUE" == tc_name:
        check_points.append(verify_legacy_pmc_pdsch_hrla(pmc_csv_file, column, cell, tc_name, path_to_ttitrace_pkl,
                                                         dllaBlerTargetHR_1, dllaBlerTargetHR_2))
        check_points.append(verify_maxmcs_based_on_legacy_pmc(pmc_csv_file, column, cell, tc_name, max_mcs=25))
        # --------------------------------------------------------------------------------------------[120 characters]
    if "CB008246_G_TC04_HrDrbPdsch_SA_multiDRB_nonGBR_Conditional_OLLA_Instance1" == tc_name:
        check_points.append(verify_legacy_pmc_pdsch_hrla(pmc_csv_file, column, cell, tc_name, path_to_ttitrace_pkl,
                                                         dllaBlerTargetHR_1, dllaBlerTargetHR_2))
        check_points.append(verify_new_pmc_pdsch_hrla(pmc_csv_file, column, cell, tc_name, path_to_ttitrace_pkl,
                                                      dllaBlerTargetHR_1, dllaBlerTargetHR_2))
        check_points.append(verify_maxmcs_based_on_ttitraces(path_to_ttitrace_pkl, dir='dl', max_mcs=25))
        tc_name = "[1]" + tc_name.replace("_Instance1", "")
        # --------------------------------------------------------------------------------------------[120 characters]
    if "CB008246_G_TC07_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_FDD" == tc_name:
        check_points.append(verify_new_pmc_pdsch_hrla(pmc_csv_file, column, cell, tc_name, path_to_ttitrace_pkl,
                                                      dllaBlerTargetHR_1, dllaBlerTargetHR_2))
        check_points.append(verify_maxmcs_based_on_ttitraces(path_to_ttitrace_pkl, dir='dl', max_mcs=25))
        check_points.append(verify_profile_existing_QAM64(cell, tc_name, path_to_ttitrace_pkl,
                                                          dllaBlerTargetHR_1, dllaBlerTargetHR_2))
        # --------------------------------------------------------------------------------------------[120 characters]
    if "CB008246_G_TC08_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_OnlineModify_NRCELL_multiUE" == tc_name:
        check_points.append(verify_maxmcs_based_on_new_pmc(pmc_csv_file, column, cell, tc_name, max_mcs=28))
        check_points.append(verify_maxmcs_based_on_new_pmc(pmc_csv_file, column-1, cell, tc_name, max_mcs=28))
        check_points.append(verify_maxmcs_based_on_new_pmc(pmc_csv_file, column-2, cell, tc_name, max_mcs=10))
        check_points.append(verify_maxmcs_based_on_new_pmc(pmc_csv_file, column-3, cell, tc_name, max_mcs=10))
        check_points.append(verify_maxmcs_based_on_new_pmc(pmc_csv_file, column-4, cell, tc_name, max_mcs=20))
        # --------------------------------------------------------------------------------------------[120 characters]
    if "CB008246_G_TC09_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_OnlineModify_NRBTS_multiUE" == tc_name:
        check_points.append(verify_new_pmc_pdsch_hrla(pmc_csv_file, column, cell, tc_name, path_to_ttitrace_pkl,
                                                      dllaBlerTargetHR_1, dllaBlerTargetHR_2))
        check_points.append(verify_profile_existing_QAM64(cell, tc_name, path_to_ttitrace_pkl,
                                                          dllaBlerTargetHR_1, dllaBlerTargetHR_1))  # Profile 1 Only
        check_points.append(verify_maxmcs_based_on_ttitraces(path_to_ttitrace_pkl, dir='dl', max_mcs=25))
        check_points.append(verify_HR_BR_switch_in_DL(path_to_ttitrace_pkl))
        # --------------------------------------------------------------------------------------------[120 characters]
    if "CB008246_G_TC10_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_IWK_NACKflood_DLFB_BRDRB_PMC" == tc_name:
        check_points.append(verify_new_pmc_pdsch_hrla(pmc_csv_file, column, cell, tc_name, path_to_ttitrace_pkl,
                                                      dllaBlerTargetHR_1, dllaBlerTargetHR_2))
        check_points.append(verify_profile_existing_QAM64(cell, tc_name, path_to_ttitrace_pkl,
                                                          dllaBlerTargetHR_1, dllaBlerTargetHR_2))
        check_points.append(verify_maxmcs_based_on_ttitraces(path_to_ttitrace_pkl, dir='dl', max_mcs=20))
        check_points.append(verify_nack_flood(path_to_ttitrace_pkl))
        # --------------------------------------------------------------------------------------------[120 characters]
    if "CB008246_G_TC11_HrDrbPdsch_SA_multiDRB_noLowSeUe_nonGBR_HRDRB_PMC" == tc_name:
        check_points.append(verify_new_pmc_pdsch_hrla(pmc_csv_file, column, cell, tc_name, path_to_ttitrace_pkl,
                                                      dllaBlerTargetHR_1, dllaBlerTargetHR_2))
        check_points.append(verify_profile_existing_QAM64(cell, tc_name, path_to_ttitrace_pkl,
                                                          dllaBlerTargetHR_1, dllaBlerTargetHR_2))
        check_points.append(verify_maxmcs_based_on_ttitraces(path_to_ttitrace_pkl, dir='dl', max_mcs=20))
        # --------------------------------------------------------------------------------------------[120 characters]
    if "CB008246_G_TC12_HrDrbPdsch_SA_multiDRB_GBR_FDD" == tc_name:
        check_points.append(verify_legacy_pmc_pdsch_hrla(pmc_csv_file, column, cell, tc_name, path_to_ttitrace_pkl,
                                                         dllaBlerTargetHR_1, dllaBlerTargetHR_2))
        check_points.append(verify_profile_existing_QAM64LOWSE(cell, tc_name, path_to_ttitrace_pkl,
                                                               dllaBlerTargetHR_1, dllaBlerTargetHR_2))
        check_points.append(verify_maxmcs_based_on_ttitraces(path_to_ttitrace_pkl, dir='dl', max_mcs=25))
        # --------------------------------------------------------------------------------------------[120 characters]
    if "CB008246_G_TC15_HrDrbPdsch_SA_multiDRB_GBR_noLowSeUe" == tc_name:
        check_points.append(verify_new_pmc_pdsch_hrla(pmc_csv_file, column, cell, tc_name, path_to_ttitrace_pkl,
                                                      dllaBlerTargetHR_1, dllaBlerTargetHR_2))
        check_points.append(verify_profile_existing_QAM64(cell, tc_name, path_to_ttitrace_pkl,
                                                          dllaBlerTargetHR_1, dllaBlerTargetHR_2))
        check_points.append(verify_maxmcs_based_on_ttitraces(path_to_ttitrace_pkl, dir='dl', max_mcs=20))
        # --------------------------------------------------------------------------------------------[120 characters]
    check_points.append(check_no_fatality_error_in_syslogs(path_to_syslog_tgz))  # <--- Common Checkpoint
    # ------------------------------------------------------------------------------------------------[120 characters]
    logging.info("check_points = %s" % check_points)
    tc_verdict = all(check_points)
    logging.info("verify_qc_test_case: tc_verdict = %s" % tc_verdict)
    rbi.set_test_variable("${TEST NAME}", tc_name)  # IMPORTANT: allows "Robot-TC-Name != QC-TC-Name" case
    rbi.should_be_true(tc_verdict)  # IMPORTANT: keep this line the LAST one


# ====================================================================================================[120 characters]
#   Validation Functions
# ====================================================================================================[120 characters]

@log_begin_end_func_name
def verify_SCF_Paramaters(cell):
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${path_to_scf_xml}")
    distname_nrbts = rbi.get_variable_value("${nrbts_str}")[0]
    distname_nrcell = distname_nrbts + "/NRCELL-%s" % cell
    try:
        expected_scf_list = [{'p_name': 'actMultiDrbNSA', 'value': 'true', 'dist_name': distname_nrbts},
                             {'p_name': 'actLAForHiReliab', 'value': 'true', 'dist_name': distname_nrcell}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("verify_SCF_Paramaters", e)
    logging.info("is_SCF_correct = %s" % is_SCF_correct)
    return is_SCF_correct


@log_begin_end_func_name
def verify_legacy_pmc_pdsch_hrla(pmc_csv_file, column, cell, tc_name, path_to_ttitrace_pkl,
                                 dllaBlerTargetHR_1, dllaBlerTargetHR_2):
    global sw_build
    are_pmcs_correct = False
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        pmcs_under_test = get_expected_pdsch_hrla(path_to_ttitrace_pkl, cell, dllaBlerTargetHR_1,
                                                  dllaBlerTargetHR_2, sw_build)
        piids_and_expected_values = {"M55366C00001": pmcs_under_test["pdsch_HRLA_PRF1_Init"],
                                     "M55366C00002": pmcs_under_test["pdsch_HRLA_PRF1_Succ"],
                                     "M55366C00003": pmcs_under_test["pdsch_HRLA_PRF2_Init"],
                                     "M55366C00004": pmcs_under_test["pdsch_HRLA_PRF2_Succ"],
                                     "M55366C00005": pmcs_under_test["pdsch_HRLA_PRF1_Succ"],
                                     "M55366C00007": pmcs_under_test["pdsch_HRLA_PRF2_Succ"]}
        are_pmcs_correct = verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, tc_name,
                                              threshold_percent=1)
        # --------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_legacy_pmc_pdsch_hrla", e)
    logging.info("are_pmcs_correct = %s" % are_pmcs_correct)
    return are_pmcs_correct


@log_begin_end_func_name
def verify_new_pmc_pdsch_hrla(pmc_csv_file, column, cell, tc_name, path_to_ttitrace_pkl,
                              dllaBlerTargetHR_1, dllaBlerTargetHR_2):
    global sw_build
    are_pmcs_correct = False
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        pmcs_under_test = get_expected_new_pmc_values(path_to_ttitrace_pkl,
                                                      dir="dl",
                                                      subfeature="G",  # <--- DL over QAM64
                                                      cell=cell,
                                                      max_dl_harq_tx=5,  # <--- maxDlHarqTx from scf.xml
                                                      max_ul_harq_tx=5,  # <--- maxUlHarqTx from scf.xml
                                                      targetBlerPrf1=dllaBlerTargetHR_1,
                                                      targetBlerPrf2=dllaBlerTargetHR_2,
                                                      sw_build=sw_build)
        # [IMPORTANT] M55366C00001..M55366C00012 are just key names for TTITraces and NOT real PM Counters
        # [IMPORTANT] M55300C00029..M55300C00040 are real PM Counters
        piids_and_expected_values = {"M55300C00029": int(pmcs_under_test["M55366C00001"]),
                                     "M55300C00030": int(pmcs_under_test["M55366C00002"]),
                                     "M55300C00031": int(pmcs_under_test["M55366C00003"]),
                                     "M55300C00032": int(pmcs_under_test["M55366C00004"]),
                                     "M55300C00033": int(pmcs_under_test["M55366C00009"]),
                                     "M55300C00034": int(pmcs_under_test["M55366C00010"]),
                                     "M55300C00035": int(pmcs_under_test["M55366C00011"]),
                                     "M55300C00036": int(pmcs_under_test["M55366C00012"]),
                                     "M55300C00037": int(pmcs_under_test["M55366C00005"]),
                                     "M55300C00038": int(pmcs_under_test["M55366C00006"]),
                                     "M55300C00039": int(pmcs_under_test["M55366C00007"]),
                                     "M55300C00040": int(pmcs_under_test["M55366C00008"])}
        are_pmcs_correct = verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, tc_name,
                                              threshold_percent=3)
        # --------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_new_pmc_pdsch_hrla", e)
    logging.info("are_pmcs_correct = %s" % are_pmcs_correct)
    return are_pmcs_correct


@log_begin_end_func_name
def verify_maxmcs_based_on_legacy_pmc(pmc_csv_file, column, cell, tc_name, max_mcs):
    are_pmcs_correct = False
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        piids_and_expected_values = {}
        for mcs in range(max_mcs+1, 29):
            piids_and_expected_values["M55366C010%s" % mcs] = 0
        logging.info("piids_and_expected_values = %s" % piids_and_expected_values)
        are_pmcs_correct = verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, tc_name,
                                              threshold_percent=0)
    except Exception as e:
        logException("verify_maxmcs_based_on_legacy_pmc", e)
    logging.info("are_pmcs_correct = %s" % are_pmcs_correct)
    return are_pmcs_correct


@log_begin_end_func_name
def verify_maxmcs_based_on_new_pmc(pmc_csv_file, column, cell, tc_name, max_mcs):
    are_pmcs_correct = False
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        piids_and_expected_values = {}
        for mcs in range(max_mcs+1, 29):
            piids_and_expected_values["M55300C000%s" % mcs] = 0
        logging.info("piids_and_expected_values = %s" % piids_and_expected_values)
        are_pmcs_correct = verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, tc_name,
                                              threshold_percent=0)
    except Exception as e:
        logException("verify_maxmcs_based_on_new_pmc", e)
    logging.info("are_pmcs_correct = %s" % are_pmcs_correct)
    return are_pmcs_correct


@log_begin_end_func_name
def verify_maxmcs_based_on_ttitraces(path_to_ttitrace_pkl, dir, max_mcs):
    is_maxmc_correct = False
    list_of_verdicts = []
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir=dir)
        timestamp = 'timeStamp'
        rnti = 'rnti'
        laMode = '{}FdSchedData.laMode'.format(dir)
        usedMcs = '{}FdSchedData.rrm{}UsedMcs'.format(dir, dir.capitalize())
        proposedMcs = '{}FdSchedData.rrm{}ProposedMcs'.format(dir, dir.capitalize())
        dciFormat = '{}FdSchedData.dciFormat'.format(dir)
        mcsTable = '{}FdSchedData.mcsTable'.format(dir)
        isValidWhatIsProposed = '{}FdSchedData.isValidWhatIsProposed'.format(dir)
        df_optimized = df[[timestamp, rnti, laMode, usedMcs, proposedMcs, dciFormat, mcsTable, isValidWhatIsProposed]]
        df_filtered = df_optimized[df_optimized[laMode].notna() & (df_optimized[laMode] != '')]
        df_filtered = df_filtered.loc[~df_filtered[dciFormat].str.contains('MSG|INVALID|FORCE', na=False)]
        df_filtered = df_filtered.loc[df_filtered[isValidWhatIsProposed] == 1]
        logging.info("df_filtered = %s" % df_filtered)
        for rnti, df_per_rnti in df_filtered.groupby('rnti'):  # Multi UE: UEs are treated independently
            logging.info("======= RNTI under TEST: %s =======" % rnti)
            df_per_rnti['Change'] = (df_per_rnti[laMode] != df_per_rnti[laMode].shift()).cumsum()
            logging.info("df_per_rnti = %s" % df_per_rnti)
            # --- Check and split Fallbacks if ANY ---------------------------------------------------[120 characters]
            df_1st_part = df_per_rnti[df_per_rnti['Change'] <= 2].drop(columns='Change').reset_index(drop=True)
            df_2nd_part = df_per_rnti[df_per_rnti['Change'] > 2].drop(columns='Change').reset_index(drop=True)
            logging.info("df_1st_part = %s" % (df_1st_part))
            logging.info("df_2nd_part = %s" % (df_2nd_part))
            # ----------------------------------------------------------------------------------------[120 characters]
            if not df_1st_part.empty:  # the 1st BR->HR
                df_1st_part_filtered = df_1st_part.loc[df_1st_part[laMode] == 'HIGHRELIABILITY']
                logging.info("df_1st_part_filtered = %s" % (df_1st_part_filtered))
                df_1st_part_filtered = df_1st_part_filtered.iloc[3:]
                logging.info("df_1st_part_filtered = %s" % (df_1st_part_filtered))
                df_1st_part_with_highermcs = df_1st_part_filtered.loc[df_1st_part_filtered[usedMcs] > max_mcs]
                logging.info("df_1st_part_with_highermcs = %s" % df_1st_part_with_highermcs)
                list_of_verdicts.append(df_1st_part_with_highermcs.empty)
            # ----------------------------------------------------------------------------------------[120 characters]
            if not df_2nd_part.empty:  # the 2nd BR->HR, after HR->BR if the Fallback happend caused by any reason
                df_2nd_part_filtered = df_2nd_part.loc[df_2nd_part[laMode] == 'HIGHRELIABILITY']
                logging.info("df_2nd_part_filtered = %s" % (df_2nd_part_filtered))
                df_2nd_part_filtered = df_2nd_part_filtered.iloc[3:]
                logging.info("df_2nd_part_filtered = %s" % (df_2nd_part_filtered))
                df_2nd_part_with_highermcs = df_2nd_part_filtered.loc[df_2nd_part_filtered[usedMcs] > max_mcs]
                logging.info("df_2nd_part_with_highermcs = %s" % df_2nd_part_with_highermcs)
                list_of_verdicts.append(df_2nd_part_with_highermcs.empty)
        # --------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_maxmcs_based_on_ttitraces", e)
    is_maxmc_correct = all(list_of_verdicts) if list_of_verdicts else is_maxmc_correct
    logging.info("list_of_verdicts = %s" % list_of_verdicts)
    logging.info("is_maxmc_correct = %s" % is_maxmc_correct)
    return is_maxmc_correct


@log_begin_end_func_name
def verify_profile_switch_QAM64LOWSE(cell, tc_name, path_to_ttitrace_pkl, dllaBlerTargetHR_1, dllaBlerTargetHR_2,
                                     ratio):
    global sw_build
    do_profiles_switch_correctly = False
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        pmcs_under_test = get_expected_new_pmc_values(path_to_ttitrace_pkl,
                                                      dir="dl",
                                                      subfeature="D",  # <--- DL over QAM64LOWSE
                                                      cell=cell,
                                                      max_dl_harq_tx=5,  # <--- maxDlHarqTx from scf.xml
                                                      max_ul_harq_tx=5,  # <--- maxUlHarqTx from scf.xml
                                                      targetBlerPrf1=dllaBlerTargetHR_1,
                                                      targetBlerPrf2=dllaBlerTargetHR_2,
                                                      sw_build=sw_build)
        # [IMPORTANT] M55366C00001 and M55366C00003 are just key names for TTITraces and NOT real PM Counters
        deviation = abs(int(pmcs_under_test["M55366C00001"])/int(pmcs_under_test["M55366C00003"]) - ratio)
        logging.info("deviation = %s" % deviation)
        allowed_deviation = (10 / 100) * ratio
        logging.info("allowed_deviation = %s" % allowed_deviation)
        do_profiles_switch_correctly = deviation < allowed_deviation
    except Exception as e:
        logException("verify_profile_switch_QAM64LOWSE", e)
    logging.info("do_profiles_switch_correctly = %s" % do_profiles_switch_correctly)
    return do_profiles_switch_correctly


@log_begin_end_func_name
def verify_profile_existing_QAM64LOWSE(cell, tc_name, path_to_ttitrace_pkl, dllaBlerTargetHR_1, dllaBlerTargetHR_2):
    global sw_build
    are_both_profiles_existing = False
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        pmcs_under_test = get_expected_new_pmc_values(path_to_ttitrace_pkl,
                                                      dir="dl",
                                                      subfeature="D",  # <--- DL over QAM64LOWSE
                                                      cell=cell,
                                                      max_dl_harq_tx=5,  # <--- maxDlHarqTx from scf.xml
                                                      max_ul_harq_tx=5,  # <--- maxUlHarqTx from scf.xml
                                                      targetBlerPrf1=dllaBlerTargetHR_1,
                                                      targetBlerPrf2=dllaBlerTargetHR_2,
                                                      sw_build=sw_build)
        # [IMPORTANT] M55366C00001 and M55366C00003 are just key names for TTITraces and NOT real PM Counters
        profile1 = int(pmcs_under_test["M55366C00001"])
        profile2 = int(pmcs_under_test["M55366C00003"])
        logging.info("Number of TXs on profile1 = %s" % profile1)
        logging.info("Number of TXs on profile2 = %s" % profile2)
        are_both_profiles_existing = (profile1 > 0) and (profile2 > 0)
    except Exception as e:
        logException("verify_profile_existing_QAM64LOWSE", e)
    logging.info("are_both_profiles_existing = %s" % are_both_profiles_existing)
    return are_both_profiles_existing


@log_begin_end_func_name
def verify_profile_switch_QAM64(cell, tc_name, path_to_ttitrace_pkl, dllaBlerTargetHR_1, dllaBlerTargetHR_2, ratio):
    global sw_build
    do_profiles_switch_correctly = False
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        pmcs_under_test = get_expected_new_pmc_values(path_to_ttitrace_pkl,
                                                      dir="dl",
                                                      subfeature="G",  # <--- DL over QAM64
                                                      cell=cell,
                                                      max_dl_harq_tx=5,  # <--- maxDlHarqTx from scf.xml
                                                      max_ul_harq_tx=5,  # <--- maxUlHarqTx from scf.xml
                                                      targetBlerPrf1=dllaBlerTargetHR_1,
                                                      targetBlerPrf2=dllaBlerTargetHR_2,
                                                      sw_build=sw_build)
        # [IMPORTANT] M55366C00001 and M55366C00003 are just key names for TTITraces and NOT real PM Counters
        deviation = abs(int(pmcs_under_test["M55366C00001"])/int(pmcs_under_test["M55366C00003"]) - ratio)
        logging.info("deviation = %s" % deviation)
        allowed_deviation = (10 / 100) * ratio
        logging.info("allowed_deviation = %s" % allowed_deviation)
        do_profiles_switch_correctly = deviation < allowed_deviation
    except Exception as e:
        logException("verify_profile_switch_QAM64", e)
    logging.info("do_profiles_switch_correctly = %s" % do_profiles_switch_correctly)
    return do_profiles_switch_correctly


@log_begin_end_func_name
def verify_profile_existing_QAM64(cell, tc_name, path_to_ttitrace_pkl, dllaBlerTargetHR_1, dllaBlerTargetHR_2):
    global sw_build
    are_profiles_existing = False
    skip_second_profile = (dllaBlerTargetHR_1 == dllaBlerTargetHR_2)
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        pmcs_under_test = get_expected_new_pmc_values(path_to_ttitrace_pkl,
                                                      dir="dl",
                                                      subfeature="G",  # <--- DL over QAM64
                                                      cell=cell,
                                                      max_dl_harq_tx=5,  # <--- maxDlHarqTx from scf.xml
                                                      max_ul_harq_tx=5,  # <--- maxUlHarqTx from scf.xml
                                                      targetBlerPrf1=dllaBlerTargetHR_1,
                                                      targetBlerPrf2=dllaBlerTargetHR_2,
                                                      sw_build=sw_build)
        # [IMPORTANT] M55366C00001 and M55366C00003 are just key names for TTITraces and NOT real PM Counters
        profile1 = int(pmcs_under_test["M55366C00001"])
        profile2 = int(pmcs_under_test["M55366C00003"]) if not skip_second_profile else 0
        logging.info("Number of TXs on profile1 = %s" % profile1)
        logging.info("Number of TXs on profile2 = %s" % profile2)
        are_profiles_existing = (profile1 > 0) and (profile2 > 0) if not skip_second_profile else (profile1 > 0)
    except Exception as e:
        logException("verify_profile_existing_QAM64", e)
    logging.info("are_profiles_existing = %s" % are_profiles_existing)
    return are_profiles_existing


@log_begin_end_func_name
def verify_nack_flood(path_to_ttitrace_pkl):
    does_nackflood_cause_fallback = False
    is_there_nackflood_on_hr = False
    is_there_recovery = False
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='dl')
        column_name_1 = 'timeStamp'
        column_name_2 = 'dlLaSwitchBetweenHrAndBr.event'
        column_name_3 = 'dlLaSwitchBetweenHrAndBr.laMode'
        df_filtered = df.loc[df[column_name_2].notna()]
        df_optimized = df_filtered[[column_name_1, column_name_2, column_name_3]]
        logging.info("df_optimized = \n%s" % df_optimized)
        dllaswitch_list = df_optimized.to_csv(index=False, header=False).splitlines()
        logging.info("dllaswitch_list = \n%s" % '\n'.join(dllaswitch_list))
        # --------------------------------------------------------------------------------------------[120 characters]
        is_there_nackflood_on_hr = any('dlNackFlood,HighReliability' in elem for elem in dllaswitch_list)
        does_nackflood_cause_fallback = any('dlNackFlood,BasicReliability' in elem for elem in dllaswitch_list)
        is_there_recovery = any('dlHRBlerRecoverPeriodTimer,HighReliability' in elem for elem in dllaswitch_list)
    except Exception as e:
        logException("verify_nack_flood", e)
    logging.info("is_there_nackflood_on_hr = %s" % is_there_nackflood_on_hr)
    logging.info("does_nackflood_cause_fallback = %s" % does_nackflood_cause_fallback)
    logging.info("is_there_recovery = %s" % is_there_recovery)
    return is_there_nackflood_on_hr and does_nackflood_cause_fallback and is_there_recovery


@log_begin_end_func_name
def verify_HR_BR_switch_in_UL(path_to_ttitrace_pkl):
    does_HR_BR_switch = False
    is_ULHRBLEROUTAGE_on_hr = False
    is_there_recovery = False
    nbr_HR_BR_outage = False
    # ------------------------------------------------------------------------------------------------[120 characters]
    path_to_ttitrace_pkl = os.path.dirname(path_to_ttitrace_pkl) + "/ttitrace_streaming_ulharq.pkl"
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='ul')
        timestamp = 'timeStamp'
        event = 'ulLaSwitchBetweenHrAndBr.event'
        laMode = 'ulLaSwitchBetweenHrAndBr.laMode'
        puschMetricRatio = 'ulLaSwitchBetweenHrAndBr.puschMetric.ratio'
        df_filtered = df.loc[df[event].notna()]
        df_optimized = df_filtered[[event, laMode]]
        logging.info("df_optimized = \n%s" % df_optimized)
        ullaswitch_list = df_optimized.to_csv(index=False, header=False).splitlines()
        logging.info("ullaswitch_list = \n%s" % '\n'.join(ullaswitch_list))
        # --------------------------------------------------------------------------------------------[120 characters]
        is_ULHRBLEROUTAGE_on_hr = any('ulHRBlerOutagePeriodTimer,HighReliability' in elem for elem in ullaswitch_list)
        does_HR_BR_switch = any('ulHRBlerOutagePeriodTimer,BasicReliability' in elem for elem in ullaswitch_list)
        is_there_recovery = any('ulHRBlerRecoverPeriodTimer,HighReliability' in elem for elem in ullaswitch_list)
        nbr_HR_BR_outage = ullaswitch_list.count('ulHRBlerOutagePeriodTimer,BasicReliability')
        nbr_HR_BR_recover = ullaswitch_list.count('ulHRBlerRecoverPeriodTimer,HighReliability')
        nbr_HR_BR_switch = (nbr_HR_BR_outage == 1 and nbr_HR_BR_recover == 1)
    except Exception as e:
        logException("verify_HR_BR_switch", e)
    logging.info("is_ULHRBLEROUTAGE_on_hr = %s" % is_ULHRBLEROUTAGE_on_hr)
    logging.info("does_HR_BR_switch = %s" % does_HR_BR_switch)
    logging.info("is_there_recovery = %s" % is_there_recovery)
    logging.info("nbr_HR_BR_outage = %s" % nbr_HR_BR_outage)
    logging.info("nbr_HR_BR_recover = %s" % nbr_HR_BR_recover)
    return is_ULHRBLEROUTAGE_on_hr and does_HR_BR_switch and is_there_recovery and nbr_HR_BR_switch


@log_begin_end_func_name
def verify_HR_BR_switch_in_DL(path_to_ttitrace_pkl):
    does_HR_BR_switch = False
    is_DLHRBLEROUTAGE_on_hr = False
    is_there_recovery = False
    # ------------------------------------------------------------------------------------------------[120 characters]
    path_to_ttitrace_pkl = os.path.dirname(path_to_ttitrace_pkl) + "/ttitrace_streaming_dlharq.pkl"
    # ------------------------------------------------------------------------------------------------[120 characters]
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
        # --------------------------------------------------------------------------------------------[120 characters]
        is_DLHRBLEROUTAGE_on_hr = any('dlHRBlerOutagePeriodTimer,HighReliability' in elem for elem in dllaswitch_list)
        does_HR_BR_switch = any('dlHRBlerOutagePeriodTimer,BasicReliability' in elem for elem in dllaswitch_list)
        is_there_recovery = any('dlHRBlerRecoverPeriodTimer,HighReliability' in elem for elem in dllaswitch_list)
    except Exception as e:
        logException("verify_HR_BR_switch", e)
    logging.info("is_DLHRBLEROUTAGE_on_hr = %s" % is_DLHRBLEROUTAGE_on_hr)
    logging.info("does_HR_BR_switch = %s" % does_HR_BR_switch)
    logging.info("is_there_recovery = %s" % is_there_recovery)
    return is_DLHRBLEROUTAGE_on_hr and does_HR_BR_switch


@log_begin_end_func_name
def plot_for_DL(path_to_ttitrace_pkl, tc_name):
    global sw_build
    targetBLER = 'dlFdSchedAdditionalData.targetBLER'
    try:
        path_to_ttitrace_pkl = os.path.dirname(path_to_ttitrace_pkl) + "/ttitrace_streaming_dlharq.pkl"
        # --------------------------------------------------------------------------------------------[120 characters]
        df = get_df_from_pkl(path_to_ttitrace_pkl, dir='dl')
        plot_df_with_scatter(df=df,
                             yaxis_column='dlFdSchedData.laMode',
                             base_location=os.path.dirname(path_to_ttitrace_pkl),
                             postfix="",
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


# ====================================================================================================[120 characters]
#   Private Functions
# ====================================================================================================[120 characters]

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
    usedMcs = '{}FdSchedData.rrm{}UsedMcs'.format(dir, dir.capitalize())
    proposedMcs = '{}FdSchedData.rrm{}ProposedMcs'.format(dir, dir.capitalize())
    dlLaSwitchEvent = 'dlLaSwitchBetweenHrAndBr.event'
    dlLaSwitchLaMode = 'dlLaSwitchBetweenHrAndBr.laMode'
    dlLaSwitchRatio = 'dlLaSwitchBetweenHrAndBr.pdschMetric.ratio'
    ulLaSwitchEvent = 'ulLaSwitchBetweenHrAndBr.event'
    ulLaSwitchLaMode = 'ulLaSwitchBetweenHrAndBr.laMode'
    ulLaSwitchRatio = 'ulLaSwitchBetweenHrAndBr.puschMetric.ratio'
    dciFormat = '{}FdSchedData.dciFormat'.format(dir)
    isValidWhatIsProposed = '{}FdSchedData.isValidWhatIsProposed'.format(dir)
    # ------------------------------------------------------------------------------------------------[120 characters]
    df = pd.read_pickle(path_to_pickle)
    if dir == 'dl':
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', ackNack, txNumber, mcsTable, targetBLER,
                 laMode, usedMcs, dlLaSwitchEvent, dlLaSwitchLaMode, dlLaSwitchRatio, proposedMcs, dciFormat,
                 isValidWhatIsProposed]]
    else:
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', crcResult, txNumber, mcsTable, targetBLER,
                 laMode, usedMcs, ulLaSwitchEvent, ulLaSwitchLaMode, ulLaSwitchRatio, proposedMcs, dciFormat,
                 isValidWhatIsProposed]]
    # Normalize string columns to uppercase (TTI trace data may use camelCase)
    str_cols = [mcsTable, laMode]
    if dir == 'dl':
        str_cols += [ackNack]
    else:
        str_cols += [crcResult]
    for col in str_cols:
        series = df[col].astype(str).str.upper()
        df[col] = series.where(series != 'NAN', other=np.nan)
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
