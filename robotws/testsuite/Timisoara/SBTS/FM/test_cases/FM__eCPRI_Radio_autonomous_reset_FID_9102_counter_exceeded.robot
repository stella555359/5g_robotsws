*** Settings ***
Documentation  This suite contains FM__eCPRI_Radio_autonomous_reset_FID_9102_counter_exceeded TC

Resource  ../test_resources/FM__eCPRI_Radio_autonomous_reset_FID_9102_counter_exceeded.robot


*** Test Cases ***
FM__eCPRI_Radio_autonomous_reset_FID_9102_counter_exceeded
    [Setup]  TC Setup
    TC__FM__eCPRI_Radio_autonomous_reset_FID_9102_counter_exceeded
    [Teardown]  TC Teardown
