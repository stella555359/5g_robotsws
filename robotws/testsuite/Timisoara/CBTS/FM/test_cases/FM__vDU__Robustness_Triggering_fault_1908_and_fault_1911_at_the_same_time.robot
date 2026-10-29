*** Settings ***
Documentation  This suite contains FM__vDU__Robustness_Triggering_fault_1908_and_fault_1911_at_the_same_time TC

Resource  ../test_resources/FM__vDU__Robustness_Triggering_fault_1908_and_fault_1911_at_the_same_time.robot


*** Test Cases ***
FM__vDU__Robustness_Triggering_fault_1908_and_fault_1911_at_the_same_time
    [Setup]  TC Setup
    TC__FM__vDU__Robustness_Triggering_fault_1908_and_fault_1911_at_the_same_time
    [Teardown]  TC Teardown
