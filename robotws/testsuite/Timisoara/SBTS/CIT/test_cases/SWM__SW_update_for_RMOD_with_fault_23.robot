*** Settings ***
Documentation  This suite contains SWM__SW_update_for_RMOD_with_fault_23 TC

Resource  ../test_resources/SWM__SW_update_for_RMOD_with_fault_23.robot


*** Test Cases ***
SWM__SW_update_for_RMOD_with_fault_23
    [Setup]  TC Setup
    TC__SWM__SW_update_for_RMOD_with_fault_23
    [Teardown]  TC Teardown
