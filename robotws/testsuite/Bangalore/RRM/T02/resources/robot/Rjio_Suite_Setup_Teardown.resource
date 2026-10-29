*** Settings ***
Documentation    Author: arunkumar.a@nokia.com
...             :Only Suite Setup and tear down.
Resource    Rjio_Operation_keywords.resource
Resource    Basic_Vm_Operation.resource
Resource    variables/Rjio_variables.robot
Resource    variables/QC_Variables.robot
Resource    Common_keywords.resource
Resource    logging_keywords.resource
Library     ../python/Test_Verification_Handler.py    WITH NAME   Verify
Variables    variables/alarm_variables.py


*** Keywords ***
Common Suite Setup
    [Documentation]    Keyword for Pre-Suite-Setup
    ...    Logging Folder Creation, VM sanity, etc... does here.
    [Arguments]    ${gnb_index}=0    ${cell_id}=${cellid_0}    ${if_update_swconfig}=${False}
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%H:%M:%S
    BuiltIn.Log To Console    [ INFO ]: Common Suite Setup Started. [Time:${time_stamp}]
    # Common_keywords.do_target_sw_as_active_sw    5G_TARGET_SW=${5G_TARGET_SW}
    FOR  ${item}   IN   @{COMMON_SW_DOWNLOAD_PATH}
        Run Keyword And Continue On Failure    Basic_Vm_Operation.Remove Folder File In VM    folder_name=${item}
        sleep    1s
        Run Keyword And Continue On Failure    OperatingSystem.Create Directory    path=${item}
        sleep    2s
    END
    Run Keyword And Ignore Error    Basic_Vm_Operation.Clear Vm Pid Before Run Case
    BuiltIn.Set Suite Variable    ${suite_setup_fail_flag}    ${True}
    ${connection}    Set Variable If    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    BuiltIn.Set Suite Variable    ${connection}
    Rjio_Operation_keywords.Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    BuiltIn.Set Suite Variable      ${Active_SW_version}
    ${SW_stream}   String.Split String    string=${Active_SW_version}   separator=_    max_split=1
    BuiltIn.Set Suite Variable    ${SW_stream}
    BuiltIn.Set Suite Variable    ${abbr_SW_stream}    ${SW_stream}[0]
    ${Golden_SCF_Path}    Rjio_Operation_keywords.Get Golden SCF Path    gnb_index=${gnb_index}
    BuiltIn.Set Suite Variable      ${Golden_SCF_Path}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    BuiltIn.Set Suite Variable      ${gNb_CuType}
    # Run Keyword If     ${if_update_swconfig}    update swconfig for gNB    connection=${connection}
    Generate suite log path
    BuiltIn.Set Suite Variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Scf_selection_depends_on_sw_version 
    Wait Until Keyword Succeeds    5min    30s    Rjio_Operation_keywords.Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    # Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    # BuiltIn.Set Suite Variable    ${scf_path}
    Rjio_Operation_keywords.Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${main_scf_path}    cell_id=${cell_id}
    BuiltIn.Log To Console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    BuiltIn.Set Suite Variable    ${BTS_name}    MRBTS-${mrbtsID}
    BuiltIn.Set Suite Variable    ${NRBTS_NAME}    NRBTS-${nrbtsID}
    BuiltIn.Log To Console   [ INFO ]: BTS Name: ${BTS_name}
    BuiltIn.Log To Console   [ INFO ]: BTS Name: ${BTS_name}
    BuiltIn.Set Suite Variable    ${nrbts_object_name}   MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    BuiltIn.Log To Console   [ INFO ]: nrpgrp object name : ${nrbts_object_name}
    BuiltIn.Set Suite Variable    ${nrpgrp_object_class_name}    NRPGRP
    BuiltIn.Log To Console   [ INFO ]: nrpgrp object class name: ${nrpgrp_object_class_name}
    BuiltIn.Set Suite Variable    ${nrpgrp_object_class_instance_0}    ${nrbts_object_name}/NRPGRP-${nrpgrp_id_0}
    BuiltIn.Set Suite Variable    ${nrpgrp_object_class_instance_1}    ${nrbts_object_name}/NRPGRP-${nrpgrp_id_1}
    BuiltIn.Set Suite Variable    ${nrpgrp_object_class_instance_2}    ${nrbts_object_name}/NRPGRP-${nrpgrp_id_2}
    BuiltIn.Set Suite Variable    ${suite_setup_fail_flag}    ${False}
    ${att}    Common_keywords.Setup Attenuation Using Taf    ports=${Attenuator_Ports_1061_1063}
    BuiltIn.Set Suite Variable    ${att}
    BuiltIn.Set Suite Variable    ${Syslog_operation_path}
    Run Keyword And Ignore Error    Create Directory    path=/tmp/btslog2
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%H:%M:%S
    BuiltIn.Log To Console    [ INFO ]: Suite Setup Completed. [Time:${time_stamp}]

Common Suite Teardown
    [Documentation]    Post test execution Keyword. Teardown, Reporting portal update, ect..
    ...    Handling in this keyword
    [Arguments]    ${gnb_index}=${0}
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%H:%M:%S
    BuiltIn.Log To Console    [ INFO ]: Suite Teardown Started. [Time:${time_stamp}]
    robot_common_operations.Common Suite Teardown
    ${connection}    BuiltIn.Set Variable If    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    BuiltIn.Wait Until Keyword Succeeds    5min    30s    Rjio_Operation_keywords.Connect to gnb coam via ssl    connection=${connection}
    ...        gnb_index=${gnb_index}
    # BuiltIn.Run Keyword If    (${save_snapshot} and ${suite_setup_fail_flag})    run keywords    Save Coam Snapshot
    # ...    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}    AND    Save Coam im snapshot
    # ...    target_dir=${SAVE LOG DIRECTORY}
    # ...    connection=${connection}
    # ...    AND    
    # ...    Capture RU logs    target_dir=${SAVE LOG DIRECTORY}    connection=${connection}
    # ...    gnb_index=${gnb_index}
    # ...    ELSE    log to console    [ INFO ]: don't collect snapshot in suite teardown!!!
    COAM Teardown gnb connections    ${connection}
    BuiltIn.Run Keyword And Ignore Error    process.Terminate All Processes    kill=True
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%H:%M:%S
    BuiltIn.Log To Console    [ INFO ]: Suite Teardown Ended. [Time:${time_stamp}]

Common Test Setup
    [Documentation]    Keyword does the Test Pre Checks and conditions.
    [Arguments]    ${gnb_index}=${0}
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%H:%M:%S
    BuiltIn.Log To Console    [ INFO ]: Test Setup Started. [Time:${time_stamp}]
    Set Test Variable    ${save_log_directory}    ${Test_log_path_base}/${TEST_NAME}
    Set Test Variable    ${snapshot_path}    ${save_log_directory}/snapshot
    # Set Test Variable    ${connection}    connection
    ${connection}    BuiltIn.Set Variable If    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    robot_common_operations.Common Case Setup
    BuiltIn.Log To Console    gNB CU type:${gNb_CuType}
    BuiltIn.Log To Console    Active_SW_version(gNB):${Active_SW_version}
    BuiltIn.Run Keyword If    ('${gNb_CuType}'=='NSA' or '${gNb_CuType}'=='SA+NSA')    
    ...    Run Keyword And Ignore Error    Log to console    Active_SW_version(eNB):${enb_active_version}
    ${TS_CASE_LOG_PATH}    Generate test case log path
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%H-%M-%S
    BuiltIn.Set Test Variable    ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    OperatingSystem.Create Directory    ${TS_CASE_LOG_PATH}
    BuiltIn.Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    BuiltIn.Log To Console    [ INFO ]: case log path:${TS_CASE_LOG_PATH}
    BuiltIn.Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    BuiltIn.Wait Until Keyword Succeeds    5min    30s    Rjio_Operation_keywords.Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${ru_status}    BuiltIn.Run Keyword And Return Status
    ...    Rjio_Operation_keywords.COAM Check GNB RU Status    connection=${connection}
    ${cell_status}    BuiltIn.Run Keyword And Return Status
    ...    Check All Cells Info Should Be Onair    connection=${connection}
    ${Status}    ${key}    BuiltIn.Run Keyword And Ignore Error    get specified scf
    ${SCF_Path}    BuiltIn.Set Variable If    '${Status}'=='PASS'    ${key}[0]    ${Golden_SCF_Path}
    ${SCF_Status}    BuiltIn.Set Variable If    '${Status}'=='PASS'    ${key}[1]    ${False}
    BuiltIn.Set Test Variable    ${Case_SCF_Path}    ${SCF_Path}
    IF  (${ru_status}!=${True} or ${cell_status}==${False} or (${SCF_Status}==${True} and ${gnb_index}==0))
        Fail    msg=Test Pre-Check Failed. RU or Cell or Scf Status not ready.
    ELSE
        ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%H:%M:%S
        BuiltIn.Log To Console    [ INFO ]: BTS Site Commission Started. [Time:${time_stamp}]
        Commissioning SCF And Check On Air    bts_id=${mrbts_id}    Commission_file=${Golden_SCF_Path}
        ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%H:%M:%S
        BuiltIn.Log To Console    [ INFO ]: BTS Site Commission Ended. [Time:${time_stamp}]
    END
    Set Test Variable   ${syslog_path}    ${TS_CASE_LOG_PATH}Syslog
    Verify.syslog_folder_tmp_empty 
    BuiltIn.Run Keyword And Continue On Failure    OperatingSystem.Create Directory    ${syslog_path}
    Set Test Variable    ${syslog_path}
    Run Keyword If    '${testline_name}' == '7_2_RJIO1061'    Set Test Variable    ${mplane_ip}    10.58.239.140
    logging_keywords.Start_DCAP    ${mplane_ip}
    Start Btslog With Path Check    btslog_dir=${syslog_path}    btslog_operation=${Syslog_operation_path}
    BuiltIn.Run Keyword And Ignore Error    selenium_coam.close_browser
    FOR  ${test_tags}  IN  @{TEST_TAGS}
        IF  '${test_tags}' != 'Mantaray'
            ${instance_id}   Common_keywords.Get Qc Id According To Sw Release    active_sw=${Active_Sw_version}
            Set Test Variable    ${TEST_QC_ID}    ${instance_id}
        ELSE
            ${instance_id}   Common_keywords.Get Qc Id According To Sw Release    active_sw=${Target_Build}
            Set Test Variable    ${TEST_QC_ID}    ${instance_id}
        END
    END
    ${tc_config_id}  BuiltIn.Run Keyword and Ignore Error  Rjio_Operation_keywords.Link SCOUT SCF to Configuration ID for Reporting
    ...    tl_name_only=${testline_name}
    Set Test Variable   ${TC_EXE_ID}    ${tc_config_id}
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%H:%M:%S
    BuiltIn.Log To Console    [ INFO ]: TEST Setup Ended. [Time:${time_stamp}]

Common Test Teardown
    [Documentation]    Test Case Post checks and condition's
    [Arguments]    ${gnb_index}=${0}     ${is_case_teardown}=${True}    ${is_check_historyalarm}=${False}
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%H:%M:%S
    BuiltIn.Log To Console    [ INFO ]: Test Teardown Started. [Time:${time_stamp}]
    robot_common_operations.Common Case Teardown
    ${connection}    BuiltIn.Set Variable If    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    BuiltIn.Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    Rjio_Operation_keywords.Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    BuiltIn.Run Keyword And Ignore Error    logging_keywords.Stop_DCAP
    # ${ru_status}    BuiltIn.Run Keyword And Ignore Error    COAM Check GNB RU Status    connection=${connection}
    # BuiltIn.Log To Console    [ INFO ]: RU status: ${ru_status}
    ${cell_status}    BuiltIn.Run Keyword And Return Status    Check All Cells Info Should Be Onair    connection=${connection}
    BuiltIn.Should Be True    ${cell_status}
    ${alarm_status}    BuiltIn.Run Keyword And Return Status    Verify.Acitive_Alarm_Verification_Test    ${ALLOWED_FAULT}
    Log To Console    [ Debug ]: Is Any Unexpected Active Alarm Observed = ${alarm_status}
    Run Keyword And Continue On Failure    Run Keyword If    '${alarm_status}' == '${False}'     FAIL    Unexpected Alarm found.!
    BuiltIn.Should Be True    ${alarm_status}
    # ${history_alarm_status}    BuiltIn.Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    # ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=${connection}
    # BuiltIn.Run Keyword If    ${is_check_historyalarm}    should be true    ${history_alarm_status}
    BuiltIn.Run Keyword And Continue On Failure    Stop Btslog With Path Check    target_dir=${syslog_path}
    # Common Case Teardown    connection=${connection}    gnb_index=${gnb_index}
    Run Keyword If  '${TEST_STATUS}' == 'PASS'  Common_keywords.Report To Reporting Portal
    ...    verdict=passed  QC_ID=${TEST_QC_ID}  target_build=${Active_Sw_version}  RP_QC_PROJECT=${QC_Project}
    ...    ELSE  Common_keywords.Report To Reporting Portal   verdict=failed  QC_ID=${TEST_QC_ID}
    ...    target_build=${Active_Sw_version}  RP_QC_PROJECT=${QC_Project}
    BuiltIn.Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    BuiltIn.Run Keyword And Ignore Error    csn.Disconnect    connection=ASIK Master
    ${time_stamp}    DateTime.Get Current Date    result_format=%Y-%m-%d-%H:%M:%S
    BuiltIn.Log To Console    [ INFO ]: Test Teardown Ended. [Time:${time_stamp}]
