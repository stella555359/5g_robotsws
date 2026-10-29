# ====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd68 for 5GC000425 Feature
# Team: 'SqdGp68'
# Email: 'I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging
import csv
import json

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# TAF & UTE Libraries:
from taf.config.scf import scf

# ET or Feature Specific Libraries:
from testsuite.Ulm.ET.resources.tti_analysis.dtx import get_dtx_stats
from pmc_analysis import (prepare_for_pm_counter_testing,
                          finalise_pm_counter_testing,
                          print_pm_counter_testcase_header,
                          print_pm_counter_testcase_footer,
                          print_pm_counter_testcase_info_to_console,
                          add_tc_result_to_report_json_dict,
                          search_for_failed_in_pmcut_dict,
                          convertRangeStringToListOfStrings,
                          verify_within_threshold,
                          verify_within_range,
                          verify_is_greater,
                          verify_is_lower,
                          verify_is_equal)
from ttitrace_analysis import (calculateHarqPuschInfo, calculate_pdsch_vol_info)
from testsuite.Ulm.ET.L2.libraries.syslogs_analysis import check_no_fatality_error_in_syslogs
from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name


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
ulFdSchedData = {}
swPostFix = None
qcDict5GC000425Y = {
    "5GC000425_Y_UP_PMCounter__ULHARQ__PUSCH_CP_INIRE_VOL_64TBL_MCSxx": "M55304C04000-M55304C04028",
    "5GC000425_Y_UP_PMCounter__ULHARQ__PUSCH_CP_INI_VOL_64TBL_MCSxx":   "M55304C03000-M55304C03028",
    "5GC000425_Y_UP_PMCounter__KPI__DL_PDCP_SDU_D_RBR_QOS_GRP_xx":      "M55320C02001-M55320C02020",
    "5GC000425_Y_UP_PMCounter__KPI__DL_PDCP_VOL_D_RBR_QOS_GRP_xx":      "M55320C01001-M55320C01020",
    "5GC000425_Y_UP_PMCounter__ULHARQ__PUSCH_CP_INI_64TBL_MCS_xx":      "M55302C00000-M55302C00028",
    "5GC000425_Y_UP_PMCounter__ULHARQ__PUSCH_CP_SUC_INI_64TBL_MCS_xx":  "M55302C04000-M55302C04028",
    "5GC000425_Y_UP_PMCounter__ULHARQ__PUSCH_CP_SUC_ANY_64TBL_MCS_xx":  "M55302C05000-M55302C05028",
    "5GC000425_Y_UP_PMCounter__ULHARQ__PUSCH_CP_UNSUCC_64TBL_MCS_xx":   "M55302C03000-M55302C03028",
    "5GC000425_Y_UP_PMCounter__KPI__DL_RLC_PDU_D_RBR_H_QOS_GRP_xx":     "M55311C12001-M55311C12020",
    "5GC000425_Y_UP_PMCounter__KPI__DL_RLC_VOL_D_RBR_H_QOS_GRP_xx":     "M55311C11001-M55311C11020",
    "5GC000425_Y_UP_PMCounter__KPI__UL_RLC_PDU_D_RBR_H_QOS_GRP_xx":     "M55311C16001-M55311C16020",
    "5GC000425_Y_UP_PMCounter__KPI__UL_RLC_VOL_D_RBR_H_QOS_GRP_xx":     "M55311C15001-M55311C15020",
    "5GC000425_Y_UP_PMCounter__ULHARQ__UL_RLC_PDU_RETX_H_QOS_GRP_xx":   "M55311C08001-M55311C08020",
    # --- New 12 QC TestCases from Paris-Sanclay:
    "5GC000425_Y_36_UP_PMCounter_M55310C050xx_KPI_L2LO_DL_RLC_DELAY_QOS_GRP_xx":         "M55310C05001-M55310C05020",
    "5GC000425_Y_37_UP_PMCounter_M55310C070xx_KPI_L2LO_DL_RLC_VOL_D_FBF_L_QOS_GRP_xx":   "M55310C07001-M55310C07020",
    "5GC000425_Y_38_UP_PMCounter_M55310C080xx_KPI_L2LO_DL_RLC_PDU_D_FBF_L_QOS_GRP_xx":   "M55310C08001-M55310C08020",
    "5GC000425_Y_39_UP_PMCounter_M55311C100xx_KPI_L2HIDU_UL_RLC_DELAY_QOS_GRP_xx":       "M55311C10001-M55311C10020",
    "5GC000425_Y_40_UP_PMCounter_M55311C170xx_KPI_L2HIDU_UL_RLC_VOL_D_OTH_H_QOS_GRP_xx": "M55311C17001-M55311C17020",
    "5GC000425_Y_41_UP_PMCounter_M55311C180xx_KPI_L2HIDU_DL_RLC_PDU_D_OTH_H_QOS_GRP_xx": "M55311C18001-M55311C18020",
    "5GC000425_Y_42_UP_PMCounter_M55312C090xx_KPI_L2HICU_DL_PDCP_DELAY_QOS_GRP_xx":      "M55319C09001-M55319C09020",
    "5GC000425_Y_43_UP_PMCounter_M55312C100xx_KPI_L2HICU_UL_PDCP_DELAY_QOS_GRP_xx":      "M55319C10001-M55319C10020",
    "5GC000425_Y_44_UP_PMCounter_M55312C130xx_KPI_L2HICU_DL_PDCP_VOL_D_OTH_QOS_GRP_xx":  "M55320C03001-M55320C03020",
    "5GC000425_Y_45_UP_PMCounter_M55312C140xx_KPI_L2HICU_DL_PDCP_SDU_D_OTH_QOS_GRP_xx":  "M55320C04001-M55320C04020",
    "5GC000425_Y_46_UP_PMCounter_M55312C150xx_KPI_L2HICU_UL_PDCP_VOL_D_OTH_QOS_GRP_xx":  "M55320C07001-M55320C07020",
    "5GC000425_Y_47_UP_PMCounter_M55312C160xx_KPI_L2HICU_UL_PDCP_SDU_D_OTH_QOS_GRP_xx":  "M55320C08001-M55320C08020",
    # --- 425X:
    "DL_VOL_DISC_BUFTH_QOS_GRP_xx":  "M55320C05001-M55320C05020",
    "DL_SDU_DISC_BUFTH_QOS_GRP_xx":  "M55320C06001-M55320C06020",
    # --- Some TestCases from Paris-Sanclay:
    "DL_PDCP_SDUs":     "M55319C01001-M55319C01020",
    "UL_PDCP_SDUs":     "M55319C05001-M55319C05020",
    "DL_RLC_PDUs":      "M55310C02001-M55310C02020",
    "UL_RLC_PDUs":      "M55311C13001-M55311C13020",
    # --- to cover PMCs for CNI-155634
    "CNI155634__PDSCH_INIRE_VOL_64TBL_MCSxx":  "M55304C02000-M55304C02028"}

# ====================================================================================================[120 characters]
#   Keywords
# ====================================================================================================[120 characters]


@log_begin_end_func_name
def verify_qc_test_case(tc_name):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Generic keyword which makes the common preparation and calls the Test Case specific Validation
    # -------------------------------------------------------------------------------------------------[120 characters]
    global swPostFix
    swPostFix = rbi.get_variable_value("${SW_POSTFIX}")
    logging.info("verify_qc_test_case: swPostFix = %s" % swPostFix)
    rbi.log_to_console(BOLD + "\n Verify QC Test Case(s) of 5GC000425: " + RESET + "~" * 102 + "")
    # rbi.log_to_console(("  "+tc_name[:80]+"   ").ljust(133), no_newline=True)
    tc_verdict = False
    ts_log_dir = rbi.get_variable_value("${ts_log_dir}")
    path_to_syslog_tgz = rbi.get_variable_value("${path_to_syslog_tgz}")
    pmc_csv_file = rbi.get_variable_value("${pm_counters_dir}") + "/pmCounters.csv"
    pmc_index = rbi.get_variable_value("${pmc_index}")
    nrbts_str = rbi.get_variable_value("${nrbts_str}")[0]
    cell = int(rbi.get_variable_value("${tdd_cell_1}"))
    column = -(pmc_index+3)
    qci_under_test = 6 if swPostFix == "MMWV_SA" else 9
    logging.info("verify_qc_test_case: tc_name = %s" % tc_name)
    logging.info("verify_qc_test_case: ts_log_dir = %s" % ts_log_dir)
    logging.info("verify_qc_test_case: pmc_csv_file = %s" % pmc_csv_file)
    logging.info("verify_qc_test_case: cell = %s" % cell)
    logging.info("verify_qc_test_case: column = %s" % column)
    logging.info("verify_qc_test_case: qci_under_test = %s" % qci_under_test)
    # --- Test Case Specific Part: --------------------------------------------------------------------[120 characters]
    if "5GC000425_Y_MEAS_PERIOD_NR_PDCP_REPORT2" == tc_name:
        tc_verdict = verify_5GC000425_Y_MEAS_PERIOD_NR_PDCP_REPORT2(pmc_csv_file, column, cell)
    if "KPI__DL_RLC" in tc_name:
        tcVol = "5GC000425_Y_UP_PMCounter__KPI__DL_RLC_VOL_D_RBR_H_QOS_GRP_xx"
        tcNum = "5GC000425_Y_UP_PMCounter__KPI__DL_RLC_PDU_D_RBR_H_QOS_GRP_xx"
        expectedSize = 1003
        tc_verdict = verifyNumVolPMCs(tcVol, tcNum, expectedSize,
                                      pmc_csv_file, cell, column, qci_under_test, "within_threshold")
    if "ULHARQ__PUSCH" in tc_name:
        tc_verdict = verify_UP_PMCounter__ULHARQ__PUSCH(tc_name, pmc_csv_file, column, cell)
    if "KPI__UL_RLC" in tc_name:
        tcName = "5GC000425_Y_UP_PMCounter__KPI__UL_RLC_PDU_D_RBR_H_QOS_GRP_xx"
        tc_verdict_num = verifySetOfPMCs(tcName, 1, pmc_csv_file, cell, column, qci_under_test, "is_greater")
        tcName = "5GC000425_Y_UP_PMCounter__KPI__UL_RLC_VOL_D_RBR_H_QOS_GRP_xx"
        tc_verdict_vol = verifySetOfPMCs(tcName, 1, pmc_csv_file, cell, column, qci_under_test, "is_greater")
        tc_verdict = tc_verdict_num and tc_verdict_vol
    if "DL_RLC_DELAY_QOS_GRP" in tc_name:
        tcDelay = "5GC000425_Y_36_UP_PMCounter_M55310C050xx_KPI_L2LO_DL_RLC_DELAY_QOS_GRP_xx"
        tcNum = "DL_RLC_PDUs"
        tc_verdict = verifyDelayPMCs(tcDelay, tcNum, 4000, pmc_csv_file, cell, column, qci_under_test, "within_range")
    if "UL_RLC_DELAY_QOS_GRP" in tc_name:
        tcDelay = "5GC000425_Y_39_UP_PMCounter_M55311C100xx_KPI_L2HIDU_UL_RLC_DELAY_QOS_GRP_xx"
        tcNum = "UL_RLC_PDUs"
        tc_verdict = verifyDelayPMCs(tcDelay, tcNum, 1000, pmc_csv_file, cell, column, qci_under_test, "within_range")
    if "DL_PDCP_DELAY_QOS_GRP" in tc_name:
        tcDelay = "5GC000425_Y_42_UP_PMCounter_M55312C090xx_KPI_L2HICU_DL_PDCP_DELAY_QOS_GRP_xx"
        tcNum = "DL_PDCP_SDUs"
        tc_verdict = verifyDelayPMCs(tcDelay, tcNum, 700, pmc_csv_file, cell, column, qci_under_test, "within_range")
    if "UL_PDCP_DELAY_QOS_GRP" in tc_name:
        tcDelay = "5GC000425_Y_43_UP_PMCounter_M55312C100xx_KPI_L2HICU_UL_PDCP_DELAY_QOS_GRP_xx"
        tcNum = "UL_PDCP_SDUs"
        tc_verdict = verifyDelayPMCs(tcDelay, tcNum, 20, pmc_csv_file, cell, column, qci_under_test, "within_range")
    if "L2HICU_DL_PDCP_VOL_D_OTH" in tc_name:
        tcVol = "5GC000425_Y_44_UP_PMCounter_M55312C130xx_KPI_L2HICU_DL_PDCP_VOL_D_OTH_QOS_GRP_xx"
        tcNum = "5GC000425_Y_45_UP_PMCounter_M55312C140xx_KPI_L2HICU_DL_PDCP_SDU_D_OTH_QOS_GRP_xx"
        expectedSize = 1000
        tc_verdict = verifyNumVolPMCs(tcVol, tcNum, expectedSize,
                                      pmc_csv_file, cell, column, qci_under_test, "within_threshold")
    if "KPI__DL_PDCP" in tc_name:
        tcVol = "5GC000425_Y_UP_PMCounter__KPI__DL_PDCP_VOL_D_RBR_QOS_GRP_xx"
        tcNum = "5GC000425_Y_UP_PMCounter__KPI__DL_PDCP_SDU_D_RBR_QOS_GRP_xx"
        expectedSize = 1000
        tc_verdict = verifyNumVolPMCs(tcVol, tcNum, expectedSize,
                                      pmc_csv_file, cell, column, qci_under_test)
    if "CNI155634" in tc_name:
        tc_verdict = verify_PDSCH_INIRE_VOL_64TBL_MCS(tc_name, pmc_csv_file, column, cell)
    # -------------------------------------------------------------------------------------------------[120 characters]
    tc_verdict = check_no_fatality_error_in_syslogs(path_to_syslog_tgz) and tc_verdict  # <--- Common Checkpoint
    # -------------------------------------------------------------------------------------------------[120 characters]
    logging.info("verify_qc_test_case: tc_verdict = %s" % tc_verdict)
    rbi.should_be_true(tc_verdict)  # IMPORTANT: keep this line the LAST one


@log_begin_end_func_name
def verify_SCF_Paramaters():
    # -------------------------------------------------------------------------------------------------[120 characters]
    # - 5GC000425 feature should get activated
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${path_to_scf_xml}")
    nrbts_str = rbi.get_variable_value("${nrbts_str}")[0]
    try:
        expected_scf_list = [{'p_name': 'actBbPoolTddFr1', 'value': 'true', 'dist_name': nrbts_str}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("verify_SCF_Paramaters", e)
    rbi.should_be_true(is_SCF_correct)


@log_begin_end_func_name
def get_dtx_statistics():
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='physCellId', direction='ul')
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)


# ====================================================================================================[120 characters]
#   Validation Functions
# ====================================================================================================[120 characters]

@log_begin_end_func_name
def verify_5GC000425_Y_MEAS_PERIOD_NR_PDCP_REPORT2(pmcCsvFile, column, cell):
    tcResult = "Failed"
    testCaseName = "5GC000425_Y_MEAS_PERIOD_NR_PDCP_REPORT2"
    try:
        measPeriod = rbi.run_keyword("Fetch Measurement Period From SCF")
        logging.info("measPeriod = %s" % measPeriod)
        CsvFile = csv.reader(open(pmcCsvFile, 'r'), delimiter=';', quotechar='|')
        pmcut = {}
        piid = "M55320C00001"
        for row in CsvFile:
            if (piid == row[0]):
                pmcut[piid] = {}
                pmcut[piid]["reported"] = get_int_value(row[column])
                pmcut[piid]["expected"] = measPeriod
                pmcut[piid]["info"] = row[-2]
                if pmcut[piid]["reported"] != -1:
                    break
        logging.info("pmcut = %s" % json.dumps(pmcut, sort_keys=True, indent=4))
        testCaseName = "5GC000425_Y_MEAS_PERIOD_NR_PDCP_REPORT2"
        suiteName = rbi.get_variable_value("${SUITE_NAME}")
        print_pm_counter_testcase_header(testCaseName, suiteName)
        print_pm_counter_testcase_info_to_console(testCaseName, cell)
        verify_within_threshold(pid=piid,
                                pm_info=pmcut[piid]["info"],
                                reported_value=pmcut[piid]["reported"],
                                expected_value=pmcut[piid]["expected"],
                                threshold=1)
        # --------------------------------------------------------------------------------------------[120 characters]
        tcResult = search_for_failed_in_pmcut_dict()
        logging.info("tcResult = %s" % tcResult)
        print_pm_counter_testcase_footer(tcResult)
        pmResultDict = add_tc_result_to_report_json_dict(testCaseName, tcResult)
        logging.info("pmResultDict = ")
        logging.info(json.dumps(pmResultDict, sort_keys=True, indent=4))
        # --------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_qc_test_case", e)
    return (tcResult.lower() == "passed")


@log_begin_end_func_name
def verifyNumVolPMCs(tcNameVol, tcNameNum, expectedSize, pmcCsvFile, cell, column, qciUT,
                     verificationType="is_equal"):
    tcResultNum = "Failed"
    tcResultVol = "Failed"
    logging.info("verifyNumVolPMCs(): tcNameVol = %s" % tcNameVol)
    logging.info("verifyNumVolPMCs(): tcNameNum = %s" % tcNameNum)
    logging.info("verifyNumVolPMCs(): expectedSize = %s" % expectedSize)
    logging.info("verifyNumVolPMCs(): qciUT = %s" % qciUT)
    PIIDs_Vol = convertRangeStringToListOfStrings(qcDict5GC000425Y[tcNameVol].split('-'))
    PIIDs_Num = convertRangeStringToListOfStrings(qcDict5GC000425Y[tcNameNum].split('-'))
    logging.info("verifyNumVolPMCs(): PIIDs_Vol = %s" % PIIDs_Vol)
    logging.info("verifyNumVolPMCs(): PIIDs_Num = %s" % PIIDs_Num)
    try:
        CsvFile = csv.reader(open(pmcCsvFile, 'r'), delimiter=';', quotechar='|')
        pmcut = {}
        for row in CsvFile:
            for piid in PIIDs_Vol:
                if (piid == row[0]):
                    pmcut[piid] = {}
                    pmcut[piid]["reported"] = get_int_value(row[column])
                    pmcut[piid]["expected"] = 0
                    pmcut[piid]["info"] = row[-2]
            for piid in PIIDs_Num:
                if (piid == row[0]):
                    pmcut[piid] = {}
                    pmcut[piid]["reported"] = get_int_value(row[column])
                    pmcut[piid]["expected"] = 0
                    pmcut[piid]["info"] = row[-2]
        logging.info("pmcut = %s" % json.dumps(pmcut, sort_keys=True, indent=4))
        logging.info("verifyNumVolPMCs(): len(PIIDs_Vol) = %s" % len(PIIDs_Vol))
        logging.info("verifyNumVolPMCs(): len(PIIDs_Num) = %s" % len(PIIDs_Num))
        logging.info("verifyNumVolPMCs(): pmcCsvFile = %s" % pmcCsvFile)
        volPiidIterableList = iter(PIIDs_Vol)
        numPiidIterableList = iter(PIIDs_Num)
        for qci in range(1, len(PIIDs_Vol)+1):
            logging.info("verifyNumVolPMCs(): qci = %s" % qci)
            volPiid = next(volPiidIterableList)
            numPiid = next(numPiidIterableList)
            logging.info("verifyNumVolPMCs(): %s -> %s" % (volPiid, pmcut[volPiid]["reported"]))
            logging.info("verifyNumVolPMCs(): %s -> %s" % (numPiid, pmcut[numPiid]["reported"]))
            if pmcut[volPiid]["reported"] and pmcut[numPiid]["reported"]:
                tempDlPdcpSduSize = int(round(float(pmcut[volPiid]["reported"])/float(pmcut[numPiid]["reported"])))
                logging.info("verifyNumVolPMCs(): Packet Size = %s" % tempDlPdcpSduSize)
                logging.info("verifyNumVolPMCs(): Expected Size = %s" % expectedSize)
                pmcut[volPiid]["expected"] = int(round(float(pmcut[numPiid]["reported"])*float(expectedSize)))
                pmcut[numPiid]["expected"] = int(round(float(pmcut[volPiid]["reported"])/float(expectedSize)))
            elif qci == qciUT:
                pmcut[volPiid]["expected"] = expectedSize
                pmcut[numPiid]["expected"] = 1  # atleast one discarded PDU is expected!
        # --- Num ----------------------------------------------------------------------------------------------------
        suiteName = rbi.get_variable_value("${SUITE_NAME}")
        print_pm_counter_testcase_header(tcNameNum, suiteName)
        print_pm_counter_testcase_info_to_console(tcNameNum, cell)
        for piid in PIIDs_Num:
            if verificationType == "within_threshold":
                verify_within_threshold(pid=piid,
                                        pm_info=pmcut[piid]["info"],
                                        reported_value=pmcut[piid]["reported"],
                                        expected_value=pmcut[piid]["expected"],
                                        threshold=int(pmcut[piid]["reported"]*0.03))
            else:
                verify_is_equal(pid=piid,
                                pm_info=pmcut[piid]["info"],
                                reported_value=pmcut[piid]["reported"],
                                expected_value=pmcut[piid]["expected"])
        tcResultNum = search_for_failed_in_pmcut_dict()
        print_pm_counter_testcase_footer(tcResultNum)
        pmResultDictNum = add_tc_result_to_report_json_dict(tcNameNum, tcResultNum)
        logging.info("verifyNumVolPMCs(): pmResultDictNum = ")
        logging.info(json.dumps(pmResultDictNum, sort_keys=True, indent=4))
        # --- Vol ----------------------------------------------------------------------------------------------------
        suiteName = rbi.get_variable_value("${SUITE_NAME}")
        print_pm_counter_testcase_header(tcNameVol, suiteName)
        print_pm_counter_testcase_info_to_console(tcNameVol, cell)
        for piid in PIIDs_Vol:
            if verificationType == "within_threshold":
                verify_within_threshold(pid=piid,
                                        pm_info=pmcut[piid]["info"],
                                        reported_value=pmcut[piid]["reported"],
                                        expected_value=pmcut[piid]["expected"],
                                        threshold=int(pmcut[piid]["reported"]*0.03))
            else:
                verify_is_equal(pid=piid,
                                pm_info=pmcut[piid]["info"],
                                reported_value=pmcut[piid]["reported"],
                                expected_value=pmcut[piid]["expected"])
        # --------------------------------------------------------------------------------------------[120 characters]
        tcResultVol = search_for_failed_in_pmcut_dict()
        print_pm_counter_testcase_footer(tcResultVol)
        pmResultDictVol = add_tc_result_to_report_json_dict(tcNameVol, tcResultVol)
        logging.info("verifyNumVolPMCs(): pmResultDictVol = ")
        logging.info(json.dumps(pmResultDictVol, sort_keys=True, indent=4))
        # --------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verifyNumVolPMCs", e)
    return (tcResultNum.lower() == "passed" and tcResultVol.lower() == "passed")


@log_begin_end_func_name
def verify_UP_PMCounter__ULHARQ__PUSCH(tc_name, pmcCsvFile, column, cell):
    # ================================================================================================[120 characters]
    # IPERF packet length must be 1000 bytes
    # IMPORTANT 1: the following should be set in swconfig.txt:
    #    rdUlAlwaysScheduled -> 0x5800C0=1
    #    rd523eSchedulinRequestActivate -> 0x590027=0
    # IMPORTANT 2: the NUMBER related counters are not aligned with VOLUME ones, if no UE is attached, because
    #    Viola Farag: the triggers for these counters (as specified in DOORS) are different
    #    Ruediger Tanzke: without traffic the HARQ counters do not count, but ghost pre-ambles are counted in Volume
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~[120 characters]
    global ulFdSchedData
    if not ulFdSchedData:
        result_dir = rbi.run_keyword("Get Testcase Log Directory")
        path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
        ulFdSchedData = calculateHarqPuschInfo(path_to_ttitrace_pkl)
    if "ULHARQ__PUSCH_CP_INI_64TBL_MCS_xx" in tc_name:
        tcResult = verify_msc_pmcs(tcName="5GC000425_Y_UP_PMCounter__ULHARQ__PUSCH_CP_INI_64TBL_MCS_xx",
                                   expectedValues=ulFdSchedData["AllNum"],
                                   pmcCsvFile=pmcCsvFile,
                                   cell=cell,
                                   column=column,
                                   verificationType="is_equal")
    if "ULHARQ__PUSCH_CP_SUC_INI_64TBL_MCS_xx" in tc_name:
        tcResult = verify_msc_pmcs(tcName="5GC000425_Y_UP_PMCounter__ULHARQ__PUSCH_CP_SUC_INI_64TBL_MCS_xx",
                                   expectedValues=ulFdSchedData["IniNum"],
                                   pmcCsvFile=pmcCsvFile,
                                   cell=cell,
                                   column=column,
                                   verificationType="is_equal")
    if "ULHARQ__PUSCH_CP_SUC_ANY_64TBL_MCS_xx" in tc_name:
        tcResult = verify_msc_pmcs(tcName="5GC000425_Y_UP_PMCounter__ULHARQ__PUSCH_CP_SUC_ANY_64TBL_MCS_xx",
                                   expectedValues=ulFdSchedData["AnyNum"],
                                   pmcCsvFile=pmcCsvFile,
                                   cell=cell,
                                   column=column,
                                   verificationType="is_equal")
    if "ULHARQ__PUSCH_CP_INI_VOL_64TBL_MCSxx" in tc_name:
        tcResult = verify_msc_pmcs(tcName="5GC000425_Y_UP_PMCounter__ULHARQ__PUSCH_CP_INI_VOL_64TBL_MCSxx",
                                   expectedValues=ulFdSchedData["IniVol"],
                                   pmcCsvFile=pmcCsvFile,
                                   cell=cell,
                                   column=column,
                                   verificationType="is_equal")
    if "ULHARQ__PUSCH_CP_INIRE_VOL_64TBL_MCSxx" in tc_name:
        tcResult = verify_msc_pmcs(tcName="5GC000425_Y_UP_PMCounter__ULHARQ__PUSCH_CP_INIRE_VOL_64TBL_MCSxx",
                                   expectedValues=ulFdSchedData["IniReVol"],
                                   pmcCsvFile=pmcCsvFile,
                                   cell=cell,
                                   column=column,
                                   verificationType="is_equal")
    if "ULHARQ__PUSCH_CP_UNSUCC_64TBL_MCS_xx" in tc_name:
        tcResult = verifyUnsucMscPMCs(tcName="5GC000425_Y_UP_PMCounter__ULHARQ__PUSCH_CP_UNSUCC_64TBL_MCS_xx",
                                      expectedValues=ulFdSchedData["UnsucNum"],
                                      pmcCsvFile=pmcCsvFile,
                                      cell=cell,
                                      column=column,
                                      verificationType="is_lower")
    return (tcResult.lower() == "passed")


@log_begin_end_func_name
def verifySetOfPMCs(tcName, expectedValue, pmcCsvFile, cell, column, qciUT, verificationType="is_equal"):
    tcResult = "Failed"
    logging.info("verifySetOfPMCs(): tcName = %s" % tcName)
    logging.info("verifySetOfPMCs(): expectedValue = %s" % expectedValue)
    logging.info("verifySetOfPMCs(): qciUT = %s" % qciUT)
    PIIDs = convertRangeStringToListOfStrings(qcDict5GC000425Y[tcName].split('-'))
    logging.info("verifySetOfPMCs(): PIIDs = %s" % PIIDs)
    try:
        CsvFile = csv.reader(open(pmcCsvFile, 'r'), delimiter=';', quotechar='|')
        pmcut = {}
        for row in CsvFile:
            for piid in PIIDs:
                if (piid == row[0]):
                    pmcut[piid] = {}
                    pmcut[piid]["reported"] = get_int_value(row[column])
                    pmcut[piid]["expected"] = 0
                    pmcut[piid]["info"] = row[column+1]
        logging.info("verifySetOfPMCs(): len(PIIDs) = %s" % len(PIIDs))
        logging.info("verifySetOfPMCs(): pmcCsvFile = %s" % pmcCsvFile)
        piidIterableList = iter(PIIDs)
        for qci in range(1, len(PIIDs)+1):
            piid = next(piidIterableList)
            logging.info("verifySetOfPMCs(): qci = %s: %s -> %s" % (qci, piid, pmcut[piid]["reported"]))
            if pmcut[piid]["reported"]:
                pmcut[piid]["expected"] = expectedValue
            elif qci == qciUT:
                pmcut[piid]["expected"] = 1  # atleast one discarded PDU is expected!
        # --------------------------------------------------------------------------------------------[120 characters]
        suiteName = rbi.get_variable_value("${SUITE_NAME}")
        print_pm_counter_testcase_header(tcName, suiteName)
        print_pm_counter_testcase_info_to_console(tcName, cell)
        for piid in PIIDs:
            if verificationType == "within_threshold":
                verify_within_threshold(pid=piid,
                                        pm_info=pmcut[piid]["info"],
                                        reported_value=pmcut[piid]["reported"],
                                        expected_value=pmcut[piid]["expected"],
                                        threshold=max(int(pmcut[piid]["reported"]*0.03), 5))
            elif verificationType == "is_greater":
                verify_is_greater(pid=piid,
                                  pm_info=pmcut[piid]["info"],
                                  reported_value=pmcut[piid]["reported"],
                                  expected_value=pmcut[piid]["expected"])
            else:
                verify_is_equal(pid=piid,
                                pm_info=pmcut[piid]["info"],
                                reported_value=pmcut[piid]["reported"],
                                expected_value=pmcut[piid]["expected"])
        # --------------------------------------------------------------------------------------------[120 characters]
        tcResult = search_for_failed_in_pmcut_dict()
        print_pm_counter_testcase_footer(tcResult)
        pmResultDict = add_tc_result_to_report_json_dict(tcName, tcResult)
        logging.info("verifySetOfPMCs(): pmResultDict = ")
        logging.info(json.dumps(pmResultDict, sort_keys=True, indent=4))
        # --------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verifySetOfPMCs", e)
    return (tcResult.lower() == "passed")


# ====================================================================================================[120 characters]
#   Private Functions
# ====================================================================================================[120 characters]

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
    logging.info("getValue(): pName = %s" % (pName))
    logging.info("getValue(): outString = %s" % (outString))
    try:
        outString = scfObj.get_value_from_scf(p_name=pName, dist_name=distName)
        outString = "true" if outString == "True" else outString
        outString = "false" if outString == "False" else outString
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


@log_begin_end_func_name
def verify_msc_pmcs(tcName, expectedValues, pmcCsvFile, cell, column, verificationType="is_equal"):
    logging.info("verify_msc_pmcs(): tcName = %s" % tcName)
    logging.info("verify_msc_pmcs(): expectedValues = %s" % expectedValues)
    PIIDs = convertRangeStringToListOfStrings(qcDict5GC000425Y[tcName].split('-'))
    logging.info("verify_msc_pmcs(): PIIDs = %s" % PIIDs)
    rangeList = qcDict5GC000425Y["5GC000425_Y_UP_PMCounter__ULHARQ__PUSCH_CP_UNSUCC_64TBL_MCS_xx"].split('-')
    unsucPIIDs = convertRangeStringToListOfStrings(rangeList)
    logging.info("verify_msc_pmcs(): unsucPIIDs = %s" % unsucPIIDs)
    numOfPassed = 0
    numOfFailed = 0
    try:
        CsvFile = csv.reader(open(pmcCsvFile, 'r'), delimiter=';', quotechar='|')
        pmcut = {}
        for row in CsvFile:
            for piid in PIIDs:
                if (piid == row[0] and "NRCELL-%s" % cell in row[1]):
                    pmcut[piid] = {}
                    pmcut[piid]["reported"] = get_int_value(row[column])
                    pmcut[piid]["expected"] = 0
                    pmcut[piid]["info"] = row[column+1]
            for piid in unsucPIIDs:
                if (piid == row[0] and "NRCELL-%s" % cell in row[1]):
                    pmcut[piid] = {}
                    pmcut[piid]["reported"] = get_int_value(row[column])
        logging.info("verify_msc_pmcs(): len(PIIDs) = %s" % len(PIIDs))
        logging.info("verify_msc_pmcs(): pmcCsvFile = %s" % pmcCsvFile)
        piidIterableList = iter(PIIDs)
        logging.info("verify_msc_pmcs(): piidIterableList = %s" % piidIterableList)
        piidIterableListUnsuc = iter(unsucPIIDs)
        logging.info("verify_msc_pmcs(): piidIterableListUnsuc = %s" % piidIterableListUnsuc)
        for mcs in range(0, len(PIIDs)):
            piid = next(piidIterableList)
            unsucpiid = next(piidIterableListUnsuc)
            pmcut[piid]["expected"] = expectedValues[mcs]  # - pmcut[unsucpiid]["reported"]
        # --------------------------------------------------------------------------------------------[120 characters]
        suiteName = rbi.get_variable_value("${SUITE_NAME}")
        print_pm_counter_testcase_header(tcName, suiteName)
        print_pm_counter_testcase_info_to_console(tcName, cell)
        logging.info("verify_msc_pmcs(): suiteName = %s" % suiteName)
        for piid in PIIDs:
            if verificationType == "within_threshold":
                if "_VOL_" in tcName:
                    threshold = max(int(pmcut[piid]["reported"] * 0.005), 1000)
                else:
                    if piid.endswith("00") or piid.endswith("25") or piid.endswith("28"):
                        threshold = max(int(pmcut[piid]["reported"] * 0.5), 10)
                    else:
                        threshold = max(int(pmcut[piid]["reported"] * 0.02), 2)
                result = verify_within_threshold(pid=piid,
                                                 pm_info=pmcut[piid]["info"],
                                                 reported_value=pmcut[piid]["reported"],
                                                 expected_value=pmcut[piid]["expected"],
                                                 threshold=threshold)
            elif verificationType == "is_lower":
                verify_is_lower(pid=piid,
                                pm_info=pmcut[piid]["info"],
                                reported_value=pmcut[piid]["reported"],
                                expected_value=pmcut[piid]["expected"])
            elif verificationType == "is_greater":
                verify_is_greater(pid=piid,
                                  pm_info=pmcut[piid]["info"],
                                  reported_value=pmcut[piid]["reported"],
                                  expected_value=pmcut[piid]["expected"])
            else:
                # TTI trace and PMCs are not equal for MCS0, dlFdschedData.tbSize for RACH MSG2 is 0 in TTI trace
                # so handle it like verificationType == "within_threshold"
                if piid.endswith("00"):
                    if "_VOL_" in tcName:
                        threshold = max(int(pmcut[piid]["reported"] * 0.005), 1000)
                    else:
                        if piid.endswith("00") or piid.endswith("25") or piid.endswith("28"):
                            threshold = max(int(pmcut[piid]["reported"] * 0.5), 10)
                        else:
                            threshold = max(int(pmcut[piid]["reported"] * 0.02), 2)
                    result = verify_within_threshold(pid=piid,
                                                     pm_info=pmcut[piid]["info"],
                                                     reported_value=pmcut[piid]["reported"],
                                                     expected_value=pmcut[piid]["expected"],
                                                     threshold=threshold)
                else:
                    verify_is_equal(pid=piid,
                                    pm_info=pmcut[piid]["info"],
                                    reported_value=pmcut[piid]["reported"],
                                    expected_value=pmcut[piid]["expected"])
        # --------------------------------------------------------------------------------------------[120 characters]
        tcResult = search_for_failed_in_pmcut_dict()
        logging.info("verify_msc_pmcs(): tcResult = %s" % tcResult)
        print_pm_counter_testcase_footer(tcResult)
        pmResultDict = add_tc_result_to_report_json_dict(tcName, tcResult)
        logging.info("verify_msc_pmcs(): pmResultDict = ")
        logging.info(json.dumps(pmResultDict, sort_keys=True, indent=4))
        # --------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_msc_pmcs", e)
    return tcResult


@log_begin_end_func_name
def verifyUnsucMscPMCs(tcName, expectedValues, pmcCsvFile, cell, column, verificationType="is_equal"):
    logging.info("verifyMscPMCs(): tcName = %s" % tcName)
    logging.info("verifyMscPMCs(): expectedValues = %s" % expectedValues)
    PIIDs = convertRangeStringToListOfStrings(qcDict5GC000425Y[tcName].split('-'))
    logging.info("verifyMscPMCs(): PIIDs = %s" % PIIDs)
    numOfPassed = 0
    numOfFailed = 0
    try:
        CsvFile = csv.reader(open(pmcCsvFile, 'r'), delimiter=';', quotechar='|')
        pmcut = {}
        for row in CsvFile:
            for piid in PIIDs:
                if (piid == row[0]):
                    pmcut[piid] = {}
                    pmcut[piid]["reported"] = get_int_value(row[column])
                    pmcut[piid]["expected"] = 0
                    pmcut[piid]["info"] = row[column+1]
        logging.info("pmcut = %s" % json.dumps(pmcut, sort_keys=True, indent=4))
        logging.info("verifyMscPMCs(): len(PIIDs) = %s" % len(PIIDs))
        logging.info("verifyMscPMCs(): pmcCsvFile = %s" % pmcCsvFile)
        piidIterableList = iter(PIIDs)
        for mcs in range(0, len(PIIDs)):
            logging.info("verifyMscPMCs(): mcs = %s" % mcs)
            piid = next(piidIterableList)
            logging.info("verifyMscPMCs(): %s -> %s" % (piid, pmcut[piid]["reported"]))
            pmcut[piid]["expected"] = expectedValues[mcs]
        # --------------------------------------------------------------------------------------------[120 characters]
        suiteName = rbi.get_variable_value("${SUITE_NAME}")
        print_pm_counter_testcase_header(tcName, suiteName)
        print_pm_counter_testcase_info_to_console(tcName, cell)
        logging.info("verifyUnsucMscPMCs(): suiteName = %s" % suiteName)
        for piid in PIIDs:
            if verificationType == "within_threshold":
                if piid.endswith("00"):
                    threshold = max(int(pmcut[piid]["reported"] * 0.2), 2)
                else:
                    threshold = max(int(pmcut[piid]["reported"] * 0.01), 1)
                result = verify_within_threshold(pid=piid,
                                                 pm_info=pmcut[piid]["info"],
                                                 reported_value=pmcut[piid]["reported"],
                                                 expected_value=pmcut[piid]["expected"],
                                                 threshold=threshold)
            elif verificationType == "is_lower":
                verify_is_lower(pid=piid,
                                pm_info=pmcut[piid]["info"],
                                reported_value=pmcut[piid]["reported"],
                                expected_value=pmcut[piid]["expected"])
            else:
                verify_is_equal(pid=piid,
                                pm_info=pmcut[piid]["info"],
                                reported_value=pmcut[piid]["reported"],
                                expected_value=pmcut[piid]["expected"])
        # --------------------------------------------------------------------------------------------[120 characters]
        tcResult = search_for_failed_in_pmcut_dict()
        logging.info("verifyUnsucMscPMCs(): tcResult = %s" % tcResult)
        print_pm_counter_testcase_footer(tcResult)
        pmResultDict = add_tc_result_to_report_json_dict(tcName, tcResult)
        logging.info("verifyUnsucMscPMCs(): pmResultDict = ")
        logging.info(json.dumps(pmResultDict, sort_keys=True, indent=4))
        # --------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verifyUnsucMscPMCs", e)
    return tcResult


@log_begin_end_func_name
def verifyDelayPMCs(tcNameVol, tcNameNum, expectedKPI, pmcCsvFile, cell, column, qciUT, verificationType="is_equal"):
    logging.info("verifyDelayPMCs(): tcNameVol = %s" % tcNameVol)
    logging.info("verifyDelayPMCs(): tcNameNum = %s" % tcNameNum)
    logging.info("verifyDelayPMCs(): expectedKPI = %s" % expectedKPI)
    logging.info("verifyDelayPMCs(): qciUT = %s" % qciUT)
    PIIDs_Vol = convertRangeStringToListOfStrings(qcDict5GC000425Y[tcNameVol].split('-'))
    PIIDs_Num = convertRangeStringToListOfStrings(qcDict5GC000425Y[tcNameNum].split('-'))
    logging.info("verifyDelayPMCs(): PIIDs_Vol = %s" % PIIDs_Vol)
    logging.info("verifyDelayPMCs(): PIIDs_Num = %s" % PIIDs_Num)
    try:
        CsvFile = csv.reader(open(pmcCsvFile, 'r'), delimiter=';', quotechar='|')
        pmcut = {}
        for row in CsvFile:
            for piid in PIIDs_Vol:
                if piid == row[0] and row[1].endswith(str(cell)):
                    pmcut[piid] = {}
                    pmcut[piid]["reported"] = get_int_value(row[column])
                    pmcut[piid]["expected"] = 0
                    pmcut[piid]["info"] = row[column+1]
                    continue
            for piid in PIIDs_Num:
                if piid == row[0] and row[1].endswith(str(cell)):
                    pmcut[piid] = {}
                    pmcut[piid]["reported"] = get_int_value(row[column])
                    pmcut[piid]["expected"] = 0
                    pmcut[piid]["info"] = row[column+1]
                    continue
        logging.info("verifyNumVolPMCs(): len(PIIDs_Vol) = %s" % len(PIIDs_Vol))
        logging.info("verifyNumVolPMCs(): len(PIIDs_Num) = %s" % len(PIIDs_Num))
        logging.info("verifyNumVolPMCs(): pmcCsvFile = %s" % pmcCsvFile)
        volPiidIterableList = iter(PIIDs_Vol)
        numPiidIterableList = iter(PIIDs_Num)
        for qci in range(1, len(PIIDs_Vol)+1):
            logging.info("verifyDelayPMCs(): qci = %s" % qci)
            volPiid = next(volPiidIterableList)
            numPiid = next(numPiidIterableList)
            logging.info("verifyDelayPMCs(): %s -> %s" % (volPiid, pmcut[volPiid]["reported"]))
            logging.info("verifyDelayPMCs(): %s -> %s" % (numPiid, pmcut[numPiid]["reported"]))
            if pmcut[volPiid]["reported"] and pmcut[numPiid]["reported"]:
                KPI = float(pmcut[volPiid]["reported"])/float(pmcut[numPiid]["reported"])
                logging.info("verifyDelayPMCs(): KPI = %s" % KPI)
                logging.info("verifyDelayPMCs(): Expected KPI = %s" % expectedKPI)
                pmcut[volPiid]["expected"] = float(pmcut[numPiid]["reported"])*float(expectedKPI)
            elif qci == qciUT:
                pmcut[volPiid]["expected"] = expectedKPI
        # --- Delay ------------------------------------------------------------------------------------------------
        suiteName = rbi.get_variable_value("${SUITE_NAME}")
        print_pm_counter_testcase_header(tcNameVol, suiteName)
        print_pm_counter_testcase_info_to_console(tcNameVol, cell)
        for piid in PIIDs_Vol:
            if verificationType == "within_threshold" or int(pmcut[piid]["expected"]) == 0:
                if expectedKPI < 1.0:
                    threshold = int(pmcut[piid]["reported"]*0.2)
                else:
                    threshold = int(pmcut[piid]["reported"]*0.03)
                verify_within_threshold(pid=piid,
                                        pm_info=pmcut[piid]["info"],
                                        reported_value=pmcut[piid]["reported"],
                                        expected_value=int(pmcut[piid]["expected"]),
                                        threshold=threshold)
            elif verificationType == "is_lower":
                verify_is_lower(pid=piid,
                                pm_info=pmcut[piid]["info"],
                                reported_value=pmcut[piid]["reported"],
                                expected_value=int(pmcut[piid]["expected"]))
            elif verificationType == "within_range":
                verify_within_range(pid=piid,
                                    pm_info=pmcut[piid]["info"],
                                    reported_value=pmcut[piid]["reported"],
                                    expected_min_value=1,
                                    expected_max_value=pmcut[piid]["expected"])
            else:
                verify_is_equal(pid=piid,
                                pm_info=pmcut[piid]["info"],
                                reported_value=pmcut[piid]["reported"],
                                expected_value=pmcut[piid]["expected"])
        tcResult = search_for_failed_in_pmcut_dict()
        print_pm_counter_testcase_footer(tcResult)
        pmResultDictVol = add_tc_result_to_report_json_dict(tcNameVol, tcResult)
        logging.info("verifyDelayPMCs(): pmResultDictVol = ")
        logging.info(json.dumps(pmResultDictVol, sort_keys=True, indent=4))
        # ------------------------------------------------------------------------------------------------------------
    except Exception as e:
        logException("verifyDelayPMCs", e)
    return (tcResult.lower() == "passed")


@log_begin_end_func_name
def logException(functionNameStr, e, silent=False):
    logging.info("%s(): Exception = <%s>" % (functionNameStr, str(e)))
    if not silent:
        rbi.log_to_console("\n" + RED + "  %s: exception happend (see log.html)" % functionNameStr + RESET + "")


@log_begin_end_func_name
def verify_PDSCH_INIRE_VOL_64TBL_MCS(tc_name, pmc_csv_file, column, cell):
    # =================================================================================================[120 characters]
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    dl_fdscheddata = calculate_pdsch_vol_info(path_to_ttitrace_pkl)
    tc_result = verify_cni_mcs_pmcs(tc_name=tc_name,
                                    expected_values=dl_fdscheddata,
                                    pmc_csv_file=pmc_csv_file,
                                    cell=cell,
                                    column=column,
                                    verification_type="within_threshold")
    return (tc_result.lower() == "passed")


@log_begin_end_func_name
def verify_cni_mcs_pmcs(tc_name, expected_values, pmc_csv_file, cell, column, verification_type="is_equal"):
    logging.info("verify_cni_mcs_pmcs(): tc_name = %s" % tc_name)
    logging.info("verify_cni_mcs_pmcs(): expected_values = %s" % expected_values)
    PIIDs = convertRangeStringToListOfStrings(qcDict5GC000425Y[tc_name].split('-'))
    logging.info("verify_cni_mcs_pmcs(): PIIDs = %s" % PIIDs)
    try:
        CsvFile = csv.reader(open(pmc_csv_file, 'r'), delimiter=';', quotechar='|')
        pmcut = {}
        for row in CsvFile:
            for piid in PIIDs:
                if (piid == row[0] and "NRCELL-%s" % cell in row[1]):
                    pmcut[piid] = {}
                    pmcut[piid]["reported"] = get_int_value(row[column])
                    pmcut[piid]["expected"] = 0
                    pmcut[piid]["info"] = row[column+1]

        logging.info("verify_cni_mcs_pmcs(): len(PIIDs) = %s" % len(PIIDs))
        logging.info("verify_cni_mcs_pmcs(): pmc_csv_file = %s" % pmc_csv_file)
        piid_iterable_list = iter(PIIDs)
        logging.info("verify_cni_mcs_pmcs(): piid_iterable_list = %s" % piid_iterable_list)
        for mcs in range(0, len(PIIDs)):
            logging.info("mcs = %s" % mcs)
            piid = next(piid_iterable_list)
            logging.info("piid = %s" % piid)
            pmcut[piid]["expected"] = expected_values[mcs]
        # --------------------------------------------------------------------------------------------[120 characters]
        suite_name = rbi.get_variable_value("${SUITE_NAME}")
        print_pm_counter_testcase_header(tc_name, suite_name)
        print_pm_counter_testcase_info_to_console(tc_name, cell)
        logging.info("verify_cni_mcs_pmcs(): suite_name = %s" % suite_name)
        for piid in PIIDs:
            threshold = max(int(pmcut[piid]["reported"] * 0.005), 1000)
            verify_within_threshold(pid=piid,
                                    pm_info=pmcut[piid]["info"],
                                    reported_value=pmcut[piid]["reported"],
                                    expected_value=pmcut[piid]["expected"],
                                    threshold=threshold)
        # --------------------------------------------------------------------------------------------[120 characters]
        tc_result = search_for_failed_in_pmcut_dict()
        logging.info("verify_cni_mcs_pmcs(): tc_result = %s" % tc_result)
        print_pm_counter_testcase_footer(tc_result)
        pm_result_dict = add_tc_result_to_report_json_dict(tc_name, tc_result)
        logging.info("verify_cni_mcs_pmcs(): pm_result_dict = ")
        logging.info(json.dumps(pm_result_dict, sort_keys=True, indent=4))
        # --------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_cni_mcs_pmcs", e)
    return tc_result
