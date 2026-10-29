*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NRL__CM__NR_Enable_Disable_Energy_Consumption_Measurement_Collection.robot

*** Test Cases ***
[1]NRL__CM__NR_Enable_Disable_Energy_Consumption_Measurement_Collection
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NRL__CM__NR_Enable_Disable_Energy_Consumption_Measurement_Collection
