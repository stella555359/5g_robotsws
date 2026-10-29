*** Settings ***
Documentation  This suite contains WebEM__Admin_CLI_getAmfData TC

Resource  ../test_resources/WebEM__Admin_CLI_getAmfData.robot


*** Test Cases ***
WebEM__Admin_CLI_getAmfData
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_getAmfData
    [Teardown]  TC Teardown
