*** Settings ***
Documentation  This suite contains WebEM__RAD_debug_parameters TC

Resource  ../test_resources/WebEM__RAD_debug_parameters.robot


*** Test Cases ***
WebEM__RAD_debug_parameters
    [Setup]  TC Setup
    TC__WebEM__RAD_debug_parameters
    [Teardown]  TC Teardown
