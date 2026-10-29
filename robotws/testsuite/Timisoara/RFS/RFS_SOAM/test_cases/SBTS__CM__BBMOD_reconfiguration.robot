*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS__CM__BBMOD_reconfiguration.robot

*** Test Cases ***
[1]SBTS__CM__BBMOD_reconfiguration
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS__CM__BBMOD_reconfiguration
