*** Settings ***
Documentation  This suite contains WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2 TC

Resource  ../test_resources/WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2.robot


*** Test Cases ***
WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_getHistoricalAndActiveAlarmsFromIMS2
    [Teardown]  TC Teardown
