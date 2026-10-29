*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    ../TestData/SISO_common_case_variables_SG8.py


*** Variables ***
@{cell_id_common}    ${1}
@{delete_cell}    ${1}

*** Keywords ***
SG8 Common case Suite Setup
    [Arguments]    ${if_commissioning}=${False}
    log to console    \n***SG8 Common case Suite Setup***
    set suite variable    ${test_teardown_fail}    ${True}
    robot_common_operations.CommonSuiteSetup
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${scf_path_common}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    set suite variable     ${scf_path_common}
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    run keyword if    ${ute_env}    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${OUTPUT DIR}
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    Run Keyword If    '${cell_type}' == 'nr_only' or '${cell_type}' == 'nr_lte'
    ...    SG8 get gNb CuType
    run keyword if    '${if_commissioning}'=='True'
    ...    Commissioning SCF And Check On Air    scf_path=${scf_path_common}
    Run Keyword If    '${cell_type}' == 'lte_only' or '${cell_type}' == 'nr_lte'
    ...    SG8 get mtbitsid and lnbtsid
    Run Keyword If    '${cell_type}' == 'nr_only' or '${cell_type}' == 'nr_lte'
    ...    SG8 get mtbitsid and nrbtsid
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}

SG8 get gNb CuType
    ${gNb_CuType}   Get gNB CU type
    set suite variable      ${gNb_CuType}

SG8 get mtbitsid and lnbtsid
    ${mrbtsID}    ${lnbtsID}    Get mrbtsID and lnbtsID via SCF    scf_path=${scf_path_common}
    log to console  MRBTS_ID:${mrbtsID}, LNBTS_ID:${lnbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${lnbtsID}

SG8 get mtbitsid and nrbtsid
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path_common}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}

SG8 Common case Test Setup
    log to console    \n***SG8 Common case Test Setup***
    robot_common_operations.CommonCaseSetup
    log to console    Active_SW_version:${Active_SW_version}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium_coam.close_browser

SG8 Common case Suite Teardown
    log to console    \n***SG8 Common case Suite Teardown***
    robot_common_operations.CommonSuiteTeardown
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    run keyword if    ${test_teardown_fail}    run keywords
    ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM    AND
    ...    Save Coam im snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM    AND
    ...    Capture RU logs    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM
    ...    ELSE
    ...    log to console    don't collect snapshot in suite teardown!!!
    COAM Teardown gnb connections
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

SG8 Common case Test Teardown
    log to console    \n***SG8 Common case Test Teardown***
    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
    robot_common_operations.CommonCaseTeardown
    set suite variable    ${test_teardown_fail}    ${False}
    Connect to gnb coam via ssl
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    run keyword if test failed     Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown
