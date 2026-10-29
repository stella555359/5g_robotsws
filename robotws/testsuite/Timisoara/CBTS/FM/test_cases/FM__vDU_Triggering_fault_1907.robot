*** Settings ***
Documentation  This suite contains FM__vDU_Triggering_fault_1907 TC

Resource  ../test_resources/FM__vDU_Triggering_fault_1907.robot


*** Test Cases ***
FM__vDU_Triggering_fault_1907
    [Setup]  TC Setup
    TC__FM__vDU_Triggering_fault_1907
    [Teardown]  TC Teardown
