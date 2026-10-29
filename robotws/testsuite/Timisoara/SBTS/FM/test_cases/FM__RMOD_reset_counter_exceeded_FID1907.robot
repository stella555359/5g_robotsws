*** Settings ***
Documentation  This suite contains TC__FM__RMOD_reset_counter_exceeded_FID1907 TC

Resource  ../test_resources/FM__RMOD_reset_counter_exceeded_FID1907.robot


*** Test Cases ***
TC__FM__RMOD_reset_counter_exceeded_FID1907
    [Setup]  TC Setup
    FM__RMOD_reset_counter_exceeded_FID1907
    [Teardown]  TC Teardown
