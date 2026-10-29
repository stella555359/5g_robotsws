*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS__CM__Re-Commissioning_of_parameter_not_implying_reset.robot

*** Test Cases ***
[1]SBTS__CM__Re-Commissioning_of_parameter_not_implying_reset
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS__CM__Re-Commissioning_of_parameter_not_implying_reset