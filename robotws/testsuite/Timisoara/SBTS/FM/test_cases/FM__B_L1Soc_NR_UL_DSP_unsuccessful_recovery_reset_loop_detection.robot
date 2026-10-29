*** Settings ***
Documentation  This suite contains FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection TC

Resource  ../test_resources/FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection.robot


*** Test Cases ***
FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Setup]  TC Setup
    TC__FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]  TC Teardown
