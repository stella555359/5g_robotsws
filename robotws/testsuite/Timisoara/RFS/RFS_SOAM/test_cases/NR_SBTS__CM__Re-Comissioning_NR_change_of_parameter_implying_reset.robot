*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__CM__Re-Comissioning_change_of_parameter_implying_reset.robot

*** Test Cases ***
[1]NR_SBTS__CM__Re-Comissioning_NR_change_of_parameter_implying_reset
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__CM__Re-Comissioning_change_of_parameter_implying_reset
