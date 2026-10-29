*** Settings ***
Documentation  This suite contains CM__Commissioning__Planned_commissioning TC

Resource  ../test_resources/CM__Commissioning__Planned_commissioning.robot


*** Test Cases ***
CM__Commissioning__Planned_commissioning
    [Setup]  TC Setup
    TC__CM__Commissioning__Planned_commissioning
    [Teardown]  TC Teardown
