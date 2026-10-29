*** Settings ***
Documentation  This suite contains FM__vDU__RMOD_reset_counter_exceeded_FID_1901 TC

Resource  ../test_resources/FM__vDU__RMOD_reset_counter_exceeded_FID_1901.robot


*** Test Cases ***
FM__vDU__RMOD_reset_counter_exceeded_FID_1901
    [Setup]  TC Setup
    TC__FM__vDU__RMOD_reset_counter_exceeded_FID_1901
    [Teardown]  TC Teardown
