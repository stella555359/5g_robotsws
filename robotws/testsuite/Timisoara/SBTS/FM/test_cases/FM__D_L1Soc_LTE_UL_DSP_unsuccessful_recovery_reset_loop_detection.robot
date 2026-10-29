*** Settings ***
Documentation  This suite contains FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection TC

Resource  ../test_resources/FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection.robot


*** Test Cases ***
FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Setup]  TC Setup
    TC__FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]  TC Teardown
