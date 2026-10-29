*** Settings ***
Documentation  This suite contains FM__Improved_combined_FM_service_with_multiple_alarms TC

Resource  ../test_resources/FM__Improved_combined_FM_service_with_multiple_alarms.robot


*** Test Cases ***
FM__Improved_combined_FM_service_with_multiple_alarms
    [Setup]  TC Setup
    TC__FM__Improved_combined_FM_service_with_multiple_alarms
    [Teardown]  TC Teardown
