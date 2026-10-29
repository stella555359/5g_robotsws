*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         12h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Initiate_RF_Statistics_diagnostic_test_withL3call.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB006293 in 22R3 program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEQY
...    PY36

*** Variables ***

*** Test Cases ***
#TL567  -- 22R3
#TL569(UTE Cloud)  -- 22R4
[1]CB006293_5G_Amber_09_Initiate_RF_Statistics_diagnostic_test_withL3call
    [Tags]    CRT_22R4    SBTS00    CRT_UTE
    General_SiSo_Initiate_RF_Statistics_diagnostic_test_withL3call

#[1]CB006293_5G_Amber_01_Set_MO_TEST_and_RF_diagnostic_threshold_values_online
#    General_SiSo_Set_the_TEST_managed_object_and_RF_diagnostic_threshold_values_online_from_BTS_Element_Manager
#
#[1]CB006293_5G_Amber_02_Remote_RF_Diagnostics_new_MO_RFSTATREQ_creation
#    General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_without_L3Call
#
#[1]CB006293_5G_Amber_03_Initiate_RF_diagnostic_test_RSSI_test_withL3call
#    General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call
#
#[1]CB006293_5G_Amber_04_Initiate_RF_diagnostic_test_SINR_per_cell_test_withL3call
#    General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call
#
#[1]CB006293_5G_Amber_05_Initiate_RF_Statistics_diagnostic_test_temprature_within_the_range
#    General_SiSo_Initiate_RF_Statistics_diagnostic_test_withoutL3call
#
#[1]CB006293_5G_Amber_06_Initiate_RF_Statistics_diagnostic_test_temprature_NOT_within_the_range
#    General_SiSo_Initiate_RF_Statistics_diagnostic_test_withoutL3call    RF_temperature_high_threshold=40
#    ...    outcome=Failed
#
#[1]CB006293_5G_Amber_07_Initiate_RF_Statistics_diagnostic_test_Ethernet_packet_test
#    General_SiSo_Initiate_RF_Statistics_diagnostic_test_withoutL3call
#
#[1]CB006293_5G_Amber_08_Initiate_RF_Statistics_diagnostic_test_radio_uptime_test
#    General_SiSo_Initiate_RF_Statistics_diagnostic_test_withoutL3call
#
#[1]CB006293_5G_Amber_10_Initiate_RF_Statistics_diagnostic_test_withoutL3call
#    General_SiSo_Initiate_RF_Statistics_diagnostic_test_withoutL3call
#
#[1]CB006293_5G_Amber_11_Deletion_of_Remote_RF_diagnostic_Test_Results_when_delete_associated_cell
#    General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_without_L3Call
#
#[1]CB006293_5G_Amber_12_Deletion_of_Remote_RF_diagnostic_Statistics_Test_Results_when_delete_associated_radio
#    General_SiSo_Initiate_RF_Statistics_diagnostic_test_withoutL3call
#
#[1]CB006293_5G_Amber_13_Initiate_RF_diagnostic_test_RSSI_test_withL3call_split_mode
#    General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call
#
#[1]CB006293_5G_Amber_14_Initiate_RF_diagnostic_test_SINR_per_cell_test_withL3call_split_mode
#    General_SiSo_Initiate_RF_diagnostic_test_from_BTS_Element_Manager_with_L3Call
#
#[1]CB006293_5G_Amber_15_Initiate_RF_Statistics_diagnostic_test_withL3call_split_mode
#    General_SiSo_Initiate_RF_Statistics_diagnostic_test_withL3call

*** Keywords ***
