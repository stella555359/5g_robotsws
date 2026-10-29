# ====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd66 for TranRob TC based
# on CB007114-G-MAX (FDD) and CB008847-E-MAX (TDD)
# Team: 'SqdGp66'
# Email: 'I_MN_RAN_L2_SW_ULM_SQD_66@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging
import csv

import pandas as pd

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# TAF & UTE Libraries:
from taf.config.scf import scf

# ET or Feature Specific Libraries:
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


# ====================================================================================================[120 characters]
#   Keywords
# ====================================================================================================[120 characters]

@log_begin_end_func_name
def verify_qc_test_case(tc_name, nbrofpmcmi, exptp):
    # ------------------------------------------------------------------------------------------------[120 characters]
    # Generic keyword which makes the common preparation and calls the Test Case specific Validation
    # ------------------------------------------------------------------------------------------------[120 characters]
    rbi.log_to_console(BOLD + "\n Verify QC Test Case(s) of L3Call_MUE_Pooling: " + RESET + "~" * 102 + "")
    tc_verdict = False
    ts_log_dir = rbi.get_variable_value("${ts_log_dir}")
    pmc_csv_file = rbi.get_variable_value("${pm_counters_dir}") + "/pmCounters.csv"
    column = 0
    logging.info("tc_name = %s, nbrofpmcmi = %s, exptp = %s" % (tc_name, nbrofpmcmi, exptp))
    logging.info("ts_log_dir = %s" % ts_log_dir)
    logging.info("pmc_csv_file = %s" % pmc_csv_file)
    # --- Test Case Specific Part: -------------------------------------------------------------------[120 characters]
    cell = 1
    if "L3Call_MUE_Pooling_TC01" == tc_name:
        check_points = [verify_SCF_Paramaters_fdd(cell)]  # <--- Common Checkpoint
        column = verify_pm_counters_column_calculation(pmc_csv_file, cell, nbrofpmcmi, nbrofues=20)
        for cell in [1, 2, 3, 4, 5, 6]:
            check_points.append(verify_legacy_pmc_ra_procedure(pmc_csv_file, column, cell, tc_name, nbrofues=20))
            check_points.append(verify_legacy_pmc_max_nbr_of_sch_ues(pmc_csv_file, column, cell, tc_name, nbrofpmcmi,
                                                                     nbrofues_MAX_SCHED_UE_PDSCH=4,
                                                                     nbrofues_MAX_SCHED_UE_PUSCH=4))
            check_points.append(verify_legacy_pmc_tp_calc(pmc_csv_file, column, cell, tc_name, nbrofpmcmi, exptp,
                                                          "M55310C010"))
            check_points.append(verify_legacy_pmc_tp_calc(pmc_csv_file, column, cell, tc_name, nbrofpmcmi, exptp,
                                                          "M55310C030"))
    if "L3Call_MUE_Pooling_TC02" == tc_name:
        cell = 1
        check_points = [verify_SCF_Paramaters_tdd(cell)]  # <--- Common Checkpoint
        column = verify_pm_counters_column_calculation(pmc_csv_file, cell, nbrofpmcmi, nbrofues=40)
        for cell in [1]:
            check_points.append(verify_legacy_pmc_ra_procedure(pmc_csv_file, column, cell, tc_name, nbrofues=40))
            check_points.append(verify_legacy_pmc_max_nbr_of_sch_ues(pmc_csv_file, column, cell, tc_name, nbrofpmcmi,
                                                                     nbrofues_MAX_SCHED_UE_PDSCH=13,
                                                                     nbrofues_MAX_SCHED_UE_PUSCH=16))
            check_points.append(verify_legacy_pmc_tp_calc(pmc_csv_file, column, cell, tc_name, nbrofpmcmi, exptp,
                                                          "M55310C010"))
            check_points.append(verify_legacy_pmc_tp_calc(pmc_csv_file, column, cell, tc_name, nbrofpmcmi, exptp,
                                                          "M55310C030"))
    # ------------------------------------------------------------------------------------------------[120 characters]
    tc_verdict = all(check_points)
    rbi.should_be_true(tc_verdict)  # IMPORTANT: keep this line the LAST one


# ====================================================================================================[120 characters]
#   Validation Functions
# ====================================================================================================[120 characters]

@log_begin_end_func_name
def verify_SCF_Paramaters_fdd(cell):
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${path_to_scf_xml}")
    distname_nrbts = rbi.get_variable_value("${nrbts_str}")[0]
    distname_nrcell = distname_nrbts + "/NRCELL-%s" % cell
    try:
        expected_scf_list = [{'p_name': 'actConnRrcPooling', 'value': 'true', 'dist_name': distname_nrbts},
                             {'p_name': 'actScheUePooling', 'value': 'true', 'dist_name': distname_nrbts}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("verify_SCF_Paramater_fdd", e)
    return is_SCF_correct


@log_begin_end_func_name
def verify_SCF_Paramaters_tdd(cell):
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${path_to_scf_xml}")
    distname_nrbts = rbi.get_variable_value("${nrbts_str}")[0]
    distname_nrcell = distname_nrbts + "/NRCELL-%s" % cell
    try:
        expected_scf_list = [{'p_name': 'actBbPoolTddFr1', 'value': 'true', 'dist_name': distname_nrbts}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("verify_SCF_Paramaters_tdd", e)
    return is_SCF_correct


def verify_legacy_pmc_max_nbr_of_sch_ues(pmc_csv_file, column, cell, tc_name, nbrofpmcmi, nbrofues_MAX_SCHED_UE_PDSCH=0,
                                         nbrofues_MAX_SCHED_UE_PUSCH=0):
    are_pmc_correct = False
    try:
        piids_and_expected_values = {"M55308C17002": int(nbrofues_MAX_SCHED_UE_PDSCH),
                                     "M55308C18002": int(nbrofues_MAX_SCHED_UE_PUSCH)}
        are_pmc_correct = verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, tc_name,
                                             nbrofpmcmi, threshold_percent=0)
        logging.info("are_pmc_correct_for_max_nbr_of_sch_ues in cell = %s: %s" % (cell, are_pmc_correct))
        # --------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_legacy_pmc_max_nbr_of_sch_ues", e)
    return are_pmc_correct


def verify_legacy_pmc_tp_calc(pmc_csv_file, column, cell, tc_name, nbrofpmcmi, exptp, prefix):
    are_pmc_correct = False
    try:
        piids_and_expected_values = {}
        num_of_qos = 20
        for qos in range(1, num_of_qos + 1):     # for i in range(20):
            piids_and_expected_values[("{}{:02d}".format(prefix, qos))] = int(exptp)
        are_pmc_correct = verify_pm_counters_tp_calculation(pmc_csv_file, column, cell, piids_and_expected_values,
                                                            tc_name, nbrofpmcmi, exptp, threshold_percent=0)
        logging.info("verify_legacy_pmc_tp_calc for %s in cell = %s: %s" % (prefix, cell, are_pmc_correct))
        # --------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_legacy_pmc_tp_calc for %s" % prefix, e)
    return are_pmc_correct


def verify_pm_counters_tp_calculation(pmc_csv_file, column, cell, piids_and_expected_values, tc_name,
                                      nbrofpmcmi, exptp, threshold_percent=0.1):
    tc_result = "Passed"
    throughput = 0
    logging.info("column = %s" % column)
    column += 1      # because the 1 measurement interval includes the register procedure
    nbrofpmcmi -= 1  # because the last measurement interval includes the deregister procedure
    mrindex = 0
    try:
        while mrindex < nbrofpmcmi:  # --- here the nbr of measurement interval's must be set
            print_pm_counter_testcase_header(tc_name, rbi.get_variable_value("${SUITE_NAME}"))
            print_pm_counter_testcase_info_to_console(tc_name, cell)
            with open(pmc_csv_file, 'r') as csv_file:
                csv_reader = csv.reader(csv_file, delimiter=';', quotechar='|')
                pmcut = {}
                for row in csv_reader:
                    piid = row[0]
                    if piid in piids_and_expected_values and "NRCELL-%s" % cell in row[1]:
                        throughput += get_int_value(row[column+mrindex])
                        if get_int_value(row[column+mrindex]) > 0:
                            pmcut[piid] = {
                                "reported": get_int_value(row[column+mrindex]),
                                "expected": piids_and_expected_values[piid],
                                "info": row[-2]
                            }
                            print_pm_counter_pid_result(piid, pmcut[piid]["info"], pmcut[piid]["reported"], "n/a",
                                                        "n/a", "threshold", "~ %s" % "n/a")
                throughput = float(format(throughput/300*8/1000000, ".3f"))
                thr = 0 if not threshold_percent else max(int(exptp * threshold_percent / 100), 1)
                local_tc_result = verify_within_threshold("            ",
                                                          pm_info="TP in MBit/s calc. for mi %s" % int(mrindex+1),
                                                          reported_value=throughput,
                                                          expected_value=int(exptp),
                                                          threshold=thr)
                if local_tc_result == "Failed":
                    tc_result = "Failed"
                mrindex += 1

        print_pm_counter_testcase_footer(tc_result)
    except Exception as e:
        logException("verify_pm_counters_tp_calculation", e)
    return (tc_result.lower() == "passed")


def verify_legacy_pmc_ra_procedure(pmc_csv_file, column, cell, tc_name, nbrofues=0):
    are_pmc_correct = False
    try:
        if tc_name == "L3Call_MUE_Pooling_TC01":
            piids_and_expected_values = {"M55306C00001": int(nbrofues/2),
                                         "M55306C02001": int(nbrofues/2),
                                         "M55306C03001": int(nbrofues/2),
                                         "M55306C05001": int(nbrofues/2)}
        if tc_name == "L3Call_MUE_Pooling_TC02":
            piids_and_expected_values = {"M55306C00001": int(nbrofues),
                                         "M55306C06001": int(nbrofues)}

        are_pmc_correct = verify_pm_counters_ra_procedure(pmc_csv_file, column, cell, piids_and_expected_values,
                                                          tc_name, threshold_percent=0)
        logging.info("are_pmc_correct_for_ra_procedure in cell = %s: %s" % (cell, are_pmc_correct))
        # --------------------------------------------------------------------------------------------[120 characters]
    except Exception as e:
        logException("verify_legacy_pmc_ra_Procedure", e)
    return are_pmc_correct


@log_begin_end_func_name
def verify_pm_counters_column_calculation(pmc_csv_file, cell, nbrofpmcmi, nbrofues=0):
    indextothefirstvalidmi = 0
    try:
        piids_and_expected_values = {"M55306C00001": int(nbrofues)}
        with open(pmc_csv_file, 'r') as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=';', quotechar='|')
            for row in csv_reader:
                piid = row[0]
                if piid in piids_and_expected_values and "NRCELL-%s" % cell in row[1]:
                    mrindex = 0
                    while mrindex < nbrofpmcmi+3:  # --- here the nbr of measurement interval's must be set
                        if get_int_value(row[mrindex]) > 0:
                            indextothefirstvalidmi = mrindex
                            logging.info("indextothefirstvalidmi: %s" % indextothefirstvalidmi)
                            break
                        mrindex += 1
    except Exception as e:
        logException("verify_legacy_pmc_ra_Procedure", e)
    return indextothefirstvalidmi


def verify_pm_counters_ra_procedure(pmc_csv_file, column, cell, piids_and_expected_values, tc_name,
                                    threshold_percent=0.1):
    tc_result = "Passed"
    try:
        print_pm_counter_testcase_header(tc_name, rbi.get_variable_value("${SUITE_NAME}"))
        print_pm_counter_testcase_info_to_console(tc_name, cell)
        with open(pmc_csv_file, 'r') as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=';', quotechar='|')
            pmcut = {}
            for row in csv_reader:
                piid = row[0]
                if piid in piids_and_expected_values and "NRCELL-%s" % cell in row[1]:
                    if get_int_value(row[column]) > 0:
                        pmcut[piid] = {
                            "reported": get_int_value(row[column]),
                            "expected": piids_and_expected_values[piid],
                            "info": row[-2]
                        }
                        thr = 0 if not threshold_percent else max(
                            int(pmcut[piid]["expected"] * threshold_percent / 100), 1)

                        local_tc_result = verify_within_threshold(pid=piid,
                                                                  pm_info=pmcut[piid]["info"],
                                                                  reported_value=pmcut[piid]["reported"],
                                                                  expected_value=pmcut[piid]["expected"],
                                                                  threshold=thr)
                        if local_tc_result == "Failed":
                            tc_result = "Failed"
        # --------------------------------------------------------------------------------------------[120 characters]
        print_pm_counter_testcase_footer(tc_result)
    except Exception as e:
        logException("verify_pm_counters_ra_procedure", e)
    return (tc_result.lower() == "passed")


def verify_pm_counters(pmc_csv_file, column, cell, piids_and_expected_values, tc_name,
                       nbrofpmcmi, threshold_percent=0.1):
    tc_result = "Passed"
    try:
        print_pm_counter_testcase_header(tc_name, rbi.get_variable_value("${SUITE_NAME}"))
        print_pm_counter_testcase_info_to_console(tc_name, cell)
        # --------------------------------------------------------------------------------------------[120 characters]
        with open(pmc_csv_file, 'r') as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=';', quotechar='|')
            pmcut = {}
            for row in csv_reader:
                piid = row[0]
                if piid in piids_and_expected_values and "NRCELL-%s" % cell in row[1]:
                    mrindex = 0
                    while mrindex < nbrofpmcmi:  # --- here the nbr of measurement interval's must be set
                        pmcut[piid] = {
                            "reported": get_int_value(row[column+mrindex]),
                            "expected": piids_and_expected_values[piid],
                            "info": row[-2]
                        }
                        thr = 0 if not threshold_percent else max(int(pmcut[piid]["expected"]*threshold_percent/100),
                                                                  1)
                        local_tc_result = verify_within_threshold(pid=piid,
                                                                  pm_info=pmcut[piid]["info"],
                                                                  reported_value=pmcut[piid]["reported"],
                                                                  expected_value=pmcut[piid]["expected"],
                                                                  threshold=thr)
                        if local_tc_result == "Failed":
                            tc_result = "Failed"
                        mrindex += 1
        # --------------------------------------------------------------------------------------------[120 characters]
        print_pm_counter_testcase_footer(tc_result)
    except Exception as e:
        logException("verify_pm_counters", e)
    return (tc_result.lower() == "passed")


def print_pm_counter_testcase_footer(tc_result, print_to_console=True):
    print_to_html_and_file("-" * 90)
    if print_to_console:
        print_pm_counter_testcase_result_to_console(tc_result)


def print_pm_counter_testcase_result_to_console(tc_result):
    if tc_result.lower() == 'passed':
        rbi.log_to_console(GREEN, no_newline=True)
    else:
        rbi.log_to_console(RED, no_newline=True)
    rbi.log_to_console(tc_result+RESET+"")


def print_pm_counter_testcase_header(qcTestCaseName, testcase_str, testcase_info=None):
    print_to_html_and_file("-" * 90)
    print_to_html_and_file("QC Test Case Name: %s" % qcTestCaseName)
    testcase_str = "(%s)" % str(testcase_str)
    if testcase_info is not None:
        print_to_html_and_file(str(testcase_info))
    print_to_html_and_file(testcase_str.ljust(15, '-') + '\n' + "PI ID".rjust(5) + "Expected".rjust(22)
                           + "Reported".rjust(15)
                           + "Verdict".rjust(15) + "Condition".rjust(15) +
                           " " + " ".ljust(15) + "PM Counter description".ljust(30))


def print_pm_counter_pid_result(pid, info, reported_value, expected_value, condition, condition_type, condition_info):
    result = "Passed" if condition else "Failed"
    print_to_html_and_file(str(pid).rjust(5) + str(expected_value).rjust(15) + str(reported_value).rjust(15) +
                           result.rjust(15) + condition_type.rjust(15) + " " + condition_info.ljust(15) + info)
    return result


def print_pm_counter_testcase_info_to_console(tc_name, cell_id=None, reporting_info=""):
    global pmcutDict
    pmcutDict = {}
    if cell_id:
        rbi.log_to_console(("\n  " + tc_name + ":   cell=" + str(cell_id)+"   " + str(reporting_info)).ljust(133),
                           no_newline=True)
    else:
        rbi.log_to_console(("\n  " + tc_name + ":   " + str(reporting_info)).ljust(133), no_newline=True)


def print_to_html_and_file(text):
    print(text)
    if pmResultFile is not None:
        pmResultFile.write(text+'\n')


def get_int_value(str_value, order_number=0):
    int_value = -1
    if str_value == "-1":
        int_value = -1
    elif str_value.startswith("ERR"):
        int_value = -1
    elif str_value.isdigit():
        int_value = int(str_value)
    elif "|" in str_value:
        int_value = int(str_value.split("|")[order_number])
        logging.info("get_int_value(): PMC value is NOT an Integer, but a list --> check XML report files!")
    else:
        logging.info("get_int_value(): PMC value has STRANGE format --> check XML report files! -- %s" % str_value)
    return int_value


def verify_within_threshold(pid, pm_info, reported_value, expected_value, threshold, pmcut=True, pmcut_attr="value"):
    expression = (abs(int(reported_value) - int(expected_value)) <= threshold) if int(reported_value) >= 0 else False
    result = print_pm_counter_pid_result(pid, pm_info, reported_value, expected_value,
                                         expression, "threshold", "~ %s" % threshold)
    return result


@log_begin_end_func_name
def verify_maxmcs_based_on_pmc(pmc_csv_file, column, cell, tc_name, max_mcs):
    are_pmc_correct = False
    # ------------------------------------------------------------------------------------------------[120 characters]
    try:
        piids_and_expected_values = {}
        for mcs in range(max_mcs+1, 29):
            piids_and_expected_values["M55366C010%s" % mcs] = 0
        logging.info("piids_and_expected_values = %s" % piids_and_expected_values)
        are_pmc_correct = verify_pm_counters(pmc_csv_file, column, cell,
                                             piids_and_expected_values, tc_name, threshold_percent=0)
    except Exception as e:
        logException("verify_maxmcs_based_on_pmc", e)
    return are_pmc_correct


# ====================================================================================================[120 characters]
#   Private Functions
# ====================================================================================================[120 characters]

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
