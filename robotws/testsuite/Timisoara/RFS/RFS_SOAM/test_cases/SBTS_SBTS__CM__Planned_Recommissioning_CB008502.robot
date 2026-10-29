*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__CM__Planned_Recommissioning_CB008502.robot

*** Test Cases ***
[1]SBTS_SBTS__CM__Planned_Recommissioning_CB008502
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__CM__Planned_Recommissioning_CB008502