# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         100 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Set_the_TEST_managed_object_and_RF_diagnostic_threshold_values_online_from_BTS_Element_Manager.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_without_L3Call.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Link_Diagnostic_and_Monitoring.robot
# 
# Documentation
# ...    Author: shufei.chen
# ...    Contact: shufei.chen@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature 5GC000956
# 
# Force Tags            RAN_5G_TDD    5G_RAN_TDD    master_classicalbts_all    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED
# ...    PY36
# ...    21A_classicalbts    SBTS00    CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AAHF
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]5GC000956_Create_RFTHLD_and_Set_RF_Diagnostic_Thresholds_from_WebEM
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
#     General_SiSo_Set_the_TEST_managed_object_and_RF_diagnostic_threshold_values_online_from_BTS_Element_Manager
# 
# [1]5GC000956_Initiate_RF_Diagnostic_test_from_WebEM_normal_mode
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
#     General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_without_L3Call    low_RSSI=-160   low_RTWP=-160
# 
# [1]5GC000956_Initiate_RF_Diagnostic_test_from_WebEM_normal_mode_with_L3_call
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
#     General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call
