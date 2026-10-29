*** Settings ***

Library  taf.selenium.sbts  WITH NAME  selenium_coam
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Library            random
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/android_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/admin_sbts.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/WebEM_CLI.robot



Documentation
...    author: Liqin Yang
...    contact: liqin.yang@nokia-sbell.com
...    Group: HGZ_SG5

*** Variables ***
${MRBTS_ID}                           ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${GNB_PATH}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
${dist_name}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
${ue_type_0}  samsung
${PATH_Storage}    /home/ute/CB009074
${Admin_cli_path}  /home/ute/current
# ${rmod}  "MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-1"
*** Keywords ***

Test Case Setup
    [Arguments]     ${case_name}
    ${TS_CASE_LOG_PATH}    catenate     SEPARATOR=/    ${PATH_Storage}    ${case_name}
    Set Test Variable    ${TS_CASE_LOG_PATH}
    Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}
    Run Keyword And Continue On Failure  create directory  ${PATH_Storage}/${case_name}
    robot_common_operations.Common Case Setup
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    # ${onair_status}    Run keyword and Return Status    COAM Check GNB cell on air
    ${exist_fault}    coam_gnb_classical.COAM Get active alarms
    Set test variable    ${exist_fault}
    #Run keyword If    ${onair_status}==${False}    Perform BTS Site Reset
    # COAM Wait for gnb ready and cell setup    timeout=20 min
    Set Suite Variable  ${CASE_LOG_PATH}  ${TS_CASE_LOG_PATH}
    # Enable Syslog Info Level Prints
    # Connect to Common Unit Master


Test Case Teardown
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api  timeout=900
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}    file_path=${TS_CASE_LOG_PATH}
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword If Test Passed  Run keyword And Ignore Error  Remove Directory  ${TS_CASE_LOG_PATH}  recursive=True
    Run Keyword And Ignore Error  taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
	robot_common_operations.Common Case Teardown
	CI interface.Common Case Teardown


Suite Case Setup
    Run Keyword And Ignore Error    coam.teardown
    robot_common_operations.Common Suite Setup
    CI_interface.Common Suite Setup
    log to console  Get Active SW Version
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    set suite variable      ${stream}
    Get btsname from scf
    Connect to gnb coam via ssl
    Get NR cell list
    Connect to gnb coam via ssl
    Modify actRfiTesting

Suite Case Teardown
    Check Alarm and stop robot testing when unexpected alarm raised
    robot_common_operations.Common Suite Teardown
    log to console    Suite Case Teardown
    CI_interface.Common Suite Setup

Start RF Scanning test via WEBEM
    [Arguments]    ${TECHNOLOGY_FOR_RF_SCAN}    ${RADIO_FOR_RF_SCAN}    ${CAPTURE_TYPE_FOR_RF_SCAN}
    ...     ${ANTENNA_FOR_RF_SCAN}      ${ANTENNA_PANEL}  ${timeout}=150  ${cancel_scan}=${False}
    Run Keyword If  '${CAPTURE_TYPE_FOR_RF_SCAN}' == 'Feedback Tx (PDRx)'  Change BTS R&D Parameter
    FOR    ${LOCAL_CELL}     IN    @{NR_CELL_LIST}
        Manual SiSo TEST RF Sniffing RF Scanning do capture      ${TECHNOLOGY_FOR_RF_SCAN}    ${RADIO_FOR_RF_SCAN}
        ...            ${CAPTURE_TYPE_FOR_RF_SCAN}    ${ANTENNA_FOR_RF_SCAN}
        ...            ${ANTENNA_PANEL}      ${LOCAL_CELL}  ${timeout}  ${cancel_scan}
        Exit For Loop If     '${CAPTURE_TYPE_FOR_RF_SCAN}' != 'Carrier Rx (FIR9)'
    END
    [Teardown]  Run Keyword If  '${CAPTURE_TYPE_FOR_RF_SCAN}' == 'Feedback Tx (PDRx)'  Change BTS R&D Parameter
    ...  flag=0

Manual SiSo TEST RF Sniffing RF Scanning do capture
    [Arguments]    ${TECHNOLOGY_FOR_RF_SCAN}    ${RADIO_FOR_RF_SCAN}    ${CAPTURE_TYPE_FOR_RF_SCAN}
    ...  ${ANTENNA_FOR_RF_SCAN}  ${ANTENNA_PANEL}  ${LOCAL_CELL}  ${timeout}=150  ${cancel_scan}=${False}
    Log to console  ${CAPTURE_TYPE_FOR_RF_SCAN} RF Scanning via WEBEM
    ${timestamp1}=       Get Current Date    result_format=%Y%m%d
    selenium_coam.start_rf_scan   ${TECHNOLOGY_FOR_RF_SCAN}   ${RADIO_FOR_RF_SCAN}
	...    ${CAPTURE_TYPE_FOR_RF_SCAN}   ${ANTENNA_FOR_RF_SCAN}   ${ANTENNA_PANEL}    ${LOCAL_CELL}
	...    timeout=${timeout}
    ${RF_SCAN_FILE_PATH}=    Run Keyword If  ${cancel_scan}  selenium_coam.cancel_rf_scan
    ...  ELSE    selenium_coam.download_rf_scan_files
    Run Keyword If  '${cancel_scan}'==False  Should Match Regexp  ${RF_SCAN_FILE_PATH}
    ...  RFMonitoring_${btsname}_rf-scan_${timestamp1}-\\d{4}.zip
    Run Keyword If  '${cancel_scan}'==False  Check RF scan file  ${RF_SCAN_FILE_PATH}

Change BTS R&D Parameter
    [Arguments]  ${flag}=1
    selenium_coam.Change Rd Debug Parameters  69      Dynamic changes  [{"paramIndexNumber":39, "paramValue":${flag}}]
    # selenium_coam.change_bts_rnd_parameters      69      Dynamic changes  [{"paramIndexNumber":39, "paramValue":${flag}}]
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock  version=${stream}

Modify actRfiTesting
    [Arguments]  ${value}=true  ${connection}=GNB_OAM
    Log To Console  Modify actRfiTesting to ${value}
    # Connect to gnb coam via ssl
    coam_parameter.perform_single_parameter_update  value=${value}  parameter=actRfiTesting
    ...  dist_name=${dist_name}  connection=${connection}  timeout=90

Start RF Scanning test via WEBCLI
    [Arguments]    ${CAPTURE_TYPE}="RX_COMBINED"  ${requestStatus}=completed  ${errorCode}=0
    Log to console  Start ${CAPTURE_TYPE} RF Scanning via WEBCLI
    Case Precondition
    ${json_data}  Create json data  requestId=3  CAPTURE_TYPE=${CAPTURE_TYPE}
    ${res1}=  Run     ${cli_cmd} --cli-port=${cli_daemon_port} --data=${json_data} --format='human' --output-file=rfScan.zip
    Check RF scan output  res1=${res1}  requestStatus=${requestStatus}  errorCode=${errorCode}  requestId=3
    [Teardown]  Case Postcondition

Precondition for WEBCLI case
    Test Case Setup    case_name=AQQQA_scan_test_with_Composite_Rx_via_WebEM_CLI
    Log to console  Precondition for WEBCLI case
    Create Directory    ${Admin_cli_path}
    Download Admin Cli  swversion=${Active_SW_version}
    Run Keyword And Ignore Error  Clean Testing Env
    Set Testing Env  path=${TS_CASE_LOG_PATH}/CB009074
    Get Runtime RMOD

Get Runtime RMOD
    [Arguments]  ${productName}=AQQQA  ${connection}=GNB_OAM
    @{current}=         coam.get_managed_objects
    ...                 class_name=RMOD_R
    ...                 timeout=${600}
    ...                 connection=${connection}
    ${numb_of_rus}	 Get Length  ${current}
    FOR  ${x}  IN RANGE  ${numb_of_rus}
      ${rmod_name}  Set Variable  ${current[${x}]["parameters"]["productName"]}
      ${status2}  Run Keyword And Return Status  Should Contain  ${rmod_name}  ${productName}
      Run Keyword If  ${status2}  Run Keywords  Set test Variable  ${rmod}
      ...  ${current[${x}]["distName"]}  AND  Exit For Loop
    END

Create json data
    [Arguments]    ${requestId}  ${CAPTURE_TYPE}="RX_COMBINED"
    ${json_data}=       catenate
    ...            '{"requestId": ${requestId},
    ...            "parameters": {
    ...                "name": "startRFScanningTest",
    ...                "parameters": {
    ...                    "technology":"NR_TDD",
    ...                    "radioDN":"${rmod}",
    ...                    "captureType":${CAPTURE_TYPE},
    ...                    "antennaPanel":"PHYANT_1_Full_Array"
    ...                }
    ...            }}'
    [Return]  ${json_data}

5_Start two RF Scanning test via WEBCLI
    [Arguments]    ${CAPTURE_TYPE}="RX_COMBINED"
    #   ${CAPTURE_TYPE_1}="RX_CARRIER"
    Log to console  Start ${CAPTURE_TYPE} RF Scanning via WEBCLI
    Case Precondition
    ${json_data}  Create json data  requestId=1  CAPTURE_TYPE=${CAPTURE_TYPE}
    Run  (${cli_cmd} --cli-port=${cli_daemon_port} --data=${json_data} --format='human' --output-file=rfScan.zip>${TS_CASE_LOG_PATH}/5_1.txt &)
    ${json_data}  Create json data  requestId=2  CAPTURE_TYPE=${CAPTURE_TYPE}
    Sleep  10s
    Run  (${cli_cmd} --cli-port=${cli_daemon_port} --data=${json_data} --format='human' --output-file=Scan.zip>${TS_CASE_LOG_PATH}/5_2.txt &)
    Sleep  150s
    ${res1}  Run   cat ${TS_CASE_LOG_PATH}/5_1.txt
    Check RF scan output  res1=${res1}  requestStatus=completed  errorCode=0
    ${res2}  Run   cat ${TS_CASE_LOG_PATH}/5_2.txt
    Check RF scan output  res1=${res2}  requestStatus=failed  errorCode=69  requestId=2
    [Teardown]  Case Postcondition

Check RF scan output
    [Arguments]  ${res1}  ${requestStatus}=completed  ${errorCode}=0  ${requestId}=1
    Log To Console  Check RF scan output
    &{res}=             Parse Output    ${res1}
    Should not be empty                 ${res}
    Should be equal as strings          ${res.requestId}  ${requestId}
    Should be equal as strings          ${res.requestStatus}  ${requestStatus}
    Should be equal as integers         ${res.errorCode}  ${errorCode}
    ${RF_SCAN_FILE_PATH}  Set Variable if  '${requestStatus}'=='completed'  ${res.outputFileName}
    Run Keyword If  '${requestStatus}'=='completed'  Check RF scan file  ${RF_SCAN_FILE_PATH}

Check RF scan file
    [Arguments]  ${RF_SCAN_FILE_PATH}
    Log To Console  Check RF scan file
    ${size}=  OperatingSystem.get file size  ${RF_SCAN_FILE_PATH}
    should be true  ${size} > 500
    Remove File  ${RF_SCAN_FILE_PATH}


Get NR cell list
    Log To Console  Get NR cell list
    ${NR_Cell_LIST}    Create List
  ${ALL_CELL_LIST}  testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.robot.bts.common.admin_operation.get_all_cell_id_via_admin
    ...    ru_index=1
    FOR    ${cell_id}    IN    @{ALL_CELL_LIST}
        ${status}  Run Keyword And Return Status  Get cellname from scf  cell_id=${cell_id}
        ${cellname}  Run Keyword If  ${status}  Get cellname from scf  ${cell_id}
        ...  ELSE  Set Variable  None
        Run keyword if  '${cellname}'=='None'  Append To List  ${NR_Cell_LIST}    NRCELL-${cell_id}
        ...  ELSE  Append To List  ${NR_Cell_LIST}    NRCELL-${cell_id}(${cellname})
    END
    Set Suite Variable  ${NR_Cell_LIST}

AQQQA_scan_test_with_capture_type
    [Arguments]    ${capture_type}=Composite Rx (HBF0)  ${login}=${True}
    Run keyword If  ${login}  Run keywords  Selenium Logout And Close Browser
    ...  AND  Selenium Login And Disable Screen Lock  version=${stream}
    Start RF Scanning test via WEBEM  NR TDD  RMOD-1 (AQQQA)    ${capture_type}    PHYANT 1    PHYANT-1 Full Array
    Start RF Scanning test via WEBEM  NR TDD  RMOD-1 (AQQQA)    ${capture_type}
    ...    PHYANT 1    PHYANT-1 Full Array  timeout=150  cancel_scan=${True}
    Start RF Scanning test via WEBEM  NR TDD  RMOD-1 (AQQQA)    ${capture_type}    PHYANT 1    PHYANT-1 Full Array
    [Teardown]  Run keyword If  ${login}  Run Keyword And Ignore Error  Selenium Logout And Close Browser

3_AQQQA_8D8U_scan_test_with_Carrier Rx (FIR9)
    Log to console  3_AQQQA_8D8U_scan_test_with_Carrier Rx (FIR9)
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock  version=${stream}
    Start RF Scanning test via WEBEM  NR TDD  RMOD-1 (AQQQA)    Carrier Rx (FIR9)    PHYANT 1    PHYANT-1 Full Array
    AQQQA_scan_test_with_capture_type  capture_type=Carrier Rx (FIR9)  login=${False}
    [Teardown]  Run Keyword And Ignore Error  Selenium Logout And Close Browser


7_AQQQA_scan_enable_and_disable_several_times
    [Arguments]  ${times}=2
    Log to console  7_AQQQA_scan_enable_and_disable_several_times
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock  version=${stream}
    FOR	   ${i}    IN RANGE    ${times}
        Log To Console  Repeat ${i} times
        Start RF Scanning test via WEBEM  NR TDD  RMOD-1 (AQQQA)    Composite Rx (HBF0)    PHYANT 1    PHYANT-1 Full Array
        Modify actRfiTesting  value=false
        ${status}  Run Keyword And Return Status  Start RF Scanning test via WEBEM  NR TDD  RMOD-1 (AQQQA)    Composite Rx (HBF0)
        ...    PHYANT 1    PHYANT-1 Full Array
        Should Be Equal As Strings  ${status}  false  ignore_case=True
        Modify actRfiTesting
    END
    [Teardown]  Run Keyword And Ignore Error  Selenium Logout And Close Browser

6_AQQQA_scan_test_with_Raw Composite_Rx (RxADC)_via_WebEM_and_WebEM_CLI
    Log to console  6_AQQQA_scan_test_with_Raw Composite_Rx (RxADC)_via_WebEM_and_WebEM_CLI
    ${status}  Run Keyword And Return Status  Start RF Scanning test via WEBEM  NR TDD  RMOD-1 (AQQQA)
    ...    Raw Composite Rx (RxADC)    PHYANT 1    PHYANT-1 Full Array
    Should Be Equal As Strings  ${status}  false  ignore_case=True
    Start RF Scanning test via WEBCLI  requestStatus=failed  errorCode=69
    ...  CAPTURE_TYPE="RX_COMBINED_RAW"
