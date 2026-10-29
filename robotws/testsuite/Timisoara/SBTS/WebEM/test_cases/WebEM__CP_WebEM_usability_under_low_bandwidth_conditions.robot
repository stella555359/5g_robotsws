*** Settings ***
Documentation  This suite contains WebEM__CP_WebEM_usability_under_low_bandwidth_conditions TC

Resource  ../test_resources/WebEM__CP_WebEM_usability_under_low_bandwidth_conditions.robot


*** Test Cases ***
WebEM__CP_WebEM_usability_under_low_bandwidth_conditions
    [Setup]  TC Setup
    TC__WebEM__CP_WebEM_usability_under_low_bandwidth_conditions
    [Teardown]  TC Teardown
