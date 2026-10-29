*** Settings ***
Documentation  This suite contains TC__FM__SoC_reset_counter_cleared_after_one_hour TC

Resource  ../test_resources/FM__SoC_reset_counter_cleared_after_one_hour.robot


*** Test Cases ***
TC__FM__SoC_reset_counter_cleared_after_one_hour
    [Setup]  TC Setup
    FM__SoC_reset_counter_cleared_after_one_hour
    [Teardown]  TC Teardown
