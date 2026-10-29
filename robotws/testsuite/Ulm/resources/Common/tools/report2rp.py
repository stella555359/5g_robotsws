import re
import sys
from csv import DictReader
import os
from taf.sw.reporting_portal import reporting_portal
from datetime import datetime


def get_dict_from(csvFileName):
    outputListOfDicts = []
    with open(csvFileName, 'r') as read_obj:
        csv_dict_reader = DictReader(read_obj, delimiter=';')
        for row in csv_dict_reader:
            outputListOfDicts.append(row)
    return outputListOfDicts


def report2rp(csvFileName):
    print("============================== Begin report2rp()")
    uteRP = reporting_portal()
    try:
        for reportTestCasesDict in get_dict_from(csvFileName):
            if reportTestCasesDict["To be reported?"] == "1":
                print("----------------------------------------------------------")
                print("To be reported? = %s" % reportTestCasesDict["To be reported?"])
                print("Test Case Name = %s" % reportTestCasesDict["TC Name"])
                print("Test Case execution id = %s" % reportTestCasesDict["tc execution id"])
                print("CIT/CRT = %s" % reportTestCasesDict["CIT/CRT"])
                print("Result = %s" % reportTestCasesDict["Result"])
                print("Build = %s" % reportTestCasesDict["Build"])
                print("TestLine = %s" % reportTestCasesDict["TL"])
                print("TestLine Type = %s" % reportTestCasesDict["TL-Type"])
                print("Logs = %s" % reportTestCasesDict["logpath"])
                print("QC ID = %s" % reportTestCasesDict["QC-ID"])
                print("QC Test Set Name = %s" % reportTestCasesDict["QC Test Set Name"])
                print("QC Testlab Path = %s" % reportTestCasesDict["QC Testlab Path"])
                print("Test Suite Path = %s" % reportTestCasesDict["Test Suite Path"])
                print("Feature = %s" % reportTestCasesDict["Feature"])
                print("qc_domain = %s" % reportTestCasesDict["QC Dom"])
                print("qc_project = %s" % reportTestCasesDict["QC Proj"])
                endtime = datetime.utcnow().strftime('%Y%m%d %H:%M:%S.%f')[:-3]
                starttime = datetime.utcnow().strftime('%Y%m%d %H:%M:%S.%f')[:-3]
                print("reportResultsToRP(): endtime = %s" % endtime)
                print("reportResultsToRP(): starttime = %s" % starttime)
                if True:
                    return uteRP.report_to_rp(
                           name=reportTestCasesDict["TC Name"],
                           qc_test_instance_name=reportTestCasesDict["TC Name"],
                           tc_execution_id=reportTestCasesDict["tc execution id"],
                           result=reportTestCasesDict["Result"],
                           links={"Test logs": reportTestCasesDict["logpath"]},
                           ca="",
                           add_info=["UTE", "TAF"],
                           build=reportTestCasesDict["Build"],
                           suite_path=reportTestCasesDict["Test Suite Path"],
                           tool="Robot",
                           hw_id="",
                           username="",
                           features_covered=reportTestCasesDict["Feature"],
                           qc_test_set_name=reportTestCasesDict["QC Test Set Name"],
                           qc_testlab_path=reportTestCasesDict["QC Testlab Path"],
                           qc_domain=reportTestCasesDict["QC Dom"],
                           qc_project=reportTestCasesDict["QC Proj"],
                           qc_id=reportTestCasesDict["QC-ID"],
                           counter_results=[],
                           kpi_results=[],
                           testline=reportTestCasesDict["TL"],
                           label=reportTestCasesDict["TL-Type"],
                           endtime=endtime,
                           starttime=starttime)
    except Exception as e:
        print("report: %s" % str(e))
    print("============================== End report2rp()")
