*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS__CM__Planned_Recommissioning_template.robot

*** Test Cases ***
[1]SBTS__CM__Planned_Recommissioning_template
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS__CM__Planned_Recommissioning_template
