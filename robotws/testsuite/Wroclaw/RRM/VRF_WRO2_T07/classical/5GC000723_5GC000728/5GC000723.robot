*** Settings ***
Documentation
...   author: Patryk Seman
...   contact: patryk.seman@nokia.com
...   This is the TESTSUITE file for feature 5GC000723

Resource         ./resources/keywords_723.robot
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py

Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   RAN_5G   RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP
...           PY36

Test Setup      Run Keyword
...             start_btslog_on_local_machine

Test Teardown   TC_teardown_723


*** Test Cases ***
[1]5GC000723_E_2_ACK_for_Bundle_MSG4
    [Documentation]  The purpose of this test is to verify if ACK/NACK for bundled MSG4 is detected successful by gNB.
    [1]5GC000723_E_2_ACK_for_Bundle_MSG4


[1]5GC000723_H_1_5MHz_successful_transition_from_RRC_Idle_to_RRC_Connected
    [Documentation]  The purpose of this test is to check if is possible successful transition
    ...              from RRC Idle to RRC Connected state.
    [1]5GC000723_H_1_5MHz_successful_transition_from_RRC_Idle_to_RRC_Connected


[1]5GC000723_H_2_5MHz_checking_if_actSACallProcessingDU_is_properly_handled_FALSE
    [Documentation]  The purpose of this test is to check if cellBarred is properly handled after set up NIDD parameter
    ...              actSACallProcessingDU to FALSE.
    [1]5GC000723_H_2_5MHz_checking_if_actSACallProcessingDU_is_properly_handled_FALSE


[1]5GC000723_F_1_10MHz_successful_transition_from_RRC_Idle_to_RRC_Connected
    [Documentation]  The purpose of this test is to verify the transition from idle to connected - 10MHz
    [1]5GC000723_F_1_10MHz_successful_transition_from_RRC_Idle_to_RRC_Connected


[1]5GC000723_F_2_15MHz_successful_transition_from_RRC_Idle_to_RRC_Connected
    [Documentation]  The purpose of this test is to verify the transition from idle to connected - 15MHz
    [1]5GC000723_F_2_15MHz_successful_transition_from_RRC_Idle_to_RRC_Connected


[1]5GC000723_F_3_20MHz_successful_transition_from_RRC_Idle_to_RRC_Connected
    [Documentation]  The purpose of this test is to verify the transition from idle to connected - 20MHz
    [1]5GC000723_F_3_20MHz_successful_transition_from_RRC_Idle_to_RRC_Connected
