*** Settings ***
Documentation     author: Chen Liang
...               contact: liang.6.chen@nokia-sbell.com

Suite Setup          Common Suite Setup 7841
Suite Teardown       Common Suite Teardown
Test Setup   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
Test Timeout         12h

Resource    CaseResource/BTS_startup_Cooled_SFP_or_SFP28_transceivers_support_for_FH_interface.robot
Resource    CaseResource/BTS_startup_SFP_or_SFP28_transceivers_start_up_support_for_backhaul_interface.robot
Resource    CaseResource/Operator_BTS_startup_SFP_or_SFP28_transceivers_support_for_fronthaul_and_backhaul_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    ../../../resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G
*** Variables ***
@{ALL_TEST_STATUS}

*** Test Cases ***
[1]CB007841-5G-C_001_BTS_startup_Cooled_SFP+_or_SFP28_transceivers_support_for_FH_interface
    [Tags]    CB007841    CRT_TRUNK    CRT_22R4
    Run Keyword And Ignore Error    robot_common_operations.Common case setup
    BTS_startup_Cooled_SFP+_or_SFP28_transceivers_support_for_FH_interface
    [Teardown]    CI_interface.Common Case Teardown

[1]CB009260-SR-A_005_BTS_startup_Cooled_SFP+_or_SFP28_transceivers_support_for_interface
    [Tags]    CB009260    CRT_TRUNK    CRT_23R4
    Run Keyword And Ignore Error    robot_common_operations.Common case setup
    ${status}   Run Keyword And Return Status   Should Be Empty   ${PREV_TEST_STATUS}
    Run Keyword If   ${status}   BTS_startup_Cooled_SFP+_or_SFP28_transceivers_support_for_FH_interface
    ...   ELSE    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
    [Teardown]    CI_interface.Common Case Teardown

[1]CB007841-5G-D_001_BTS_startup_SFP+_or_SFP28_transceivers_start_up_support_for_backhaul_interface
    [Tags]    CB007841    CRT_TRUNK    CRT_22R4
    Run Keyword And Ignore Error    robot_common_operations.Common case setup
    BTS_startup_SFP+_or_SFP28_transceivers_start_up_support_for_backhaul_interface
    [Teardown]    CI_interface.Common Case Teardown

[1]CB007841-5G-E_002_Operator_BTS_startup_SFP+_or_SFP28_transceivers_support_for_fronthaul_and_backhaul_interface
    [Tags]    CB007841    CRT_TRUNK    CRT_22R4
    Run Keyword And Ignore Error    robot_common_operations.Common case setup
    Operator_BTS_startup_SFP+_or_SFP28_transceivers_support_for_fronthaul_and_backhaul_interface
    [Teardown]    Case Teardown

[1]CB007841-5G-E_001_BTS_shall_support_NIDD_parameter(EQM_APEQM-SFPOperatorMode)_to_enable_and_disable_SFP+_or_SFP28_compliance_validation
    [Tags]    CB007841    CRT_TRUNK    CRT_22R4
    Run Keyword And Ignore Error    robot_common_operations.Common case setup
    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
    [Teardown]    CI_interface.Common Case Teardown

[1]CB009260-SR-A_004_The_BTS_shall_support_NIDD_parameter_(EQM_APEQM-SFPOperatorMode)_to_enable_and_disable_SFP+_or_SFP28_compliance_validation
    [Tags]    CB009260    CRT_TRUNK    CRT_23R4
    Run Keyword And Ignore Error    robot_common_operations.Common case setup
    ${status}   Run Keyword And Return Status   Should Contain X Times   ${ALL_TEST_STATUS}   PASS   1
    Run Keyword If   ${status}   Operator_BTS_startup_SFP+_or_SFP28_transceivers_support_for_fronthaul_and_backhaul_interface
    ...   ELSE    Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
    [Teardown]    Run Keywords   CI_interface.Common Case Teardown   AND   Run Keyword If   ${status}   Case Teardown

CB007841_BTS_startup_Cooled_SFP+_or_SFP28_transceivers_support_And_NIDD_for_BH_and_FH_interface
    List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL

*** Keywords ***
Case Teardown
    sleep    15s
    Upload whitelist file    upload_whitelist_path=${SFPwhitelist_PATH}SFPwhitelist.xml
    Reset DU
    run keyword and continue on failure    check none fault 4657
    sleep    3s
    ssh.Connect to    hostname=${test_pc_host}    username=${test_pc_username}
    ...   password=${test_pc_password}    alias=test_pc
    ssh.send command    command=rm -rf ${SFPwhitelist_PATH}${SFPwhitelist_NAME}
    ...    connection=test_pc    timeout=15 s
    ssh.send command    command=rm -rf ${SFPwhitelist_PATH}log
    ...    connection=test_pc    timeout=15 s
    CI_interface.Common Case Teardown
    [Teardown]    ssh.Disconnect    connection=test_pc
