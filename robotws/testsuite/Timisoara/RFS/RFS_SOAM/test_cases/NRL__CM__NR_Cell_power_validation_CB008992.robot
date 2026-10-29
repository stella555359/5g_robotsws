*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__CM__NR_Cell_power_validation_CB008992.robot

*** Test Cases ***
[1]NRL__CM__NR_Cell_power_validation_CB008992
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__CM__NR_Cell_power_validation_CB008992
