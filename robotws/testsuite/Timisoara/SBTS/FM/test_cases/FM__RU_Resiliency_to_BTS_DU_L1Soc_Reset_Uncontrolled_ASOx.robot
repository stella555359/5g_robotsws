*** Settings ***
Documentation  This suite contains FM__RU_Resiliency_to_BTS_DU_L1Soc_Reset_Uncontrolled_ASOx_testcase TC

Resource  ../test_resources/FM__RU_Resiliency_to_BTS_DU_L1Soc_Reset_Uncontrolled_ASOx.robot


*** Test Cases ***
FM__RU_Resiliency_to_BTS_DU_L1Soc_Reset_Uncontrolled_ASOx
    [Setup]  TC Setup
    TC__FM__RU_Resiliency_to_BTS_DU_L1Soc_Reset_Uncontrolled_ASOx
    [Teardown]  TC Teardown
