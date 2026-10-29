import os
import yaml
import json
import inspect
import platform
from taf.sw.reporting_portal import reporting_portal as ute_reporting_portal

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

rbi = BuiltIn()
trunkSwBuildStr = "SBTS00_ENB_9999"


# ====================================================================================================[120 characters]
#   Python Helper Keywords
# ====================================================================================================[120 characters]

def construct_sw_build_from(gnbSwVersion, enbSwVersion, resultDir=""):
    try:
        if resultDir:
            for element in resultDir.split("/"):
                if element.startswith("5G") and not element.startswith("5GC"):
                    gnbSwVersion = element
                    rbi.log("construct_sw_build_from(): gnbSwVersion = %s (NEW)" % gnbSwVersion, "TRACE")
                    break
    except Exception as e:
        logException("construct_sw_build_from", e)
    return gnbSwVersion + ";" + enbSwVersion if enbSwVersion else gnbSwVersion


def construct_testline_from(resultDir=""):
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
    return testLine


def get_info_from_qc_file(resultDir="", qcFilePath="", gnbSwVersion="", tcName="", swPostFix=""):
    outputList = []
    try:
        suiteDir = rbi.get_variable_value("${SUITE SOURCE}")
        if qcFilePath:
            qcInfoFilePath = suiteDir[:suiteDir.rfind("/testsuite/")] + "/" + qcFilePath
        else:
            for frame in inspect.stack():
                if "testsuite/" in frame[1]:
                    qcInfoFilePath = frame[1].replace(".py", ".qc").replace(".robot", ".qc")
                    break
            else:
                qcInfoFilePath = __file__.replace(".pyc", ".py").replace(".py", ".qc").replace(".robot", ".qc")
            if not os.path.isfile(qcInfoFilePath):
                qcInfoFilePath = suiteDir.replace(".robot", ".qc")
        outputList = get_qc_info_list(qcInfoFilePath, gnbSwVersion, tcName, swPostFix)
    except Exception as e:
        logException("get_info_from_qc_file", e)
    return outputList


def get_gnb_sw_build_version(gnbId, resultDir=""):
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
        rbi.log("get_gnb_sw_build_version(): gnbSwVersion = %s" % gnbSwVersion, "TRACE")
    except Exception as e:
        logException("get_gnb_sw_build_version", e)
    return gnbSwVersion


def get_qc_info_list(qcInfoFilePath, gnbSwVersion, tcName="", swPostFix=""):
    global global_qc_domain
    global global_qc_project
    # global_qc_domain, global_qc_project = "MN_5G", "5G"
    global_qc_domain, global_qc_project = "MN_RAN", "RAN_ST"
    qc_testlab_path, qc_test_set_name = "", ""
    rbi.log("get_qc_info_list(): trunkSwBuildStr = %s" % trunkSwBuildStr, "TRACE")
    try:
        with open(qcInfoFilePath, "rb") as jsonFile:
            qcInfo = json.load(jsonFile)
            for qcInfoKey in sorted(list(qcInfo.keys()), reverse=True):
                rbi.log("get_qc_info_list(): qcInfoKey = %s" % qcInfoKey, "TRACE")
                if "@" in qcInfoKey:
                    swBuild = qcInfoKey.split("@")[0]
                    postfix = qcInfoKey.split("@")[1]
                else:
                    swBuild = qcInfoKey
                    postfix = ""
                swBuild = "".join(swBuild.rsplit(".*", 1)) if swBuild.endswith(".*") else swBuild
                swBuild = "".join(swBuild.rsplit("*", 1)) if swBuild.endswith("*") else swBuild
                swBuild = "".join(swBuild.rsplit(".", 1)) if swBuild.endswith(".") else swBuild
                rbi.log("get_qc_info_list(): swBuild = %s" % swBuild, "TRACE")
                rbi.log("get_qc_info_list(): gnbSwVersion = %s" % gnbSwVersion, "TRACE")
                rbi.log("get_qc_info_list(): swPostFix = %s" % swPostFix, "TRACE")
                rbi.log("get_qc_info_list(): postfix = %s" % postfix, "TRACE")
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
    return [qc_testlab_path, qc_test_set_name]


def report_results_to_rep(tcName, tsResult, swBuild, testLine, suitePath, qcTestlabPath,
                          qcTestSetName, pmCounters="", featuresCovered="", isForDebugging="no"):
    uteRP = ute_reporting_portal()
    counter_results = yaml.load(pmCounters, Loader=yaml.FullLoader) if pmCounters else []
    rbi.log("reportResultsToRP(): counter_results = %s" % counter_results, "TRACE")
    features_covered = yaml.load(featuresCovered, Loader=yaml.FullLoader) if featuresCovered else []
    rbi.log("reportResultsToRP(): features_covered = %s" % features_covered, "TRACE")
    rbi.log("reportResultsToRP(): global_qc_domain = %s" % global_qc_domain, "TRACE")
    rbi.log("reportResultsToRP(): global_qc_project = %s" % global_qc_project, "TRACE")
    try:
        if not (str(isForDebugging).lower() == "yes" or str(isForDebugging).lower() == "true"):
            uteRP.report_to_rp(name=tcName,
                               qc_test_instance_name=tcName,
                               result=tsResult,
                               links={},
                               ca="",
                               add_info=["UTE", "TAF"],
                               build=swBuild,
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
                               testline=testLine)
            rbi.sleep("18s")
        else:
            rbi.log("reportResultsToRP(): =============================================================", "TRACE")
            rbi.log("reportResultsToRP(): name = %s" % tcName, "TRACE")
            rbi.log("reportResultsToRP(): result = %s" % tsResult, "TRACE")
            rbi.log("reportResultsToRP(): build = %s" % swBuild, "TRACE")
            rbi.log("reportResultsToRP(): suite_path = %s" % suitePath, "TRACE")
            rbi.log("reportResultsToRP(): qc_test_set_name = %s" % qcTestSetName, "TRACE")
            rbi.log("reportResultsToRP(): qc_testlab_path = %s" % qcTestlabPath, "TRACE")
            rbi.log("reportResultsToRP(): counter_results = %s" % counter_results, "TRACE")
            rbi.log("reportResultsToRP(): =============================================================", "TRACE")
    except Exception as e:
        logException("report_results_to_rep", e)


def get_enb_sw_version_if_enb_is_present(enbId):
    statusStr, returnStr = rbi.run_keyword_and_ignore_error("get eNB SW Version", "enb_id=%s" % enbId)
    rbi.log("get_enb_sw_version_if_enb_is_present(): statusStr = %s" % statusStr, "TRACE")
    rbi.log("get_enb_sw_version_if_enb_is_present(): returnStr = %s" % returnStr, "TRACE")
    return (returnStr if statusStr == "PASS" else "")


def logException(functionNameStr, e, silent=False):
    rbi.log("%s(): Exception = <%s>" % (functionNameStr, str(e)), "TRACE")
    if not silent:
        rbi.log_to_console("  %s: exception happend (see log.html)" % functionNameStr)
