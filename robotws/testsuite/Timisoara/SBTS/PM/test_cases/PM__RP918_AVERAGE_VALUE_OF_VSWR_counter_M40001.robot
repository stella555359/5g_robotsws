*** Settings ***
Documentation  This suite contains PM__RP918_AVERAGE_VALUE_OF_VSWR_counter_M40001 TC

Resource  ../test_resources/PM__RP918_AVERAGE_VALUE_OF_VSWR_counter_M40001.robot


*** Test Cases ***
PM__RP918_AVERAGE_VALUE_OF_VSWR_counter_M40001
    [Setup]  TC Setup
    TC__PM__RP918_AVERAGE_VALUE_OF_VSWR_counter_M40001
    [Teardown]  TC Teardown
