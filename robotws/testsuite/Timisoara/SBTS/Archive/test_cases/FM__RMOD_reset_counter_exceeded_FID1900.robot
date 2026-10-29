*** Settings ***
Resource    ../test_resources/FM__RMOD_reset_counter_exceeded_FID1900.robot

*** Test Cases ***
FM__RMOD_reset_counter_exceeded_FID1900
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__RMOD_reset_counter_exceeded_FID1900

