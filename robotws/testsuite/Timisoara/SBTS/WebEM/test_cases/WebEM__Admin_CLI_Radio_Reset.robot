*** Settings ***
Documentation  This suite contains WebEM__Admin_CLI_Radio_Reset TC

Resource  ../test_resources/WebEM__Admin_CLI_Radio_Reset.robot


*** Test Cases ***
WebEM__Admin_CLI_Radio_Reset
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_Radio_Reset
    [Teardown]  TC Teardown
