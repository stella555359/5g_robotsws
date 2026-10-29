*** Settings ***
Documentation  This suite contains WebEM__Admin_CLI_getCmChangeHistoryFromIMS2 TC

Resource  ../test_resources/WebEM__Admin_CLI_getCmChangeHistoryFromIMS2.robot


*** Test Cases ***
WebEM__Admin_CLI_getCmChangeHistoryFromIMS2
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_getCmChangeHistoryFromIMS2
    [Teardown]  TC Teardown
