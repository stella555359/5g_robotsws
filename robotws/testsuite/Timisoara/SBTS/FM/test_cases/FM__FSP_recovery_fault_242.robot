*** Settings ***
Documentation  This suite contains FM__FSP_recovery_fault_242 TC

Resource  ../test_resources/FM__FSP_recovery_fault_242.robot


*** Test Cases ***
FM__FSP_recovery_fault_242
    [Setup]  TC Setup
    TC__FM__FSP_recovery_fault_242
    [Teardown]  TC Teardown
