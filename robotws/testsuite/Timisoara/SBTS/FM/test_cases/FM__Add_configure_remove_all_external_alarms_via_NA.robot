*** Settings ***
Documentation  This suite contains FM__Add_configure_remove_all_external_alarms_via_NA TC

Resource  ../test_resources/FM__Add_configure_remove_all_external_alarms_via_NA.robot


*** Test Cases ***
FM__Add_configure_remove_all_external_alarms_via_NA
    [Setup]  TC Setup
    TC__FM__Add_configure_remove_all_external_alarms_via_NA
    [Teardown]  TC Teardown
