*** Settings ***
Documentation  This suite contains WebEM__Admin_CLI_getActiveAlarms TC

Resource  ../test_resources/WebEM__Admin_CLI_getActiveAlarms.robot


*** Test Cases ***
WebEM__Admin_CLI_getActiveAlarms
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_getActiveAlarms
    [Teardown]  TC Teardown
