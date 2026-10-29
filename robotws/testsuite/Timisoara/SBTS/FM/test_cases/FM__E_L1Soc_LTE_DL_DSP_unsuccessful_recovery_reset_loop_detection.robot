*** Settings ***
Documentation  This suite contains FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection TC

Resource  ../test_resources/FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection.robot


*** Test Cases ***
FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Setup]  TC Setup
    TC__FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]  TC Teardown
