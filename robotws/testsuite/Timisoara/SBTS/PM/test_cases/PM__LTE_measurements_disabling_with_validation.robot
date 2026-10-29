*** Settings ***
Documentation  This suite contains PM__LTE_measurements_disabling_with_validation TC

Resource  ../test_resources/PM__LTE_measurements_disabling_with_validation.robot


*** Test Cases ***
PM__LTE_measurements_disabling_with_validation
    [Setup]  TC Setup
    TC__PM__LTE_measurements_disabling_with_validation
    [Teardown]  TC Teardown
