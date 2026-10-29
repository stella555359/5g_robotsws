*** Settings ***
Documentation  This suite contains DEV__Commissioning_for_SBTS_with_alarms TC

Resource  ../test_resources/DEV__Commissioning_for_SBTS_with_alarms.robot


*** Test Cases ***
DEV__Commissioning_for_SBTS_with_alarms
    [Setup]  TC Setup
    TC__DEV__Commissioning_for_SBTS_with_alarms
    [Teardown]  TC Teardown
