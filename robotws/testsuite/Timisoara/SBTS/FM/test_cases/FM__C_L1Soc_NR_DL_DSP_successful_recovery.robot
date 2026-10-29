*** Settings ***
Documentation  This suite contains FM__C_L1Soc_NR_DL_DSP_successful_recovery TC

Resource  ../test_resources/FM__C_L1Soc_NR_DL_DSP_successful_recovery.robot


*** Test Cases ***
FM__C_L1Soc_NR_DL_DSP_successful_recovery
    [Setup]  TC Setup
    TC__FM__C_L1Soc_NR_DL_DSP_successful_recovery
    [Teardown]  TC Teardown
