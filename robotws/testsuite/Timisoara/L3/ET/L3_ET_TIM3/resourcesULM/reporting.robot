*** Settings ***
Documentation    Keywords related to test result reporting to ReP
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library     python/reporting.py

Resource    testline.robot


*** Keywords ***

Online Reporting to ReP
    [Documentation]
    ...    This KW can be used to trigger the reporting of a test case result to Reporting Portal.
    ...
    ...    | tcName     | QC Test Instance name including the instance number (approval version could be omitted) |
    ...    | ..     | e.g. "[1]5GC000510-C_D_UL_open_loop_power_control" |
    ...    | tsResult   | optional argument, if tsResult is omitted robot global variable ${TEST STATUS} is used. |
    ...    |            | possible values: "passed"/"failed"/"PASS"/"FAIL"/"True"/"False" (not case insensitive)  |
    ...    | pmCounters | PM Counters under test |
    ...    | ..     | e.g. "[{'piid': 'M55319C00001', 'result': 'Passed', 'value': 30}, {'piid': 'M55320C00001', 'result': 'Passed', 'value' 30}]" |
    ...    | resultDir  | result directory if it is different from the current one (e.g. for the offline reporting) |
    ...    | isForDebugging | control to omit the communication to the ReP |
    ...    | ..     | possible values: "no", "yes", "true", or "false" (case insensitive) |
    ...    | qcFilePath | path to .qc file starting from "testsuite/.." |
    ...    | gnb_id     | Id/Number of gNB |
    ...    | enb_id     | Id/Number of eNB |
    ...    | swPostFix  | post-fix string for the SW Branch in .qc file, e.g. ASIL_Parity |
    ...    
    ...    *Example*
    ...    | online Reporting to ReP | [1]5GC000510-C_D_UL_open_loop_power_control |                 |
    ...    | online Reporting to ReP | [1]5GC000510-C_D_UL_open_loop_power_control | tcResult=passed |
    ...
    ...     *Note*  please see the examples
    ...         Ulm/Common/Examples/reporting_example.robot
    ...         Ulm/Common/Examples/reporting_example.qc
    ...
    [Arguments]  ${tcName}  ${tsResult}=${None}  ${pmCounters}=${EMPTY}  ${resultDir}=${EMPTY}  ${featuresCovered}=${EMPTY}  ${isForDebugging}=No
    ...          ${qcFilePath}=${EMPTY}   ${gnb_id}=0   ${enb_id}=0   ${swPostFix}=${EMPTY}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
    ${enbSwVersion}=   get eNB SW Version if eNB is present   ${enb_id}
    ${gnbSwVersion}=   get gNB SW Build Version   ${gnb_id}   ${resultDir}
    ${swBuild}=   construct SW BUILD from   ${gnbSwVersion}   ${enbSwVersion}   ${resultDir}
    ${testLine}=   construct TESTLINE from   ${resultDir}
    @{qcInfo}=   get Info from QC File   ${resultDir}   ${qcFilePath}   ${gnbSwVersion}   ${tcName}   ${swPostFix}
    report Results to ReP   tcName=${tcName}
    ...                     tsResult=${tsResult}
    ...                     swBuild=${swBuild}
    ...                     testLine=${testLine}
    ...                     suitePath=${SUITE SOURCE}
    ...                     qcTestlabPath=@{qcInfo}[0]
    ...                     qcTestSetName=@{qcInfo}[1]
    ...                     pmCounters=${pmCounters}
    ...                     featuresCovered=${featuresCovered}
    ...                     isForDebugging=${isForDebugging}
    #--------------------------------------------------------------------------------------------------------------------------------[150 characters]
