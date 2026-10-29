*** Settings ***
Resource    ../test_resources/FM__RF_Fiber_Insert_Removal_Break_both_Primary_and_Secondary_Link.robot

*** Test Cases ***
FM__RF_Fiber_Insert_Removal_Break_both_Primary_and_Secondary_Link
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__RF_Fiber_Insert_Removal_Break_both_Primary_and_Secondary_Link
