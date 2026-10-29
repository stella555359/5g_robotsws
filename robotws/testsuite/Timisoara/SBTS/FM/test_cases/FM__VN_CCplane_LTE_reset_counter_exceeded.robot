*** Settings ***
Documentation  This suite contains FM_VN_CCplane_LTE_reset_counter_exceeded TC

Resource  ../test_resources/FM__VN_CCplane_LTE_reset_counter_exceeded.robot


*** Test Cases ***
FM_VN_CCplane_LTE_reset_counter_exceeded
    [Setup]  TC Setup
    TC__FM_VN_CCplane_LTE_reset_counter_exceeded
    [Teardown]  TC Teardown
