*** Settings ***
Documentation  This suite contains WebEM__Admin_CLI_get_alarm_history_remote TC

Resource  ../test_resources/WebEM__Admin_CLI_get_alarm_history_remote.robot


*** Test Cases ***
WebEM__Admin_CLI_get_alarm_history_remote
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_get_alarm_history_remote
    [Teardown]  TC Teardown
