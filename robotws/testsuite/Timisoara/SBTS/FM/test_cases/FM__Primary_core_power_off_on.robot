*** Settings ***
Documentation  This suite contains FM__Primary_Core_power_off_on TC

Resource  ../test_resources/FM__Primary_core_power_off_on.robot


*** Test Cases ***
FM__Primary_Core_power_off_on
    [Setup]  TC Setup
    TC__FM__Primary_core_power_off_on
    [Teardown]  TC Teardown
