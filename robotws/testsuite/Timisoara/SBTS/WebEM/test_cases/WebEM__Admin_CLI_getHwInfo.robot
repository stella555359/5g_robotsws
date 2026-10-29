*** Settings ***
Documentation  This suite contains WebEM__Admin_CLI_getHwInfo TC

Resource  ../test_resources/WebEM__Admin_CLI_getHwInfo.robot


*** Test Cases ***
WebEM__Admin_CLI_getHwInfo
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_getHwInfo
    [Teardown]  TC Teardown
