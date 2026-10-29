# ====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd68 for 5GC000425 Feature
# Team: 'SqdGp68'
# Email: 'I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging
import os
import csv
import json
import datetime
import re

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem


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
def prepare_for_pm_counter_testing():
    resultBaseDir = rbi.run_keyword("Get Test Suite Result Base Directory")
    logging.info("finalise_pm_counter_testing(): resultBaseDir = %s" % resultBaseDir)
    suiteName = rbi.get_variable_value("${SUITE_NAME}")
    logging.info("finalise_pm_counter_testing(): suiteName = %s" % suiteName)
    open_pm_results_summary_file(resultBaseDir)
    create_reporting_dictionary(suiteName)


@log_begin_end_func_name
def finalise_pm_counter_testing():
    resultBaseDir = rbi.run_keyword("Get Test Suite Result Base Directory")
    logging.info("finalise_pm_counter_testing(): resultBaseDir = %s" % resultBaseDir)
    close_pm_results_summary_file()
    save_reporting_dictionary(resultBaseDir)


# ====================================================================================================[120 characters]
#   Private Functions
# ====================================================================================================[120 characters]

@log_begin_end_func_name
def finalise_pm_counter_testing():
    resultBaseDir = rbi.run_keyword("Get Test Suite Result Base Directory")
    logging.info("finalise_pm_counter_testing(): resultBaseDir = %s" % resultBaseDir)
    close_pm_results_summary_file()
    save_reporting_dictionary(resultBaseDir)


@log_begin_end_func_name
def open_pm_results_summary_file(filedir, filename="pm_results_summary.log", filemode='w'):
    global pmResultFile
    if pmResultFile is None:
        filepath = os.path.join(filedir, filename)
        pmResultFile = open(filepath, filemode)
        logging.info("Opening pm_results_summary log file '%s' with mode=%s" %
                     (pmResultFile.name, pmResultFile.mode))
        if filemode == 'w':
            print_to_html_and_file("#" * 80)
            print_to_html_and_file("PM Counter summary results")
            print_to_html_and_file("(generated on %s)" % datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
            print_to_html_and_file("#" * 80)
    else:
        logging.info("Skip opening of pm_results_summary log "
                     "file because file is already opened (pmResultFile != None)", "WARN")


@log_begin_end_func_name
def close_pm_results_summary_file():
    global pmResultFile
    if pmResultFile is not None:
        logging.info("Closing pm_results_summary log file '%s' with mode=%s" %
                     (pmResultFile.name, pmResultFile.mode))
        pmResultFile.close()
        pmResultFile = None
    else:
        logging.info("Skip closing of pm_results_summary log "
                     "file because file is already closed (pmResultFile == None)", "WARN")


def print_to_html_and_file(text):
    print(text)
    if pmResultFile is not None:
        pmResultFile.write(text+'\n')


@log_begin_end_func_name
def print_pm_counter_test_scenario_header(ts_to_verify):
    print_to_html_and_file("\n")
    print_to_html_and_file("=" * 80)
    print_to_html_and_file("Verify_logs for '%s'" % ts_to_verify)
    print_to_html_and_file("=" * 80)
    print_to_html_and_file("")


def print_pm_counter_testcase_header(qcTestCaseName, testcase_str, testcase_info=None):
    print_to_html_and_file("-" * 90)
    print_to_html_and_file("QC Test Case Name: %s" % qcTestCaseName)
    testcase_str = "(%s)" % str(testcase_str)
    if testcase_info is not None:
        print_to_html_and_file(str(testcase_info))
    print_to_html_and_file(testcase_str.ljust(15) + "PI ID".rjust(5) + "Expected".rjust(15) + "Reported".rjust(15) +
                           "Verdict".rjust(15) + "Condition".rjust(15) +
                           " " + " ".ljust(15) + "PM Counter description".ljust(30))


def print_pm_counter_pid_result(pid, info, reported_value, expected_value, condition, condition_type, condition_info):
    result = "Passed" if condition else "Failed"
    print_to_html_and_file(str(pid).rjust(20) + str(expected_value).rjust(15) + str(reported_value).rjust(15) +
                           result.rjust(15) + condition_type.rjust(15) + " " + condition_info.ljust(15) + info)
    return result


@log_begin_end_func_name
def print_pm_counter_testcase_footer(tc_result, print_to_console=True):
    print_to_html_and_file("-" * 90)
    if print_to_console:
        print_pm_counter_testcase_result_to_console(tc_result)


@log_begin_end_func_name
def print_pm_counter_testcase_info_to_console(tc_name, cell_id=None, reporting_info=""):
    global pmcutDict
    pmcutDict = {}
    if cell_id:
        rbi.log_to_console(("\n  " + tc_name + ":   cell=" + str(cell_id)+"   " + str(reporting_info)).ljust(133),
                           no_newline=True)
    else:
        rbi.log_to_console(("\n  " + tc_name + ":   " + str(reporting_info)).ljust(133), no_newline=True)


@log_begin_end_func_name
def print_pm_counter_testcase_result_to_console(tc_result):
    if tc_result.lower() == 'passed':
        rbi.log_to_console(GREEN, no_newline=True)
    else:
        rbi.log_to_console(RED, no_newline=True)
    rbi.log_to_console(tc_result+RESET+"")


@log_begin_end_func_name
def search_for_failed_in_pmcut_dict(pmcut_dict=None):
    if pmcut_dict is None:
        global pmcutDict
        pmcut_dict = pmcutDict
    for pmName, pmDict in pmcut_dict.items():
        if pmDict["result"] == "Failed":
            return "Failed"
    return "Passed"


@log_begin_end_func_name
def add_tc_result_to_report_json_dict(tc_name, tc_result, pmcut_dict=None):
    global reportJsonDict
    if pmcut_dict is None:
        global pmcutDict
        pmcut_dict = pmcutDict
    logging.info("add testcase result to report JSON dict:\n" +
                 "tc_name=%s\n" % tc_name +
                 "tc_result=%s\n" % tc_result +
                 "pmcut_dict=%s\n" % pmcut_dict)
    try:
        for pmDict in reportJsonDict[tc_name]["pm_counters"]:
            pmName = pmDict["piid"]
            report_value = pmcut_dict[pmName]["value"] if pmcut_dict[pmName]["value"] != - \
                1 else pmcut_dict[pmName]["rtpm"]
            pmDict["value"] = report_value
            pmDict["result"] = pmcut_dict[pmName]["result"]
        reportJsonDict[tc_name]["result"] = tc_result
        logging.info("updating \"%s\" in reportJsonDict\n" % (tc_name))
    except Exception as e:
        logging.info("adding \"%s\" to reportJsonDict\n" % (tc_name))
        reportJsonDict[tc_name] = {"kpi_entries": [], "pm_counters": [], "result": ""}
        for pmName, pmDict in pmcut_dict.items():
            report_value = pmcut_dict[pmName]["value"] if pmcut_dict[pmName]["value"] != - \
                1 else pmcut_dict[pmName]["rtpm"]
            reportJsonDict[tc_name]["pm_counters"].append(
                {"piid": pmName, "result": pmDict["result"], "value": report_value})
        reportJsonDict[tc_name]["result"] = tc_result
    return reportJsonDict[tc_name]["pm_counters"]


@log_begin_end_func_name
def create_reporting_dictionary(suiteName):
    global reportJsonFileName
    global reportJsonDict
    reportJsonDict = {}
    reportJsonFileName = suiteName + "_results.json"


@log_begin_end_func_name
def save_reporting_dictionary(resultBaseDir):
    jsonResultFile = ""
    if reportJsonFileName:
        if reportJsonDict:
            sanityCheckOfReportJSON()
            logging.info("save_reporting_dictionary(): Final reportJsonDict:")
            logging.info(json.dumps(reportJsonDict, sort_keys=True, indent=4))
            jsonResultFile = os.path.join(resultBaseDir, reportJsonFileName)
            json.dump(reportJsonDict, open(jsonResultFile, 'w'), sort_keys=True, indent=4)
            suitePath = rbi.get_variable_value("${SUITE SOURCE}")
            sourceDir = suitePath[:suitePath.rfind('/')]
            OperatingSystem().copy_file(jsonResultFile,
                                        OperatingSystem().join_path(sourceDir, "reporting", reportJsonFileName))
    return jsonResultFile


def addToPmcutDict(pid, value=None, info=None, rtpm=None, result=None):
    global pmcutDict
    pid_format_regex = r"M([-+]?\d+).([-+]?\d+)"
    match_pid_format_ca = re.match(pid_format_regex+"[_.](.*)", pid)
    if match_pid_format_ca:
        if '_' in pid:
            new_pid = pid.split('_')[0]
        elif '.' in pid:
            new_pid = pid.split('.')[0]
        else:
            new_pid = pid
        logging.info("addToPmcutDict received pid='%s' and it will chaged it to '%s'" % (pid, new_pid))
        pid = new_pid
    match_pid_format = re.match(pid_format_regex+'$', pid)
    if match_pid_format:
        if pid in list(pmcutDict.keys()):
            action = 'Updating'
            if value is not None:
                pmcutDict[pid]["value"] = value
            if info is not None:
                pmcutDict[pid]["info"] = info
            if rtpm is not None:
                pmcutDict[pid]["rtpm"] = rtpm
            if result is not None and result.lower() != "failed":
                pmcutDict[pid]["result"] = result
        else:
            action = 'Creating'
            value = -1 if value is None else value
            info = "" if info is None else info
            rtpm = -1 if rtpm is None else rtpm
            result = "" if result is None else result
            pmcutDict[pid] = {"value": value, "info": info, "rtpm": rtpm, "result": result}
        logging.info("%s pmcut dict key='%s', value=%s, info=%s, rtpm=%s, result=%s" %
                     (action, pid, pmcutDict[pid]["value"], pmcutDict[pid]["info"],
                      pmcutDict[pid]["rtpm"], pmcutDict[pid]["result"]))


def verify_within_threshold(pid, pm_info, reported_value, expected_value, threshold, pmcut=True, pmcut_attr="value"):
    expression = (abs(int(reported_value) - int(expected_value)) <= threshold) if int(reported_value) >= 0 else False
    result = print_pm_counter_pid_result(pid, pm_info, reported_value, expected_value,
                                         expression, "threshold", "~ %s" % threshold)
    if pmcut and pid:
        kwargs = {"pid": pid, "info": pm_info, "result": result, str(pmcut_attr): reported_value}
        addToPmcutDict(**kwargs)
    return result


def verify_within_range(pid, pm_info, reported_value, expected_min_value,
                        expected_max_value, pmcut=True, pmcut_attr="value"):
    expression = (int(reported_value) >= int(expected_min_value) and int(reported_value)
                  <= int(expected_max_value)) if int(reported_value) >= 0 else False
    min_str = ("%s" % expected_min_value) if int(expected_min_value) < 1e6 else "%.1E" % expected_min_value
    max_str = ("%s" % expected_max_value) if int(expected_max_value) < 1e6 else "%.1E" % expected_max_value
    range_str = "[%s, %s]" % (min_str, max_str)
    result = print_pm_counter_pid_result(pid, pm_info, reported_value, range_str,
                                         expression, "range (min", "<= x <=max)")
    if pmcut:
        kwargs = {"pid": pid, "info": pm_info, "result": result, str(pmcut_attr): reported_value}
        addToPmcutDict(**kwargs)
    return result


def verify_is_equal(pid, pm_info, reported_value, expected_value, pmcut=True, pmcut_attr="value"):
    expression = (int(reported_value) == int(expected_value)) if (int(reported_value) >= 0 or
                                                                  int(expected_value) < 0) else False
    result = print_pm_counter_pid_result(pid, pm_info, reported_value, expected_value,
                                         expression, "is equal", "== %s" % expected_value)
    if pmcut:
        kwargs = {"pid": pid, "info": pm_info, "result": result, str(pmcut_attr): reported_value}
        addToPmcutDict(**kwargs)
    return result


def verify_is_lower(pid, pm_info, reported_value, expected_value, pmcut=True, pmcut_attr="value"):
    expression = (int(reported_value) <= int(expected_value)) if int(reported_value) >= 0 else False
    result = print_pm_counter_pid_result(pid, pm_info, reported_value, expected_value,
                                         expression, "is lower", "<= %s" % expected_value)
    if pmcut:
        kwargs = {"pid": pid, "info": pm_info, "result": result, str(pmcut_attr): reported_value}
        addToPmcutDict(**kwargs)
    return result


def verify_is_greater(pid, pm_info, reported_value, expected_value, pmcut=True, pmcut_attr="value"):
    expression = (int(reported_value) >= int(expected_value)) if int(reported_value) >= 0 else False
    result = print_pm_counter_pid_result(pid, pm_info, reported_value, expected_value,
                                         expression, "is greater", ">= %s" % expected_value)
    if pmcut:
        kwargs = {"pid": pid, "info": pm_info, "result": result, str(pmcut_attr): reported_value}
        addToPmcutDict(**kwargs)
    return result


def verify_percentage_within_threshold(pid, pm_info, reported_value, expected_value, threshold,
                                       pmcut=True, pmcut_attr="value"):
    expression = (abs(float(reported_value) * 100.0 / float(expected_value) - 100.0)
                  <= threshold) if int(reported_value) >= 0 else False
    result = print_pm_counter_pid_result(pid, pm_info, reported_value, expected_value,
                                         expression, "%% threshold", "~ %s" % expected_value)
    if pmcut:
        kwargs = {"pid": pid, "info": pm_info, "result": result, str(pmcut_attr): reported_value}
        addToPmcutDict(**kwargs)
    return result


@log_begin_end_func_name
def sanityCheckOfReportJSON():
    global reportJsonDict
    lisOfBadTestCases = []
    for testCase in reportJsonDict:
        testCaseDict = reportJsonDict[testCase]
        for pmCounter in testCaseDict["pm_counters"]:
            if pmCounter["value"] < 0:
                lisOfBadTestCases.append(testCase)
                break
    if lisOfBadTestCases:
        logging.info("sanityCheckOfReportJSON(): lisOfBadTestCases = %s" % lisOfBadTestCases, "WARN")
    for badTestCase in lisOfBadTestCases:
        del reportJsonDict[badTestCase]


@log_begin_end_func_name
def convertRangeStringToListOfStrings(rangeList):
    commonPrefix = os.path.commonprefix(rangeList)
    logging.info("convertRangeStringToListOfStrings(): commonPrefix = %s" % commonPrefix)
    startString = rangeList[0].replace(commonPrefix, '')
    logging.info("convertRangeStringToListOfStrings(): startString = %s" % startString)
    finishString = rangeList[1].replace(commonPrefix, '')
    logging.info("convertRangeStringToListOfStrings(): finishString = %s" % finishString)
    outputList = range(int(startString), int(finishString)+1)
    logging.info("convertRangeStringToListOfStrings(): outputList = %s" % outputList)
    numOfDigits = len(startString)
    logging.info("convertRangeStringToListOfStrings(): numOfDigits = %s" % numOfDigits)
    if numOfDigits == 1:
        outputList = ['%s%01d' % (commonPrefix, element) for element in outputList]
    elif numOfDigits == 2:
        outputList = ['%s%02d' % (commonPrefix, element) for element in outputList]
    elif numOfDigits == 3:
        outputList = ['%s%03d' % (commonPrefix, element) for element in outputList]
    elif numOfDigits == 4:
        outputList = ['%s%04d' % (commonPrefix, element) for element in outputList]
    else:
        outputList = ['%s%s' % (commonPrefix, element) for element in outputList]
    return outputList
