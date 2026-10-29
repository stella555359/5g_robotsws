*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NRL__FM__RMOD_Voltage_threshold_check_CB009903.robot

*** Test Cases ***
[1]NRL__FM__RMOD_Voltage_threshold_check_CB009903
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NRL__FM__RMOD_Voltage_threshold_check_CB009903