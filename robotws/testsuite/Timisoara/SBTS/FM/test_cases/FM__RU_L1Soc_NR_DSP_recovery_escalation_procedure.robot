*** Settings ***
Documentation  This suite contains FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure TC

Resource  ../test_resources/FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure.robot


*** Test Cases ***
FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure
    [Setup]  TC Setup
    TC__FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure
    [Teardown]  TC Teardown
