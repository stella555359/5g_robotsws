*** Settings ***
Documentation  This suite contains CM__Commissioning__Configuration_reset TC

Resource  ../test_resources/CM__Commissioning__Configuration_reset.robot


*** Test Cases ***
CM__Commissioning__Configuration_reset
    [Setup]  TC Setup
    TC__CM__Commissioning__Configuration_reset
    [Teardown]  TC Teardown
