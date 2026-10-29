*** Settings ***
Documentation  This suite contains FM__Site_reset_counter_exceeded_fid_246 TC

Resource  ../test_resources/FM__Site_reset_counter_exceeded_fid_246.robot


*** Test Cases ***
FM__Site_reset_counter_exceeded_fid_246
    [Setup]  TC Setup
    TC__FM__Site_reset_counter_exceeded_fid_246
    [Teardown]  TC Teardown
