*** Settings ***
Documentation  This suite contains FM__eCPRI_RU_Fault_10_information_enriched_case_1 TC

Resource  ../test_resources/FM__eCPRI_RU_Fault_10_information_enriched_case_1.robot


*** Test Cases ***
FM__eCPRI_RU_Fault_10_information_enriched_case_1
    [Setup]  TC Setup
    TC__FM__eCPRI_RU_Fault_10_information_enriched_case_1
    [Teardown]  TC Teardown
