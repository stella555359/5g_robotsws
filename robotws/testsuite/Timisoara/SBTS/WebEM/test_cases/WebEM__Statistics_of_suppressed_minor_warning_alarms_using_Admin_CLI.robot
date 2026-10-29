*** Settings ***
Documentation  This suite contains WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI TC

Resource  ../test_resources/WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI.robot


*** Test Cases ***
WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI
    [Setup]  TC Setup
    TC__WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI
    [Teardown]  TC Teardown
