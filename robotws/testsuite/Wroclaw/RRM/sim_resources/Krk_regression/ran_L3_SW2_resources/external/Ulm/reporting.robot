*** Settings ***
Documentation    Keywords related to ReP
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library     ./python/reporting.py
Resource    ./testline.robot


*** Keywords ***

Online Reporting to ReP
    [Documentation]    :Author: Nikolay Shkulepov
    ...
    ...    :param tcName: STRING - QC Test Instance name including the instance number (approval version could be omitted),
    ...           e.g. "[1]5GC000510-C_D_UL_open_loop_power_control"
    ...    :param tsResult: STRING - verification verdict, possible values: "passed" or "failed" (case insensitive)
    ...    :param pmCounters: STRING (default=EMPTY) - PM Counters under test,
    ...           e.g. "[{'piid': 'M55319C00001', 'result': 'Passed', 'value': 30}, {'piid': 'M55320C00001', 'result': 'Passed', 'value' 30}]"
    ...    :param resultDir: STRING (default=EMPTY) - result directory if it is different from the current one (e.g. for the offline reporting)
    ...    :param isForDebugging: STRING (default=no) - it helps to omit the communication to the ReP,
    ...                           possible values: "no", "yes", "true", or "false" (case insensitive)
    ...    :param qcFilePath: STRING (default=EMPTY) - path to .qc file starting from "testsuite/.."
    ...    :param gnb_id: (default=0) Id/Number of gNB
    ...    :param enb_id: (default=0) Id/Number of eNB
    ...    :param swPostFix: STRING (default=EMPTY) - post-fix string for the SW Branch in .qc file, e.g. ASIL_Parity
    ...    :Example:
    ...         online Reporting to ReP   [1]5GC000510-C_D_UL_open_loop_power_control   passed
    ...     IMPORTANT: please see the examples
    ...         Ulm/Common/Examples/reporting_example.robot
    ...         Ulm/Common/Examples/reporting_example.qc
    ...
    [Arguments]  ${tcName}  ${tsResult}  ${pmCounters}=${EMPTY}  ${resultDir}=${EMPTY}  ${featuresCovered}=${EMPTY}  ${isForDebugging}=No
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
