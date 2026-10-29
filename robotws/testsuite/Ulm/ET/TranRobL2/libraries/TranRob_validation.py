# =====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd68 for CB007449 Feature
# Team: 'SqdGp68'
# Email: 'I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com'
# -----------------------------------------------------------------------------------------------------[120 characters]

import logging
import csv
import json

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# TAF & UTE Libraries:
from taf.config.scf import scf

# ET or Feature Specific Libraries:
import numpy as np
import pandas as pd

from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.resources.SQD68.pmc_analysis import (prepare_for_pm_counter_testing,
                                                           finalise_pm_counter_testing,
                                                           print_pm_counter_testcase_header,
                                                           print_pm_counter_testcase_footer,
                                                           print_pm_counter_testcase_info_to_console,
                                                           add_tc_result_to_report_json_dict,
                                                           search_for_failed_in_pmcut_dict,
                                                           verify_within_threshold)
from testsuite.Ulm.ET.resources.tti_analysis.helper_functions import display_df_as_html
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


@log_begin_end_func_name
def verify_qc_test_case(tc_name):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # It could be used for "offline" verification, but 'logs' keyword must be called prior,
    # see 'logs' keyword description for the details.
    # -------------------------------------------------------------------------------------------------[120 characters]
    rbi.log_to_console(BOLD + "\n Verify QC Test Case(s) of CB007449: " + RESET + "~" * 102 + "")
    tc_verdict = False
    rbi.set_suite_variable("${SW_POSTFIX}", "TranRob")
    ts_log_dir = rbi.get_variable_value("${ts_log_dir}")
    path_to_scf_xml = rbi.get_variable_value("${path_to_scf_xml}")
    path_to_syslog_tgz = rbi.get_variable_value("${path_to_syslog_tgz}")
    pmc_csv_file = rbi.get_variable_value("${pm_counters_dir}") + "/pmCounters.csv"
    pmc_index = rbi.get_variable_value("${pmc_index}")
    cell = 1
    column = -(pmc_index+3)
    logging.info("tc_name = %s" % tc_name)
    logging.info("ts_log_dir = %s" % ts_log_dir)
    logging.info("pmc_csv_file = %s" % pmc_csv_file)
    logging.info("cell = %s" % cell)
    logging.info("column = %s" % column)
    # --- Test Case Specific Part: --------------------------------------------------------------------[120 characters]
    if tc_name == "L3Call_MUE_on_SingleCell":
        tc_verdict = verify_SA_Tput(path_to_scf_xml=path_to_scf_xml,
                                    pmc_csv_file=pmc_csv_file,
                                    column=column,
                                    cell=cell,
                                    dl_mbps=1100,
                                    ul_mbps=200,
                                    tc_name=tc_name)
    if tc_name == "L3Call_MUE_CA_TDD_TDD":
        tc_verdict = verify_SA_Tput(path_to_scf_xml=path_to_scf_xml,
                                    pmc_csv_file=pmc_csv_file,
                                    column=column,
                                    cell=cell,
                                    dl_mbps=1200,
                                    ul_mbps=180,
                                    tc_name=tc_name)
    if tc_name == "L3Call_MUE_CA_FDD_FDD":
        tc_verdict = verify_SA_Tput(path_to_scf_xml=path_to_scf_xml,
                                    pmc_csv_file=pmc_csv_file,
                                    column=column,
                                    cell=cell,
                                    dl_mbps=370,
                                    ul_mbps=100,
                                    tc_name=tc_name)
        tc_verdict = verify_SA_Tput_in_CA(path_to_scf_xml=path_to_scf_xml,
                                          pmc_csv_file=pmc_csv_file,
                                          column=column,
                                          cell=cell,
                                          dl_mbps=370,
                                          ul_mbps=100,
                                          tc_name=tc_name) and tc_verdict
    # -------------------------------------------------------------------------------------------------[120 characters]
    tc_verdict = check_no_fatality_error_in_syslogs(path_to_syslog_tgz) and tc_verdict  # <--- Common Checkpoint
    # -------------------------------------------------------------------------------------------------[120 characters]
    rbi.set_test_variable("${TEST NAME}", tc_name)  # IMPORTANT: allows "Robot-TC-Name != QC-TC-Name" case
    rbi.should_be_true(tc_verdict)  # IMPORTANT: keep this line the LAST one


@log_begin_end_func_name
def verify_SA_Tput(path_to_scf_xml, pmc_csv_file, column, cell, dl_mbps, ul_mbps, tc_name):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Verification of "Capacity" Test Case with Multi-UE UL/DL traffic for a long durtation
    #   the scenario is passed if all Check Points (cp) have passed
    # Output Argument(s): a BOOLEAN verdict
    # -------------------------------------------------------------------------------------------------[120 characters]
    cp1_is_duration_correct = False
    cp2_is_kpi_5094_correct = False  # 5G SA PDCP SDU throughput in Downlink
    cp3_is_kpi_5095_correct = False  # 5G SA PDCP SDU throughput in Uplink
    try:
        visualization()
        df = pd.read_csv(pmc_csv_file, sep=';', low_memory=False)
        # --- Check Point #1: -------------------------------------------------------------------------[120 characters]
        df_values = df[df['PI_ID'].str.startswith('M55319C00001')].iloc[:, 5:-3].astype('int64')
        meas_period_nr_pdcp_report1 = df_values.sum() * 1000
        logging.info("len(meas_period_nr_pdcp_report1) = %s" % len(meas_period_nr_pdcp_report1))
        cp1_is_duration_correct = len(meas_period_nr_pdcp_report1) >= 60  # <-- 60 * 5min = 5hours
        # --- Check Point #2: -------------------------------------------------------------------------[120 characters]
        if len(meas_period_nr_pdcp_report1) > 8:
            dl_vol_tx_sa = df[df['PI_ID'].str.startswith('M55319C120')].iloc[:, 5:-3].astype('int64').sum() * 8
            logging.info("len(dl_vol_tx_sa) = %s" % len(dl_vol_tx_sa))
            kpi_5094 = dl_vol_tx_sa / meas_period_nr_pdcp_report1
            logging.info("NR_5094.mean() = %s = %s" % (kpi_5094.mean(), int(kpi_5094.mean())))
            logging.info("NR_5094.median() = %s = %s" % (kpi_5094.median(), int(kpi_5094.median())))
            cp2_is_kpi_5094_correct = int(kpi_5094.median()) >= dl_mbps
        # --- Check Point #3: -------------------------------------------------------------------------[120 characters]
        if len(meas_period_nr_pdcp_report1) > 8:
            ul_vol_tx_sa = df[df['PI_ID'].str.startswith('M55319C160')].iloc[:, 5:-3].astype('int64').sum() * 8
            logging.info("len(ul_vol_tx_sa) = %s" % len(ul_vol_tx_sa))
            kpi_5095 = ul_vol_tx_sa / meas_period_nr_pdcp_report1
            logging.info("NR_5095.mean() = %s = %s" % (kpi_5095.mean(), int(kpi_5095.mean())))
            logging.info("NR_5095.median() = %s = %s" % (kpi_5095.median(), int(kpi_5095.median())))
            cp3_is_kpi_5095_correct = int(kpi_5095.median()) >= ul_mbps
    # -------------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_SA_Tput", e)
    logging.info("cp1_is_duration_correct = %s" % cp1_is_duration_correct)
    logging.info("cp2_is_kpi_5094_correct = %s" % cp2_is_kpi_5094_correct)
    logging.info("cp3_is_kpi_5095_correct = %s" % cp3_is_kpi_5095_correct)
    return (cp1_is_duration_correct and
            cp2_is_kpi_5094_correct and
            cp3_is_kpi_5095_correct)


@log_begin_end_func_name
def verify_SA_Tput_in_CA(path_to_scf_xml, pmc_csv_file, column, cell, dl_mbps, ul_mbps, tc_name):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Verification of "Capacity" Test Case with Multi-UE UL/DL traffic for a long durtation
    #   the scenario is passed if all Check Points (cp) have passed
    # Output Argument(s): a BOOLEAN verdict
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_kpi_5883_correct = False  # 5G SA and NSA Downlink Intra/Inter-gNB CA RLC data volume from PCell
    is_kpi_5884_correct = False  # 5G SA and NSA Downlink Intra/Inter-gNB CA RLC data volume from SCell
    try:
        visualization()
        df = pd.read_csv(pmc_csv_file, sep=';', low_memory=False)
        meas_period_nr_pdcp_report1 = df[df['PI_ID'].str.startswith('M55319C00001')].sum()[5:-3]*1000
        logging.info("len(meas_period_nr_pdcp_report1) = %s" % len(meas_period_nr_pdcp_report1))
        # --- Check Point #1: PCell -------------------------------------------------------------------[120 characters]
        if len(meas_period_nr_pdcp_report1) > 8:
            dl_vol_pcell = df[df['PI_ID'].str.startswith('M55310C20000')].iloc[:, 5:-3].astype('int64').sum()[5:-3]
            logging.info("len(dl_vol_pcell) = %s" % len(dl_vol_pcell))
            logging.info("dl_vol_pcell = %s" % dl_vol_pcell)
            kpi_5883 = dl_vol_pcell.sum() / 1000000
            logging.info("kpi_5883 = %s" % kpi_5883)
            is_kpi_5883_correct = int(kpi_5883) > 0
        # --- Check Point #2: SCell -------------------------------------------------------------------[120 characters]
        if len(meas_period_nr_pdcp_report1) > 8:
            dl_vol_scell = df[df['PI_ID'].str.startswith('M55310C20001')].iloc[:, 5:-3].astype('int64').sum()[5:-3]
            logging.info("len(dl_vol_scell) = %s" % len(dl_vol_scell))
            logging.info("dl_vol_scell = %s" % dl_vol_scell)
            kpi_5884 = dl_vol_scell.sum() / 1000000
            logging.info("kpi_5884 = %s" % kpi_5884)
            is_kpi_5884_correct = int(kpi_5884) > 0
    # -------------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_SA_Tput_in_CA", e)
    logging.info("is_kpi_5883_correct = %s" % is_kpi_5883_correct)
    logging.info("is_kpi_5884_correct = %s" % is_kpi_5884_correct)
    return (is_kpi_5883_correct and
            is_kpi_5884_correct)


# =====================================================================================================[120 characters]
#   Private Functions
# =====================================================================================================[120 characters]

@log_begin_end_func_name
def verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, tc_name):
    tcResult = "Failed"
    try:
        suiteName = rbi.get_variable_value("${SUITE_NAME}")
        print_pm_counter_testcase_header(tc_name, suiteName)
        print_pm_counter_testcase_info_to_console(tc_name, cell)
        # ---------------------------------------------------------------------------------------------[120 characters]
        CsvFile = csv.reader(open(pmc_csv_file, 'r'), delimiter=';', quotechar='|')
        pmcut = {}
        for row in CsvFile:
            for piid in piids_and_expected_values.keys():
                if (piid == row[0] and "NRCELL-%s" % cell in row[1]):
                    pmcut[piid] = {}
                    pmcut[piid]["reported"] = get_int_value(row[column])
                    pmcut[piid]["expected"] = piids_and_expected_values[piid]
                    pmcut[piid]["info"] = row[-2]
                    verify_within_threshold(pid=piid,
                                            pm_info=pmcut[piid]["info"],
                                            reported_value=pmcut[piid]["reported"],
                                            expected_value=pmcut[piid]["expected"],
                                            threshold=1)
        # ---------------------------------------------------------------------------------------------[120 characters]
        tcResult = search_for_failed_in_pmcut_dict()
        logging.info("tcResult = %s" % tcResult)
        print_pm_counter_testcase_footer(tcResult)
        pmResultDict = add_tc_result_to_report_json_dict(tc_name, tcResult)
    except Exception as e:
        logException("verify_legacy_pm_counters", e)
    return (tcResult.lower() == "passed"), pmResultDict


@log_begin_end_func_name
def verifyParametersInScf(verifyScfList, scfFilePath):
    isPassed = True
    scfObj = scf()
    for parameter in verifyScfList:
        returnedValue = 0
        try:
            scfObj.load_scf(scfFilePath)
            returnedValue = getValue(scfObj, parameter["p_name"], parameter["dist_name"])
            aResult = (returnedValue == parameter["value"])
        except Exception as e:
            logException("verifyParametersInScf", e, silent=True)
            aResult = "SCF is NOT available"
            isPassed = False
        else:
            isPassed = (isPassed and aResult)
        logging.info(30*"-" + "> %s == %s (%s)" % (parameter["value"], returnedValue, aResult))
    return isPassed


def getValue(scfObj, pName, distName):
    outString = ""
    try:
        outString = scfObj.get_value_from_scf(p_name=pName, dist_name=distName)
        if outString == "True":
            outString = "true"
        logging.info("getValue(): '%s' = '%s' (SCF)" % (pName, outString))
    except Exception as e:
        logException("getValue", e)
    return outString


def get_int_value(strValue, orderNumber=0):
    intValue = -1
    if strValue == "-1":
        intValue = -1
    elif strValue.startswith("ERR"):
        intValue = -1
    elif strValue.isdigit():
        intValue = int(strValue)
    elif "|" in strValue:
        intValue = int(strValue.split("|")[orderNumber])
        logging.info("getIntValue(): PMC value is NOT an Integer, but a list --> check XML report files!")
        logging.info("getIntValue(): intValue = %s" % intValue)
    else:
        logging.info("getIntValue(): PMC value has STRANGE format --> check XML report files!")
    return intValue


def logException(functionNameStr, e, silent=False):
    logging.info("%s(): Exception = <%s>" % (functionNameStr, str(e)))
    if not silent:
        rbi.log_to_console("" + RED + "  %s: exception happend (see log.html)" % functionNameStr + RESET + "")


def visualization():
    pd.set_option('display.max_columns', None)
    pd.set_option('display.expand_frame_repr', False)
