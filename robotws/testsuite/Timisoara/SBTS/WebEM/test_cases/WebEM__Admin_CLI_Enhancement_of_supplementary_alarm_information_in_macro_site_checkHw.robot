*** Settings ***
Documentation  This suite contains WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_checkHw TC

Resource  ../test_resources/WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_checkHw.robot


*** Test Cases ***
WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_checkHw
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_Enhancement_of_supplementary_alarm_information_in_macro_site_checkHw
    [Teardown]  TC Teardown
