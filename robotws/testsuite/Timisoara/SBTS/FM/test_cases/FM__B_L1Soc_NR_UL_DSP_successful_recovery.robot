*** Settings ***
Documentation  This suite contains FM__B_L1Soc_NR_UL_DSP_successful_recovery TC

Resource  ../test_resources/FM__B_L1Soc_NR_UL_DSP_successful_recovery.robot


*** Test Cases ***
FM__B_L1Soc_NR_UL_DSP_successful_recovery
    [Setup]  TC Setup
    TC__FM__B_L1Soc_NR_UL_DSP_successful_recovery
    [Teardown]  TC Teardown
