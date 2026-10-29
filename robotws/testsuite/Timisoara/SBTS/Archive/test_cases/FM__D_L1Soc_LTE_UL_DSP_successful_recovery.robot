*** Settings ***
Resource    ../test_resources/FM__D_L1Soc_LTE_UL_DSP_successful_recovery.robot

*** Test Cases ***
FM__D_L1Soc_LTE_UL_DSP_successful_recovery
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__D_L1Soc_LTE_UL_DSP_successful_recovery
