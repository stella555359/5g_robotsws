*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_CPRI_feature_activation_in_runtime_NR.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_CPRI_timing_offset_modification.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_CPRI_feature_fault_trigger.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB008004 in SBTS00 program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ASOE_AZNA_AZHA
...    PY36

*** Variables ***

*** Test Cases ***
# TL604(NSA)  --  SBTS00
[1]CB008004-SR-CC_07_CPRI_feature_activation_in_runtime_NR
    General_SiSo_CPRI_feature_activation_in_runtime_NR    duration=${300}
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}

[1]CB008004-SR-CC_05_CPRI_timing_offset_modification
    [Tags]    RF50
    General_SiSo_CPRI_timing_offset_modification

[1]CB008004-SR-CC_11_CPRI_feature_fault_trigger
    [Tags]    2S-8004    RF50
    ${fault_list}    Create List    4677
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_CPRI_feature_fault_trigger

*** Keywords ***
