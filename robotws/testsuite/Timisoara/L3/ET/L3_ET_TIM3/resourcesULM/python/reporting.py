import os
import yaml
import json
import inspect
import platform
import logging
from ute_reporting_portal import ute_reporting_portal
from datetime import datetime

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

rbi = BuiltIn()
trunkSwBuildStr = "SBTS00_ENB_999"


# ====================================================================================================[120 characters]
#   Python Helper Keywords
# ====================================================================================================[120 characters]

def log_begin_end_func_name(fn):
    def inner(*args, **kwargs):
        logging.info("============================== Begin Function {0}".format(fn.__name__))
        func_return = fn(*args, **kwargs)
        logging.info("============================== End Function {0}".format(fn.__name__))
        return func_return
    return inner


@log_begin_end_func_name
def construct_sw_build_from(gnbSwVersion, enbSwVersion, resultDir=""):
    logging.info("construct_testline_from(): gnbSwVersion = %s" % gnbSwVersion)
    logging.info("construct_testline_from(): enbSwVersion = %s" % enbSwVersion)
    logging.info("construct_testline_from(): resultDir = %s" % resultDir)
    try:
        if resultDir:
            for element in resultDir.split("/"):
                if element.startswith("5G") and not element.startswith("5GC"):
                    gnbSwVersion = element
                    logging.info("construct_sw_build_from(): gnbSwVersion = %s (NEW)" % gnbSwVersion)
                    break
    except Exception as e:
        logException("construct_sw_build_from", e)
    return gnbSwVersion + ";" + enbSwVersion if enbSwVersion else gnbSwVersion


@log_begin_end_func_name
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
            testLine = "".join(testLine.rsplit("_0", 1)) if testLine.endswith("_0") else testLine
            testLine = "".join(testLine.rsplit("_1", 1)) if testLine.endswith("_1") else testLine
            testLine = "".join(testLine.rsplit("_2", 1)) if testLine.endswith("_2") else testLine
    logging.info("construct_testline_from(): testLine = %s" % testLine)
    return testLine


def get_info_from_qc_file(resultDir="", qcFilePath="", gnbSwVersion="", tcName="", swPostFix=""):
    outputList = []
    try:
        qcInfoFilePath = find_qc_file(resultDir, qcFilePath)
        outputList = get_qc_info_list(qcInfoFilePath, gnbSwVersion, tcName, swPostFix)
    except Exception as e:
        logException("get_info_from_qc_file", e)
    return outputList


@log_begin_end_func_name
def find_qc_file(resultDir="", qcFilePath=""):
    logging.info("find_qc_file(): resultDir = %s" % resultDir)
    logging.info("find_qc_file(): qcFilePath = %s" % qcFilePath)
    qcInfoFilePath = ""
    try:
        suiteDir = rbi.get_variable_value("${SUITE SOURCE}")
        logging.info("find_qc_file(): suiteDir = %s" % suiteDir)
        # ---------------------------------------------------------------------------------------------[120 characters]
        if qcFilePath:
            qcInfoFilePath = suiteDir[:suiteDir.rfind("/testsuite/")] + "/" + qcFilePath
        logging.info("find_qc_file(): [Option 1] qcInfoFilePath = %s" % qcInfoFilePath)
        if os.path.isfile(qcInfoFilePath):
            logging.info("find_qc_file(): .qc file exists")
            return qcInfoFilePath
        else:
            logging.info("find_qc_file(): .qc file NOT found yet, search further")
        # ---------------------------------------------------------------------------------------------[120 characters]
        for frame in inspect.stack():
            if "testsuite/" in frame[1]:
                qcInfoFilePath = frame[1].replace(".py", ".qc").replace(".robot", ".qc")
                break
        else:
            qcInfoFilePath = __file__.replace(".pyc", ".py").replace(".py", ".qc").replace(".robot", ".qc")
        logging.info("find_qc_file(): [Option 2] qcInfoFilePath = %s" % qcInfoFilePath)
        if os.path.isfile(qcInfoFilePath):
            logging.info("find_qc_file(): .qc file exists")
            return qcInfoFilePath
        else:
            logging.info("find_qc_file(): .qc file NOT found yet, search further")
        # ---------------------------------------------------------------------------------------------[120 characters]
        qcInfoFilePath = suiteDir.replace(".robot", ".qc")
        logging.info("find_qc_file(): [Option 3] qcInfoFilePath = %s" % qcInfoFilePath)
        if os.path.isfile(qcInfoFilePath):
            logging.info("find_qc_file(): .qc file exists")
            return qcInfoFilePath
        else:
            logging.info("find_qc_file(): .qc file NOT found yet, search further")
        # ---------------------------------------------------------------------------------------------[120 characters]
        qcInfoFilePath = suiteDir.replace("-", "_").split("_")[0] + ".qc"
        logging.info("find_qc_file(): [Option 4] qcInfoFilePath = %s" % qcInfoFilePath)
        if os.path.isfile(qcInfoFilePath):
            logging.info("find_qc_file(): .qc file exists")
            return qcInfoFilePath
        else:
            logging.info("find_qc_file(): .qc file NOT found yet, search further")
        # ---------------------------------------------------------------------------------------------[120 characters]
        qcInfoFilePath = suiteDir.replace("-", "_").split("_")[0] + ".qc"
        splitPath = qcInfoFilePath.split("/")
        qcInfoFilePath = "/".join(splitPath[0:-2]) + "/" + splitPath[-1]
        logging.info("find_qc_file(): [Option 5] qcInfoFilePath = %s" % qcInfoFilePath)
        if os.path.isfile(qcInfoFilePath):
            logging.info("find_qc_file(): .qc file exists")
            return qcInfoFilePath
    except Exception as e:
        logException("find_qc_file", e)
    logging.info("find_qc_file(): .qc file were NOT found, please check the repository!")
    return qcInfoFilePath


@log_begin_end_func_name
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
            gnbSwVersion = rbi.run_keyword("Get gNB SW version", "gnb_id=%s" % gnbId)
        logging.info("get_gnb_sw_build_version(): gnbSwVersion = %s" % gnbSwVersion)
    except Exception as e:
        logException("get_gnb_sw_build_version", e)
    logging.info("get_gnb_sw_build_version(): gnbSwVersion = %s" % gnbSwVersion)
    return gnbSwVersion


@log_begin_end_func_name
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
                swBuild = "".join(swBuild.rsplit(".*", 1)) if swBuild.endswith(".*") else swBuild
                swBuild = "".join(swBuild.rsplit("*", 1)) if swBuild.endswith("*") else swBuild
                swBuild = "".join(swBuild.rsplit(".", 1)) if swBuild.endswith(".") else swBuild
                logging.info("get_qc_info_list(): swBuild = %s" % swBuild)
                logging.info("get_qc_info_list(): gnbSwVersion = %s" % gnbSwVersion)
                logging.info("get_qc_info_list(): swPostFix = %s" % swPostFix)
                logging.info("get_qc_info_list(): postfix = %s" % postfix)
                if swBuild in trunkSwBuildStr and "TRUNK" in list(qcInfo.keys()):
                    continue
                doesPostfixMatch = swPostFix == postfix
                doesSwMatch = swBuild in gnbSwVersion
                doesTrunkSwMatch = (trunkSwBuildStr in gnbSwVersion and swBuild == "TRUNK")
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
                    listOfQcTestSets = list(qcInfo[qcInfoKey][qc_testlab_path].keys())
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
    logging.info("get_qc_info_list(): qc_test_set_name = %s" % qc_test_set_name)
    return [qc_testlab_path, qc_test_set_name]


@log_begin_end_func_name
def report_results_to_rep(tcName, swBuild, testLine, suitePath, qcTestlabPath,
                          qcTestSetName, tsResult=None, pmCounters="", featuresCovered="", isForDebugging="no"):
    uteRP = ute_reporting_portal()
    counter_results = yaml.load(pmCounters, Loader=yaml.FullLoader) if pmCounters else []
    logging.info("reportResultsToRP(): counter_results = %s" % counter_results)
    features_covered = yaml.load(featuresCovered, Loader=yaml.FullLoader) if featuresCovered else []
    logging.info("reportResultsToRP(): features_covered = %s" % features_covered)
    logging.info("reportResultsToRP(): global_qc_domain = %s" % global_qc_domain)
    logging.info("reportResultsToRP(): global_qc_project = %s" % global_qc_project)
    swBuild, cuSwBuild = extract_cuswbuild_if_needed_from(swBuild)
    result = convert_result_to_qc_notation(tsResult)
    try:
        if not (str(isForDebugging).lower() == "yes" or str(isForDebugging).lower() == "true"):
            uteRP.report_to_rp(name=tcName,
                               qc_test_instance_name=tcName,
                               result=result,
                               links={},
                               ca="",
                               add_info=["UTE", "TAF"],
                               build=swBuild,
                               cu_build=cuSwBuild,
                               suite_path=suitePath,
                               tool="Robot",
                               hw_id="",
                               username="",
                               features_covered=featuresCovered,
                               qc_test_set_name=qcTestSetName,
                               qc_testlab_path=qcTestlabPath,
                               qc_domain=global_qc_domain,
                               qc_project=global_qc_project,
                               qc_id=None,
                               counter_results=counter_results,
                               kpi_results=[],
                               testline=testLine,
                               endtime=datetime.utcnow().strftime('%Y%m%d %H:%M:%S.%f')[:-3],
                               starttime=datetime.utcnow().strftime('%Y%m%d %H:%M:%S.%f')[:-3])
            rbi.sleep("18s")
        else:
            logging.info("reportResultsToRP(): =============================================================")
            logging.info("reportResultsToRP(): name = %s" % tcName)
            logging.info("reportResultsToRP(): result = %s" % result)
            logging.info("reportResultsToRP(): build = %s" % swBuild)
            logging.info("reportResultsToRP(): cu_build = %s" % cuSwBuild)
            logging.info("reportResultsToRP(): suite_path = %s" % suitePath)
            logging.info("reportResultsToRP(): qc_test_set_name = %s" % qcTestSetName)
            logging.info("reportResultsToRP(): qc_testlab_path = %s" % qcTestlabPath)
            logging.info("reportResultsToRP(): counter_results = %s" % counter_results)
            logging.info("reportResultsToRP(): =============================================================")
    except Exception as e:
        logException("report_results_to_rep", e)


@log_begin_end_func_name
def extract_cuswbuild_if_needed_from(swBuild):
    logging.info("extract_cuswbuild_if_needed_from(): swBuild = %s" % swBuild)
    duSwBuild = swBuild
    cuSwBuild = ""
    if swBuild.startswith("vCUCNF"):
        splited_sw_build = swBuild.split("-")
        logging.info("extract_cuswbuild_if_needed_from(): splited_sw_build = %s" % splited_sw_build)
        duSwBuild = splited_sw_build[1]
        cuSwBuild = splited_sw_build[0]
    logging.info("extract_cuswbuild_if_needed_from(): duSwBuild = %s" % duSwBuild)
    logging.info("extract_cuswbuild_if_needed_from(): cuSwBuild = %s" % cuSwBuild)
    return duSwBuild, cuSwBuild


@log_begin_end_func_name
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
    statusStr, returnStr = rbi.run_keyword_and_ignore_error("get eNB SW Version", "enb_id=%s" % enbId)
    logging.info("get_enb_sw_version_if_enb_is_present(): statusStr = %s" % statusStr)
    logging.info("get_enb_sw_version_if_enb_is_present(): returnStr = %s" % returnStr)
    return (returnStr if statusStr == "PASS" else "")


def logException(functionNameStr, e, silent=False):
    logging.info("%s(): Exception = <%s>" % (functionNameStr, str(e)))
    if not silent:
        rbi.log_to_console("  %s: exception happend (see log.html)" % functionNameStr)
