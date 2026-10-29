*** Settings ***
Documentation    Author: yonna.yao@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

Resource    common_host_server.robot
Resource    common_logs_operate.robot
Resource    common_gnb.robot
Resource    common_airphone.robot
Resource    common_qualcomm.robot
Resource    common_common.robot
Resource    internal_setup_teardown.robot
Library     ../../python/tak_airphone/
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Keywords ***
SG13 Common Suite Setup
    [Arguments]    ${domain}=noklab\\
    [Documentation]    This keyword is common Suite Setup.
    ...    Examples:
    ...    | Common Suite Setup |
    robot_common_operations.Common Suite Setup
    CI_interface.Common Suite Setup
   # Set Tags     QCP_RAN_ET
    Set Tags     QCD_MN_RAN
    Clean Up Env
    Get Host IP
    Get Host Name
    ${TL_TOPOLOGY}    Set Variable    ${tl.tl_cloud_topology}
    Set Suite Variable    ${TL_TOPOLOGY}
    Get GNB Software Version
    Get Control Board Type
    Get Base Band Board Type
    #Get Test Line Type
    Run Keyword If     "${L1_TYPE}"=="${EMPTY}"    Get L1Bypass Type
    Download All Tools
    ${UE_TYPE}    internal_setup_teardown._get_ue_type
    Set Suite Variable    ${UE_TYPE}
#    Run Keyword If    '${UE_TYPE}'=='airphone'    _airphone_suite_setup
 #   Run Keyword If    '${UE_TYPE}'=='qualcomm'    _qualcomm_suite_setup    ${domain}
    Run Keyword If    '${UE_TYPE}'=='qct_dx50'    _qualcomm_suite_setup    ${domain}
    Set Suite Variable    ${MCS_CONFIG_FILE}    /home/ute/testline_configuration/${TL_NAME}/mcs_config.yml
#    Run Keyword If    '${UE_TYPE}'=='cpe'    _cpe_suite_setup
#	${ret}     run      pip list |grep -E "^ta|^ute"
#    log    ${ret}
	#${ret}   OperatingSystem.Run and return rc and output  . /home/ute/test_repo/bin/activate;pip install ta_a2a -U

SG13 Common Suite Teardown
    [Documentation]    This keyword is common Suite Teardown.
    ...    Examples:
    ...    | Common Suite Teardown |
    robot_common_operations.Common Suite Teardown
    Run Keyword If    '${UE_TYPE}'=='airphone'    Airphone Teardown
    #Run Keyword If    '${UE_TYPE}'=='qualcomm'    Qualcomm Teardown
    Run Keyword If    '${UE_TYPE}'=='cpe'    _cpe_suite_teardown


SG13 Common Test Setup
    [Documentation]    This keyword is common Test Setup. will start common logs.
    ...    Examples:
    ...    | Common Test Setup |
    ...    ${allowed_faults_ids}=49,7107 #allow multiple fault IDs
    [Arguments]    ${allowed_faults_ids}=7107
    robot_common_operations.Common Case Setup    allowed_faults_ids=${allowed_faults_ids}
    Run Keyword And Ignore Error    Set QC Tag In Case     ${TEST_NAME}     ${SOFTWARE_INFO}
    Run Keyword And Ignore Error    Start Collect Logs
    CI_interface.Common Case Setup
    run keyword and ignore error    Requset Configuration Id Report

SG13 Common Test Teardown
    [Documentation]    This keyword is common Test Teardown. will stop common logs and collect config files
    ...    Examples:
    ...    | Common Test Teardown |   |
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    Stop Collect Logs
    OperatingSystem.create directory    ${test_log_directory()}/All/
    Run Keyword And Ignore Error    Backup Scf                 ${test_log_directory()}/All/
    Run Keyword And Ignore Error    Backup Swconfig            ${test_log_directory()}/All/
    Run Keyword If    '${UE_TYPE}'=='airphone'    _airphone_test_teardown
    kill_ute_syslog_process
    CI_interface.Common Case Teardown
