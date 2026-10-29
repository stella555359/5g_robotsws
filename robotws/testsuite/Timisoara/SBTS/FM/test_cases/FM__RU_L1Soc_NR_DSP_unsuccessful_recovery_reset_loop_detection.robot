*** Settings ***
Documentation  This suite contains FM__RU_L1Soc_NR_DSP_unsuccessful_recovery_reset_loop_detection TC

Resource  ../test_resources/FM__RU_L1Soc_NR_DSP_unsuccessful_recovery_reset_loop_detection.robot


*** Test Cases ***
FM__RU_L1Soc_NR_DSP_unsuccessful_recovery_reset_loop_detection
    [Setup]  TC Setup
    TC__FM__RU_L1Soc_NR_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]  TC Teardown
