*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NR_NR__CM__NR_ALD_Planned_Recommissioning.robot

*** Test Cases ***
[1]NR_NR__CM__NR_ALD_Planned_Recommissioning
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NR_NR__CM__NR_ALD_Planned_Recommissioning

