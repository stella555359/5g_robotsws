*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template.robot

*** Test Cases ***
[1] NR_NR__CM__BTS1_BTS2_Planned_Recommissioning
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template

