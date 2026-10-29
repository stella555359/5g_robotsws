import os
import yaml
import json
import inspect
import platform
import logging
from taf.sw.reporting_portal import reporting_portal
from datetime import datetime


# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

rbi = BuiltIn()
trunkSwBuildStr = "SBTS00_ENB_999"


def construct_sw_build_from(gnbSwVersion, enbSwVersion, resultDir=""):
    logging.info("construct_testline_from(): gnbSwVersion = %s" % gnbSwVersion)
    logging.info("construct_testline_from(): enbSwVersion = %s" % enbSwVersion)
    logging.info("construct_testline_from(): resultDir = %s" % resultDir)
    try:
        if resultDir:
            for element in resultDir.split("/"):
                if element.startswith("5G") and not element.startswith("5GC"):
                    gnbSwVersion = element
                    logging.info(
                        "construct_sw_build_from(): gnbSwVersion = %s (NEW)" % gnbSwVersion)
                    break
    except Exception as e:
        logException("construct_sw_build_from", e)
    return gnbSwVersion + ";" + enbSwVersion if enbSwVersion else gnbSwVersion


def construct_testline_from(resultDir=""):
    logging.info("construct_testline_from(): resultDir = %s" % resultDir)
    testLine = ""
    try:
        if not resultDir:
            resultDir = rbi.run_keyword("Get Testcase Log Directory")
        for element in resultDir.split("/"):
            if element.startswith("7_"):
                testLine = element
            elif element.startswith("TL"):
                testLine = "7_15_" + element
    except Exception as e:
        logException("construct_testline_from", e, silent=True)
    if not testLine:
        try:
            testLine = rbi.run_keyword("Get Testline Name")
        except Exception as e:
            logException("construct_testline_from", e, silent=True)
            testLine = platform.node().replace("-", "_")
            testLine = "".join(testLine.rsplit("_0", 1)
                               ) if testLine.endswith("_0") else testLine
            testLine = "".join(testLine.rsplit("_1", 1)
                               ) if testLine.endswith("_1") else testLine
            testLine = "".join(testLine.rsplit("_2", 1)
                               ) if testLine.endswith("_2") else testLine
    logging.info("construct_testline_from(): testLine = %s" % testLine)
    return testLine


def get_info_from_qc_file(resultDir="", qcFilePath="", gnbSwVersion="", tcName="", swPostFix=""):
    outputList = []
    try:
        qcInfoFilePath = find_qc_file(resultDir, qcFilePath)
        outputList = get_qc_info_list(
            qcInfoFilePath, gnbSwVersion, tcName, swPostFix)
    except Exception as e:
        logException("get_info_from_qc_file", e)
    return outputList


def find_qc_file(resultDir="", qcFilePath=""):
    logging.info("find_qc_file(): resultDir = %s" % resultDir)
    logging.info("find_qc_file(): qcFilePath = %s" % qcFilePath)
    qcInfoFilePath = ""
    try:
        suiteDir = rbi.get_variable_value("${SUITE SOURCE}")
        logging.info("find_qc_file(): suiteDir = %s" % suiteDir)
        # ---------------------------------------------------------------------------------------------[120 characters]
        if qcFilePath:
            qcInfoFilePath = suiteDir[:suiteDir.rfind(
                "/testsuite/")] + "/" + qcFilePath
        logging.info(
            "find_qc_file(): [Option 1] qcInfoFilePath = %s" % qcInfoFilePath)
        if os.path.isfile(qcInfoFilePath):
            logging.info("find_qc_file(): .qc file exists")
            return qcInfoFilePath
        else:
            logging.info(
                "find_qc_file(): .qc file NOT found yet, search further")
        # ---------------------------------------------------------------------------------------------[120 characters]
        for frame in inspect.stack():
            if "testsuite/" in frame[1]:
                qcInfoFilePath = frame[1].replace(
                    ".py", ".qc").replace(".robot", ".qc")
                break
        else:
            qcInfoFilePath = __file__.replace(".pyc", ".py").replace(
                ".py", ".qc").replace(".robot", ".qc")
        logging.info(
            "find_qc_file(): [Option 2] qcInfoFilePath = %s" % qcInfoFilePath)
        if os.path.isfile(qcInfoFilePath):
            logging.info("find_qc_file(): .qc file exists")
            return qcInfoFilePath
        else:
            logging.info(
                "find_qc_file(): .qc file NOT found yet, search further")
        # ---------------------------------------------------------------------------------------------[120 characters]
        qcInfoFilePath = suiteDir.replace(".robot", ".qc")
        logging.info(
            "find_qc_file(): [Option 3] qcInfoFilePath = %s" % qcInfoFilePath)
        if os.path.isfile(qcInfoFilePath):
            logging.info("find_qc_file(): .qc file exists")
            return qcInfoFilePath
        else:
            logging.info(
                "find_qc_file(): .qc file NOT found yet, search further")
        # ---------------------------------------------------------------------------------------------[120 characters]
        splitSuiteDir = suiteDir.split("/")
        qcInfoFileName = splitSuiteDir[-1].replace("-", "_").replace(".", "_").split("_")[0] + ".qc"
        qcInfoFilePath = "/".join(splitSuiteDir[0:-1]) + "/" + qcInfoFileName
        logging.info(
            "find_qc_file(): [Option 4] qcInfoFilePath = %s" % qcInfoFilePath)
        if os.path.isfile(qcInfoFilePath):
            logging.info("find_qc_file(): .qc file exists")
            return qcInfoFilePath
        else:
            logging.info(
                "find_qc_file(): .qc file NOT found yet, search further")
        # ---------------------------------------------------------------------------------------------[120 characters]
        splitSuiteDir = suiteDir.split("/")
        qcInfoFileName = splitSuiteDir[-1].replace("-", "_").replace(".", "_").split("_")[0] + ".qc"
        qcInfoFilePath = "/".join(splitSuiteDir[0:-2]) + "/" + qcInfoFileName
        logging.info(
            "find_qc_file(): [Option 5] qcInfoFilePath = %s" % qcInfoFilePath)
        if os.path.isfile(qcInfoFilePath):
            logging.info("find_qc_file(): .qc file exists")
            return qcInfoFilePath
        else:
            logging.info(
                "find_qc_file(): .qc file NOT found yet, search further")
        # ---------------------------------------------------------------------------------------------[120 characters]
        splitSuiteDir = suiteDir.split("/")
        qcInfoFileName = splitSuiteDir[-1].replace("-", "_").replace(".", "_").split("_")[0] + ".qc"
        qcInfoFilePath = "/".join(splitSuiteDir[0:-3]) + "/" + qcInfoFileName
        logging.info(
            "find_qc_file(): [Option 6] qcInfoFilePath = %s" % qcInfoFilePath)
        if os.path.isfile(qcInfoFilePath):
            logging.info("find_qc_file(): .qc file exists")
            return qcInfoFilePath
    except Exception as e:
        logException("find_qc_file", e)
    logging.info(
        "find_qc_file(): .qc file was NOT found, please check the repository!")
    return qcInfoFilePath


def get_gnb_sw_build_version(gnbId, resultDir=""):
    logging.info("get_gnb_sw_build_version(): gnbId = %s" % gnbId)
    logging.info("get_gnb_sw_build_version(): resultDir = %s" % resultDir)
    gnbSwVersion = ""
    try:
        if resultDir:
            for element in resultDir.split("/"):
                if element.startswith("5G") and not element.startswith("5GC"):
                    gnbSwVersion = element
                    break
                if element.startswith("SBTS"):
                    gnbSwVersion = element
                    break
        if not gnbSwVersion:
            gnbSwVersion = rbi.run_keyword(
                "Get gNB SW version", "gnb_id=%s" % gnbId)
        logging.info("get_gnb_sw_build_version(): gnbSwVersion = %s" %
                     gnbSwVersion)
    except Exception as e:
        logException("get_gnb_sw_build_version", e)
    logging.info("get_gnb_sw_build_version(): gnbSwVersion = %s" %
                 gnbSwVersion)
    return gnbSwVersion


def get_qc_info_list(qcInfoFilePath, gnbSwVersion, tcName="", swPostFix=""):
    logging.info("get_qc_info_list(): qcInfoFilePath = %s" % qcInfoFilePath)
    logging.info("get_qc_info_list(): gnbSwVersion = %s" % gnbSwVersion)
    logging.info("get_qc_info_list(): tcName = %s" % tcName)
    logging.info("get_qc_info_list(): swPostFix = %s" % swPostFix)
    global global_qc_domain
    global global_qc_project
    global_qc_domain, global_qc_project = "MN_5G", "5G"
    qc_testlab_path, qc_test_set_name = "", ""
    logging.info("get_qc_info_list(): trunkSwBuildStr = %s" % trunkSwBuildStr)
    try:
        with open(qcInfoFilePath, "rb") as jsonFile:
            qcInfo = json.load(jsonFile)
            for qcInfoKey in sorted(list(qcInfo.keys()), reverse=True):
                logging.info("get_qc_info_list(): qcInfoKey = %s" % qcInfoKey)
                if "@" in qcInfoKey:
                    swBuild = qcInfoKey.split("@")[0]
                    postfix = qcInfoKey.split("@")[1]
                else:
                    swBuild = qcInfoKey
                    postfix = ""
                swBuild = "".join(swBuild.rsplit(".*", 1)
                                  ) if swBuild.endswith(".*") else swBuild
                swBuild = "".join(swBuild.rsplit(
                    "*", 1)) if swBuild.endswith("*") else swBuild
                swBuild = "".join(swBuild.rsplit(
                    ".", 1)) if swBuild.endswith(".") else swBuild
                logging.info("get_qc_info_list(): swBuild = %s" % swBuild)
                logging.info("get_qc_info_list(): gnbSwVersion = %s" %
                             gnbSwVersion)
                logging.info("get_qc_info_list(): swPostFix = %s" % swPostFix)
                logging.info("get_qc_info_list(): postfix = %s" % postfix)
                if swBuild in trunkSwBuildStr and "TRUNK" in list(qcInfo.keys()):
                    continue
                doesPostfixMatch = swPostFix == postfix
                doesSwMatch = swBuild in gnbSwVersion
                doesTrunkSwMatch = (
                    trunkSwBuildStr in gnbSwVersion and swBuild == "TRUNK")
                if (doesTrunkSwMatch or doesSwMatch) and doesPostfixMatch:
                    if "qc_domain" in list(qcInfo[qcInfoKey].keys()):
                        global_qc_domain = qcInfo[qcInfoKey]["qc_domain"]
                        qcInfo[qcInfoKey].pop("qc_domain")
                    if "qc_project" in list(qcInfo[qcInfoKey].keys()):
                        global_qc_project = qcInfo[qcInfoKey]["qc_project"]
                        qcInfo[qcInfoKey].pop("qc_project")
                    if "label" in list(qcInfo[qcInfoKey].keys()):
                        label = qcInfo[qcInfoKey]["label"].lower()
                        if label == "syve":
                            global_qc_domain = "MN_RAN"
                            global_qc_project = "RAN_SyVe"
                        elif label == ".*":
                            pass
                        else:
                            global_qc_domain = "MN_RAN"
                            global_qc_project = "RAN_ET"
                        qcInfo[qcInfoKey].pop("label")
                    qc_testlab_path = list(qcInfo[qcInfoKey].keys())[0]
                    listOfQcTestSets = list(
                        qcInfo[qcInfoKey][qc_testlab_path].keys())
                    if len(listOfQcTestSets) > 1:
                        for qcTestSet in listOfQcTestSets:
                            listOfQcTestInstancies = qcInfo[qcInfoKey][qc_testlab_path][qcTestSet]
                            if any(tcName in TI for TI in listOfQcTestInstancies):
                                qc_test_set_name = qcTestSet
                                break
                    else:
                        qc_test_set_name = listOfQcTestSets[0]
                    break
    except Exception as e:
        logException("get_qc_info_list", e)
    logging.info("get_qc_info_list(): qc_testlab_path = %s" % qc_testlab_path)
    logging.info("get_qc_info_list(): qc_test_set_name = %s" %
                 qc_test_set_name)
    return [qc_testlab_path, qc_test_set_name]


def report_results_to_rep(tcName, swBuild, testLine, suitePath,
                          qcTestlabPath="", qcTestSetName="",
                          qc_domain=None, qc_project=None, qc_id=None,
                          customers=None, ca=None, organization=None, location=None,
                          tsResult=None, pmCounters="", featuresCovered="", rfsw_build="",
                          isForDebugging="no", tc_execution_id="0815", kpi_results="", links={}):
    uteRP = reporting_portal()
    if isinstance(pmCounters, str):
        counter_results = yaml.load(pmCounters, Loader=yaml.FullLoader) if pmCounters else []
    logging.info("reportResultsToRP(): counter_results = %s" % counter_results)
    if isinstance(kpi_results, str):
        kpi_results = yaml.load(kpi_results, Loader=yaml.FullLoader) if kpi_results else []
    logging.info("reportResultsToRP(): kpi_results = %s" % kpi_results)
    if isinstance(featuresCovered, str):
        features_covered = yaml.load(featuresCovered, Loader=yaml.FullLoader) if featuresCovered else []
    logging.info("reportResultsToRP(): features_covered = %s" % features_covered)
    # if qc_domain, qc_project not given in arguments use the global variables legacy compatibility
    if qc_domain is None:
        qc_domain = global_qc_domain
        logging.info("reportResultsToRP(): global_qc_domain = %s" %
                     global_qc_domain)
    if qc_project is None:
        qc_project = global_qc_project
        logging.info("reportResultsToRP(): global_qc_project = %s" %
                     global_qc_project)
    result = convert_result_to_qc_notation(tsResult)
    try:
        if not (str(isForDebugging).lower() == "yes" or str(isForDebugging).lower() == "true"):
            uteRP.report_to_rp(name=tcName,
                               qc_test_instance_name=tcName,
                               tc_execution_id=tc_execution_id,
                               result=result,
                               links=links,
                               add_info=["UTE", "TAF"],
                               build=swBuild,
                               cu_build="",
                               suite_path=suitePath,
                               tool="Robot",
                               hw_id="",
                               username="",
                               ca=ca,
                               organization=organization,
                               location=location,
                               features_covered=featuresCovered,
                               customers=customers,
                               qc_test_set_name=qcTestSetName,
                               qc_testlab_path=qcTestlabPath,
                               qc_domain=qc_domain,
                               qc_project=qc_project,
                               qc_id=qc_id,
                               counter_results=counter_results,
                               kpi_results=kpi_results,
                               rfsw_build=rfsw_build,
                               testline=testLine,
                               endtime=datetime.utcnow().strftime('%Y%m%d %H:%M:%S.%f')[:-3],
                               starttime=datetime.utcnow().strftime('%Y%m%d %H:%M:%S.%f')[:-3])
            rbi.sleep("18s")
        else:
            logging.info("reportResultsToRP(): =============================================================")
            logging.info("reportResultsToRP(): name = %s" % tcName)
            logging.info("reportResultsToRP(): result = %s" % result)
            logging.info("reportResultsToRP(): build = %s" % swBuild)
            logging.info("reportResultsToRP(): ca = %s" % ca)
            logging.info("reportResultsToRP(): organization = %s" % organization)
            logging.info("reportResultsToRP(): location = %s" % location)
            logging.info("reportResultsToRP(): suite_path = %s" % suitePath)
            logging.info("reportResultsToRP(): customers = %s" % customers)
            logging.info("reportResultsToRP(): qc_domain = %s" % qc_domain)
            logging.info("reportResultsToRP(): qc_project = %s" % qc_project)
            logging.info("reportResultsToRP(): qc_id = %s" % qc_id)
            logging.info("reportResultsToRP(): qc_test_set_name = %s" % qcTestSetName)
            logging.info("reportResultsToRP(): qc_testlab_path = %s" % qcTestlabPath)
            logging.info("reportResultsToRP(): counter_results = %s" % counter_results)
            logging.info("reportResultsToRP(): =============================================================")
    except Exception as e:
        logException("report_results_to_rep", e)


def convert_result_to_qc_notation(tsResult):
    if tsResult is None:
        tsResult = rbi.get_variable_value("${TEST STATUS}")
    logging.info("convert_result_to_qc_notation(): tsResult = %s" % tsResult)
    result = str(tsResult).lower()
    if result in ["passed", "pass", "true", "yes"]:
        result = "passed"
    elif result in ["failed", "fail", "false", "not"]:
        result = "failed"
    logging.info("convert_result_to_qc_notation(): result = %s" % result)
    return result


def get_enb_sw_version_if_enb_is_present(enbId):
    statusStr, returnStr = rbi.run_keyword_and_ignore_error(
        "get eNB SW Version", "enb_id=%s" % enbId)
    logging.info(
        "get_enb_sw_version_if_enb_is_present(): statusStr = %s" % statusStr)
    logging.info(
        "get_enb_sw_version_if_enb_is_present(): returnStr = %s" % returnStr)
    return (returnStr if statusStr == "PASS" else "")


def logException(functionNameStr, e, silent=False):
    logging.info("%s(): Exception = <%s>" % (functionNameStr, str(e)))
    if not silent:
        rbi.log_to_console(
            "  %s: exception happend (see log.html)" % functionNameStr)
