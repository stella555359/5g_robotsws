*** Settings ***
Documentation  This suite contains CM__Recommissioning_with_BTS_reset TC

Resource  ../test_resources/CM__Recommissioning_with_BTS_reset.robot


*** Test Cases ***
CM__Recommissioning_with_BTS_reset
    [Setup]  TC Setup
    TC__CM__Recommissioning_with_BTS_reset
    [Teardown]  TC Teardown
