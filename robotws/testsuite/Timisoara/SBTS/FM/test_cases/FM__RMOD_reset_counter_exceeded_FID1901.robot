*** Settings ***
Documentation  This suite contains FM__RMOD_reset_counter_exceeded_FID1901 TC

Resource  ../test_resources/FM__RMOD_reset_counter_exceeded_FID1901.robot


*** Test Cases ***
FM__RMOD_reset_counter_exceeded_FID1901
    [Setup]  TC Setup
    TC__FM__RMOD_reset_counter_exceeded_FID1901
    [Teardown]  TC Teardown
