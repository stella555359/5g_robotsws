*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__CM__Planned_Recommissioning_CB008502.robot

*** Test Cases ***
[1]NR_NR__CM__Planned_Recommissioning_CB008502
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__CM__Planned_Recommissioning_CB008502