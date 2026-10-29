*** Settings ***
Documentation  This suite contains WebEM__Admin_CLI_getCellList TC

Resource  ../test_resources/WebEM__Admin_CLI_getCellList.robot


*** Test Cases ***
WebEM__Admin_CLI_getCellList
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_getCellList
    [Teardown]  TC Teardown
