*** Settings ***
Documentation  This suite contains WebEM__IP_Connectivity_test TC

Resource  ../test_resources/WebEM__IP_Connectivity_test.robot


*** Test Cases ***
WebEM__IP_Connectivity_test
    [Setup]  TC Setup
    TC__WebEM__IP_Connectivity_test
    [Teardown]  TC Teardown
