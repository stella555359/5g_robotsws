*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NR_SBTS__CM__Re-Comissioning_NR_change_of_parameter_not_implying_reset.robot

*** Test Cases ***
[1]NR_SBTS__CM__Re-Comissioning_NR_change_of_parameter_not_implying_reset
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NR_SBTS__CM__Re-Comissioning_NR_change_of_parameter_not_implying_reset
