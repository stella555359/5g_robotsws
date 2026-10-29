*** Settings ***
Documentation  This suite contains CM__Commissioning__Planned_commissioning_without_initial_SBTS_verification TC

Resource  ../test_resources/CM__Commissioning__Planned_commissioning_without_initial_SBTS_verification.robot


*** Test Cases ***
CM__Commissioning__Planned_commissioning_without_initial_SBTS_verification
    [Setup]  TC Setup
    TC__CM__Commissioning__Planned_commissioning_without_initial_SBTS_verification
    [Teardown]  TC Teardown
