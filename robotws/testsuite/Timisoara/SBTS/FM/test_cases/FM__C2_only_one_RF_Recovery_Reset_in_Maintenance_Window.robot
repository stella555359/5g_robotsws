*** Settings ***
Documentation  This suite contains FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window TC

Resource  ../test_resources/FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window.robot


*** Test Cases ***
FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window
    [Setup]  TC Setup
    TC__FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window
    [Teardown]  TC Teardown
