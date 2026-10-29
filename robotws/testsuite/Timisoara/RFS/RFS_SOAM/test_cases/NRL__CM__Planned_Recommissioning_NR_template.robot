*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template.robot

*** Test Cases ***
[1]NRL__CM__Planned_Recommissioning_NR_template
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template

