*** Settings ***
Documentation  This suite contains FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case TC

Resource  ../test_resources/FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case.robot


*** Test Cases ***
FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case
    [Setup]  TC Setup
    TC__FM__RU_Resiliency_to_BTS_DU_L1SoC_Reset_Controlled_Case
    [Teardown]  TC Teardown
