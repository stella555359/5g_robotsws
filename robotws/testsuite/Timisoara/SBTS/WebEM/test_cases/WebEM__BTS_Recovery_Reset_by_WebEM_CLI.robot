*** Settings ***
Documentation  This suite contains WebEM__BTS_Recovery_Reset_by_WebEM_CLI TC

Resource  ../test_resources/WebEM__BTS_Recovery_Reset_by_WebEM_CLI.robot


*** Test Cases ***
WebEM__BTS_Recovery_Reset_by_WebEM_CLI
    [Setup]  TC Setup
    TC__WebEM__BTS_Recovery_Reset_by_WebEM_CLI
    [Teardown]  TC Teardown
