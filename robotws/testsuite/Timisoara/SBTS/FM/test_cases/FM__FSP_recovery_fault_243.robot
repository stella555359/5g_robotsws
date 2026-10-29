*** Settings ***
Documentation  This suite contains FM__FSP_recovery_fault_243 TC

Resource  ../test_resources/FM__FSP_recovery_fault_243.robot


*** Test Cases ***
FM__FSP_recovery_fault_243
    [Setup]  TC Setup
    TC__FM__FSP_recovery_fault_243
    [Teardown]  TC Teardown
