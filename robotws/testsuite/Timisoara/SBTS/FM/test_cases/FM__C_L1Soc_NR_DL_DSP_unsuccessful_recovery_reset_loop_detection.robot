*** Settings ***
Documentation  This suite contains FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection TC

Resource  ../test_resources/FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.robot


*** Test Cases ***
FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Setup]  TC Setup
    TC__FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]  TC Teardown
