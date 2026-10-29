*** Settings ***
Documentation  This suite contains CM__Recommissioning_delta_commissioning_with_reset TC

Resource  ../test_resources/CM__Recommissioning_delta_commissioning_with_reset.robot


*** Test Cases ***
CM__Recommissioning_delta_commissioning_with_reset
    [Setup]  TC Setup
    TC__CM__Recommissioning_delta_commissioning_with_reset
    [Teardown]  TC Teardown
