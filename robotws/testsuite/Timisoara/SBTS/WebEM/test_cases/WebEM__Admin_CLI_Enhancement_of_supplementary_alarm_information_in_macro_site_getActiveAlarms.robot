*** Settings ***
Documentation  This suite contains WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_getActiveAlarms TC

Resource  ../test_resources/WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_getActiveAlarms.robot


*** Test Cases ***
WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_getActiveAlarms
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_getActiveAlarms
    [Teardown]  TC Teardown
