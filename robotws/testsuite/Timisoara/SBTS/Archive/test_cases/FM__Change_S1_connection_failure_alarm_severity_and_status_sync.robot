*** Settings ***
Resource    ../test_resources/FM__Change_S1_connection_failure_alarm_severity_and_status_sync.robot

*** Test Cases ***
FM__Change_S1_connection_failure_alarm_severity_and_status_sync
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__Change_S1_connection_failure_alarm_severity_and_status_sync

