*** Settings ***
Documentation  This suite contains FM__eCPRI_resiliency_to_BTS_DU_FSP_Reset_Controlled_Case_testcase TC

Resource  ../test_resources/FM__eCPRI_resiliency_to_BTS_DU_FSP_Reset_Controlled_Case.robot


*** Test Cases ***
FM__eCPRI_resiliency_to_BTS_DU_FSP_Reset_Controlled_Case_testcase
    [Setup]  TC Setup
    TC__FM__eCPRI_resiliency_to_BTS_DU_FSP_Reset_Controlled_Case
    [Teardown]  TC Teardown
