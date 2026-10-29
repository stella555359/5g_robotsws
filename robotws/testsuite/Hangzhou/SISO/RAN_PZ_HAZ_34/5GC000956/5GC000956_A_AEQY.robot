*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call.robot
#Resource    ${BASIC_PATH_5G}/General_SiSo_Set_the_TEST_managed_object_and_RF_diagnostic_threshold_values_online_from_BTS_Element_Manager.robot
#Resource    ${BASIC_PATH_5G}/General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_without_L3Call.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature 5GC000956-A in 5G21A program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEQY
...    PY36

*** Variables ***

*** Test Cases ***
#TL318  -- 22R2
#TL567  -- 22R3
#TL569(UTE Cloud)  -- 22R4
[1][1.0] 5GC000956_AEQY_008_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call
    [Tags]    CRT_22R4    SBTS00    CRT_UTE    CDRT
    General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call

#[1][1.0] 5GC000956_AEQY_001_Set_the_TEST_managed_object_and_RF_diagnostic_threshold_values_online_from_BTS_Element_Manager
#    General_SiSo_Set_the_TEST_managed_object_and_RF_diagnostic_threshold_values_online_from_BTS_Element_Manager
#
#[1][1.0] 5GC000956_AEQY_007_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_without_L3Call
#    General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_without_L3Call

*** Keywords ***
