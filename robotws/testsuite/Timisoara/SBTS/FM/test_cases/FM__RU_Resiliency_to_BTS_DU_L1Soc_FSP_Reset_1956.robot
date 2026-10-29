*** Settings ***
Documentation  This suite contains FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_1956_testcase TC

Resource  ../test_resources/FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_1956.robot


*** Test Cases ***
FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_1956
    [Setup]  TC Setup
    TC__FM__RU_Resiliency_to_BTS_DU_L1Soc_FSP_Reset_1956
    [Teardown]  TC Teardown
