*** Settings ***
Documentation  This suite contains FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure TC

Resource  ../test_resources/FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.robot


*** Test Cases ***
FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Setup]  TC Setup
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]  TC Teardown
