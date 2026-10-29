*** Settings ***
Documentation  This suite contains WebEM__Admin_CLI_getSwVersionStatus TC

Resource  ../test_resources/WebEM__Admin_CLI_getSwVersionStatus.robot


*** Test Cases ***
WebEM__Admin_CLI_getSwVersionStatus
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_getSwVersionStatus
    [Teardown]  TC Teardown
