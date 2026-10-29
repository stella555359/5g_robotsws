*** Settings ***
Documentation  This suite contains FM__Trigger_and_clear_fault_181 TC

Resource  ../test_resources/FM__Trigger_and_clear_fault_181.robot


*** Test Cases ***
FM__Trigger_and_clear_fault_181
    [Setup]  TC Setup
    TC__FM__Trigger_and_clear_fault_181
    [Teardown]  TC Teardown
