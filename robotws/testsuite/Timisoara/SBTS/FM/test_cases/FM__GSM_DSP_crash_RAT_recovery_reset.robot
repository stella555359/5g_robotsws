*** Settings ***
Documentation  This suite contains FM__GSM_DSP_crash_RAT_recovery_reset TC

Resource  ../test_resources/FM__GSM_DSP_crash_RAT_recovery_reset.robot


*** Test Cases ***
FM__GSM_DSP_crash_RAT_recovery_reset
    [Setup]  TC Setup
    TC__FM__GSM_DSP_crash_RAT_recovery_reset
    [Teardown]  TC Teardown
