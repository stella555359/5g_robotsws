*** Settings ***
Documentation  This suite contains FM__vDU_Triggering_fault_1911 TC

Resource  ../test_resources/FM__vDU_Triggering_fault_1911.robot


*** Test Cases ***
FM__vDU_Triggering_fault_1911
    [Setup]  TC Setup
    TC__FM__vDU_Triggering_fault_1911
    [Teardown]  TC Teardown
