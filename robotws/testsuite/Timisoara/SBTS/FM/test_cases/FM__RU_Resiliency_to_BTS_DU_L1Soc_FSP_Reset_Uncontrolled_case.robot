*** Settings ***
Documentation  This suite contains FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_Uncontrolled_case_testcase TC

Resource  ../test_resources/FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_Uncontrolled_case.robot


*** Test Cases ***
FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_Uncontrolled_case
    [Setup]  TC Setup
    TC__FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_Uncontrolled_case
    [Teardown]  TC Teardown
