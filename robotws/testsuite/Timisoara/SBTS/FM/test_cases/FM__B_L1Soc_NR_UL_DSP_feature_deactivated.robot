*** Settings ***
Documentation  This suite contains FM__B_L1Soc_NR_UL_DSP_feature_deactivated TC

Resource  ../test_resources/FM__B_L1Soc_NR_UL_DSP_feature_deactivated.robot


*** Test Cases ***
FM__B_L1Soc_NR_UL_DSP_feature_deactivated
    [Setup]  TC Setup
    TC__FM__B_L1Soc_NR_UL_DSP_feature_deactivated
    [Teardown]  TC Teardown
