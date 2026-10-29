*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__CM__NR_Cell_power_validation_CB008992.robot

*** Test Cases ***
[1]SBTS_SBTS__CM__NR_Cell_power_validation_CB008992
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__CM__NR_Cell_power_validation_CB008992
