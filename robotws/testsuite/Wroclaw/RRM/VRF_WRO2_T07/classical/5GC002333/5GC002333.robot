*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   This is the TESTSUITE file for feature 5GC002333

Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/swconfig.py
Resource        ./resources/keywords_2333.robot

Suite Setup     prepare_swconfig

Test Setup      start_btslog_on_local_machine

Test Teardown   TC_teardown_2333


*** Test Cases ***
[1]5GC002333_K_3_20MHz_successful_transition_from_RRC_Idle_to_RRC_Connected
    [1]5GC002333_K_3_20MHz_successful_transition_from_RRC_Idle_to_RRC_Connected


[1]5GC002333_K_4_5MHz_successful_transition_from_RRC_Idle_to_RRC_Connected
    [1]5GC002333_K_4_5MHz_successful_transition_from_RRC_Idle_to_RRC_Connected


[1]5GC002333_K_5_RRC_connection_establishment_failure_in_gNB_CU_CP_RRC_Rejection
    [1]5GC002333_K_5_RRC_connection_establishment_failure_in_gNB_CU_CP_RRC_Rejection


[1]5GC002333_J_1_RRC_connection_establishment_failure_in_gNB_DU_RRC_Rejection
    [1]5GC002333_J_1_RRC_connection_establishment_failure_in_gNB_DU_RRC_Rejection
