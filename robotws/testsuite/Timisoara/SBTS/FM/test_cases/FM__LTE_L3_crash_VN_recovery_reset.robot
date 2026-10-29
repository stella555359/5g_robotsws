*** Settings ***
Documentation  This suite contains FM___LTE_L3_crash_VN_recovery_reset TC

Resource  ../test_resources/FM__LTE_L3_crash_VN_recovery_reset.robot


*** Test Cases ***
FM___LTE_L3_crash_VN_recovery_reset
    [Setup]  TC Setup
    TC__FM___LTE_L3_crash_VN_recovery_reset
    [Teardown]  TC Teardown
