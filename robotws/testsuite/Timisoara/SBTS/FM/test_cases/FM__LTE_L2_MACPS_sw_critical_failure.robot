*** Settings ***
Documentation  This suite contains FM__LTE_L2_MACPS_sw_critical_failure TC

Resource  ../test_resources/FM__LTE_L2_MACPS_sw_critical_failure.robot


*** Test Cases ***
TC__FM__LTE_L2_MACPS_sw_critical_failure
    [Setup]  TC Setup
    FM__LTE_L2_MACPS_sw_critical_failure
    [Teardown]  TC Teardown
