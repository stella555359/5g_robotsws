*** Settings ***
Documentation  This suite contains PM__LTE_Intra_eNB_Handover_Extension TC

Resource  ../test_resources/PM__LTE_Intra_eNB_Handover_Extension.robot


*** Test Cases ***
PM__LTE_Intra_eNB_Handover_Extension
    [Setup]  TC Setup
    TC__PM__LTE_Intra_eNB_Handover_Extension
    [Teardown]  TC Teardown
