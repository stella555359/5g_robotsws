*** Settings ***
Resource    ../test_resources/FM__E_L1Soc_LTE_DL_DSP_successful_recovery.robot

*** Test Cases ***
TC__FM__E_L1Soc_LTE_DL_DSP_successful_recovery
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    FM__E_L1Soc_LTE_DL_DSP_successful_recovery
