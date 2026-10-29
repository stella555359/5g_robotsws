*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__CM__Occupied_bandwidth_validation_CB008992.robot

*** Test Cases ***
[1]SBTS_SBTS__CM__Occupied_bandwidth_validation_CB008992
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__CM__Occupied_bandwidth_validation_CB008992