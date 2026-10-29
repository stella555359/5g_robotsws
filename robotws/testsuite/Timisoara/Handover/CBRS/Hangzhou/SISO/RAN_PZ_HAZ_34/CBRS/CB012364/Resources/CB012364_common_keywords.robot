*** Settings ***
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Timisoara/Handover/CBRS/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../resources/cbrs_common_keywords.robot

Documentation    This is for SG8 common keywords
...              Author: wangqingqing
...              Squard: HZ SG8


*** Keywords ***
CB012364 CBRS Test Teardown
    [Arguments]    ${actCbrsEnhMeas}=${False}
    log to console    \n***CBRS Test Teardown***
    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
    robot_common_operations.CommonCaseTeardown
    set suite variable    ${test_teardown_fail}    ${False}
    Deactivate feature CBRS By Coam    actCbrsEnhMeas=${actCbrsEnhMeas}
    Connect to gnb coam via ssl
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    should be true    ${history_alarm_status}
    run keyword if test failed     Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

CB012364-A_01_NR_static_Mplane_connect_to_IPV6_Primary_DP_IP_port
    ${SCF_CB012364}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CB012364_
    Commissioning SCF And Check RU On Air   scf_file_path=${SCF_CB012364}
    start SAS server
    Activate feature CBRS By Coam
    Wait until keyword succeeds    6min    30s    verify all cells should be onair
    Wait Until Keyword Succeeds    3min    5s    Check GrantOperationState Status Success
